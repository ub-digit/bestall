import type { Location } from "#shared/types/Location";
import { getServerSession } from "#auth";
import { Item } from "~~/shared/types/Biblio";

export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    throw createError({ statusCode: 401, statusMessage: "Unauthorized" });
  }
  let { locale, current_item, record_type, current_subscription } = getQuery(
    event,
  ) as {
    locale?: string;
    current_item?: Item;
    record_type?: string;
    current_subscription?: Subscription;
  };

  if (!locale) {
    locale = "sv"; // if missing add default locale
  }

  console.log(`Fetching locations with locale param: ${locale}`);

  const userParsed = session.user; // Use the user data from the session, which is more secure and reliable than the one passed as a query parameter. The query parameter is only used as a fallback if the session user data is not available for some reason.
  console.log("User fetched from session on server:", userParsed);
  const runtimeConfig = useRuntimeConfig();
  const data: any = await $fetch(`${runtimeConfig.apiBase}/locations`, {
    method: "POST", // Use POST method to send user data in the request body, which is more secure than sending it as query parameters
    body: {
      current_user: userParsed, // Pass the entire user object from the session to the API for potential user-specific filtering. This is more secure and reliable than passing user data through query parameters.
      current_item: current_item ? JSON.parse(current_item) : null, // Pass current item-type for potential item-specific filtering in the API
      current_subscription: current_subscription
        ? JSON.parse(current_subscription)
        : null, // Pass current subscription-type for potential subscription-specific filtering in the API
      record_type: record_type || null, // Pass record type for potential item-specific filtering in the API
    },
    headers: {
      current_username: userParsed?.cardnumber || "", // Pass the username from the session to the API for potential user-specific filtering
    },
  });

  // Extend the original locations with localized names based on the locale query parameter
  const extendedLocations = data.locations.map((location: Location) => ({
    ...location,
    name: locale === "en" ? location.name_en : location.name_sv,
    sublocations: location.sublocations.map((sublocation: Location) => ({
      ...sublocation,
      name: locale === "en" ? sublocation.name_en : sublocation.name_sv,
    })),
  }));

  try {
    return extendedLocations;
  } catch (error) {
    console.error("Error returning locations:", error);
    return error;
  } finally {
    console.log("Seeding completed.");
  }
});
