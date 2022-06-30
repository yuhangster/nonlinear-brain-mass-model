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
		#Initialize the weights  and bias in layer
		self.apply(self._init_weights)
	
	def _init_weights(self, module):
		if isinstance(module, nn.Linear):
			#torch full returns a tensor matrix as initializtion for weights
			#inital to all zero
			#module.weight.data = torch.full((18,36),0.2)
			module.weight.data.zero_()
			if module.bias is not None:
				module.bias.data.zero_()

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
	
    	
	#the function is made num_function
	#split the first coefficient based on the number of the num_function
	
	#the length in every piece is the number of the equations & Xs
	#for each equation it is same as take the every row of the coefficient
	#x1 x2 ... S(x1) S(x2).... depend on the library of the function

    

#input_tensor = torch.from_numpy(x)


net = Net(4, 2)
#the dimension of the x is t by states (Xs)
x = torch.tensor([[1., 10.], [3., 7.]])
print(x.shape)
#the dimension of the y is t by states dot (Xs dot) 
y = torch.tensor([[3.,7.],[1.,10.]])
print(y.shape)

loss_function = nn.MSELoss()
optimizer = torch.optim.SGD(net.parameters(),
                             lr = 1e-3,
                             weight_decay = 1e-8)

for i in range(2):
    
	optimizer.zero_grad()
	loss = loss_function(net.forward(x), y)
	loss.backward()
	
	
	for param in net.parameters():
		#print(param.grad.shape)
		#this shape is the shape of the coefficient 
		#the model dimension (4,2) --- 2 by 4
		#1:3 does not include the index at 3  
		
		#eq1  3
		param.grad[0,:3] = 0
		param.grad[0,4:] = 0
		#eq2  4
		param.grad[1,:4] = 0
		param.grad[1,5:] = 0
		#eq3  5
		param.grad[2,:5] = 0
		param.grad[2,6:] = 0
		#eq4  0 3 26
		param.grad[3,1:3] = 0
		param.grad[3,4:26] = 0
		param.grad[3,27:] = 0
		#eq5  1 4 18 35
		param.grad[4,0:1] = 0
		param.grad[4,2:4] = 0
		param.grad[4,5:18] = 0
		param.grad[4,19:35] = 0
		#eq6  2 5 24
		param.grad[5,:2] = 0
		param.grad[5,3:5] = 0
		param.grad[5,6:24] = 0
		param.grad[5,25:] = 0
		#eq7  7
		param.grad[6,:7] = 0
		param.grad[6,8:] = 0
		#eq8  6 7 26 35
		param.grad[7,0:6] = 0
		param.grad[7,8:26] = 0
		param.grad[7,27:35] = 0
		#eq9
		param.grad[8,:] = 0

		#eq10 12
		param.grad[9,:12] = 0
		param.grad[9,13:] = 0
		#eq11 13
		param.grad[10,:13] = 0
		param.grad[10,14:] = 0
		#eq12 14
		param.grad[11,:14] = 0
		param.grad[11,15:] = 0
		#eq13 9 12 26 35
		param.grad[12,:9] = 0
		param.grad[12,10:12] = 0
		param.grad[12,13:26] = 0
		param.grad[12,27:35] = 0
		#eq14 10 13 18
		param.grad[13,:10] = 0
		param.grad[13,11:13] = 0
		param.grad[13,14:18] = 0
		param.grad[13,19:] = 0
		#eq15 11 14 33
		param.grad[14,:11] = 0
		param.grad[14,12:14] = 0
		param.grad[14,15:33] = 0
		param.grad[14,34:] = 0
		#eq16 16
		param.grad[15,:16] = 0
		param.grad[15,17:] = 0
		#eq17 15 16 35
		param.grad[16,:15] = 0
		param.grad[16,17:35] = 0
		#eq18
		param.grad[17,:] = 0
	
	optimizer.step()
	print(i,' : ',list(net.parameters()))
	print(net.forward(x).detach(),y)


# all_params = net.parameters()
# for p in all_params:
#     print(p.detach().numpy())

printEq(net.parameters())
# #the function is it for the meaking the funcstion 
# #the other this thing 
# #from theshiping thing tha fir the accutsation the for