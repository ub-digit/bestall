<template>
  <div class="order-details">
    <BiblioInfo v-if="order.biblio" :biblio="order.fullBiblio" />

    <UserWarning />

    <form @submit.prevent="submitOrder">
      <div v-if="order.subscription" class="form-component subscriptionNotes">
        <label for="subscriptionNotes">
          {{ $t("orderForm.labels.subscriptionNotes") }}
        </label>
        <textarea
          id="subscriptionNotes"
          v-model="order.subscriptionNotes"
          autofocus
          :placeholder="$t('orderForm.placeholders.subscriptionNotes')"
        />
      </div>

      <div v-if="order.subscription" class="form-component">
        <label for="subs">
          {{ $t("orderForm.labels.publicNote") }}
        </label>
        <div id="subs" class="subscription-public-note">
          {{ currentSubscriptionOnOrder?.public_note || "" }}
        </div>
      </div>

      <div class="form-component">
        <label for="loanType">{{ $t("orderForm.labels.loanType") }}</label>
        <select id="loanType" v-model="order.loanType">
          <option
            v-for="lt in loanTypes"
            :key="lt.id"
            :value="lt.id"
            :disabled="lt.is_disabled"
          >
            {{ lt.name }}
          </option>
        </select>
      </div>

      <div
        v-if="currentLoanTypeOnOrder?.show_pickup_location"
        class="form-component"
      >
        <label for="location">{{ $t("orderForm.labels.location") }}</label>
        <select id="location" v-model="order.location">
          <option value="" disabled>
            {{ $t("orderForm.placeholders.selectLocation") }}
          </option>
          <option
            v-for="loc in locations"
            :key="loc.id"
            :value="loc.id"
            :disabled="loc.is_disabled"
          >
            {{ loc.name }}
          </option>
        </select>
      </div>

      <div v-if="!order.subscription" class="form-component reserve-notes">
        <label for="reserveNotes">
          {{ $t("orderForm.labels.reserveNotes") }}

          <span
            >{{ currentReserveNotesLength }}/{{ maxReserveNotesLength }}</span
          >
        </label>
        <textarea
          id="reserveNotes"
          v-model="order.reserveNotes"
          :maxlength="maxReserveNotesLength"
          :placeholder="$t('orderForm.placeholders.reserveNotes')"
        />
        <p>
          <small v-html="$t('orderForm.messages.privacyWarning')"></small>
        </p>
      </div>
      <div class="actions-area">
        <button class="btn-light" type="button" @click="goBack()">
          {{ $t("actions.back") }}
        </button>
        <button
          class="btn-primary"
          type="submit"
          :disabled="
            !order.loanType ||
            (currentLoanTypeOnOrder?.show_pickup_location && !order.location)
          "
        >
          {{ $t("actions.submit") }}
        </button>
      </div>
    </form>
  </div>
  <Debug v-if="$config.public.debugInfo" :order="order" :biblio="biblio" />
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});
import type { Location } from "~/types/Location";
import type { LoanType } from "~/types/LoanType";
import type { Item } from "~/types/Biblio";
import type { Order, OrderSuccessResponse } from "~/types/Order";

const maxReserveNotesLength =
  useRuntimeConfig().public.reserveNoteMaxLength || 140;
const currentReserveNotesLength = ref(0);
const { status, data: authData } = useAuth();
const route = useRoute();
const router = useRouter();
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
watch(
  () => order.value?.reserveNotes,
  (newVal) => {
    currentReserveNotesLength.value = newVal ? newVal.length : 0;
  },
);

const { locale } = useI18n();

const currentSubscriptionOnOrder = computed(() => {
  if (!order.value || !order.value.subscription) return null;
  return order.value.fullBiblio?.subscriptiongroups
    ?.flatMap((sg: any) => sg.subscriptions)
    .find((sub: any) => sub.id === order.value.subscription);
});

const currentItemOnOrder = computed(() => {
  if (!order.value || !order.value.item) return null;
  return order.value.fullBiblio?.items?.find(
    (item: Item) => item.id === order.value.item,
  );
});

const currentLoanTypeOnOrder = computed(() => {
  if (!order.value || !order.value.loanType) return null;
  return loanTypes.value?.find(
    (loanType: LoanType) => loanType.id === order.value.loanType,
  );
});

const { data: loanTypesPayload, error: loanTypesError } = await useFetch<
  LoanType[]
>("/api/loantypes", {
  query: {
    locale: locale.value,
    current_item: currentItemOnOrder?.value, // Pass current item-type for potential item-specific filtering
  },
});

const { loanTypes, setLoanTypes, resetLoanTypes } = useLoanTypes();
resetLoanTypes(); // Clear loan types before setting new ones to avoid showing stale data during loading
setLoanTypes(loanTypesPayload.value || []);

const { data: locationsPayload, error: locationsError } = await useFetch<
  Location[]
>("/api/locations", {
  query: {
    locale: locale.value,
    current_item: currentItemOnOrder?.value,
    current_subscription: currentSubscriptionOnOrder.value, // Pass current subscription-type for potential subscription-specific filtering
    record_type: order.value?.fullBiblio?.record_type,
  }, // Pass current item-type for potential item-specific filtering
});
const { locations, setLocations, resetLocations } = useLocations();
resetLocations(); // Clear locations before setting new ones to avoid showing stale data during loading
setLocations(locationsPayload.value || []);

const submitOrder = async () => {
  try {
    const data: OrderSuccessResponse = await $fetch(
      "/api/order/" + route.params.id,
      {
        method: "POST",
        body: order.value,
      },
    );
    setOrderSuccessResponse({
      ...data.data,
    });
    navigateTo(
      useLocalePath()({
        path: `/order/${route.params.id}/confirm`,
        query: route.query,
      }),
    );
  } catch (error) {
    console.error("Error submitting order:", error);
    // Handle error case, e.g. show an error message or redirect to an error page
    return;
  }
};

const goBack = () => {
  router.back();
};

setOrder({
  loanType: loanTypes.value?.filter((lt) => !lt.is_disabled)?.[0]?.id,
  location: "",
});
</script>

<style scoped>
.actions-area {
  display: flex;
  justify-content: space-between;
}
.order-details {
}
.form-component {
  margin-bottom: var(--spacer-24);
  display: flex;
  flex-direction: column;
}

.subscription-public-note {
  margin-top: var(--spacer-8);
  pre {
    overflow: scroll;
  }
  background-color: var(--light-light);
  border: 1px solid var(--dark-light);
  padding: 0.5rem;
  border-radius: 4px;
  white-space: pre-wrap;
}

.reserve-notes {
  label {
    display: flex;
    justify-content: space-between;
    align-items: center;
    span {
      color: var(--dark-light);
      font-weight: normal;
    }
  }
  textarea {
    min-height: 100px;
  }
}

p {
  margin-top: var(--spacer-4);
  margin-bottom: 0;
}
</style>
