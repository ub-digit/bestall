<script setup lang="ts">
import type { Biblio } from "~/types/Biblio";
import type { Item } from "~/types/Biblio";
import type { EventPayload } from "~/types/EventPayload";

const emit = defineEmits<{
  (e: "handleEvent", payload: EventPayload): void;
}>();

function handleEvent(payload: EventPayload) {
  emit("handleEvent", payload);
}

defineProps<{
  biblio: Biblio;
}>();
</script>
<template>
  <div
    class="view-type-subscription"
    v-if="biblio?.viewType === 'subscription'"
  >
    <div class="holdings">
      <div id="holdings-available" class="holdings">
        <ViewHoldings
          v-if="biblio?.subscriptiongroups.length"
          :subscriptionGroups="biblio.subscriptiongroups"
          @handleEvent="(payload) => handleEvent(payload)"
          :header="
            $t('viewType.subscription.holdings', {
              numberOfAvailable: biblio?.subscriptiongroups.length,
            })
          "
        />
      </div>
    </div>

    <br />

    <div id="items-available" class="items" v-if="biblio?.items.length">
      <ViewItemsTable
        v-if="biblio?.items"
        :items="biblio.items"
        @handleEvent="(payload) => handleEvent(payload)"
        :hasActions="true"
        :hasSubscriptions="true"
        :header="
          $t('viewType.subscription.copies', {
            numberOfAvailable: biblio?.items.length,
          })
        "
      >
        <template #info>
          <div v-if="!biblio?.items.length">
            <p class="muted">
              {{ $t("message.noAvailableItems") }}
            </p>
            <ViewQueuePane
              :biblio="biblio"
              @handleEvent="(payload) => handleEvent(payload)"
            />
          </div>
        </template>
      </ViewItemsTable>
    </div>
  </div>
  <div v-else>
    {{ $t("message.unsupportedViewType", { viewType: biblio?.viewType }) }}
  </div>
</template>

<style scoped></style>
