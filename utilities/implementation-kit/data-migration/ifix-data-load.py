
#!/usr/bin/env python
# coding: utf-8

# In[1]:


# !/usr/bin/python
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


# In[3]:



def update_entity(id,name, code, level, child_list, newchild):
    # conn = requests.post("localhost", 8082)
    print("updating children")
    print(newchild)
    child_list.append(str(newchild))
    print(child_list)
    payload = {
        "requestHeader": {
            "ts": 1627193067,
            "version": "0.1.0",
            "msgId": "ek9d96e8-3b6b-4e36-9503-0f14a01af74n"
        },
        "departmentEntity": {
            "id": str(id),
            "tenantId": "pb",
            "departmentId": "3e2cc10e-939f-4827-a7fb-b0f09d941ef4",
            "code": str(code),
            "name": str(name),
            "hierarchyLevel": int(level),
            "children": child_list
        }
    }
    print(payload)
    headers = {
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQQVlIQWZ1YXpiRFpadlVGdEJSdmFQOWxYaHROXzBUS2FzdUpxZWl3bW04In0.eyJleHAiOjE2NDg1Njc4NzksImlhdCI6MTY0NTk3NTg3OSwianRpIjoiMmE2MGFhNjEtYzVlZC00OGNhLWI2ZTktMzFjNmY4NzA4OGZiIiwiaXNzIjoiaHR0cHM6Ly9pZml4LXVhdC5wc2Vncy5pbi9hdXRoL3JlYWxtcy9pZml4IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImJhMDE1OGFiLWZlYTMtNDc5NC04ZDE3LTRiYjc4MjFhZmM2NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlmaXgtdWF0IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZmlzY2FsLWV2ZW50LXByb2R1Y2VyIiwiZGVmYXVsdC1yb2xlcy1pZml4Il19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiY2xpZW50SG9zdCI6IjE5Mi4xNzIuMzMuMzgiLCJjbGllbnRJZCI6ImlmaXgtdWF0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJ0ZW5hbnRJZCI6InBiIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWlmaXgtdWF0IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNzIuMzMuMzgifQ.cRLfwk15rQjn4imVUzwNHvYjabqknJNee9jzWLUpZvS0rW8owuHHb6xttimTdbPCD0XBdXB-g5SNWDv0jHfSFhDbsCFmXEaIKDgG27_bZzd_ebOvZ7HMHdE83tQ_ElHBvTmfpbyYlBbhQkjQD78EMhtNx_Oyx7N-I2IlIO8X2Z9CSio52Dxkj4Pedbz5z_s87y59WPcPAhmEwoBnzzk47TBiEl70iSV7Ep09lq1kJUP2FuuvkcblriiUvlwFSfgwq2x2S6rrckVv0L29eBnz3OvVe6LWVvQ-p_28fge1qsSMOcA7Ajd7yRmoaOkwxuZ0bfCDjo9qh55JaSJ9oJhO2Q',
        'Content-Type': 'application/json'
    }
    post_response = requests.post(url=host + "/ifix-department-entity/departmentEntity/v1/_update", headers=headers,
                                  json=payload)
    res = post_response.json()

    update_status = name + ' updated'

    return update_status


# In[4]:


def create_entity(name, code, level):
    # conn = http.client.HTTPSConnection("localhost", 8080)

    payload = {
        "requestHeader": {
            "ts": 1627193067,
            "version": "0.1.0",
            "msgId": "ek9d96e8-3b6b-4e36-9503-0f14a01af74n"
        },
        "departmentEntity": {
            "tenantId": "pb",
            "departmentId": "3e2cc10e-939f-4827-a7fb-b0f09d941ef4",
            "code": str(code),
            "name": str(name),
            "hierarchyLevel": int(level),
            "children": []
        }
    }
    headers = {
        'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJQQVlIQWZ1YXpiRFpadlVGdEJSdmFQOWxYaHROXzBUS2FzdUpxZWl3bW04In0.eyJleHAiOjE2NDg1Njc4NzksImlhdCI6MTY0NTk3NTg3OSwianRpIjoiMmE2MGFhNjEtYzVlZC00OGNhLWI2ZTktMzFjNmY4NzA4OGZiIiwiaXNzIjoiaHR0cHM6Ly9pZml4LXVhdC5wc2Vncy5pbi9hdXRoL3JlYWxtcy9pZml4IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImJhMDE1OGFiLWZlYTMtNDc5NC04ZDE3LTRiYjc4MjFhZmM2NyIsInR5cCI6IkJlYXJlciIsImF6cCI6ImlmaXgtdWF0IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZmlzY2FsLWV2ZW50LXByb2R1Y2VyIiwiZGVmYXVsdC1yb2xlcy1pZml4Il19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiY2xpZW50SG9zdCI6IjE5Mi4xNzIuMzMuMzgiLCJjbGllbnRJZCI6ImlmaXgtdWF0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJ0ZW5hbnRJZCI6InBiIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LWlmaXgtdWF0IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNzIuMzMuMzgifQ.cRLfwk15rQjn4imVUzwNHvYjabqknJNee9jzWLUpZvS0rW8owuHHb6xttimTdbPCD0XBdXB-g5SNWDv0jHfSFhDbsCFmXEaIKDgG27_bZzd_ebOvZ7HMHdE83tQ_ElHBvTmfpbyYlBbhQkjQD78EMhtNx_Oyx7N-I2IlIO8X2Z9CSio52Dxkj4Pedbz5z_s87y59WPcPAhmEwoBnzzk47TBiEl70iSV7Ep09lq1kJUP2FuuvkcblriiUvlwFSfgwq2x2S6rrckVv0L29eBnz3OvVe6LWVvQ-p_28fge1qsSMOcA7Ajd7yRmoaOkwxuZ0bfCDjo9qh55JaSJ9oJhO2Q',
        'Content-Type': 'application/json'
    }

    post_response = requests.post(url=host + "/ifix-department-entity/departmentEntity/v1/_create", headers=headers,
                                  json=payload)
    res = post_response.json()

    # CODE for getting id
    departmentEntity = res.get("departmentEntity")
    tempid = departmentEntity[0]['id']

    childlist = departmentEntity[0]['children']
    return tempid, childlist


