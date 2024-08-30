import { CardLabel, Dropdown, LabelFieldPair, Loader, RemoveableTag } from "@egovernments/digit-ui-react-components";
import React, { useEffect, useState } from "react";
import cleanup from "../Utils/cleanup";
import MultiSelectDropdown from "./Multiselect";
import { useParams } from "react-router-dom";

const makeDefaultValues = (sessionFormData) => {
  return sessionFormData?.Jurisdictions?.map((ele, index) => {
    return {
      key: index,
      hierarchy: {
        code: ele?.hierarchy,
        name: ele?.hierarchy,
      },
      boundaryType: { label: ele?.boundaryType, i18text: ele.boundaryType ? `EGOV_LOCATION_BOUNDARYTYPE_${ele.boundaryType?.toUpperCase()}` : null },
      boundary: { code: ele?.boundary },
      divisionBoundary: ele?.divisionBoundary,
      division: ele?.division,
      designation: ele?.designation,
      roles: ele?.roles,
      department: ele?.department,
      designation: ele?.designation


    };
  });
};

const SelectUserTypeAndDesignation = ({ t, config, onSelect, userType, formData }) => {
  const tenantId = Digit.ULBService.getCurrentTenantId();
  const [inactiveJurisdictions, setInactiveJurisdictions] = useState([]);
  const { data: data = {}, isLoading } = Digit.Hooks.hrms.useHrmsMDMS(tenantId, "egov-hrms", "HRMSRolesandDesignation") || {};
  const { id: employeeId } = useParams();
  const isupdate = Digit.SessionStorage.get("isupdate");
  const userDetails = Digit.UserService.getUser();
  const uuids = [userDetails?.info?.uuid];
  const { data: userData, isUserDataLoading } = Digit.Hooks.useUserSearch(Digit.ULBService.getStateId(), { uuid: uuids }, {});
  const employeeCreateSession = Digit.Hooks.useSessionStorage("NEW_EMPLOYEE_CREATE", {});
  const [sessionFormData, setSessionFormData, clearSessionFormData] = employeeCreateSession;
  const isEdit = window.location.href?.includes("hrms/edit");
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  const [Boundary, selectboundary] = useState([]);
  const [jurisdictions, setjurisdictions] = useState(
    !isEdit && sessionFormData?.Jurisdictions?.length > 0
      ? makeDefaultValues(sessionFormData)
      : formData?.Jurisdictions || [
        {
          id: undefined,
          key: 1,
          hierarchy: null,
          boundaryType: null,
          boundary: null,
          division: {},
          divisionBoundary: [],
          roles: [],
          department: {},
          designation: {}
        },
      ]
  );



  const [userTypeDesignation, setUserTypeDesignation] = useState(
    !isEdit && sessionFormData?.Jurisdictions?.length > 0
      ? makeDefaultValues(sessionFormData)
      : formData?.Jurisdictions || [
        {
          id: undefined,
          key: 1,
          hierarchy: null,
          boundaryType: null,
          boundary: null,
          division: {},
          department: {},
          designation: {},
          divisionBoundary: [],
          roles: [],
        },
      ]
  );
  const [jurisdictionsData, setJuristictionsData] = useState([]);
  let hierarchylist = [];
  // const hierarchyData = data?.MdmsRes?.["egov-location"]["TenantBoundary"].filter((ele) => ele?.hierarchyType?.code == "REVENUE")[0]?.hierarchyType;
  // hierarchylist.push(hierarchyData);

  // User Details
  const { isLoadingDesignation, isError, error, data: responseData, ...rest } = Digit.Hooks.hrms.useHRMSSearch({ codes: employeeId }, tenantId, null, isupdate);



  let divisions = [];
  divisions = data?.MdmsRes?.["tenant"]["tenants"]
    ?.filter((items) => items?.divisionCode)
    ?.map((item) => {
      return {
        code: item.divisionCode,
        name: item.divisionName,
        i18text: Digit.Utils.locale.getCityLocale(item.divisionCode),
      };
    });
  const uniqueDivisions = divisions?.reduce((unique, obj) => {
    const isDuplicate = unique.some((item) => item.id === obj.id && item.name === obj.name);
    if (!isDuplicate) {
      unique.push(obj);
    }
    return unique;
  }, []);

  useEffect(() => {
    let cities = userData?.user[0]?.roles?.map((role) => role.tenantId)?.filter((value, index, array) => array.indexOf(value) === index);

    selectboundary(
      data?.MdmsRes?.tenant?.tenants
        ?.filter((city) => city.code != Digit.ULBService.getStateId() && cities?.includes(city.code))
        ?.map((city) => {
          return { ...city, i18text: Digit.Utils.locale.getCityLocale(city.code) };
        })
    );
  }, [data, userData]);

  useEffect(() => {
    let jurisdictionData = jurisdictions?.map((jurisdiction) => {
      let res = {
        id: jurisdiction?.id,
        hierarchy: jurisdiction?.boundary?.code,
        boundaryType: "City",
        boundary: jurisdiction?.boundary?.code,
        tenantId: STATE_ADMIN ? jurisdiction?.divisionBoundary && jurisdiction?.divisionBoundary[0]?.code : jurisdiction?.boundary?.code,
        auditDetails: jurisdiction?.auditDetails,
        division: jurisdiction?.division,
        department: jurisdiction?.department,
        designation: jurisdiction?.designation
      };
      res = cleanup(res);
      if (jurisdiction?.roles) {
        res["roles"] = jurisdiction?.roles.map((ele) => {
          delete ele.description;
          return ele;
        });
      }
      if (jurisdiction?.divisionBoundary) {
        res["divisionBoundary"] = jurisdiction?.divisionBoundary;
      }
      if (isEdit && STATE_ADMIN) {
        data?.MdmsRes?.["tenant"]["tenants"]?.map((items) => {
          if (items?.code === jurisdiction?.boundary?.code) {
            res["division"] = {
              code: items?.divisionCode,
              i18text: Digit.Utils.locale.convertToLocale(items?.divisionCode, "EGOV_LOCATION_DIVISION"),
            };
            res["divisionBoundary"] = [
              {
                name: items.name,
                code: items.code,
                i18text: Digit.Utils.locale.getCityLocale(items.code),
              },
            ];
          }
        });
      }
      return res;
    });
    if (isEdit && STATE_ADMIN) {
      let divisionData = [];
      if (isEdit && jurisdictionData.length > 0) {
        jurisdictionData?.map((jurisdiction) => {
          if (jurisdiction?.divisionBoundary && jurisdiction?.divisionBoundary?.length > 0 && divisionData.length === 0) {
            divisionData.push(jurisdiction);
          } else if (divisionData.length > 0) {
            if (divisionData[divisionData.length - 1]?.division?.code !== jurisdiction?.division?.code) {
              divisionData.push(jurisdiction);
            }
          }
        });
      }

      let finalData = [];
      divisionData &&
        divisionData?.length > 0 &&
        divisionData?.map((data, index) => {
          let divisionBoundarydata = [];
          jurisdictionData?.map((jurisdiction) => {
            if (data?.division?.code === jurisdiction?.division?.code) {
              if (divisionBoundarydata?.length === 0) {
                jurisdiction?.divisionBoundary[0] !== undefined && divisionBoundarydata.push(jurisdiction?.divisionBoundary[0]);
              } else if (divisionBoundarydata?.length > 0) {
                if (divisionBoundarydata[divisionBoundarydata?.length - 1]?.code !== jurisdiction?.divisionBoundary[0]) {
                  jurisdiction?.divisionBoundary[0] !== undefined && divisionBoundarydata.push(jurisdiction?.divisionBoundary[0]);
                }
              }
            }
          });
          let obj = {
            ...data,
            key: index,
            divisionBoundary: divisionBoundarydata,
          };
          finalData.push(obj);
        });

      jurisdictionData = finalData;
    }
    setJuristictionsData(jurisdictionData);
    onSelect(
      config.key,
      [...jurisdictionData, ...inactiveJurisdictions].filter((value) => Object.keys(value).length !== 0)
    );

  }, [jurisdictions, data?.MdmsRes]);

  const reviseIndexKeys = () => {
    setjurisdictions((prev) => prev.map((unit, index) => ({ ...unit, key: index })));
  };

  function filterJurisdictions(unit, jurisdictions) {
    const divisionBoundaryCodes = new Set(unit.divisionBoundary.map(item => item.code));
    return jurisdictions.filter(jurisdiction => {
      return !divisionBoundaryCodes.has(jurisdiction.boundary.code);
    });
  }
  const handleRemoveUnit = (unit) => {
    if (STATE_ADMIN) {
      if (!isEdit) {
        setjurisdictions(jurisdictions.filter(
          (element) => element.key !== unit.key
        ));
        setjurisdictions((prev) => prev.map((unit, index) => ({ ...unit, key: index })));
      }
      else {
        setJuristictionsData(jurisdictionsData.filter(
          (element) => element.key !== unit.key
        ));
        let filterJurisdictionsItems = filterJurisdictions(unit, jurisdictions);
        setjurisdictions(filterJurisdictionsItems);
        setjurisdictions((prev) => prev.map((unit, index) => ({ ...unit, key: index })));
      }
      if (FormData.errors?.Jurisdictions?.type == unit.key) {
        clearErrors("Jurisdictions");
      }
      reviseIndexKeys();
    }
    else {
      if (unit.id) {
        let res = {
          id: unit?.id,
          hierarchy: unit?.hierarchy?.code,
          boundaryType: unit?.boundaryType?.label,
          boundary: unit?.boundary?.code,
          division: unit?.division?.code,
          tenantId: unit?.boundary?.code,
          auditDetails: unit?.auditDetails,
          isdeleted: true,
          isActive: false,
        };
        res = cleanup(res);
        if (unit?.roles) {
          res["roles"] = unit?.roles.map((ele) => {
            delete ele.description;
            return ele;
          });
        }
        setInactiveJurisdictions([...inactiveJurisdictions, res]);
      }
      setJuristictionsData((pre) => pre.filter((el) => el.key !== unit.key));
      setjurisdictions((prev) => prev.filter((el) => el.key !== unit.key));
      if (FormData.errors?.Jurisdictions?.type == unit.key) {
        clearErrors("Jurisdictions");
      }

      reviseIndexKeys();

    }

  };
  let boundaryTypeoption = [];
  const [focusIndex, setFocusIndex] = useState(-1);



  function getroledata() {
    if (STATE_ADMIN) {
      // Specify the role codes you want to filter
      const roleCodesToFilter = ["HRMS_ADMIN", "EMPLOYEE", "DIV_ADMIN"];
      // Use the filter method to extract roles with the specified codes
      return data?.MdmsRes?.["ws-services-masters"]["WSServiceRoles"]
        .filter((role) => {
          return roleCodesToFilter.includes(role.code);
        })
        .map((role) => {
          return { code: role.code, name: role?.name ? role?.name : " ", i18text: "ACCESSCONTROL_ROLES_ROLES_" + role.code };
        });
    } else {
      // Specify the role codes you want to filter
      const roleCodesToFilter = ["HRMS_ADMIN", "DIV_ADMIN", "MDMS_ADMIN", "LOC_ADMIN", "SYSTEM"];
      // Use the filter method to extract roles with the specified codes
      return data?.MdmsRes?.["ws-services-masters"].WSServiceRoles?.filter((role) => {
        return !roleCodesToFilter.includes(role.code);
      })?.map((role) => {
        return { code: role.code, name: role?.name ? role?.name : " ", i18text: "ACCESSCONTROL_ROLES_ROLES_" + role.code };
      });
    }
  }

  function getdesignationdata() {

    return data?.MdmsRes?.["common-masters"]?.Designation?.map((ele) => {
      ele["i18key"] = t("COMMON_MASTERS_DESIGNATION_" + ele.code);
      return ele;
    });
  }
  function getUserTypes() {
    return data?.MdmsRes?.["common-masters"]?.Department?.map((ele) => {
      ele["i18key"] = t("COMMON_MASTERS_DEPARTMENT" + ele.code);
      return ele;
    });
  }

  if (isLoading && isUserDataLoading && isLoadingDesignation) {
    return <Loader />;
  }

  return (
    <div>
      <Jurisdiction
        t={t}
        formData={formData}
        jurisdictions={jurisdictions}
        key={0}
        keys={jurisdictions[0].key}
        data={data}
        userDetails={userData?.user[0]}
        jurisdiction={jurisdictions[0]}
        setjurisdictions={setjurisdictions}
        index={0}
        focusIndex={focusIndex}
        setFocusIndex={setFocusIndex}
        hierarchylist={hierarchylist}
        divisions={uniqueDivisions}
        boundaryTypeoption={boundaryTypeoption}
        getroledata={getroledata}
        handleRemoveUnit={handleRemoveUnit}
        Boundary={Boundary}
        getdesignationdata={getdesignationdata()}
        getUserTypes={getUserTypes()}
        config={config}
        onSelect={onSelect}
        responseData={responseData}
      />
    </div>
  );
};

function Jurisdiction({
  t,
  formData,
  data,
  userDetails,
  jurisdiction,
  jurisdictions,
  setjurisdictions,
  setJuristictionsData,
  jurisdictionsData,
  onSelect,
  config,
  handleRemoveUnit,
  hierarchylist,
  divisions,
  getroledata,
  roleoption,
  index,
  Boundary,
  getdesignationdata,
  getUserTypes,
  responseData
}) {
  // console.log(responseData?.Employees[0]?.assignments[0]?.department, "responseData");
  // console.log(responseData?.Employees[0]?.assignments[0]?.designation, "responseData");

  const [BoundaryType, selectBoundaryType] = useState([]);
  const [divisionBoundary, setDivisionBoundary] = useState([]);
  const [designationList, setDesignationList] = useState([]);
  const [depamentValue, setDepamentValue] = useState("");
  const [designationValue, setDesignationValue] = useState("");

  const [Division, setDivision] = useState([]);
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  let isMobile = window.Digit.Utils.browser.isMobile();
  const isEdit = window.location.href?.includes("hrms/edit");
  let defaultjurisdiction = () => {
    let currentTenant = Digit.ULBService.getCurrentTenantId();
    let defaultjurisdiction;
    Boundary?.map((ele) => {
      if (ele.code === currentTenant) {
        defaultjurisdiction = ele;
      }
    })
    return defaultjurisdiction;
  }
  useEffect(() => {

    if (responseData != null && depamentValue == "" && isEdit) {
      getUserTypes?.forEach((ele) => {
        if (ele.code === responseData?.Employees[0]?.assignments[0]?.department) {
          setDepamentValue(ele);
          const filteredItems = getdesignationdata.filter(val => val.department.includes(ele.code));
          setDesignationList(filteredItems);
          setjurisdictions((pre) => pre.map((item) => (item.key == jurisdiction.key ? { ...item, department: ele } : item)));
          // setDesignationValue(filteredItems[0]);
          // setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: filteredItems[0] } : item)));
        }
      });
    }
  },);

  useEffect(() => {
    if (responseData != null) {
      getdesignationdata?.forEach((ele) => {
        if (ele.code === responseData?.Employees[0]?.assignments[0]?.designation) {
          setDesignationValue(ele);
          setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: ele } : item)));
        }
      });
    }
  }, [depamentValue]);
  useEffect(() => {
    setDivision(
      divisions?.map((item) => {
        return { ...item, i18text: Digit.Utils.locale.convertToLocale(item.code, "EGOV_LOCATION_DIVISION") };
      })
    );
  }, [divisions]);

  const tenant = Digit.ULBService.getCurrentTenantId();

  useEffect(() => {
    if (Boundary?.length > 0) {
      selectedboundary(Boundary?.filter((ele) => ele.code == jurisdiction?.boundary?.code)[0]);
    }
  }, [Boundary]);

  const selectedboundary = (value) => {
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, boundary: value } : item)));
  };
  const selectDepartment = (value) => {
    setDesignationList([]);
    setjurisdictions((pre) => pre.map((item) => (item.key == jurisdiction.key ? { ...item, department: value } : item)));
    const filteredItems = getdesignationdata.filter(val => val.department.includes(value.code));
    setDesignationList(filteredItems);
    setDesignationValue(filteredItems[0]);
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: filteredItems[0] } : item)));
  };
  const selectDesignation = (value) => {
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: value } : item)));

  };

  return (
    <div key={jurisdiction?.keys} style={{ marginBottom: "16px" }}>
      {
        !STATE_ADMIN && (
          <div>
            <div style={{ marginTop: "10px" }}>
              <React.Fragment>
                <LabelFieldPair>
                  <CardLabel className="card-label-smaller">{`${t("HR_COMMON_DEPARTMENT")} * `}</CardLabel>
                  <Dropdown
                    className="form-field"
                    isMandatory={true}
                    selected={depamentValue}
                    option={getUserTypes}
                    select={selectDepartment}
                    optionKey="name"
                    t={t}
                  />
                </LabelFieldPair>
              </React.Fragment>
            </div>
            <div style={{ marginTop: "10px" }}>
              <React.Fragment>
                <LabelFieldPair>
                  <CardLabel className="card-label-smaller">{`${t("HR_COMMON_USER_DESIGNATION")} * `}</CardLabel>
                  <Dropdown
                    className="form-field"
                    isMandatory={true}
                    selected={designationValue}
                    option={designationList}
                    select={selectDesignation}
                    optionKey="name"
                    t={t}
                  />
                </LabelFieldPair>
              </React.Fragment>
            </div>
          </div>)
      }
    </div>
  );
}

export default SelectUserTypeAndDesignation;

