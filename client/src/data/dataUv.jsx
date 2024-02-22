import { getDataOfUVHCM } from "../apis/callAPI";
import { formatInputStartDate, formatInputEndDate } from "../utils/utilDay";

export const fetchDataUVHCM = async () => {
  const result = await getDataOfUVHCM(
    formatInputStartDate,
    formatInputEndDate
  );
  return result;
};