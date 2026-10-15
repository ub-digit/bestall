<script setup lang="ts">
const loading = useLoginLoading();
const { t } = useI18n();
</script>

<template>
  <div v-if="loading" class="loading-overlay" role="status" aria-live="polite">
    <span class="spinner" aria-hidden="true" />
    <span class="visually-hidden">{{ t("app.loading") }}</span>
  </div>
</template>

<style scoped>
.loading-overlay {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  background: oklch(from var(--dark-dark) l c h / 0.5);
}

.spinner {
  width: var(--spacer-48);
  height: var(--spacer-48);
  border: var(--spacer-4) solid var(--light-dark);
  border-top-color: var(--brand-base);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
