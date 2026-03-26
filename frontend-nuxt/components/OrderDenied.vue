<script setup lang="ts">
const props = defineProps<{
  error: any;
}>();
</script>
<template>
  <div class="order-denied-container">
    <div class="order-denied">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="32"
        height="32"
        viewBox="0 0 24 24"
      >
        <!-- Icon from Material Symbols by Google - https://github.com/google/material-design-icons/blob/master/LICENSE -->
        <path
          fill="currentColor"
          d="M8 13h8q.425 0 .713-.288T17 12t-.288-.712T16 11H8q-.425 0-.712.288T7 12t.288.713T8 13m4 9q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22"
        />
      </svg>
      <h2>{{ $t("orderDenied.title") }}</h2>

      <slot name="description">
        <p class="description" v-html="$t('orderDenied.description')"></p>
      </slot>

      <ul v-if="error?.data?.data?.length" class="error-list">
        <li v-for="(item, index) in error?.data?.data" :key="index">
          {{ $t("orderDenied.errors." + item.code) }}
        </li>
      </ul>
      <div class="order-denied-code">
        <p>{{ $t("orderDenied.errorCode", { code: error.statusCode }) }}</p>

        <p v-if="useRuntimeConfig().public.debugInfo" class="error-detail">
          {{ $t("orderDenied.errorDetail", { detail: error.statusMessage }) }}
        </p>
      </div>
    </div>
  </div>
</template>
<style scoped>
.order-denied-container {
  min-height: 50vh;
  display: flex;
  justify-content: center;
  align-items: center;
  .order-denied {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 1rem;
    svg {
      color: var(--danger-dark);
      width: 3rem;
      height: 3rem;
    }
    h2 {
      margin: 0;
    }
    p {
      margin: 0;
    }

    .order-denied-code {
      margin-top: 1rem;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      align-items: center;
      background-color: var(--danger-dark);
      color: var(--light-light);
      padding: 1rem;
      border-radius: 0.5rem;
    }
  }
  .error-list {
    font-size: 0.8rem;
    margin: 0;
    padding: 0;
    list-style: none;
  }
}
</style>
