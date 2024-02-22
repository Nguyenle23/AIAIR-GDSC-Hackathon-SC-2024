import React, { useEffect, useState } from "react";
import "./humiChart.css";

import ReactLoading from "react-loading";
import Highcharts, { chart } from "highcharts";
import HighchartsReact from "highcharts-react-official";
import Dropdown from "react-dropdown";
import "react-dropdown/style.css";

import {
  formatDate,
  convertToBangkokTime,
  formattedTimeToModel,
} from "../../../utils/utilDay";
import { options, selectOption } from "../../../utils/utilOptionModel";
import { currentDate } from "../../../constants/constanst";
import { fetch100DataOfHumiHCM, fetchDataHumiHCM, fetchDataHumiThuDuc } from "../../../data/dataHumi";
import {
  predictHumiWithGB,
  predictHumiWithLR,
  predictHumiWithLSTM,
  predictHumiWithProphet,
  predictHumiWithRF,
  predictHumiWithXGB,
} from "../../../apis/callModelAPI";
import { getNewestDataHCM, get100DataOfHumiHCM } from "../../../apis/callAPI";

const HumiChart = () => {
  const [loading, setLoading] = useState(false);
  const [chartData, setChartData] = useState({
    seriesData: [],
    timeData: [],
    obj: [],
    timeDataPredict: [],
  });
  const [chartDataThuDuc, setChartDataThuDuc] = useState({
    seriesData: [],
    timeData: [],
  });
  const [dataHumi, setDataHumi] = useState({
    value: [],
    time: [],
  });

  const [predictData, setPredictData] = useState({
    seriesData: [],
    timeData: [],
  });
  const [checkPredict, setCheckPredict] = useState(false);
  const [active, setActive] = useState("realtime");

  const realChart = {
    accessibility: {
      enabled: false,
    },
    title: {
      text: `Historical data of Humidity on ${formatDate(currentDate)}`,
    },
    subtitle: {
      text: "Notice: The data is updated every 5 minutes and pinch to zoom in",
      align: "center",
    },
    chart: {
      style: {
        fontFamily: "Quicksand",
        fontSize: "16px",
        backgroundColor: "rgba(255, 255, 255, 0.0)",
      },
      zoomType: "x",
    },
    credits: {
      enabled: false,
    },
    xAxis: {
      type: "datetime",
      categories: chartData.timeData,
      title: {
        text: "Hour (UTC+7)",
      },
      labels: {
        step: 24,
      },
    },
    yAxis: {
      labels: {
        formatter: function () {
          return this.value;
        },
      },
      reversed: false,
      title: {
        x: -16,
        text: "Humidity (%)",
      },
    },
    responsive: {
      rules: [
        {
          condition: {
            maxWidth: 500,
          },
          chartOptions: {
            legend: {
              enabled: false,
            },
          },
        },
      ],
    },
    plotOptions: {
      line: {
        dataLabels: {
          enabled: true,
        },
      },
      marker: {
        radius: 2,
      },
      lineWidth: 1,
      states: {
        hover: {
          lineWidth: 1,
        },
      },
    },
    series: [
      {
        type: "line",
        name: "Ho Chi Minh City",
        data: chartData.seriesData,
      },
      // {
      //   type: "line",
      //   name: "Thu Duc City",
      //   data: chartDataThuDuc.seriesData,
      // },
    ],
  };

  const predictChart = {
    accessibility: {
      enabled: false,
    },
    title: {
      text: `Forecasted data of Humidity for next hour on ${formatDate(
        currentDate
      )}`,
    },
    subtitle: {
      text: "Notice: The data predicted is just a relative value and not save in database",
    },
    chart: {
      style: {
        fontFamily: "Montserrat",
        fontSize: "16px",
        backgroundColor: "rgba(255, 255, 255, 0.0)",
      },
      zoomType: "x",
    },
    credits: {
      enabled: false,
    },
    xAxis: {
      type: "datetime",
      categories: chartData.timeDataPredict,
      title: {
        text: "Hour (UTC+7)",
      },
      labels: {
        step: 2,
      },
    },
    yAxis: {
      labels: {
        formatter: function () {
          return this.value;
        },
      },
      reversed: false,
      title: {
        x: -16,
        text: "Humidity (%)",
      },
    },
    responsive: {
      rules: [
        {
          condition: {
            maxWidth: 500,
          },
          chartOptions: {
            legend: {
              enabled: false,
            },
          },
        },
      ],
    },
    plotOptions: {
      line: {
        dataLabels: {
          enabled: true,
        },
      },
      marker: {
        radius: 2,
      },
      lineWidth: 1,
      states: {
        hover: {
          lineWidth: 1,
        },
      },
    },
    series: [
      {
        type: "line",
        name: "Ho Chi Minh City",
        data: predictData.seriesData,
      },
    ],
  };

  const realtimeFunction = () => {
    setCheckPredict(false);
  };

  let objFormat = {
    time: [],
    value: [],
  };

  const selectOption = async (option) => {
    switch (option.value) {
      case "Prophet":
        setLoading(true);
        try {
          await predictHumiWithProphet(chartData.obj).then((result) => {
            setCheckPredict(true);
            setPredictData({
              timeData: chartData.timeDataPredict,
              seriesData: result.data.forecast,
            });
          });
        } catch (error) {
          console.error("Error occurred:", error);
        } finally {
          setLoading(false);
        }

        break;
      case "LSTM":
        setLoading(true);
        try {
          await predictHumiWithLSTM(dataHumi).then((result) => {
            setCheckPredict(true);
            setPredictData({
              timeData: chartData.timeDataPredict,
              seriesData: result.data.forecast,
            });
          });
        } catch (error) {
          console.error("Error occurred:", error);
        } finally {
          setLoading(false);
        }

        break;
      case "GB":
        setLoading(true);
        try {
          await predictHumiWithGB(chartData.obj).then((result) => {
            setCheckPredict(true);
            setPredictData({
              timeData: chartData.timeDataPredict,
              seriesData: result.data.forecast,
            });
          });
        } catch (error) {
          console.error("Error occurred:", error);
        } finally {
          setLoading(false);
        }
        break;
      case "XGB":
        setLoading(true);
        try {
          await predictHumiWithXGB(chartData.obj).then((result) => {
            setCheckPredict(true);
            setPredictData({
              timeData: chartData.timeDataPredict,
              seriesData: result.data.forecast,
            });
          });
        } catch (error) {
          console.error("Error occurred:", error);
        } finally {
          setLoading(false);
        }
        break;
      case "RF":
        setLoading(true);
        try {
          await predictHumiWithRF(chartData.obj).then((result) => {
            setCheckPredict(true);
            setPredictData({
              timeData: chartData.timeDataPredict,
              seriesData: result.data.forecast,
            });
          });
        } catch (error) {
          console.error("Error occurred:", error);
        } finally {
          setLoading(false);
        }
        break;
      case "LR":
        setLoading(true);
        try {
          await predictHumiWithLR(chartData.obj).then((result) => {
            setCheckPredict(true);
            setPredictData({
              timeData: chartData.timeDataPredict,
              seriesData: result.data.forecast,
            });
          });
        } catch (error) {
          console.error("Error occurred:", error);
        } finally {
          setLoading(false);
        }
        break;
      case "SARIMA":
        alert("SARIMA is not available now");
        break;
      
      default:
        break;
    }
  };

  useEffect(() => {
    fetchDataHumiHCM().then(async (result) => {
      const data = result.data.feeds.map((item) => parseFloat(item.field2));
      const time = result.data.feeds.map((item) => {
        const date = new Date(item.created_at);
        const bangkokTime = convertToBangkokTime(date);
        return `${bangkokTime.hour}:${bangkokTime.minute} ${bangkokTime.amPm}`;
      });

      const timeDataPredictArr = [];
      await getNewestDataHCM().then((result) => {
        const date = new Date(result.feeds[0].created_at);
        for (let i = 0; i < 12; i++) {
          // Repeat 12 times to increment by 1 hour (12 * 5 minutes = 1 hour)
          date.setMinutes(date.getMinutes() + 5); // Add 5 minutes to the current date
          const bangkokTime = convertToBangkokTime(date);
          const timeDataPredict = `${bangkokTime.hour}:${bangkokTime.minute} ${bangkokTime.amPm}`;
          timeDataPredictArr.push(timeDataPredict);
        }
      });

      // send to model
      result.data.feeds.forEach((entry) => {
        const date = new Date(entry.created_at);
        const formattedTime = formattedTimeToModel(date);
        objFormat.time.push(formattedTime);
        objFormat.value.push(entry.field2);
      });

      setChartData({
        seriesData: data,
        timeData: time,
        obj: objFormat,
        timeDataPredict: timeDataPredictArr,
      });
    });

    fetchDataHumiThuDuc().then((result) => {
      const data = result.data.feeds.map((item) => parseFloat(item.field2));
      const time = result.data.feeds.map((item) => {
        const date = new Date(item.created_at);
        const bangkokTime = convertToBangkokTime(date);
        return `${bangkokTime.hour}:${bangkokTime.minute} ${bangkokTime.amPm}`;
      });
      setChartDataThuDuc({ seriesData: data, timeData: time });
    });
    setInterval(fetchDataHumiHCM, 5 * 60 * 1000);
  }, []);

  useEffect(() => {
    fetch100DataOfHumiHCM().then((result) => {
      let objFormat = {
        time: [],
        value: [],
      };

      result.data.feeds.forEach((entry) => {
        const date = new Date(entry.created_at);
        const formattedTime = formattedTimeToModel(date);
        objFormat.time.push(formattedTime);
        objFormat.value.push(entry.field2);
      });

      setDataHumi({
        value: objFormat.value,
        time: objFormat.time,
      });
    });
  }, []);

  return (
    <>
      <div className="line-chart-container">
        <div className="btn-line-chart">
          <div className="btn-chart">
            <button
              className={
                active === "realtime" ? "btn-realtime" : "btn-realtime-active"
              }
              onClick={() => {
                setActive("realtime");
                setLoading(true);
                realtimeFunction();
                setLoading(false);
              }}
            >
              Now
            </button>
            <button>
              <Dropdown
                options={options}
                onChange={(selectedOption) =>
                  selectOption(selectedOption, chartData.obj)
                }
                placeholder="Select algorithm"
              />
            </button>
          </div>
          {loading ? (
            <div className="loading">
              <ReactLoading
                type={"spin"}
                color={"#141cc4"}
                height={100}
                width={100}
              />
            </div>
          ) : (
            <>
              {checkPredict === false ? (
                <HighchartsReact highcharts={Highcharts} options={realChart} />
              ) : (
                <HighchartsReact
                  highcharts={Highcharts}
                  options={predictChart}
                />
              )}
            </>
          )}
        </div>
      </div>
    </>
  );
};

export default HumiChart;
