<template>
  <div>
    <div class="view-type-book" v-if="biblio?.viewType === 'book'">
      <div id="items-available" class="items-available">
        <ViewItemsTable
          v-if="biblio?.itemsAvailable"
          :items="biblio.itemsAvailable"
          :hasActions="true"
          :hasSubscriptions="false"
          @handleEvent="(payload) => handleEvent(payload)"
          :header="
            $t('viewType.book.available', {
              numberOfAvailable: biblio?.itemsAvailable.length,
            })
          "
        >
          <template #info>
            <div v-if="!biblio?.itemsAvailable.length">
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

      <br />

      <div class="items-not-available">
        <ViewItemsTable
          v-if="biblio?.itemsNotAvailable"
          :items="biblio.itemsNotAvailable"
          :hasActions="false"
          :hasSubscriptions="false"
          :header="
            $t('viewType.book.notAvailable', {
              numberOfNotAvailable: biblio?.itemsNotAvailable.length,
            })
          "
        >
          <template #info>
            <p
              v-if="!biblio?.itemsNotAvailable.length"
              v-html="$t('message.allItemsAreAvailable')"
            ></p>

            <div v-if="biblio.can_be_queued">
              <p
                v-if="!biblio?.itemsNotAvailable.length"
                class="muted"
                v-html="$t('message.noNotAvailableItems')"
              ></p>

              <p
                v-if="
                  biblio?.itemsAvailable.filter((item) => item.can_be_ordered)
                    .length
                "
                v-html="$t('message.infoAboutAvailableItems')"
              ></p>
              <p
                v-else-if="biblio?.has_available_kursbok"
                v-html="$t('message.hasAvaillableCourseBook')"
              ></p>
            </div>
          </template>
        </ViewItemsTable>
      </div>
    </div>
    <div v-else>
      {{ $t("message.unsupportedViewType", { viewType: biblio?.viewType }) }}
    </div>
  </div>
</template>

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

function handleJoinQueue(biblioId: string) {
  emit("handleEvent", {
    biblioId: biblioId,
    typeOfEvent: "joinQueue",
  });
}

defineProps<{
  biblio: Biblio;
}>();
</script>

<style scoped>
.info-available-items {
  display: flex;
  align-items: center;
  gap: var(--spacer-8);
}

.view-type-book {
  display: flex;
  flex-direction: column;
  gap: var(--spacer-16);
  .no-available-items {
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 1rem;
  }

  .info-area {
    display: flex;
    align-items: center;
    .info-item {
      margin: var(--spacer-16) 0;
    }
  }
}
</style>
