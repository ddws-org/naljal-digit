import json
from typing import BinaryIO, List
import requests
from datetime import datetime, timezone, time, timedelta, date
from dateutil.relativedelta import relativedelta
from dateutil import tz
import pytz
from dateutil import parser
from decimal import Decimal
import os
import psycopg2


def getGPWSCHeirarchy():
    # call the projectmodule mdms for each unique tenant which would return the array of unique villages( i.e tenantid) along with the respectie
    # zone circle division subdivision project
    # https://realpython.com/python-requests/ helps on how make ajax calls. url put it in app.properties and read through configs

    try:
        mdms_url = os.getenv('API_URL')
        state_tenantid = os.getenv('TENANT_ID')
        mdms_requestData = {
            "RequestInfo": {
                "apiId": "mgramseva-common",
                "ver": 0.01,
                "ts": "",
                "action": "_search",
                "did": 1,
                "key": "",
                "msgId": ""
            },
            "MdmsCriteria": {
                "tenantId": state_tenantid,
                "moduleDetails": [
                    {
                        "moduleName": "tenant",
                        "masterDetails": [
                            {
                                "name": "tenants"
                            }
                        ]
                    }
                ]
            }
        }

        mdms_response = requests.post(mdms_url + 'egov-mdms-service/v1/_search', json=mdms_requestData, verify=False)

        mdms_responseData = mdms_response.json()
        # Extract tenant data
        tenantList = mdms_responseData.get('MdmsRes', {}).get('tenant', {}).get('tenants', [])
        if not tenantList:
            print("No tenants found in the response.")
            return []

        print(len(tenantList))

        # Collect hierarchy data for each tenant
        dataList = []
        for tenant in tenantList:
            tenant_code = tenant.get('code', 'Unknown')

            # Collect hierarchy information
            hierarchy_info = {
                "state": state_tenantid,
                "tenantId": tenant_code,
                "districtName": tenant.get('city', {}).get('districtName', 'N/A'),
                "blockname": tenant.get('city', {}).get('blockname', 'N/A'),
                "panchayatname": tenant.get('city', {}).get('panchayatname', 'N/A'),
                "regionName": tenant.get('city', {}).get('regionName', 'N/A')
            }
            dataList.append(hierarchy_info)

        print("heirarchy collected")
        return dataList

    except Exception as exception:
        print("Exception occurred while fetching hierarchy from MDMS")
        print(exception)


def getRateMasters(tenantId):
    # make mdms call to get the rate unique rate masters i.e billig slab . count the unique billing slabs and return the number
    print("Rate master count returned")
    try:

        url = os.getenv('API_URL')

        requestData = {
            "RequestInfo": {
                "apiId": "mgramseva-common",
                "ver": 0.01,
                "ts": "",
                "action": "_search",
                "did": 1,
                "key": "",
                "msgId": ""
            },
            "MdmsCriteria": {
                "tenantId": tenantId,
                "moduleDetails": [
                    {
                        "moduleName": "ws-services-calculation",
                        "masterDetails": [
                            {
                                "name": "WCBillingSlab"
                            }
                        ]
                    }
                ]
            }
        }

        response = requests.post(url + 'egov-mdms-service/v1/_search', json=requestData)

        responseData = response.json()
        wcBillingSlabList = responseData['MdmsRes']['ws-services-calculation']['WCBillingSlab']

        return len(wcBillingSlabList)
    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)


