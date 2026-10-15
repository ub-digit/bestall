import type { VerifyError } from "#shared/types/verifyError";
import { FetchError } from "ofetch";

export default defineEventHandler(async (event) => {
  const { id } = event.context.params as { id: string };
  try {
    const response = await $fetch(
      `${useRuntimeConfig().apiBase}/biblios/${id}?items_on_subscriptions=false`,
    );
    if (response) {
      console.log("Response received:", response);
      return "success";
    }
  } catch (error: FetchError | any) {
    // Source - https://stackoverflow.com/a/71299614
    // Posted by trincot, modified by community. See post 'Timeline' for change history
    // Retrieved 2026-09-15, License - CC BY-SA 4.0

    console.log(Object.getOwnPropertyNames(error));

    throw createError({
      statusCode: error?.statusCode || 500,
      status: error?.status || "Unknown status",
      data: error.data,
      statusMessage: error?.statusMessage || "Unknown statusMessage",
    });
  }
});
