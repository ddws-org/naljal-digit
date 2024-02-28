import { CardLabel, Dropdown, LabelFieldPair, Loader, RemoveableTag } from "@egovernments/digit-ui-react-components";
import React, { useEffect, useState } from "react";
import cleanup from "../Utils/cleanup";
import MultiSelectDropdown from "./Multiselect";

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
      roles: ele?.roles,
    };
  });
};

const Jurisdictions = ({ t, config, onSelect, userType, formData }) => {
  const tenantId = Digit.ULBService.getCurrentTenantId();
  const [inactiveJurisdictions, setInactiveJurisdictions] = useState([]);
  const { data: data = {}, isLoading } = Digit.Hooks.hrms.useHrmsMDMS(tenantId, "egov-hrms", "HRMSRolesandDesignation") || {};
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
          },
        ]
  );
  const [jurisdictionsData, setJuristictionsData] = useState([]);
  let hierarchylist = [];
  // const hierarchyData = data?.MdmsRes?.["egov-location"]["TenantBoundary"].filter((ele) => ele?.hierarchyType?.code == "REVENUE")[0]?.hierarchyType;
  // hierarchylist.push(hierarchyData);

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
  // useEffect(() => {
  //   setJuristictionsData(formData?.Jurisdictions);
  // }, [formData?.Jurisdictions, jurisdictions]);

  const reviseIndexKeys = () => {
    setjurisdictions((prev) => prev.map((unit, index) => ({ ...unit, key: index })));
  };

  const handleAddUnit = () => {
    setjurisdictions((prev) => [
      ...prev,
      {
        key: prev.length + 1,
        hierarchy: null,
        boundaryType: null,
        boundary: null,
        division: null,
        divisionBoundary: [],
        roles: [],
      },
    ]);
  };
  const handleRemoveUnit = (unit) => {
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
          return { code: role.code, name: role?.name ? role?.name : " ", labelKey: "ACCESSCONTROL_ROLES_ROLES_" + role.code };
        });
    } else {
      // Specify the role codes you want to filter
      const roleCodesToFilter = ["HRMS_ADMIN", "DIV_ADMIN", "MDMS_ADMIN", "LOC_ADMIN", "SYSTEM"];
      // Use the filter method to extract roles with the specified codes
      return data?.MdmsRes?.["ws-services-masters"].WSServiceRoles?.filter((role) => {
        return !roleCodesToFilter.includes(role.code);
      })?.map((role) => {
        return { code: role.code, name: role?.name ? role?.name : " ", labelKey: "ACCESSCONTROL_ROLES_ROLES_" + role.code };
      });
    }
  }
  if (isLoading && isUserDataLoading) {
    return <Loader />;
  }
  return (
    <div>
      {isEdit && STATE_ADMIN ? (
        <React.Fragment>
          {jurisdictionsData?.map((jurisdiction, index) => (
            <Jurisdiction
              t={t}
              formData={formData}
              jurisdictions={jurisdictions}
              key={index}
              keys={jurisdiction.key}
              data={data}
              userDetails={userData?.user[0]}
              jurisdiction={jurisdiction}
              setjurisdictions={setjurisdictions}
              setJuristictionsData={setJuristictionsData}
              jurisdictionsData={jurisdictionsData}
              onSelect={onSelect}
              config={config}
              index={index}
              focusIndex={focusIndex}
              setFocusIndex={setFocusIndex}
              hierarchylist={hierarchylist}
              divisions={uniqueDivisions}
              boundaryTypeoption={boundaryTypeoption}
              getroledata={getroledata}
              handleRemoveUnit={handleRemoveUnit}
              Boundary={Boundary}
            />
          ))}
        </React.Fragment>
      ) : (
        jurisdictions?.map((jurisdiction, index) => (
          <Jurisdiction
            t={t}
            formData={formData}
            jurisdictions={jurisdictions}
            key={index}
            keys={jurisdiction.key}
            data={data}
            userDetails={userData?.user[0]}
            jurisdiction={jurisdiction}
            setjurisdictions={setjurisdictions}
            index={index}
            focusIndex={focusIndex}
            setFocusIndex={setFocusIndex}
            hierarchylist={hierarchylist}
            divisions={uniqueDivisions}
            boundaryTypeoption={boundaryTypeoption}
            getroledata={getroledata}
            handleRemoveUnit={handleRemoveUnit}
            Boundary={Boundary}
          />
        ))
      )}
      <label onClick={handleAddUnit} className="link-label" style={{ width: "12rem" }}>
        {t("HR_ADD_JURISDICTION")}
      </label>
    </div>
  );
};
// -------------------------------------------------------------------------------------
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
}) {
  const [BoundaryType, selectBoundaryType] = useState([]);
  // const [Boundary, selectboundary] = useState([]);
  const [divisionBoundary, setDivisionBoundary] = useState([]);
  const [Division, setDivision] = useState([]);
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  let isMobile = window.Digit.Utils.browser.isMobile();
  const isEdit = window.location.href?.includes("hrms/edit");

  // useEffect(() => {
  //   selectBoundaryType(
  //     data?.MdmsRes?.["egov-location"]["TenantBoundary"]
  //       .filter((ele) => {
  //         return ele?.hierarchyType?.code == hierarchylist[0]?.code;
  //       })
  //       .map((item) => {
  //         return { ...item.boundary, i18text: Digit.Utils.locale.convertToLocale(item.boundary.label, "EGOV_LOCATION_BOUNDARYTYPE") };
  //       })
  //   );
  // }, [jurisdiction?.hierarchy, data?.MdmsRes]);

  useEffect(() => {
    setDivision(
      divisions?.map((item) => {
        return { ...item, i18text: Digit.Utils.locale.convertToLocale(item.code, "EGOV_LOCATION_DIVISION") };
      })
    );
  }, [divisions]);

  const tenant = Digit.ULBService.getCurrentTenantId();
  // useEffect(() => {
  //   console.log("ssss")
  //   let cities = userDetails?.roles.map((role) => role.tenantId)?.filter((value, index, array) => array.indexOf(value) === index);
  //   selectboundary(
  //     data?.MdmsRes?.tenant?.tenants
  //       ?.filter((city) => city.code != Digit.ULBService.getStateId() && cities?.includes(city.code))
  //       ?.map((city) => {
  //         return { ...city, i18text: Digit.Utils.locale.getCityLocale(city.code) };
  //       })
  //   );
  // }, [data]);

  useEffect(() => {
    if (Boundary?.length > 0) {
      selectedboundary(Boundary?.filter((ele) => ele.code == jurisdiction?.boundary?.code)[0]);
    }
  }, [Boundary]);
  const selectHierarchy = (value) => {
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, hierarchy: value } : item)));
  };

  const selectboundaryType = (value) => {
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, boundaryType: value } : item)));
  };

  const selectedboundary = (value) => {
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, boundary: value } : item)));
  };

  const selectDivision = (value) => {
    // Extract projects using array methods
    const project = data?.MdmsRes?.["tenant"]["tenants"].filter((obj) => obj.divisionCode === value.code);
    const finalProjects = project?.map((project) => ({
      name: project.name,
      code: project.code,
      i18text: Digit.Utils.locale.getCityLocale(project.code),
    }));
    setDivisionBoundary(finalProjects);
    if (isEdit && STATE_ADMIN) {
      setJuristictionsData((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, division: value, divisionBoundary: [] } : item)));
      let data = jurisdictionsData?.map((items, index) => {
        let obj = {};
        if (index === jurisdiction?.key) {
          obj = {
            ...items,
            division: value,
            divisionBoundary: [],
          };
        } else {
          obj = { ...items };
        }
        return obj;
      });
      onSelect(
        config.key,
        [...data].filter((value) => Object.keys(value).length !== 0)
      );
    } else {
      setjurisdictions((pre) => pre.map((item) => (item.key == jurisdiction.key ? { ...item, division: value, divisionBoundary: [] } : item)));
    }
  };

  const getboundarydata = (value) => {
    // Extract projects using array methods
    const project = data?.MdmsRes?.["tenant"]["tenants"].filter((obj) => obj.divisionCode === value?.code);
    const finalProjects = project?.map((project) => ({
      name: project.name,
      code: project.code,
      i18text: Digit.Utils.locale.getCityLocale(project.code),
    }));
    return finalProjects;
  };
  const selectrole = (e) => {
    let res = [];
    e &&
      e?.map((ob) => {
        res.push(ob?.[1]);
      });

    res?.forEach((resData) => {
      resData.labelKey = "ACCESSCONTROL_ROLES_ROLES_" + resData.code;
    });

    if (isEdit && STATE_ADMIN) setJuristictionsData((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, roles: res } : item)));
    let data = jurisdictionsData?.map((items, index) => {
      let obj = {};
      if (index === jurisdiction?.key) {
        obj = {
          ...items,
          roles: res,
        };
      } else {
        obj = { ...items };
      }
      return obj;
    });
    if (isEdit && STATE_ADMIN)
      onSelect(
        config?.key,
        [...data].filter((value) => Object.keys(value).length !== 0)
      );
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, roles: res } : item)));
  };

  const selectDivisionBoundary = (e) => {
    let res = [];
    e &&
      e?.map((ob) => {
        res.push(ob?.[1]);
      });
    if (isEdit && STATE_ADMIN) {
      setJuristictionsData((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, divisionBoundary: res } : item)));
      let data = jurisdictionsData?.map((items, index) => {
        let obj = {};
        if (index === jurisdiction?.key) {
          obj = {
            ...items,
            divisionBoundary: res,
          };
        } else {
          obj = { ...items };
        }
        return obj;
      });
      onSelect(
        config.key,
        [...data].filter((value) => Object.keys(value).length !== 0)
      );
    } else {
      setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, divisionBoundary: res } : item)));
    }
  };

  const onRemove = (index, key) => {
    let afterRemove = jurisdiction?.roles.filter((value, i) => {
      return i !== index;
    });
    setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, roles: afterRemove } : item)));
  };

  const onRemoveBoundary = (index) => {
    let afterRemove = jurisdiction?.divisionBoundary.filter((value, i) => {
      return i !== index;
    });
    if (isEdit && STATE_ADMIN) {
      setJuristictionsData((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, divisionBoundary: afterRemove } : item)));
      let data = jurisdictionsData?.map((items, index) => {
        let obj = {};
        if (index === jurisdiction?.key) {
          obj = {
            ...items,
            divisionBoundary: afterRemove,
          };
        } else {
          obj = { ...items };
        }
        return obj;
      });
      onSelect(
        config.key,
        [...data].filter((value) => Object.keys(value).length !== 0)
      );
    } else {
      setjurisdictions((pre) => pre.map((item) => (item.key === jurisdiction.key ? { ...item, divisionBoundary: afterRemove } : item)));
    }
  };
  return (
    <div key={jurisdiction?.keys} style={{ marginBottom: "16px" }}>
      <div style={{ border: "1px solid #E3E3E3", padding: "16px", marginTop: "8px" }}>
        <LabelFieldPair>
          <div className="label-field-pair" style={{ width: "100%" }}>
            <h2 className="card-label card-label-smaller" style={{ color: "#505A5F" }}>
              {t("HR_JURISDICTION")} {index + 1}
            </h2>
          </div>
          {jurisdictions.length > 1 ? (
            <div
              onClick={() => handleRemoveUnit(jurisdiction)}
              style={{ marginBottom: "16px", padding: "5px", cursor: "pointer", textAlign: "right" }}
            >
              X
            </div>
          ) : null}
        </LabelFieldPair>
        {STATE_ADMIN ? (
          <React.Fragment>
            <LabelFieldPair>
              <CardLabel className="card-label-smaller">{`${t("HR_DIVISIONS_LABEL")} * `}</CardLabel>
              <Dropdown
                className="form-field"
                isMandatory={true}
                selected={jurisdiction?.division}
                disable={Division?.length === 0}
                option={Division}
                select={selectDivision}
                optionKey="i18text"
                t={t}
              />
            </LabelFieldPair>
            <div style={{ display: !isMobile ? "flex" : "" }}>
              <CardLabel className="card-label-smaller">{`${t("HR_BOUNDARY_LABEL")} * `}</CardLabel>
              <div className="form-field">
                <MultiSelectDropdown
                  className="form-field"
                  isMandatory={true}
                  defaultUnit="Selected"
                  selected={jurisdiction?.divisionBoundary}
                  options={
                    isEdit && STATE_ADMIN ? (jurisdiction?.division == undefined ? [] : getboundarydata(jurisdiction?.division)) : divisionBoundary
                  }
                  onSelect={selectDivisionBoundary}
                  optionsKey="i18text"
                  showSelectAll={true}
                  t={t}
                />
                <div className="tag-container" style={{ height: jurisdiction?.divisionBoundary?.length > 0 && "50px", overflowY: "scroll" }}>
                  {jurisdiction?.divisionBoundary?.length > 0 &&
                    jurisdiction?.divisionBoundary[0] !== undefined &&
                    jurisdiction?.divisionBoundary?.map((value, index) => {
                      return (
                        <RemoveableTag key={index} text={`${t(value["i18text"]).slice(0, 22)} ...`} onClick={() => onRemoveBoundary(index, value)} />
                      );
                    })}
                </div>
              </div>
            </div>
          </React.Fragment>
        ) : (
          <React.Fragment>
            <LabelFieldPair>
              <CardLabel className="card-label-smaller">{`${t("HR_BOUNDARY_LABEL")} * `}</CardLabel>
              <Dropdown
                className="form-field"
                isMandatory={true}
                selected={jurisdiction?.boundary}
                option={Boundary}
                select={selectedboundary}
                optionKey="i18text"
                t={t}
              />
            </LabelFieldPair>
            <div style={{ display: !isMobile ? "flex" : "" }}>
              <CardLabel className="card-label-smaller">{t("HR_COMMON_TABLE_COL_ROLE")} *</CardLabel>
              <div className="form-field">
                <MultiSelectDropdown
                  className="form-field"
                  isMandatory={true}
                  defaultUnit="Selected"
                  selected={jurisdiction?.roles}
                  options={getroledata(roleoption)}
                  onSelect={selectrole}
                  optionsKey="labelKey"
                  t={t}
                />
                <div className="tag-container">
                  {jurisdiction?.roles.length > 0 &&
                    jurisdiction?.roles.map((value, index) => {
                      return <RemoveableTag key={index} text={`${t(value["labelKey"]).slice(0, 22)} ...`} onClick={() => onRemove(index, value)} />;
                    })}
                </div>
              </div>
            </div>
          </React.Fragment>
        )}
      </div>
    </div>
  );
}

export default Jurisdictions;
