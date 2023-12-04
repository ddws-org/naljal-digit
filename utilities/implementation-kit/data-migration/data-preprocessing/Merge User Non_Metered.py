#!/usr/bin/env python
# coding: utf-8

# In[1]:


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


# In[2]:


#_path = 'mGramSeva Data Collection/Try'
_path = 'Cleaned Data/North Zone/Amritsar No 1/'
#_path = 'mGramSeva Data Collection/North Zone/SBS Nagar/'
#_path = 'mGramSeva Data Collection/Central Zone'
#_path = 'Other'

npd = pd.DataFrame()
files = []    
    
for r,d,f in os.walk(_path):
    for file in f:
        files.append(os.path.join(r,file))

for idx, file in enumerate(files):
    print()
    print (idx+1,'_____', file + '______________________________Processing Started.')
    
    dc = pd.read_excel(file, sheet_name=None)
    keys = dc.keys()  

    #df_final = pd.DataFrame()
    result = pd.DataFrame()
    for key in keys:
        compKey = key.lower()

        df_prow = pd.DataFrame()
        df_pbound = pd.DataFrame()
        
        ########################################################################################################
        if 'user' in compKey or 'upgra' in compKey:
            print('Processing Sheet____',key)
            df = dc[key]
        
            print(df)

            npd = npd.append(df)

    #npd.dropna(inplace = True)

    print()
    print(idx+1,'_____', file + '______________________________File Done.')

    
print('---------------Final------------------------')
display(npd)    


npd.to_excel('NorthZoneUserMerged.xlsx', index = False)
print('---------------------Done----------------------------------.')


# In[ ]:





# In[ ]:




