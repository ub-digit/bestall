import type { Biblio } from "./Biblio";

type OrderSuccessResponse = {
  showQueuePosition: boolean;
  showPickupLocation: boolean;
  showMyLoansLink: boolean;
  positionInQueue: string | null;
  pickupLocation_en: string | null;
  pickupLocation_sv: string | null;
  pickupLocation?: string | null;
  item_referenced: boolean;
};

type Order = {
  location: string | null;
  loanType: string | null;
  biblio: string;
  fullBiblio: Biblio | null;
  item: string;
  current_item_extended: any | null;
  reserveNotes: string;
  subscription: string;
  subscriptionNotes: string;
};

export type { Order, OrderSuccessResponse };
