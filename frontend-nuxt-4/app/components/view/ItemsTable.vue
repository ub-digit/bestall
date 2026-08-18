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
    <div
      v-if="items?.length"
      :class="`items-table ${hasSubscriptions ? 'has-subscriptions' : ''} ${hasActions ? 'has-actions' : ''}`"
    >
      <div class="items-table-head">
        <div v-if="hasSubscriptions" class="items-table-cell header-cell">
          {{ $t("table.header.copy") }}
        </div>
        <div class="items-table-cell header-cell">
          {{ $t("table.header.location") }}
        </div>
        <div class="items-table-cell header-cell">
          {{ $t("table.header.status") }}
        </div>
        <div v-if="hasActions" class="items-table-cell header-cell">
          {{ $t("table.header.action") }}
        </div>
      </div>

      <div v-for="item in items" :key="item.id" class="items-table-row">
        <div
          v-if="hasSubscriptions"
          class="items-table-cell"
          :label="$t('table.header.copy')"
        >
          {{ item.copy_number }}
        </div>
        <div class="items-table-cell" :label="$t('table.header.location')">
          <div class="location">
            <div class="location-name">{{ item.location_name }}</div>
            <div class="sublocation-name">
              <span v-if="item.sublocation_name">{{
                item.sublocation_name
              }}</span>
              <span v-else>{{ $t("message.needsToBeOrdered") }}</span>
            </div>
          </div>
        </div>
        <div class="items-table-cell" :label="$t('table.header.status')">
          <div>
            {{ getStatusStr(item) }}
            <span class="status-limitation" v-if="item.status_limitation">
              | {{ $t(`status.statusLimitation.${item.status_limitation}`) }}
            </span>
          </div>
        </div>
        <div
          v-if="hasActions"
          class="items-table-cell actions-cell"
          :label="$t('table.header.action')"
        >
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
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.status-limitation {
  opacity: 0.8;
  color: var(--danger-base);
  font-size: 0.875em;
}
.collect-button {
  font-style: italic;
  opacity: 0.6;
}

.items-table-container {
  border: 1px solid var(--light-base);

  @media (min-width: 48rem) {
    .items-table.has-subscriptions {
      --grid-columns: 3;
    }

    .items-table.has-actions {
      --grid-columns: 3;
    }
    .items-table.has-subscriptions.has-actions {
      --grid-columns: 4;
    }
    .items-table:not(.has-subscriptions):not(.has-actions) {
      --grid-columns: 2;
    }
  }
  .items-table {
    display: grid;
    padding: var(--spacer-16);
    gap: var(--spacer-32);
    @media (min-width: 48rem) {
      gap: var(--spacer-8);
    }

    .items-table-head {
      font-weight: bold;
      padding-bottom: var(--spacer-16);
      border-bottom: 1px solid var(--light-base);
      display: none;
      @media (min-width: 48rem) {
        display: grid;
        grid-template-columns: repeat(var(--grid-columns), 1fr);
      }
    }
    .items-table-row {
      display: grid;
      border-bottom: 1px solid var(--light-base);
      padding-bottom: var(--spacer-16);
      gap: var(--spacer-8);
      @media (min-width: 48rem) {
        grid-template-columns: repeat(var(--grid-columns), 1fr);
      }

      .items-table-cell {
        display: flex;
        align-items: center;
        justify-content: space-between;
        &::before {
          content: attr(label);
          font-weight: bold;
          display: block;
          @media (min-width: 48rem) {
            display: none;
          }
        }
        @madia (min-width: 48rem) {
          padding: var(--spacer-8) var(--spacer-16);
        }
        @media (min-width: 48rem) {
          &.actions-cell {
            display: flex;
            justify-content: flex-end;
          }
        }
      }
    }
  }
}

.location-name,
.sublocation-name {
  word-break: break-word;
}

.actions-cell {
  display: flex;
  @media (min-width: 48rem) {
    justify-content: flex-end;
  }
  gap: var(--spacer-8);
  align-items: center;
}
</style>
