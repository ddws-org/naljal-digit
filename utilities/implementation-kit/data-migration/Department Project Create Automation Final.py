#!/usr/bin/env python
# coding: utf-8

# In[1]:


#!/usr/bin/python
# -*- coding: utf-8 -*-
import csv
import pandas as pd
import numpy as np
import pytz
import requests
import json
import openpyxl
import time
import datetime
import subprocess
import os
import string
import random
import re
import http.client


# In[2]:


host = 'http://localhost:8080'
host2 = 'http://localhost:8098'


# In[3]:


def update_entity(idd, name, code, proID,departmentEntityIds, villname):
    
    departmentEntityIds.append(str(idd))
    
    payload = {
      "requestHeader": {
        "ts": 1627193067,
        "version": "2.0.0",
        "msgId": "Unknown",
        "signature": "NON",
        "userInfo": {
            "uuid": "admin"
        }
      },
      "project": {
        "id": str(proID),
        "tenantId": "pb",
        "code": str(code),
        "name": str(name),
        "expenditureId": "06c421d7-10b9-40be-b4ed-4cbdc75e7308",
        "departmentEntityIds": departmentEntityIds
      }
    }
    headers = {
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQQVlIQWZ1YXpiRFpadlVGdEJSdmFQOWxYaHROXzBUS2FzdUpxZWl3bW04In0.eyJleHAiOjE2NDg1Njc4NzksImlhdCI6MTY0NTk3NTg3OSwianRpIjoiMmE2MGFhNjEtYzVlZC00OGNhLWI2ZTktMzFjNmY4NzA4OGZiIiwiaXNzIjoiaHR0cHM6Ly9pZml4LXVhdC5wc2Vncy5pbi9hdXRoL3JlYWxtcy9pZml4IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImJhMDE1OGFiLWZlYTMtNDc5NC04ZDE3LTRiYjc4MjFhZmM2NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlmaXgtdWF0IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZmlzY2FsLWV2ZW50LXByb2R1Y2VyIiwiZGVmYXVsdC1yb2xlcy1pZml4Il19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiY2xpZW50SG9zdCI6IjE5Mi4xNzIuMzMuMzgiLCJjbGllbnRJZCI6ImlmaXgtdWF0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJ0ZW5hbnRJZCI6InBiIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWlmaXgtdWF0IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNzIuMzMuMzgifQ.cRLfwk15rQjn4imVUzwNHvYjabqknJNee9jzWLUpZvS0rW8owuHHb6xttimTdbPCD0XBdXB-g5SNWDv0jHfSFhDbsCFmXEaIKDgG27_bZzd_ebOvZ7HMHdE83tQ_ElHBvTmfpbyYlBbhQkjQD78EMhtNx_Oyx7N-I2IlIO8X2Z9CSio52Dxkj4Pedbz5z_s87y59WPcPAhmEwoBnzzk47TBiEl70iSV7Ep09lq1kJUP2FuuvkcblriiUvlwFSfgwq2x2S6rrckVv0L29eBnz3OvVe6LWVvQ-p_28fge1qsSMOcA7Ajd7yRmoaOkwxuZ0bfCDjo9qh55JaSJ9oJhO2Q',
        'Content-Type': 'application/json'
    }
    post_response = requests.post(url=host2 + "/adapter-master-data/project/v1/_update", headers=headers,
                                  json=payload)
    res = post_response.json()
    data = json.dumps(res)
    

    update_status = villname + ' updated to Project ' + name

    return update_status


# In[4]:


