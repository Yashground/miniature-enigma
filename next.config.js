module.exports = {
  output: "export",
    webpack: (config) => {
    // Fixes npm packages that depend on `fs` module
    config.node = {
      fs: 'empty'
    };

    // Remove the fallback configuration
    if (config.resolve.fallback) {
      delete config.resolve.fallback;
    }

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
