const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const webpack = require("webpack");
// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

// Read the public path from environment variable or use a default value
const ENV_PUBLIC_PATH = process.env.PUBLIC_PATH || '/uat/mgramseva-web/'; // Default to 'uat'\


console.log("##ENV_HELM ENV_PUBLIC_PATH: ", process.env.PUBLIC_PATH);
console.log("##ENV_HELM NODE_ENV: ", process.env.NODE_ENV);
console.log("##ENV_HELM REACT_APP_STATE_LEVEL_TENANT_ID: ", process.env.REACT_APP_STATE_LEVEL_TENANT_ID);

module.exports = {
  // mode: 'development',
  entry: "./src/index.js",
  devtool: "source-map",
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-env", "@babel/preset-react"],
            plugins: ["@babel/plugin-proposal-optional-chaining"]
          }
        }
      },
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
    ],
  },
  output: {
    filename: "[name].bundle.js",
    path: path.resolve(__dirname, "build"),
    publicPath: ENV_PUBLIC_PATH, 
  },
  optimization: {
    splitChunks: {
      chunks: "all",
      minSize: 20000,
      maxSize: 50000,
      enforceSizeThreshold: 50000,
      minChunks: 1,
      maxAsyncRequests: 30,
      maxInitialRequests: 30,
    },
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({ inject: true, template: "public/index.html" }),
    new webpack.DefinePlugin({
      'process.env.PUBLIC_PATH': JSON.stringify(ENV_PUBLIC_PATH),
    }),
  ],
};
