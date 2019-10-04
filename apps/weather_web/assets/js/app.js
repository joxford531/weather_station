// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let tempLine = null;
let humidityLine = null;
let dewpointLine = null;
let pressureLine = null;

let chartColors = {
  red: 'rgb(255, 99, 132)',
  orange: 'rgb(255, 159, 64)',
  yellow: 'rgb(255, 205, 86)',
  green: 'rgb(75, 192, 192)',
  blue: 'rgb(54, 162, 235)',
  purple: 'rgb(153, 102, 255)',
  grey: 'rgb(201, 203, 207)'
};

let tempConfig = {
  type: 'line',
  data: {
    datasets: [
      {
        label: 'BMP180 Temp',
        borderColor: chartColors.red,
        fill: false,
        data: []
      },
      {
        label: 'SHT31 Temp',
        borderColor: chartColors.blue,
        fill: false,
        data: []
      }
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    title: {
      display: true,
      text: 'hourly temp data'
    },
    scales: {
      xAxes: [{
        type: 'time',
        display: true,
        scaleLabel: {
          display: true,
          labelString: 'Date'
        },
        ticks: {
          major: {
            fontStyle: 'bold',
            fontColor: '#FF0000'
          }
        }
      }],
      yAxes: [{
        display: true,
        scaleLabel: {
          display: true,
          labelString: 'Temp °F'
        }
      }]
    }
  }
};

let humidityConfig = JSON.parse(JSON.stringify(tempConfig));

humidityConfig.data.datasets = [{
  label: 'SHT31 Humidity',
  borderColor: chartColors.green,
  fill: false,
  data: []
}]

humidityConfig.options.title.text = "hourly humidity data";
humidityConfig.options.scales.yAxes[0].scaleLabel.labelString = "Humidity %"

let dewpointConfig = JSON.parse(JSON.stringify(humidityConfig));

dewpointConfig.data.datasets = [{
  label: 'Dew Point',
  borderColor: chartColors.orange,
  fill: false,
  data: []
}]

dewpointConfig.options.title.text = "hourly dew point data";
dewpointConfig.options.scales.yAxes[0].scaleLabel.labelString = "DewPoint °F"

let pressureConfig = JSON.parse(JSON.stringify(dewpointConfig));

pressureConfig.data.datasets = [{
  label: 'Pressure',
  borderColor: chartColors.red,
  fill: false,
  data: []
}]

pressureConfig.options.title.text = "hourly barometric data";
pressureConfig.options.scales.yAxes[0].scaleLabel.labelString = "inHg"

let hooks = {
  tempChart: {
    mounted() {
      let ctx = document.getElementById('canvas-temperature').getContext('2d');

      tempConfig.data.datasets[0].data = JSON.parse(this.el.dataset.bmp);
      tempConfig.data.datasets[1].data = JSON.parse(this.el.dataset.sht);

      tempLine = new Chart(ctx, tempConfig);
    },
    updated() {
      let el = document.getElementById("temperature-holder");
      tempConfig.data.datasets[0].data = JSON.parse(el.dataset.bmp);
      tempConfig.data.datasets[1].data = JSON.parse(el.dataset.sht);
      tempConfig.options.title.text = `${el.dataset.period.replace(/\"/g, "")} temp data`
      tempLine.update();
    }
  },
  humidityChart: {
    mounted() {
      let ctx = document.getElementById('canvas-humidity').getContext('2d');

      humidityConfig.data.datasets[0].data = JSON.parse(this.el.dataset.humidity);

      humidityLine = new Chart(ctx, humidityConfig);
    },
    updated() {
      let el = document.getElementById("humidity-holder");
      humidityConfig.data.datasets[0].data = JSON.parse(el.dataset.humidity);
      humidityConfig.options.title.text = `${el.dataset.period.replace(/\"/g, "")} humidity data`
      humidityLine.update();
    }
  },
  dewpointChart: {
    mounted() {
      let ctx = document.getElementById('canvas-dewpoint').getContext('2d');

      dewpointConfig.data.datasets[0].data = JSON.parse(this.el.dataset.dewpoint);

      dewpointLine = new Chart(ctx, dewpointConfig);
    },
    updated() {
      let el = document.getElementById("dewpoint-holder");
      dewpointConfig.data.datasets[0].data = JSON.parse(el.dataset.dewpoint);
      dewpointConfig.options.title.text = `${el.dataset.period.replace(/\"/g, "")} dew point data`
      dewpointLine.update();
    }
  },
  pressureChart: {
    mounted() {
      let ctx = document.getElementById('canvas-pressure').getContext('2d');

      pressureConfig.data.datasets[0].data = JSON.parse(this.el.dataset.pressure);

      pressureLine = new Chart(ctx, pressureConfig);
    },
    updated() {
      let el = document.getElementById("pressure-holder");
      pressureConfig.data.datasets[0].data = JSON.parse(el.dataset.pressure);
      pressureConfig.options.title.text = `${el.dataset.period.replace(/\"/g, "")} pressure data`
      pressureLine.update();
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, { hooks })
liveSocket.connect()