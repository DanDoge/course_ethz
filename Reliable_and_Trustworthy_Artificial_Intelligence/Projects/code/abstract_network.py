import numpy as np
import torch
import torch.nn as nn
from networks import Normalization, SPU

check_soundness = True

def get_lower_bound(lower, upper, weight, bias):
    weight_negative = weight < 0
    weight_positive = weight > 0

    weight_positive_transpose = (weight * weight_positive)
    weight_negative_transpose = (weight * weight_negative)

    lower_out = weight_positive_transpose @ lower + weight_negative_transpose @ upper + bias

    return lower_out

def get_upper_bound(lower, upper, weight, bias):
    weight_negative = weight < 0
    weight_positive = weight > 0

    weight_positive_transpose = (weight * weight_positive)
    weight_negative_transpose = (weight * weight_negative)

    upper_out = weight_negative_transpose @ lower + weight_positive_transpose @ upper + bias

    return upper_out

def get_linear_bound(lower, upper, weight, bias):
    weight_negative = weight < 0
    weight_positive = weight > 0

    weight_positive_transpose = (weight * weight_positive)
    weight_negative_transpose = (weight * weight_negative)

    lower_out = weight_positive_transpose @ lower + weight_negative_transpose @ upper + bias
    upper_out = weight_negative_transpose @ lower + weight_positive_transpose @ upper + bias

    return lower_out, upper_out

class abstract_affine_transformer(torch.nn.Module):
    def __init__(self, weight, bias) -> None:
        super().__init__()
        self.weight = weight.clone().detach()
        self.bias = bias.clone().detach()
        self.fc_size = self.bias.shape[0]

    def forward(self, lower, upper):
        weight_negative = self.weight < 0
        weight_positive = self.weight > 0

        weight_positive_masked = (self.weight * weight_positive)
        weight_negative_masked = (self.weight * weight_negative)


        lower_out = weight_positive_masked @ lower + weight_negative_masked @ upper + self.bias
        upper_out = weight_negative_masked @ lower + weight_positive_masked @ upper + self.bias

        return lower_out, upper_out

