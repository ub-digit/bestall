import type { Order } from "#shared/types/Order";

export const useOrder = () => {
  const emptyOrder: Order = {
    location: "",
    loanType: null,
    biblio: "",
    fullBiblio: null, // to avoid having to pickup biblio data from API during order creation.
    item: "",
    subscription: "",
    reserveNotes: "",
    subscriptionNotes: "",
    current_item_extended: null,
  };

  const orderSuccessResponse = useState<OrderSuccessResponse>(
    "orderSuccessResponse",
    () =>
      ({
        showQueuePosition: false,
        positionInQueue: null,
        showPickupLocation: false,
        pickupLocation_en: null,
        pickupLocation_sv: null,
        showRequiredPickupCode: false,
        showMyLoansLink: false,
        item_referenced: false,
      }) as OrderSuccessResponse,
  );

  const setOrderSuccessResponse = (data: Partial<OrderSuccessResponse>) => {
    Object.assign(orderSuccessResponse.value, data);
  };

  const resetOrderSuccessResponse = () => {
    Object.assign(orderSuccessResponse.value, {
      showQueuePosition: false,
      positionInQueue: null,
      showPickupLocation: false,
      pickupLocation_en: null,
      pickupLocation_sv: null,
      showMyLoansLink: false,
      item_referenced: false,
    } as OrderSuccessResponse);
  };

  const order = useState<Order>("order", () => ({ ...emptyOrder }) as Order);
  const orderSubmitted = useState<boolean>("order-submitted", () => false);

  /**
   * Updates the order state with the provided partial data.
   * @param data - Partial order object containing the properties to update
   */
  const setOrder = (data: Partial<Order>) => {
    Object.assign(order.value, data);
  };

  const resetOrder = () => {
    Object.assign(order.value, emptyOrder);
    orderSubmitted.value = false;
  };

  const markOrderSubmitted = () => {
    orderSubmitted.value = true;
  };

  return {
    order,
    orderSubmitted,
    setOrder,
    resetOrder,
    markOrderSubmitted,
    orderSuccessResponse,
    setOrderSuccessResponse,
    resetOrderSuccessResponse,
  };
};
