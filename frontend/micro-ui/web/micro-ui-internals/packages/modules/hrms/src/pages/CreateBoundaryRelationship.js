import React, { useState, useRef, useEffect, useCallback } from "react";
import { Card, CardLabel, LabelFieldPair, Header, Dropdown, Toast } from "@egovernments/digit-ui-react-components";

import { PopUp, Button, TextInput, FieldV1 } from "@egovernments/digit-ui-components";

import { useTranslation } from "react-i18next";
import { useHistory } from "react-router-dom/cjs/react-router-dom.min";
import ApplicationTable from "../components/inbox/ApplicationTable";

const CreateBoundaryRelationship = () => {
  const { t } = useTranslation();
  const [showToast, setShowToast] = useState(null);
  const [hierarchyType, setHierarchyType] = useState(null);
  const [level, setLevel] = useState(null);
  const [parent, setParent] = useState(null);
  const [boundaryEntry, setBoundaryEntry] = useState("");
  const stateId = Digit.ULBService.getStateId();
  const [showPopUp, setShowPopUp] = useState(false);
  const [refetchTrigger, setRefetchTrigger] = useState(0);
  const [paginatedData, setPaginatedData] = useState([]);

  const closePopup = () => {
    setShowPopUp(false);
    setBoundaryEntry("");
  };

  const GetCell = (value) => <span className="cell-text">{t(value)}</span>;

  const [searchParams, setSearchParams] = useState({
    offset: 0,
    limit: 10,
  });
  const handleFilterChange = (data) => {
    setSearchParams((prevSearchParams) => ({ ...prevSearchParams, ...data }));
  };
  const fetchNextPage = useCallback(() => {
    setSearchParams((prevSearchParams) => ({ ...prevSearchParams, offset: parseInt(prevSearchParams?.offset) + parseInt(prevSearchParams?.limit) }));
  }, []);

  const fetchPrevPage = () => {
    setSearchParams((prevSearchParams) => ({ ...prevSearchParams, offset: parseInt(prevSearchParams?.offset) - parseInt(prevSearchParams?.limit) }));
  };

  const handlePageSizeChange = (e) => {
    setSearchParams((prevSearchParams) => ({ ...prevSearchParams, limit: e.target.value }));
  };

  const [formData, setFormData] = useState(new Map());
  const formDataRef = useRef(formData);

  const reqCriteriaBoundaryHierarchySearch = {
    url: "/boundary-service/boundary-hierarchy-definition/_search",
    params: {},
    body: {
      BoundaryTypeHierarchySearchCriteria: {
        tenantId: stateId,
      },
      changeQueryName: "hierarchyData",
    },
    config: {
      select: (data) => {
        const result = data?.BoundaryHierarchy;
        return result;
      },
    },
  };


  const reqCriteriaBoundaryRelationshipCreate = {
    url: `/${Digit.InitEnvironment.getStatePath}/boundary-service/boundary-relationships/_create`,
    params: {},
    body: {},
    config: {
      enabled: true,
    },
  };

  const reqCriteriaBoundaryEntityCreate = {
    url: `/${Digit.InitEnvironment.getStatePath}/boundary-service/boundary/_create`,
    params: {},
    body: {},
    config: {
      enabled: true,
    },
  };

  const [reqCriteriaBoundaryRelationshipSearch, setReqCriteriaBoundaryRelationshipSearch] = useState({
    url: "/boundary-service/boundary-relationships/_search",
    params: { tenantId: stateId, hierarchyType: null, includeChildren: true },
    body: {},
    config: {
      select: (data) => {
        const result = data?.TenantBoundary;
        return result?.[0]?.boundary;
      },
    },
    changeQueryName: "relationshipData",
  });

  useEffect(() => {
    if (hierarchyType && hierarchyType?.hierarchyType) {
      setReqCriteriaBoundaryRelationshipSearch((prevState) => ({
        ...prevState,
        params: {
          ...prevState.params,
          hierarchyType: hierarchyType.hierarchyType,
        },
        changeQueryName: prevState.changeQueryName + "a",
      }));
    }
  }, [hierarchyType, refetchTrigger]);

  useEffect(() => {
    if (level && hierarchyType && hierarchyType.boundaryHierarchy) {
      const newFormData = new Map();

      for (let i = 0; i < hierarchyType.boundaryHierarchy.length; i++) {
        const currentType = hierarchyType.boundaryHierarchy[i].boundaryType;
        if (currentType === level.boundaryType) {
          break;
        }
        newFormData.set(currentType, "");
      }
      setFormData(newFormData);
      formDataRef.current = newFormData;
    }
  }, [hierarchyType, level]);

  const { data: hierarchyTypeData } = Digit.Hooks.useCustomAPIHook(reqCriteriaBoundaryHierarchySearch);
  const relation_mutation = Digit.Hooks.useCustomAPIMutationHook(reqCriteriaBoundaryRelationshipCreate);
  const entity_mutation = Digit.Hooks.useCustomAPIMutationHook(reqCriteriaBoundaryEntityCreate);
  const { data: relationshipData, error, isLoading } = Digit.Hooks.useCustomAPIHook(reqCriteriaBoundaryRelationshipSearch);

  const handleHierarchyTypeChange = (selectedValue) => {
    setHierarchyType(selectedValue);
    setLevel(null);
    setParent(null);
    setFormData(new Map());
    formDataRef.current = new Map();
  };

  const handleLevelChange = (selectedValue) => {
    setLevel(selectedValue);

    const newFormData = new Map();
    for (let i = 0; i < hierarchyType?.boundaryHierarchy?.length; i++) {
      const currentType = hierarchyType?.boundaryHierarchy[i]?.boundaryType;
      if (currentType === selectedValue.boundaryType) {
        break;
      }
      newFormData.set(currentType, formData.get(currentType) || "");
    }
    setFormData(newFormData);
    formDataRef.current = newFormData;
  };

  const createRelationship = async () => {
    try {
      await relation_mutation.mutate(
        {
          params: {},
          body: {
            BoundaryRelationship: {
              tenantId: stateId,
              code: boundaryEntry,
              hierarchyType: hierarchyType?.hierarchyType,
              boundaryType: level?.boundaryType,
              parent: parent,
            },
          },
        },
        {
          onError: (resp) => {
            let label = `${t("WBH_BOUNDARY_CREATION_FAIL")}: `;
            resp?.response?.data?.Errors?.map((err, idx) => {
              if (idx === resp?.response?.data?.Errors?.length - 1) {
                label = label + t(Digit.Utils.locale.getTransformedLocale(err?.code)) + ".";
              } else {
                label = label + t(Digit.Utils.locale.getTransformedLocale(err?.code)) + ", ";
              }
            });
            setShowToast({ label, isError: true });
            closeToast();
            closePopup();
            onFilterChange = { handleFilterChange };
          },
          onSuccess: () => {
            setShowToast({ label: `${t("WBH_BOUNDARY_UPSERT_SUCCESS")}` });
            closeToast();
            closePopup();
            setRefetchTrigger((prev) => prev + 1);
          },
        }
      );
    } catch {}
  };

  const submitBoundaryEntry = async () => {
    try {
      if (!hierarchyType || !level || !boundaryEntry) {
        setShowToast({ label: `${t("NALJAL_FILLOUT_IS_MANDATORY")}`, isError: true });
        closeToast();
        return;
      }

      if (hierarchyType && level && hierarchyType?.boundaryHierarchy?.[0] !== level && !parent) {
        setShowToast({ label: `${t("NALJAL_FILLOUT_IS_MANDATORY")}`, isError: true });
        closeToast();
        return;
      }

      await entity_mutation.mutate(
        {
          params: {},
          body: {
            Boundary: [
              {
                tenantId: stateId,
                code: boundaryEntry,
                geometry: null,
              },
            ],
          },
        },
        {
          onError: (resp) => {
            let label = `${t("WBH_BOUNDARY_CREATION_FAIL")}: `;
            resp?.response?.data?.Errors?.map((err, idx) => {
              if (idx === resp?.response?.data?.Errors?.length - 1) {
                label = label + t(Digit.Utils.locale.getTransformedLocale(err?.code)) + ".";
              } else {
                label = label + t(Digit.Utils.locale.getTransformedLocale(err?.code)) + ", ";
              }
            });
            setShowToast({ label, isError: true });
            closeToast();
            closePopup();
          },
          onSuccess: () => {
            createRelationship();
          },
        }
      );
    } catch {}
  };

  const handleSelect = (boundaryType, selectedValue) => {
    setFormData((prevFormData) => {
      const updatedFormData = new Map(prevFormData);
      updatedFormData.set(boundaryType, selectedValue);
      formDataRef.current = updatedFormData;
      return updatedFormData;
    });

    const hierarchyLevels = hierarchyType.boundaryHierarchy.map(({ boundaryType }) => boundaryType);
    const boundaryIndex = hierarchyLevels.indexOf(boundaryType);
    const levelIndex = hierarchyType.boundaryHierarchy.indexOf(level);

    if (boundaryIndex === levelIndex - 1) {
      const lastEntry = Array.from(formDataRef.current).pop();
      if (lastEntry) {
        const [lastKey, lastValue] = lastEntry;
        setParent(lastValue.code);
      }
    }
    const currentBoundaryTypeIndex = hierarchyType.boundaryHierarchy.findIndex((h) => h.boundaryType === boundaryType);

    const childBoundaryTypes = hierarchyType.boundaryHierarchy.slice(currentBoundaryTypeIndex + 1, levelIndex);

    setFormData((prevFormData) => {
      const updatedFormData = new Map(prevFormData);
      childBoundaryTypes.forEach((childBoundary) => {
        updatedFormData.set(childBoundary.boundaryType, "");
      });

      formDataRef.current = updatedFormData;

      return updatedFormData;
    });
  };

  const optionsForHierarchy = (boundaryType) => {
    if (!relationshipData || !hierarchyType || !formData) return [];
    const hierarchyLevels = hierarchyType.boundaryHierarchy.map(({ boundaryType }) => boundaryType);
    const boundaryIndex = hierarchyLevels.indexOf(boundaryType);

    if (boundaryIndex === -1) return [];
    let currentOptions = relationshipData;

    for (let i = 0; i < boundaryIndex; i++) {
      const selectedCode = formData?.get(hierarchyLevels[i])?.code;
      if (!selectedCode) return [];
      const foundOption = currentOptions.find((option) => option?.code === selectedCode);
      if (!foundOption) return [];
      currentOptions = foundOption?.children || [];
    }
    return currentOptions;
  };
  const closeToast = () => {
    setTimeout(() => {
      setShowToast(null);
    }, 5000);
  };

  const isTablePopulated = (formData) => {
    const formArray = Array.from(formDataRef.current);

    if (level) {
      const levelIndex = hierarchyType?.boundaryHierarchy?.indexOf(level);
      if (formArray.length === 0 && levelIndex == 0) return true;
    }

    if (formArray.length === 0) return false;

    for (const [key, value] of formArray) {
      if (!value) {
        return false;
      }
    }
    return true;
  };

  const getLevelArray = () => {
    if (!relationshipData || !hierarchyType || !isTablePopulated()) return [];
    const hierarchyLevels = hierarchyType.boundaryHierarchy.map(({ boundaryType }) => boundaryType);
    const levelIndex = hierarchyLevels.indexOf(level?.boundaryType);

    if (levelIndex === -1) return [];
    let currentOptions = relationshipData;

    for (let i = 0; i < levelIndex; i++) {
      const selectedCode = formData?.get(hierarchyLevels[i])?.code;
      if (!selectedCode) return [];
      const foundOption = currentOptions.find((option) => option?.code === selectedCode);
      if (!foundOption) return [];
      currentOptions = foundOption?.children || [];
    }
    let reversedArray = [...currentOptions].reverse();
    return currentOptions;
  };

  const displayPopUp = () => {
    setShowPopUp(true);
  };

  useEffect(() => {
    const allData = getLevelArray();
    const startIndex = searchParams.offset;
    const endIndex = startIndex + parseInt(searchParams.limit);
    setPaginatedData(allData.slice(Math.max(0, startIndex), endIndex).reverse());
  }, [relationshipData, level, formData, searchParams.offset, searchParams.limit]);

  const columns = () => {
    const formDataArray = Array.from(formDataRef.current);
    if (formDataArray.length === 0 && (!level || level.boundaryType !== hierarchyType?.boundaryHierarchy?.[0]?.boundaryType)) return [];

    const columnArray = Array.from(formDataRef?.current?.keys()).map((key) => {
      return {
        Header: key,
        accessor: key,
        Cell: ({ row }) => {
          return GetCell(formDataRef?.current?.get(key)?.code || "");
        },
      };
    });

    if (level) {
      columnArray.push({
        Header: level.boundaryType,
        accessor: level.boundaryType,
        Cell: ({ row }) => {
          return GetCell(row?.original?.code || "");
        },
      });
    }

    return columnArray;
  };

  console.log(searchParams, "serachParams");
  console.log("showpopup", showPopUp);

  let result;
  if (getLevelArray()?.length === 0) {
    result = (
      <div style={{ marginTop: 20 }}>
        {t("COMMON_TABLE_NO_RECORD_FOUND")
          .split("\\n")
          .map((text, index) => (
            <p key={index} style={{ textAlign: "center" }}>
              {text}
            </p>
          ))}
      </div>
    );
  } else {
    let array = [];
    if (isTablePopulated) array = getLevelArray();
    result = (
      <ApplicationTable
        t={t}
        data={paginatedData}
        columns={columns()}
        getCellProps={(cellInfo) => {
          return {
            style: {
              padding: "20px 18px",
              fontSize: "16px",
              minWidth: "150px",
            },
          };
        }}
        onFilterChange={handleFilterChange}
        isPaginationRequired={array?.length > 10 ? true : false}
        onPageSizeChange={handlePageSizeChange}
        currentPage={parseInt(searchParams.offset / searchParams.limit)}
        onNextPage={fetchNextPage}
        onPrevPage={fetchPrevPage}
        pageSizeLimit={searchParams?.limit}
        totalRecords={array.length}
      />
    );
  }

  return (
    <React.Fragment>
      <Header className="works-header-search">{t("NALJAL_UPLOAD_BOUNDARY")}</Header>
      <Card className="workbench-create-form">
        <LabelFieldPair style={{ alignItems: "flex-start", paddingLeft: "1rem", marginBottom: "1.5rem" }}>
          <CardLabel style={{ marginBottom: "0.4rem", fontWeight: "700" }}>{t("NALJAL_HIERARCHY_TYPE")} *</CardLabel>
          <Dropdown className="form-field" option={hierarchyTypeData} select={handleHierarchyTypeChange} optionKey={"hierarchyType"} />
        </LabelFieldPair>
        <LabelFieldPair style={{ alignItems: "flex-start", paddingLeft: "1rem", marginBottom: "1.5rem" }}>
          <CardLabel style={{ marginBottom: "0.4rem", fontWeight: "700" }}>{t("NALJAL_HIERARCHY_LEVEL")} *</CardLabel>
          <Dropdown
            className="form-field"
            option={hierarchyType?.boundaryHierarchy || []}
            select={handleLevelChange}
            selected={level}
            optionKey={"boundaryType"}
          />
        </LabelFieldPair>
      </Card>

      {Array.from(formData).length > 0 && (
        <Card className="workbench-create-form">
          {Array.from(formData).map(([boundaryType, value], index) => (
            <LabelFieldPair key={index} style={{ alignItems: "flex-start", paddingLeft: "1rem", marginBottom: "1.5rem" }}>
              <CardLabel style={{ marginBottom: "0.4rem", fontWeight: "700" }}>{t(`NALJAL_HIERARCHY_${boundaryType?.toUpperCase()}`)} *</CardLabel>
              <Dropdown
                className="form-field"
                option={optionsForHierarchy(boundaryType)}
                select={(e) => {
                  handleSelect(boundaryType, e);
                }}
                selected={formData?.get(boundaryType)}
                optionKey={"code"}
              />
            </LabelFieldPair>
          ))}
        </Card>
      )}

      {level && isTablePopulated() && (
        <Card className="workbench-create-form">
          <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: "2em" }}>
            <Button
              variation="secondary"
              label={t("ADD_NEW_BOUNDARY")}
              textStyles={{ color: "#c84c0e", width: "unset" }}
              className={"hover"}
              onClick={displayPopUp}
            />
          </div>

          <LabelFieldPair style={{ alignItems: "flex-start", paddingLeft: "1rem" }}>
            {showPopUp && (
              <PopUp
                className={"boundaries-pop-module"}
                type={"default"}
                subheading={t(`NALJAL_HIERARCHY_${level?.boundaryType?.toUpperCase()}`)}
                onClose={closePopup}
                footerChildren={[
                  <Button
                    type={"button"}
                    size={"large"}
                    variation={"secondary"}
                    label={t("CLOSE")}
                    textStyles={{ color: "#c84c0e", width: "unset" }}
                    onClick={closePopup}
                  />,
                  <Button
                    type={"button"}
                    size={"large"}
                    variation={"primary"}
                    label={t("CREATE_BOUNDARY")}
                    textStyles={{ width: "unset" }}
                    onClick={() => {
                      submitBoundaryEntry();
                    }}
                  />,
                ]}
                sortFooterChildren={true}
              >
                <div style={{ display: "flex", justifyContent: "space-between" }}>
                  <TextInput
                    maxlength="64"
                    onChange={(e) => {
                      setBoundaryEntry(e.target.value);
                    }}
                    value={boundaryEntry}
                  />
                </div>
              </PopUp>
            )}
          </LabelFieldPair>

          {isTablePopulated() && (
            <div className="result" style={{ marginLeft: "24px", flex: 1 }}>
              {result}
            </div>
          )}
        </Card>
      )}
      {showToast && (
        <Toast error={showToast.isError} label={showToast.label} isDleteBtn={"true"} onClose={() => setShowToast(false)} style={{ bottom: "8%" }} />
      )}
    </React.Fragment>
  );
};

export default CreateBoundaryRelationship;