class abstract_SPU_transformer(torch.nn.Module):
    def __init__(self, fc_size) -> None:
        super().__init__()

        self.fc_size = fc_size

        self.weight_upper = torch.zeros((fc_size))
        self.bias_upper = torch.zeros(fc_size)

        self.weight_lower = torch.zeros((fc_size))
        self.bias_lower = torch.zeros(fc_size)

        self.lambda_list = torch.zeros((fc_size, 4)).uniform_(-.1, .1) # lambda for three different cases: crossing cases have two lambdas

        self.lambda_list = torch.nn.Parameter(self.lambda_list)
        self.link_function = lambda x: torch.sin(x + 0.) / 2 + .5
        # self.link_function = torch.sigmoid

    def update_idx_lower_gtz(self, idx_lower_gtz, lower, upper, lower_out, upper_out):
        upper_out[idx_lower_gtz] = upper[idx_lower_gtz] ** 2 - 0.5
        weight_upper = upper[idx_lower_gtz] + lower[idx_lower_gtz]
        bias_upper = -upper[idx_lower_gtz] * lower[idx_lower_gtz] - .5

        lambda_to_x = lower[idx_lower_gtz] + (upper[idx_lower_gtz] - lower[idx_lower_gtz]) * self.link_function(self.lambda_list[idx_lower_gtz, 0])
        weight_lower = 2 * lambda_to_x
        bias_lower =  - lambda_to_x ** 2 - 0.5

        lower_out[idx_lower_gtz] = weight_lower * lower[idx_lower_gtz] + bias_lower
        self.weight_upper[idx_lower_gtz] = weight_upper
        self.weight_lower[idx_lower_gtz] = weight_lower
        self.bias_upper[idx_lower_gtz] = bias_upper
        self.bias_lower[idx_lower_gtz] = bias_lower

    def update_idx_upper_ltz(self, idx_upper_ltz, lower, upper, lower_out, upper_out):
        sigmoid_upper = torch.sigmoid(upper[idx_upper_ltz])
        lower_out[idx_upper_ltz] = - sigmoid_upper

        weight_lower = (torch.sigmoid(lower[idx_upper_ltz]) - sigmoid_upper) / (upper[idx_upper_ltz] - lower[idx_upper_ltz])
        bias_lower = - sigmoid_upper - weight_lower * upper[idx_upper_ltz]

        lambda_to_x = lower[idx_upper_ltz] + (upper[idx_upper_ltz] - lower[idx_upper_ltz]) * self.link_function(self.lambda_list[idx_upper_ltz, 1])
        sigmoid_lambda_to_x = torch.sigmoid(lambda_to_x)
        weight_upper = - sigmoid_lambda_to_x * (1. - sigmoid_lambda_to_x)
        bias_upper = - weight_upper * lambda_to_x - sigmoid_lambda_to_x

        upper_out[idx_upper_ltz] = weight_upper * lower[idx_upper_ltz] + bias_upper
        self.weight_upper[idx_upper_ltz] = weight_upper
        self.weight_lower[idx_upper_ltz] = weight_lower
        self.bias_upper[idx_upper_ltz] = bias_upper
        self.bias_lower[idx_upper_ltz] = bias_lower

    def forward(self, lower, upper):
        fc_size = self.fc_size

        # just in case
        upper[upper == lower] += 1e-8

        # remove dependency on previous epoches, make torch happy
        self.weight_upper = torch.zeros((fc_size))
        self.bias_upper = torch.zeros(fc_size)
        self.weight_lower = torch.zeros((fc_size))
        self.bias_lower = torch.zeros(fc_size)

        lower_out = torch.zeros_like(lower)
        upper_out = torch.zeros_like(upper)

        idx_lower_gtz = lower >= 0
        self.update_idx_lower_gtz(idx_lower_gtz, lower, upper, lower_out, upper_out)

        idx_upper_ltz = upper <= 0
        self.update_idx_upper_ltz(idx_upper_ltz, lower, upper, lower_out, upper_out)

        for i in range(fc_size):
            if lower[i] < 0 < upper[i]:
                #lower_out[i] = -.5
                sigmoid_lower = torch.sigmoid(lower[i])
                slope_tangent = -sigmoid_lower * (1. - sigmoid_lower)
                slope_line = (upper[i] ** 2 - 0.5 + sigmoid_lower) / (upper[i] - lower[i])
                if slope_line >= slope_tangent:
                    weight_upper = slope_line
                    bias_upper = -sigmoid_lower - lower[i] * weight_upper
                    upper_out[i] = torch.max(-sigmoid_lower, upper[i] ** 2 - 0.5)
                else:
                    # find a tangent line that pass through (u, u^2 - 0.5)
                    st = lower[i]
                    ed = 0.
                    while ed - st > 1e-3:
                        mid = (st + ed) / 2.
                        sigmoid_mid = torch.sigmoid(mid)
                        y_upper = -sigmoid_mid * (1. - sigmoid_mid) * (upper[i] - mid) - sigmoid_mid
                        if y_upper > upper[i] ** 2 - 0.5:
                            st = mid
                        else:
                            ed = mid
                    # lambda ranges in (lower, st)
                    lambda_to_x = lower[i] + (st - lower[i]) * self.link_function(self.lambda_list[i, 3])

                    sigmoid_lambda_to_x = torch.sigmoid(lambda_to_x)
                    weight_upper = - sigmoid_lambda_to_x * (1. - sigmoid_lambda_to_x)
                    bias_upper = - weight_upper * lambda_to_x - sigmoid_lambda_to_x 
                    upper_out[i] = weight_upper * lower[i] + bias_upper               

                if self.link_function(self.lambda_list[i, 2]) < 0.5:
                    # 0 -> negative slope, 0.5 -> y = -0.5
                    weight_lower = (1. - 2 * self.link_function(self.lambda_list[i, 2])) * ((sigmoid_lower - 0.5) / (-lower[i]))
                    bias_lower = -0.5 * torch.ones(1)
                    lower_out[i] = -.5 + weight_lower * upper[i]
                else:
                    # 0.5 -> y = -0.5, 1. -> tangent at upper[i]
                    lambda_to_x = upper[i] * (2 * self.link_function(self.lambda_list[i, 2]) - 1.)
                    weight_lower = 2 * lambda_to_x
                    bias_lower =  - lambda_to_x ** 2 - 0.5
                    lower_out[i] = weight_lower * lower[i] + bias_lower

                self.weight_upper[i] = weight_upper
                self.weight_lower[i] = weight_lower
                self.bias_upper[i] = bias_upper
                self.bias_lower[i] = bias_lower

        return lower_out, upper_out

