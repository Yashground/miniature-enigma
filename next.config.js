// next.config.js
module.exports = {
  output: "export",         //as per new next js version, no need of next export in script
   webpack: (config) => {
    config.resolve = {
      ...config.resolve,     //changing per new webpack release
      fallback: {
        fs: false,
        path: false,
        os: false,
      },
    };
    return config;
  },
  exportPathMap: async function (
    defaultPathMap,
    { dev, dir, outDir, distDir, buildId }
  ) {
    return {
      '/': { page: '/' },
      // Add other static routes as needed
    }
  },
};
