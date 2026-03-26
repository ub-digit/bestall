<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});
const router = useRouter();
const route = useRoute();
const { status, data: authData } = useAuth();
const { locale } = useI18n();
import type { Location } from "~/types/Location";
import type { LoanType } from "~/types/LoanType";
import type { Order } from "~/types/Order";
import type { EventPayload } from "~/types/EventPayload";

const { data: locations, error: locationsError } = await useFetch<Location[]>(
  "/api/locations",
  {
    query: { locale: locale.value },
  },
);

const { data: loanTypes, error: loanTypesError } = await useFetch<LoanType[]>(
  "/api/loantypes",
  {
    query: { locale: locale.value },
  },
);

const { data: biblio, error: biblioError } = await useFetch<any>(
  `/api/biblios/${route.params.id}`,
  { query: { locale: locale.value } },
);
const { order, setOrder, resetOrder } = useOrder();

const handleEvent = (payload: EventPayload) => {
  resetOrder();
  setOrder({
    user: authData?.value?.user?.borrowernumber || "unknown", // same for every case
    fullBiblio: biblio.value, // same for every case. Avoids having to fetch from api again during order creation.
  });
  switch (payload.typeOfEvent) {
    case "joinQueue":
      setOrder({
        biblio: payload.biblioId,
        item: payload.itemId,
      });
      router.push({
        path: `/order/${route.params.id}/details`,
        query: { ...route.query },
      });

      break;
    case "order":
      setOrder({
        biblio: payload.biblioId,
        item: payload.itemId,
      });
      router.push({
        path: `/order/${route.params.id}/details`,
        query: { ...route.query },
      });
      break;
    case "subscriptionOrder":
      setOrder({
        biblio: payload.biblioId,
        subscription: payload.subscriptionId,
        subscriptionCallNumber: payload.subscriptionCallNumber,
        subscriptionLocation: payload.subscriptionLocation,
        subscriptionSublocation: payload.subscriptionSublocation,
        subscriptionSublocationId: payload.subscriptionSublocationId,
      });
      router.push({
        path: `/order/${route.params.id}/details`,
        query: { ...route.query },
      });
      break;
    default:
      console.warn("Unknown event type:", payload.typeOfEvent);
  }
};
</script>
<template>
  <div>
    <BiblioInfo v-if="biblio" :biblio="biblio" />

    <ViewBook
      v-if="biblio?.viewType === 'book'"
      :biblio="biblio"
      @handleEvent="(payload) => handleEvent(payload)"
    />

    <ViewSubscription
      v-else-if="biblio?.viewType === 'subscription'"
      :biblio="biblio"
      @handleEvent="(payload) => handleEvent(payload)"
    />

    <ViewCollection
      v-else-if="biblio?.viewType === 'collection'"
      :biblio="biblio"
      @handleEvent="(payload) => handleEvent(payload)"
    >
    </ViewCollection>
    <div v-else>
      {{ $t("message.unsupportedViewType", { viewType: biblio?.viewType }) }}
    </div>

    <Debug v-if="$config.public.debugInfo" :order="order" :biblio="biblio" />
  </div>
</template>
<style scoped></style>
