export const OpenSearchConfig = {
  "label": "OPEN_PAYMENT_SEARCH",
  "type": "search",
  "apiDetails": {
    "serviceName": "/ws-services/wc/_search",
    "requestParam": {},
    "requestBody": {},
    "minParametersForSearchForm": 2,
    "masterName": "commonUiConfig",
    "moduleName": "OpenPaymentSearch",
    "tableFormJsonPath": "requestBody.pagination",
    "filterFormJsonPath": "requestBody.custom",
    "searchFormJsonPath": "requestBody.custom"
  },
  "sections": {
    "search": {
      "uiConfig": {
        "type": "search",
        "headerLabel": "OPEN_PAYMENT_SEARCH",
        "headerStyle": null,
        "primaryLabel": "ES_COMMON_SEARCH",
        "secondaryLabel": "ES_COMMON_CLEAR_SEARCH",
        "minReqFields": 2,
        "showFormInstruction": "OPEN_PAYMENT_SEARCH_HINT",
        "defaultValues": {
          "consumerCode": ""
        },
        "fields": [
          {
            label: "SELECT_TENANT",
            type: "apidropdown",
            isMandatory: false,
            disable: false,
            populators: {
              "optionsCustomStyle": {
                "top": "2.3rem",
                "overflow": "auto",
                "maxHeight": "400px"
              },
              name: "tenantId",
              optionsKey: "updatedCode",
              allowMultiSelect: false,
              masterName: "commonUiConfig",
              moduleName: "OpenPaymentSearch",
              customfn: "populateReqCriteria",
            },
          },
          {
            "label": "CONNECTION_ID",
            "type": "text",
            "isMandatory": false,
            "disable": false,
            "populators": {
              "name": "consumerCode",
              "style": {
                "marginBottom": "0px"
              },
              "placeholder": "WS/7141/2024-25/****",
              // "validation":{
              //   "maxLength":"1"
              // }
            },
          },
        ]
      },
      "label": "",
      "children": {},
      "show": true
    },
    "searchResult": {
      "uiConfig": {
        "columns": [
          {
            "label": "OP_CONS_CODE",
            "jsonPath": "connectionNo",
            "additionalCustomization": true
          },
          // {
          //   "label": "OP_BILL_NUM",
          //   "jsonPath": "billNumber",
          //   // "additionalCustomization": true
          // },
          {
            "label": "OP_PAYER_NAME",
            "jsonPath": "connectionHolders[0].name",
            "additionalCustomization": true
          },
          {
            "label": "OP_APPLICATION_TYPE",
            "jsonPath": "applicationType",
            "additionalCustomization": true
          },
          {
            "label": "OP_CONNECTION_TYPE",
            "jsonPath": "connectionType",
            "additionalCustomization": true
          },
          {
            "label": "OP_METER_ID",
            "jsonPath": "meterId",
            // "additionalCustomization": true
          },
          {
            "label": "OP_CONNECTION_OLD_ID",
            "jsonPath": "oldConnectionNo",
            // "additionalCustomization": true
          },
          {
            "label": "OP_METER_INSTALLATION_DATE",
            "jsonPath": "meterInstallationDate",
            "additionalCustomization": true
          },
          {
            "label": "OP_METER_READING_DATE",
            "jsonPath": "previousReadingDate",
            "additionalCustomization": true
          },
          // {
          //   "label": "OP_PROPERTY_TYPE",
          //   "jsonPath": "additionalDetails.propertyType",
          //   "additionalCustomization": true
          // },
          {
            "label": "OP_APPLICATION_STATUS",
            "jsonPath": "status",
            "additionalCustomization": true
          },
          // {
          //   "label": "OP_SERVICE_TYPE",
          //   "jsonPath": "connectionType",
          //   "additionalCustomization": true
          // },
          // {
          //   "label": "OP_MOB_NO",
          //   "jsonPath": "mobileNumber",
          //   // "additionalCustomization": true
          // },
          // {
          //   "label": "OP_BILL_DATE",
          //   "jsonPath": "billDate",
          //   "additionalCustomization": true
          // },
          // {
          //   "label": "OP_BILL_TOTAL_AMT",
          //   "jsonPath": "totalAmount",
          //   "additionalCustomization": true
          // },
          // {
          //   "label": "TQM_PLANT",
          //   "jsonPath": "plantCode",
          //   "additionalCustomization": false,
          //   "prefix": "PQM.PLANT_",
          //   "translate": true
          // },
          // {
          //   "label": "TQM_TREATMENT_PROCESS",
          //   "jsonPath": "processCode",
          //   "additionalCustomization": false,
          //   "prefix": "PQM.Process_",
          //   "translate": true
          // },
          // {
          //   "label": "TQM_TEST_TYPE",
          //   "jsonPath": "testType",
          //   "additionalCustomization": false,
          //   "prefix": "PQM.TestType_",
          //   "translate": true
          // },
          // {
          //   "label": "ES_TQM_TEST_DATE",
          //   "jsonPath": "auditDetails.lastModifiedTime",
          //   "additionalCustomization": true
          // },
          // {
          //   "label": "TQM_TEST_RESULTS",
          //   "jsonPath": "status",
          //   "additionalCustomization": true
          // }
        ],
        // "showActionBarMobileCard": true,
        // "actionButtonLabelMobileCard": "TQM_VIEW_RESULTS",
        "enableGlobalSearch": false,
        "enableColumnSort": false,
        "resultsJsonPath": "WaterConnection",
        "tableClassName": "table pqm-table"
      },
      "children": {},
      "show": true
    }
  },
  "additionalSections": {}
}
