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
    ? { roles: "DIV_ADMIN", isStateLevelSearch: true }
    : {
        roles: "SYSTEM, GP_ADMIN, COLLECTION_OPERATOR, PROFILE_UPDATE, DASHBOAD_VIEWER, SARPANCH, REVENUE_COLLECTOR, SECRETARY",
        isStateLevelSearch: false,
      };
  const { isLoading, isError, error, data, ...rest } = Digit.Hooks.hrms.useHRMSCount(tenantId, roles);

  const moduleForSomeDIVAdmin =
    DIV_ADMIN && MDMS_ADMIN
      ? [
          {
            label: t("WORK_BENCH_URL_MASTER_DATA"),
            link: `${window?.location?.origin}/workbench-ui/employee/workbench/mdms-search-v2?moduleName=ws-services-calculation&masterName=WCBillingSlab`,
            category: t("HR_EDIT_MASTER"),
          },
        ]
      : [];

  const moduleForSomeSTATEUser =
    STATE_ADMIN && MDMS_ADMIN
      ? [
          {
            label: t("WORK_BENCH_URL_VILLAGE_MASTER_DATA"),
            link: `${window?.location?.origin}/workbench-ui/employee/workbench/mdms-search-v2?moduleName=tenant&masterName=tenants`,
            category: t("HR_EDIT_MASTER"),
          },
        ]
      : [];

  const moduleForDivisionUser =
    DIV_ADMIN && MDMS_ADMIN
      ? [
          {
            label: t("WORK_BENCH_URL_PENALTY_MASTER_DATA"),
            link: `${window?.location?.origin}/workbench-ui/employee/workbench/mdms-search-v2?moduleName=ws-services-calculation&masterName=Penalty`,
            category: t("HR_EDIT_MASTER"),
          },
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
        label: STATE_ADMIN ? t("HR_COMMON_CREATE_DIVISION_EMPLOYEE_HEADER") : t("HR_COMMON_CREATE_EMPLOYEE_HEADER"),
        link: `/${window?.contextPath}/employee/hrms/create`,
        category: t("HR_CREATE_USER_HEADER"),
      },
      {
        label: STATE_ADMIN ? t("HR_DIVISION_SEARCH_USER") : t("HR_SEARCH_USER"),
        link: `/${window?.contextPath}/employee/hrms/search-user`,
        roles: ["DIV_ADMIN", "STATE_ADMIN"],
        category: t("SEARCH_USER_HEADER"),
      },
      {
        label: t("HR_HOME_SEARCH_RESULTS_HEADING"),
        link: `/${window?.contextPath}/employee/hrms/inbox`,
        category: t("SEARCH_USER_HEADER"),
      },

 {
            label: t("HR_STATE_ REPORTS"),
            link: `/${window?.contextPath}/employee/hrms/dashboard?moduleName=dashboard&pageName=state`,
            category: t("HR_DASHBOARD_HEADER"),
          },
      {
        label: t("HR_RATE_DASHBOARD"),
        link: `/${window?.contextPath}/employee/hrms/dashboard?moduleName=dashboard&pageName=rate-master`,
        category: t("HR_DASHBOARD_HEADER"),
      },
      {
        label: t("HR_ROLLOUT_DASHBOARD"),
        link: `/${window?.contextPath}/employee/hrms/dashboard?moduleName=dashboard&pageName=rollout`,
        category: t("HR_DASHBOARD_HEADER"),
      },
      ...moduleForSomeDIVAdmin,
      ...moduleForSomeSTATEUser,
      ...moduleForDivisionUser,
    ],
  };

  return <EmployeeModuleCard {...propsForModuleCard} />;
};

export default HRMSCard;
