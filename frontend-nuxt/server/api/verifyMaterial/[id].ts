import type { VerifyError } from "~/types/verifyError";
import { FetchError } from "ofetch";

export default defineEventHandler(async (event) => {
  const runtimeConfig = useRuntimeConfig();
  const { id } = event.context.params as { id: string };
  console.log(`baseurl`, runtimeConfig.apiBase);
  const errorCodes = [
    { code: "NOT_FOUND", httpcode: 404 },
    { code: "FORBIDDEN", httpcode: 403 },
    { code: "UNAUTHORIZED", httpcode: 401 },
    { code: "INVALID_DATA", httpcode: 400 },
    { code: "SERVER_ERROR", httpcode: 500 },
  ];
  try {
    const response = await $fetch(
      `${runtimeConfig.apiBase}/biblios/${id}?items_on_subscriptions=true`,
    );
    if (response) {
      return "success";
    }
  } catch (error: FetchError | any) {
    let customError: VerifyError | null = null;
    switch (error.response.status) {
      case 404:
        customError = {
          code: "NOT_FOUND",
          detail: `Item not found: ${id}`,
          data: null,
          errors: [
            {
              code: "ITEM_NOT_FOUND",
              detail: "The requested biblio record could not be found.",
            },
          ],
        };
        break;
      case 403:
        customError = {
          code: "FORBIDDEN",
          detail: `Item not allowed for loan: ${id}`,
          data: null,
          errors: [
            {
              code: "CAN_NOT_BE_BORROWED",
              detail: "This item is not allowed for loan.",
            },
          ],
        };
        break;
      case 401:
        customError = {
          code: "UNAUTHORIZED",
          detail: "Unauthorized access",
          data: null,
          errors: [
            {
              code: "UNAUTHORIZED",
              detail: "You are not authorized to access this resource.",
            },
          ],
        };
        break;
      case 400:
        customError = {
          code: "INVALID_DATA",
          detail: "Invalid request data",
          data: null,
          errors: [
            {
              code: "INVALID_ID",
              detail: `The provided ID is invalid: ${id}`,
            },
          ],
        };
        break;
      case 500:
        customError = {
          code: "SERVER_ERROR",
          detail: "Internal server error",
          data: null,
          errors: [
            {
              code: "INTERNAL_SERVER_ERROR",
              detail: "An internal server error occurred.",
            },
          ],
        };
        break;
      default:
        customError = {
          code: "SERVER_ERROR",
          detail: "An unexpected error occurred",
          data: null,
          errors: [{ code: "UNKNOWN_ERROR", detail: error.value.message }],
        };
    }
    if (customError) {
      throw createError({
        statusCode:
          errorCodes.find((e) => e.code === customError?.code)?.httpcode || 500,
        statusMessage: customError.detail,
        data: customError,
      });
    }
  }
});
