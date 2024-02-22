import { getDataOfCO2HCM, getDataOfCO2TD } from "../apis/callAPI";
import { formatInputStartDate, formatInputEndDate } from "../utils/utilDay";

export const fetchDataCO2HCM = async () => {
  const result = await getDataOfCO2HCM(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};

export const fetchDataCO2ThuDuc = async () => {
  const result = await getDataOfCO2TD(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};