import React, { useState } from "react";
import { Switch, Route, useRouteMatch, useLocation } from "react-router-dom";
import { ActionBar, Menu, SubmitBar, BreadCrumb } from "@egovernments/digit-ui-react-components";
import { useTranslation } from "react-i18next";
// import { ComplaintDetails } from "./ComplaintDetails";
// import { CreateComplaint } from "./CreateComplaint";
// import Inbox from "./Inbox";
import { Employee } from "../../constants/Routes";
// import Response from "./Response";

const Complaint = () => {
  const [displayMenu, setDisplayMenu] = useState(false);
  const [popup, setPopup] = useState(false);
  const match = useRouteMatch();
  const { t } = useTranslation();
  let location = useLocation().pathname;

  const isInbox = location?.includes("inbox");
  const isPgr = location?.includes("pgr");
  const isCreate = location?.includes("create");
  const isDetails = location?.includes("details");
  const isResponse = location?.includes("response");
  // const breadcrumConfig = {
  //   home: {
  //     content: t("CS_COMMON_HOME"),
  //     path: Employee.Home,
  //   },
  //   inbox: {
  //     content: t("CS_COMMON_INBOX"),
  //     path: match.url + Employee.Inbox,
  //   },
  //   createComplaint: {
  //     content: t("CS_PGR_CREATE_COMPLAINT"),
  //     path: match.url + Employee.CreateComplaint,
  //   },
  //   complaintDetails: {
  //     content: t("CS_PGR_COMPLAINT_DETAILS"),
  //     path: match.url + Employee.ComplaintDetails + ":id",
  //   },
  //   response: {
  //     content: t("CS_PGR_RESPONSE"),
  //     path: match.url + Employee.Response,
  //   },
  // };
  function popupCall(option) {
    setDisplayMenu(false);
    setPopup(true);
  }

  // let location = useLocation().pathname;

  const crumbs = [
    {
      path: "/mgramseva-web/employee",
      content: t("ES_COMMON_HOME"),
      show: isPgr,
    },
    {
      path: "/mgramseva-web/employee/pgr/inbox",
      content: t("CS_COMMON_INBOX"),
      show: isPgr && isInbox,
    },
    {
      path: "/mgramseva-web/employee/pgr/complaint/create",
      content: t("CS_PGR_CREATE_COMPLAINT"),
      show: isPgr && isCreate,
    },
    {
      path: "/mgramseva-web/employee/pgr/inbox",
      content: t("CS_PGR_COMPLAINT_DETAILS"),
      show: isPgr && isDetails,
    },
    {
      path: "mgramseva-web/employee/pgr/response",
      content: t("CS_PGR_RESPONSE"),
      show: isPgr && isResponse,
    },
  ];

  const CreateComplaint = Digit?.ComponentRegistryService?.getComponent('PGRCreateComplaintEmp');
  const ComplaintDetails = Digit?.ComponentRegistryService?.getComponent('PGRComplaintDetails');
  const Inbox = Digit?.ComponentRegistryService?.getComponent('PGRInbox');
  const Response = Digit?.ComponentRegistryService?.getComponent('PGRResponseEmp');

  return (
    <React.Fragment>
      <div className="ground-container">
          <Switch>
            <Route path={match.url} component={() => <BreadCrumb crumbs={crumbs}></BreadCrumb>} />
          </Switch>
        <Switch>
          <Route path={match.url + Employee.CreateComplaint} component={() => <CreateComplaint parentUrl={match.url} />} />
          <Route path={match.url + Employee.ComplaintDetails + ":id*"} component={() => <ComplaintDetails />} />
          <Route path={match.url + Employee.Inbox} component={Inbox} />
          <Route path={match.url + Employee.Response} component={Response} />
        </Switch>
      </div>
      {/* <ActionBar>
        {displayMenu ? <Menu options={["Assign Complaint", "Reject Complaint"]} onSelect={popupCall} /> : null}
        <SubmitBar label="Take Action" onSubmit={() => setDisplayMenu(!displayMenu)} />
      </ActionBar> */}
    </React.Fragment>
  );
};

export default Complaint;
