<template>
  <div class="confirm-page">
    <UserWarning />
    <div class="confirmation-message">
      <h1>{{ $t("confirmation.header") }}</h1>

      <div
        v-if="orderSuccessResponse?.item_referenced"
        class="item-referenced-info"
      >
        {{ $t("confirmation.itemReferencedInfo") }}
      </div>

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

        <div class="pickup-code-info">
          {{ $t("confirmation.pickupInfoCode") }}
        </div>
      </div>
      <div v-else class="no-pickup-info">
        {{ $t("confirmation.messageNoPickup") }}
      </div>

      <i18n-t
        v-if="orderSuccessResponse?.showMyLoansLink && isEnabledMyLoansLink"
        keypath="confirmation.myLoansLink"
        tag="div"
        class="my-loans-link"
      >
        <template #myLoansLink>
          <a :href="myLoansUrl">
            {{ $t("confirmation.myLoansLinkLabel") }}
          </a>
        </template>
      </i18n-t>
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

const runtimeConfig = useRuntimeConfig();
const { locale } = useI18n();
const hideGUAuthParamValue = runtimeConfig.public.hideGUAuthParamValue;
const myLoansBaseUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.myLoansUrlEn
    : runtimeConfig.public.myLoansUrlSv,
);
const myLoansUrl = computed(
  () => `${myLoansBaseUrl.value.replace(/\/$/, "")}/login?lang=${locale.value}`,
);

const isEnabledMyLoansLink = computed(() => {
  const currentHideGUAuthParamValue =
    route?.query?.[runtimeConfig.public.hideGUAuthParamName];
  if (currentHideGUAuthParamValue === hideGUAuthParamValue) {
    return false;
  }
  return true;
});

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
