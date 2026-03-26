type EventPayload = {
  biblioId: string;
  itemId?: string;
  subscriptionId?: string;
  subscriptionLocation?: string;
  subscriptionSublocationId?: string;
  subscriptionSublocation?: string;
  subscriptionCallNumber?: string;

  typeOfEvent: "joinQueue" | "order" | "subscriptionOrder";
};

export type { EventPayload };
