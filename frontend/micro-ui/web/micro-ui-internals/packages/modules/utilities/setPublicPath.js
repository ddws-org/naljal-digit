// setPublicPath.js
if (window.globalConfigs && typeof window.globalConfigs.getConfig === 'function') {
    const publicPath = window.globalConfigs.getConfig("STATE_PREFIX_CODE");
    if (publicPath) {
        __webpack_public_path__ = `${publicPath}/mgramseva-web/`;
    }
}
