Map<String, dynamic> getTestData() {
  return {
    ///Forgot Password Inputs
    'forgotPasswordMobileNumber': '9686151676',

    ///*********** Language Selection and Login Inputs ****************
    'selectLanguage': 2,  //For Punjabi - 0, Hindi- 1 , English - 2
    'loginPhoneNumber' : '9686151676',
    'loginPassword' : 'eGov@123',

    ///********** Edit Profile Inputs *************
    'editProfileName': 'Naveen ',
    'editProfileGender' : 'CORE_COMMON_GENDER_MALE', //For Female- CORE_COMMON_GENDER_FEMALE, Transgender- CORE_COMMON_GENDER_TRANSGENDER
    'editProfileEmail' : 'naveen@egov.in',

    ///*********** Change Password Inputs ***********
    'currentPassword': 'eGov@123 ',
    'newPassword' : 'eGov@123',
    'confirmNewPassword' : 'eGov@123',

    ///********* Search Connection Inputs *************
    'searchConnectionMobileNumber': '8145632987',
    'searchConnectionName': 'Na',
    'searchConnectionOldConnectionID': 'WS-763-88463',
    'searchConnectionNewConnectionID': 'WS/400/2021-22/0018',

    ///********* Create Consumer Inputs ***************
    'consumerName': 'Ramesh',
    'consumerGender': 'CORE_COMMON_GENDER_MALE', //For Female- CORE_COMMON_GENDER_FEMALE, Transgender- CORE_COMMON_GENDER_TRANSGENDER
    'consumerSpouseOrParent': 'Rajesh',
    'consumerPhoneNumber': '9859856321',
    'consumerCategory': 'APL', // [APL, BPL]
    'consumerSubCategory': 'SC', // [SC, ST, GENERAL]
    'consumerProperty': 'RESIDENTIAL', // [RESIDENTIAL, COMMERCIAL]
    'consumerService': 'Metered', // [Metered, Non_Metered]
    'consumerOldConnectionID': 'WS-986-456',
    'previousReadingDate': '1/10/2021',
    'consumerMeterNumber': 'ID745MS',
    'consumerMeterReadingField1': '1',
    'consumerMeterReadingField2': '3',
    'consumerMeterReadingField3': '2',
    'consumerMeterReadingField4': '4',
    'consumerMeterReadingField5': '0',
    'consumerLastBilledCycleYear': '2021',
    'consumerLastBilledCycleMonth': 'OCT',
    'consumerArrears': '100',

    ///********** Update Consumer Inputs ****************
    'updateConsumerSearchMobileNumber': '8145632987',
    'updateConsumerProperty': 'COMMERCIAL',
    'updateConsumerMarkConnectionInactive': 'No', //To mark connection inactive --- 'Yes

    ///************** Metered Bill Generation Inputs ***********
    'billGenerateSearchMobileNumber' : '9513848423',
    'newMeterReadingField1' : '1',
    'newMeterReadingField2' : '4',
    'newMeterReadingField3' : '3',
    'newMeterReadingField4' : '2',
    'newMeterReadingField5' : '0',

    ///********* Bulk Demand Generate Inputs *********
    'bulkDemandBillingYear': '2021-22',
    'bulkDemandBillingCycle': 'OCT',

    ///*******Expense Inputs ********
    'addExpenseType' : 'ELECTRICITY_BILL',
    'searchExpenseType' : 'OM',
    'expenseVendorName' : 'hara',
    'expenseVendorPhoneNum' : '9949210191',
    'expenseVendorAmount' : '1000',
    'searchExpenseBillID' : 'EB-2021-22-0270',

    ///******** GPWSC Dashboard Inputs ********
    'dashboardSearch' : 'hara',
    'graphicalDashboardMonthIndex' : 5,

    ///********* Household Register Inputs *********
    'householdSearch' : '1370',
  };
}
