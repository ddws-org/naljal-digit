const { createProxyMiddleware } = require("http-proxy-middleware");
const getDynamicPart = (url) => {
  const parsedUrl = new URL(url);
  const pathParts = parsedUrl.pathname.split('/').filter(Boolean);
  return pathParts.length > 0 ? pathParts[0] : null; // Gets the first part after the domain
};
const createProxy = createProxyMiddleware({
  target: `${process.env.REACT_APP_PROXY_URL}/${getDynamicPart(window?.location?.href)}`,
  changeOrigin: true,
});
module.exports = function (app) {
  [
    "/egov-mdms-service",
    "/mdms-v2",
    "/egov-location",
    "/localization",
    "/egov-workflow-v2",
    "/pgr-services",
    "/filestore",
    "/egov-hrms",
    "/user-otp",
    "/user",
    "/fsm",
    "/billing-service",
    "/collection-services",
    "/pdf-service",
    "/pg-service",
    "/vehicle",
    "/vendor",
    "/property-services",
    "/fsm-calculator/v1/billingSlab/_search",
    "/muster-roll",
  ].forEach((location) => app.use(location, createProxy));
};
