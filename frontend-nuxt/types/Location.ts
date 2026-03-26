export type { Location };

type Location = {
  id: string;
  location_id: string;
  name_sv: string;
  name_en: string;
  name: string;
  is_open_loc: string;
  is_paging_loc: string;
  is_open_pickup_loc: string;
  is_kursbok_loc: string;
  sublocations: Location[]; // Recursive type to allow for nested sublocations
  categories: string[]; // e.g. ["PICKUP", "OPEN"]
  disabled?: boolean; // to indicate if the location should be disabled in the UI based on the current order and configuration
};
