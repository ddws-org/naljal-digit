import { Header, Loader, Toast } from "@egovernments/digit-ui-react-components";
import React, { useCallback, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import DesktopInbox from "../components/inbox/DesktopInbox";
import MobileInbox from "../components/inbox/MobileInbox";

const Inbox = ({ parentRoute, businessService = "HRMS", initialStates = {}, filterComponent, isInbox }) => {
  const tenantId = Digit.ULBService.getCurrentTenantId();
  const { isLoading: isLoading, Errors, data: res } = Digit.Hooks.hrms.useHRMSCount(tenantId);
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  const DIVISION_ADMIN = Digit.UserService.hasAccess(["DIV_ADMIN"]);

  const { t } = useTranslation();
  const [pageOffset, setPageOffset] = useState(initialStates.pageOffset || 0);
  const [pageSize, setPageSize] = useState(initialStates.pageSize || 10);
  const [sortParams, setSortParams] = useState([{ id: "code", desc: false }]);
  const [totalRecords, setTotalReacords] = useState(undefined);
  const [searchParams, setSearchParams] = useState(() => {
    return initialStates.searchParams || {};
  });
  const [toast, setToast] = useState(null);

  let isMobile = window.Digit.Utils.browser.isMobile();
  let paginationParams = isMobile
    ? { limit: 100, offset: pageOffset, sortBy: sortParams?.[0]?.id, sortOrder: sortParams?.[0]?.desc ? "DESC" : "ASC" }
    : { limit: pageSize, offset: pageOffset, sortBy: sortParams?.[0]?.id, sortOrder: sortParams?.[0]?.desc ? "DESC" : "ASC" };
  const isupdate = Digit.SessionStorage.get("isupdate");

  let roles = STATE_ADMIN
    ? { roles: "DIV_ADMIN", isStateLevelSearch: true }
    : {
      roles: "SYSTEM, GP_ADMIN, COLLECTION_OPERATOR, PROFILE_UPDATE, DASHBOAD_VIEWER, SARPANCH, REVENUE_COLLECTOR, SECRETARY",
      isStateLevelSearch: false,
    };

  let requestBody = {
    criteria: {
      tenantIds: searchParams?.tenantIds,
      isActive: searchParams?.isActive,
      roles: ["DIV_ADMIN", "HRMS_ADMIN"],
      type: "EMPLOYEE",
    },
  };
  if (searchParams?.hasOwnProperty("isActive")) {
    requestBody.criteria = {
      ...requestBody.criteria,
      isActive: searchParams?.isActive,
    };
  }


  const checkRoles = requestBody.criteria.roles[0] !== "DIV_ADMIN";
  const { data: divisionData, ...rests } = Digit.Hooks.hrms.useHRMSEmployeeSearch(requestBody, isupdate, {
    enabled: !STATE_ADMIN ? false : (STATE_ADMIN && searchParams?.hasOwnProperty("isActive")) || searchParams?.hasOwnProperty("tenantIds") ? true : false,
  });



  if (searchParams?.hasOwnProperty("roles")) {
    roles.roles = searchParams?.roles;
  }

  const { isLoading: hookLoading, isError, error, data, ...rest } = Digit.Hooks.hrms.useHRMSSearch(
    searchParams,
    tenantId,
    paginationParams,
    isupdate,
    roles,
    {
      enabled: (!searchParams?.hasOwnProperty("isActive") && !searchParams?.hasOwnProperty("tenantIds")) || DIVISION_ADMIN ? true : false,
    }
  );

  useEffect(() => {
    // setTotalReacords(res?.EmployeCount?.totalEmployee);
  }, [res]);

  useEffect(() => { }, [hookLoading, rest]);

  useEffect(() => {
    setPageOffset(0);
  }, [searchParams]);

  const fetchNextPage = () => {
    setPageOffset((prevState) => prevState + pageSize);
  };

  const fetchPrevPage = () => {
    setPageOffset((prevState) => prevState - pageSize);
  };

  const closeToast = () => {
    setTimeout(() => {
      setToast(null);
    }, 5000);
  };
  const handleFilterChange = (filterParam) => {
    // if (!searchParams.names || !searchParams.phone || !searchParams.codes || !filterParam.tenantIds || !filterParam.isActive) {
    //   // Show toast message
    //   setToast({ key: true, label: "Please enter a minimum one value to search" });
    //   closeToast();
    //   return; // Don't proceed with the search
    // }

    let keys_to_delete = filterParam.delete;
    let _new = { ...searchParams, ...filterParam };
    if (keys_to_delete) keys_to_delete.forEach((key) => delete _new[key]);
    filterParam.delete;
    delete _new.delete;
    if (!_new.tenantId) {
      _new = { tenantId: tenantId };
    }
    setSearchParams({ ..._new });
  };

  const handleSort = useCallback((args) => {
    if (args.length === 0) return;
    setSortParams(args);
  }, []);

  const handlePageSizeChange = (e) => {
    setPageSize(Number(e.target.value));
  };

  const getSearchFields = () => {
    return [
      {
        label: t("HR_NAME_LABEL"),
        name: "name",
      },
      {
        label: t("HR_MOB_NO_LABEL"),
        name: "phone",
        maxlength: 10,
        pattern: "[4-9][0-9]{9}",
        title: t("ES_SEARCH_APPLICATION_MOBILE_INVALID"),
        componentInFront: "+91",
      },
      {
        label: t("HR_EMPLOYEE_ID_LABEL"),
        name: "codes",
      },
    ];
  };
  if (isLoading) {
    return <Loader />;
  }

  if (data?.length !== null) {
    if (isMobile) {
      return (
        <MobileInbox
          businessService={businessService}
          data={divisionData ? divisionData : data}
          isLoading={hookLoading}
          defaultSearchParams={initialStates.searchParams}
          isSearch={!isInbox}
          onFilterChange={handleFilterChange}
          searchFields={getSearchFields()}
          onSearch={handleFilterChange}
          onSort={handleSort}
          onNextPage={fetchNextPage}
          tableConfig={rest?.tableConfig}
          onPrevPage={fetchPrevPage}
          currentPage={Math.floor(pageOffset / pageSize)}
          pageSizeLimit={pageSize}
          disableSort={false}
          onPageSizeChange={handlePageSizeChange}
          parentRoute={parentRoute}
          searchParams={searchParams}
          sortParams={sortParams}
          totalRecords={totalRecords}
          linkPrefix={`/${window?.contextPath}/employee/hrms/details/`}
          filterComponent={filterComponent}
        />
        // <div></div>
      );
    } else {
      return (
        <div>
          {isInbox && <Header>{t("HR_HOME_SEARCH_RESULTS_HEADING")}</Header>}
          <DesktopInbox
            businessService={businessService}
            data={divisionData ? divisionData : data}
            isLoading={hookLoading}
            defaultSearchParams={initialStates.searchParams}
            isSearch={!isInbox}
            onFilterChange={handleFilterChange}
            searchFields={getSearchFields()}
            onSearch={handleFilterChange}
            onSort={handleSort}
            onNextPage={fetchNextPage}
            onPrevPage={fetchPrevPage}
            currentPage={Math.floor(pageOffset / pageSize)}
            pageSizeLimit={pageSize}
            disableSort={false}
            onPageSizeChange={handlePageSizeChange}
            parentRoute={parentRoute}
            searchParams={searchParams}
            sortParams={sortParams}
            totalRecords={totalRecords}
            filterComponent={filterComponent}
          />
          {toast && (
            <Toast
              error={toast.key}
              label={t(toast.label)}
              onClose={() => {
                setToast(null);
              }}
            />
          )}
        </div>
      );
    }
  }
};

export default Inbox;
