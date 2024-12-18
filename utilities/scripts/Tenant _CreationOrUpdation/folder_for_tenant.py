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

def create_json_billing(state_code,name):

    bsdata = {
        "tenantId": state_code+"."+name.lower().replace(" ", ""),
        "moduleName": "BillingService",
        "BusinessService":[
            {
                "businessService": "EXPENSE.ELECTRICITY_BILL",
                "code": "EXPENSE.ELECTRICITY_BILL",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.SALARY",
                "code": "EXPENSE.SALARY",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.MACHINERY_REPAIR",
                "code": "EXPENSE.MACHINERY_REPAIR",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.OTHERS",
                "code": "EXPENSE.OTHERS",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "ws-services-calculation",
                "code": "WS",
                "collectionModesNotAllowed": [
                    "DD",
                    "CHEQUE",
                    "CARD",
                    "OFFLINE_NEFT",
                    "OFFLINE_RTGS",
                    "POSTAL_ORDER",
                    "ONLINE"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": True,
                "demandUpdateTime": 86400000,
                "isVoucherCreationEnabled": False,
                "billGineiURL": "egov-searcher/bill-genie/waterbills/_get",
                "isBillAmendmentEnabled": True
            },
            {
                "businessService": "EXPENSE.CHLORINATION",
                "code": "EXPENSE.CHLORINATION",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.WATER_TREATMENT",
                "code": "EXPENSE.WATER_TREATMENT",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.PIPELINE_REPAIR",
                "code": "EXPENSE.PIPELINE_REPAIR",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.NEW_MACHINERY",
                "code": "EXPENSE.NEW_MACHINERY",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.NEW_PIPELINE",
                "code": "EXPENSE.NEW_PIPELINE",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            },
            {
                "businessService": "EXPENSE.INCENTIVES",
                "code": "EXPENSE.INCENTIVES",
                "collectionModesNotAllowed": [
                    "DD"
                ],
                "partPaymentAllowed": True,
                "isAdvanceAllowed": False,
                "isVoucherCreationEnabled": True,
                "isActive": True,
                "type": "Adhoc"
            }
        ]
    }

    filename = "data/"+state_code+"/"+name.lower().replace(" ", "")+"/BillingService/BusinessService.json"
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(bsdata, f, ensure_ascii=False, indent=4)

def create_json_bound(state_code,name,pb_village_folder_local_name):
    
    bdata = {
              "tenantId": state_code+"."+name.lower().replace(" ", ""),
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
                    "name": pb_village_folder_local_name.upper(),
                    "localname": pb_village_folder_local_name.upper(),
                    "longitude": None,
                    "latitude": None,
                    "label": "City",
                    "code": state_code+"."+name.lower().replace(" ", ""),
                    "children":[
                      {
                        "id": 1,
                        "boundaryNum": 1,
                        "name": pb_village_folder_local_name.upper(),
                        "localname": pb_village_folder_local_name.upper(),
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
                    "name": pb_village_folder_local_name.upper(),
                    "localname": pb_village_folder_local_name.upper(),
                    "longitude": None,
                    "latitude": None,
                    "label": "City",
                    "code": state_code+"."+name.lower().replace(" ", ""),
                    "children":[
                      {
                        "id": 1,
                        "boundaryNum": 1,
                        "name": pb_village_folder_local_name.upper(),
                        "localname": pb_village_folder_local_name.upper(),
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

     
    filename = "data/"+state_code+"/"+name.lower().replace(" ", "")+"/egov-location/boundary-data.json"
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(bdata, f, ensure_ascii=False, indent=4)


def create_json_rate(state_code,name, ratec, rater):
    
    ratec = float(ratec)
    rater = float(rater)
    
    print( ratec, rater)
    
    if  ratec == 'nan':
        ratec = 0
    if rater == 'nan':
        rater = 0
        
    maxi = max(ratec, rater)

    rdata = {
          "tenantId": state_code+"."+name.lower().replace(" ", ""),
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
              "id": "2",
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
              "id": "3",
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
        
    filename1 = "data/"+state_code+"/"+name.lower().replace(" ", "")+"/ws-services-calculation/WCBillingSlab.json"
    os.makedirs(os.path.dirname(filename1), exist_ok=True)
    
    with open(filename1, 'w', encoding='utf-8') as f:
        json.dump(rdata, f, ensure_ascii=False, indent=4)


def create_json_penalty(state_code,name,penalty):
    penaltyset=0
    try:
        penaltyset=int(penalty)
    except:
        penaltyset=0

    pdata = {
        "tenantId": state_code+"."+name.lower().replace(" ",""),
        "moduleName": "ws-services-calculation",
        "Penalty": [
            {
                "type": "Fixed",
                "subType": "currentMonth",
                "rate": penaltyset,
                "amount": None,
                "minAmount": None,
                "applicableAfterDays": 10,
                "flatAmount": None,
                "fromFY": "2023-24",
                "startingDay": "01/04/2023"
            }
        ]
    }

    filename1 = "data/" +state_code+ "/" +name.lower().replace(" ","") + "/ws-services-calculation/Penalty.json"
    os.makedirs(os.path.dirname(filename1), exist_ok=True)

    with open(filename1, 'w', encoding='utf-8') as f:
        json.dump(pdata, f, ensure_ascii=False, indent=4)

# In[3]:

df = pd.read_excel("KA_data_IMIS .xlsx",dtype=str)
display(df)

pb_village_folder = ""
#
# if os.path.exists("tenants.json"):
#     os.remove("tenants.json")
#     print("Tenant file already existed. Deleted successfully")
# else:
#     print("The file does not exist!")
    
df = df.fillna(0)
state_code="as"
for index, row in df.iterrows():
    print(row['unique_tenant_code'])
    pb_village_folder = row['unique_tenant_code']
    pb_village_folder_local_name = row['tenant_name']

    create_json_billing(state_code,pb_village_folder)
    create_json_bound(state_code,pb_village_folder,pb_village_folder_local_name)
    create_json_rate(state_code,pb_village_folder, row['Rate_Comm'],row['Rate_Res'])
    create_json_penalty(state_code,pb_village_folder,row['Penalty'])




# In[ ]:





# In[ ]:




