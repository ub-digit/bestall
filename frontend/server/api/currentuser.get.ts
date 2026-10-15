import { getServerSession } from "#auth";
import { FetchError } from "ofetch";

export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    throw createError({ statusCode: 401, statusMessage: "Unauthorized" });
  }
  let { biblio, current_username } = getQuery(event) as {
    biblio?: string;
    current_username?: string;
  };

  const runtimeConfig = useRuntimeConfig();

  try {
    const response: any = await $fetch(
      `${runtimeConfig.apiBase}/users/current?biblio=${biblio}`,
      {
        method: "GET",
        headers: {
          "current-username": current_username || "",
        },
      },
    );
    return response;
  } catch (error: FetchError | any) {
    const msg = error.data?.errors?.errors || "Unknown error";
    console.error("Error fetching current user data:", msg);
    throw createError({
      statusCode: error.status || 500,
      statusMessage: error.statusText || "Internal Server Error",
      data: msg,
    });
  }
});
