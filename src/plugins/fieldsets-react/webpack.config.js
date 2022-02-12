const path = require("path")

module.exports = {
  mode: process.env.NODE_ENV,
  entry: "./src/index.js",
  module: {
    rules: [
      {
        test: /\.(png|jpg|gif|woff|woff2)$/i,
        use: [
          {
            loader: "url-loader",
            options: {
              limit: 8192,
            },
          },
        ],
      },
      {
        test: /\.jsx?$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-typescript", "@babel/preset-react"]
          },
        },
      },
    ],
  },
  resolve: {
    extensions: [".jsx", ".js"],
  },
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "build"),
  },
  devServer: {
    compress: true,
    port: 3000,
    publicPath: "/build/",
  },
}
