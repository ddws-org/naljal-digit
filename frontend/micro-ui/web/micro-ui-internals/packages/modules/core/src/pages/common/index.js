import React, { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Redirect, Route, Switch, useLocation, useRouteMatch, useHistory } from "react-router-dom";
import { AppModules } from "../../components/AppModules";
import ErrorBoundary from "../../components/ErrorBoundaries";
import TopBarSideBar from "../../components/TopBarSideBar";

import EmployeeLogin from "./Login";
import ErrorComponent from "../../components/ErrorComponent";
import { PrivateRoute, Card, CardText, CardSubHeader, CardLabelError } from "@egovernments/digit-ui-react-components";




const userScreensExempted = ["user/profile", "user/error"];

const CommonApp = ({
  stateInfo,
  userDetails,
  CITIZEN,
  cityDetails,
  mobileView,
  handleUserDropdownSelection,
  logoUrl,
  DSO,
  stateCode,
  modules,
  appTenants,
  sourceUrl,
  pathname,
  initData,
}) => {
  const history = useHistory();
  const { t } = useTranslation();
  const { path } = useRouteMatch();
  const location = useLocation();
  const showLanguageChange = location?.pathname?.includes("language-selection");
  const isUserProfile = userScreensExempted.some((url) => location?.pathname?.includes(url));
  const DIV_ADMIN = Digit.UserService.hasAccess(["DIV_ADMIN"]);
  const MDMS_ADMIN = Digit.UserService.hasAccess(["MDMS_ADMIN"]);
  const STATE_ADMIN = Digit.UserService.hasAccess(["STATE_ADMIN"]);


  const [showAlert, setShowAlert] = useState(false);
  useEffect(() => {
    Digit.UserService.setType("employee");



    if (userDetails?.info?.roles.some(obj => obj.name === "STATE ADMIN")) {
      setShowAlert(false);
    }
    if (cityDetails.code == "pb") {
      if (DIV_ADMIN == 0 && MDMS_ADMIN == 1 && STATE_ADMIN == 1) {
        setShowAlert(false);
      }
      if (DIV_ADMIN == 0 && MDMS_ADMIN == 0 && STATE_ADMIN == 0) {
        setShowAlert(true);

      } else {
        setShowAlert(false);

      }
    }
    else {
      setShowAlert(false);
    }


    // if (cityDetails.code == "pb") {
    //   setShowAlert(true);
    // }
    // else {
    //   setShowAlert(false);
    // }
  }, []);

  const closeAlert = () => {
    setShowAlert(false);
  };



  return (
    <div className="employee">
      <Switch>
        <Route path={`${path}/page`}>
          {isUserProfile && (
            <TopBarSideBar
              t={t}
              stateInfo={stateInfo}
              userDetails={userDetails}
              CITIZEN={CITIZEN}
              cityDetails={cityDetails}
              mobileView={mobileView}
              handleUserDropdownSelection={handleUserDropdownSelection}
              logoUrl={logoUrl}
              showSidebar={isUserProfile ? true : false}
              showLanguageChange={!showLanguageChange}
            />
          )}
          <div
            className={isUserProfile ? "grounded-container" : "loginContainer"}
            style={
              isUserProfile
                ? { padding: 0, paddingTop: "80px", marginLeft: mobileView ? "" : "64px" }
                : { "--banner-url": `url(${stateInfo?.bannerUrl})`, padding: "0px" }
            }
          >
            <Switch>
              <Route path={`${path}/page/view`}>
                <EmployeeLogin />
              </Route>

              <Route path={`${path}/page/error`}>
                <ErrorComponent
                  initData={initData}
                  goToHome={() => {
                    history.push(`/${window?.contextPath}/${Digit?.UserService?.getType?.()}`);
                  }}
                />
              </Route>

            </Switch>
          </div>
        </Route>
        <Route>
          <TopBarSideBar
            t={t}
            stateInfo={stateInfo}
            userDetails={userDetails}
            CITIZEN={CITIZEN}
            cityDetails={cityDetails}
            mobileView={mobileView}
            handleUserDropdownSelection={handleUserDropdownSelection}
            logoUrl={logoUrl}
            modules={modules}
          />
          <div className={`main ${DSO ? "m-auto" : ""}`} style={{ width: "100%", marginLeft: 0 }}>
            <div className="employee-app-wrapper">
              <ErrorBoundary initData={initData}>
                <AppModules stateCode={stateCode} userType="employee" modules={modules} appTenants={appTenants} />
              </ErrorBoundary>
              {/* ALERT BOX */}
              {(userDetails?.info?.roles.some(obj => obj.name === "STATE ADMIN") ? false : true) && showAlert && <div className="customEmployeeWarnings"> {/* Centered row */}
                <Card className="customEmployeeWarnings">
                  <div className="employee-app-container">
                    <div className="">
                      <div className="">
                        <CardText> {t("CS_COMMON_SELECT_TITLE_VILLAGE")}</CardText>
                        <CardLabelError>{t("CS_COMMON_SELECT_VILLAGE")}</CardLabelError>
                        {/* <button onClick={closeAlert}>Close</button> */}
                      </div>
                    </div>
                  </div>
                </Card>
              </div>}
              {/* ALERT BOX */}


            </div>

            <div className="employee-home-footer">
              <img
                alt="Powered by DIGIT"
                src={window?.globalConfigs?.getConfig?.("DIGIT_FOOTER")}
                style={{ height: "1.1em", cursor: "pointer" }}
                onClick={() => {
                  window.open(window?.globalConfigs?.getConfig?.("DIGIT_HOME_URL"), "_blank").focus();
                }}
              />
            </div>
          </div>
        </Route>
        <Route>
          <Redirect to={`${path}/user/language-selection`} />
        </Route>
      </Switch>
    </div>
  );
};

export default CommonApp;
