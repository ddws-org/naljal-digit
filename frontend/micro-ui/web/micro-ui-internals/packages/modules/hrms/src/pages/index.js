import { PrivateRoute } from "@egovernments/digit-ui-react-components";
import React, { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { Link, Switch, useLocation, useHistory } from "react-router-dom";
import SearchUser from "./SearchUser";
import Dashboard from "./Dashboard";
import CreateBoundaryRelationship from "./CreateBoundaryRelationship";
import CreateNewHierarchy from "./CreateNewHierarchy";

// const {SixFtApart,Rotate360}=SVG;
const EmployeeApp = ({ path, url, userType }) => {
  const { t } = useTranslation();
  const location = useLocation();
  const mobileView = innerWidth <= 640;
  const tenantId = Digit.ULBService.getCurrentTenantId();
  const inboxInitialState = {
    searchParams: {
      tenantId: tenantId,
    },
  };
  const history = useHistory();

  const HRMSResponse = Digit?.ComponentRegistryService?.getComponent("HRMSResponse");
  const HRMSDetails = Digit?.ComponentRegistryService?.getComponent("HRMSDetails");
  const Inbox = Digit?.ComponentRegistryService?.getComponent("HRInbox");
  const CreateEmployee = Digit?.ComponentRegistryService?.getComponent("HRCreateEmployee");
  const EditEmpolyee = Digit?.ComponentRegistryService?.getComponent("HREditEmpolyee");

  const employeeCreateSession = Digit.Hooks.useSessionStorage("NEW_EMPLOYEE_CREATE", {});
  const [sessionFormData, setSessionFormData, clearSessionFormData] = employeeCreateSession;

  // remove session form data if user navigates away from the estimate create screen
  useEffect(() => {
    if (!window.location.href.includes("/hrms/create") && sessionFormData && Object.keys(sessionFormData) != 0) {
      clearSessionFormData();
    }
  }, [location]);

  return (
    <Switch>
      <React.Fragment>
        <div className="ground-container">
          <p className="breadcrumb" style={{ marginLeft: mobileView ? "1vw" : "0px" }}>
            <Link to={`/${window?.contextPath}/employee`} style={{ cursor: "pointer", color: "#666" }}>
              {t("HR_COMMON_BUTTON_HOME")}
            </Link>{" "}
            / <span>{location.pathname === `/${window?.contextPath}/employee/hrms/inbox` ? t("HR_COMMON_HEADER") : t("HR_COMMON_HEADER")}</span>
          </p>
          <div class="back-btn2 " onClick={() => history.goBack()}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="black" width="19px">
              <path d="M24 0v24H0V0h24z" fill="none" opacity=".87"></path>
              <path d="M14 7l-5 5 5 5V7z"></path>
            </svg>
            <p>Back</p>
          </div>
          <PrivateRoute
            path={`${path}/inbox`}
            component={() => (
              <Inbox parentRoute={path} businessService="hrms" filterComponent="HRMS_INBOX_FILTER" initialStates={inboxInitialState} isInbox={true} />
            )}
          />
          <PrivateRoute path={`${path}/create`} component={() => <CreateEmployee />} />
          <PrivateRoute path={`${path}/response`} component={(props) => <HRMSResponse {...props} parentRoute={path} />} />
          <PrivateRoute path={`${path}/details/:tenantId/:id`} component={() => <HRMSDetails />} />
          <PrivateRoute path={`${path}/edit/:tenantId/:id`} component={() => <EditEmpolyee />} />
          <PrivateRoute path={`${path}/search-user`} component={() => <SearchUser />} />
          <PrivateRoute path={`${path}/dashboard`} component={() => <Dashboard />} />
          <PrivateRoute path={`${path}/create-new-hierarchy`} component={() => <CreateNewHierarchy />} />
          <PrivateRoute path={`${path}/create-boundary-relationship`} component={() => <CreateBoundaryRelationship />} />
        </div>
      </React.Fragment>
    </Switch>
  );
};

export default EmployeeApp;
