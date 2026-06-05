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
      showRequiredPickupCode: false,
      showMyLoansLink: false,
    } as OrderSuccessResponse);
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
    orderSuccessResponse,
    setOrderSuccessResponse,
    resetOrderSuccessResponse,
  };
};
