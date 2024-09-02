import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import { PasswordEyeEnableSvg, PasswordEyeDisableSvg } from "./svgindex";

const Password = (props) => {
    const user_type = Digit.SessionStorage.get("userType");
    const [passwordVisibleFlag, setPasswordVisibleFlag] = useState(false);
    const onChange = (e) => {
        let val = e.target.value;
        props?.onChange?.(val);
    };
    const showPassword = () => {
        setPasswordVisibleFlag(!passwordVisibleFlag);
    };

    return (
        <React.Fragment>
            <div className="field-container">
                <div className={`text-input ${user_type === "employee" ? "" : "text-mobile-input-width"} ${props.className}`}>
                    <input
                        type={passwordVisibleFlag ? "text" : "password"}
                        name={props.name}
                        id={props.id}
                        className={`${user_type ? "employee-card-input" : "citizen-card-input"} ${props.disable && "disabled"} focus-visible ${props.errorStyle && "employee-card-input-error"}`}
                        placeholder={props.placeholder}
                        onChange={onChange}
                        ref={props.inputRef}
                        value={props.value}
                        style={{ ...props.style }}
                        minLength={props.minlength}
                        maxLength={props.maxlength || 10}
                        max={props.max}
                        min={props.min}
                        readOnly={props.disable}
                        title={props.title}
                        step={props.step}
                        autoFocus={props.autoFocus}
                    />
                </div>
                {!props.hideSpan ? (
                    <span onClick={showPassword} style={{ maxWidth: "50px", paddingLeft: "5px", marginTop: "unset", border: "1px solid #464646", borderLeft: "none", cursor: "pointer" }} className="citizen-card-input citizen-card-input--front">
                        {passwordVisibleFlag?<PasswordEyeDisableSvg />:<PasswordEyeEnableSvg/>}
                        
                    </span>
                ) : null}
            </div>
        </React.Fragment>
    );
};

export default Password;