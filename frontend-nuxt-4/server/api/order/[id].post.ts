import { Order } from "#shared/types/Order";
import { Location } from "#shared/types/Location";
import { LoanType } from "#shared/types/LoanType";
import { getServerSession } from "#auth";

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event);
    const order = body as Order;
    const session = await getServerSession(event);
    if (!session) {
      throw createError({ statusCode: 401, statusMessage: "Unauthorized" });
    }
    let { locale } = getQuery(event) as { locale?: string };

    if (!locale) {
      locale = "sv"; // if missing add default locale
    }

    const user = session.user;

    if (!order) {
      throw createError({
        statusCode: 400,
        statusMessage: "Request body is required",
      });
    }
    const runtimeConfig = useRuntimeConfig();

    const loantypes: LoanType[] = await $fetch("/api/loantypes");
    const locations: Location[] = await $fetch("/api/locations");

    const currentLoanType: LoanType = loantypes.find(
      (lt: LoanType) => lt.id === order.loanType,
    ) as LoanType;
    const currentLocation: Location = locations.find(
      (loc: Location) => loc.id === order.location,
    ) as Location;

    order.orderSuccessResponse = {} as Order["orderSuccessResponse"]; // initialize orderSuccessResponse to an empty object to avoid undefined errors when setting properties on it later

    if (order?.fullBiblio?.has_item_level_queue || order.subscription) {
      order.orderSuccessResponse!.showQueuePosition = true;
    }
    order.orderSuccessResponse!.positionInQueue = "55"; // from Koha

    if (currentLoanType?.show_pickup_location) {
      order.orderSuccessResponse!.showPickupLocation = true;
      order.orderSuccessResponse!.pickupLocation_en = currentLocation?.name_en;
      order.orderSuccessResponse!.pickupLocation_sv = currentLocation?.name_sv;
      order.orderSuccessResponse!.pickupLocation =
        locale === "en" ? currentLocation?.name_en : currentLocation?.name_sv;

      order.orderSuccessResponse!.showRequiredPickupCode = !!user?.pickupCode;
    }

    order.orderSuccessResponse!.showMyLoansLink = order.subscriptionNotes
      ? false
      : true;

    console.log("Received order data:", order);
    console.log("Fetched loantypes:", loantypes);
    console.log("Fetched locations:", locations);

    // determine if showQueuePosition should be true or false (hasItemLevelQueuePosition or hasSubscription on order object)
    // add queue position
    // determine if showPickupLocation should be true or false (has showPickupLocation set to true on loantype)
    // add pickup location as pickupLocation_sv and pickupLocation_en
    // determine if showRequiredPickupCode should be true or false (user.pickupCode))
    // determine if showMyLoansLink should be true or false (if subscriptionNotes is empty on order object, then showMyLoansLink should be true, otherwise false. In short if ends up in Koha/MyLoans show it)
    // add to orderSuccessResponse on order object

    return {
      ...order,
      statusCode: 200,
      message: "Order created successfully",
    };
  } catch (error) {
    console.error("Order API error:", error);
    throw createError({
      statusCode: 500,
      statusMessage: "Internal server error",
    });
  }
});
