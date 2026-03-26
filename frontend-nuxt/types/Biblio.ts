export interface Item {
  biblio_id: string;
  has_item_level_queue: boolean;
  is_reserved: boolean;
  id: string;
  sublocation_id: string;
  item_type: string;
  barcode: string;
  item_call_number: string;
  lost: string;
  restricted?: string;
  not_for_loan: string;
  copy_number?: string;
  withdrawn: string;
  due_date?: string;
  in_transit: string;
  currentlocation_id: string;
  sublocation_open_loc: boolean;
  sublocation_paging_loc: boolean;
  sublocation_pickup_loc: boolean;
  sublocation_name_sv: string;
  sublocation_name_en: string;
  location_id: string;
  location_name_sv: string;
  location_name_en: string;
  can_be_ordered: boolean;
  can_be_queued: boolean;
  status: string;
  status_limitation?: string;
  is_availible: boolean;
  location_name?: string;
  sublocation_name?: string;
}

export interface SubscriptionGroup {
  biblio_id: string;
  id: string;
  location_name_sv: string;
  location_name_en: string;
  location_name?: string;
  location_id: string;
  short_info: string[];
  subscriptions: Subscription[];
}

export interface Subscription {
  id: string;
  biblio_id: string;
  can_be_ordered: boolean;
  sublocation_id: string;
  call_number: string;
  public_note: string;
  location_id: string;
  subscriptiongroup_id: string;
  sublocation_name_sv: string;
  sublocation_name_en: string;
  sublocation_name?: string;
  location_name_sv: string;
  location_name_en: string;
  location_name?: string;
}

export interface Biblio {
  id: string;
  subscriptiongroups: SubscriptionGroup[];
  record_type: string;
  title: string;
  origin: null;
  isbn: string;
  edition: string;
  has_enum: null;
  biblio_call_number: null;
  items: Item[];
  no_in_queue: number;
  default_queue_location: string;
  can_be_queued: boolean;
  has_item_level_queue: boolean;
  has_available_kursbok: boolean;
  viewType: string;
  itemsAvailable: Item[];
  itemsNotAvailable: Item[];
}