class abstract_fully_connected(torch.nn.Module):
    def __init__(self, device, net) -> None:
        super().__init__()
        pre_layers = [Normalization(device), nn.Flatten()]
        layers = []
        fc_layers = []
        for l in net.layers:
            if type(l) == nn.Linear:
                fc_layers.append(l.weight.shape[0])
        for i, fc_size in enumerate(fc_layers):
            # 0 -> 2, 1 -> 4
            layers += [abstract_affine_transformer(net.layers[2 + 2 * i].weight, net.layers[2 + 2 * i].bias)]
            if i + 1 < len(fc_layers):
                layers += [abstract_SPU_transformer(fc_size)]
        self.pre_layers = nn.Sequential(*pre_layers)
        self.layers = nn.Sequential(*layers)
        self.net = net
        self.input_lower = None
        self.input_upper = None

    def forward(self, x, eps, true_label):
        self.true_label = true_label

        if self.input_lower is None:
            self.input_lower = torch.maximum(x - eps, torch.zeros_like(x))
            self.input_upper = torch.minimum(x + eps, torch.ones_like(x))

            self.input_lower = self.pre_layers(self.input_lower).reshape(-1)
            self.input_upper = self.pre_layers(self.input_upper).reshape(-1)

        lower = self.input_lower
        upper = self.input_upper

        if check_soundness:
            x_net = self.net.layers[1](self.net.layers[0](x))
            if (x_net.reshape(-1) < self.input_lower - 1e-5).any() or (x_net.reshape(-1) > self.input_upper + 1e-5).any():
                print("error in norm")


        for i in range(len(self.layers)):
            lower, upper = self.layers[i](lower, upper)

            if check_soundness:
                lower_bkup = lower.clone()
                upper_bkup = upper.clone()
                x_net = self.net.layers[i + 2](x_net)
                if (x_net.reshape(-1) < lower - 1e-5).any() or (x_net.reshape(-1) > upper + 1e-5).any():
                    print("error in pre backsubstitution", i)  
                    for j in range(x_net.shape[1]):
                        if (x_net[0, j] < lower[j] - 1e-5).any() or (x_net[0, j] > upper[j] + 1e-5).any():
                            print(j, x_net[0, j], lower[j], upper[j], lower_bkup[j], upper_bkup[j])
                    exit()         


            lower_backsubstituted, upper_backsubstituted = self.back_substitution(i + 1)
        
            lower = lower_backsubstituted
            upper = upper_backsubstituted

            if check_soundness and i == len(self.layers) - 1:
                x_net -= x_net[0, self.true_label].clone() 
                if (x_net.reshape(-1) < lower - 1e-5).any() or (x_net.reshape(-1) > upper + 1e-5).any():
                    print("error in post backsubstitution", i)
                    for j in range(x_net.shape[1]):
                        if (x_net[0, j] < lower[j] - 1e-5).any() or (x_net[0, j] > upper[j] + 1e-5).any():
                            print(j, x_net[0, j].item(), lower[j].item(), lower_backsubstituted[j].item(), upper_backsubstituted[j].item(), upper[j].item())

                    exit()  

        return lower, upper

    def back_substitution(self, layer_idx=None):

        if layer_idx == None:
            layer_idx = len(self.layers)

        lower = self.input_lower
        upper = self.input_upper

        dim = self.layers[layer_idx - 1].fc_size

        weight_lower = torch.eye(dim, dim)
        weight_upper = torch.eye(dim, dim)
        if layer_idx == len(self.layers):
            for i in range(dim):
                weight_lower[i, self.true_label] = weight_lower[i, self.true_label] - 1.
                weight_upper[i, self.true_label] = weight_upper[i, self.true_label] - 1.
        bias_upper = torch.zeros(dim)
        bias_lower = torch.zeros(dim)

        for layer in self.layers[:layer_idx][::-1]:
            if type(layer) == abstract_affine_transformer:
                bias_lower = bias_lower + weight_lower @ layer.bias
                weight_lower = weight_lower @ layer.weight
                
                bias_upper = bias_upper + weight_upper @ layer.bias
                weight_upper = weight_upper @ layer.weight
            elif type(layer) == abstract_SPU_transformer:
                adjusted_weight_lower = torch.zeros_like(weight_lower)
                adjusted_bias_lower = torch.zeros_like(bias_lower)
                for i in range(adjusted_weight_lower.shape[1]):
                    col_lower = weight_lower[:, i]

                    mask_positive = (col_lower > 0).int()
                    mask_negative = (col_lower < 0).int()
                    
                    res_lower_weight = mask_negative * (torch.ones_like(col_lower) * layer.weight_upper[i]) + mask_positive * (torch.ones_like(col_lower) * layer.weight_lower[i])
                    adjusted_bias_lower += mask_negative * col_lower * layer.bias_upper[i] + mask_positive * col_lower * layer.bias_lower[i]

                    adjusted_weight_lower[:, i] = res_lower_weight * col_lower

                adjusted_weight_upper = torch.zeros_like(weight_upper)
                adjusted_bias_upper = torch.zeros_like(bias_upper)
                for i in range(adjusted_weight_upper.shape[1]):
                    col_upper = weight_upper[:, i]

                    mask_positive = (col_upper > 0).int()
                    mask_negative = (col_upper < 0).int()
                    
                    res_upper_weight = mask_negative * (torch.ones_like(col_upper) * layer.weight_lower[i]) + mask_positive * (torch.ones_like(col_upper) * layer.weight_upper[i])
                    adjusted_bias_upper += mask_negative * col_upper * layer.bias_lower[i] + mask_positive * col_upper * layer.bias_upper[i]

                    adjusted_weight_upper[:, i] = res_upper_weight * col_upper

                bias_lower = bias_lower + adjusted_bias_lower
                weight_lower = adjusted_weight_lower

                bias_upper = bias_upper + adjusted_bias_upper
                weight_upper = adjusted_weight_upper


        lower_backsubstituted = get_lower_bound(lower, upper, weight_lower, bias_lower)
        upper_backsubstituted = get_upper_bound(lower, upper, weight_upper, bias_upper)

        return lower_backsubstituted, upper_backsubstituted


