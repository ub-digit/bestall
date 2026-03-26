import type { Order } from "~/types/Order";

export const useOrder = () => {
  const emptyOrder: Order = {
    user: "",
    location: "",
    loanType: null,
    biblio: "",
    fullBiblio: null, // to avoid having to pickup biblio data from API during order creation.
    item: "",
    subscription: "",
    reserveNotes: "",
    queuePosition: "",
    isReservedClicked: false,
    subscriptionNotes: "",
    subscriptionLocation: "",
    subscriptionSublocationId: "",
    subscriptionSublocation: "",
    subscriptionCallNumber: "",
  };

  const order = useState<Order>("order", () => ({}) as Order);
  //  Object.assign(order.value, emptyOrder);
  /**
   * Updates the order state with the provided partial data.
   * @param data - Partial order object containing the properties to update
   */
  const setOrder = (data: Partial<Order>) => {
    Object.assign(order.value, data);
  };

  const resetOrder = () => {
    Object.assign(order.value, emptyOrder);
  };

  return {
    order,
    setOrder,
    resetOrder,
  };
};
