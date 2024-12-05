import React, { useEffect, useReducer, useRef, useState } from "react";
import { useTranslation } from "react-i18next";

const MultiSelectDropdown = ({
  options,
  optionsKey,
  selected = [],
  onSelect,
  defaultLabel = "",
  defaultUnit = "",
  BlockNumber = 1,
  isOBPSMultiple = false,
  props = {},
  isPropsNeeded = false,
  ServerStyle = {},
  config,
  showSelectAll = false,
}) => {
  const [active, setActive] = useState(false);
  const [searchQuery, setSearchQuery] = useState();
  const [optionIndex, setOptionIndex] = useState(-1);
  const [isSelected, setIsSelected] = useState(false);
  const dropdownRef = useRef();
  const { t } = useTranslation();

  const CheckSvg = ({ className, style = {} }) => (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#F47738" className={className} style={style}>
      <path d="M0 0h24v24H0z" fill="none" />
      <path d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z" />
    </svg>
  );

  const ArrowDown = ({ className, onClick, styles, disable }) => (
    <svg
      style={{ ...styles }}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill={disable ? "#9E9E9E" : "black"}
      className={className}
      onClick={onClick}
      width="18px"
      height="18px"
    >
      <path d="M0 0h24v24H0V0z" fill="none" />
      <path d="M7 10l5 5 5-5H7z" />
    </svg>
  );

  const RemoveableTag = ({ text, onClick, extraStyles, disabled = false }) => (
    <div className="tag" style={extraStyles ? extraStyles?.tagStyles : {}}>
      <span className="text" style={extraStyles ? extraStyles?.textStyles : {}}>
        {text}
      </span>
      <span onClick={disabled ? null : onClick}>
        <Close className="close" style={extraStyles ? extraStyles?.closeIconStyles : {}} />
      </span>
    </div>
  );
  function reducer(state, action) {
    switch (action.type) {
      case "ADD_TO_SELECTED_EVENT_QUEUE":
        const newStateData = Array.isArray(action?.payload?.[1])
          ? action?.payload?.[1]?.map((items, index) => {
              let obj = {
                i18text: items?.i18text,
                propsData: [action.payload?.[0], action.payload?.[1]?.[index]],
              };
              return obj;
            })
          : [...state, { [optionsKey]: action.payload?.[1]?.[optionsKey], propsData: action.payload }];
        return newStateData;
      case "REMOVE_FROM_SELECTED_EVENT_QUEUE":
        const newState = Array.isArray(action?.payload?.[1]) ? [] : state.filter((e) => e?.[optionsKey] !== action.payload?.[1]?.[optionsKey]);
        onSelect(
          newState?.map((e) => e?.propsData),
          props
        ); // Update the form state here
        return newState;
      case "REPLACE_COMPLETE_STATE":
        return action.payload;
      default:
        return state;
    }
  }

  useEffect(() => {
    dispatch({ type: "REPLACE_COMPLETE_STATE", payload: fnToSelectOptionThroughProvidedSelection(selected) });
  }, [selected?.length]);

  function fnToSelectOptionThroughProvidedSelection(selected) {
    return selected?.map((e) => ({
      [optionsKey]: e?.i18text ? e.i18text : `ACCESSCONTROL_ROLES_ROLES_${e.code}`,
      propsData: [null, e],
    }));
  }

  const [alreadyQueuedSelectedState, dispatch] = useReducer(reducer, selected, fnToSelectOptionThroughProvidedSelection);

  useEffect(() => {
    if (!active) {
      onSelect(
        alreadyQueuedSelectedState?.map((e) => e.propsData),
        props
      );
    }
  }, [active]);

  useEffect(() => {
    if (alreadyQueuedSelectedState?.length === filteredOptions?.length) {
      if (alreadyQueuedSelectedState?.length != 0 && filteredOptions?.length != 0) {
        setIsSelected(true);
      }
    } else {
      setIsSelected(false);
    }
  }, [alreadyQueuedSelectedState]);

  function handleOutsideClickAndSubmitSimultaneously() {
    setActive(false);
  }

  Digit.Hooks.useClickOutside(dropdownRef, handleOutsideClickAndSubmitSimultaneously, active, { capture: true });
  const filtOptns =
    searchQuery?.length > 0
      ? options.filter(
          (option) =>
            t(option[optionsKey] && typeof option[optionsKey] == "string" && option[optionsKey].toUpperCase())
              .toLowerCase()
              .indexOf(searchQuery.toLowerCase()) >= 0
        )
      : options;

  function onSearch(e) {
    setSearchQuery(e.target.value);
  }

  function onSelectToAddToQueue(...props) {
    const isChecked = arguments[0].target.checked;
    isChecked
      ? dispatch({ type: "ADD_TO_SELECTED_EVENT_QUEUE", payload: arguments })
      : dispatch({ type: "REMOVE_FROM_SELECTED_EVENT_QUEUE", payload: arguments });
  }

  /* Custom function to scroll and select in the dropdowns while using key up and down */
  const keyChange = (e) => {
    if (e.key == "ArrowDown") {
      setOptionIndex((state) => (state + 1 == filtOptns.length ? 0 : state + 1));
      if (optionIndex + 1 == filtOptns.length) {
        e?.target?.parentElement?.parentElement?.children?.namedItem("jk-dropdown-unique")?.scrollTo?.(0, 0);
      } else {
        optionIndex > 2 && e?.target?.parentElement?.parentElement?.children?.namedItem("jk-dropdown-unique")?.scrollBy?.(0, 45);
      }
      e.preventDefault();
    } else if (e.key == "ArrowUp") {
      setOptionIndex((state) => (state !== 0 ? state - 1 : filtOptns.length - 1));
      if (optionIndex === 0) {
        e?.target?.parentElement?.parentElement?.children?.namedItem("jk-dropdown-unique")?.scrollTo?.(100000, 100000);
      } else {
        optionIndex > 2 && e?.target?.parentElement?.parentElement?.children?.namedItem("jk-dropdown-unique")?.scrollBy?.(0, -45);
      }
      e.preventDefault();
    } else if (e.key == "Enter") {
      onSelectToAddToQueue(e, filtOptns[optionIndex]);
    }
  };

  const filteredOptions =
    searchQuery?.length > 0
      ? options.filter(
          (option) =>
            t(option[optionsKey] && typeof option[optionsKey] == "string" && option[optionsKey].toUpperCase())
              .toLowerCase()
              .indexOf(searchQuery.toLowerCase()) >= 0
        )
      : options;

  const handleSelectAll = (...data) => {
    const isChecked = data[0].target.checked;
    setIsSelected(isChecked);
    isChecked
      ? dispatch({ type: "ADD_TO_SELECTED_EVENT_QUEUE", payload: data })
      : dispatch({ type: "REMOVE_FROM_SELECTED_EVENT_QUEUE", payload: data });
  };
  const MenuItem = ({ option, index }) => (
    <div key={index} style={isOBPSMultiple ? (index % 2 !== 0 ? { background: "#EEEEEE" } : {}) : {}}>
      <input
        type="checkbox"
        value={option[optionsKey]}
        checked={alreadyQueuedSelectedState.find((selectedOption) => selectedOption[optionsKey] === option[optionsKey]) ? true : false}
        onChange={(e) =>
          isPropsNeeded
            ? onSelectToAddToQueue(e, option, props)
            : isOBPSMultiple
            ? onSelectToAddToQueue(e, option, BlockNumber)
            : onSelectToAddToQueue(e, option)
        }
        style={{ minWidth: "24px", width: "100%" }}
      />
      <div className="custom-checkbox">
        <CheckSvg style={{ innerWidth: "24px", width: "24px" }} />
      </div>
      <p
        className="label"
        style={
          index === optionIndex
            ? {
                opacity: 1,
                backgroundColor: "rgba(238, 238, 238, var(--bg-opacity))",
              }
            : {}
        }
      >
        {t(option[optionsKey] && typeof option[optionsKey] == "string" && option[optionsKey])}
      </p>
    </div>
  );
  const Menu = () => {
    return (
      <div style={{ display: "block" }}>
        {showSelectAll && (
          <div>
            <input
              type="checkbox"
              checked={isSelected}
              onChange={(e) => handleSelectAll(e, filteredOptions)} // Create this function
              style={{ minWidth: "24px", width: "100%" }}
            />
            <div className="custom-checkbox">
              <CheckSvg style={{ innerWidth: "24px", width: "24px" }} />
            </div>
            <p className="label">{t("SELECT_ALL")}</p>
          </div>
        )}
        {filteredOptions.map((option, index) => (
          <MenuItem option={option} key={index} index={index} />
        ))}
      </div>
    );
    // return filteredOptions?.map((option, index) => <MenuItem option={option} key={index} index={index} />);
  };
  return (
    <div>
      <div className="multi-select-dropdown-wrap" ref={dropdownRef} style={{ marginBottom: "24px" }}>
        <div className={`master${active ? `-active` : ``}`}>
          <input
            className="cursorPointer"
            style={{ opacity: 0 }}
            type="text"
            onKeyDown={keyChange}
            onFocus={() => setActive(true)}
            value={searchQuery}
            onChange={onSearch}
          />
          <div className="label">
            <p>{alreadyQueuedSelectedState.length > 0 ? `${alreadyQueuedSelectedState.length} ${defaultUnit}` : defaultLabel}</p>
            <ArrowDown />
          </div>
        </div>
        {active ? (
          <div className="server" id="jk-dropdown-unique" style={ServerStyle ? ServerStyle : {}}>
            <Menu />
          </div>
        ) : null}
      </div>
      {config?.isDropdownWithChip ? (
        <div className="tag-container">
          {alreadyQueuedSelectedState.length > 0 &&
            alreadyQueuedSelectedState.map((value, index) => {
              return (
                <RemoveableTag
                  key={index}
                  text={`${t(value[optionsKey]).slice(0, 22)} ...`}
                  onClick={isPropsNeeded ? (e) => onSelectToAddToQueue(e, value, props) : (e) => onSelectToAddToQueue(e, value)}
                />
              );
            })}
        </div>
      ) : null}
    </div>
  );
};

export default MultiSelectDropdown;
