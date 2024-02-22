import { currentDate, previousDate } from "../constants/constanst";

export const formatDate = (date) => {
  let day = date.getDate();
  let month = date.getMonth() + 1;
  let year = date.getFullYear();

  //get the date of the week
  let dayOfWeek = date.getDay();
  let dayOfWeekName = "";
  switch (dayOfWeek) {
    case 0:
      dayOfWeekName = "Sunday";
      break;
    case 1:
      dayOfWeekName = "Monday";
      break;
    case 2:
      dayOfWeekName = "Tuesday";
      break;
    case 3:
      dayOfWeekName = "Wednesday";
      break;
    case 4:
      dayOfWeekName = "Thursday";
      break;
    case 5:
      dayOfWeekName = "Friday";
      break;
    case 6:
      dayOfWeekName = "Saturday";
      break;
  }

  if (day < 10) day = `0${day}`;
  if (month < 10) month = `0${month}`;

  return `${dayOfWeekName}, ${day}-${month}-${year}`;
};

export const getAmPm = (hour) => {
  return hour >= 12 ? "PM" : "AM";
};

export const convertToBangkokTime = (dateInput) => {
  const options = {
    timeZone: "Asia/Bangkok",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  };

  const date = new Date(dateInput);
  const formatter = new Intl.DateTimeFormat("en-US", options);
  const bangkokTime = formatter.format(date);
  const hour = parseInt(bangkokTime.split(":")[0], 10);

  const adjustedHour = hour % 12 === 0 ? 12 : hour % 12;
  const amPm = getAmPm(hour); // Assuming getAmPm function is available elsewhere

  return {
    hour: adjustedHour,
    minute: bangkokTime.slice(3),
    amPm: amPm,
  };
};

export const formatInputStartDate = `${currentDate.getUTCFullYear()}-${String(
  currentDate.getUTCMonth() + 1
).padStart(2, "0")}-${String(currentDate.getUTCDate()).padStart(
  2,
  "0"
)}%2000:00:00`;

export const formatInputEndDate = `${currentDate.getUTCFullYear()}-${String(
  currentDate.getUTCMonth() + 1
).padStart(2, "0")}-${String(currentDate.getUTCDate()).padStart(
  2,
  "0"
)}%2023:59:00`;

export const formattedTimeToModel = (dateInput) => {
  return `${dateInput.getFullYear()}-${(dateInput.getMonth() + 1)
    .toString()
    .padStart(2, "0")}-${dateInput
    .getDate()
    .toString()
    .padStart(
      2,
      "0"
    )} ${dateInput.getHours()}:${dateInput.getMinutes()}:${dateInput.getSeconds()}`;
};

export const formatInputStartPrevDate = `${previousDate
  .getUTCFullYear()
  .toString()}-${String(previousDate.getUTCMonth() + 1).padStart(
  2,
  "0"
)}-${String(previousDate.getUTCDate() + 1).padStart(2, "0")}%2008:00:00`;

export const formatInputEndPrevDate = `${previousDate
  .getUTCFullYear()
  .toString()}-${String(previousDate.getUTCMonth() + 1).padStart(
  2,
  "0"
)}-${String(previousDate.getUTCDate() + 1).padStart(2, "0")}%2016:00:00`;
