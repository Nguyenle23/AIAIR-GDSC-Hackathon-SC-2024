import { get100DataOfHumiHCM, getDataOfHumiHCM, getDataOfHumiThuDuc } from "../apis/callAPI";
import { formatInputStartDate, formatInputEndDate, formatInputStartPrevDate, formatInputEndPrevDate } from "../utils/utilDay";

export const fetchDataHumiHCM = async () => {
  const result = await getDataOfHumiHCM(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};

export const fetchDataHumiThuDuc = async () => {
  const result = await getDataOfHumiThuDuc(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};

export const fetch100DataOfHumiHCM = async () => {
  const result = await get100DataOfHumiHCM(
    formatInputStartPrevDate,
    formatInputEndPrevDate
  );
  return result;
};