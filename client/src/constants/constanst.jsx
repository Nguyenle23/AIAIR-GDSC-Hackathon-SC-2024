export const currentDate = new Date();

export const previousDate = new Date(
  currentDate.getFullYear(),
  currentDate.getMonth(),
  currentDate.getDate() - 1
);