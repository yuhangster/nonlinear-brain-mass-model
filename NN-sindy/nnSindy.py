import torch 
from torch import nn
import numpy as np

class Net(torch.nn.Module):
	def __init__(self, input_dim, output_dim):
		super().__init__()
		#input dimension by output dimension is like a tranform matrix
		#with dimeneison in by out
		#ex: if the inputs are a 2x3, input dim is 3, output dim is 1
		#then the outputs are  2x1  
		#inputs are t by 18
		#input dimension is 18
		#output dimension is 9
		#outputs are t by 9
		self.inputDim = input_dim
		self.outputDim = output_dim

		self.layer = nn.Linear(self.inputDim, self.outputDim, bias = False)
		# Freeze weights in layer

	def forward(self, x):
		#make modification of x
		temp_x = x_ext(x)
		#print(temp_x)
		return self.layer(temp_x)

#extend the input x with functions in the function library
#input: x the input matrix  (time steps by categories)
#output: extended x (time steps by categories*number of functions)
def x_ext (x):
	num_func = 2; 
	#x.shape[0]: number of t
	#x.shape[1]: number of Xs
	#number of function in function library is 2
	x_ext = np.zeros([x.shape[0],x.shape[1]*num_func])
	#print(x.shape[0],x.shape[1])
	x_ext[:,0:x.shape[1]] = x
	x_ext[:,x.shape[1]:] = array_map(x)
	x_ext = x_ext.astype(np.float32)
	#print('x_ext: ',x_ext.shape)
	return torch.from_numpy(x_ext)
	
#the functions library that used for training
#def fuc_lib():
#	return
def S(x):
	# return customed sigmoid of x
	e0 = 2.5
	r = 0.56
	fr = -e0 + 2*e0/(1+np.exp(-r*x));
	return fr

def array_map(x):
	b = [ np.array(t) for t in list(map(S, x)) ]
	a = np.array(b)
	#print(a)
	#print (type(a),a.shape)
	return torch.from_numpy(a)

#the all_params takes the value net.parameter
def printEq(all_params):
	for i, p in enumerate(all_params):
    	#first p is with x second p is bias
		if i == 0:
			mx = p.detach().numpy()
			#mx.shape[0] is number of equations
			#Initialize the bias to zero 
			bias = np.zeros(mx.shape[0])
		elif i == 1:
			bias = p.detach().numpy()
			
	#total number of j equal to the number of equations
	for j in range(mx.shape[0]):
		#print(mx[j,:], bias[j])
		combEq(mx[j,:],bias[j],mx.shape[0],(j+1))
	

def combEq (ary, bias,funcNum, num):
    #check if the length of array input is integer multiplicit of funcNum
	if len(ary)%funcNum != 0:
		print ('Mismatch of number of coefficient and function.')
		return
	segment = int(len(ary)/funcNum)
	print('x' + str(num) + ' dot = ', end = ' ')
	for i in range(segment):
		temp = ary[i*funcNum:i*funcNum+segment]
		#make it case dependent for now later use a library
		if i == 0:
			for j in range(len(temp)):
				print(temp[j],'*x'+ str(j+1) +' + ', end = ' ')
		if i == 1:
			for k in range(len(temp)):
				print(temp[k],'* S(x'+ str(k+1) +') + ', end = ' ')
	print(bias)	
	
    	
# 	#the function is made num_function
# 	#split the first coefficient based on the number of the num_function
	
# 	#the length in every piece is the number of the equations & Xs
# 	#for each equation it is same as take the every row of the coefficient
# 	#x1 x2 ... S(x1) S(x2).... depend on the library of the function

    

# #input_tensor = torch.from_numpy(x)


# net = Net(4, 2)
# #the dimension of the x is t by states (Xs)
# x = torch.tensor([[1., 10.], [3., 7.]])
# print(x.shape)
# #the dimension of the y is t by states dot (Xs dot) 
# y = torch.tensor([[3.,7.],[1.,10.]])
# print(y.shape)

# loss_function = nn.MSELoss()
# optimizer = torch.optim.SGD(net.parameters(),
#                              lr = 1e-3,
#                              weight_decay = 1e-8)

# for i in range(100):
    
# 	optimizer.zero_grad()
# 	loss = loss_function(net.forward(x), y)
# 	loss.backward()
# 	'''
# 	j = 1
# 	for param in net.parameters():
# 		#print(param.grad)
# 		if j == 1:
# 			param.grad[0,1:3] = 0
# 			j += 1 
# 	'''
# 	optimizer.step()

# ###

# print(i,' : ',list(net.parameters()))
# print(net.forward(x).detach(),y)

# all_params = net.parameters()
# for p in all_params:
#     print(p.detach().numpy())

# printEq(net.parameters())
# #the function is it for the meaking the funcstion 
# #the other this thing 
# #from theshiping thing tha fir the accutsation the for