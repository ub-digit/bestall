<template>
  <div class="confirm-page">
    <UserWarning />
    <div class="confirmation-message">
      <h1>{{ $t("confirmation.header") }}</h1>

      <div
        v-if="orderSuccessResponse?.showQueuePosition"
        class="queue-info-wrapper"
        v-html="
          $t('confirmation.youHavePlaceInQueue', {
            positionInQueue: orderSuccessResponse?.positionInQueue,
          })
        "
      ></div>

      <div
        v-if="orderSuccessResponse?.showPickupLocation"
        class="pickup-location-info"
      >
        <div
          v-html="
            $t('confirmation.messagePickup', {
              pickupLocation: orderSuccessResponse?.pickupLocation,
            })
          "
        ></div>

        <div
          v-if="orderSuccessResponse?.showRequiredPickupCode"
          class="pickup-code-info"
        >
          {{ $t("confirmation.pickupInfoCode") }}
        </div>
        <div
          v-else-if="!orderSuccessResponse?.showRequiredPickupCode"
          class="pickup-info-name"
          v-html="$t('confirmation.pickupInfoName')"
        ></div>
      </div>
      <div v-else class="no-pickup-info">
        {{ $t("confirmation.messageNoPickup") }}
      </div>

      <div
        v-if="orderSuccessResponse?.showMyLoansLink"
        class="my-loans-link"
        v-html="$t('confirmation.myLoansLink')"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});

const route = useRoute();
const {
  order,
  setOrder,
  resetOrder,
  orderSuccessResponse,
  setOrderSuccessResponse,
  resetOrderSuccessResponse,
} = useOrder();
if (!order.value?.biblio) {
  // if there's no biblio data in the order, we can't show the details page, so we redirect back to the search page
  const route = useRoute();
  navigateTo(
    useLocalePath()({ path: "/order/" + route.params.id, query: route.query }),
  );
}
</script>

<style scoped>
.confirm-page {
  max-width: var(--reading-width);
  .confirmation-message {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    .pickup-location-info {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }
  }
  /* Styles here */
}
</style>
