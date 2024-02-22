import React, { useEffect, useState, useContext } from "react";
import "./tempChart.css";
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
import { fetchDataTempHCM, fetch100DataOfTempHCM, fetchDataTempThuDuc } from "../../../data/dataTemp";
import {
  predictTempWithGB,
  predictTempWithLR,
  predictTempWithLSTM,
  predictTempWithProphet,
  predictTempWithProphetLSTM,
  predictTempWithRF,
  predictTempWithXGB,
} from "../../../apis/callModelAPI";
import { getNewestDataHCM, get100DataOfTempHCM } from "../../../apis/callAPI";
// import { ModelResultContext } from "../../../contexts/ModelResultContext";

const TempChart = () => {
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
  const [dataTemp, setDataTemp] = useState({
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
      text: `Historical data of Temperature on ${formatDate(currentDate)}`,
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
        text: "Temperature (°C)",
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
      text: `Forecasted data of Temperature for next hour with 5-intervals on ${formatDate(
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
        text: "Temperature (°C)",
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
      // {
      //   type: "line",
      //   name: "Thu Duc City",
      //   data: chartDataThuDuc.seriesData,
      // },
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
      case "Prophet-LSTM":
        setLoading(true);
        try {
          await predictTempWithProphetLSTM(chartData.obj).then((result) => {
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
      case "Prophet":
        setLoading(true);
        try {
          await predictTempWithProphet(chartData.obj).then((result) => {
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
          await predictTempWithLSTM(chartData.obj).then((result) => {
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
          await predictTempWithGB(chartData.obj).then((result) => {
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
          await predictTempWithXGB(chartData.obj).then((result) => {
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
          await predictTempWithRF(chartData.obj).then((result) => {
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
          await predictTempWithLR(chartData.obj).then((result) => {
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
    fetchDataTempHCM().then(async (result) => {
      const data = result.data.feeds.map((item) => parseFloat(item.field1));
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
        objFormat.value.push(entry.field1);
      });

      setChartData({
        seriesData: data,
        timeData: time,
        obj: objFormat,
        timeDataPredict: timeDataPredictArr,
      });
    });

    fetchDataTempThuDuc().then((result) => {
      const data = result.data.feeds.map((item) => parseFloat(item.field1));
      const time = result.data.feeds.map((item) => {
        const date = new Date(item.created_at);
        const bangkokTime = convertToBangkokTime(date);
        return `${bangkokTime.hour}:${bangkokTime.minute} ${bangkokTime.amPm}`;
      });
      setChartDataThuDuc({ seriesData: data, timeData: time });
    });

    setInterval(fetchDataTempHCM, 5 * 60 * 1000);
  }, []);

  useEffect(() => {
    fetch100DataOfTempHCM().then((result) => {
      let objFormat = {
        time: [],
        value: [],
      };

      result.data.feeds.forEach((entry) => {
        const date = new Date(entry.created_at);
        const formattedTime = formattedTimeToModel(date);
        objFormat.time.push(formattedTime);
        objFormat.value.push(entry.field1);
      });

      setDataTemp({
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

export default TempChart;
