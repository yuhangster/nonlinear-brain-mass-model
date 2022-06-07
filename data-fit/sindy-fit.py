#!/usr/bin/env python
# coding: utf-8

# In[2]:


import pandas as pd
import numpy as np
import pysindy as ps
import math
import scipy.io
from numpy import diff

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy.integrate import solve_ivp
from sklearn.linear_model import Lasso


# ## Case 1: Single column 

# ###  Create the training dataset

# In[3]:


#use the trial 1 to 7 the training data
arrayNum = 2
trial = 100
t_train = [] 
x_train = []
xdot_train = []

#for every arrayNum
for i in range (1,arrayNum+1):
    for j in range (trial):
        mat = scipy.io.loadmat(r'C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-dataMat\data_'+str(i)+'.mat')
        #get the data
        tp_t = mat.get("data_t")
        tp_x = mat.get("data_x")
        tp_xdot = mat.get("data_xdot")
        t_train.append(tp_t[:,:,j])
        x_train.append(tp_x[:,:,j])
        xdot_train.append(tp_xdot[:,:,j])
        
print(x_train[0].shape)
print(type(x_train[0]))
print(len(t_train))
print(t_train[1].shape)


# In[30]:


i = 0
for trl in x_train:
    cl1 = trl[:,1] - trl[:,2]
    plt.plot(t_train[i], cl1)
    i += 1


# ### Fit the Sindy with the training dataset

# In[33]:


#I will initial with only 2 functions: one is x 
# the other is the sigmoid-liked function
library_functions = [
    lambda x : x,
    lambda x : -2.5+5/(1+np.exp(-0.56*x)) #-e0+2*e0/(1+exp(-r*x))
]
library_function_names = [
    lambda x : x,
    lambda x : 'S(' + x + ')'
]

custom_library = ps.CustomLibrary(
    library_functions=library_functions, function_names=library_function_names
)


# In[34]:


#pass the x and its derivative
#Threshold:
#minimum coefficient 0.0026 hi*gamma4/ti
optimizer = ps.STLSQ(threshold=0.001)
feature_library=custom_library
dt = 0.01
model = ps.SINDy(
    feature_library=feature_library,
    optimizer = optimizer
)
model.fit(x_train, t=t_train, x_dot=xdot_train,multiple_trajectories=True)
model.print()


# ### Score for the time derivative prediction produced by the model

# In[35]:


#Use the trail 8 to 10 as test data
#training data
t_test = []
x_test = []
xdot_test = []

#for every arrayNum
for i in range (8,11):
    for j in range (trial):
        mat = scipy.io.loadmat(r'C:\Users\l2016\GitHub\nonlinear-brain-mass-model\data-gen\single-column-dataMat\data_'+str(i)+'.mat')
        #get the data
        tp_t = mat.get("data_t")
        tp_x = mat.get("data_x")
        tp_xdot = mat.get("data_xdot")
        t_test.append(tp_t[:,:,j])
        x_test.append(tp_x[:,:,j])
        xdot_test.append(tp_xdot[:,:,j])
    
#x_test can have 200 trails
print('Model score: %f' % model.score(x_test, t = t_test, x_dot = xdot_test, multiple_trajectories=True))


# ### Plots for test data time derivative  comperation

# In[36]:


print(x_test[0][0,:])
#x test doing split
xdot_predicted = model.predict(x_test, multiple_trajectories=True)

fig, axs = plt.subplots(x_test[0].shape[1], 1, sharex=True, figsize=(7, 9))

for i in range(x_test[0].shape[1]):
    for j in range(1):
        axs[i].plot(t_test[j], xdot_test[j][:, i],'k')
        axs[i].plot(t_test[j], xdot_predicted[j][:, i],'r--')
        
    axs[i].legend(['Numerical derivative', 'Model derivative'])
    axs[i].set(xlabel='t', ylabel='$\dot x_{}$'.format(i))
fig.show()


# ### Generate model prediction X

# In[79]:


# time interval of the simulation
dt = 0.1
t_sim = np.arange(10, 200, dt)

# use the x_train at 5 ms value as initial condition
    #the 1st index is 5s
x0_sim = x_test[0][500,:]
print(x0_sim)

x_test_sim = model.simulate(x0_sim, t_sim, integrator = "odeint")
print('dimension of the x_test_simulation:', x_test_sim.shape)


# ### Plots for model prediction performance

# In[80]:


#simulation result
cl1_sim = x_test_sim[:,1] - x_test_sim[:,2]
print(len(cl1_sim))
print(len(t_sim))
#real value
cl1 = x_test[0][:,1] - x_test[0][:,2]


# In[82]:


fig, ax = plt.subplots(figsize=(7, 9))
ax.plot(t_test[0], cl1,'k')
ax.plot( t_sim, cl1_sim, 'r--')
ax.legend(['real value','model predeiction'])
ax.set_xlim([0, 260])
ax.set_ylim([-0.5, 1])


# ### Numerical performance of the model on the test data

# In[ ]:


#calculate the performance by 1 - the SE/sum of all data points 

