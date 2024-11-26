const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

console.log("PUBLIC_PATH:1", process.env);
// console.log("PUBLIC_PATH:2", process[env]);
// console.log("PUBLIC_PATH:3", process[env].PUBLIC_PATH);

// console.log("PUBLIC_PATH:4",JSON.stringify(process.env));
// console.log("PUBLIC_PATH:5",JSON.stringify(process[env].PUBLIC_PATH));
// console.log("PUBLIC_PATH:6",JSON.stringify(process[env]));

// for (const key in process.env) {
//   console.log(`${"PUBLIC_PATH:7-1"}` `${key}: ${process.env[key]}`);
// console.log("PUBLIC_PATH:7",JSON.stringify((`${key}: ${process.env[key]}`)));

  

// }

const publicPath = process.env.REACT_APP_FILE_PATH;




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
    publicPath: '/'
      // publicPath: "",
    // publicPath: "/mgramseva-web/",
    // publicPath: publicPath,
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
  ],
};
