<script setup lang="ts">
const message = ref("");
const configuredTimeoutDurationMs = Number(
  useRuntimeConfig().public.toastDurationMs,
);
const timeoutDurationMs =
  Number.isFinite(configuredTimeoutDurationMs) &&
  configuredTimeoutDurationMs > 0
    ? configuredTimeoutDurationMs
    : 4000;
const progressKey = ref(0);
let timeout: ReturnType<typeof setTimeout> | undefined;

function show(text: string) {
  message.value = text;
  progressKey.value += 1;

  if (timeout) {
    clearTimeout(timeout);
  }
  timeout = setTimeout(() => {
    message.value = "";
    timeout = undefined;
  }, timeoutDurationMs);
}

function close() {
  message.value = "";
  if (timeout) {
    clearTimeout(timeout);
    timeout = undefined;
  }
}

onBeforeUnmount(() => {
  if (timeout) {
    clearTimeout(timeout);
  }
});

defineExpose({ show });
</script>

<template>
  <div v-if="message" class="toast" role="status" aria-live="polite">
    <span>{{ message }}</span>
    <button
      class="toast-close"
      type="button"
      :aria-label="$t('app.closeNotification')"
      @click="close"
    >
      <span aria-hidden="true">&times;</span>
    </button>
    <div class="toast-progress" aria-hidden="true">
      <span
        :key="progressKey"
        :style="{ animationDuration: `${timeoutDurationMs}ms` }"
      ></span>
    </div>
  </div>
</template>

<style scoped>
.toast {
  position: fixed;
  right: var(--spacer-16);
  bottom: var(--spacer-16);
  display: flex;
  align-items: flex-start;
  gap: var(--spacer-16);
  z-index: 1000;
  max-width: min(32rem, calc(100vw - 2 * var(--spacer-16)));
  padding: var(--spacer-16);
  color: var(--light-light);
  background: var(--dark-dark);
  border-radius: var(--border-radius);
  box-shadow: 0 2px 12px rgb(0 0 0 / 20%);
  overflow: hidden;
}

.toast-close {
  flex: 0 0 auto;
  padding: 0;
  border: 0;
  color: inherit;
  background: transparent;
  font: inherit;
  font-size: 1.25rem;
  line-height: 1;
  cursor: pointer;
}

.toast-close:focus-visible {
  outline: 2px solid currentColor;
  outline-offset: 2px;
}

.toast-progress {
  position: absolute;
  right: 0;
  bottom: 0;
  left: 0;
  height: 3px;
  background: rgb(255 255 255 / 25%);
}

.toast-progress span {
  display: block;
  width: 100%;
  height: 100%;
  background: var(--info-base);
  transform-origin: left;
  animation: toast-timeout linear forwards;
}

@keyframes toast-timeout {
  to {
    transform: scaleX(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .toast-progress {
    display: none;
  }
}
</style>
