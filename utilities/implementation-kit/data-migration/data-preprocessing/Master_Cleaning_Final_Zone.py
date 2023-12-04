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

import shutil

import warnings; warnings.simplefilter('ignore')


# In[2]:


def rename_col_consumer (df):
    old_c = []
    new_c = []
    check = []
    #columns = ["Sl No","Customer Name","Gender","Fathers/Spouse Name","Phone number","Old Connection ID","Property type","Service Type","Door Number","Street Number/Name","Ward","Meter Number","Last Meter Reading Date","GPWSC Name","Arrears","Previous reading"]

    for c in df.columns:
        old_c.append(c)
    #print('old:',old_c)

    sub = 'no'
    #print ('Consuemr:',[s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'name'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'gen'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'fat'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'ph'
    check.append([s for s in old_c if sub in s.lower()])
    #print (check)
    if len(check[0]) != 0:
        #print(check)
        new_c.append([s for s in old_c if sub in s.lower()][0])
    else:
        sub = 'mob'
        #print ([s for s in old_c if sub in s.lower()])
        new_c.append([s for s in old_c if sub in s.lower()][0])
        
    check = []

    sub = 'con'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'prop'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'ser'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'doo'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'str'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'ward'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'meter n'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'vious meter'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'gp'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'arr'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'data'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])
    #print(new_c)
    
    return new_c

def rename_col_user(df):
    old_c = []
    new_c = []
    check = []
    #columns = ["Sr. No.","GPWSC/Tenant","Name","Mobile Numer","Father's Name","Gender","Email Id","Date of Birth","Type","Role1","Boundary","Role2"]
    
    for c in df.columns:
        old_c.append(c)
    #print(old_c)

    sub = 'no'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'vil'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'umer'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])
    
    sub = 'num'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'fat'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'gen'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'ema'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'date'
    #print ([s for s in old_c if sub in s.lower()])
    check.append([s for s in old_c if sub in s.lower()])
    #print(check)
    if len(check[0]) != 0:
        #print('user',check)
        new_c.append([s for s in old_c if sub in s.lower()][0])
    else:
        sub = 'dob'
        new_c.append([s for s in old_c if sub in s.lower()][0])
    check = []

    sub = 'desig'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'e1'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'bound'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])

    sub = 'e2'
    #print ([s for s in old_c if sub in s.lower()])
    new_c.append([s for s in old_c if sub in s.lower()][0])
    
    #print(new_c)
    
    return new_c


# In[5]:


_path = 'Mansa No 2/'#Excel Files Done
#_path = 'mGramSeva Data Collection/Excel Files Done/North Zone/'
#_path = 'mGramSeva Data Collection/Try/'
#_path = 'mGramSeva Data Collection/North Zone/SBS Nagar/'
#_path = 'mGramSeva Data Collection/Central Zone'
#_path = 'Other'

files = []    
    
for r,d,f in os.walk(_path):
    for file in f:
        files.append(os.path.join(r,file))
        print(file)

