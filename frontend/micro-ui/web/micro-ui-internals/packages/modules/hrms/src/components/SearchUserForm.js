import { Loader, Header, Dropdown, LabelFieldPair, CardLabel, LinkLabel, SubmitBar, Toast } from "@egovernments/digit-ui-react-components";
import React, { useState, useMemo, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { Controller, useForm, useWatch } from "react-hook-form";
import MultiSelectDropdown from "../components/pageComponents/Multiselect";

const XLSX = require("xlsx");

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

    if (isLeafNode && node?.codes) {
      // codes.add(node.codes);
      node?.codes?.forEach((code) => codes.add(code));
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

function buildTree(data, hierarchyData) {
  const tree = { options: [] };

  data.forEach((item) => {
    // Ignore items without zoneCode
    if (!item.blockcode) return;

    let currentLevel = tree;

    hierarchyData.forEach(({ level }, index) => {
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

      if (index === hierarchyData.length - 1) {
        currentLevel[value].codes = currentLevel[value].codes || [];
        currentLevel[value].codes.push(item.code);
      }

      currentLevel = currentLevel[value];
    });
  });

  return tree;
}

const SearchUserForm = React.memo(({ uniqueTenants, setUniqueTenants, roles, setUniqueRoles, employeeData }) => {
  const { t } = useTranslation();
  const [showToast, setShowToast] = useState(null);

  // For District user
  const [hierarchy, setHierarchy] = useState([
    { level: "blockcode", value: 1, optionsKey: "blockname", isMandatory: true },
    { level: "panchayatcode", value: 2, optionsKey: "panchayatname", isMandatory: false },
    { level: "villageCode", value: 3, optionsKey: "villageName", isMandatory: false },
  ]);

  // For Block user
  const [blockHierarchy, setBlockHierarchy] = useState([
    // { level: "blockcode", value: 4, optionsKey: "blockname", isMandatory: true },
    { level: "panchayatcode", value: 2, optionsKey: "panchayatname", isMandatory: false },
    { level: "villageCode", value: 3, optionsKey: "villageName", isMandatory: false },
    // block default,   panchayath,village
  ]);
  const [tree, setTree] = useState(null);
  const [rolesOptions, setRolesOptions] = useState(null);
  const [isShowAllClicked, setIsShowAllClicked] = useState(false);
  const blockAdmin = Digit.UserService.hasAccess(["DIV_ADMIN"]);
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
      code: "",
      blockcode: "",
      panchayatcode: "",
      villageCode: "",
      roles: [],
    },
  });

  const formData = watch();

  const clearSearch = () => {
    reset({
      code: "",
      blockcode: "",
      panchayatcode: "",
      villageCode: "",
      roles: [],
    });
    setUniqueRoles(null);
    setUniqueTenants(null);
  };

  function mapTenantProperties(tenants) {
    return tenants.map((tenant) => {
      const cityProperties = {
        blockcode: tenant.city.blockcode,
        blockname: tenant.city.blockname,
        panchayatcode: tenant.city.panchayatcode,
        panchayatname: tenant.city.panchayatname,
        villageName: tenant.city.villageName,
        villageCode: tenant.city.villageCode,
      };

      // Destructure remaining tenant properties (excluding city)
      const { city, ...otherTenantProperties } = tenant;

      // Combine city properties and other tenant properties
      return {
        ...otherTenantProperties,
        // ...tenant,
        ...cityProperties,
      };
    });
  }

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
          },
        ],
      },
    },
    config: {
      cacheTime: Infinity,
      select: (data) => {
        const requiredKeys = ["code", "name", "blockcode", "blockname", "panchayatcode", "panchayatname", "villageCode", "villageName"];
        const result = data?.MdmsRes?.tenant?.tenants;
        const filteredResult = filterKeys(result, requiredKeys);
        const resultInTree = buildTree(filteredResult, hierarchy);
        const excludeCodes = ["HRMS_ADMIN", "LOC_ADMIN", "MDMS_ADMIN", "EMPLOYEE", "SYSTEM"];
        const roles = data?.MdmsRes?.["ws-services-masters"]?.["WSServiceRoles"]
          ?.filter(
            (row) =>
              !excludeCodes.includes(row?.code) &&
              (row?.name === "SECRETARY" || row?.name === "CHAIRMEN" || row?.name === "Revenue Collector" || row?.name === "DIVISION ADMIN")
          )
          ?.map((role) => ({
            ...role,
            i18text: "ACCESSCONTROL_ROLES_ROLES_" + role?.code,
          }));

        setRolesOptions(roles);
        setTree(resultInTree);
        return result;
      },
    },
  };

  const requestCriteria2 = {
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
                filter: `[?(@.code == '${Digit.ULBService.getCurrentTenantId()}')]`,
              },
            ],
          },
        ],
      },
    },
    changeQueryName: "userData",
    config: {
      cacheTime: Infinity,
      select: (data) => {
        const requiredKeys = ["code", "name", "blockcode", "blockname", "panchayatcode", "panchayatname", "villageCode", "villageName"];

        const result = data?.MdmsRes?.tenant?.tenants;

        formData.villageCode = result[0];
        formData.panchayatcode = result[0];
        formData.blockcode = result[0];

        const filteredResult = filterKeys(result, requiredKeys);
        return result;
      },
    },
  };

  const { isLoading, data, revalidate, isFetching, error } = Digit.Hooks.useCustomAPIHook(requestCriteria);
  const { data: userData } = Digit.Hooks.useCustomAPIHook(requestCriteria2);

  useEffect(() => {
    if (isShowAllClicked && employeeData) {
      jsonToExcel(employeeData, "employees.xlsx");
      setIsShowAllClicked(false);
    }
  }, [employeeData, uniqueTenants]);

  function jsonToExcel(employeeData, fileName) {
    const employees = employeeData.map((employee) => ({
      "User Id": employee.code,
      Name: employee.user.name,
      "Type of User": employee?.assignments[0]?.department,
      Designation: t(employee?.assignments[0]?.designation),
      Username: employee?.user?.mobileNumber,
      Status: employee?.isActive ? "Active" : "Inactive",
      Tenant: t(employee?.tenantId),
    }));

    try {
      const wb = XLSX.utils.book_new();
      const ws = XLSX.utils.json_to_sheet(employees);

      XLSX.utils.book_append_sheet(wb, ws, "Employees");

      XLSX.writeFile(wb, fileName);
    } catch (error) {
      console.log("Error occurred", error);
    }
  }

  const showAllData = () => {
    // clearSearch();
    if (blockAdmin) setRequiredOptions(formData);
    setIsShowAllClicked(true);
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
      const code = formData?.[levels[i]]?.[levels[i]];
      if (!code || !currentLevel[code]) break;
      currentLevel = currentLevel[code];
    }

    //this is the list of tenants under the current subtree
    const listOfUniqueTenants = getUniqueLeafCodes(currentLevel);
    setUniqueTenants(() => listOfUniqueTenants);
    setUniqueRoles(() => rolesOptions?.filter((row) => row.code)?.map((role) => role.code));
  };

  const onSubmit = (data) => {
    //assuming atleast one hierarchy is entered
    if (blockAdmin) setRequiredOptions(data);
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

    // debugger;

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
    setUniqueRoles(() => data?.roles?.filter((row) => row.code)?.map((role) => role.code));
  };
  const [blockTree, setBlockTree] = useState(null);

  useEffect(() => {
    if (userData) {
      const blockC = userData[0].blockcode;

      if (tree && tree[blockC]) {
        setBlockTree(tree[blockC]);
      }
    }
  }, [userData, tree]);

  const setRequiredOptions = (formData) => {
    // formData.villageCode = userData[0];
    // formData.panchayatcode = userData[0];
    formData.blockcode = userData[0];
  };

  const optionsForHierarchy = (level, value) => {
    if (!tree) return [];

    if (blockAdmin && !blockTree) return [];

    const levels = blockAdmin ? blockHierarchy.map(({ level }) => level) : hierarchy.map(({ level }) => level);

    const levelIndex = levels.indexOf(level);

    if (levelIndex === -1 || levelIndex === 0) return blockAdmin ? blockTree.options : tree.options;

    let currentLevel = blockAdmin ? blockTree : tree;

    for (let i = 0; i < levelIndex; i++) {
      const code = formData[levels[i]]?.[levels[i]];
      if (!code || !currentLevel[code]) return [];
      currentLevel = currentLevel[code];
    }

    if (blockAdmin) setRequiredOptions(formData);
    return currentLevel?.options || [];
  };

  const closeToast = () => {
    setShowToast(null);
  };

  const renderHierarchyFields = useMemo(() => {
    return (blockAdmin ? blockHierarchy : hierarchy).map(({ level, optionsKey, isMandatory, ...rest }, idx) => (
      <LabelFieldPair>
        <CardLabel style={{ marginBottom: "0.4rem" }}>{`${t(Digit.Utils.locale.getTransformedLocale(`HR_SU_${level}`))} ${
          isMandatory ? "*" : ""
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
                // const childLevels = hierarchy.slice(hierarchy.findIndex((h) => h.level === level) + 1);
                // childLevels.forEach((child) => setValue(child.level, ""));
                const childLevels = (blockAdmin ? blockHierarchy : hierarchy).slice(
                  (blockAdmin ? blockHierarchy : hierarchy).findIndex((h) => h.level === level) + 1
                );
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
                        optionsKey={"i18text"}
                        props={props} //these are props from Controller
                        isPropsNeeded={true}
                        onSelect={(e) => {
                          props.onChange(
                            e
                              ?.map((row) => {
                                return row?.[1] ? row[1] : null;
                              })
                              .filter((e) => e)
                          );
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
                  );
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
              <LinkLabel
                style={{ marginBottom: 0, whiteSpace: "nowrap" }}
                onClick={() => {
                  showAllData();
                }}
              >
                {t("HR_SHOW_ALL_DATA")}
              </LinkLabel>
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
});

export default SearchUserForm;
