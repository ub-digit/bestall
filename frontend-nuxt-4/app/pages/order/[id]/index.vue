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

const localePath = useLocalePath();

if (authData?.value.user?.errors?.code === "FORBIDDEN") {
  showError({
    statusCode: 403,
    statusMessage: "Forbidden",
    data: {
      data: { errors: authData?.value?.user?.errors || [] },
    },
  });
  // show error here
}

const { data, error } = await useFetch<any>(
  `/api/currentuser/?biblio=${route.params.id}&current_username=${authData?.value?.user?.cardnumber}`,
);
if (error.value) {
  showError({
    statusCode: error?.value?.statusCode || "unknown code",
    statusMessage: error.value?.statusMessage || "Unknown message",
    data: {
      data: { errors: { errors: error.value.data?.data || [] } },
    },
  });
}

const { data: biblio, error: biblioError } = await useFetch<any>(
  `/api/biblios/${route.params.id}`,
  { query: { locale: locale.value } },
);
console.log("Fetched biblio:", biblio.value);

const redirectToDetailsPage = () => {
  const path = localePath({
    path: `/order/${route.params.id}/details`,
    query: { ...route.query },
  });
  router.push(path);
};

const { order, setOrder, resetOrder } = useOrder();
const handleEvent = (payload: EventPayload) => {
  resetOrder();
  setOrder({
    user: authData?.value?.user?.cardnumber || "unknown", // same for every case
    fullBiblio: biblio.value, // same for every case. Avoids having to fetch from api again during order creation.
  });

  switch (payload.typeOfEvent) {
    case "joinQueue":
      setOrder({
        biblio: payload.biblioId,
        item: payload.itemId,
      });
      redirectToDetailsPage();
      break;
    case "order":
      setOrder({
        biblio: payload.biblioId,
        item: payload.itemId,
      });
      redirectToDetailsPage();
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
      redirectToDetailsPage();
      break;
    default:
      console.warn("Unknown event type:", payload.typeOfEvent);
  }
};
</script>
<template>
  <div>
    <BiblioInfo v-if="biblio" :biblio="biblio" />

    <UserWarning />
    <!-- the actual view type component, which is different based on the biblio.viewType -->
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
  </div>
</template>
<style scoped>
.bib-title {
  font-weight: bold;
  font-size: 1.2em;
  max-width: var(--reading-width);
}
</style>
