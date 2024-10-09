import {
  ActionBar,
  Card,
  CardSubHeader,
  DocumentSVG,
  Header,
  Loader,
  Menu,
  Row,
  StatusTable,
  SubmitBar,
} from "@egovernments/digit-ui-react-components";
import React, { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { useHistory, useParams } from "react-router-dom";
import ActionModal from "../components/Modal";
import { convertEpochFormateToDate, pdfDownloadLink } from "../components/Utils";

const Details = () => {
  const activeworkflowActions = ["DEACTIVATE_EMPLOYEE_HEAD", "COMMON_EDIT_EMPLOYEE_HEADER"];
  const deactiveworkflowActions = ["ACTIVATE_EMPLOYEE_HEAD"];
  const [selectedAction, setSelectedAction] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const { t } = useTranslation();
  const { id: employeeId } = useParams();
  const { tenantId: tenantId } = useParams();
  const history = useHistory();
  const [displayMenu, setDisplayMenu] = useState(false);
  const isupdate = Digit.SessionStorage.get("isupdate");
  const { isLoading, isError, error, data, ...rest } = Digit.Hooks.hrms.useHRMSSearch({ codes: employeeId }, tenantId, null, isupdate);
  const [errorInfo, setErrorInfo, clearError] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_ERROR_DATA", false);
  const [mutationHappened, setMutationHappened, clear] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_MUTATION_HAPPENED", false);
  const [successData, setsuccessData, clearSuccessData] = Digit.Hooks.useSessionStorage("EMPLOYEE_HRMS_MUTATION_SUCCESS_DATA", false);
  const isMobile = window.Digit.Utils.browser.isMobile();
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);
  const DIVISION_ADMIN = Digit.UserService.hasAccess(["DIV_ADMIN"]);

  const { data: mdmsData = {} } = Digit.Hooks.hrms.useHrmsMDMS(tenantId, "egov-hrms", "HRMSRolesandDesignation") || {};

  mdmsData?.MdmsRes?.["tenant"]["tenants"]?.map((items) => {
    data?.Employees[0]?.jurisdictions?.map((jurisdiction) => {
      if (items?.code === jurisdiction?.boundary) {
        jurisdiction["division"] = items?.divisionCode;
      }
    });
  });

  useEffect(() => {
    setMutationHappened(false);
    clearSuccessData();
    clearError();
  }, []);

  function onActionSelect(action) {
    setSelectedAction(action);
    setDisplayMenu(false);
  }

  const closeModal = () => {
    setSelectedAction(null);
    setShowModal(false);
  };
  const handleDownload = async (document) => {
    const res = await Digit.UploadServices.Filefetch([document?.documentId], Digit.ULBService.getStateId());
    let documentLink = pdfDownloadLink(res.data, document?.documentId);
    window.open(documentLink, "_blank");
  };

  const submitAction = (data) => {};

  useEffect(() => {
    switch (selectedAction) {
      case "DEACTIVATE_EMPLOYEE_HEAD":
        return setShowModal(true);
      case "ACTIVATE_EMPLOYEE_HEAD":
        return setShowModal(true);
      case "COMMON_EDIT_EMPLOYEE_HEADER":
        return history.push(`/${window?.contextPath}/employee/hrms/edit/${tenantId}/${employeeId}`);
      default:
        break;
    }
  }, [selectedAction]);

  if (isLoading) {
    return <Loader />;
  }

  return (
    <React.Fragment>
      <div
        style={
          isMobile
            ? { marginLeft: "-12px", fontFamily: "calibri", color: "#FF0000" }
            : { marginLeft: "15px", fontFamily: "calibri", color: "#FF0000" }
        }
      >
        <Header>{t("HR_NEW_EMPLOYEE_FORM_HEADER")}</Header>
      </div>
      {!isLoading && data?.Employees.length > 0 ? (
        <div>
          <Card>
            <StatusTable>
              <Row
                label={<CardSubHeader className="card-section-header">{t("HR_EMP_STATUS_LABEL")} </CardSubHeader>}
                text={
                  data?.Employees?.[0]?.isActive ? (
                    <div className="sla-cell-success"> {t("ACTIVE")} </div>
                  ) : (
                    <div className="sla-cell-error">{t("INACTIVE")}</div>
                  )
                }
                textStyle={{ fontWeight: "bold", maxWidth: "7rem" }}
              />
            </StatusTable>
            <CardSubHeader className="card-section-header">{t("HR_PERSONAL_DETAILS_FORM_HEADER")} </CardSubHeader>
            <StatusTable>
              <Row label={t("HR_NAME_LABEL")} text={data?.Employees?.[0]?.user?.name || "NA"} textStyle={{ whiteSpace: "pre" }} />
              <Row label={t("HR_MOB_NO_LABEL")} text={data?.Employees?.[0]?.user?.mobileNumber || "NA"} textStyle={{ whiteSpace: "pre" }} />
              <Row label={t("HR_GENDER_LABEL")} text={t(data?.Employees?.[0]?.user?.gender) || "NA"} />
              <Row label={t("HR_EMAIL_LABEL")} text={data?.Employees?.[0]?.user?.emailId || "NA"} />
              <Row label={t("HR_COMMON_DEPARTMENT")} text={t(data?.Employees?.[0]?.assignments[0]?.department) || "NA"} />
              <Row label={t("HR_COMMON_USER_DESIGNATION")} text={t(data?.Employees?.[0]?.assignments[0]?.designation) || "NA"} />
              {DIVISION_ADMIN === 1 && <Row label={t("HR_COMMON_USER_PRIMARY_VILLAGE")} text={t(data?.Employees?.[0]?.tenantId) || "NA"} />}
            </StatusTable>
            {data?.Employees?.[0]?.isActive == false ? (
              <StatusTable>
                <Row
                  label={t("HR_EFFECTIVE_DATE")}
                  text={convertEpochFormateToDate(
                    data?.Employees?.[0]?.deactivationDetails?.sort((a, b) => new Date(a.effectiveFrom) - new Date(b.effectiveFrom))[0]?.effectiveFrom
                  )}
                />
                <Row
                  label={t("HR_DEACTIVATION_REASON")}
                  text={
                    t(
                      "EGOV_HRMS_DEACTIVATIONREASON_" +
                        data?.Employees?.[0]?.deactivationDetails?.sort((a, b) => new Date(a.effectiveFrom) - new Date(b.effectiveFrom))[0]
                          .reasonForDeactivation
                    ) || "NA"
                  }
                />
                <Row
                  label={t("HR_REMARKS")}
                  text={
                    data?.Employees?.[0]?.deactivationDetails?.sort((a, b) => new Date(a.effectiveFrom) - new Date(b.effectiveFrom))[0].remarks ||
                    "NA"
                  }
                />

                <Row
                  label={t("HR_ORDER_NO")}
                  text={
                    data?.Employees?.[0]?.deactivationDetails?.sort((a, b) => new Date(a.effectiveFrom) - new Date(b.effectiveFrom))[0]?.orderNo ||
                    "NA"
                  }
                />
              </StatusTable>
            ) : null}

            {data?.Employees?.[0]?.documents ? (
              <StatusTable style={{ marginBottom: "40px" }}>
                <Row label={t("TL_APPROVAL_UPLOAD_HEAD")} text={""} />
                <div style={{ display: "flex", flexWrap: "wrap" }}>
                  {data?.Employees?.[0]?.documents?.map((document, index) => {
                    return (
                      <a onClick={() => handleDownload(document)} style={{ minWidth: "160px", marginRight: "20px" }} key={index}>
                        <DocumentSVG width={85} height={100} style={{ background: "#f6f6f6", padding: "8px", marginLeft: "15px" }} />
                        <p style={{ marginTop: "8px", maxWidth: "196px" }}>{document.documentName}</p>
                      </a>
                    );
                  })}
                </div>
              </StatusTable>
            ) : null}
            {data?.Employees?.[0]?.jurisdictions.length > 0 ? (
              <CardSubHeader className="card-section-header">{t("HR_JURIS_DET_HEADER")}</CardSubHeader>
            ) : null}

            {data?.Employees?.[0]?.jurisdictions?.length > 0
              ? data?.Employees?.[0]?.jurisdictions?.map((element, index) => {
                  return (
                    <StatusTable
                      key={index}
                      style={{
                        maxWidth: "640px",
                        border: "1px solid rgb(214, 213, 212)",
                        inset: "0px",
                        width: "auto",
                        padding: ".2rem",
                        marginBottom: "2rem",
                      }}
                    >
                      <div style={{ paddingBottom: "2rem" }}>
                        {" "}
                        {t("HR_JURISDICTION")} {index + 1}
                      </div>
                      {STATE_ADMIN ? (
                        <Row
                          label={t("HR_DIVISIONS_LABEL")}
                          text={t(Digit.Utils.locale.convertToLocale(element?.division, "EGOV_LOCATION_BOUNDARYTYPE"))}
                          textStyle={{ whiteSpace: "pre" }}
                        />
                      ) : null}
                      <Row label={t("HR_BOUNDARY_LABEL")} text={t(element?.boundary)} />
                      {!STATE_ADMIN ? (
                        <Row
                          label={t("HR_ROLE_LABEL")}
                          text={data?.Employees?.[0]?.user.roles
                            .filter((ele) => ele.tenantId == element?.boundary)
                            ?.map((ele) => t(`ACCESSCONTROL_ROLES_ROLES_` + ele?.code))}
                        />
                      ) : null}
                    </StatusTable>
                  );
                })
              : null}
          </Card>
        </div>
      ) : null}
      {showModal ? (
        <ActionModal t={t} action={selectedAction} tenantId={tenantId} applicationData={data} closeModal={closeModal} submitAction={submitAction} />
      ) : null}
      <ActionBar>
        {displayMenu && data ? (
          <Menu
            localeKeyPrefix="HR"
            options={data?.Employees?.[0]?.isActive ? activeworkflowActions : deactiveworkflowActions}
            t={t}
            onSelect={onActionSelect}
          />
        ) : null}
        <SubmitBar label={t("HR_COMMON_TAKE_ACTION")} onSubmit={() => setDisplayMenu(!displayMenu)} />
      </ActionBar>
    </React.Fragment>
  );
};

export default Details;
