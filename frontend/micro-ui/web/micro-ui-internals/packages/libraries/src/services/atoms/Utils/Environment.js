// Environment.js
export const InitializeEnvironment = {
    get getStatePath() {
        const parsedUrl = new URL(window?.location?.href);
        const pathParts = parsedUrl.pathname.split('/').filter(Boolean);
    
        // Return the first part of the path for non-local URLs
        return pathParts.length > 0 ? pathParts[0] : null;
      },
  };
  
  