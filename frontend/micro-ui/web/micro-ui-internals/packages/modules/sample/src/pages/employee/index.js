import { AppContainer, BreadCrumb, PrivateRoute } from "@egovernments/digit-ui-react-components";
import React from "react";
import { useTranslation } from "react-i18next";
import { Route, Switch } from "react-router-dom";
import Sample from "./Sample";
import SampleInbox from "./SampleInbox";
import SampleSearch from "./SampleSearch";
import AdvancedCreate from "./AdvancedForm";
import Response from "./Response";

const ProjectBreadCrumb = ({ location }) => {
  const { t } = useTranslation();
  const crumbs = [
    {
      path: `/${window?.contextPath}/employee`,
      content: t("HOME"),
      show: true,
    },
    {
      path: `/${window?.contextPath}/employee`,
      content: t(location.pathname.split("/").pop()),
      show: true,
    },
  ];
  return <BreadCrumb crumbs={crumbs} spanStyle={{ maxWidth: "min-content" }} />;
};

const App = ({ path, stateCode, userType, tenants }) => {
  const commonProps = { stateCode, userType, tenants, path };

  return (
    <Switch>
      <AppContainer className="ground-container">
        <React.Fragment>
          <ProjectBreadCrumb location={location} />
        </React.Fragment>
        <PrivateRoute path={`${path}/create`} component={() => <Sample></Sample>} />
        <PrivateRoute path={`${path}/advanced`} component={() => <AdvancedCreate></AdvancedCreate>} />
        <PrivateRoute path={`${path}/inbox`} component={() => <SampleInbox></SampleInbox>} />
        <PrivateRoute path={`${path}/search`} component={() => <SampleSearch></SampleSearch>} />
        <PrivateRoute path={`${path}/response`} component={() => <Response></Response>} />
      </AppContainer>
    </Switch>
  );
};

export default App;
