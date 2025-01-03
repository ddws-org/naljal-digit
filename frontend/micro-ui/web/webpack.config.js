const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const webpack = require("webpack");

console.log("PUBLIC_PATH:1", process.env);
module.exports = {
  // mode: 'development',
  entry: './src/index.js',
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
    publicPath:'/assam/mgramseva-web/',
    // publicPath: process.env['REACT_APP_CONTEXT_PATH'], // Use runtime public path
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
  //   new webpack.DefinePlugin({
  //     'process.env.REACT_APP_CONTEXT_PATH': JSON.stringify(process.env.REACT_APP_CONTEXT_PATH),
  // }),
  ],
};

// Dynamically set the publicPath based on the environment
// if (typeof window !== "undefined") {
//   const pathName = window.location.pathname;

//   if (pathName.includes('/uat')) {
//     __webpack_public_path__ = `${window.location.origin}/uat/mgramseva-web/`;
//   } else if (pathName.includes('/assam')) {
//     __webpack_public_path__ = `${window.location.origin}/assam/mgramseva-web/`;
//   } else if (pathName.includes('/kerala')) {
//     __webpack_public_path__ = `${window.location.origin}/kerala/mgramseva-web/`;
//   } else {
//     __webpack_public_path__ = `${window.location.origin}/mgramseva-web/`;  // Default path
//   }
// }
