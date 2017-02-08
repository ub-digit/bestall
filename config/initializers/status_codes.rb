# Contains high level repsonse codes
module ResponseCodes
  SUCCESS = 0
  FAIL = -1
end

# Contains error codes and their http response codes
module ErrorCodes
  # Generic error code
  ERROR = {
    http_status: 400,
    code: "ERROR"
  }

  # Used for authentication errors (i.e. needs to be logged in)
  AUTH_ERROR = {
    http_status: 401,
    code: "AUTH_ERROR"
  }

  # Used for authentication errors (i.e. needs specific rights)
  PERMISSION_ERROR = {
    http_status: 403,
    code: "PERMISSION_ERROR"
  }

  # Used for session validation errors
  SESSION_ERROR = {
    http_status: 401,
    code: "SESSION_ERROR"
  }

  # Used when data cannot be retrieved (i.e. error in request or database)
  DATA_ACCESS_ERROR = {
    http_status: 404,
    code: "DATA_ACCESS_ERROR"
  }

  # Generic object error
  OBJECT_ERROR = {
    http_status: 404,
    code: "OBJECT_ERROR"
  }

  # Used when requested data could not be returned
  REQUEST_ERROR = {
    http_status: 404,
    code: "REQUEST_ERROR"
  }

  # Used when object validation fails
  VALIDATION_ERROR = {
    http_status: 422,
    code: "VALIDATION_ERROR"
  }
end
