import React, { useEffect, useState } from "react";
import tempIcon from "../../assets/temp-icon.png";
import humiIcon from "../../assets/humi-icon.png";
import co2Icon from "../../assets/co2-icon.png";
import coIcon from "../../assets/co-icon.png";
import dustIcon from "../../assets/dust-icon.png";
import uvIcon from "../../assets/uv-icon.png";
import locationMark from "../../assets/location.png";
import { getNewestDataHCM, getNewestDataThuDuc } from "../../apis/callAPI";

import "./HeaderHCM.css";
import { convertToBangkokTime } from "../../utils/utilDay";

const HeaderHCM = () => {
  const [dataHCM, setDataHCM] = useState([]);
  const [timeHCM, setTimeHCM] = useState("");
  const keyData = [
    {
      index: "1",
      icon: tempIcon,
      title: "Temperature",
      field: "field1",
      level: "°C",
      width: "4rem",
      height: "4rem",
    },
    {
      index: "2",
      icon: humiIcon,
      title: "Humidity",
      field: "field2",
      level: "%",
      width: "4rem",
      height: "4rem",
    },
    {
      index: "3",
      icon: co2Icon,
      title: "MQ135",
      field: "field3",
      level: "PPM",
      width: "5rem",
      height: "5.5rem",
    },
    {
      index: "4",
      icon: coIcon,
      title: "MQ7",
      field: "field4",
      level: "PPM",
      width: "4rem",
      height: "4rem",
    },
    {
      index: "5",
      icon: uvIcon,
      title: "UV Index",
      field: "field6",
      level: "",
      width: "4.5rem",
      height: "4.5rem",
    },
    {
      index: "6",
      icon: dustIcon,
      title: "PM2.5",
      field: "field5",
      level: "µg m3",
      width: "4.5rem",
      height: "4.5rem",
    },
  ];

  useEffect(() => {
    const getData = async () => {
      const data = await getNewestDataHCM();
      var getFeeds = data.feeds;
      setDataHCM(getFeeds);
      setTimeHCM(getFeeds[0].created_at);
    };
    getData();
  }, []);

  return (
    <div className="header">
      <div className="location">
        <img className="location-icon" src={locationMark} alt="icon" />
        <h3 className="location-text">
          {timeHCM ? convertToBangkokTime(timeHCM).hour + ":" + convertToBangkokTime(timeHCM).minute + " " + convertToBangkokTime(timeHCM).amPm + " | ": "Loading..."}
          Phu Nhuan District, Ho Chi Minh City
        </h3>
      </div>
      <div className="header-container">
        <ul className="figure-list">
          {keyData.map((data) => (
            <li key={data.index} className="list-item">
              <img className="icon" src={data.icon} alt="icon" />
              <div className="list-item-detail">
                <h4 className="list-item-title">{data.title}</h4>
                <span className="list-item-number">
                  <span>
                    {dataHCM[0]
                      ? Math.round(dataHCM[0][data.field] * 1000) / 1000
                      : "Loading..."}
                  </span>
                  <span className="list-item-level">{data.level}</span>
                </span>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default HeaderHCM;