if __name__ == '__main__':
    from networks import FullyConnected

    DEVICE = 'cpu'
    INPUT_SIZE = 10

    # soundness check -> passed
    check_soundness = True
    for i in range(1000):
        net = FullyConnected(DEVICE, INPUT_SIZE, [100, 100, 100, 100, 100, 10]).to(DEVICE)
        abs_net = abstract_fully_connected(DEVICE, net)
        x = torch.rand([100])
        true_label = torch.argmax(net(x))
        eps = np.random.rand() * .3 + 1e-3
        lo, uo = abs_net(x, eps, true_label)
        xo = net(torch.clamp(x + torch.rand_like(x) * 2. * eps - eps, 0., 1.))[0]
        #print(xo, true_label)

        xo -= xo[true_label].clone()

        print(torch.nn.functional.relu(lo - xo).max(), torch.nn.functional.relu(xo - uo).abs().max())




        # some code trash
        '''
        lower_linear = self.lower_list[-2] # or -1, -3 ?
        upper_linear = self.upper_list[-2] # or -1, -3 ?

        weight_SPU_lower = self.layers[i].weight_lower.diag()
        weight_SPU_upper = self.layers[i].weight_upper.diag()

        bias_SPU_lower = self.layers[i].bias_lower
        bias_SPU_upper = self.layers[i].bias_upper

        weight_linear = self.layers[i - 1].weight
        bias_linear = self.layers[i - 1].bias

        weight_lower_two_layers = weight_SPU_lower @ weight_linear
        bias_lower_two_layers = weight_SPU_lower @ bias_linear + bias_SPU_lower

        weight_upper_two_layers = weight_SPU_upper @ weight_linear
        bias_upper_two_layers = weight_SPU_upper @ bias_linear + bias_SPU_upper

        lower_backsubstituted, _ = get_linear_bound(lower_linear, upper_linear, weight_lower_two_layers, bias_lower_two_layers)
        _, upper_backsubstituted = get_linear_bound(lower_linear, upper_linear, weight_upper_two_layers, bias_upper_two_layers)
        '''