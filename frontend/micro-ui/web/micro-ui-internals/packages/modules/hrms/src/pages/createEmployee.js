import { FormComposer, Toast, Loader, Header } from "@egovernments/digit-ui-react-components";
import React, { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { useHistory } from "react-router-dom";
import { newConfig } from "../components/config/config";
import _ from "lodash";

const CreateEmployee = () => {
  const tenantId = Digit.ULBService.getCurrentTenantId();
  const [canSubmit, setSubmitValve] = useState(false);
  const [mobileNumber, setMobileNumber] = useState(null);
  const [showToast, setShowToast] = useState(null);
  const [phonecheck, setPhonecheck] = useState(false);
  const [checkfield, setcheck] = useState(false);
  const { t } = useTranslation();
  const history = useHistory();
  const isMobile = window.Digit.Utils.browser.isMobile();
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);

  const { data: mdmsData, isLoading } = Digit.Hooks.useCommonMDMS(Digit.ULBService.getStateId(), "egov-hrms", ["CommonFieldsConfig"], {
    select: (data) => {
      return {
        config: data?.MdmsRes?.["egov-hrms"]?.CommonFieldsConfig,
      };
    },
    retry: false,
    enable: false,
  });
  const { data: hrmsData = {} } = Digit.Hooks.hrms.useHrmsMDMS(tenantId, "egov-hrms", "HRMSConfig") || {};
  const [mutationHappened, setMutationHappened, clear] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_MUTATION_HAPPENED", false);
  const [errorInfo, setErrorInfo, clearError] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_ERROR_DATA", false);
  const [successData, setsuccessData, clearSuccessData] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_MUTATION_SUCCESS_DATA", false);

  useEffect(() => {
    setMutationHappened(false);
    clearSuccessData();
    clearError();
  }, []);

  const checkMailNameNum = (formData) => {
    const email = formData?.SelectEmployeeEmailId?.emailId || "";
    const name = formData?.SelectEmployeeName?.employeeName || "";
    const validEmail = email.length == 0 ? true : email.match(Digit.Utils.getPattern("Email"));
    return validEmail && name.match(Digit.Utils.getPattern("Name"));
  };

  const closeToast = () => {
    setTimeout(() => {
      setShowToast(null);
    }, 5000);
  };
  useEffect(() => {
    if (mobileNumber && mobileNumber.length == 10 && mobileNumber.match(Digit.Utils.getPattern("MobileNo"))) {
      setShowToast(null);
      Digit.HRMSService.search(tenantId, null, { phone: mobileNumber }).then((result, err) => {
        if (result.Employees.length > 0) {
          setShowToast({ key: true, label: "ERR_HRMS_USER_EXIST_MOB" });
          closeToast();
          setPhonecheck(false);
        } else {
          setPhonecheck(true);
        }
      });
    } else {
      setPhonecheck(false);
    }
  }, [mobileNumber]);

  const defaultValues = {
    Jurisdictions: [
      {
        id: undefined,
        key: 1,
        hierarchy: null,
        boundaryType: null,
        boundary: {
          code: tenantId,
        },
        division: null,
        roles: [],
      },
    ],
  };

  const employeeCreateSession = Digit.Hooks.useSessionStorage("NEW_EMPLOYEE_CREATE", {});
  const [sessionFormData, setSessionFormData, clearSessionFormData] = employeeCreateSession;

  function hasUniqueTenantIds(items) {
    // Create a Set to efficiently store unique tenantIds
    const uniqueTenantIds = new Set();
    // Iterate through each item
    for (const item of items) {
      const tenantId = item.tenantId;
      // Check if tenantId already exists in the Set
      if (uniqueTenantIds.has(tenantId)) {
        // Duplicate found, return false
        return false;
      }
      // Add unique tenantId to the Set
      uniqueTenantIds.add(tenantId);
    }
    // No duplicates found, all tenantIds are unique
    return true;
  }

  function hasUniqueDivisions(items) {
    const uniqueDivisions = new Set();
    for (const item of items) {
      const divisionCode = item?.division?.code;
      if (divisionCode && uniqueDivisions.has(divisionCode)) {
        return false;
      }
      uniqueDivisions.add(divisionCode);
    }
    return true;
  }

  const onFormValueChange = (setValue = true, formData) => {
    let isValid = false;
    if (!_.isEqual(sessionFormData, formData)) {
      setSessionFormData({ ...sessionFormData, ...formData });
    }
    if (formData?.SelectEmployeePhoneNumber?.mobileNumber) {
      setMobileNumber(formData?.SelectEmployeePhoneNumber?.mobileNumber);
    } else {
      setMobileNumber(formData?.SelectEmployeePhoneNumber?.mobileNumber);
    }
    for (let i = 0; i < formData?.Jurisdictions?.length; i++) {
      let key = formData?.Jurisdictions[i];
      if (!((key?.boundary || key?.divisionBoundary) && (key?.boundaryType || key?.division) && key?.tenantId)) {
        setcheck(false);
        break;
      } else {
        if (!STATE_ADMIN) {
          if (
            formData?.SelectUserTypeAndDesignation[0] &&
            formData?.SelectUserTypeAndDesignation[0]?.department != undefined &&
            formData?.SelectUserTypeAndDesignation[0]?.designation != undefined
          ) {
            isValid = true;
          } else {
            isValid = false;
          }

          key?.roles?.length > 0 && setcheck(true);
        } else if (STATE_ADMIN) {
          setcheck(true);
          isValid = false;
        }
      }
    }
    // console.log(formData.
    //   SelectUserTypeAndDesignation[0].department != undefined
    //   , "formData");
    // console.log(formData.
    //   SelectUserTypeAndDesignation[0].designation != undefined
    //   , "formData");
    console.log(isValid, "isValid");

    if (
      formData?.SelectEmployeeGender?.gender.code &&
      formData?.SelectEmployeeName?.employeeName &&
      formData?.SelectEmployeePhoneNumber?.mobileNumber &&
      formData?.Jurisdictions?.length &&
      STATE_ADMIN
        ? formData?.Jurisdictions.length &&
          hasUniqueDivisions(formData?.Jurisdictions) &&
          !formData?.Jurisdictions.some((juris) => juris?.division == undefined || juris?.divisionBoundary?.length === 0)
        : formData?.Jurisdictions?.length &&
          formData?.Jurisdictions.length &&
          !formData?.Jurisdictions.some((juris) => juris?.roles?.length === 0) &&
          isValid &&
          checkfield &&
          phonecheck &&
          checkMailNameNum(formData) &&
          hasUniqueTenantIds(formData?.Jurisdictions)
    ) {
      setSubmitValve(true);
    } else {
      setSubmitValve(false);
    }
  };

  const navigateToAcknowledgement = (Employees) => {
    history.replace(`/${window?.contextPath}/employee/hrms/response`, { Employees, key: "CREATE", action: "CREATE" });
  };

  const onSubmit = (data) => {
    if (!STATE_ADMIN && data.Jurisdictions?.filter((juris) => juris.tenantId == tenantId).length == 0) {
      setShowToast({ key: true, label: "ERR_BASE_TENANT_MANDATORY" });
      closeToast();
      return;
    }
    if (
      STATE_ADMIN &&
      !Object.values(
        data.Jurisdictions.reduce((acc, sum) => {
          if (sum && sum?.division?.code) {
            acc[sum?.division?.code] = acc[sum?.division?.code] ? acc[sum?.division?.code] + 1 : 1;
          }
          return acc;
        }, {})
      ).every((s) => s == 1)
    ) {
      setShowToast({ key: true, label: "ERR_INVALID_JURISDICTION" });
      closeToast();
      return;
    } else if (
      !Object.values(
        data.Jurisdictions.reduce((acc, sum) => {
          if (sum && sum?.tenantId) {
            acc[sum.tenantId] = acc[sum.tenantId] ? acc[sum.tenantId] + 1 : 1;
          }
          return acc;
        }, {})
      ).every((s) => s == 1)
    ) {
      setShowToast({ key: true, label: "ERR_INVALID_JURISDICTION" });
      closeToast();
      return;
    }
    let roles = [];
    let jurisdictions = [];
    if (STATE_ADMIN) {
      const divisionBoundaryCodes = data?.Jurisdictions.flatMap((j) => j.divisionBoundary.map((item) => item.code));
      let stateRoles = [
        {
          code: "EMPLOYEE",
          name: "EMPLOYEE",
          labelKey: "ACCESSCONTROL_ROLES_ROLES_EMPLOYEE",
        },
        {
          code: "DIV_ADMIN",
          name: "DIVISION ADMIN",
          labelKey: "ACCESSCONTROL_ROLES_ROLES_DIV_ADMIN",
        },
        {
          code: "HRMS_ADMIN",
          name: "HRMS_ADMIN",
          labelKey: "ACCESSCONTROL_ROLES_ROLES_HRMS_ADMIN",
        },
        {
          code: "MDMS_ADMIN",
          name: "MDMS Admin",
          description: "Mdms admin",
        },
      ];
      divisionBoundaryCodes &&
        divisionBoundaryCodes.length > 0 &&
        divisionBoundaryCodes.map((item) => {
          stateRoles?.map((role) => {
            roles.push({
              code: role.code,
              name: role.name,
              labelKey: role.labelKey,
              tenantId: item,
            });
          });
        });

      data?.Jurisdictions?.map((items) => {
        items?.divisionBoundary.map((item) => {
          jurisdictions.push({
            hierarchy: "REVENUE",
            boundaryType: "City",
            boundary: item?.code,
            tenantId: item?.code,
            roles: stateRoles,
          });
        });
      });

      // Map the data and add tenantId to roles array
      const mappedData = jurisdictions.map((jurisdiction) => {
        return {
          ...jurisdiction,
          roles: jurisdiction.roles.map((role) => ({
            ...role,
            tenantId: jurisdiction.tenantId,
          })),
        };
      });
      jurisdictions = mappedData;
    } else {
      roles = data?.Jurisdictions?.map((ele) => {
        return ele.roles?.map((item) => {
          item["tenantId"] = ele.boundary;
          return item;
        });
      });
    }
    roles.push({
      name: "EMPLOYEE",
      code: "EMPLOYEE",
      tenantId: "pb",
    });

    const mappedroles = [].concat.apply([], roles);
    let dateOfAppointment = new Date();
    dateOfAppointment.setDate(dateOfAppointment.getDate() - 1);
    let Employees = [
      {
        tenantId: tenantId,
        employeeStatus: "EMPLOYED",
        code: data?.SelectEmployeeId?.code ? data?.SelectEmployeeId?.code : undefined,
        dateOfAppointment: dateOfAppointment.getTime(),
        employeeType: hrmsData?.["egov-hrms"]?.HRMSConfig[0]?.employeeType,
        jurisdictions: STATE_ADMIN ? jurisdictions : data?.Jurisdictions,
        assignments: [
          {
            fromDate: new Date().getTime(),
            isCurrentAssignment: hrmsData?.["egov-hrms"]?.HRMSConfig[0]?.isCurrentAssignment,
            department: !STATE_ADMIN ? data?.SelectUserTypeAndDesignation[0]?.department?.code : hrmsData?.["egov-hrms"]?.HRMSConfig[0]?.department,
            designation: STATE_ADMIN
              ? hrmsData?.["egov-hrms"]?.HRMSConfig[0]?.designation?.filter((x) => x?.isStateUser)[0]?.code
              : data?.SelectUserTypeAndDesignation[0]?.designation?.code,
          },
        ],
        user: {
          mobileNumber: data?.SelectEmployeePhoneNumber?.mobileNumber,
          name: data?.SelectEmployeeName?.employeeName,
          correspondenceAddress: tenantId,
          emailId: data?.SelectEmployeeEmailId?.emailId ? data?.SelectEmployeeEmailId?.emailId : undefined,
          gender: data?.SelectEmployeeGender?.gender.code,
          dob: 805055400000,
          roles: mappedroles,
          tenantId: tenantId,
        },
        serviceHistory: [],
        education: [],
        tests: [],
      },
    ];
    /* use customiseCreateFormData hook to make some chnages to the Employee object */
    Employees = Digit?.Customizations?.HRMS?.customiseCreateFormData ? Digit.Customizations.HRMS.customiseCreateFormData(data, Employees) : Employees;

    if (data?.SelectEmployeeId?.code && data?.SelectEmployeeId?.code?.trim().length > 0) {
      Digit.HRMSService.search(tenantId, null, { codes: data?.SelectEmployeeId?.code }).then((result, err) => {
        if (result.Employees.length > 0) {
          setShowToast({ key: true, label: "ERR_HRMS_USER_EXIST_ID" });
          closeToast();
          return;
        } else {
          navigateToAcknowledgement(Employees);
        }
      });
    } else {
      navigateToAcknowledgement(Employees);
    }
  };
  if (isLoading) {
    return <Loader />;
  }

  const config = mdmsData?.config ? mdmsData.config : newConfig;
  return (
    <div>
      <div
        style={
          isMobile
            ? { marginLeft: "-12px", fontFamily: "calibri", color: "#FF0000" }
            : { marginLeft: "15px", fontFamily: "calibri", color: "#FF0000" }
        }
      >
        <Header>{STATE_ADMIN ? t("HR_COMMON_CREATE_DIVISION_EMPLOYEE_HEADER") : t("HR_COMMON_CREATE_EMPLOYEE_HEADER")}</Header>
      </div>
      <FormComposer
        // defaultValues={defaultValues}
        defaultValues={sessionFormData}
        heading={t("")}
        config={config}
        onSubmit={onSubmit}
        onFormValueChange={onFormValueChange}
        isDisabled={!canSubmit}
        label={t("HR_COMMON_BUTTON_SUBMIT")}
      />
      {showToast && (
        <Toast
          error={showToast.key}
          label={t(showToast.label)}
          onClose={() => {
            setShowToast(null);
          }}
        />
      )}
    </div>
  );
};
export default CreateEmployee;
