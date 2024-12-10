export const newConfig = [
  {
    head: "Personal Details",
    body: [
      {
        type: "component",
        component: "SelectEmployeeName",
        key: "SelectEmployeeName",
        withoutLabel: true,
      },
      {
        type: "component",
        component: "SelectEmployeePhoneNumber",
        key: "SelectEmployeePhoneNumber",
        withoutLabel: true,
      },
      {
        type: "component",
        component: "SelectEmployeeGender",
        key: "SelectEmployeeGender",
        withoutLabel: true,
      },
      {
        type: "component",
        component: "SelectEmployeeEmailId",
        key: "SelectEmployeeEmailId",
        withoutLabel: true,
      },
      {
        type: "component",
        isMandatory: true,
        component: "SelectUserTypeAndDesignation",
        key: "SelectUserTypeAndDesignation",
        withoutLabel: true,
      },
    ],
  },
  {
    head: "HR_JURISDICTION_DETAILS_HEADER",
    body: [
      {
        type: "component",
        isMandatory: true,
        component: "Jurisdictions",
        key: "Jurisdictions",
        withoutLabel: true,
      },
    ],
  },
];
