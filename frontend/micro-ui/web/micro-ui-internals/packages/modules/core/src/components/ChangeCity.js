import { Dropdown } from "@egovernments/digit-ui-react-components";
import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";

const stringReplaceAll = (str = "", searcher = "", replaceWith = "") => {
  if (searcher == "") return str;
  while (str?.includes(searcher)) {
    str = str?.replace(searcher, replaceWith);
  }
  return str;
};

const ChangeCity = (prop) => {
  const [dropDownData, setDropDownData] = useState({
    label: `TENANT_TENANTS_${stringReplaceAll(Digit.SessionStorage.get("Employee.tenantId"), ".", "_")?.toUpperCase()}`,
    value: Digit.SessionStorage.get("Employee.tenantId"),
  });
  const [selectCityData, setSelectCityData] = useState([]);
  const history = useHistory();
  const isDropdown = prop.dropdown || false;
  let selectedCities = [];

  const uuids = [prop.userDetails?.info?.uuid];
  const { data: userData, isUserDataLoading } = Digit.Hooks.useUserSearch(Digit.ULBService.getStateId(), { uuid: uuids }, {}); 
  const { data: mdmsData = {}, isLoading: isMdmsLoading } =
    Digit.Hooks.hrms.useHrmsMDMS(Digit.ULBService.getCurrentTenantId(), "egov-hrms", "HRMSRolesandDesignation") || {};

  const handleChangeCity = (city) => {
    const loggedInData = Digit.SessionStorage.get("citizen.userRequestObject");
    const filteredRoles = loggedInData?.info?.roles?.filter((role) => role.tenantId === city.value);
    if (filteredRoles?.length > 0) {
      loggedInData.info.roles = filteredRoles;
      loggedInData.info.tenantId = city?.value;
    }

    Digit.SessionStorage.set("Employee.tenantId", city?.value);
    Digit.UserService.setUser(loggedInData);
    setDropDownData(city);
    if (window.location.href.includes(`/${window?.contextPath}/employee/`)) {
      const redirectPath = location.state?.from || `/${window?.contextPath}/employee`;
      history.replace(redirectPath);
    }
    window.location.reload();
  };

  useEffect(() => {
    const tenantId = Digit.SessionStorage.get("Employee.tenantId");

    if (!tenantId || !mdmsData?.MdmsRes?.["tenant"]["tenants"] || isUserDataLoading || isMdmsLoading) {
      return;
    }

    const tenantIds = userData?.user[0].roles?.map((role) => role.tenantId);

    const filteredArray = mdmsData.MdmsRes["tenant"]["tenants"].filter((item) => {
      if (item.code !== "pb") { // Exclude "pb" tenants
        return tenantIds?.includes(item.code);
      } else {
        return item.code === tenantId; // Include "pb" tenants matching tenantId
      }
    }).map((item) => ({
      label: item.code !== "pb" 
        ? `${prop?.t(Digit.Utils.locale.convertToLocale(item?.divisionCode, "EGOV_LOCATION_DIVISION"))} - ${prop?.t(
            `TENANT_TENANTS_${stringReplaceAll(item.code, ".", "_")?.toUpperCase()}`
          )}`
        : `TENANT_TENANTS_${stringReplaceAll(item.code, ".", "_")?.toUpperCase()}`,
      value: item.code,
    }));

    setSelectCityData(filteredArray);
    selectedCities = filteredArray.filter((select) => select.value === tenantId);

  }, [dropDownData, mdmsData?.MdmsRes, userData, isUserDataLoading, isMdmsLoading]);

  return (
    <div style={prop?.mobileView ? { color: "#767676" } : {}}>
      <Dropdown
        t={prop?.t}
        style={{ width: "150px" }}
        option={selectCityData.length > 0 ? selectCityData : [{ label: "Loading...", value: "" }]}
        selected={dropDownData}
        optionKey={"label"}
        select={handleChangeCity}
        optionCardStyles={{ overflow: "auto",
          maxHeight: "400px",
          minWidth: "20rem"
        }}
      />
    </div>
  );
};

export default ChangeCity;