def getCollectionsMade(tenantId, startdate, enddate):
    # make db call with query to get the collections made in the current date in the given tenant
    # should be till date not current date.
    print("collections made returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        if startdate != None and enddate != None:
            COLLECTION_MADE_TILL_THE_CURRENT_DATE_QUERY = "select sum(amountpaid) from egcl_paymentdetail where businessservice = 'WS' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'"
        else:
            COLLECTION_MADE_TILL_THE_CURRENT_DATE_QUERY = "select sum(amountpaid) from egcl_paymentdetail where businessservice = 'WS' and tenantid = '" + tenantId + "'"

        cursor.execute(COLLECTION_MADE_TILL_THE_CURRENT_DATE_QUERY)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getCollectionsMadeOnline(tenantId):
    # make db call with query to get the collections made in the current date of type online in the given tenant, as of now no data exists but write the query
    # should be till date not current date.

    print("collections made online returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        COLLECTION_MADE_TILL_THE_CURRENT_DATE_ONLINE_QUERY = "select sum(pd.amountpaid) from egcl_payment p join egcl_paymentdetail pd on p.id = pd.paymentid where pd.businessservice = 'WS' and p.tenantid = '" + tenantId + "'" + " and p.paymentmode = 'ONLINE' "

        cursor.execute(COLLECTION_MADE_TILL_THE_CURRENT_DATE_ONLINE_QUERY)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getLastCollectionDate(tenantId, startdate, enddate):
    # make db call to get the last collection date for the given tenant
    print("lat collection date returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            LAST_COLLECTION_DATE_QUERY = "select createdtime from egcl_paymentdetail where businessservice = 'WS' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'" + " order by createdtime desc limit 1"
        else:
            LAST_COLLECTION_DATE_QUERY = "select createdtime from egcl_paymentdetail where businessservice = 'WS' and tenantid = '" + tenantId + "'" + " order by createdtime desc limit 1"

        cursor.execute(LAST_COLLECTION_DATE_QUERY)
        result = cursor.fetchone()

        formatedDate = datetime.fromtimestamp(result[0] / 1000.0)

        print(formatedDate)
        return formatedDate
    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getExpenseBillEntered(tenantId, startdate, enddate):
    # make db call to get the total no of expenses entered  in the give tenant on the current date
    # total till date not current date

    print("expense bill entered returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_NO_EXPENSES_TILL_DATE = "select count(*) from eg_echallan where typeofexpense<>'ELECTRICITY_BILL' and applicationstatus='ACTIVE' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'"
        else:
            TOTAL_NO_EXPENSES_TILL_DATE = "select count(*) from eg_echallan where typeofexpense<>'ELECTRICITY_BILL' and applicationstatus='ACTIVE' and tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_NO_EXPENSES_TILL_DATE)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getElectricityExpenseBillEntered(tenantId, startdate, enddate):
    # make db call to get the total no of expenses entered  in the give tenant on the current date
    # total till date not current date

    print("expense bill entered returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_NO_EXPENSES_TILL_DATE = "select count(*) from eg_echallan where typeofexpense='ELECTRICITY_BILL' and applicationstatus='ACTIVE' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'"
        else:
            TOTAL_NO_EXPENSES_TILL_DATE = "select count(*) from eg_echallan where typeofexpense='ELECTRICITY_BILL' and applicationstatus='ACTIVE' and tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_NO_EXPENSES_TILL_DATE)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getLastExpTransactionDate(tenantId, startdate, enddate):
    # make db call to get the latest expense bill entered date in that given tenant
    print("expense transaction date")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            LAT_EXP_BILL_DATE = "select createdtime from eg_echallan where applicationstatus='ACTIVE' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'" + " order by createdtime desc limit 1"
        else:
            LAT_EXP_BILL_DATE = "select createdtime from eg_echallan where applicationstatus='ACTIVE' and tenantid = '" + tenantId + "'" + " order by createdtime desc limit 1"

        cursor.execute(LAT_EXP_BILL_DATE)
        result = cursor.fetchone()
        formatedDate = datetime.fromtimestamp(result[0] / 1000.0)
        print(formatedDate)
        return formatedDate

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getNoOfBillsPaid(tenantId, startdate, enddate):
    # make db call to get total no of expenses bills marked as paid till current date.
    print("No of bill paid")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select count(*) from eg_echallan where typeofexpense<>'ELECTRICITY_BILL' and applicationstatus = 'PAID' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'"
        else:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select count(*) from eg_echallan where typeofexpense<>'ELECTRICITY_BILL' and tenantid = '" + tenantId + "'" + " and applicationstatus = 'PAID' "

        cursor.execute(TOTAL_EXPENSES_BILL_MARKED_PAID)
        result = cursor.fetchone()
        print(result[0])
        return result[0]
    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalAmountExpenseBills(tenantId, startdate, enddate):
    # make db call to get total no of expenses bills marked as paid till current date.
    print("No of bill paid")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select sum(dd.taxamount) from eg_echallan challan inner join egbs_Demand_v1 dem on dem.consumercode=challan.referenceid inner join egbs_Demanddetail_v1 dd on dem.id=dd.demandid where dem.status='ACTIVE' and challan.typeofexpense<>'ELECTRICITY_BILL' and challan.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and dem.tenantid = '" + tenantId + "'"
        else:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select sum(dd.taxamount) from eg_echallan challan inner join egbs_Demand_v1 dem on dem.consumercode=challan.referenceid inner join egbs_Demanddetail_v1 dd on dem.id=dd.demandid where dem.status='ACTIVE' and challan.typeofexpense<>'ELECTRICITY_BILL' and dem.tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_EXPENSES_BILL_MARKED_PAID)
        result = cursor.fetchone()
        print(result[0])
        return result[0]
    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalAmountElectricityBills(tenantId, startdate, enddate):
    # make db call to get total no of expenses bills marked as paid till current date.
    print("No of bill paid")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select sum(dd.taxamount) from eg_echallan challan inner join egbs_Demand_v1 dem on dem.consumercode=challan.referenceid inner join egbs_Demanddetail_v1 dd on dem.id=dd.demandid where dem.status='ACTIVE' and challan.typeofexpense='ELECTRICITY_BILL' and challan.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and dem.tenantid = '" + tenantId + "'"
        else:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select sum(dd.taxamount) from eg_echallan challan inner join egbs_Demand_v1 dem on dem.consumercode=challan.referenceid inner join egbs_Demanddetail_v1 dd on dem.id=dd.demandid where dem.status='ACTIVE' and challan.typeofexpense='ELECTRICITY_BILL' and dem.tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_EXPENSES_BILL_MARKED_PAID)
        result = cursor.fetchone()
        print(result[0])
        return result[0]
    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalAmountPaidBills(tenantId, startdate, enddate):
    # make db call to get total no of expenses bills marked as paid till current date.
    print("No of bill paid")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select sum(dd.taxamount) from eg_echallan challan inner join egbs_Demand_v1 dem on dem.consumercode=challan.referenceid inner join egbs_Demanddetail_v1 dd on dem.id=dd.demandid where challan.applicationstatus='PAID' and challan.typeofexpense<>'ELECTRICITY_BILL' and challan.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and dem.tenantid = '" + tenantId + "'"
        else:
            TOTAL_EXPENSES_BILL_MARKED_PAID = "select sum(dd.taxamount) from eg_echallan challan inner join egbs_Demand_v1 dem on dem.consumercode=challan.referenceid inner join egbs_Demanddetail_v1 dd on dem.id=dd.demandid where challan.applicationstatus='PAID' and challan.typeofexpense<>'ELECTRICITY_BILL' and dem.tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_EXPENSES_BILL_MARKED_PAID)
        result = cursor.fetchone()
        print(result[0])
        return result[0]
    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getRatingCount(tenantId):
    # make db call to get the total no of ratings
    print("no of ratings")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        TOTAL_RATINGS = "select count(*) from eg_ws_feedback where tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_RATINGS)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getLastRatingDate(tenantId):
    # make db call to get the last rating date entered date in that given tenant
    print("last rating date geiven")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        LAST_RATING_DATE = "select createdtime from eg_ws_feedback where tenantid = '" + tenantId + "'" + " order by createdtime desc limit 1"

        cursor.execute(LAST_RATING_DATE)
        result = cursor.fetchone()
        formatedDate = datetime.fromtimestamp(result[0] / 1000.0)
        print(formatedDate)
        return formatedDate

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getActiveUsersCount(tenantId):
    # make db call to get the total no of active users(EMPLOYEE)
    print("no of active users")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        NO_OF_ACTIVE_USERS = "select count(distinct ur.user_id) from eg_user u inner join eg_userrole_v1 ur on u.id = ur.user_id where u.active = 't' and u.type='EMPLOYEE' and ur.role_tenantid = '" + tenantId + "'"

        cursor.execute(NO_OF_ACTIVE_USERS)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalAdvanceCreated(tenantId, startdate, enddate):
    # query the postgresql db to get the total count of total advance in the given tenant till date
    print("advance sum returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        if startdate != None and enddate != None:
            ADVANCE_COUNT_QUERY = "select sum(dd.taxamount) from egbs_demanddetail_v1 dd inner join egbs_demand_v1 d on dd.demandid = d.id where d.status = 'ACTIVE' and dd.taxheadcode='WS_ADVANCE_CARRYFORWARD' and d.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and d.tenantid = '" + tenantId + "'"
        else:
            ADVANCE_COUNT_QUERY = "select sum(dd.taxamount) from egbs_demanddetail_v1 dd inner join egbs_demand_v1 d on dd.demandid = d.id where d.status = 'ACTIVE' and dd.taxheadcode='WS_ADVANCE_CARRYFORWARD' and d.tenantid = '" + tenantId + "'"

        cursor.execute(ADVANCE_COUNT_QUERY)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalPenaltyCreated(tenantId, startdate, enddate):
    # query the postgresql db to get the total count of total penalty in the given tenant till date
    print("penalty sum returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        if startdate != None and enddate != None:
            PENALTY_COUNT_QUERY = "select sum(dd.taxamount) from egbs_demanddetail_v1 dd inner join egbs_demand_v1 d on dd.demandid = d.id where d.status = 'ACTIVE' and dd.taxheadcode='WS_TIME_PENALTY' and d.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and d.tenantid = '" + tenantId + "'"
        else:
            PENALTY_COUNT_QUERY = "select sum(dd.taxamount) from egbs_demanddetail_v1 dd inner join egbs_demand_v1 d on dd.demandid = d.id where d.status = 'ACTIVE' and dd.taxheadcode='WS_TIME_PENALTY' and d.tenantid = '" + tenantId + "'"

        cursor.execute(PENALTY_COUNT_QUERY)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getConsumersCount(tenantId, startdate, enddate):
    print("consumer count returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        if startdate != None and enddate != None:
            CONSUMER_COUNT = "select count(*) from eg_ws_connection where status = 'Active' and createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'"
        else:
            CONSUMER_COUNT = "select count(*) from eg_ws_connection where status = 'Active' and tenantid = '" + tenantId + "'"
        cursor.execute(CONSUMER_COUNT)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalConsumerCount(tenantId, startdate, enddate):
    print("consumer count returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        if startdate != None and enddate != None:
            CONSUMER_COUNT = "select count(*) from eg_ws_connection where createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and tenantid = '" + tenantId + "'"
        else:
            CONSUMER_COUNT = "select count(*) from eg_ws_connection where tenantid = '" + tenantId + "'"
        cursor.execute(CONSUMER_COUNT)
        result = cursor.fetchone()
        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getLastDemandDate(tenantId, startdate, enddate):
    print("last demand date returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        if startdate != None and enddate != None:
            LAST_DEMAND_DATE = "select max(to_timestamp(taxperiodto/1000)::date) from eg_ws_connection conn left outer join egbs_demand_v1 dmd on dmd.consumercode=conn.connectionno and dmd.status='ACTIVE'                                                                                                                                            left outer join egbs_demanddetail_v1 dtl on dtl.demandid=dmd.id and taxheadcode='10101' where dtl.id is not null and conn.status='Active'and businessservice='WS' and (EXTRACT(epoch FROM (to_timestamp(taxperiodto/1000))-to_timestamp(taxperiodfrom/1000)))::int/86400<=31 and dmd.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and dmd.tenantid = '" + tenantId + "'"
        else:
            LAST_DEMAND_DATE = "select max(to_timestamp(taxperiodto/1000)::date) from eg_ws_connection conn left outer join egbs_demand_v1 dmd on dmd.consumercode=conn.connectionno and dmd.status='ACTIVE'                                                                                                                                            left outer join egbs_demanddetail_v1 dtl on dtl.demandid=dmd.id and taxheadcode='10101' where dtl.id is not null and conn.status='Active'and businessservice='WS' and (EXTRACT(epoch FROM (to_timestamp(taxperiodto/1000))-to_timestamp(taxperiodfrom/1000)))::int/86400<=31 and dmd.tenantid = '" + tenantId + "'"

        cursor.execute(LAST_DEMAND_DATE)
        result = cursor.fetchone()

        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalDemandRaised(tenantId, startdate, enddate):
    print("last demand date returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            LAST_DEMAND_COUNT = "select count(distinct dmd.consumercode) from eg_ws_connection conn left outer join egbs_demand_v1 dmd on dmd.consumercode=conn.connectionno and dmd.status='ACTIVE'                                                                                                                                            left outer join egbs_demanddetail_v1 dtl on dtl.demandid=dmd.id and taxheadcode='10101' where conn.status='Active'and businessservice='WS' and dtl.id is not null and (EXTRACT(epoch FROM (to_timestamp(taxperiodto/1000))-to_timestamp(taxperiodfrom/1000)))::int/86400<=31 and dmd.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and dmd.tenantid = '" + tenantId + "' group by taxperiodto order by taxperiodto desc limit 1 "
        else:
            LAST_DEMAND_COUNT = "select count(distinct dmd.consumercode) from eg_ws_connection conn left outer join egbs_demand_v1 dmd on dmd.consumercode=conn.connectionno and dmd.status='ACTIVE'                                                                                                                                            left outer join egbs_demanddetail_v1 dtl on dtl.demandid=dmd.id and taxheadcode='10101' where conn.status='Active'and businessservice='WS' and dtl.id is not null and (EXTRACT(epoch FROM (to_timestamp(taxperiodto/1000))-to_timestamp(taxperiodfrom/1000)))::int/86400<=31 and dmd.tenantid = '" + tenantId + "' group by taxperiodto order by taxperiodto desc limit 1"

        cursor.execute(LAST_DEMAND_COUNT)
        result = cursor.fetchone()

        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getTotalDemandAmount(tenantId, startdate, enddate):
    print("demand amount returned")
    try:
        connection = getConnection()
        cursor = connection.cursor()
        if startdate != None and enddate != None:
            TOTAL_DEMAND_AMOUNT = "select sum(dd.taxamount) from egbs_demand_v1 dem inner join egbs_demanddetail_v1 dd on dem.id=dd.demandid where dem.status='ACTIVE' and dem.businessservice='WS' and dd.taxheadcode<>'WS_ADVANCE_CARRYFORWARD' and dem.createdtime between '" + startdate + "'" + " and '" + enddate + "'" + " and dem.tenantid = '" + tenantId + "'"
        else:
            TOTAL_DEMAND_AMOUNT = "select sum(dd.taxamount) from egbs_demand_v1 dem inner join egbs_demanddetail_v1 dd on dem.id=dd.demandid where dem.status='ACTIVE' and dem.businessservice='WS' and dd.taxheadcode<>'WS_ADVANCE_CARRYFORWARD' and dem.tenantid = '" + tenantId + "'"

        cursor.execute(TOTAL_DEMAND_AMOUNT)
        result = cursor.fetchone()

        print(result[0])
        return result[0]

    except Exception as exception:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def getdaterange(i):
    epochnow = None;
    lastepoch = None
    if i == 'Last seven days':
        now = datetime.now()
        lastSevenDays = (now - timedelta(days=7)).replace(hour=0, minute=0, second=0, microsecond=0)
        lastepoch = now.strftime('%s') + '000'
        epochnow = lastSevenDays.strftime('%s') + '000'

    if i == 'Last 15 days':
        now = datetime.now()
        lastFifteenDays = (now - timedelta(days=15)).replace(hour=0, minute=0, second=0, microsecond=0)
        lastepoch = now.strftime('%s') + '000'
        epochnow = lastFifteenDays.strftime('%s') + '000'

    if i == 'currentMonth-Till date':
        today = datetime.now().year
        currentMonth = datetime.now().month
        start_date = datetime(today, currentMonth, 1)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = datetime.now().strftime('%s') + '000'

    if i == 'Previous Month':
        nowdate = datetime.now()
        today = nowdate.year
        lastonemonth = (nowdate - relativedelta(months=1)).month
        if lastonemonth == 12:
            start_date = datetime(today - 1, lastonemonth, 1)
            end_date = datetime(today, 1, 1) + timedelta(days=-1)
        else:
            start_date = datetime(today, lastonemonth, 1)
            end_date = datetime(today, lastonemonth + 1, 1) + timedelta(days=-1)
        enddate = end_date.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = enddate.strftime('%s') + '000'

    if i == 'Quarter-1':
        month = datetime.now().month
        if (month < 4):
            year = datetime.now().year - 1
        else:
            year = datetime.now().year
        start_date = datetime(year, 4, 1)
        end_date = datetime(year, 6, 30)
        end = datetime.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = end.strftime('%s') + '000'

    if i == 'Quarter-2':
        month = datetime.now().month
        if (month < 4):
            year = datetime.now().year - 1
        else:
            year = datetime.now().year
        start_date = datetime(year, 7, 1)
        end_date = datetime(year, 9, 30)
        end = datetime.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = end.strftime('%s') + '000'

    if i == 'Quarter-3':
        month = datetime.now().month
        if (month < 4):
            year = datetime.now().year - 1
        else:
            year = datetime.now().year
        start_date = datetime(year, 10, 1)
        end_date = datetime(year, 12, 31)
        end = datetime.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = end.strftime('%s') + '000'

    if i == 'Quarter-4':
        year = datetime.now().year
        start_date = datetime(year, 1, 1)
        end_date = datetime(year, 3, 31)
        end = datetime.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = end.strftime('%s') + '000'

    if i == 'FY to date':
        today = datetime.now().year
        month = datetime.now().month
        if (month < 4):
            start_date = datetime(today - 1, 4, 1)
        else:
            start_date = datetime(today, 4, 1)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = datetime.now().strftime('%s') + '000'

    if i == 'Previous 1st FY (23-24)':
        today = datetime.now().year
        lastyear = today - 1
        start_date = datetime(lastyear, 4, 1)
        end_date = datetime(today, 4, 1) + timedelta(days=-1)
        enddate = end_date.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = enddate.strftime('%s') + '000'

    if i == 'Previous 2nd FY (22-23)':
        today = datetime.now().year
        start_date = datetime(today - 2, 4, 1)
        end_date = datetime(today - 1, 4, 1) + timedelta(days=-1)
        enddate = end_date.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = enddate.strftime('%s') + '000'

    if i == 'Previous 3rd FY (21-22)':
        today = datetime.now().year
        start_date = datetime(today - 3, 4, 1)
        end_date = datetime(today - 2, 4, 1) + timedelta(days=-1)
        enddate = end_date.combine(end_date, time.max)
        epochnow = start_date.strftime('%s') + '000'
        lastepoch = enddate.strftime('%s') + '000'

    return epochnow, lastepoch


def createEntryForRollout(tenant, activeUsersCount, totalAdvance, totalPenalty, totalConsumerCount, consumerCount,
                          lastDemandGenratedDate, noOfDemandRaised, totaldemAmount, collectionsMade, lastCollectionDate,
                          expenseCount, countOfElectricityExpenseBills, noOfPaidExpenseBills, lastExpTrnsDate,
                          totalAmountOfExpenseBills, totalAmountOfElectricityBills, totalAmountOfPaidExpenseBills,
                          date):
    # create entry into new table in postgres db with the table name roll_outdashboard . enter all field into the db and additional createdtime additional column

    print("inserting data into db")
    try:
        connection = getConnection()
        cursor = connection.cursor()

        # createdTime = int(round(time.time() * 1000)) // time in currenttimemillis format

        tzInfo = pytz.timezone('Asia/Kolkata')
        createdTime = datetime.now(tz=tzInfo)
        print("createdtime -->", createdTime)

        postgres_insert_query = "INSERT INTO roll_out_dashboard (tenantid, projectcode, zone, circle, division, subdivision, section,active_users_count,total_advance,total_penalty,total_connections,active_connections, last_demand_gen_date, demand_generated_consumer_count,total_demand_amount,collection_till_date,last_collection_date,expense_count,count_of_electricity_expense_bills,no_of_paid_expense_bills,last_expense_txn_date,total_amount_of_expense_bills,total_amount_of_electricity_bills,total_amount_of_paid_expense_bills,date_range,createdtime) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        record_to_insert = (
        tenant['tenantId'], tenant['projectcode'], tenant['zone'], tenant['circle'], tenant['division'],
        tenant['subdivision'], tenant['section'], activeUsersCount, totalAdvance, totalPenalty, totalConsumerCount,
        consumerCount, lastDemandGenratedDate, noOfDemandRaised, totaldemAmount, collectionsMade, lastCollectionDate,
        expenseCount, countOfElectricityExpenseBills, noOfPaidExpenseBills, lastExpTrnsDate, totalAmountOfExpenseBills,
        totalAmountOfElectricityBills, totalAmountOfPaidExpenseBills, date, createdTime)
        cursor.execute(postgres_insert_query, record_to_insert)

        connection.commit()
        return

    except (Exception, psycopg2.Error) as error:
        print("Exception occurred while connecting to the database")
        print(exception)

    finally:
        if connection:
            cursor.close()
            connection.close()


def convert_decimal_to_float(value):
    return float(value) if isinstance(value, Decimal) else value


def convert_date_to_string(value):
    return value.isoformat() if isinstance(value, (date, datetime)) else None


def createEntryForRolloutToElasticSearch(tenant, activeUsersCount, totalAdvance, totalPenalty, totalConsumerCount,
                                         consumerCount, lastDemandGenratedDate, noOfDemandRaised, totaldemAmount,
                                         collectionsMade, lastCollectionDate, expenseCount,
                                         countOfElectricityExpenseBills, noOfPaidExpenseBills, lastExpTrnsDate,
                                         totalAmountOfExpenseBills, totalAmountOfElectricityBills,
                                         totalAmountOfPaidExpenseBills, date,tenantName):
    # url = 'http://localhost:8080/ws-calculator/waterCalculator/_rollOutDashboardSearch'
    rollOut_headers = {'Content-Type': 'application/json'}
    url = os.getenv('WS_API_URL')

    if not url:
        print("API_URL environment variable is not set.")
        return

    requestData = {
        "RequestInfo": {
            "apiId": "Rainmaker",
            "action": "",
            "did": 1,
            "key": "",
            "msgId": "20170310130900|en_IN",
            "requesterId": "",
            "ts": 1513579888683,
            "ver": ".01",
            "authToken": "572ad571-9061-444e-bcdb-84061b61f467"
        },
        "rollOutDashboard": {
            "id": 1,
            "tenantid": tenant['tenantId'],
            "projectcode": tenant['projectcode'],
            "zone": tenant['zone'],
            "circle": tenant['circle'],
            "division": tenant['division'],
            "subdivision": tenant['subdivision'],
            "section": tenant['section'],
            "activeUsersCount": activeUsersCount,
            "totalAdvance": convert_decimal_to_float(totalAdvance),
            "totalPenalty": convert_decimal_to_float(totalPenalty),
            "totalConnections": totalConsumerCount,
            "activeConnections": consumerCount,
            "lastDemandGenDate": convert_date_to_string(lastDemandGenratedDate),
            "demandGeneratedConsumerCount": noOfDemandRaised,
            "totalDemandAmount": convert_decimal_to_float(totaldemAmount),
            "collectionTillDate": convert_decimal_to_float(collectionsMade),
            "lastCollectionDate": convert_date_to_string(lastCollectionDate),
            "expenseCount": expenseCount,
            "countOfElectricityExpenseBills": countOfElectricityExpenseBills,
            "noOfPaidExpenseBills": noOfPaidExpenseBills,
            "lastExpenseTxnDate": convert_date_to_string(lastExpTrnsDate),
            "totalAmountOfExpenseBills": convert_decimal_to_float(totalAmountOfExpenseBills),
            "totalAmountOfElectricityBills": convert_decimal_to_float(totalAmountOfElectricityBills),
            "totalAmountOfPaidExpenseBills": convert_decimal_to_float(totalAmountOfPaidExpenseBills),
            "dateRange": date,
            "tenantName": tenantName
        }
    }

    print(requestData)

    try:
        response = requests.post(url + 'ws-calculator/waterCalculator/_rollOutDashboardSearch', headers=rollOut_headers,
                                 json=requestData)
        if response.status_code == 200:
            print("Successfully inserted data for tenant " + tenant['tenantId'] + " and date range " + date)
        else:
            print("Failed to insert data for tenant " + tenant['tenantId'] + " and date range " + date)
            print("Response:", response.json())
    except Exception as e:
        print("An error occurred:")
        print(e)


def process():
    print("continue is the process")

    tenants = getGPWSCHeirarchy()
    for tenant in tenants:
        print("Tenant:", tenant['tenantId'])
        tenantName = tenant['tenantName']
        print("Tenant Name:", tenantName)
        activeUsersCount = getActiveUsersCount(tenant['tenantId'])
        daterange = ['Consolidated (As on date)']
        for i, date in enumerate(daterange):
            startdate, enddate = getdaterange(date)

            totalConsumerCount = getTotalConsumerCount(tenant['tenantId'], startdate, enddate)
            if totalConsumerCount > 0:
                totaldemAmount = getTotalDemandAmount(tenant['tenantId'], startdate, enddate)
                totalAdvance = getTotalAdvanceCreated(tenant['tenantId'], startdate, enddate)
                totalPenalty = getTotalPenaltyCreated(tenant['tenantId'], startdate, enddate)
                lastDemandGenratedDate = getLastDemandDate(tenant['tenantId'], startdate, enddate)
                noOfDemandRaised = getTotalDemandRaised(tenant['tenantId'], startdate, enddate)
                lastCollectionDate = getLastCollectionDate(tenant['tenantId'], startdate, enddate)
                collectionsMade = getCollectionsMade(tenant['tenantId'], startdate, enddate)
                consumerCount = getConsumersCount(tenant['tenantId'], startdate, enddate)
            else:
                totaldemAmount = 0.0
                totalAdvance = 0.0
                totalPenalty = 0.0
                lastDemandGenratedDate = None
                noOfDemandRaised = 0
                lastCollectionDate = None
                collectionsMade = 0.0
                consumerCount = 0

            totalAmountOfExpenseBills = getTotalAmountExpenseBills(tenant['tenantId'], startdate, enddate)

            if totalAmountOfExpenseBills is not None and totalAmountOfExpenseBills > 0:
                # totalAmountOfExpenseBills = getTotalAmountExpenseBills(tenant['tenantId'], startdate, enddate)
                totalAmountOfElectricityBills = getTotalAmountElectricityBills(tenant['tenantId'], startdate, enddate)
                totalAmountOfPaidExpenseBills = getTotalAmountPaidBills(tenant['tenantId'], startdate, enddate)
                countOfElectricityExpenseBills = getElectricityExpenseBillEntered(tenant['tenantId'], startdate,enddate)
                lastExpTrnsDate = getLastExpTransactionDate(tenant['tenantId'], startdate, enddate)
                noOfPaidExpenseBills = getNoOfBillsPaid(tenant['tenantId'], startdate, enddate)
            else:
                # totalAmountOfExpenseBills = 0.0
                totalAmountOfElectricityBills = 0.0
                totalAmountOfPaidExpenseBills = 0.0
                countOfElectricityExpenseBills = 0
                lastExpTrnsDate = None
                noOfPaidExpenseBills = 0

            expenseCount = getExpenseBillEntered(tenant['tenantId'], startdate, enddate)
            # createEntryForRollout(tenant,activeUsersCount,totalAdvance, totalPenalty,totalConsumerCount,consumerCount,lastDemandGenratedDate,noOfDemandRaised,totaldemAmount,collectionsMade,lastCollectionDate, expenseCount,countOfElectricityExpenseBills,noOfPaidExpenseBills, lastExpTrnsDate, totalAmountOfExpenseBills, totalAmountOfElectricityBills, totalAmountOfPaidExpenseBills,date)
            createEntryForRolloutToElasticSearch(tenant, activeUsersCount, totalAdvance, totalPenalty,
                                                 totalConsumerCount,
                                                 consumerCount, lastDemandGenratedDate, noOfDemandRaised,
                                                 totaldemAmount,
                                                 collectionsMade, lastCollectionDate, expenseCount,
                                                 countOfElectricityExpenseBills,
                                                 noOfPaidExpenseBills, lastExpTrnsDate, totalAmountOfExpenseBills,
                                                 totalAmountOfElectricityBills, totalAmountOfPaidExpenseBills, date,tenantName)
    print("End of rollout dashboard")
    return


def getConnection():
    dbHost = os.getenv('DB_HOST')
    dbSchema = os.getenv('DB_SCHEMA')
    dbUser = os.getenv('DB_USER')
    dbPassword = os.getenv('DB_PWD')
    dbPort = os.getenv('DB_PORT')

    connection = psycopg2.connect(user=dbUser,
                                  password=dbPassword,
                                  host=dbHost,
                                  port=dbPort,
                                  database=dbSchema)

    return connection


def getCurrentDate():
    currentDate = datetime.today().strftime('%Y-%m-%d')
    currentDateInMillis = str(parser.parse(currentDate).timestamp() * 1000)

    return currentDateInMillis


def createTable():
    CREATE_TABLE_QUERY = """create table roll_out_dashboard(
        id SERIAL primary key, 	
        tenantid varchar(250) NOT NULL,
        projectcode varchar(66),
        zone varchar(250),
        circle varchar(250),
        division varchar(250),
        subdivision varchar(250),
        section varchar(250),
        active_users_count NUMERIC(10),
        total_advance NUMERIC(10),
        total_penalty NUMERIC(10),
        total_connections NUMERIC(10),
        active_connections NUMERIC(10),
        last_demand_gen_date DATE,
        demand_generated_consumer_count NUMERIC(10),
        total_demand_amount NUMERIC(10),
        collection_till_date NUMERIC(12, 2),
        last_collection_date DATE,
        expense_count BIGINT,
        count_of_electricity_expense_bills BIGINT,
        no_of_paid_expense_bills BIGINT,
        last_expense_txn_date Date,
        total_amount_of_expense_bills BIGINT,
        total_amount_of_electricity_bills BIGINT,
        total_amount_of_paid_expense_bills BIGINT,
        date_range varchar(250),
        createdtime TIMESTAMP NOT NULL
        )"""

    return CREATE_TABLE_QUERY


if __name__ == '__main__':
    print("main method started")
    process()
