import type { Biblio } from "./Biblio";

type OrderSuccessResponse = {
  showQueuePosition: boolean;
  showPickupLocation: boolean;
  showMyLoansLink: boolean;
  positionInQueue: string | null;
  pickupLocation_en: string | null;
  pickupLocation_sv: string | null;
  pickupLocation?: string | null;
};

type Order = {
  location: string | null;
  loanType: string | null;
  biblio: string;
  fullBiblio: Biblio | null;
  item: string;
  reserveNotes: string;
  subscription: string;
  subscriptionNotes: string;
};

export type { Order, OrderSuccessResponse };
