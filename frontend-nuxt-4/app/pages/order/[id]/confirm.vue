<template>
  <div class="confirm-page">
    <UserWarning />

    <div class="confirmation-message">
      <div>
        <h3>DEBUG:</h3>

        <h4>Order data sent from API:</h4>
        <pre>{{ JSON.stringify(order, null, 2) }}</pre>
        <h4>Locations</h4>
        <pre>{{ JSON.stringify(locations, null, 2) }}</pre>
        <h4>Loan Types</h4>
        <pre>{{ JSON.stringify(loanTypes, null, 2) }}</pre>
      </div>

      <h1>{{ $t("confirmation.header") }}</h1>

      <div v-if="order.queuePosition" class="queue-info-wrapper">
        {{
          $t("confirmation.queuePosition", { position: order.queuePosition })
        }}
      </div>

      <div
        v-if="currentLoanTypeOnOrder.value?.showPickupLocation"
        class="pickup-location-info"
      >
        {{
          $t("confirmation.messagePickup", {
            pickupLocation: currentLocationOnOrder.value?.name,
          })
        }}
      </div>
      <div v-else class="no-pickup-info">
        {{ $t("confirmation.messageNoPickup") }}
      </div>

      <div
        v-if="order.fullBiblio.hasItemLevelQueue || order.subscription"
        class="my-loans-link"
      >
        {{ $t("confirmation.myLoansLink") }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});

const route = useRoute();
const { order, setOrder, resetOrder } = useOrder();
if (!order.value?.biblio) {
  // if there's no biblio data in the order, we can't show the details page, so we redirect back to the search page
  const route = useRoute();
  navigateTo(
    useLocalePath()({ path: "/order/" + route.params.id, query: route.query }),
  );
}
const orderError = ref(null);

const currentItemOnOrder = computed(() => {
  if (!order.value || !order.value.item) return null;
  return order.value.fullBiblio?.items?.find(
    (item: Item) => item.id === order.value.item,
  );
});

const currentSubscriptionOnOrder = computed(() => {
  if (!order.value || !order.value.subscription) return null;
  return order.value.fullBiblio?.subscriptiongroups
    ?.flatMap((sg: any) => sg.subscriptions)
    .find((sub: any) => sub.id === order.value.subscription);
});

const currentLoanTypeOnOrder = computed(() => {
  if (!order.value || !order.value.loanType) return null;
  return loanTypes.value?.find(
    (loanType: LoanType) => loanType.id === order.value.loanType,
  );
});

const currentLocationOnOrder = computed(() => {
  if (!order.value || !order.value.pickupLocation) return null;
  return locations.value?.find(
    (loc: Location) => loc.id === order.value.pickupLocation,
  );
});

const { locations, setLocations, resetLocations } = useLocations();
const { loanTypes, setLoanTypes, resetLoanTypes } = useLoanTypes();

try {
  const { data, error } = await useFetch(`/api/orders/${route.params.id}/`, {
    method: "POST",
    body: {
      order: order.value, // Pass the current order data to the API for confirmation
    },
  });
  if (error.value) {
    // Handle error case, e.g. show an error message or redirect to an error page
    console.error("Error confirming order:", error.value);
  }
} catch (error) {
  orderError.value = error; // Set the error object to display an error message in the template
  console.error("Error confirming order:", error);
}
</script>

<style scoped>
.confirm-page {
  /* Styles here */
}
</style>
