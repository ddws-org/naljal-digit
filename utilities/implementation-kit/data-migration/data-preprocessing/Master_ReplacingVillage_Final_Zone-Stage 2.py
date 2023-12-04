#!/usr/bin/env python
# coding: utf-8

# In[14]:


import os
import pandas as pd
import openpyxl
import numpy as np
import re
from datetime import datetime
#from datetime import date
from pathlib import Path
from  builtins import any as b_any

import shutil

import warnings; warnings.simplefilter('ignore')


# In[15]:


def unqno(con_arr):
    
    print("---------------------------------Connection-----------------------------------")
    
    uniqueval = set(con_arr)
    
    new_list = []
    fin_list = []
    
    numbers = list(range(1, 100000))
    remains = list(set(numbers) - set(con_arr))
    
    numberOfx = 0

    for i in range(len(con_arr)):
        if con_arr[i] in new_list:
            new_list.append('x')
            numberOfx += 1
        else:
            new_list.append(con_arr[i])
            
    remains = remains[:numberOfx]
    
    count = 0 
    for i in range(len(new_list)):
        if new_list[i] == 'x':
            fin_list.append(remains[count])
            count += 1
        else:
            fin_list.append(new_list[i])
    
    #print('final:', fin_list)
    
    return fin_list


# In[16]:


def changeconsumer(newName, df):
    
    villNamelist = newName.split(",")
    villNamelist2 = []
    for i in villNamelist:
        j = i.upper()
        k = j.replace(' ', '')
        villNamelist2.append(k)
    villNamelist2 = sorted(villNamelist2)

    
    try:
        fin_list = unqno(df['Old Connection ID'].tolist())
        df['Old Connection ID'] = fin_list
    except:
        fin_list = unqno(df['Existing Connection ID'].tolist())
        df['Existing Connection ID'] = fin_list
    
    newdf = df
        
    uniq = newdf['GPWSC Name'].unique()
    uniq = sorted(uniq)

    
    mini = min(len(uniq),len(villNamelist2))
    


    for i in range(mini):
        newdf = newdf.replace(to_replace = uniq[i],value = villNamelist2[i].replace(" ", ""))
        



    return newdf


# In[21]:


def changeuser(newName, df):
    
    villNamelist = newName.split(",")
    villNamelist2 = []
    for i in villNamelist:
        j = i.lower()
        k = j.replace(' ', '')
        villNamelist2.append(k)
    villNamelist2 = sorted(villNamelist2)
    print(villNamelist2)
    
    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
    
    newdf = df
        
    try:    
        uniq = newdf['GPWSC/Tenant'].unique()
    except:
        try:
            uniq = newdf['GPWSC'].unique()
        except:
            uniq = newdf['Boundary/ GPWSC'].unique()
            
    try:
        newdf.drop('Village Name', inplace=True, axis=1)
    except:
        pass
        
    uniq = sorted(uniq)
    print(uniq)
    
    mini = min(len(uniq),len(villNamelist2))
    


    for i in range(mini):
        newdf = newdf.replace(to_replace = uniq[i],value = villNamelist2[i].replace(" ", ""))
    
    newdf.columns = ['SlNo','GPWSC/Tenant','Name','Mobile Number','Fathers Name','Gender','Email Id','Date of Birth','Designation','Role1','Boundary','Role2']

    return newdf


# In[22]:


def changerate(newName, df):
    
    villNamelist = newName.split(",")
    villNamelist2 = []
    
    for i in villNamelist:
        j = i.lower()
        k = j.replace(' ', '')
        villNamelist2.append(k)
        
    villNamelist2 = sorted(villNamelist2)

    newdf = df
        
    uniq = newdf['GPWSC'].unique()
    uniq = sorted(uniq)
    print(uniq)
    
    mini = min(len(uniq),len(villNamelist2))
    


    for i in range(mini):
        newdf = newdf.replace(to_replace = uniq[i],value = villNamelist2[i].replace(" ", ""))


    return newdf


# In[23]:


def changebound(newName, df):
    
    villNamelist = newName.split(",")
    villNamelist2 = []
    
    for i in villNamelist:
        j = i.lower()
        k = j.replace(' ', '')
        villNamelist2.append(k)
        
    villNamelist2 = sorted(villNamelist2)
    print(villNamelist2)
    newdf = df
        
    uniq = newdf['Village Name'].unique()
    uniq = sorted(uniq)

    
    mini = min(len(uniq),len(villNamelist2))
    

    for i in range(mini):
        newdf = newdf.replace(to_replace = uniq[i],value = villNamelist2[i].replace(" ", ""))
   
    
    return newdf


# In[26]:


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!please change this!!!!!!!!!!!!!!!!!!!!!!!!!!
_path = 'All Files/'
_patho = 'Allfileoutput/'
inputfile = 'Restdivison.xlsx'
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

dcr = pd.read_excel(inputfile)

dcr = dcr[['Village Name', 'Sheet Name']]
dcr['Village Name'].replace(regex=True, inplace=True, to_replace=r'[^A-Za-z]+', value=r'')

dcr = dcr.groupby(['Sheet Name'], as_index = False).agg({'Village Name': ','.join})


tally_list= []

for index, row in dcr.iterrows():
    print(row['Village Name'], row['Sheet Name'])

    
    dc = pd.read_excel(_path + row['Sheet Name'], sheet_name=None)
    
    tally_list.append(row['Sheet Name'])
    
    f = _patho+row['Sheet Name']
    
    keys = dc.keys()  

    kk = list(keys)
    kkl = [each_string.lower() for each_string in kk]
    
    fdfc=pd.DataFrame()
    fdfu=pd.DataFrame()
    fdfr=pd.DataFrame()
    fdfb=pd.DataFrame()

    for key in keys:
        

        compKey = key.lower()

        if (compKey.find('consu') != -1) or (compKey.find('mgram') != -1):
            fdfc = changeconsumer(row['Village Name'], dc[key])
            
        if (compKey.find('user') != -1) or (compKey.find('upgra') != -1):
            fdfu = changeuser(row['Village Name'], dc[key])
            
        if (compKey.find('rate') != -1):
            fdfr = changerate(row['Village Name'], dc[key])
            
        if (compKey.find('bound') != -1) or (compKey.find('sheet') != -1):
            fdfb = changebound(row['Village Name'], dc[key])
            
        writer1 = pd.ExcelWriter(f)

        fdfc.to_excel(writer1, sheet_name = 'Consumer Master', index = False)
        fdfu.to_excel(writer1, sheet_name = 'User Master', index = False)
        fdfr.to_excel(writer1, sheet_name = 'Rate Master', index = False)
        fdfb.to_excel(writer1, sheet_name = 'Boundary Master', index = False)

        writer1.save()
        writer1.close()


        print()
    print(row['Sheet Name'] + '______________________________File Done.')

    
print('---------------Final------------------------')
#final = final.drop_duplicates()
#display(final)


# In[ ]:





# In[ ]:




