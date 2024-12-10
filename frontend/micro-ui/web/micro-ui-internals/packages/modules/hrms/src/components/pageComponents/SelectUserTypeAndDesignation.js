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
      blockBoundary: ele?.blockBoundary,
      block: ele?.block,
      designation: ele?.designation,
      roles: ele?.roles,
      department: ele?.department,
      designation: ele?.designation,
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
            block: {},
            blockBoundary: [],
            roles: [],
            department: {},
            designation: {},
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
            block: {},
            department: {},
            designation: {},
            blockBoundary: [],
            roles: [],
          },
        ]
  );
  const [jurisdictionsData, setJuristictionsData] = useState([]);
  let hierarchylist = [];
  // const hierarchyData = data?.MdmsRes?.["egov-location"]["TenantBoundary"].filter((ele) => ele?.hierarchyType?.code == "REVENUE")[0]?.hierarchyType;
  // hierarchylist.push(hierarchyData);

  // User Details
  const { isLoadingDesignation, isError, error, data: responseData, ...rest } = Digit.Hooks.hrms.useHRMSSearch(
    { codes: employeeId },
    tenantId,
    null,
    isupdate
  );

  let blocks = [];
  blocks = data?.MdmsRes?.["tenant"]["tenants"]
    ?.filter((items) => items?.blockcode)
    ?.map((item) => {
      return {
        code: item.blockcode,
        name: item.blockname,
        i18text: Digit.Utils.locale.getCityLocale(item.blockcode),
      };
    });
  const uniqueBlocks = blocks?.reduce((unique, obj) => {
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
        tenantId: STATE_ADMIN ? jurisdiction?.blockBoundary && jurisdiction?.blockBoundary[0]?.code : jurisdiction?.boundary?.code,
        auditDetails: jurisdiction?.auditDetails,
        block: jurisdiction?.block,
        department: jurisdiction?.department,
        designation: jurisdiction?.designation,
      };
      res = cleanup(res);
      if (jurisdiction?.roles) {
        res["roles"] = jurisdiction?.roles.map((ele) => {
          delete ele.description;
          return ele;
        });
      }
      if (jurisdiction?.blockBoundary) {
        res["blockBoundary"] = jurisdiction?.blockBoundary;
      }
      if (isEdit && STATE_ADMIN) {
        data?.MdmsRes?.["tenant"]["tenants"]?.map((items) => {
          if (items?.code === jurisdiction?.boundary?.code) {
            res["block"] = {
              code: items?.blockcode,
              i18text: Digit.Utils.locale.convertToLocale(items?.blockcode, "EGOV_LOCATION_DIVISION"),
            };
            res["blockBoundary"] = [
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
      let blockData = [];
      if (isEdit && jurisdictionData.length > 0) {
        jurisdictionData?.map((jurisdiction) => {
          if (jurisdiction?.blockBoundary && jurisdiction?.blockBoundary?.length > 0 && blockData.length === 0) {
            blockData.push(jurisdiction);
          } else if (blockData.length > 0) {
            if (blockData[blockData.length - 1]?.block?.code !== jurisdiction?.block?.code) {
              blockData.push(jurisdiction);
            }
          }
        });
      }

      let finalData = [];
      blockData &&
        blockData?.length > 0 &&
        blockData?.map((data, index) => {
          let blockBoundarydata = [];
          jurisdictionData?.map((jurisdiction) => {
            if (data?.block?.code === jurisdiction?.block?.code) {
              if (blockBoundarydata?.length === 0) {
                jurisdiction?.blockBoundary[0] !== undefined && blockBoundarydata.push(jurisdiction?.blockBoundary[0]);
              } else if (blockBoundarydata?.length > 0) {
                if (blockBoundarydata[blockBoundarydata?.length - 1]?.code !== jurisdiction?.blockBoundary[0]) {
                  jurisdiction?.blockBoundary[0] !== undefined && blockBoundarydata.push(jurisdiction?.blockBoundary[0]);
                }
              }
            }
          });
          let obj = {
            ...data,
            key: index,
            blockBoundary: blockBoundarydata,
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
    const blockBoundaryCodes = new Set(unit.blockBoundary.map((item) => item.code));
    return jurisdictions.filter((jurisdiction) => {
      return !blockBoundaryCodes.has(jurisdiction.boundary.code);
    });
  }
  const handleRemoveUnit = (unit) => {
    if (STATE_ADMIN) {
      if (!isEdit) {
        setjurisdictions(jurisdictions.filter((element) => element.key !== unit.key));
        setjurisdictions((prev) => prev.map((unit, index) => ({ ...unit, key: index })));
      } else {
        setJuristictionsData(jurisdictionsData.filter((element) => element.key !== unit.key));
        let filterJurisdictionsItems = filterJurisdictions(unit, jurisdictions);
        setjurisdictions(filterJurisdictionsItems);
        setjurisdictions((prev) => prev.map((unit, index) => ({ ...unit, key: index })));
      }
      if (FormData.errors?.Jurisdictions?.type == unit.key) {
        clearErrors("Jurisdictions");
      }
      reviseIndexKeys();
    } else {
      if (unit.id) {
        let res = {
          id: unit?.id,
          hierarchy: unit?.hierarchy?.code,
          boundaryType: unit?.boundaryType?.label,
          boundary: unit?.boundary?.code,
          block: unit?.block?.code,
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
        blocks={uniqueBlocks}
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
  blocks,
  getroledata,
  roleoption,
  index,
  Boundary,
  getdesignationdata,
  getUserTypes,
  responseData,
}) {
  // console.log(responseData?.Employees[0]?.assignments[0]?.department, "responseData");
  // console.log(responseData?.Employees[0]?.assignments[0]?.designation, "responseData");

  const [BoundaryType, selectBoundaryType] = useState([]);
  const [blockBoundary, setBlockBoundary] = useState([]);
  const [designationList, setDesignationList] = useState([]);
  const [depamentValue, setDepamentValue] = useState("");
  const [designationValue, setDesignationValue] = useState("");

  const [Block, setBlock] = useState([]);
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
    });
    return defaultjurisdiction;
  };

  const DIV_ADMIN = Digit.UserService.hasAccess(["DIV_ADMIN"]);


  function filterDesignationList(designationList) {
    if (DIV_ADMIN) {
        return designationList.filter(item => item.code !== "DESIG_65");
    }
    return designationList;
}


  useEffect(() => {
    if (responseData != null && depamentValue == "" && isEdit) {
      getUserTypes?.forEach((ele) => {
        if (ele.code === responseData?.Employees[0]?.assignments[0]?.department) {
          setDepamentValue(ele);
          const filteredItems = getdesignationdata.filter((val) => val.department?.includes(ele.code));
          setDesignationList(filteredItems);
          setjurisdictions((pre) => pre.map((item) => (item.key == jurisdiction.key ? { ...item, department: ele } : item)));
          // setDesignationValue(filteredItems[0]);
          // setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: filteredItems[0] } : item)));
        }
      });
    }
  });

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
    setBlock(
      blocks?.map((item) => {
        return { ...item, i18text: Digit.Utils.locale.convertToLocale(item.code, "EGOV_LOCATION_DIVISION") };
      })
    );
  }, [blocks]);

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
    const filteredItems = getdesignationdata.filter((val) => val.department.includes(value.code));
    setDesignationList(filteredItems);
    setDesignationValue(filteredItems[0]);
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: filteredItems[0] } : item)));
  };
  const selectDesignation = (value) => {
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, designation: value } : item)));
  };

  return (
    <div key={jurisdiction?.keys} style={{ marginBottom: "16px" }}>
      {!STATE_ADMIN && (
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
                  option={filterDesignationList(designationList)}
                  select={selectDesignation}
                  optionKey="name"
                  t={t}
                />
              </LabelFieldPair>
            </React.Fragment>
          </div>
        </div>
      )}
    </div>
  );
}

export default SelectUserTypeAndDesignation;
