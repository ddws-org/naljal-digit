if (window.__PUBLIC_PATH__) {
  __webpack_public_path__ = window.__PUBLIC_PATH__; // eslint-disable-line
  console.log(`*** LOG ***1`,__webpack_public_path__);
  try {
    // Set the public path dynamically
    if (__webpack_public_path__ !== undefined) {
      __webpack_public_path__ = config.publicPath;
  console.log(`*** LOG ***2`,__webpack_public_path__);

    }
  } catch (error) {
    console.error('Failed to load public path configuration:', error);
    // Fallback to a default public path if needed
    __webpack_public_path__ = '/uat/mgramseva-web/';
  console.log(`*** LOG ***3`,__webpack_public_path__);


  }
}
else {
  __webpack_public_path__ = '/uat/mgramseva-web/';
  console.log(`*** LOG ***4`,__webpack_public_path__);

}  
