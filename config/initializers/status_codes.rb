# Contains high level repsonse codes
module ResponseCodes
  SUCCESS = 0
  FAIL = -1
end

# Contains http statuses and their codes
module ErrorCodes
  
  # Used when something is wrong with the request
  BAD_REQUEST = {
    status: 400,
    code: "BAD_REQUEST"
  }

  UNAUTHORIZED = {
    status: 401,
    code: "UNAUTHORIZED"
  }

  # Used for authentication errors (i.e. needs specific rights)
  FORBIDDEN = {
    status: 403,
    code: "FORBIDDEN"
  }

  NOT_FOUND = {
    status: 404,
    code: "NOT_FOUND"
  }

  # Used when object validation fails
  UNPROCESSABLE_ENTITY = {
    status: 422,
    code: "UNPROCESSABLE_ENTITY"
  }

  # Used when we get a server error
  INTERNAL_SERVER_ERROR = {
    status: 500,
    code: "INTERNAL_SERVER_ERROR"
  }
end
