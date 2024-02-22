import { getDataOfCOHCM } from "../apis/callAPI";
import { formatInputStartDate, formatInputEndDate } from "../utils/utilDay";

export const fetchDataCOHCM = async () => {
  const result = await getDataOfCOHCM(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};