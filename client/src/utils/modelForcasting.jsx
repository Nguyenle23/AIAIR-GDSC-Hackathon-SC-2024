// import { fetchDataTempHCM } from "../data/dataTemp";
// import { predictTempWithGB,  } from "../apis/callModelAPI";
// import { convertToBangkokTime } from "./utilDay";
// import { predictTempWithProphet } from "../apis/callModelAPI";

// export const predictProphetFunc = async (data) => {
//   return predictTempWithProphet(data).then((result) => {
//     return result.data.forecast;
//   });
// }

// export const predictGBFunction = async () => {
//   return fetchDataTempHCM().then(async (result) => {
//     console.log(result)
//     const data = result.data.feeds.map((item) => parseFloat(item.field1));

//     const time = [
//       ...result.data.feeds.map((item) => {
//         return item.created_at;
//       }),
//     ];

//     const dataTemp = await predictTempWithGB(time);
//     const resultPredict = dataTemp.data;

//     const formatTime = result.data.feeds.map((item) => {
//       const date = new Date(item.created_at);

//       const resultBangkokTime = convertToBangkokTime(date);

//       return `${resultBangkokTime.hour}:${resultBangkokTime.minute} ${resultBangkokTime.amPm}`;
//     });

//     //next hour based on time of last data point
//     const lastDataPointTime = new Date(
//       result.data.feeds[result.data.feeds.length - 1].created_at
//     );

//     const options = {
//       timeZone: "Asia/Bangkok",
//       hour: "2-digit",
//       minute: "2-digit",
//       hour12: false,
//     };

//     const formatter = new Intl.DateTimeFormat("en-US", options);
//     const bangkokTime = formatter.format(lastDataPointTime);

//     const hour = parseInt(bangkokTime.split(":")[0], 10);
//     const nextHour = new Date(lastDataPointTime);
//     nextHour.setHours(hour + 1);

//     // Convert to 12-hour format with AM/PM notation
//     let adjustedHour = nextHour.getHours() % 12;
//     adjustedHour = adjustedHour === 0 ? 12 : adjustedHour; // Handle 12 AM

//     const amPm = nextHour.getHours() < 12 ? "AM" : "PM"; // Determine AM or PM

//     formatTime.push(`${adjustedHour}:${bangkokTime.slice(3)} ${amPm}`);

//     // setCheckPredict(true);
//     // setPredictData({
//     //   timeData: formatTime,
//     //   seriesData: data.concat(resultPredict),
//     // });

//     return {
//       timeData: formatTime,
//       seriesData: data.concat(resultPredict)
//     }
//   });
// };
