export const parseBoolean = (value: string) => {
  if (value === null || value === undefined || value === "undefined") {
    return false;
  }

  switch (value.toLowerCase().trim()) {
    case "true":
    case "1":
      return true;

    case "false":
    case "0":
      return false;
    default:
      return Boolean(value);
  }
};
