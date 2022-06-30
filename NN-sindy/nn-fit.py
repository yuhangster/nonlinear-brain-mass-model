from nnSindy import *
import numpy as np
import pysindy as ps
import scipy.io
from numpy import diff

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy.integrate import solve_ivp
from sklearn.linear_model import Lasso

# Case: Two columns

#use all the trial as training data set
trial = 10
arrayNum = 10
#16 states representing column 1 0-7 and column 2 8-15 
t_train = [] 
x_train = []
xdot_train = []

#only one mat file 
for i in range (10,arrayNum+1):
    mat = scipy.io.loadmat(r'C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\data2col-noisyIn\data2col_' + str(i) +'.mat')
    for j in range (trial):
        #get the data
        tp_t = mat.get("data_t")
        tp_x = mat.get("data_x")
        tp_xdot = mat.get("data_xdot")
        t_train.append(tp_t[:,:,j])
        x_train.append(tp_x[:,:,j])
        xdot_train.append(tp_xdot[:,:,j])

print('shape of single training set: ', x_train[0].shape)
print('type of the training set: ', type(x_train[0]))
print('number of training trials: ',len(t_train))
print('shape of single time set: ', t_train[0].shape)
print('type of the training set: ', type(t_train[0]))

#plot the data
#fig, ax = plt.subplots( nrows=1, ncols=1 )  # create figure & 1 axis
# i = 0
# for trl in x_train:
#     cl1 = [trl[1,:] - trl[2,:]]
#     cl1 = np.array(cl1)
#     print(type(cl1))
#     cl2 = [trl[9,:] - trl[10,:]]
#     cl2 = np.array(cl2)
    
#     #ax.plot(t_train[0],cl1,'k')
    
#     plt.plot(t_train[0],cl2,'k')
#     plt.show()
#     i+=1
#fig.savefig(r'C:\Users\l2016\GitHub\nonlinear-brain-mass-model\training-data.png')   # save the figure to file
#plt.close(fig)

#include the x2 -x3 and x9 -x10 in x_train
#which is index 1 - index 2 and index 8 - index 9

xTrain = np.array(x_train)
print(xTrain.shape)
xdotTrain = np.array(xdot_train)
xTrain = xTrain.reshape(-1, *xTrain.shape[-1:])
xdotTrain = xdotTrain.reshape(-1, *xdotTrain.shape[-1:])
print('xTrain shape is ', xTrain.shape)
print('xdotTrain shape is', xdotTrain.shape)

temp_x = np.zeros((98910,18))
temp_x[:,0:7] = xTrain[:,0:7]
temp_x[:,8] = xTrain[:,1] - xTrain[:,2]
temp_x[:,9:16] = xTrain[:,8:15]
temp_x[:,17] = xTrain[:,8] - xTrain[:,9]
print('temp_x shape is ', temp_x.shape)
temp_xdot = np.zeros((98910,18))
temp_xdot[:,0:7] = xdotTrain[:,0:7]
temp_xdot[:,8] = xdotTrain[:,1] - xdotTrain[:,2]
temp_xdot[:,9:16] = xdotTrain[:,8:15]
temp_xdot[:,17] = xdotTrain[:,8] - xdotTrain[:,9]
print('temp_xdot shape is ', temp_xdot.shape)
xTrain = temp_x.astype(np.float32)
xdotTrain = temp_xdot.astype(np.float32)

#Initialize the model
#there are 16 states and 2 functions 
#the total combination is 36, the output is 1;/8 
net = Net(36,18)
#the dimension of the x is t by states (Xs)
x = torch.from_numpy(xTrain)
print(x.shape)
#the dimension of the y is t by states dot (Xs dot) 
y = torch.from_numpy(xdotTrain)
print(y.shape)

loss_function = nn.MSELoss()
optimizer = torch.optim.SGD(net.parameters(),
                             lr = 1e-3,
                             weight_decay = 1e-8)

for i in range(100):
    
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

###

# print(i,' : ',list(net.parameters()))
# print(net.forward(x).detach(),y)

# all_params = net.parameters()
# for p in all_params:
#     print(p.detach().numpy())

printEq(net.parameters())
