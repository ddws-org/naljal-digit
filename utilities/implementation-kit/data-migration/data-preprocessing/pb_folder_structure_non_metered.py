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
import json

from IPython.display import HTML, display
import warnings; warnings.simplefilter('ignore')


# In[2]:


def create_json_bound(name):
    
    bdata = {
              "tenantId": "pb."+name.lower().replace(" ", ""),
              "moduleName": "egov-location",
              "TenantBoundary": [
                {
                  "hierarchyType": {
                    "code": "REVENUE",
                    "name": "REVENUE"
                  },
                  "boundary": {
                    "id": 1,
                    "boundaryNum": 1,
                    "name": name.upper(),
                    "localname": name.upper(),
                    "longitude": None,
                    "latitude": None,
                    "label": "City",
                    "code": "pb."+name.lower().replace(" ", ""),
                    "children":[
                      {
                        "id": 1,
                        "boundaryNum": 1,
                        "name": name.upper(),
                        "localname": name.upper(),
                        "longitude": None,
                        "latitude": None,
                        "label": "Locality",
                        "code": "WARD1"
                      }
                    ]
                  }
                },
                {
                  "hierarchyType": {
                    "code": "ADMIN",
                    "name": "ADMIN"
                  },
                  "boundary": {
                    "id": 1,
                    "boundaryNum": 1,
                    "name": name.upper(),
                    "localname": name.upper(),
                    "longitude": None,
                    "latitude": None,
                    "label": "City",
                    "code": "pb."+name.lower().replace(" ", ""),
                    "children":[
                      {
                        "id": 1,
                        "boundaryNum": 1,
                        "name": name.upper(),
                        "localname": name.upper(),
                        "longitude": None,
                        "latitude": None,
                        "label": "Locality",
                        "code": "WARD1"
                      }
                    ]
                  }
                }
              ]
            }

     
    filename = "10 Divisions Multi Villages pb/"+name.lower().replace(" ", "")+"/egov-location/boundary-data.json"
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(bdata, f, ensure_ascii=False, indent=4)


def create_json_rate(name, ratec, rater):
    
    ratec = float(ratec)
    rater = float(rater)
    
    print( ratec, rater)
    
    if ratec == 0 or ratec == 'nan':
        ratec = 50
    if rater == 0 or rater == 'nan':
        rater = 50
        
    maxi = max(ratec, rater)

    rdata = {
          "tenantId": "pb."+name.lower().replace(" ", ""),
          "moduleName": "ws-services-calculation",
          "WCBillingSlab": [
            {
              "id": "1",
              "buildingType": "RESIDENTIAL",
              "connectionType": "Metered",
              "calculationAttribute": "Water consumption",
              "minimumCharge": 100,

              "slabs": [
                {
                  "from": 0,
                  "to": 20,
                  "charge": 0,
                  "meterCharge": 0
                },
                  {
                      "from": 20,
                      "to": 100000,
                      "charge": 5,
                      "meterCharge": 0
                  }
              ]
            },
            {
              "id": 2,
              "buildingType": "COMMERCIAL",
              "calculationAttribute": "Water consumption",
              "connectionType": "Metered",

              "minimumCharge": 100,

              "slabs": [
                {
                  "from": 0,
                  "to": 20,
                  "charge": 0,
                  "meterCharge": 0
                },
                  {
                      "from": 20,
                      "to": 100000,
                      "charge": 5,
                      "meterCharge": 0
                  }
              ]
            },
            {
              "id": 3,
              "buildingType": "MIXED",
              "calculationAttribute": "Water consumption",
              "connectionType": "Metered",

              "minimumCharge": 100,

              "slabs": [
                {
                  "from": 0,
                  "to": 20,
                  "charge": 0,
                  "meterCharge": 0
                },
                  {
                      "from": 20,
                      "to": 100000,
                      "charge": 5,
                      "meterCharge": 0
                  }
              ]
            },
            {
              "id": "4",
              "buildingType": "PUBLICSECTOR",
              "calculationAttribute": "Water consumption",
              "connectionType": "Metered",
              "minimumCharge": 100,

              "slabs": [
                {
                  "from": 0,
                  "to": 20,
                  "charge": 0,
                  "meterCharge": 0
                },
                  {
                      "from": 20,
                      "to": 100000,
                      "charge": 5,
                      "meterCharge": 0
                  }
              ]
            },
            {
              "id": "5",
              "buildingType": "RESIDENTIAL",
              "calculationAttribute": "Flat",
              "connectionType": "Non_Metered",

              "minimumCharge": rater
            },
            {
              "id": "6",
              "buildingType": "COMMERCIAL",
              "calculationAttribute": "Flat",
              "connectionType": "Non_Metered",

              "minimumCharge": ratec
            },
            {
              "id": "7",
              "buildingType": "MIXED",
              "calculationAttribute": "Flat",
              "connectionType": "Non_Metered",

              "minimumCharge": maxi
            },
               {
              "id": "8",
              "buildingType": "PUBLICSECTOR",
              "calculationAttribute": "Flat",
              "connectionType": "Non_Metered",

              "minimumCharge": maxi
            }
          ]
        }
        
    filename1 = "10 Divisions Multi Villages pb/"+name.lower().replace(" ", "")+"/ws-services-calculation/WCBillingSlab.json"
    os.makedirs(os.path.dirname(filename1), exist_ok=True)
    
    with open(filename1, 'w', encoding='utf-8') as f:
        json.dump(rdata, f, ensure_ascii=False, indent=4)


# In[3]:


def update_tenant(name, vc):
    
    global parent_tenant
    
    tenant = {
            "code": "pb."+name.lower().replace(" ", ""),
            "name": name.upper(),
            "description": name.upper(),
            "logoId": "",
            "imageId": None,
            "domainUrl": "",
            "type": "CITY",
            "twitterUrl": None,
            "facebookUrl": None,
            "emailId": "",
            "OfficeTimings": {
                "Mon - Fri": "9.00 AM - 5.00 PM"
            },
            "city": {
                "name": name.upper(),
                "localName": name.upper(),
                "districtCode": "",
                "districtName": None,
                "regionName": "",
                "ulbGrade": "",
                "longitude": None,
                "latitude": None,
                "shapeFileLocation": None,
                "captcha": None,
                "code": str(vc),
                "ddrName": name.upper(),
                "projectId": str(vc)
            },
            "address": name.upper(),
            "pincode": [],
            "contactNumber": "",
            "pdfHeader": "",
            "pdfContactDetails": ""
        }
    
    #tenant = json.loads(tenant)
    #parent_tenant.update(tenant)

            
    filename1 = "tenant.json"
    #os.makedirs(os.path.dirname(filename1), exist_ok=True)
    
    with open(filename1, 'a', encoding='utf-8') as f:
        json.dump(tenant, f, ensure_ascii=False, indent=4)
        f.write(',')


# In[4]:


df = pd.read_excel("10DivisonsMultiVillage.xlsx")
display(df)

pb_village_folder = ""

if os.path.exists("tenant.json"):
    os.remove("tenant.json")
    print("Tenant file already existed. Deleted successfully")
else:
    print("The file does not exist!")
    
df = df.fillna(0)

for index, row in df.iterrows():
    print(row['Village Name'])
    pb_village_folder = row['Village Name']
    
    create_json_bound(pb_village_folder)
    create_json_rate(pb_village_folder, row['Rate C'],row['Rate R'])
    update_tenant(pb_village_folder,row['Village Code'])
    


# In[ ]:





# In[ ]:




