import argparse
import torch
from torch.nn.modules.padding import ReplicationPad1d
from torch.optim import lr_scheduler
from networks import FullyConnected
from abstract_network import *

DEVICE = 'cpu'
INPUT_SIZE = 28


def analyze(net, inputs, eps, true_label):
    abs_net = abstract_fully_connected(DEVICE, net)
    num_epoch = 500 # loop
    optim_per_layer = True

    param_list = []
    for idx, layer in enumerate(abs_net.layers):
        if type(layer) == abstract_SPU_transformer:
            param_list.extend(layer.parameters())
            
            if optim_per_layer:
                optimizer = torch.optim.Adam(param_list, lr = .1)
                for epoch in range(10):
                    lo, uo = abs_net(inputs, eps, true_label)
                    if 0 >= torch.max(uo):
                        return 1

                    loss = torch.sum(torch.nn.functional.relu(uo))
                    if epoch and epoch % 1000 == 0:
                        print(uo[uo > 0].detach().numpy())
                    optimizer.zero_grad()
                    loss.backward(retain_graph=False)
                    optimizer.step()

    optimizer = torch.optim.Adam(param_list, lr = .1)
    for epoch in range(num_epoch):
        lo, uo = abs_net(inputs, eps, true_label)
        if 0 >= torch.max(uo):
            return 1

        loss = torch.sum(torch.nn.functional.relu(uo))
        if epoch and epoch % 1000 == 0:
            print(uo[uo > 0].detach().numpy())
        optimizer.zero_grad()
        loss.backward(retain_graph=False)
        optimizer.step()

    #print(uo.max().item())
    return 0


def main():
    parser = argparse.ArgumentParser(description='Neural network verification using DeepPoly relaxation')
    parser.add_argument('--net',
                        type=str,
                        required=True,
                        help='Neural network architecture which is supposed to be verified.')
    parser.add_argument('--spec', type=str, required=True, help='Test case to verify.')
    args = parser.parse_args()

    with open(args.spec, 'r') as f:
        lines = [line[:-1] for line in f.readlines()]
        true_label = int(lines[0])
        pixel_values = [float(line) for line in lines[1:]]
        eps = float(args.spec[:-4].split('/')[-1].split('_')[-1])

    if args.net.endswith('fc1'):
        net = FullyConnected(DEVICE, INPUT_SIZE, [50, 10]).to(DEVICE)
    elif args.net.endswith('fc2'):
        net = FullyConnected(DEVICE, INPUT_SIZE, [100, 50, 10]).to(DEVICE)
    elif args.net.endswith('fc3'):
        net = FullyConnected(DEVICE, INPUT_SIZE, [100, 100, 10]).to(DEVICE)
    elif args.net.endswith('fc4'):
        net = FullyConnected(DEVICE, INPUT_SIZE, [100, 100, 50, 10]).to(DEVICE)
    elif args.net.endswith('fc5'):
        net = FullyConnected(DEVICE, INPUT_SIZE, [100, 100, 100, 100, 10]).to(DEVICE)
    else:
        assert False

    net.load_state_dict(torch.load('../mnist_nets/%s.pt' % args.net, map_location=torch.device(DEVICE)))

    inputs = torch.FloatTensor(pixel_values).view(1, 1, INPUT_SIZE, INPUT_SIZE).to(DEVICE)
    outs = net(inputs)
    pred_label = outs.max(dim=1)[1].item()
    assert pred_label == true_label

    if analyze(net, inputs, eps, true_label):
        print('verified')
    else:
        print('not verified')


if __name__ == '__main__':
    main()
