import React, { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { Header, InboxSearchComposer, Loader } from "@egovernments/digit-ui-react-components";
import { OpenSearchConfig } from "../configs/OpenSearchConfig";
import { Link } from "react-router-dom";

const OpenSearch = () => {
  const { t } = useTranslation();
  const queryParams = Digit.Hooks.useQueryParams();

  //An effect to update configs 
  // useEffect(() => {
  //   // if (!queryParams.tenantId) {
  //   //   // Update configs
  //   //   OpenSearchConfig.minParametersForSearchForm += 1;
  //   //   OpenSearchConfig.sections.search.uiConfig.minReqFields += 1;
  //   //   OpenSearchConfig.sections.search.uiConfig.defaultValues = {
  //   //     ...OpenSearchConfig.sections.search.uiConfig.defaultValues,
  //   //     tenantId: ""
  //   //   };
  //   //   OpenSearchConfig.sections.search.uiConfig.fields = [
  //   //     ...OpenSearchConfig.sections.search.uiConfig.fields,
  //   //     {
  //   //       label: "SELECT_TENANT",
  //   //       type: "dropdown",
  //   //       isMandatory: false,
  //   //       disable: false,
  //   //       populators: {
  //   //         name: "tenantId",
  //   //         optionsKey: "name",
  //   //         optionsCustomStyle: { top: "2.3rem" },
  //   //         mdmsConfig: {
  //   //           masterName: "tenants",
  //   //           moduleName: "tenant",
  //   //           localePrefix: "TENANT",
  //   //         },
  //   //       },
  //   //     },
  //   //   ];
  //   // }

  //   if (!queryParams.businessService) {
  //     // Update configs
  //     OpenSearchConfig.minParametersForSearchForm += 1;
  //     OpenSearchConfig.sections.search.uiConfig.minReqFields += 1;
  //     OpenSearchConfig.sections.search.uiConfig.defaultValues = {
  //       ...OpenSearchConfig.sections.search.uiConfig.defaultValues,
  //       businessService: ""
  //     };
  //     OpenSearchConfig.sections.search.uiConfig.fields = [
  //       ...OpenSearchConfig.sections.search.uiConfig.fields,
  //       {
  //         label: "SELECT_BS",
  //         type: "dropdown",
  //         isMandatory: false,
  //         disable: false,
  //         populators: {
  //           name: "businessService",
  //           optionsKey: "name",
  //           optionsCustomStyle: { top: "2.3rem" },
  //           mdmsConfig: {
  //             masterName: "BusinessService",
  //             moduleName: "BillingService",
  //             localePrefix: "BUSINESS_SERV",
  //           },
  //         },
  //       },
  //     ];
  //   }
  // }, []); 

  return (
    <React.Fragment>
      <div>
        {/* <Header className="works-header-search">{t("OPEN_PAYMENT_LOGIN")}</Header> */}
        {/* <div className="inbox-search-wrapper"> */}
        {/* <div className="search-wrapper">

            <div className="tooltip">
              <Link className="dropdown-user-link links-font-high" to="/mgramseva-web/employee/user/login">{t("OPEN_PAYMENT_LOGIN_ADMIN")}</Link>
              <span className="tooltiptext" style={{ whiteSpace: "nowrap" }}>{t("OPEN_PAYMENT_LOGIN_ADMIN_TOOL_TIP")}</span>
            </div>
            <br />
            <br />
            <div className="tooltip">
              <a
                href="/mgramseva" target="_blank" rel="noopener noreferrer" className="dropdown-user-link links-font-high">{t("OPEN_PAYMENT_LOGIN_EMPLOYEE")}</a>
              <span className="tooltiptext" style={{ whiteSpace: "nowrap" }}>{t("OPEN_PAYMENT_LOGIN_EMPLOYEE_TOOL_TIP")}</span>
            </div>
          </div>
        </div> */}
        <br />
        <Header className="works-header-search">{t(OpenSearchConfig?.label)}</Header>
        <div className="inbox-search-wrapper">
          <InboxSearchComposer configs={{ ...OpenSearchConfig, additionalDetails: { queryParams } }}></InboxSearchComposer>
        </div>
      </div>
    </React.Fragment >
  );
};

export default OpenSearch;
