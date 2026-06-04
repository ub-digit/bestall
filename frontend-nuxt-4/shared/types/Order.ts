import type { Biblio } from "./Biblio";

type OrderSuccessResponse = {
  showQueuePosition: boolean;
  showPickupLocation: boolean;
  showMyLoansLink: boolean;
  showRequiredPickupCode: boolean;
  positionInQueue: string;
  pickupLocation_en: string;
  pickupLocation_sv: string;
  pickupLocation: string;
};

type Order = {
  user: string;
  location: string | null;
  loanType: number | null;
  biblio: string;
  fullBiblio: Biblio | null;
  item: string;
  reserveNotes: string;
  queuePosition: string;
  isReservedClicked: boolean;
  subscription: string;
  subscriptionNotes: string;
  subscriptionLocation: string;
  subscriptionSublocationId: string;
  subscriptionSublocation: string;
  subscriptionCallNumber: string;
  orderSuccessResponse?: OrderSuccessResponse | null;
};

export type { Order };
