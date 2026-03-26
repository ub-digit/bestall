<script setup lang="ts">
import type { Item } from "~/types/Biblio";
import type { EventPayload } from "~/types/EventPayload";
interface Props {
  items: Item[];
  header?: string;
  hasActions?: boolean;
  hasSubscriptions?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  header: "",
  hasActions: false,
  hasSubscriptions: false,
});

const emit = defineEmits<{
  (e: "handleEvent", payload: EventPayload): void;
}>();

function handleEvent(payload: EventPayload) {
  emit("handleEvent", payload);
}

const getStatusStr = (item: Item) => {
  switch (item.status) {
    case "AVAILABLE":
      return $t("status.available");
    case "RESERVED":
      return $t("status.reserved");
    case "LOANED":
      return $t("status.loaned", {
        loanedTo: item.due_date
          ? new Date(item.due_date).toLocaleDateString(
              useRuntimeConfig().public.dateFormat || "sv-SE",
            )
          : $t("status.loanedDateUnknown"),
      });
    case "NOT_IN_PLACE":
      return $t("status.notInPlace");
    case "DELAYED":
      return $t("status.delayed");
    case "IN_TRANSIT":
      return $t("status.inTransit");
    case "DURING_ACQUISITION":
      return $t("status.duringAcquisition");
    default:
      return "";
  }
};
</script>

<template>
  <h5 class="items-table-header h3">{{ header }}</h5>

  <div class="items-table-info">
    <slot name="info"></slot>
  </div>

  <div class="items-table-container">
    <table
      :class="`items-table ${hasSubscriptions ? 'has-subscriptions' : ''} ${hasActions ? 'has-actions' : ''}`"
      v-if="items?.length"
    >
      <thead>
        <tr>
          <th v-if="hasSubscriptions">{{ $t("table.header.copy") }}</th>
          <th>{{ $t("table.header.location") }}</th>
          <th>{{ $t("table.header.status") }}</th>
          <th v-if="hasActions">{{ $t("table.header.action") }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in items" :key="item.id">
          <td v-if="hasSubscriptions">{{ item.copy_number }}</td>
          <td>
            <div class="location">
              <div class="location-name">{{ item.location_name }}</div>
              <div class="sublocation-name">
                <span v-if="item.sublocation_name">{{
                  item.sublocation_name
                }}</span>
                <span v-else>{{ $t("message.needsToBeOrdered") }}</span>
              </div>
            </div>
          </td>
          <td>
            {{ getStatusStr(item) }}
            <span class="status-limitation" v-if="item.status_limitation">
              |
              {{
                $t(`status.statusLimitation.${item.status_limitation}`)
              }}</span
            >
          </td>
          <td v-if="hasActions">
            <div v-if="item.can_be_ordered" class="order-button">
              <button
                class="btn-primary"
                @click="
                  handleEvent({
                    biblioId: item.biblio_id,
                    itemId: item.id,
                    typeOfEvent: 'order',
                  })
                "
              >
                {{ $t("actions.order") }}
              </button>
            </div>
            <div v-else-if="item.can_be_queued" class="queue-button">
              <button
                class="btn-primary"
                @click="
                  handleEvent({
                    biblioId: item.biblio_id,
                    itemId: item.id,
                    typeOfEvent: 'joinQueue',
                  })
                "
              >
                {{ $t("actions.queue") }}
              </button>
            </div>
            <span v-else-if="item.is_availible" class="collect-button">
              {{ $t("actions.collect") }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.items-table-header {
  font-weight: bold;
  margin-bottom: var(--spacer-16);
}
.status-limitation {
  opacity: 0.8;
  color: var(--danger-base);
  font-size: 0.875em;
}
.collect-button {
  font-style: italic;
  opacity: 0.6;
}
.items-table {
  width: 100%;
  border-collapse: collapse;

  th,
  td {
    border: 1px solid var(--light-base);
    padding: var(--spacer-8);

    text-align: left;
    @media (min-width: 48rem) {
      border: none;
      border-bottom: 1px solid var(--light-base);
    }
  }
  &.has-subscriptions,
  &.has-actions {
    th:last-child,
    td:last-child {
      text-align: right;
    }
  }
}
</style>
