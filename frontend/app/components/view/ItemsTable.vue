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

const isStatusLimitationToastEnabled = [true, "true"].includes(
  useRuntimeConfig().public.showStatusLimitationToast as boolean | string,
);

function handleEvent(payload: EventPayload) {
  emit("handleEvent", payload);
}

const statusLimitationToast = ref<{ show: (message: string) => void } | null>(
  null,
);

function showStatusLimitationToast(item: Item) {
  if (!isStatusLimitationToastEnabled) return;

  const limitation = $t(
    `status.statusLimitation.${item.status_limitation + "_DESCRIPTION"}`,
  );
  statusLimitationToast.value?.show(
    $t("item.status-limitation", { limitation }),
  );
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
  <h3 class="items-table-header">{{ header }}</h3>

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
          <div class="status">
            <div class="status-text">{{ getStatusStr(item) }}</div>
            <div
              v-if="item.status_limitation"
              class="status-limitation"
              :class="{
                'status-limitation-actionable': isStatusLimitationToastEnabled,
              }"
              :role="isStatusLimitationToastEnabled ? 'button' : undefined"
              :tabindex="isStatusLimitationToastEnabled ? 0 : undefined"
              @click="showStatusLimitationToast(item)"
              @keydown.enter="showStatusLimitationToast(item)"
              @keydown.space.prevent="showStatusLimitationToast(item)"
            >
              <svg
                class="status-limitation-icon"
                viewBox="0 0 24 24"
                aria-hidden="true"
                focusable="false"
              >
                <circle
                  cx="12"
                  cy="12"
                  r="9"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="1.8"
                />
                <path
                  d="M12 10.5v5"
                  stroke="currentColor"
                  stroke-width="1.8"
                  stroke-linecap="round"
                />
                <circle cx="12" cy="7.2" r="1.2" fill="currentColor" />
              </svg>
              {{ $t(`status.statusLimitation.${item.status_limitation}`) }}
            </div>
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
  <Toast v-if="isStatusLimitationToastEnabled" ref="statusLimitationToast" />
</template>

<style scoped>
.status {
  text-align: right;
  @media (min-width: 48rem) {
    text-align: left;
  }
  .status-limitation {
    appearance: none;
    display: inline-flex;
    align-items: center;
    gap: var(--spacer-4);
    color: var(--info-base);
    background: transparent;
    border: 1px solid;
    padding: var(--spacer-4);
    border-radius: var(--border-radius);
    font-size: 0.875em;
    font-family: inherit;
    &.status-limitation-actionable {
      cursor: pointer;

      &:focus-visible {
        outline: 2px solid currentColor;
        outline-offset: 2px;
      }
    }
  }

  .status-limitation-icon {
    width: 1em;
    height: 1em;
    flex-shrink: 0;
  }
}

.collect-button {
  font-style: italic;
  opacity: 0.6;
}

.items-table-container {
  /* border: 1px solid var(--light-base); */

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
      gap: var(--spacer-16);
      @media (min-width: 48rem) {
        grid-template-columns: repeat(var(--grid-columns), 1fr);
      }

      .items-table-cell {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;

        &::before {
          content: attr(label);
          font-weight: bold;
          display: block;
          @media (min-width: 48rem) {
            display: none;
          }
        }
        @media (min-width: 48rem) {
          padding: var(--spacer-8) 0;
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

.location {
  display: flex;
  flex-direction: column;
  gap: var(--spacer-4);
  text-align: right;
  @media (min-width: 48rem) {
    text-align: left;
  }
  .location-name,
  .sublocation-name {
    word-break: break-word;
  }
}
.status {
  display: flex;
  flex-direction: column;
  gap: var(--spacer-4);
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
