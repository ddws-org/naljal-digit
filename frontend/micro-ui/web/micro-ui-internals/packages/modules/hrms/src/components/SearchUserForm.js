import { Loader, Header, Dropdown, LabelFieldPair, CardLabel, LinkLabel, SubmitBar, Toast } from "@egovernments/digit-ui-react-components";
import React, { useState, useMemo, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { Controller, useForm, useWatch } from "react-hook-form";
import MultiSelectDropdown from "./MultiSelectDropdown";
function filterKeys(data, keys) {
  return data.map((item) => {
    const filteredItem = {};
    keys.forEach((key) => {
      if (item.hasOwnProperty(key)) {
        filteredItem[key] = item[key];
      }
    });
    return filteredItem;
  });
}

function getUniqueLeafCodes(tree) {
  const codes = new Set();

  function traverse(node) {
    if (!node || typeof node !== "object") return;

    const keys = Object.keys(node).filter((key) => key !== "options" && key !== "codes");

    // Check if it's a leaf node (all remaining keys' values are strings)
    const isLeafNode = keys.every((key) => typeof node[key] === "string");

    if (isLeafNode && node.code) {
      codes.add(node.code);
    } else {
      // Traverse every other key except options and codes
      keys.forEach((key) => {
        if (typeof node[key] === "object") {
          traverse(node[key]);
        }
      });
    }
  }

  traverse(tree);

  return Array.from(codes);
}

function buildTree(data, hierarchy) {
  const tree = { options: [] };

  data.forEach((item) => {
    // Ignore items without zoneCode
    if (!item.zoneCode) return;

    let currentLevel = tree;

    hierarchy.forEach(({ level }, index) => {
      const value = item[level];

      if (!currentLevel[value]) {
        // Clone the item and delete the options property from it
        const clonedItem = { ...item };
        delete clonedItem.options;

        // Initialize the current level with the cloned item
        currentLevel[value] = { ...clonedItem, options: [] };

        // Push the cloned item to the options array without the options property
        currentLevel.options.push({ ...clonedItem });
      }

      if (index === hierarchy.length - 1) {
        currentLevel[value].codes = currentLevel[value].codes || [];
        currentLevel[value].codes.push(item.code);
      }

      currentLevel = currentLevel[value];
    });
  });

  return tree;
}

const SearchUserForm = ({ uniqueTenants, setUniqueTenants, roles, setUniqueRoles }) => {
  const { t } = useTranslation();
  const [showToast, setShowToast] = useState(null);
  const [hierarchy, setHierarchy] = useState([
    { level: "zoneCode", value: 1, optionsKey: "zoneName", isMandatory: true },
    { level: "circleCode", value: 2, optionsKey: "circleName", isMandatory: true },
    { level: "divisionCode", value: 3, optionsKey: "divisionName", isMandatory: true },
    { level: "subDivisionCode", value: 4, optionsKey: "subDivisionName", isMandatory: false },
    { level: "sectionCode", value: 5, optionsKey: "sectionName", isMandatory: false },
    // { "level": "schemeCode", "value": 6,"optionsKey":"schemeName" },
    { level: "code", value: 7, optionsKey: "name", isMandatory: false },
  ]);
  const [tree, setTree] = useState(null);
  const [rolesOptions, setRolesOptions] = useState(null)
  // const [zones,setZones] = useState([])
  // const [circles,setCircles] = useState([])
  // const [divisions,setDivisions] = useState([])
  // const [subDivisions,setSubDivisions] = useState([])
  // const [sections,setSections] = useState([])
  // const [schemes,setSchemes] = useState([])
  // const [codes,setCodes] = useState([])

  const requestCriteria = {
    url: "/mdms-v2/v1/_search",
    params: { tenantId: Digit.ULBService.getStateId() },
    body: {
      MdmsCriteria: {
        tenantId: Digit.ULBService.getStateId(),
        moduleDetails: [
          {
            moduleName: "tenant",
            masterDetails: [
              {
                name: "tenants",
              },
            ],
          },
          {
            moduleName: "ws-services-masters",
            masterDetails: [
              {
                name: "WSServiceRoles",
              },
            ],
          }
        ],
      },
    },
    config: {
      cacheTime: Infinity,
      select: (data) => {
        const requiredKeys = [
          "code",
          "name",
          "zoneCode",
          "zoneName",
          "circleCode",
          "circleName",
          "divisionCode",
          "divisionName",
          "subDivisionCode",
          "subDivisionName",
          "sectionCode",
          "sectionName",
          "schemeCode",
          "schemeName",
        ];
        const result = data?.MdmsRes?.tenant?.tenants;
        const filteredResult = filterKeys(result, requiredKeys);
        const resultInTree = buildTree(filteredResult, hierarchy);
        const excludeCodes = ["HRMS_ADMIN", "LOC_ADMIN", "MDMS_ADMIN", "EMPLOYEE", "SYSTEM"];
        setRolesOptions(data?.MdmsRes?.["ws-services-masters"]?.["WSServiceRoles"]?.filter(row => !excludeCodes.includes(row?.code)
          &&
          (row?.name === "Secretary" || row?.name === "Sarpanch" || row?.name === "Revenue Collector" || row?.name === "DIVISION ADMIN")
        ))

        //updating to state roles as requested
        // setRolesOptions([
        //   // {
        //   //   code: "",
        //   //   name: "Select All",
        //   //   description: "",
        //   // },
        //   {
        //     code: "EMPLOYEE",
        //     name: "EMPLOYEE",
        //     labelKey: "ACCESSCONTROL_ROLES_ROLES_EMPLOYEE",
        //   },
        //   {
        //     code: "DIV_ADMIN",
        //     name: "DIVISION ADMIN",
        //     labelKey: "ACCESSCONTROL_ROLES_ROLES_DIV_ADMIN",
        //   },
        //   {
        //     code: "HRMS_ADMIN",
        //     name: "HRMS_ADMIN",
        //     labelKey: "ACCESSCONTROL_ROLES_ROLES_HRMS_ADMIN",
        //   },
        //   {
        //     code: "MDMS_ADMIN",
        //     name: "MDMS Admin",
        //     description: "Mdms admin",
        //   },

        // ])
        setTree(resultInTree);
        return result;
      },
    },
  };

  const { isLoading, data, revalidate, isFetching, error } = Digit.Hooks.useCustomAPIHook(requestCriteria);

  const {
    register,
    handleSubmit,
    setValue,
    getValues,
    reset,
    watch,
    trigger,
    control,
    formState,
    errors,
    setError,
    clearErrors,
    unregister,
  } = useForm({
    defaultValues: {
      "zoneCode": "",
      "circleCode": "",
      "divisionCode": "",
      "subDivisionCode": "",
      "sectionCode": "",
      "code": "",
      "roles": []
    },
  });

  const formData = watch();

  const clearSearch = () => {
    reset({
      "zoneCode": "",
      "circleCode": "",
      "divisionCode": "",
      "subDivisionCode": "",
      "sectionCode": "",
      "code": "",
      "roles": []
    });
    setUniqueRoles(null);
    setUniqueTenants(null);

    // dispatch({
    //   type: uiConfig?.type === "filter"?"clearFilterForm" :"clearSearchForm",
    //   state: { ...uiConfig?.defaultValues }
    //   //need to pass form with empty strings
    // })
    //here reset tableForm as well
    // dispatch({
    //   type: "tableForm",
    //   state: { limit:10,offset:0 }
    //   //need to pass form with empty strings
    // })
  };

  const onSubmit = (data) => {
    //assuming atleast one hierarchy is entered

    if (Object.keys(data).length === 0 || Object.values(data).every((value) => !value)) {
      //toast message
      setShowToast({ warning: true, label: t("ES_COMMON_MIN_SEARCH_CRITERIA_MSG") });
      setTimeout(closeToast, 5000);
      return;
    }
    //other validations if any
    //check mandatory fields
    let areMandatoryFieldsNotFilled = false;
    hierarchy.forEach(({ level, isMandatory }) => {
      if (isMandatory && (!data[level] || data[level]?.length === 0)) {
        areMandatoryFieldsNotFilled = true;
        return; // Exit the loop early
      }
    });

    if (areMandatoryFieldsNotFilled) {
      setShowToast({ warning: true, label: t("ES_COMMON_MIN_SEARCH_CRITERIA_MSG") });
      setTimeout(closeToast, 5000);
      return;
    }

    //checking roles
    if (data?.roles?.length === 0 || !data?.roles) {
      setShowToast({ warning: true, label: t("ES_COMMON_MIN_SEARCH_CRITERIA_MSG") });
      setTimeout(closeToast, 5000);
      return;
    }

    //here apply a logic to compute the subtree based on the hierarchy selected
    const levels = hierarchy.map(({ level }) => level);
    //compute current level
    let maxSelectedLevel = levels[0];
    levels.forEach((level) => {
      if (formData[level]) {
        maxSelectedLevel = level;
      } else {
        return;
      }
    });

    const levelIndex = levels.indexOf(maxSelectedLevel);

    let currentLevel = tree;
    for (let i = 0; i <= levelIndex; i++) {
      const code = data?.[levels[i]]?.[levels[i]];
      if (!code || !currentLevel[code]) return [];
      currentLevel = currentLevel[code];
    }

    //this is the list of tenants under the current subtree
    const listOfUniqueTenants = getUniqueLeafCodes(currentLevel);
    setUniqueTenants(() => listOfUniqueTenants);
    setUniqueRoles(() => data?.roles?.filter(row => row.code)?.map(role => role.code));
  };

  const optionsForHierarchy = (level, value) => {
    if (!tree) return [];

    const levels = hierarchy.map(({ level }) => level);
    const levelIndex = levels.indexOf(level);

    //zoneCode(1st level(highest parent))
    if (levelIndex === -1 || levelIndex === 0) return tree.options;

    let currentLevel = tree;
    for (let i = 0; i < levelIndex; i++) {
      const code = formData[levels[i]]?.[levels[i]];
      if (!code || !currentLevel[code]) return [];
      currentLevel = currentLevel[code];
    }
    return currentLevel.options || [];
  };

  const closeToast = () => {
    setShowToast(null);
  };

  const renderHierarchyFields = useMemo(() => {
    return hierarchy.map(({ level, optionsKey, isMandatory, ...rest }, idx) => (
      <LabelFieldPair>
        <CardLabel style={{ marginBottom: "0.4rem" }}>{`${t(Digit.Utils.locale.getTransformedLocale(`HR_SU_${level}`))} ${isMandatory ? "*" : ""
          }`}</CardLabel>
        <Controller
          render={(props) => (
            <Dropdown
              style={{ display: "flex", justifyContent: "space-between" }}
              option={optionsForHierarchy(level)}
              key={level}
              optionKey={optionsKey}
              value={props.value}
              select={(e) => {
                props.onChange(e);
                //clear all child levels
                const childLevels = hierarchy.slice(hierarchy.findIndex((h) => h.level === level) + 1);
                childLevels.forEach((child) => setValue(child.level, ""));
              }}
              selected={props.value}
              defaultValue={props.value}
              t={t}
              optionCardStyles={{
                top: "2.3rem",
                overflow: "auto",
                maxHeight: "200px",
              }}
            />
          )}
          rules={{}}
          defaultValue={""}
          name={level}
          control={control}
        />
      </LabelFieldPair>
    ));
  }, [formData]);

  if (isLoading || !setTree) {
    return <Loader />;
  }

  return (
    <div className={"search-wrapper"}>
      <form onSubmit={handleSubmit(onSubmit)}>
        <div>
          <p className="search-instruction-header">{t("HR_SU_HINT")}</p>
          <div className={`search-field-wrapper search `}>
            {renderHierarchyFields}
            <LabelFieldPair>
              <CardLabel style={{ marginBottom: "0.4rem" }}>{`${t(Digit.Utils.locale.getTransformedLocale(`HR_SU_ROLES`))} ${"*"}`}</CardLabel>
              <Controller
                render={(props) => {
                  return (
                    <div style={{ display: "grid", gridAutoFlow: "row" }}>
                      <MultiSelectDropdown
                        options={rolesOptions}
                        optionsKey={"name"}
                        props={props} //these are props from Controller
                        isPropsNeeded={true}
                        onSelect={(e) => {
                          props.onChange(
                            e
                              ?.map((row) => {
                                return row?.[1] ? row[1] : null;
                              })
                              .filter((e) => e)
                          )
                        }}
                        selected={props?.value || []}
                        defaultLabel={t("HR_SU_SELECT_ROLES")}
                        defaultUnit={t("COMMON_ROLES_SELECTED")}
                        showSelectAll={true}
                        t={t}
                      // config={config}
                      // disable={false}
                      // optionsDisable={config?.optionsDisable}
                      />
                    </div>
                  )
                }}
                rules={{}}
                defaultValue={[]}
                name={"roles"}
                control={control}
              />
            </LabelFieldPair>
            <div className={`search-button-wrapper search `} style={{}}>
              <LinkLabel
                style={{ marginBottom: 0, whiteSpace: "nowrap" }}
                onClick={() => {
                  clearSearch();
                }}
              >
                {t("HR_SU_CLEAR_SEARCH")}
              </LinkLabel>
              <SubmitBar label={t("HR_SU_SEARCH")} submit="submit" disabled={false} />
            </div>
          </div>
        </div>
      </form>
      {showToast && (
        <Toast
          warning={showToast?.warning}
          error={showToast?.error}
          label={showToast?.label}
          onClose={() => {
            closeToast();
          }}
          isDleteBtn={true}
        />
      )}
    </div>
  );
};

export default SearchUserForm;
