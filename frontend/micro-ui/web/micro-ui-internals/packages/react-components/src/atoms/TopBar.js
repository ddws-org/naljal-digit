import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import Hamburger from "./Hamburger";
import { NotificationBell } from "./svgindex";
import { useLocation, Link } from "react-router-dom";
import BackButton from "./BackButton";

const TopBar = ({
  img,
  isMobile,
  logoUrl,
  onLogout,
  toggleSidebar,
  ulb,
  userDetails,
  notificationCount,
  notificationCountLoaded,
  cityOfCitizenShownBesideLogo,
  onNotificationIconClick,
  hideNotificationIconOnSomeUrlsWhenNotLoggedIn,
  changeLanguage,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const handleClick = () => {
    setIsOpen(!isOpen);
  };
  const { pathname } = useLocation();

  // const showHaburgerorBackButton = () => {
  //   if (pathname === "/digit-ui/citizen" || pathname === "/digit-ui/citizen/" || pathname === "/digit-ui/citizen/select-language") {
  //     return <Hamburger handleClick={toggleSidebar} />;
  //   } else {
  //     return <BackButton className="top-back-btn" />;
  //   }
  // };


  const url = window.location.pathname; // Get the current URL pathname
  const isPaymentPath = url.includes('/payment/'); // Check for payment path

  const paymentlogoUrl = isPaymentPath
    ? window?.globalConfigs?.getConfig?.("LOGO_URL") // Show payment logo if path matches
    : logoUrl;
  // console.log(isPaymentPath, "isPaymentPath");
  return (
    <div className="navbar">
      <div className="center-container back-wrapper">
        <div className="hambuger-back-wrapper" style={{
          justifyContent: "center",
          alignItems: "center"
        }}>
          {isMobile && !isPaymentPath && <Hamburger handleClick={toggleSidebar} />}
          <img
            className="city"
            id="topbar-logo"
            src={paymentlogoUrl || "https://cdn.jsdelivr.net/npm/@egovernments/digit-ui-css@1.0.7/img/m_seva_white_logo.png"}
            alt="mGramSeva"
          />
          {isPaymentPath && <img className="state" src={logoUrl} />}
          {!isPaymentPath && <h3>{cityOfCitizenShownBesideLogo}</h3>}
        </div>

        <div className="RightMostTopBarOptions">

          <div className="dropdown-user">
            <button className="dropbtn" onClick={handleClick}
              style={{
                color: "white",
                fontSize: "1rem",
                margin: "10px",
                backgroundColor: "#efefef00"
              }}
            >
              Login
            </button>
            {isOpen && (
              <div className="dropdown-user-overlay">
                <ul className="dropdown-user-content">
                  <li style={{
                    borderBottom: "solid 1px grey",
                  }}>
                    <Link className="dropdown-user-link" to="/mgramseva-web/employee/user/login">Admin Login</Link>
                  </li>
                  <li>
                    <a
                      href="/mgramseva" target="_blank" rel="noopener noreferrer" className="dropdown-user-link">Login as Employee</a>
                    
                  </li>
                </ul>
              </div>
            )}
          </div>

          <div className="rmv-padding">
          {!hideNotificationIconOnSomeUrlsWhenNotLoggedIn || isPaymentPath ? changeLanguage : null}
          </div>

          {/* {!hideNotificationIconOnSomeUrlsWhenNotLoggedIn ? (
            <div className="EventNotificationWrapper" onClick={onNotificationIconClick}>
              {notificationCountLoaded && notificationCount ? (
                <span>
                  <p>{notificationCount}</p>
                </span>
              ) : null}
              <NotificationBell />
            </div>
          ) : null} */}
          <div>

          </div>

        </div>
      </div>
    </div>
  );
};

TopBar.propTypes = {
  img: PropTypes.string,
};

TopBar.defaultProps = {
  img: undefined,
};

export default TopBar;
