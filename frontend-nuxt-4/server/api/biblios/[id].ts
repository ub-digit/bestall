import { Biblio } from "#shared/types/Biblio";
import { Item } from "#shared/types/Biblio";
import { SubscriptionGroup } from "#shared/types/Biblio";
import { Subscription } from "#shared/types/Biblio";
import { getServerSession } from "#auth";
import { useErrorCodes } from "~/composables/useErrorCodes";

import type { VerifyError } from "#shared/types/verifyError";
import { FetchError } from "ofetch";

export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    throw createError({ statusCode: 401, statusMessage: "Unauthorized" });
  }
  const runtimeConfig = useRuntimeConfig();
  const { id } = event.context.params as { id: string };
  let { locale } = getQuery(event) as { locale?: string };

  if (!locale) {
    locale = "sv"; // if missing add default locale
  }

  const userParsed = session.user;
  console.log(
    `Fetching biblio with ID: ${id} for locale: ${locale} by user: ${userParsed?.cardnumber || "unknown"}`,
  );

  const getSublocationName = (biblio: Biblio, item: Item, locale: string) => {
    // get current sublocation_name based on locale
    let sublocation_name =
      locale === "en" ? item.sublocation_name_en : item.sublocation_name_sv;

    // extend sublocation_name.
    if (item.sublocation_open_loc) {
      if (item.item_call_number) {
        return (sublocation_name += ", " + item.item_call_number);
      } else if (biblio.biblio_call_number) {
        return (sublocation_name += ", " + biblio.biblio_call_number);
      } else {
        return sublocation_name; // if no call number is available, return the original sublocation name
      }
    }
    return null; // change to "needs to be ordered" on client using i18n
  };

  const transformBiblio = (biblio: Biblio) => {
    /* add location_name and sublocation_name based on locale to each item. Makes frontend easier to display localized names  based on current locale*/
    const allOriginalItems = biblio.items || [];
    const allExtendedItems = allOriginalItems.map((item: Item) => ({
      ...item,
      location_name:
        locale === "en" ? item.location_name_en : item.location_name_sv,
      sublocation_name: getSublocationName(biblio, item, locale),
    }));

    if (!biblio.subscriptiongroups?.length && !biblio.has_item_level_queue) {
      const extendedBiblio = {
        ...biblio,
        viewType: "book",
        itemsAvailable: allExtendedItems.filter(
          (item: any) => item.is_availible,
        ),
        itemsNotAvailable: allExtendedItems.filter(
          (item: any) => !item.is_availible,
        ),
      };
      return extendedBiblio;
    } else if (
      biblio.subscriptiongroups?.length ||
      biblio.has_item_level_queue
    ) {
      const extendedBiblio = {
        ...biblio,
        subscriptiongroups: biblio.subscriptiongroups.map(
          (group: SubscriptionGroup) => ({
            ...group,
            location_name:
              locale === "en" ? group.location_name_en : group.location_name_sv,
            subscriptions: group.subscriptions.map(
              (subscription: Subscription) => ({
                ...subscription,
                location_name:
                  locale === "en"
                    ? subscription.location_name_en
                    : subscription.location_name_sv,
                sublocation_name:
                  locale === "en"
                    ? subscription.sublocation_name_en
                    : subscription.sublocation_name_sv,
              }),
            ),
          }),
        ),
      };
      return {
        ...extendedBiblio,
        viewType: "subscription",
      };
    } else if (
      !biblio.subscriptiongroups?.length &&
      biblio.has_item_level_queue
    ) {
      return {
        ...biblio,
        viewType: "collection",
      };
    }
  };

  try {
    if (id) {
      const data: any = await $fetch(
        `${runtimeConfig.apiBase}/biblios/${id}?items_on_subscriptions=true`,
        // Note: make to post and send biblio_id and user data
        {
          method: "GET",
          /*body: {
            current_user: userParsed, // Pass the entire user object from the session to the API for potential user-specific filtering. This is more secure and reliable than passing user data through query parameters.
          },*/
          headers: {
            current_username: userParsed?.cardnumber || "", // Pass the username from the session to the API for potential user-specific filtering
          },
        },
      );
      return transformBiblio(data?.biblio);
    }
  } catch (error: FetchError | any) {
    const errorCodes = useErrorCodes();
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
