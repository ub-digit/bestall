import type { Location } from "~/types/Location";
export default defineEventHandler(async (event) => {
  let { locale } = getQuery(event) as { locale?: string };

  if (!locale) {
    locale = "sv"; // if missing add default locale
  }

  console.log(`Fetching locations with locale param: ${locale}`);

  const runtimeConfig = useRuntimeConfig();
  const data: any = await $fetch(`${runtimeConfig.public.apiBase}/locations`);

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
