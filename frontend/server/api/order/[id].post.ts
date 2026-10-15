import { Order, OrderSuccessResponse } from "#shared/types/Order";
import { Location } from "#shared/types/Location";
import { LoanType } from "#shared/types/LoanType";
import { Biblio, Item } from "#shared/types/Biblio";
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

    const user = session.user as typeof session.user & { cardnumber?: string };

    if (!order) {
      throw createError({
        statusCode: 400,
        statusMessage: "Request body is required",
      });
    }
    const currentItemOnOrder = () => {
      if (!order || !order.item) return null;
      return order.fullBiblio?.items?.find(
        (item: Item) => item.id === order.item,
      );
    };

    const orderToSubmit: Order = {
      ...order,
      current_item_extended: currentItemOnOrder(),
    };

    /* remove unnecessary data from the order payload to 
    make it smaller, since the API only needs the biblio id, item id, location id and loan type id to be able to create the order. The full biblio data is not needed for the order and can be fetched separately if needed based on the biblio id. */
    if (orderToSubmit.fullBiblio) {
      orderToSubmit.fullBiblio.items = []; // remove items from full biblio to make the order payload smaller, since the items are not needed for the order and can be fetched separately if needed based on the biblio id.
      orderToSubmit.fullBiblio.itemsAvailable = []; // remove
      orderToSubmit.fullBiblio.itemsNotAvailable = []; // remove
    }

    console.log("Submitting order:", orderToSubmit);

    const data = await $fetch<{ reserve: OrderSuccessResponse }>(
      `${useRuntimeConfig().apiBase}/reserves/`,
      {
        method: "POST",
        body: {
          orderToSubmit,
        },
        headers: {
          "current-username": user.cardnumber || "",
        },
      },
    );

    const extendedResponse = {
      ...data.reserve,
      pickupLocation:
        locale === "en"
          ? data.reserve.pickupLocation_en
          : data.reserve.pickupLocation_sv,
    };

    return {
      data: extendedResponse,
      statusCode: 200,
      message: "Order created successfully",
    };
  } catch (error) {
    const fetchError = error as {
      statusCode?: number;
      status?: number;
      statusMessage?: string;
      statusText?: string;
      data?: unknown;
      response?: {
        status?: number;
        statusText?: string;
        _data?: unknown;
      };
    };
    const responseData = fetchError.data ?? fetchError.response?._data;
    const responseMessage =
      typeof responseData === "object" &&
      responseData !== null &&
      "message" in responseData &&
      typeof responseData.message === "string"
        ? responseData.message
        : undefined;
    const statusCode =
      fetchError.statusCode ??
      fetchError.status ??
      fetchError.response?.status ??
      500;
    const statusMessage =
      fetchError.statusMessage ??
      responseMessage ??
      fetchError.statusText ??
      fetchError.response?.statusText ??
      "Internal server error";

    console.error("Order API error:", { statusCode, statusMessage });
    throw createError({
      statusCode,
      statusMessage,
      data: responseData,
    });
  }
});
