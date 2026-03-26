import { Biblio } from "~/types/Biblio";
import { Item } from "~/types/Biblio";
import { SubscriptionGroup } from "~/types/Biblio";
import { Subscription } from "~/types/Biblio";
export default defineEventHandler(async (event) => {
  const runtimeConfig = useRuntimeConfig();

  const { id } = event.context.params as { id: string };
  let { locale } = getQuery(event) as { locale?: string };

  if (!locale) {
    locale = "sv"; // if missing add default locale
  }

  console.log(`Fetching biblio with ID: ${id} for locale: ${locale}`);

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
        `${runtimeConfig.public.apiBase}/biblios/${id}?items_on_subscriptions=true`,
      );
      return transformBiblio(data?.biblio);
    }

    throw createError({
      status: 404,
      statusText: `Item not found: ${id}`,
    });
  } catch (error: any) {
    throw error;
  }
});
