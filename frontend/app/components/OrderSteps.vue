<script setup lang="ts">
const route = useRoute();
const config = useRuntimeConfig();
const steps = ["select", "details", "confirm"] as const;

// Path is matched without the locale prefix, so /en/order/1/details also works.
const currentStep = computed(() => {
  const match = route.path.match(/\/order\/[^/]+(?:\/(details|confirm))?\/?$/);
  if (!match) return -1;
  return match[1] ? steps.indexOf(match[1] as (typeof steps)[number]) : 0;
});
</script>

<template>
  <nav
    v-if="config.public.showOrderSteps && currentStep >= 0"
    class="order-steps"
    :aria-label="$t('orderSteps.label')"
  >
    <ol>
      <li
        v-for="(step, index) in steps"
        :key="step"
        :class="{
          'is-current': index === currentStep,
          'is-done': index < currentStep,
        }"
        :aria-current="index === currentStep ? 'step' : undefined"
      >
        <span class="order-steps__number" aria-hidden="true">
          {{ index + 1 }}
        </span>
        <span class="order-steps__label">{{ $t(`orderSteps.${step}`) }}</span>
      </li>
    </ol>
  </nav>
</template>

<style scoped>
.order-steps {
  margin-bottom: var(--spacer-48);

  ol {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacer-8) var(--spacer-24);
    margin: 0;
    padding: 0;
    list-style: none;
  }

  li {
    display: flex;
    align-items: center;
    gap: var(--spacer-8);
    color: var(--dark-base);

    &:not(:last-child)::after {
      content: "›";
      margin-left: var(--spacer-16);
    }

    &.is-done {
      color: var(--dark-dark);
    }

    &.is-current {
      color: var(--brand-base);
      font-weight: 700;
    }
  }

  .order-steps__number {
    display: inline-grid;
    place-items: center;
    width: 1.75rem;
    height: 1.75rem;
    border: 1px solid currentColor;
    border-radius: 50%;
    font-size: 0.875rem;
  }

  .is-current .order-steps__number {
    background: var(--brand-base);
    border-color: var(--brand-base);
    color: var(--light-light);
  }
}
</style>