def create_entity(idd, name, code, villname):
    
    print("creating entity")
    
    idlist = []
    idlist.append(str(idd))
    
    payload = {
      "requestHeader": {
        "ts": 1627193067,
        "version": "2.0.0",
        "msgId": "Unknown",
        "signature": "NON",
        "userInfo": {
            "uuid": "admin"
        }
      },
      "project": {
        "tenantId": "pb",
        "code": str(code),
        "name": str(name),
        "expenditureId": "06c421d7-10b9-40be-b4ed-4cbdc75e7308",
        "departmentEntityIds":  list(idlist)
      }
    }

    
    headers = {
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQQVlIQWZ1YXpiRFpadlVGdEJSdmFQOWxYaHROXzBUS2FzdUpxZWl3bW04In0.eyJleHAiOjE2NDg1Njc4NzksImlhdCI6MTY0NTk3NTg3OSwianRpIjoiMmE2MGFhNjEtYzVlZC00OGNhLWI2ZTktMzFjNmY4NzA4OGZiIiwiaXNzIjoiaHR0cHM6Ly9pZml4LXVhdC5wc2Vncy5pbi9hdXRoL3JlYWxtcy9pZml4IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImJhMDE1OGFiLWZlYTMtNDc5NC04ZDE3LTRiYjc4MjFhZmM2NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlmaXgtdWF0IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZmlzY2FsLWV2ZW50LXByb2R1Y2VyIiwiZGVmYXVsdC1yb2xlcy1pZml4Il19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiY2xpZW50SG9zdCI6IjE5Mi4xNzIuMzMuMzgiLCJjbGllbnRJZCI6ImlmaXgtdWF0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJ0ZW5hbnRJZCI6InBiIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWlmaXgtdWF0IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNzIuMzMuMzgifQ.cRLfwk15rQjn4imVUzwNHvYjabqknJNee9jzWLUpZvS0rW8owuHHb6xttimTdbPCD0XBdXB-g5SNWDv0jHfSFhDbsCFmXEaIKDgG27_bZzd_ebOvZ7HMHdE83tQ_ElHBvTmfpbyYlBbhQkjQD78EMhtNx_Oyx7N-I2IlIO8X2Z9CSio52Dxkj4Pedbz5z_s87y59WPcPAhmEwoBnzzk47TBiEl70iSV7Ep09lq1kJUP2FuuvkcblriiUvlwFSfgwq2x2S6rrckVv0L29eBnz3OvVe6LWVvQ-p_28fge1qsSMOcA7Ajd7yRmoaOkwxuZ0bfCDjo9qh55JaSJ9oJhO2Q',
        'Content-Type': 'application/json'
    }

    post_response = requests.post(url=host2 + "/adapter-master-data/project/v1/_create", headers=headers,
                                  json=payload)
    res = post_response.json()
    
    data = json.dumps(res)
    
    
    # CODE for getting id
    project = res.get("project")
    tempid = project[0]['id']

    if tempid:
        status = name + ' project created for ' + villname
        
    else:
        status = 'Project not created'

    return status


# In[ ]:


def search_api_project(idd, villname, name, code):
    idlist = str(idd)
    print("calling project search api for "+ name)

    payload = {
      "requestHeader": {
        "ts": 1627193067,
        "version": "2.0.0",
        "msgId": "Unknown",
        "signature": "NON"
      },
      "criteria": {
        "tenantId": "pb",
          "code": str(code)
      }
    }
    headers = {
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQQVlIQWZ1YXpiRFpadlVGdEJSdmFQOWxYaHROXzBUS2FzdUpxZWl3bW04In0.eyJleHAiOjE2NDg1Njc4NzksImlhdCI6MTY0NTk3NTg3OSwianRpIjoiMmE2MGFhNjEtYzVlZC00OGNhLWI2ZTktMzFjNmY4NzA4OGZiIiwiaXNzIjoiaHR0cHM6Ly9pZml4LXVhdC5wc2Vncy5pbi9hdXRoL3JlYWxtcy9pZml4IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImJhMDE1OGFiLWZlYTMtNDc5NC04ZDE3LTRiYjc4MjFhZmM2NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlmaXgtdWF0IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZmlzY2FsLWV2ZW50LXByb2R1Y2VyIiwiZGVmYXVsdC1yb2xlcy1pZml4Il19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiY2xpZW50SG9zdCI6IjE5Mi4xNzIuMzMuMzgiLCJjbGllbnRJZCI6ImlmaXgtdWF0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJ0ZW5hbnRJZCI6InBiIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWlmaXgtdWF0IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNzIuMzMuMzgifQ.cRLfwk15rQjn4imVUzwNHvYjabqknJNee9jzWLUpZvS0rW8owuHHb6xttimTdbPCD0XBdXB-g5SNWDv0jHfSFhDbsCFmXEaIKDgG27_bZzd_ebOvZ7HMHdE83tQ_ElHBvTmfpbyYlBbhQkjQD78EMhtNx_Oyx7N-I2IlIO8X2Z9CSio52Dxkj4Pedbz5z_s87y59WPcPAhmEwoBnzzk47TBiEl70iSV7Ep09lq1kJUP2FuuvkcblriiUvlwFSfgwq2x2S6rrckVv0L29eBnz3OvVe6LWVvQ-p_28fge1qsSMOcA7Ajd7yRmoaOkwxuZ0bfCDjo9qh55JaSJ9oJhO2Q',
        'Content-Type': 'application/json'
    }
    
    #check the link
    post_response = requests.post(url=host2 + "/adapter-master-data/project/v1/_search", headers=headers,
                                  json=payload)
    res = post_response.json()
    print(res)
    # CODE for getting id
    departmentEntity = res.get("project")
    update_stat = ''
    createstat = ''
    
    if departmentEntity:
        proID = departmentEntity[0]['id']
        departmentEntityIds = departmentEntity[0]['departmentEntityIds']
        searchstat = 'Project Id exists'
        
        ##check
        print("Updating Project")
        updatestat = update_entity(idlist, name, code, proID,departmentEntityIds, villname)
        
    else:
        idd = ''
        updatestat=''
        searchstat = 'Project Id does not exist'
        
        ##Check
        createstat = create_entity(idlist, name, code, villname)
        
    return searchstat, updatestat, createstat