for idx, file in enumerate(files):
    print (idx+1,'_____', file + '______________________________Processing Started.')
    print ()
    with pd.ExcelWriter(file, mode='a', engine='openpyxl', date_format="MM/DD/YYYY", datetime_format="MM/DD/YYYY HH:MM:SS", if_sheet_exists='replace') as writer:
        #with pd.ExcelWriter("Cleaned Mansa No 2/"+file.split(os.sep)[-2].split('/')[-1]+'/'+os.path.basename(file), engine='xlsxwriter', date_format="MM/DD/YYYY", datetime_format="MM/DD/YYYY HH:MM:SS") as writer1:
        with pd.ExcelWriter("Cleaned Mansa No 2/"+os.path.basename(file), engine='xlsxwriter', date_format="MM/DD/YYYY", datetime_format="MM/DD/YYYY HH:MM:SS") as writer1:
        #with pd.ExcelWriter("mGramSeva Data Collection/try1out/"+'/'+os.path.basename(file), engine='xlsxwriter', date_format="MM/DD/YYYY", datetime_format="MM/DD/YYYY HH:MM:SS") as writer1:   
            dc = pd.read_excel(file, sheet_name=None, header=1, na_values = ['N A','','NA ','s','G','NaN','N.A','-','--', 'Nil', 'nil','NIl',' ','..','...'])
            keys = dc.keys()        
            for key in keys:
                compKey = key.lower()
                if 'consu' in compKey or 'mgram' in compKey or Path(file).stem.lower()[:4] in compKey:
                    print('\nProcessing Sheet____',key)
                    df = dc[key]
                    prevMeterReadingDateExist = False
                    prevMeterReading = False
                    phno = False
                    meterNo = False
                    wardno = False
                    doorno = False
                    #print(df)
                    
                    
                    
                    df.dropna(axis = 0, how = 'all', inplace = True)
                    
                    #Only for Batala no 2
                    #df = df[2:]
                    #new_header = df.iloc[0] #grab the first row for the header
                    #df = df[1:] #take the data less the header row
                    #df.columns = new_header
                    #print(df)
                   
                    for colName in df.keys():
                            compColName = colName.lower()
                            compColName = re.sub(r'^\W+|\W+$', '', compColName)
                            if 'name' == compColName or 'consumer' in compColName: 
                                df[colName] = df[colName].dropna().map(str.title)
                                df[colName] = df[colName].str.strip()
                                df[colName] = [re.sub('[^a-zA-Z\s]', '', str(x)) for x in df[colName]]
                                df[colName] = df[colName].str.upper()
                                #print (colName,'|Field found and processed')
                            elif 'father' in compColName:
                                df[colName] = df[colName].fillna('NA')
                                df[colName] = df[colName].astype(str)
                                df[colName] = df[colName].dropna().map(str.upper)
                                df[colName] = df[colName].str.strip()
                                df[colName] = [re.sub('[^a-zA-Z\s]', '', str(x)) for x in df[colName]]
                                df[colName] = df[colName].str.upper()
                                #df[colName] = df[colName].fillna('NA')
                                #print (colName,'|Field found and processed')
                            elif 'gender' in compColName: 
                                newIndexes = []
                                newValues = []
                               # df[colName] = (df[colName].str.strip()
                                #          .replace('',np.nan)
                                 #         .transform(lambda x: x.bfill().ffill()))
                                df[colName] = df[colName].dropna().map(str.upper) 
                                df[colName] = df[colName].str.strip()
                                for index, value in df[colName].items():   
                                    value = str(value)
                                    if re.search(r'^M\w*', value):
                                        newValues.append('MALE')
                                        newIndexes.append(index)
                                    elif re.search(r'^F\w*', value):
                                        newValues.append('FEMALE')
                                        newIndexes.append(index)
                                    else:
                                        pass        
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)
                                df[colName] = df[colName].str.strip()
                                #print (colName,'|Field found and processed')
                            elif 'phone' in compColName or 'mobile' in compColName:
                                phno = True
                                defValue = '6666666666'
                                newIndexes = []
                                newValues = []
                                modified = False
                                for index, value in df[colName].items():
                                    #print(str(value),':', type(value),':',len(str(value)[:-2]))
                                    
                                    if type(value) == float:
                                        
                                        if len(str(value)[:-2]) != 10:
                                            modified = True
                                            newValues.append(defValue)
                                            newIndexes.append(index)
                                        
                                        else:
                                            value = str(value)
                                            value = re.sub(r'[-./\s]+', '', value) 
                                            newValues.append(value[:-1])
                                            newIndexes.append(index)

                                    elif type(value) == int:
                                        if len(str(value)) != 10:
                                            modified = True
                                            newValues.append(defValue)
                                            newIndexes.append(index)
                                    
                                    elif type(value) == str:
                                        value = str(value)
                                        value = re.sub(r'[-./\s]+', '', value)
                                        if len(value) != 10:
                                            modified = True
                                            newValues.append(defValue)
                                            newIndexes.append(index)
                                    
                                    else:
                                        value = str(value)
                                        value = re.sub(r'[-./\s]+', '', value) 
                                        newValues.append(value[:-1])
                                        newIndexes.append(index)

                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)
                                df[colName] = df[colName].astype(str)
                                #print (colName, '|Field found and processed','|Modified:', modified, '|No of Modifications:', newSeries.size)
                            
                            elif 'property' in compColName:
                                df[colName] = df[colName].dropna().map(str.upper)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].fillna('RESIDENTIAL')
                            elif 'service' in compColName:
                                df[colName] = df[colName].dropna().map(str.title)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].str.replace(r'[-\s]+', '_', regex=True)
                                df[colName] = df[colName].fillna('Non_Metered')
                            elif 'gpwsc' in compColName:
                                df[colName] = (df[colName].astype(str).str.strip()
                                          .replace('',np.nan)
                                          .transform(lambda x: x.bfill().ffill()))
                                df[colName] = df[colName].dropna().map(str.upper)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].str.replace(r'[-\s]+', '', regex=True)
                                
                            elif 'ward' in compColName:
                                wardno = True
                                df[colName] = df[colName].fillna(0)
                                df[colName] = df[colName].astype(float)
                                df[colName] = df[colName].astype(int)
                                df.loc[df[colName] == 0, colName] = 'WARD1'
                                
                            elif 'meter n' in compColName:
                                meterNo = True
                                df[colName] = df[colName].fillna(0)
                                df[colName] = 0
                                df[colName] = df[colName].astype(int)
                                df.loc[df[colName] == 0, colName] = ''
                                #df[colName] = df[colName].fillna('WARD1')
                                
                            elif 'connection' in compColName:
                                minValue = 0
                                newIndexes = []
                                newValues = []
                                modified = False
                                for index, value in df[colName].items():
                                     if pd.isnull(value):
                                        modified = True
                                        valueList = df[colName].to_list()
                                        minValue = minValue + 1
                                        while minValue in valueList:
                                            minValue = minValue + 1
                                        newValues.append(int(minValue))
                                        newIndexes.append(index)
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)
                                try:
                                    df[colName] = df[colName].astype(float)
                                    df[colName] = df[colName].astype(int)
                                except:
                                    pass
                                df[colName] = df[colName].astype(str)
                                #print (colName, '|Field found and processed', '|Unique:', df[colName].is_unique, '|Modified:', modified, '|No of Modifications:', newSeries.size)

                            elif 'arrear' in compColName:
                                df[colName] = df[colName].fillna('0')
                                #print (colName, '|Field found and processed')
                                
                            elif 'door' in compColName:
                                doorno = True
                                df[colName] = df[colName].fillna('')
                                #print (colName, '|Field found and processed')

                            elif 'reading date' in compColName:
                                prevMeterReadingDateExist = True
                           
                                readingDt = datetime.strptime('09/01/2021', '%m/%d/%Y')
                                readingDt = datetime.strftime(readingDt, "%m/%d/%Y")
                                df[colName] = df[colName].fillna(str(readingDt))
                                #print(df[colName])
                                newIndexes = []
                                newValues = []
                                for index, value in df[colName].items():
                                    if isinstance(value, str):
                                        if re.search(r'[-./\s]+', value):
                                            value = re.sub(r'[-./\s]+', '/', value)
                                            value = datetime.strptime(value, '%m/%d/%Y')
                                            value = datetime.strftime(value, "%m/%d/%Y")
                                    newValues.append(value)
                                    newIndexes.append(index)
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)

                            elif 'previous reading' in compColName:
                                prevMeterReading = True
                                df[colName] = df[colName].fillna('0')

                            else:
                                pass

                    if not phno:
                        #print('Phone Number', '|Not Exist, Creating Field')
                        df['Phone Number'] = '6666666666'
                    if not wardno:
                        #print('Ward No.', '|Not Exist, Creating Field')
                        df['Ward No'] = 'WARD1'
                        
                    if not prevMeterReadingDateExist:
                        #print('Previous Meter Reading Date', '|Not Exist, Creating Field')
                        readingDt = datetime.strptime('09/01/2021', '%m/%d/%Y')
                        readingDt = datetime.strftime(readingDt, "%m/%d/%Y")
                        #readingDt = pd.to_datetime('01/09/2021', format='%d/%m/%Y', errors='ignore')
                        df['Previous Meter Reading Date'] = readingDt

                    if not prevMeterReading:
                        #print('Previous Meter Reading', '|Not Exist, Creating Field')
                        df['Previous Meter Data'] = 0
                        
                    if not meterNo:
                        #print('Meter Number', '|Not Exist, Creating Field')
                        df['Meter Number'] = ''
                    
                    if not doorno:
                        print('Door Number', '|Not Exist, Creating Field')
                        df['Door No'] = ''

                    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
                    #print(df)
                    rename_columns = rename_col_consumer(df)
                    #df.columns = ["Sl No","Name","Gender","Fathers/Spouse Name","Phone number","Old Connection ID","Property type","Service Type","Door Number","Street Number/Street Name","Ward","Meter Number","Previous Meter Reading Date","GPWSC Name","Arrears","Previous reading"]
                    df = df[rename_columns]
                    df.columns = ["Sl No","Customer Name","Gender","Fathers/Spouse Name","Phone number","Old Connection ID","Property type","Service Type","Door Number","Street Number/Name","Ward","Meter Number","Last Meter Reading Date","GPWSC Name","Arrears","Previous reading"]
                    
                    df = df.astype(str)
                    df = df.replace(['nan'],'')
                    
                    #display(df)
                    
                    df = df[df["GPWSC Name"].eq("NAN") == False]
                    
                    #display(df)
                    if df['Customer Name'].eq('NAN').any() or df['Fathers/Spouse Name'].eq('NA').all():
                        print(df)
                        raise Exception("Sorry it Non Funtional")
                    
                    df.to_excel(writer1,sheet_name='Consumer', index = False)


                    print('New Sheet created____','Modified Cnmr Sheet')

                ########################################################################################################
                elif 'user' in compKey or 'upgra' in compKey:
                    print()
                    print('Processing Sheet____',key)
                    df = dc[key]
                                      
                    df.dropna(axis = 0, how = 'all', inplace = True)
                    df = df.loc[:, ~df.columns.str.contains("ole")]
                    try:
                        df = df.loc[:, ~df.columns.str.contains("ole2")]
                    except:
                        pass
                    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
                    
                    #Only for Batala no 2
                    #df = df[2:]
                    #new_header = df.iloc[0] #grab the first row for the header
                    #df = df[1:] #take the data less the header row
                    #df.columns = new_header
                    ###########################
                    #print(df)        
                    #df = df.iloc[df[[0]].str.contains("Note") == False]
                    
                    phno = False

                    designations = []
                    for colName in df.keys():
                            compColName = colName.lower()
                            compColName = re.sub(r'^\W+|\W+$', '', compColName)
                            if re.search(r'^sr[-./\s]*n', compColName):                             
                                minValue = 0
                                newIndexes = []
                                newValues = []
                                modified = False
                                for index, value in df[colName].items():
                                     if pd.isnull(value):
                                        modified = True
                                        valueList = df[colName].to_list()
                                        minValue = minValue + 1
                                        while minValue in valueList:
                                            minValue = minValue + 1
                                        newValues.append(minValue)
                                        newIndexes.append(int(float(index)))
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)       
                            
                                #print (colName,'|Field found and processed')
                            
                            elif 'name' == compColName or 'consumer' in compColName: 
                                df[colName] = df[colName].ffill()
                                df[colName] = df[colName].dropna().map(str.title)
                                df[colName] = df[colName].str.strip()
                                df[colName] = [re.sub('[^a-zA-Z\s]', '', str(x)) for x in df[colName]]
                                df[colName] = df[colName].astype(str).str.upper()
                                
                            elif 'gpw' in compColName:                             
                                df[colName] = df[colName].ffill()
                                df[colName] = df[colName].dropna().map(str.lower)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].str.replace(r'[-\s]+', '', regex=True)
                                #print (colName,'|Field found and processed')
                            
                            elif 'vill' == compColName:
                                
                                df[colName] = df[colName].dropna().map(str.lower)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].str.replace(r'[-\s]+', '', regex=True)
                                df[colName] = df[colName].ffill()
                                #print (colName,'|Field found and processed')
                            elif 'father' in compColName: 
                                df[colName] = df[colName].astype(str).dropna().map(str.title)
                                df[colName] = df[colName].astype(str).str.strip()
                                df[colName] = [re.sub('[^a-zA-Z\s]', '', str(x)) for x in df[colName]]
                                df[colName] = df[colName].astype(str).str.upper()
                                #print (colName,'|Field found and processed')
                            elif 'gender' in compColName: 
                                newIndexes = []
                                newValues = []
                                df[colName] = df[colName].dropna().map(str.upper)
                                df[colName] = df[colName].str.strip()
                                for index, value in df[colName].items():
                                    value = str(value)
                                    if re.match(r'^M\w*', value):
                                        newValues.append('MALE')
                                        newIndexes.append(index)
                                    elif re.match(r'^F\w*', value):
                                        newValues.append('FEMALE')
                                        newIndexes.append(index)
                                    else:
                                        pass        
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)
                                df[colName] = df[colName].str.strip()
                                #print (colName,'|Field found and processed')
                                
                                
                            elif 'phone' in compColName or 'mobile' in compColName:
                                phno = True
                                defValue = '6666666666'
                                newIndexes = []
                                newValues = []
                                modified = False
                                for index, value in df[colName].items():
                                    #print(str(value),':', type(value),':',len(str(value)))
                                    
                                    if type(value) == float:
                                        
                                        if len(str(value)[:-2]) != 10:
                                            modified = True
                                            newValues.append(defValue)
                                            newIndexes.append(index)
                                        
                                        else:
                                            value = str(value)
                                            value = re.sub(r'[-./\s]+', '', value) 
                                            newValues.append(value[:-1])
                                            newIndexes.append(index)
                                    
                                    elif type(value) == int:
                                        if len(str(value)) != 10:
                                            modified = True
                                            newValues.append(defValue)
                                            newIndexes.append(index)
                                    
                                    elif type(value) == str:
                                        value = str(value)
                                        value = re.sub(r'[-./\s]+', '', value)
                                        if len(value) != 10:
                                            modified = True
                                            newValues.append(defValue)
                                            newIndexes.append(index)
                                    
                                    else:
                                        value = str(value)
                                        value = re.sub(r'[-./\s]+', '', value) 
                                        newValues.append(value[:-1])
                                        newIndexes.append(index)
                                        
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)
                                df[colName] = df[colName].astype(str)
                                #print (colName, '|Field found and processed','|Modified:', modified, '|No of Modifications:', newSeries.size)
                            
                            elif 'desig' in compColName: 
                                df[colName] = df[colName].dropna().map(str.title)
                                df[colName] = df[colName].str.strip()
                                
                                df.loc[df[colName].str.contains('pan', na=False), colName] = 'Sarpanch'
                                df.loc[df[colName].str.contains('sec', na=False), colName] = 'Secretary'
                                #df.loc[df[colName].str.contains('pan'), colName] = 'Sarpanch'
                                #df.loc[df[colName].str.contains('sec'), colName] = 'Secretary'
                                designations = df[colName]
                                #print (colName,'|Field found and processed')
                            
                            elif 'birth' in compColName or 'dob' in compColName: 
                                prevMeterReadingDateExist = True
                                readingDt = datetime.strptime('12/01/1970', '%m/%d/%Y')
                                readingDt = datetime.strftime(readingDt, "%m/%d/%Y")
                                
                                df[colName] = df[colName].fillna(str(readingDt))
                                                                
                                newIndexes = []
                                newValues = []
                                for index, value in df[colName].items():
                                    if isinstance(value, str):
                                        if re.search(r'[-./\s]+', value):
                                            value = re.sub(r'[-./\s]+', '/', value)
                                            try:
                                                value = datetime.strptime(value, '%d/%m/%Y')
                                            except:
                                                value = datetime.strptime(value, '%m/%d/%Y')
                                            value = datetime.strftime(value, "%m/%d/%Y")
                                    newValues.append(value)
                                    newIndexes.append(index)
                                newSeries = pd.Series(newValues, newIndexes)
                                df[colName].update(newSeries)
                                #df[colName] = pd.to_datetime(df[colName], format='%m/%d/%y')
                                #print(type(df[colName]),df[colName])
                                #print(df.dtypes)
                                #print (colName,'|Field found and processed')

                    role1 = []
                    boundary = []
                    role2 = []

                    for index, value in designations.items():
                        value = str(value)
                        value = value.lower()
                        if 'pan' in value:
                            role1.append('EXPENSE_PROCESSING,BULK_DEMAND_PROCESSING,DASHBOARD_VIEWER,GP_ADMIN, COLLECTION_OPERATOR')
                        elif 'sec' in value:
                            role1.append('EXPENSE_PROCESSING,BULK_DEMAND_PROCESSING,DASHBOARD_VIEWER,GP_ADMIN, COLLECTION_OPERATOR')
                        elif 'rev' in value or 'col' in value:
                            role1.append('COLLECTION_OPERATOR, DASHBOARD_VIEWER')
                        elif 'pump' in value or 'ope' in value:
                            role1.append('COLLECTION_OPERATOR, DASHBOARD_VIEWER')
                        else:
                            role1.append('Role Not Found')
                            
                    df['Role1'] = role1    
                    
                    if not phno:
                        print('Phone Number', '|Not Exist, Creating Field')
                        df['Phone Number'] = '6666666666'
                        
                    df.drop(df.columns[[1]], axis = 1, inplace = True)
                    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
                    
                    df = df.rename(columns=lambda c: 'phone number' if 'mob' in c.lower() else c)
                    df.ffill(inplace = True)
                                        
                    df['Boundary'] = 'WARD1'
                    df['Role2'] = 'PROFILE_UPDATE'
                    
                    df.columns = ["Sl No","Village","Consumer","Mobile Number","Father's Name","Gender","Email Id","Date of Birth","Designation","Role1","Boundary","Role2"]
                    
                    rename_columns = rename_col_user(df)
                    
                    df = df[rename_columns]
                    
                    df.columns = ["SlNo","GPWSC/Tenant","Name","Mobile Number","Father's Name","Gender","Email Id","Date of Birth","Designation","Role1","Boundary","Role2"]
                    
                    
                    #df = df.loc[df['Sl No'].str.contains('ande', na=False), colName] = np.nan
                    #df = df[df["Sl No"].str.contains("Mande") == False]
                    try:
                        df = df[~df.SlNo.str.contains("Note", na=False)]
                    except:
                        pass
                    
                    try:
                        df['SlNo'] = df['SlNo'].astype(float)
                        df['SlNo'] = df['SlNo'].astype(int)
                    except:
                        pass
                    df['SlNo'] = df['SlNo'].astype(str)
                    df['Boundary'] = 'WARD1'
                    
                                       
                    perc = 25.0
                    min_count =  int(((100-perc)/100)*df.shape[1] + 1)
                    df = df.dropna( axis=0, thresh=min_count)
                    
                    df = df.astype(str)
                    df = df.replace(['nan'],'')
        
                    
                    df.to_excel(writer1,sheet_name='User', index = False)
                    #df.to_excel(writer,sheet_name='Usrn', index = False)
                    print('New Sheet created____','Modified Usr Sheet')
                
                ########################################################################################################
                elif 'rate' in compKey:
                    print()
                    print('Processing Sheet____',key)
                    df = dc[key]
                    
                    df = df.iloc[:5]
                    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
                    #df.dropna(axis = 0, how = 'all', inplace = True)
                    
                    
                    perc = 25.0
                    min_count =  int(((100-perc)/100)*df.shape[1] + 1)
                    df = df.dropna( axis=0, thresh=min_count)
                    
                    charges_cols = [col for col in df.columns if 'harge' in col]
                    df[charges_cols] = 'Water Charges'
                    ###########Only For South Zone##########################
                    #print(len(df. columns))
                    #print(df. columns)
                    
                     
                    if len(df. columns) == 8:
                        
                        cols  = df.columns
                        #print(df.columns)
                        df.columns = map(str.strip, cols)
                        #print(df.columns)
                        #print('Length: ',len(df. columns))
                        
                        df = df[df['Charges'].str.contains('ater', na=False)]
                        try:
                            df.drop('If Metered', axis=1, inplace=True)
                        except:
                            pass
                        df.columns = ['Sr No','GPWSC','Charges','Property Type','Service Type','Calculation Type','Rate']
                        
                    
                    
                    #df.loc[(df[‘Color’] == ‘Green’) | (df[‘Shape’] == ‘Rectangle’)]
                    #df.drop(columns =cols[6:9], inplace=True)
                    
                    
                    for colName in df.keys():
                        compColName = colName.lower()
                        #print(compColName)
                        #df = df[df[2].str.contains('arges')]
                        if 'gpw' == compColName or 'charg' == compColName or 'calc' == compColName: 
                                df[colName] = df[colName].dropna().map(str.title)
                                df[colName] = df[colName].str.strip()
                                df[colName] = [re.sub('[^a-zA-Z\s]', '', str(x)) for x in df[colName]]
                                df[colName] = df[colName].str.title()
                                df[colName] = df[colName].apply(str)
                                #print (colName, '|Field found and processed')
                        
                        elif 'arrear' in compColName:
                                df[colName] = df[colName].fillna('0')
                                df[colName] = df[colName].apply(str)
                                #print (colName, '|Field found and processed')
                        
                        elif 'property' in compColName:
                                df[colName] = df[colName].dropna().map(str.upper)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].fillna('RESIDENTIAL')
                                #print (colName, '|Field found and processed')
                                
                        elif 'service' in compColName:
                                df[colName] = df[colName].dropna().map(str.title)
                                df[colName] = df[colName].str.strip()
                                df[colName] = df[colName].str.replace(r'[-\s]+', '_', regex=True)
                                df[colName] = df[colName].fillna('Non_Metered')
                                #print (colName, '|Field found and processed')
                        
                        elif 'no' in compColName or 'bank c' in compColName:
                            df[colName] = df[colName].fillna('0')
                            df[colName] = df[colName].astype(float)
                            df[colName] = df[colName].astype(int)
                            df[colName] = df[colName].astype(str)
                        elif 'rate' in compColName:
                            df[colName] = df[colName].fillna('50')
                            df[colName] = df[colName].astype(float)
                            df[colName] = df[colName].astype(str)
                            df[colName] = df[colName].map(lambda x: str(x)[:-2])

                    #df = df.loc[:, ~df.columns.str.contains("ole1")]
                    df.columns = ['Sr No','GPWSC','Charges','Property Type','Service Type','Calculation Type','Rate']
                    df = df.astype(str)
                    df = df.replace(['nan'],'')
                    
                    df.to_excel(writer1,sheet_name='Rate Master', index = False)
                    print('New Sheet created____','Modified Rate Sheet')
                
                ########################################################################################################
                elif 'bank' in compKey:
                    print()
                    print('Processing Sheet____',key)
                    df = dc[key]
                    
                    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
                    df.dropna(axis = 0, how = 'all', inplace = True)
                    
                    perc = 25.0
                    min_count =  int(((100-perc)/100)*df.shape[1] + 1)
                    df = df.dropna( axis=0, thresh=min_count)
                    
                    #Only for Batala no 2
                    #df = df[2:]
                    #new_header = df.iloc[0] #grab the first row for the header
                    #df = df[1:] #take the data less the header row
                    #df.columns = new_header
                    ###########################
                    
                    #df = df.loc[:, :14]
                    df = df.astype(str)
                    df = df.replace(['nan'],'0')
                    #print(df)
                    for colName in df.keys():
                        compColName = colName.lower()
                        if 'no' in compColName or 'bank c' in compColName:
                            df[colName] = df[colName].fillna('0')
                            try:
                                df[colName] = df[colName].astype(float)
                                df[colName] = df[colName].astype(int)
                            except:
                                pass
                            df[colName] = df[colName].astype(str)
                        if 'ph' in compColName:
                            defValue = '6666666666'
                            newIndexes = []
                            newValues = []
                            modified = False
                            for index, value in df[colName].items():
                                    #print(str(value),':', type(value),':',len(str(value)[:-2]))
                                    
                                if type(value) == float:
                                        
                                    if len(str(value)[:-2]) != 10:
                                        modified = True
                                        newValues.append(defValue)
                                        newIndexes.append(index)
                                        
                                    else:
                                        value = str(value)
                                        value = re.sub(r'[-./\s]+', '', value) 
                                        newValues.append(value[:-1])
                                        newIndexes.append(index)

                                elif type(value) == int:
                                    if len(str(value)) != 10:
                                        modified = True
                                        newValues.append(defValue)
                                        newIndexes.append(index)
                                    
                                elif type(value) == str:
                                    value = str(value)
                                    value = re.sub(r'[-./\s]+', '', value)
                                    if len(value) != 10:
                                        modified = True
                                        newValues.append(defValue)
                                        newIndexes.append(index)
                                    
                                else:
                                    value = str(value)
                                    value = re.sub(r'[-./\s]+', '', value) 
                                    newValues.append(value[:-1])
                                    newIndexes.append(index)

                            newSeries = pd.Series(newValues, newIndexes)
                            df[colName].update(newSeries)
                            df[colName] = df[colName].astype(str)
                            #print (colName, '|Field found and processed','|Modified:', modified, '|No of Modifications:')
                            
                            #df[colName] = df[colName].fillna('6666666666')
                            #df[colName] = df[colName].astype(float)
                            #df[colName] = df[colName].astype(str)
                            #df[colName] = df[colName].map(lambda x: str(x)[:-2])
                        if 'acc' in compColName:
                            df[colName] = df[colName].fillna('')
                            #df[colName] = df[colName].astype(float)
                            df[colName] = df[colName].astype(str)
                            #df[colName] = df[colName].map(lambda x: str(x)[:-2])
                            df[colName] = [re.sub('[0-9]', '', str(x)) for x in df[colName]]
                        if 'branch c' in compColName:
                            df[colName] = df[colName].fillna('')
                            try:
                                df[colName] = df[colName].astype(float)
                                df[colName] = df[colName].astype(str)
                                df[colName] = df[colName].map(lambda x: str(x)[:-2])
                            except:
                                df[colName] = df[colName].astype(str)
                            
                        
                    df = df.replace(['0'],'')
                    df = df.astype(str)
                    #for colName in df.keys():

                    #df = df.loc[:, ~df.columns.str.contains("ole1")]
                    #df.columns = []
                    
                    df.to_excel(writer1,sheet_name='Bank', index = False)
                    print('New Sheet created____','Modified Bank Sheet')
                
                ########################################################################################################
                elif 'bound' in compKey or 'sheet' in compKey:
                    print()
                    print('Processing Sheet____',key)
                    df = dc[key]
                    
                    
                    combined = '\t'.join(list(df.columns))
                    if 'nnamed' in combined:
                        print('************************')
                        new_header = df.iloc[0] #grab the first row for the header
                        df = df[1:] #take the data less the header row
                        df.columns = new_header
                    ###########################
                      
                    #df = df.iloc[:3]
                    df.dropna(axis = 0, how = 'all', inplace = True)
                    df = df.iloc[:, :15]
                    
                    
                    perc = 25.0
                    min_count =  int(((100-perc)/100)*df.shape[1] + 1)
                    df = df.dropna( axis=0, thresh=min_count)
                    
                    
                    df = df.loc[:, ~df.columns.str.contains('^Unnamed', na=False)]
                    
                    df.columns = ['Sl No','Zone Code','Zone Name','Circle Code','Circle Name','Division Code','Division Name','SD Code','Sub Division Name','Section Code','Section Name','Village Code','Village Name','GPWSC Scheme','Scheme Code']

                    
                    #for colName in df.keys():

                    #df = df.loc[:, ~df.columns.str.contains("ole1")]
                    df = df.astype(str)
                    df = df.replace(['nan'],'')
                    
                    df.to_excel(writer1,sheet_name='Boundary Data', index = False)
                    print('New Sheet created____','Modified Boundary Sheet')
                    
                    
            writer1.save
            writer1.close
        writer.save
        writer.close
        print()
        print('---------------------'+file + '-----------------------------------.')
        print('------------------------------------------Saved Successfully-------------------------------------------------------------.')
        print('-----------------------------------------------#########-----------------------------------------------------------------.')
        print()


# In[ ]:





# In[ ]:




