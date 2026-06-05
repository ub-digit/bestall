import { Order, OrderSuccessResponse } from "#shared/types/Order";
import { Location } from "#shared/types/Location";
import { LoanType } from "#shared/types/LoanType";
import { Biblio, Item } from "~~/shared/types/Biblio";
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

    const orderToSumbit: Order = {
      ...order,
    };

    /* remove unnecessary data from the order payload to 
    make it smaller, since the API only needs the biblio id, item id, location id and loan type id to be able to create the order. The full biblio data is not needed for the order and can be fetched separately if needed based on the biblio id. */
    if (orderToSumbit.fullBiblio) {
      orderToSumbit.fullBiblio.items = []; // remove items from full biblio to make the order payload smaller, since the items are not needed for the order and can be fetched separately if needed based on the biblio id.
      orderToSumbit.fullBiblio.itemsAvailable = []; // remove
      orderToSumbit.fullBiblio.itemsNotAvailable = []; // remove
    }

    let orderSuccessResponse: OrderSuccessResponse = $fetch(
      `${useRuntimeConfig().apiBase}/reserves/`,
      {
        method: "POST",
        body: {
          orderToSumbit,
        },
        headers: {
          current_username: user?.cardnumber || "",
        },
      },
    );

    orderSuccessResponse = {
      showQueuePosition: true,
      positionInQueue: "2",
      showPickupLocation: true,
      pickupLocation_sv: "Pickuplocation string sv", // Placeholder value, replace with actual logic to determine pickup location name in Swedish
      pickupLocation_en: "Pickuplocation string en", // Placeholder value, replace with actual logic to determine pickup location name in English
      showRequiredPickupCode: true,
      showMyLoansLink: true,
    };

    const extendedOrderSuccessResponse = {
      ...orderSuccessResponse,
      pickupLocation:
        locale === "en"
          ? orderSuccessResponse.pickupLocation_en
          : orderSuccessResponse.pickupLocation_sv,
    };

    return {
      ...extendedOrderSuccessResponse,
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
