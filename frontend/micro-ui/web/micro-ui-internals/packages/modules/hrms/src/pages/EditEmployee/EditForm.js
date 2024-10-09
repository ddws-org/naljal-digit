import { FormComposer, Toast, Loader } from "@egovernments/digit-ui-react-components";
import React, { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { useHistory } from "react-router-dom";
import { newConfig } from "../../components/config/config";
import { convertEpochToDate } from "../../components/Utils";

const EditForm = ({ tenantId, data }) => {
  const { t } = useTranslation();
  const history = useHistory();
  const [canSubmit, setSubmitValve] = useState(false);
  const [showToast, setShowToast] = useState(null);
  const [mobileNumber, setMobileNumber] = useState(null);
  const [phonecheck, setPhonecheck] = useState(false);
  const [checkfield, setcheck] = useState(false);
  const { data: mdmsData, isLoading } = Digit.Hooks.useCommonMDMS(Digit.ULBService.getStateId(), "egov-hrms", ["CommonFieldsConfig"], {
    select: (data) => {
      return {
        config: data?.MdmsRes?.["egov-hrms"]?.CommonFieldsConfig,
      };
    },
    retry: false,
    enable: false,
  });
  const [errorInfo, setErrorInfo, clearError] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_ERROR_DATA", false);
  const [mutationHappened, setMutationHappened, clear] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_MUTATION_HAPPENED", false);
  const [successData, setsuccessData, clearSuccessData] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_MUTATION_SUCCESS_DATA", false);

  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  useEffect(() => {
    setMutationHappened(false);
    clearSuccessData();
    clearError();
  }, []);

  useEffect(() => {
    if (mobileNumber && mobileNumber.length == 10 && mobileNumber?.match(Digit.Utils.getPattern("MobileNo"))) {
      setShowToast(null);
      if (data.user.mobileNumber == mobileNumber) {
        setPhonecheck(true);
      } else {
        Digit.HRMSService?.search(tenantId, null, { phone: mobileNumber })?.then((result, err) => {
          if (result.Employees.length > 0) {
            setShowToast({ key: true, label: "ERR_HRMS_USER_EXIST_MOB" });
            setPhonecheck(false);
          } else {
            setPhonecheck(true);
          }
        });
      }
    } else {
      setPhonecheck(false);
    }
  }, [mobileNumber]);

  let defaultValues = {
    tenantId: tenantId,
    employeeStatus: "EMPLOYED",
    employeeType: data?.code,
    SelectEmployeePhoneNumber: { mobileNumber: data?.user?.mobileNumber },
    SelectEmployeeId: { code: data?.code },
    SelectEmployeeName: { employeeName: data?.user?.name },
    SelectEmployeeEmailId: { emailId: data?.user?.emailId },
    SelectEmployeeCorrespondenceAddress: { correspondenceAddress: data?.user?.correspondenceAddress },
    SelectDateofEmployment: { dateOfAppointment: convertEpochToDate(data?.dateOfAppointment) },
    SelectEmployeeType: { code: data?.employeeType, active: true },
    SelectEmployeeGender: {
      gender: {
        code: data?.user?.gender,
        name: `COMMON_GENDER_${data?.user?.gender}`,
      },
    },
    SelectUserTypeAndDesignation: {
      department: data?.assignments[0]?.department,
      designation: data?.assignments[0]?.designation,
    },

    SelectDateofBirthEmployment: { dob: convertEpochToDate(data?.user?.dob) },
    Jurisdictions: data?.jurisdictions?.map((ele, index) => {
      let obj = {
        key: index,
        hierarchy: {
          code: ele.hierarchy,
          name: ele.hierarchy,
        },
        boundaryType: { label: ele.boundaryType, i18text: `EGOV_LOCATION_BOUNDARYTYPE_${ele.boundaryType.toUpperCase()}` },
        boundary: { code: ele.boundary },
        roles: data?.user?.roles?.filter((item) => item.tenantId == ele.boundary),
        division: {},
        divisionBoundary: [],
      };

      return obj;
    }),
    Assignments: data?.assignments?.map((ele, index) => {
      return Object.assign({}, ele, {
        key: index,
        fromDate: convertEpochToDate(ele.fromDate),
        toDate: convertEpochToDate(ele.toDate),
        isCurrentAssignment: ele.isCurrentAssignment,
        designation: {
          code: ele.designation,
          i18key: "COMMON_MASTERS_DESIGNATION_" + ele.designation,
        },
        department: {
          code: ele.department,
          i18key: "COMMON_MASTERS_DEPARTMENT_" + ele.department,
        },
      });
    }),
  };
  const checkMailNameNum = (formData) => {
    const email = formData?.SelectEmployeeEmailId?.emailId || "";
    const name = formData?.SelectEmployeeName?.employeeName || "";
    const validEmail = email.length == 0 ? true : email.match(Digit.Utils.getPattern("Email"));
    return validEmail && name.match(Digit.Utils.getPattern("Name"));
  };

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
    if (formData?.SelectEmployeePhoneNumber?.mobileNumber) {
      setMobileNumber(formData?.SelectEmployeePhoneNumber?.mobileNumber);
    } else {
      setMobileNumber(formData?.SelectEmployeePhoneNumber?.mobileNumber);
    }

    for (let i = 0; i < formData?.Jurisdictions?.length; i++) {
      let key = formData?.Jurisdictions[i];
      if (!((key?.boundary || key?.divisionBoundary) && (key?.boundaryType || key?.division))) {
        setcheck(false);
        break;
      } else {
        if (!STATE_ADMIN) {
          key?.roles?.length > 0 && setcheck(true);
          if (
            formData?.SelectUserTypeAndDesignation[0] &&
            formData?.SelectUserTypeAndDesignation[0]?.department != undefined &&
            formData?.SelectUserTypeAndDesignation[0]?.designation != undefined
          ) {
            isValid = true;
          } else {
            isValid = false;
          }
        } else if (STATE_ADMIN) {
          setcheck(true);
          isValid = false;
        }
      }
    }

    if (
      formData?.SelectEmployeeGender?.gender.code &&
      formData?.SelectEmployeeName?.employeeName &&
      formData?.SelectEmployeePhoneNumber?.mobileNumber &&
      STATE_ADMIN
        ? formData?.Jurisdictions?.length &&
          !formData?.Jurisdictions.some((juris) => juris?.division == undefined || juris?.divisionBoundary?.length === 0) &&
          hasUniqueDivisions(formData?.Jurisdictions)
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

  const onSubmit = (input) => {
    if (!STATE_ADMIN && input.Jurisdictions.filter((juris) => juris.tenantId == tenantId && juris.isActive !== false).length == 0) {
      setShowToast({ key: true, label: "ERR_BASE_TENANT_MANDATORY" });
      return;
    } else if (!STATE_ADMIN && input.Jurisdictions.filter((juris) => !juris?.roles?.length).length > 0) {
      setShowToast({ key: true, label: "Atleast one Role should be selected per Jurisdiction" });
      return;
    }
    if (
      !Object.values(
        input.Jurisdictions.reduce((acc, sum) => {
          if (sum && sum?.tenantId) {
            acc[sum.tenantId] = acc[sum.tenantId] ? acc[sum.tenantId] + 1 : 1;
          }
          return acc;
        }, {})
      ).every((s) => s == 1)
    ) {
      setShowToast({ key: true, label: "ERR_INVALID_JURISDICTION" });
      return;
    }
    let roles = [];
    let jurisdictions = [];
    if (STATE_ADMIN) {
      const divisionBoundaryCodes = input?.Jurisdictions.flatMap((j) => j.divisionBoundary.map((item) => item.code));
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
      input?.Jurisdictions?.map((items) => {
        items?.divisionBoundary.map((item) => {
          let obj = {
            hierarchy: "REVENUE",
            boundaryType: "City",
            boundary: item?.code,
            tenantId: item?.code,
            roles: items.roles,
          };
          data?.jurisdictions?.map((jurisdition) => {
            if (jurisdition?.boundary === item?.code) {
              obj["id"] = jurisdition.id;
              obj["auditDetails"] = jurisdition.auditDetails;
            }
          });
          jurisdictions.push(obj);
        });
      });
      // Map the data and add tenantId to roles array
      const mappedData = jurisdictions.map((jurisdiction, index) => {
        return {
          ...jurisdiction,
          roles: stateRoles.map((role) => ({
            ...role,
            tenantId: jurisdiction.tenantId,
          })),
        };
      });

      jurisdictions = mappedData;
    } else {
      input.Jurisdictions.map((items) => {
        let obj = {
          hierarchy: items?.hierarchy,
          boundaryType: items?.boundaryType,
          boundary: items?.boundary,
          tenantId: items?.tenantId,
          roles: items?.roles,
        };
        data?.jurisdictions?.map((jurisdition) => {
          if (jurisdition?.boundary === items?.boundary) {
            obj["id"] = jurisdition.id;
            obj["auditDetails"] = jurisdition.auditDetails;
          }
        });
        jurisdictions.push(obj);
      });
      roles = input?.Jurisdictions?.map((ele) => {
        return ele.roles?.map((item) => {
          item["tenantId"] = ele.boundary;
          return item;
        });
      });
    }
    let requestdata = Object.assign({}, data);
    roles = [].concat.apply([], roles);
    // console.log(input?.SelectUserTypeAndDesignation, "input?.Assignments");
    // console.log(data?.assignments, "data?.assignments");
    // console.log(input, "INPUT");

    let dataAssignments = data?.assignments;
    dataAssignments[0].department = input.SelectUserTypeAndDesignation[0]?.department?.code;
    dataAssignments[0].designation = input.SelectUserTypeAndDesignation[0]?.designation?.code;

    requestdata.assignments = input?.Assignments ? input?.Assignments : dataAssignments;
    requestdata.dateOfAppointment = Date.parse(input?.SelectDateofEmployment?.dateOfAppointment);
    requestdata.code = input?.SelectEmployeeId?.code ? input?.SelectEmployeeId?.code : data?.code;
    requestdata.jurisdictions = jurisdictions;
    requestdata.user.emailId = input?.SelectEmployeeEmailId?.emailId ? input?.SelectEmployeeEmailId?.emailId : undefined;
    requestdata.user.gender = input?.SelectEmployeeGender?.gender.code;
    requestdata.user.dob = Date.parse(input?.SelectDateofBirthEmployment?.dob) || data?.user?.dob;
    requestdata.user.mobileNumber = input?.SelectEmployeePhoneNumber?.mobileNumber;
    requestdata["user"]["name"] = input?.SelectEmployeeName?.employeeName;
    requestdata.user.correspondenceAddress = input?.SelectEmployeeCorrespondenceAddress?.correspondenceAddress;
    requestdata.user.roles = roles.filter((role) => role && role.name);
    let Employees = [requestdata];

    /* use customiseUpdateFormData hook to make some chnages to the Employee object */
    Employees = Digit?.Customizations?.HRMS?.customiseUpdateFormData ? Digit.Customizations.HRMS.customiseUpdateFormData(data, Employees) : Employees;
    history.replace(`/${window?.contextPath}/employee/hrms/response`, { Employees, key: "UPDATE", action: "UPDATE" });
  };
  if (isLoading) {
    return <Loader />;
  }

  const config = mdmsData?.config ? mdmsData.config : newConfig;

  return (
    <div>
      <FormComposer
        heading={t("HR_COMMON_EDIT_EMPLOYEE_HEADER")}
        isDisabled={!canSubmit}
        label={t("HR_COMMON_BUTTON_SUBMIT")}
        config={config.map((config) => {
          return {
            ...config,
            body: config.body.filter((a) => !a.hideInEmployee),
          };
        })}
        fieldStyle={{ marginRight: 0 }}
        onSubmit={onSubmit}
        defaultValues={defaultValues}
        onFormValueChange={onFormValueChange}
      />{" "}
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
export default EditForm;
