import { getDataOfPM25HCM } from "../apis/callAPI";
import { formatInputStartDate, formatInputEndDate } from "../utils/utilDay";

export const fetchDataPM25HCM = async () => {
  const result = await getDataOfPM25HCM(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};