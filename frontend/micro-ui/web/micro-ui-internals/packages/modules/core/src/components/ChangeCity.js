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
  const [selectedCity, setSelectedCity] = useState([]); //selectedCities?.[0]?.value
  const history = useHistory();
  const isDropdown = prop.dropdown || false;
  let selectedCities = [];

  const { data: data = {}, isLoading } =
    Digit.Hooks.hrms.useHrmsMDMS(Digit.ULBService.getCurrentTenantId(), "egov-hrms", "HRMSRolesandDesignation") || {};

  const handleChangeCity = (city) => {
    const loggedInData = Digit.SessionStorage.get("citizen.userRequestObject");
    const filteredRoles = Digit.SessionStorage.get("citizen.userRequestObject")?.info?.roles?.filter((role) => role.tenantId === city.value);
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
    const userloggedValues = Digit.SessionStorage.get("citizen.userRequestObject");
    let teantsArray = [],
      filteredArray = [];
    userloggedValues?.info?.roles?.forEach((role) => teantsArray.push(role.tenantId));
    let unique = teantsArray.filter((item, i, ar) => ar.indexOf(item) === i);

    unique?.forEach((uniCode) => {
      data?.MdmsRes?.["tenant"]["tenants"]?.map((items) => {
        if (items?.code !== "pb" && items?.code === uniCode) {
          filteredArray.push({
            label: `${prop?.t(Digit.Utils.locale.convertToLocale(items?.divisionCode, "EGOV_LOCATION_DIVISION"))} - ${prop?.t(
              `TENANT_TENANTS_${stringReplaceAll(uniCode, ".", "_")?.toUpperCase()}`
            )}`,
            value: uniCode,
          });
        } else if (items?.code === "pb" && items?.code === uniCode) {
          filteredArray.push({
            label: `TENANT_TENANTS_${stringReplaceAll(uniCode, ".", "_")?.toUpperCase()}`,
            value: uniCode,
          });
        }
      });
    });
    selectedCities = filteredArray?.filter((select) => select.value == Digit.SessionStorage.get("Employee.tenantId"));
    setSelectCityData(filteredArray);
  }, [dropDownData, data?.MdmsRes]);

  // if (isDropdown) {
  return (
    <div style={prop?.mobileView ? { color: "#767676" } : {}}>
      <Dropdown
        t={prop?.t}
        style={{ width: "150px" }}
        option={selectCityData}
        selected={dropDownData}
        optionKey={"label"}
        select={handleChangeCity}
        // freeze={true}
        // noBorder={true}
        optionCardStyles={{ overflow: "revert", display: "table" }}
        // customSelector={
        //   <label className="cp">
        //     {prop?.t(`TENANT_TENANTS_${stringReplaceAll(Digit.SessionStorage.get("Employee.tenantId"), ".", "_")?.toUpperCase()}`)}
        //   </label>
        // }
      />
    </div>
  );
  // } else {
  //   return (
  //     <React.Fragment>
  //       <div style={{ marginBottom: "5px" }}>City</div>
  //       <div className="language-selector" style={{display: "flex", flexWrap: "wrap"}}>
  //         {selectCityData?.map((city, index) => (
  //           <div className="language-button-container" key={index}>
  //             <CustomButton
  //               selected={city.value === Digit.SessionStorage.get("Employee.tenantId")}
  //               text={city.label}
  //               onClick={() => handleChangeCity(city)}
  //             ></CustomButton>
  //           </div>
  //         ))}
  //       </div>
  //     </React.Fragment>
  //   );
  // }
};

export default ChangeCity;