<template>
  <div class="order-details">
    <BiblioInfo v-if="order.biblio" :biblio="order.fullBiblio" />

    <form @submit.prevent="submitOrder">
      <div v-if="order.subscription" class="form-component subscriptionNotes">
        <label for="subscriptionNotes">
          {{ $t("orderForm.labels.subscriptionNotes") }}
        </label>
        <textarea
          id="subscriptionNotes"
          v-model="order.subscriptionNotes"
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
            :disabled="lt.isDisabled"
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
            v-for="loc in pickupLocations"
            :key="loc.id"
            :value="loc.id"
            :disabled="loc.disabled"
          >
            {{ loc.name }}
            <span v-if="loc.disabled && loc.categories.includes('CLOSED')">
              ({{ $t("message.libraryClosed") }})
            </span>
            <span
              v-else-if="loc.disabled && loc.categories.includes('NO_PICKUP')"
            >
              ({{ $t("message.cannotPickUpHere") }})
            </span>
            <span v-else-if="loc.disabled">
              ({{ $t("message.cannotTemporaryPickUpHere") }})
            </span>
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
        <button class="btn-primary" type="submit">
          {{ $t("actions.submit") }}
        </button>
      </div>
    </form>

    <pre>{{ order }}</pre>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});
import type { Location } from "~/types/Location";
import type { LoanType } from "~/types/LoanType";
import type { Item } from "~/types/Biblio";

const maxReserveNotesLength =
  useRuntimeConfig().public.reserveNoteMaxLength || 140;
const currentReserveNotesLength = ref(0);
const { status, data: authData } = useAuth();
const router = useRouter();
const { order, setOrder, resetOrder } = useOrder();

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
const { data: locations, error: locationsError } = await useFetch<Location[]>(
  "/api/locations",
  {
    query: { locale: locale.value },
  },
);
const possiblePickupLocations = computed<Location[]>(() => {
  const categoriesToIncludePickup = ["PICKUP"]; // maybe move to .env if it needs to be configurable
  if (!locations.value) return [];
  return locations.value.filter((loc) =>
    loc.categories.some((category) =>
      categoriesToIncludePickup.includes(category),
    ),
  );
});

const doApplyFilter = computed<boolean>(() => {
  if (
    order?.value?.fullBiblio?.record_type === "monograph" &&
    order?.value?.item
  ) {
    return true;
  }
  if (
    order?.value?.fullBiblio?.record_type === "serial" &&
    order?.value?.item &&
    order?.value?.fullBiblio?.items?.find(
      (item: Item) => item.id === order.value.item,
    )?.can_be_ordered
  ) {
    return true;
  }
  return false;
});

const pickupLocations = computed<Location[]>(() => {
  possiblePickupLocations.value.forEach((loc) => {
    loc.disabled = false; // reset disabled state before applying filter
  });

  possiblePickupLocations.value.forEach((loc) => {
    if (
      loc.categories.includes("CLOSED") ||
      loc.categories.includes("NO_PICKUP")
    ) {
      loc.disabled = true;
    }
  });
  if (!doApplyFilter.value) return possiblePickupLocations.value;

  let entity: any = null;
  if (order?.value?.item) {
    entity = order.value.fullBiblio?.items?.find(
      (item: any) => item.id === order.value.item,
    );
  } else if (order?.value?.subscription) {
    entity = order.value.fullBiblio?.subscriptiongroups
      ?.flatMap((sg: any) => sg.subscriptions)
      .find((sub: any) => sub.id === order.value.subscription);
  }

  if (!entity) return possiblePickupLocations.value;
  if (entity.sublocation_open_pickup_loc) return possiblePickupLocations.value;
  if (entity.sublocation_open_loc) {
    const userCategories = ["FI", "SY", "FY", "FC", "FT"]; // maybe move to .env if it needs to be configurable
    if (userCategories.includes(authData.value?.user?.categorycode)) {
      return possiblePickupLocations.value;
    } else {
      const homeLocation = entity.location_id;
      const filteredPossiblePickupLocations: Location[] =
        possiblePickupLocations.value.map((item) => {
          if (item.id == homeLocation) {
            item.disabled = true;
          }
          return item;
        });
      return filteredPossiblePickupLocations;
    }
  }
  return possiblePickupLocations.value;
});

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

const { data: loanTypes, error: loanTypesError } = await useFetch<LoanType[]>(
  "/api/loantypes",
  {
    query: {
      locale: locale.value,
      user: JSON.stringify(authData.value?.user), // Pass auth data to the API for potential user-specific filtering
      itemType: currentItemOnOrder?.value?.item_type, // Pass current item-type for potential item-specific filtering
      NotForLoan: currentItemOnOrder?.value?.not_for_loan, // Pass not_for_loan status for potential filtering
    },
  },
);

const submitOrder = () => {
  // For demonstration, we'll just log the order data. In a real application, you'd send this to your backend API.
  console.log("Submitting order:", order.value);
  alert(JSON.stringify(order.value, null, 2));
};

const goBack = () => {
  router.back();
};

setOrder({
  loanType: loanTypes.value?.filter((lt) => !lt.isDisabled)?.[0]?.id,
  location: "",
});
</script>

<style scoped>
.actions-area {
  display: flex;
  justify-content: space-between;
}
.order-details {
  max-width: var(--reading-width);
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
