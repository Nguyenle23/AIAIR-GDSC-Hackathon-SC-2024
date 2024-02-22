import { get100DataOfTempHCM, getDataOfTempHCM, getDataOfTempThuDuc } from "../apis/callAPI";
import { formatInputStartDate, formatInputEndDate, formatInputStartPrevDate, formatInputEndPrevDate } from "../utils/utilDay";

export const fetchDataTempHCM = async () => {
  const result = await getDataOfTempHCM(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};

export const fetchDataTempThuDuc = async () => {
  const result = await getDataOfTempThuDuc(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};

export const fetch100DataOfTempHCM = async () => {
  const result = await get100DataOfTempHCM(
    formatInputStartPrevDate,
    formatInputEndPrevDate
  );
  return result;
}