# In[5]:


def search_api(name, code, level, search_result):
    # conn = http.client.HTTPSConnection("localhost", 8034)
    # payload = {
    #     "requestHeader": {
    #         "ts": 1627193067,
    #         "version": "0.1.0",
    #         "msgId": "ek9d96e8-3b6b-4e36-9503-0f14a01af74n",
    #         "userInfo": {
    #             "uuid": "e4fd96e8-3b6b-4e36-9503-0f14a01af39d"
    #         }
    #     },
    #     "criteria": {
    #         "Ids": [],
    #         "tenantId": "pb",
    #         "departmentId": "3e2cc10e-939f-4827-a7fb-b0f09d941ef4",
    #     	"code": str(code)
    #      }
    # }
    print("calling search api for "+ name + " " + str(level) + " " + str(search_result))
    childid = search_result

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
    idd = None
    childsearch = []
    update_stat = ''
    if departmentEntity:
        idd = departmentEntity[0]['id']
        childsearch = departmentEntity[0]['children']

    if idd is None or idd == '':
        cid, child_list = create_entity(name, code, level)

        cid_status = name + ' created'
        if level < 6:

            if childid in childsearch:
                pass
            else:
                print("search result from update"+ str(childid))
                update_stat = update_entity(cid,name, code, level, childsearch, childid)

        return cid, cid_status, update_stat

    else:
        # check logic!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        # how to get id of the search
        departmentEntity = res.get("departmentEntity")
        cid = departmentEntity[0]['id']
        # cid = data['departmentHierarchyLevel'][0]['id']
        if(name!=None):
            cid_status = name + 'exists'
        update_stat = ''

        return cid, cid_status, update_stat


# In[6]:


def loadRBsheet(departmentID):
    RBsheet = pd.read_excel('RateBoundaryMergedNorth.xlsx')
    BoundaryLevels = RBsheet.iloc[:, 11:]

    BoundaryLevels.drop('GPWSC Scheme', inplace=True, axis=1)
    BoundaryLevels = BoundaryLevels.loc[:, ~BoundaryLevels.columns.str.contains('^Unnamed')]

    BoundaryLevels.drop('Scheme Code', inplace=True, axis=1)

    try:
        BoundaryLevels.drop('Sheet Name', inplace=True, axis=1)
    except:
        pass

    status_column = []

    # display(BoundaryLevels)

    for index, row in BoundaryLevels.iterrows():
        r = row.to_list()
        r = r[::-1]
        # print(r)

        # Separate codes and names into two lists
        listCodes = r[1::2]
        listNames = r[::2]

        # level 6
        search_result6, idstatus6, updatestatus6 = search_api(listNames[0], listCodes[0], 6, '')
        # level 5
        print("search_result6" + str(search_result6))
        search_result5, idstatus5, updatestatus5 = search_api(listNames[1], listCodes[1], 5, search_result6)

        # level 4
        print("search_result5" + str(search_result5))
        search_result4, idstatus4, updatestatus4 = search_api(listNames[2], listCodes[2], 4, search_result5)

        # level 3
        print("search_result4" + str(search_result4))
        search_result3, idstatus3, updatestatus3 = search_api(listNames[3], listCodes[3], 3, search_result4)

        # level 2
        print("search_result3" + str(search_result3))
        search_result2, idstatus2, updatestatus2 = search_api(listNames[4], listCodes[4], 2, search_result3)

        # level 1
        print("search_result2" + str(search_result2))
        search_result, idstatus1, updatestatus1 = search_api(listNames[5], listCodes[5], 1, search_result2)

        finalstatus = idstatus6 + ',' + updatestatus6 + ',' + idstatus5 + ',' + updatestatus5 + ',' + idstatus4 + ',' + updatestatus4 + ',' + idstatus3 + ',' + updatestatus3 + ',' + idstatus2 + ',' + updatestatus2 + ',' + idstatus1 + ',' + updatestatus1
        print(finalstatus)
        if(status_column!=None):
            status_column = status_column.append(finalstatus)

    print(status_column)

    BoundaryLevels['Status'] = status_column

    BoundaryLevels.to_excel('RateBoundaryMergedNorthStatus.xlsx')


# In[7]:


if __name__ == '__main__':
    # main ID
    departmentID = '3d9ef18a-361a-40cf-b142-dd6f998e1ad2'

    loadRBsheet(departmentID)

# In[ ]:
