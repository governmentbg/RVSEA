// const { defineConfig } = require('@vue/cli-service')
// module.exports = defineConfig({
//   transpileDependencies: true
// })

const path = require("path");

console.log("Mode: ", process.env.NODE_ENV);
const publicPath = process.env.PUBLIC_PATH;
console.log("Public path: ", publicPath);

module.exports = {
    publicPath,
    outputDir: path.resolve(__dirname, "./../wwwroot"),
    assetsDir: 'assets',
    productionSourceMap: process.env.NODE_ENV != 'production',

    pluginOptions: {
      vuetify: {
			// https://github.com/vuetifyjs/vuetify-loader/tree/next/packages/vuetify-loader
		}
    }
};
