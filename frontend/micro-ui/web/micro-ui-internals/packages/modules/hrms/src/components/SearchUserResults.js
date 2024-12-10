import React from "react";
import { useTranslation } from "react-i18next";
import { Table, Loader, Card } from "@egovernments/digit-ui-react-components";
import { Link } from "react-router-dom";

const SearchUserResults = ({ isLoading, data, ...props }) => {
  const { t } = useTranslation();
  const GetCell = (value) => <span className="cell-text">{t(value)}</span>;
  const GetSlaCell = (value) => {
    return value == "INACTIVE" ? (
      <span className="sla-cell-error">{t(value) || ""}</span>
    ) : (
      <span className="sla-cell-success">{t(value) || ""}</span>
    );
  };

  const columns = React.useMemo(() => {
    return [
      {
        Header: t("HR_EMP_ID_LABEL"),
        disableSortBy: false,
        accessor: "code",
        Cell: ({ row }) => {
          console.log(row, "ROW");

          return (
            // <span className="link">
            //   <Link to={`/${window?.contextPath}/employee/hrms/details/${row.original.tenantId}/${row.original.code}`}>{row.original.code}</Link>
            // </span>
            GetCell(`${row.original?.code}`)
          );
        },
      },
      {
        Header: t("HR_EMP_NAME_LABEL"),
        disableSortBy: false,
        accessor: "name",
        Cell: ({ row }) => {
          return GetCell(`${row.original?.user?.name}`);
        },
      },
      {
        Header: t("HR_USER_DEPARTMENT"),
        disableSortBy: false,
        accessor: "department",
        Cell: ({ row }) => {
          return GetCell(`${row.original?.assignments[0]?.department}`);
        },
      },
      {
        Header: t("HR_USER_DESIGNATION"),
        disableSortBy: false,
        accessor: "designation",
        Cell: ({ row }) => {
          return GetCell(`${row.original?.assignments[0]?.designation}`);
        },
      },
      {
        Header: t("HR_USER_ID_LABEL"),
        disableSortBy: false,
        accessor: "mobileNumber",
        Cell: ({ row }) => {
          return GetCell(`${row.original?.user?.mobileNumber}`);
        },
      },
      {
        Header: t("HR_STATUS_LABEL"),
        disableSortBy: false,
        accessor: "isActive",
        Cell: ({ row }) => {
          return GetSlaCell(`${row.original?.isActive ? "ACTIVE" : "INACTIVE"}`);
        },
      },

      {
        Header: t("HR_SU_TENANT"),
        disableSortBy: false,
        accessor: "tenantId",
        Cell: ({ row }) => {
          return GetCell(`${row.original?.tenantId}`);
        },
      },
    ];
  }, [data]);

  let result;

  if (isLoading) {
    result = <Loader />;
  } else if (data?.length === 0) {
    result = (
      <Card style={{ marginTop: 20 }}>
        {/* TODO Change localization key */}
        {t("COMMON_TABLE_NO_RECORD_FOUND")
          .split("\\n")
          .map((text, index) => (
            <p key={index} style={{ textAlign: "center" }}>
              {text}
            </p>
          ))}
      </Card>
    );
  } else if (data?.length > 0) {
    result = (
      <Table
        t={t}
        data={data}
        columns={columns}
        getCellProps={(cellInfo) => {
          return {
            style: {
              maxWidth: cellInfo.column.Header == t("HR_EMP_ID_LABEL") ? "150px" : "",
              padding: "20px 18px",
              fontSize: "16px",
              minWidth: "150px",
            },
          };
        }}
        // onNextPage={onNextPage}
        // onPrevPage={onPrevPage}
        // currentPage={currentPage}
        totalRecords={data ? data.length : 0}
        // onPageSizeChange={onPageSizeChange}
        // pageSizeLimit={pageSizeLimit}
        // onSort={onSort}
        // sortParams={sortParams}
        // disableSort={disableSort}
        autoSort={true}
        manualPagination={false}
      />
    );
  }

  return <div>{result}</div>;
};

export default SearchUserResults;