# In[23]:


def search_api_entity(name, code):

    print("calling search api for "+ name)

    payload = {
        "requestHeader": {
            "ts": 1627193067,
            "version": "0.1.0",
            "msgId": "ek9d96e8-3b6b-4e36-9503-0f14a01af74n",
            "userInfo": {
                "uuid": "e4fd96e8-3b6b-4e36-9503-0f14a01af39d"
            }
        },
        "criteria": {
            "Ids": [],
            "tenantId": "pb",
            "departmentId": "3e2cc10e-939f-4827-a7fb-b0f09d941ef4",
            "code": str(code)
        }
    }


    headers = {
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQQVlIQWZ1YXpiRFpadlVGdEJSdmFQOWxYaHROXzBUS2FzdUpxZWl3bW04In0.eyJleHAiOjE2NDg1Njc4NzksImlhdCI6MTY0NTk3NTg3OSwianRpIjoiMmE2MGFhNjEtYzVlZC00OGNhLWI2ZTktMzFjNmY4NzA4OGZiIiwiaXNzIjoiaHR0cHM6Ly9pZml4LXVhdC5wc2Vncy5pbi9hdXRoL3JlYWxtcy9pZml4IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImJhMDE1OGFiLWZlYTMtNDc5NC04ZDE3LTRiYjc4MjFhZmM2NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlmaXgtdWF0IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZmlzY2FsLWV2ZW50LXByb2R1Y2VyIiwiZGVmYXVsdC1yb2xlcy1pZml4Il19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiY2xpZW50SG9zdCI6IjE5Mi4xNzIuMzMuMzgiLCJjbGllbnRJZCI6ImlmaXgtdWF0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJ0ZW5hbnRJZCI6InBiIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWlmaXgtdWF0IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNzIuMzMuMzgifQ.cRLfwk15rQjn4imVUzwNHvYjabqknJNee9jzWLUpZvS0rW8owuHHb6xttimTdbPCD0XBdXB-g5SNWDv0jHfSFhDbsCFmXEaIKDgG27_bZzd_ebOvZ7HMHdE83tQ_ElHBvTmfpbyYlBbhQkjQD78EMhtNx_Oyx7N-I2IlIO8X2Z9CSio52Dxkj4Pedbz5z_s87y59WPcPAhmEwoBnzzk47TBiEl70iSV7Ep09lq1kJUP2FuuvkcblriiUvlwFSfgwq2x2S6rrckVv0L29eBnz3OvVe6LWVvQ-p_28fge1qsSMOcA7Ajd7yRmoaOkwxuZ0bfCDjo9qh55JaSJ9oJhO2Q',
        'Content-Type': 'application/json'
    }
    post_response = requests.post(url=host + "/ifix-department-entity/departmentEntity/v1/_search", headers=headers,
                                  json=payload)
    res = post_response.json()

    # CODE for getting id
    departmentEntity = res.get("departmentEntity")

    update_stat = ''
    if departmentEntity:
        idd = departmentEntity[0]['id']
        update_stat = 'Department Entity Id exists'
    else:
        idd = ''
        update_stat = 'Department Entity Id does not exist'
        
    return idd, update_stat


# In[24]:


def loadRBsheet(departmentID):
    RBsheet = pd.read_excel('RateBoundaryMergedNorth.xlsx')
    BoundaryLevels = RBsheet[['Village Code','Village Name','GPWSC Scheme','Scheme Code']]

    # display(BoundaryLevels)
    for index, row in BoundaryLevels.iterrows():
        r = row.to_list()
        
        print(r)

        # Get Key from Department Creation Entity API
        getKey, status = search_api_entity(str(r[1]),r[0])
        
        searchstat, updatestat, createstat = search_api_project(getKey,r[1], r[2], r[3])


        finalstatus = status + ',' + searchstat + ',' + updatestat + ',' + createstat

        BoundaryLevels['Status'] = finalstatus

    BoundaryLevels.to_excel('RateBoundaryMergedNorthProjectStatus.xlsx')


# In[25]:


if __name__ == '__main__':
    # main ID
    departmentID = '3d9ef18a-361a-40cf-b142-dd6f998e1ad2'

    loadRBsheet(departmentID)


# In[ ]:




