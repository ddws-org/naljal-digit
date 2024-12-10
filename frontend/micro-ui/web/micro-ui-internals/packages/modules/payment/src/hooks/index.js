import utils from "../utils";

const payment = {
 
};

const Hooks = {
  payment,
};

const Utils = {
  browser: {
    sample: () => {},
  },
  payment:{
    ...utils
  }
};

export const CustomisedHooks = {
  Hooks,
  Utils,
};
