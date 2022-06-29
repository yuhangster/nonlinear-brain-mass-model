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
print('shape of single time set: ', t_train[1].shape)

i = 0
for trl in x_train:
    cl1 = trl[1,:] - trl[2,:]
    cl1 = np.reshape(cl1, (1,249702))
    cl2 = trl[9,:] - trl[10,:]
    cl2 = np.reshape(cl2, (1,249702))
    plt.plot(t_train[i],cl1,'r',t_train[i],cl2,'k')
    i+=1

#Initialize the model
#there are 16 states and 2 functions 
#the total combination is 32, the output is 8 
net = Net(32,8)

x_train = np.transpose(x_train)
xdot_train = np.transpose(xdot_train)