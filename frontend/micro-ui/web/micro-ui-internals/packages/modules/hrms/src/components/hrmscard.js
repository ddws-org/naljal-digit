import { PersonIcon } from "@egovernments/digit-ui-react-components";
import React from "react";
import { useTranslation } from "react-i18next";
import EmployeeModuleCard from "./EmployeeModuleCard";

const HRMSCard = () => {
  const ADMIN = Digit.Utils.hrmsAccess();
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  const DIV_ADMIN = Digit.UserService.hasAccess(["DIV_ADMIN"]);
  const MDMS_ADMIN = Digit.UserService.hasAccess(["MDMS_ADMIN"]);
  if (!ADMIN) {
    return null;
  }
  const { t } = useTranslation();
  const tenantId = Digit.ULBService.getCurrentTenantId();
  let roles = STATE_ADMIN
    ? { roles: "DIV_ADMIN, HRMS_ADMIN", isStateLevelSearch: true }
    : { roles: "SYSTEM, GP_ADMIN, COLLECTION_OPERATOR, PROFILE_UPDATE, DASHBOAD_VIEWER", isStateLevelSearch: false };
  const { isLoading, isError, error, data, ...rest } = Digit.Hooks.hrms.useHRMSCount(tenantId, roles);

  const moduleForSomeDIVAdmin =
    DIV_ADMIN && MDMS_ADMIN
      ? [
          {
            label: t("WORK_BENCH_URL_MASTER_DATA"),
            link: `${window?.location?.origin}/workbench-ui/employee/workbench/mdms-search-v2?moduleName=ws-services-calculation&masterName=WCBillingSlab`,
          },
          // {
          //   label: t("WORK_BENCH_URL_LOCALIZATION"),
          //   link: `${window?.location?.origin}/workbench-ui/employee/workbench/localisation-search`,
          // },
        ]
      : [];
  const propsForModuleCard = {
    Icon: <PersonIcon />,
    moduleName: t("ACTION_TEST_HRMS"),
    kpis: [
      {
        count: isLoading ? "-" : data?.EmployeCount?.totalEmployee,
        label: t("TOTAL_EMPLOYEES"),
        link: `/${window?.contextPath}/employee/hrms/inbox`,
      },
      {
        count: isLoading ? "-" : data?.EmployeCount?.activeEmployee,
        label: t("ACTIVE_EMPLOYEES"),
        link: `/${window?.contextPath}/employee/hrms/inbox`,
      },
    ],
    links: [
      {
        label: t("HR_HOME_SEARCH_RESULTS_HEADING"),
        link: `/${window?.contextPath}/employee/hrms/inbox`,
      },
      {
        label: STATE_ADMIN ? t("HR_COMMON_CREATE_DIVISION_EMPLOYEE_HEADER") : t("HR_COMMON_CREATE_EMPLOYEE_HEADER"),
        link: `/${window?.contextPath}/employee/hrms/create`,
      },
      // {
      //   label: t("HR_STATE_ REPORTS"),
      //   link: "https://ifix-dwss.psegs.in/digit-ui/employee/dss/dashboard/ifix",
      // },
      ...moduleForSomeDIVAdmin,
    ],
  };

  return <EmployeeModuleCard {...propsForModuleCard} />;
};

export default HRMSCard;
