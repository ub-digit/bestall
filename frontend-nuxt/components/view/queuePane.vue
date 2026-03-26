<script setup lang="ts">
import type { Biblio } from "~/types/Biblio";
import type { EventPayload } from "~/types/EventPayload";
const props = defineProps<{
  biblio: Biblio;
}>();
const emit = defineEmits<{
  (e: "handleEvent", payload: EventPayload): void;
}>();
</script>
<template>
  <div class="queue-pane">
    <div class="queue-pane-header">
      {{
        $t("message.numberOfPeopleInQueueOnNotAvailable", {
          numberOfPeople: biblio.no_in_queue,
        })
      }}
    </div>
    <button
      class="btn-primary"
      @click="
        emit('handleEvent', { biblioId: biblio.id, typeOfEvent: 'joinQueue' })
      "
    >
      {{ $t("actions.queue") }}
    </button>
  </div>
</template>

<style scoped>
.queue-pane {
  .queue-pane-header {
    font-weight: 700;
  }
  padding: var(--spacer-16);
  border: 1px solid var(--light-base);
  border-radius: var(--spacer-4);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacer-16);
  margin-bottom: var(--spacer-16);
}
</style>
