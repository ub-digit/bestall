export default defineEventHandler(async (event) => {
  const contactRequest = await readBody(event);
  console.log("Contact request received:", contactRequest);
  // check for empty values here and make it safe
  if (
    !contactRequest.firstName ||
    !contactRequest.lastName ||
    !contactRequest.email ||
    !contactRequest.message
  ) {
    throw createError({
      statusCode: 400,
      statusMessage: "Name, email, and message are required",
    });
  }
  if (!contactRequest) {
    throw createError({
      statusCode: 400,
      statusMessage: "Request body is required",
    });
  }

  console.log("Contact request received:", contactRequest);
  await new Promise((resolve) => setTimeout(resolve, 1000));

  return {
    data: contactRequest,
    statusCode: 200,
    message: "Contact request received successfully",
  };
});
