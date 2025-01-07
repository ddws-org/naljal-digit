import Axios from "axios";
import Urls from "./urls";

export const UploadServices = {
  Filestorage: async (module, filedata, tenantId) => {
    const formData = new FormData();
    formData.append("file", filedata, filedata.name);
    formData.append("tenantId", tenantId);
    formData.append("module", module);
    let tenantInfo=window?.globalConfigs?.getConfig("ENABLE_SINGLEINSTANCE")?`?tenantId=${tenantId}`:"";
    var config = {
      method: "post",
      baseURL: `${window?.location?.origin}/${Digit.InitEnvironment.getStatePath}`,
      url:`${Urls.FileStore}${tenantInfo}`,   
      data: formData,
      headers: { "auth-token": Digit.UserService.getUser() ? Digit.UserService.getUser()?.access_token : null},
    };    
    const res = await Axios(config);
    return res;
  },


  MultipleFilesStorage: async (module, filesData, tenantId) => {
    const formData = new FormData();
    const filesArray = Array.from(filesData)
    filesArray?.forEach((fileData, index) => fileData ? formData.append("file", fileData, fileData.name) : null);
    formData.append("tenantId", tenantId);
    formData.append("module", module);
    let tenantInfo=window?.globalConfigs?.getConfig("ENABLE_SINGLEINSTANCE")?`?tenantId=${tenantId}`:"";
    var config = {
      method: "post",
      baseURL: `${window?.location?.origin}/${Digit.InitEnvironment.getStatePath}`, 
      url:`${Urls.FileStore}${tenantInfo}`,
      data: formData,
      headers: { 'Content-Type': 'multipart/form-data',"auth-token": Digit.UserService.getUser().access_token },
    };
    const res = await Axios(config);
    return res;
  },

  Filefetch: async (filesArray, tenantId) => {
    let tenantInfo=window?.globalConfigs?.getConfig("ENABLE_SINGLEINSTANCE")?`?tenantId=${tenantId}`:"";
    var config = {
      method: "get",
      baseURL: `${window?.location?.origin}/${Digit.InitEnvironment.getStatePath}`,
      url:`${Urls.FileFetch}${tenantInfo}`,
      params: {
        tenantId: tenantId,
        fileStoreIds: filesArray?.join(","),
      },
    };
    const res = await Axios(config);
    return res;
  },
};
