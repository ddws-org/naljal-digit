import copy
import json

import requests
import time

# API URLs
search_url = "https://naljal-uat.digit.org/user/_search"
division_user_number = ""
authToken = "6e0df3ea-3fc8-4097-a02b-47b7b0d5d039"

# List of UUIDs
uuid_list = [
    # Add UUIDs here
]

# Request body template for the first API call
request_body_search_by_uuid = {
    "requestHeader": {
        "apiId": "mgramseva",
        "ver": 1,
        "ts": "",
        "action": "POST",
        "did": 1,
        "key": "",
        "msgId": "",
        "authToken": authToken,
        "userInfo": None
    },
    "tenantId": "ka",
    "uuid": []
}

# request_body_search_by_number = {
#     "requestHeader": {
#         "apiId": "mgramseva",
#         "ver": 1,
#         "ts": "",
#         "action": "POST",
#         "did": 1,
#         "key": "",
#         "msgId": "",
#         "authToken": authToken,
#         "userInfo": None
#     },
#     "tenantId": "pb",
#     "mobileNumber": division_user_number
# }

# Loop through the UUIDs and make the first API call
for uuid in uuid_list:
    request_body_search_by_uuid["uuid"] = [uuid]

    # Make the first API request
    response = requests.post(search_url, json=request_body_search_by_uuid)

    # Check for a successful response
    if response.status_code == 200:
        data = response.json()
        # Extract the user[0] object
        user_data = data.get('user', [])
        if user_data:
            user = user_data[0]
            # has_div_admin_role = any(role["code"] == "DIV_ADMIN" for role in user.get("roles", []))
            has_pspcl_admin_role = any(role["code"] == "PSPCL_ADMIN" for role in user.get("roles", []))
            has_hrms_admin_role = any(role["code"] == "HRMS_ADMIN" for role in user.get("roles", []))
            has_citizen_role = any(role["code"] == "CITIZEN" for role in user.get("roles", []))
            has_mdms_admin_role = any(role["code"] == "MDMS_ADMIN" for role in user.get("roles", []))
            has_localization_admin_role = any(role["code"] == "LOC_ADMIN" for role in user.get("roles", []))

            if not (has_pspcl_admin_role or has_citizen_role or has_mdms_admin_role or has_localization_admin_role):
                del user["createdDate"]
                del user["lastModifiedDate"]
                del user["pwdExpiryDate"]

                user["dob"] = "805075200000"
                user["defaultPwdChgd"] = "True"
                roles = user.get("roles", [])

                role = roles[0]
                primary_tenant_id = "ka"

                # Create a dictionary to store the results
                tenant_roles_map = {}

                current_time_milliseconds = int(time.time() * 1000)
                jurisdiction_data = [
                   
                ]

                # Iterate through the roles and populate the tenant_roles_map
                for role in roles:
                    tenant_id = role["tenantId"]
                    if tenant_id not in tenant_roles_map:
                        tenant_roles_map[tenant_id] = []
                    tenant_roles_map[tenant_id].append(role)

                if not (has_hrms_admin_role):
                    for tenant_id, tenant_roles in tenant_roles_map.items():
                        temp_role = [
                            {
                                "code": "HRMS_ADMIN",
                                "name": "HRMS_ADMIN",
                                "tenantId": tenant_id
                            }
                        ]
                        tenant_roles_map[tenant_id].extend(temp_role)
                        user["roles"]=tenant_roles

                # Print the resulting dictionary
                for tenant_id, tenant_roles in tenant_roles_map.items():
                    if(tenant_id != "ka"):
                        new_data_entry = {
                        "hierarchy": "REVENUE",
                        "boundaryType": "City",
                        "boundary": tenant_id,
                        "tenantId": tenant_id,
                        "roles": tenant_roles
                        }
                        jurisdiction_data.append(new_data_entry)

                    

                # Create the request body for the second API call
                create_employee_body = {
                    "Employees": [
                        {
                            "id": user["id"],
                            "uuid": user["uuid"],
                            "tenantId": primary_tenant_id,
                            "employeeStatus": "EMPLOYED",
                            "assignments": [
                                {
                                    "fromDate": current_time_milliseconds,
                                    "isCurrentAssignment": "true",
                                    "department": "DWSS",
                                    "designation": "DESIG_61"
                                }
                            ],
                            "dateOfAppointment": current_time_milliseconds,
                            "employeeType": "PERMANENT",
                            "jurisdictions": jurisdiction_data,
                            "user": user,
                            "serviceHistory": [],
                            "education": [],
                            "tests": []
                        }
                    ],
                    "key": "CREATE",
                    "action": "CREATE",
                    "RequestInfo": {
                        "apiId": "Rainmaker",
                        "authToken": authToken,
                        "userInfo": {
                            "uuid": "4c9a3af1-4f8b-4887-9ff6-f43f813a3d13",
                            "tenantId": "ka",
                        },
                        "msgId": "1695277002383|en_IN",
                        "plainAccessRequest": {}
                    }
                }

                print("Employee create body:", create_employee_body)

                url = "https://naljal-uat.digit.org/user/users/_updatenovalidate"

                user_copy=copy.deepcopy(user)
                user_copy["dob"]=None

                payload = json.dumps({
                    "RequestInfo": {
                        "api_id": "1",
                        "ver": "1",
                        "ts": None,
                        "action": "create",
                        "did": "",
                        "key": "",
                        "msg_id": "",
                        "requester_id": "",
                        "authToken": authToken,
                        "token_type": "bearer"
                    },
                    "User": user_copy
                })
                headers = {
                    'Content-Type': 'application/json'
                }

                print("User update body",payload)

                response = requests.request("POST", url, headers=headers, data=payload)

                print(response.json())

                create_employee_url = "https://naljal-uat.digit.org/egov-hrms/employees/_create?tenantId=" + primary_tenant_id + "&_=" + str(current_time_milliseconds)

                # Make the second API call
                if len(jurisdiction_data) != 0:
                    create_employee_response = requests.post(create_employee_url, json=create_employee_body)

                    # Check the response for the second API call
                    if create_employee_response.status_code == 202:
                        create_employee_data = create_employee_response.json()
                        print("Successfully created employee:", uuid)
                    else:
                        print("Error creating employee:", uuid, ":", create_employee_response.status_code, create_employee_response.text)
                else:
                    print("user with uuid",uuid," has only ka tenant mapped to it, skipping employee creation.")

            else:
                print("User with UUID", uuid, " has div admi or pspcl admin or hrms admin or mdms admin or loc admin role, skipping employee creation.")
        else:
            print("No user data found for UUID", uuid)
    else:
        print("Error for UUID:", uuid, ":", response.status_code, response.text)
