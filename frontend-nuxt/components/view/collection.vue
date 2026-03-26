<script setup lang="ts">
import type { Biblio } from "~/types/Biblio";
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
  <div class="view-type-collection" v-if="biblio?.viewType === 'collection'">
    <div id="items-available" class="items">
      <ViewItemsTable
        v-if="biblio?.items"
        :items="biblio.items"
        @handleEvent="(payload) => handleEvent(payload)"
        :hasActions="true"
        :hasSubscriptions="false"
        :header="
          $t('viewType.collection.copies', {
            numberOfAvailable: biblio?.items.length,
          })
        "
      >
        <template #info>
          <div v-if="!biblio?.items.length">
            <p class="muted">
              {{ $t("message.noAvailableItems") }}
            </p>
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
