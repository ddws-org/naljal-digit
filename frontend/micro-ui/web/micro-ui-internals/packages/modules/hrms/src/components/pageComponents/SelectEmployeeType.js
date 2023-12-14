import React, { useState, useEffect } from "react";
import { Loader } from "@egovernments/digit-ui-react-components";
import { Dropdown, LabelFieldPair, CardLabel } from "@egovernments/digit-ui-react-components";
import { useLocation } from "react-router-dom";

const SelectEmployeeType = ({ t, config, onSelect, formData = {}, userType }) => {
  const tenantId = Digit.ULBService.getCurrentTenantId();

  const { pathname: url } = useLocation();
  const editScreen = url.includes("/modify-application/");
  const { data: data = {}, isLoading } = Digit.Hooks.hrms.useHrmsMDMS(tenantId, "egov-hrms", "HRMSRolesandDesignation") || {};
  const [employeeType, setemployeeType] = useState(formData?.SelectEmployeeType);
  const [employeeTypeData, setEmployeeTypeData] = useState([]);

  function SelectEmployeeType(value) {
    setemployeeType(value);
  }
  useEffect(() => {
    setEmployeeTypeData(data?.MdmsRes?.["egov-hrms"]?.EmployeeType?.filter((x) => x?.code === "PERMANENT"));
  }, [data, data?.MdmsRes]);

  useEffect(() => {
    onSelect(config.key, employeeTypeData?.length == 1 ? employeeTypeData[0] : employeeType);
  }, [employeeTypeData]);
  const inputs = [
    {
      label: "HR_EMPLOYMENT_TYPE_LABEL",
      type: "text",
      name: "EmployeeType",
      validation: {
        isRequired: true,
      },
      isMandatory: true,
    },
  ];

  if (isLoading) {
    return <Loader />;
  }

  return inputs?.map((input, index) => {
    return (
      <LabelFieldPair key={index}>
        <CardLabel className="card-label-smaller">
          {t(input.label)}
          {input.isMandatory ? " * " : null}
        </CardLabel>
        <Dropdown
          className="form-field"
          selected={employeeTypeData?.length > 0 ? employeeTypeData[0] : employeeType}
          option={employeeTypeData}
          select={SelectEmployeeType}
          disable={true}
          optionKey="code"
          defaultValue={undefined}
          t={t}
        />
      </LabelFieldPair>
    );
  });
};

export default SelectEmployeeType;