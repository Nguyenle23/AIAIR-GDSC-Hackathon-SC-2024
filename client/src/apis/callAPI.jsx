import axios from "axios";

const timezone = "Asia%2FBangkok";

const apiKey = "99d40475f251003865b51c383d6fda8d"

const oldChannelID = "2115707";

const channelIDThuDuc = "2239030";

const newChannelIDHCM = "2404698";

export const getNewestDataHCM = async () => {
  const response = await axios.get(
    "https://api.thingspeak.com/channels/" + newChannelIDHCM + "/feeds.json?results=1"
  );
  return response.data;
};

export const getNewestDataThuDuc = async () => {
  const response = await axios.get(
    "https://api.thingspeak.com/channels/" + channelIDThuDuc + "/feeds.json?results=1"
  );
  return response.data;
};

//------------Wind----------------
export const getWindHCM = async () => {
  const response = await axios.get(
    "https://api.openweathermap.org/data/2.5/weather?lat=10.7936588867&lon=106.6803109431&appid=" + apiKey
  );
  return response.data;
};

export const getWindThuDuc = async () => {
  const response = await axios.get(
    "https://api.openweathermap.org/data/2.5/weather?lat=10.8619784&lon=106.8034464&appid=" + apiKey
  );
  return response.data;
};

//------------Temperature----------------
export const getDataOfTempHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/1.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const get100DataOfTempHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/1.json?timezone=Asia%2FBangkok&results=288&start=${start}&end=${end}`
    // `https://api.thingspeak.com/channels/2115707/fields/1.json?timezone=${timezone}&results=100`
  );
  return response;
};

export const getDataOfTempThuDuc = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/1.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

//------------Humidity----------------
export const getDataOfHumiHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/2.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const get100DataOfHumiHCM = async (start, end) => {
  const response = await axios.get(
    // `https://api.thingspeak.com/channels/2115707/fields/2.json?timezone=${timezone}&results=100`
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/2.json?timezone=Asia%2FBangkok&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const getDataOfHumiThuDuc = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/2.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

//------------CO2----------------
export const getDataOfCO2HCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/3.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const get100DataOfCO2HCM = async () => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/3.json?timezone=${timezone}&results=100`
  );
  return response;
};

export const getDataOfCO2TD = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/3.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

//------------CO----------------
export const getDataOfCOHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/4.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const get100DataOfCOHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/4.json?timezone=${timezone}&results=100`
  );
  return response;
};

//------------UV----------------
export const getDataOfUVHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/5.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const get100DataOfUVHCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/5.json?timezone=${timezone}&results=100`
  );
  return response;
};

//------------PM2.5----------------
export const getDataOfPM25HCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/6.json?timezone=${timezone}&results=288&start=${start}&end=${end}`
  );
  return response;
};

export const get100DataOfPM25HCM = async (start, end) => {
  const response = await axios.get(
    `https://api.thingspeak.com/channels/${newChannelIDHCM}/fields/6.json?timezone=${timezone}&results=100`
  );
  return response;
};