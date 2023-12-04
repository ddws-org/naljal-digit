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

from IPython.display import HTML, display
import warnings; warnings.simplefilter('ignore')


# In[18]:


def boundary1(result, compKey, key, dc, mainkeyl, mainkeyu, filen, pth):
    
    npd = pd.DataFrame()
    
    combined = '\t'.join(mainkeyl)
    
    for i in mainkeyu:
        if 'bound' in i.lower():
            key = i
    
    if 'bound' in combined:
        print('Processing Sheet____',key)
        df = dc[key]
        df = df.fillna('')
        
        print("!!!!!!!!!!!!!!\n",df)

        df = df.iloc[:, 1:15]
        if df.empty:
            raise Exception('DataFrame is empty!')

        result = pd.concat([result, df],axis=1, join = 'outer')
        
        print(filen)
        result['Sheet Name'] = filen
        result['File Path'] = pth
        print(result)

        result = result.fillna(method='ffill')

        npd = npd.append(result)


        npd = npd.iloc[:, : 27]

        npd.dropna(inplace = True)
        print("Boundary")
        display(npd)

        return npd


# In[19]:


def rates(compKey, key, dc, mainkl, mainku, filen, pth):
    
    result = pd.DataFrame()
    if 'rate' in compKey:

        print('Processing Sheet____',key)
        df = dc[key]
        df = df.fillna('')

        #print(df)
        if len(df.index) == 1:

            try:
                if df['Property Type'].str.contains('RES').sum() == 0:

                    df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type C','Service Type C','Calculation Type C', 'Rate C']
                    df['Property Type R'], df['Service Type R'], df['Calculation Type R'], df['Rate R'] = ['RESIDENTIAL', 'Non_Metered', 'Flat Rate', 0]
                df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type R','Service Type R','Calculation Type R', 'Rate R','Property Type C','Service Type C','Calculation Type C','Rate C']
                
            except:
                pass

            try:
                if df['Property Type'].str.contains('COM').sum() == 0:

                    df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type R','Service Type R','Calculation Type R', 'Rate R']
                    df['Property Type C'], df['Service Type C'], df['Calculation Type C'], df['Rate C'] = ['COMMERCIAL', 'Non_Metered', 'Flat Rate', 0]
                    df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type R','Service Type R','Calculation Type R', 'Rate R','Property Type C','Service Type C','Calculation Type C','Rate C']
                
            except:
                pass

        elif len(df.index) == 0:

                raise ValueError('No Data found')

        elif len(df.index) == 2 and df['Property Type'].str.contains('RES').sum() == 1 and df['Property Type'].str.contains('COM').sum() == 1:

                row_1=df.iloc[0].to_list()
                row_2=df.iloc[1].to_list()
                row_2 = row_2[3:]
                row = row_1 + row_2
                df['Property Type C'], df['Service Type C'], df['Calculation Type C'], df['Rate C'] = "","","",""
                df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type R','Service Type R','Calculation Type R', 'Rate R','Property Type C','Service Type C','Calculation Type C','Rate C']
                to_append = row
                df_length = len(df)
                df.loc[df_length] = to_append
                df = df.iloc[2:]

        elif df['Property Type'].str.contains('RES').sum() > 1:
            print('Multiple rows on Rate exists')
            
            ptc = []
            stc = []
            ctc = []
            rc =  []
            for i in range(len(df)):
                ptc.append('COMMERCIAL')
                stc.append('Non_Metered')
                ctc.append('Flat Rate')
                rc.append(0)
                
            df['Property Type C'] = ptc
            df['Service Type C'] = stc
            df['Calculation Type C'] = ctc
            df['Rate C'] = rc
            df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type R','Service Type R','Calculation Type R', 'Rate R','Property Type C','Service Type C','Calculation Type C','Rate C']
                
        elif df['Property Type'].str.contains('COM').sum() > 1:
            print('Multiple rows on Rate exists')
            
            ptr = []
            strr = []
            ctr = []
            rr =  []
            for i in range(len(df)):
                ptr.append('RESIDENTIAL')
                strr.append('Non_Metered')
                ctr.append('Flat Rate')
                rr.append(0)
                
            df['Property Type R'] = ptr
            df['Service Type R'] = strr
            df['Calculation Type R'] = ctr
            df['Rate R'] = rr
            df.columns = ['Sr No', 'GPWSC', 'Charges', 'Property Type R','Service Type R','Calculation Type R', 'Rate R','Property Type C','Service Type C','Calculation Type C','Rate C']
                
        result = df.copy()
        print("Merged result")
        display(result)
        result = boundary1(result, compKey, key, dc, mainkl, mainku, filen, pth)

        return result


# In[21]:


_path = 'try/'
#_path = 'Cleaned Data/North Zone/'
#_path = 'mGramSeva Data Collection/North Zone/SBS Nagar/'
#_path = 'mGramSeva Data Collection/Central Zone'
#_path = 'Other'


npd = pd.DataFrame()
final = pd.DataFrame()
files = [] 
divname = []
    
for r,d,f in os.walk(_path):
    for file in f:
        files.append(os.path.join(r,file))

for idx, file in enumerate(files):
    print()
    print (idx+1,'_____', file + '______________________________Processing Started.')
    
    dc = pd.read_excel(file, sheet_name=None)
    keys = dc.keys()  

    kk = list(keys)
    kkl = [each_string.lower() for each_string in kk]
    #df_final = pd.DataFrame()
    #print(kk)
    #divname = file.split('/')[-1]
    #print('divname: ', divname)
    
    for key in keys:
        compKey = key.lower()
        
        npd = rates(compKey, key, dc,kkl, kk, os.path.basename(file), file)
        print("npd")
        display(npd)
        final = final.append(npd)
        
        #display(rate)
        #npd = boundary1(rate, compKey, key, dc)

        print()
    print(idx+1,'_____', file + '______________________________File Done.')

    
print('---------------Final------------------------')
#final = final.drop_duplicates()
#display(final)    


final.to_excel('zzzRateBoundarytry.xlsx', index = False)
print('---------------------Done----------------------------------.')


# In[ ]:





# In[ ]:




