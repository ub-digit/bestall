import type { Biblio } from "./Biblio";

type Order = {
  user: string;
  location: string | null;
  loanType: number | null;
  biblio: string;
  fullBiblio: Biblio | null; // TODO: Define a proper type for this
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
};

export type { Order };
