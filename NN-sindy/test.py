import torch
from torch import nn
import numpy as np


class Net(torch.nn.Module):
	def __init__(self):
		super().__init__()

		self.inputDim = 2
		self.outputDim = 1

		self.layer = nn.Linear(self.inputDim, self.outputDim,bias = False)

		# Freeze weights in layer

	def forward(self, x):
		
		return self.layer(x)


net = Net()
x = torch.tensor([[1., 2.], [1.,1.]])
print(x.shape)
y = torch.tensor([[4.],[6.]])
print(y.shape)

loss_function = nn.MSELoss()
optimizer = torch.optim.SGD(net.parameters(),
                             lr = 1e-1,
                             weight_decay = 1e-8)

###
###After you calculate gradient using backward() function, call

###param.grad[:, 1:10, :, :] = 0

for i in range(10):

	optimizer.zero_grad()
	loss = loss_function(net.forward(x), y)
	loss.backward()
	
	#for Bias term
	#j = 1
	# for param in net.parameters():
	# 	print(param.grad.shape)
	# 	#if j == 1:
	# 		# param.grad[0,1:] = 0
	# 		# j += 1
	# 	param.grad[0,1:] = 0

	print(net.parameters.shape)
	net.parameters.grad[0,1:] = 0
	
	optimizer.step()
	print(i,' : ',list(net.parameters()))
	print(net.forward(x).detach(),y)