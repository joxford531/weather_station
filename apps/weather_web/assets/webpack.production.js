const path = require('path');
const merge = require('webpack-merge');
const base = require('./webpack.config.js');

let glob = require("glob-all");
let PurgecssPlugin = require("purgecss-webpack-plugin");

// Extractor specific to Tailwind
class TailwindExtractor {
  static extract(content) {
    return content.match(/[A-Za-z0-9-_:\/]+/g) || [];
  }
}

let purge = new PurgecssPlugin({
  paths: glob.sync([
    path.resolve(__dirname, "../lib/weather_web/live/**/*.ex"),
    path.resolve(__dirname, "../lib/weather_web/templates/**/*.eex"),
    path.resolve(__dirname, "../lib/weather_web/templates/**/*.leex"),
    path.resolve(__dirname, "../lib/weather_web/views/**/*.ex"),
  ]),
  extractors: [
    {
      extractor: TailwindExtractor,
      extensions: ["ex", "eex", "leex"]
    }
  ]
});

module.exports = merge(base, {
  plugins: [
    purge
  ]
});