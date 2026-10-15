export const useErrorCodes = () => {
  const errorCodes = [
    { code: "NOT_FOUND", httpcode: 404 },
    { code: "FORBIDDEN", httpcode: 403 },
    { code: "UNAUTHORIZED", httpcode: 401 },
    { code: "INVALID_DATA", httpcode: 400 },
    { code: "SERVER_ERROR", httpcode: 500 },
  ];

  return errorCodes;
};
