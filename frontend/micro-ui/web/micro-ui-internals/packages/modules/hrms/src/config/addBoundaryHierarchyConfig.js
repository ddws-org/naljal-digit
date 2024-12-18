export const addBoundaryHierarchyConfig = [
  {
    body: [
      {
        label: "WBH_HIERARCHY_NAME",
        type: "text",
        isMandatory: true,
        disable: false,
        populators: {
          name: "hierarchyType",
          customStyle: { UUUU: "baseline" },
          required: true,
          validation: {
            maxlength: 25,
          },
        },
      },
      {
        isMandatory: true,
        key: "levelcards",
        type: "component",
        component: "LevelCards",
        withoutLabel: true,
        disable: false,
        populators: {
          name: "levelcards",
          required: true,
          validation: {
            maxlength: 25,
          },
        },
      },
    ],
  },
];
