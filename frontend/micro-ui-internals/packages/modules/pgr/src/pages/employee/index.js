import React, { useState } from "react";
import { Switch, Route, useRouteMatch } from "react-router-dom";

import { BackButton, ActionBar, Menu, SubmitBar } from "@egovernments/digit-ui-react-components";
import { ComplaintDetails } from "./ComplaintDetails";
import { CreateComplaint } from "./CreateComplaint";
import Inbox from "./Inbox";
import { Employee } from "../../constants/Routes";

const Complaint = () => {
  const [displayMenu, setDisplayMenu] = useState(false);
  const [popup, setPopup] = useState(false);
  const match = useRouteMatch();

  function popupCall(option) {
    console.log("option", option);
    setDisplayMenu(false);
    setPopup(true);
  }
  return (
    <React.Fragment>
      <div className="ground-container">
        <BackButton>Back</BackButton>
        {console.log("match.url:", match.url)}
        {console.log("Employee.CreateComplaint:", Employee.CreateComplaint)}
        <Switch>
          <Route path={match.url + Employee.CreateComplaint} component={() => <CreateComplaint />} />
          <Route path={match.url + Employee.Inbox} component={Inbox} />
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
