import requests
import json

# Base URLs
HOST = ""  # Replace with the actual host
SEARCH_URL = HOST + "assam/mdms-v2/v2/_search"
UPDATE_URL = HOST + "assam/mdms-v2/v2/_update/ws-services-calculation.WCBillingSlab"
TOKEN_URL = HOST + "assam/user/oauth/token"

# Tenant IDs
TENANT_IDs = []  # List of tenant IDs

# Credentials for access token
USERNAME = ""  # Replace with actual username
PASSWORD = ""  # Replace with actual password

# Headers for token generation
TOKEN_HEADERS = {
    "Connection": "keep-alive",
    "content-type": "application/x-www-form-urlencoded",
    "origin": HOST,
    "Authorization": "Basic ZWdvdi11c2VyLWNsaWVudDo=",
}

# Headers for other API requests
HEADERS = {
    "accept": "application/json, text/plain, */*",
    "content-type": "application/json;charset=UTF-8",
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
}

# Function to fetch access token
def get_access_token():
    query = {
        "username": USERNAME,
        "password": PASSWORD,
        "userType": "EMPLOYEE",
        "scope": "read",
        "grant_type": "password",
        "tenantId": "as",
    }
    response = requests.post(TOKEN_URL, data=query, headers=TOKEN_HEADERS)
    if response.status_code == 200:
        return response.json().get("access_token")
    else:
        print(f"Failed to fetch access token: {response.status_code} {response.text}")
        return None

# Search request body template
def get_search_payload(tenant_id, auth_token):
    return {
        "MdmsCriteria": {
            "tenantId": tenant_id,
            "filters": {},
            "schemaCode": "ws-services-calculation.WCBillingSlab",
            "limit": 10,
            "offset": 0,
        },
        "RequestInfo": {
            "apiId": "Rainmaker",
            "authToken": auth_token,
            "userInfo": {
                "id": 15512,
                "uuid": "ced2601f-9488-4eac-8d3e-33339fd540a2",
                "userName": "4000000001",
                "name": "State User",
                "mobileNumber": "4000000001",
                "roles": [
                    {
                "name": "STATE ADMIN",
                "code": "STATE_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "MDMS ADMIN",
                "code": "MDMS_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "Localisation admin",
                "code": "LOC_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "HRMS_ADMIN",
                "code": "HRMS_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "Employee",
                "code": "EMPLOYEE",
                "tenantId": "as"
            }
                ],
                "active": True,
                "tenantId": tenant_id,
            },
            "msgId": "1735571691591|en_IN",
        },
    }

# Function to call the search API
def fetch_mdms_data(tenant_id, auth_token):
    payload = get_search_payload(tenant_id, auth_token)
    response = requests.post(SEARCH_URL, headers=HEADERS, json=payload)
    if response.status_code == 200:
        return response.json().get("mdms", [])
    else:
        print(f"Error fetching data for {tenant_id}: {response.status_code} {response.text}")
        return []

# Function to call the update API
def update_mdms_data(mdms_item, auth_token):
    update_payload = {
        "Mdms": {
            "id": mdms_item["id"],
            "tenantId": mdms_item["tenantId"],
            "schemaCode": mdms_item["schemaCode"],
            "uniqueIdentifier": mdms_item["uniqueIdentifier"],
            "data": mdms_item["data"],
            "isActive": mdms_item["isActive"],
            "auditDetails": mdms_item["auditDetails"],
        },
        "RequestInfo": {
            "apiId": "Rainmaker",
            "authToken": auth_token,
            "userInfo": {
                "id": 1522,
                "uuid": "ced2601f-9488-4eac-8d3e-33339fd540a2",
                "userName": "4000000001",
                "name": "State User",
                "mobileNumber": "4000000001",
                "roles": [
                    {
                "name": "STATE ADMIN",
                "code": "STATE_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "MDMS ADMIN",
                "code": "MDMS_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "Localisation admin",
                "code": "LOC_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "HRMS_ADMIN",
                "code": "HRMS_ADMIN",
                "tenantId": "as"
            },
            {
                "name": "Employee",
                "code": "EMPLOYEE",
                "tenantId": "as"
            }
                ],
                "active": True,
                "tenantId": mdms_item["tenantId"],
            },
            "msgId": "1735571842370|en_IN",
        },
    }
    
    response = requests.post(UPDATE_URL, headers=HEADERS, json=update_payload)
    if response.status_code == 202:
        print(f"Updated successfully: {mdms_item['uniqueIdentifier']} for tenant {mdms_item['tenantId']}")
    else:
        print(f"Error updating {mdms_item['uniqueIdentifier']} for tenant {mdms_item['tenantId']}: {response.status_code} {response.text}")

# Main function
def main():
    access_token = get_access_token()
    if not access_token:
        print("Access token retrieval failed. Exiting.")
        return

    for tenant_id in TENANT_IDs:
        print(f"Processing tenant ID: {tenant_id}")
        mdms_data = fetch_mdms_data(tenant_id, access_token)
        if not mdms_data:
            print(f"No data found for tenant ID: {tenant_id}")
            continue

        for item in mdms_data:
            if item.get('tenantId') == tenant_id:
                print(f"Tenant ID matches for item: {item.get('tenantId')}")
                # Call the update API
                update_mdms_data(item, access_token)
            else:
                print(f"Skipping item with tenantId: {item.get('tenantId')}, does not match {tenant_id}")
            

if __name__ == "__main__":
    main()
