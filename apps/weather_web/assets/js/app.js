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

let myLine = null;

let chartColors = {
  red: 'rgb(255, 99, 132)',
  orange: 'rgb(255, 159, 64)',
  yellow: 'rgb(255, 205, 86)',
  green: 'rgb(75, 192, 192)',
  blue: 'rgb(54, 162, 235)',
  purple: 'rgb(153, 102, 255)',
  grey: 'rgb(201, 203, 207)'
};

let config = {
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
    title: {
      display: true,
      text: 'Chart.js Time Point Data'
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
          labelString: 'Temp F'
        }
      }]
    }
  }
};

let hooks = {
  chart: {
    mounted() {
      let ctx = document.getElementById('canvas').getContext('2d');

      config.data.datasets[0].data = JSON.parse(this.el.dataset.bmp);
      config.data.datasets[1].data = JSON.parse(this.el.dataset.sht);

      myLine = new Chart(ctx, config);
    },
    updated() {
      let el = document.getElementById("canvas-holder")
      config.data.datasets[0].data = JSON.parse(el.dataset.bmp);
      config.data.datasets[1].data = JSON.parse(el.dataset.sht);
      myLine.update();
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, { hooks })
liveSocket.connect()