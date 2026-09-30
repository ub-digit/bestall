<script setup lang="ts">
const props = withDefaults(
  defineProps<{
    modelValue: boolean;
    title: string;
    closeLabel: string;
    closeOnBackdrop?: boolean;
  }>(),
  { closeOnBackdrop: true },
);

const emit = defineEmits<{
  "update:modelValue": [value: boolean];
}>();

const dialog = useTemplateRef<HTMLDialogElement>("dialog");
const titleId = useId();

const syncDialog = (open: boolean) => {
  const element = dialog.value;
  if (!element) return;

  if (open && !element.open) {
    element.showModal();
  } else if (!open && element.open) {
    element.close();
  }
};

const close = () => emit("update:modelValue", false);

watch(() => props.modelValue, syncDialog);
onMounted(() => syncDialog(props.modelValue));
</script>

<template>
  <dialog
    ref="dialog"
    class="base-modal"
    :aria-labelledby="titleId"
    @click="
      props.closeOnBackdrop && $event.target === $event.currentTarget && close()
    "
    @cancel.prevent="close"
    @close="close"
  >
    <header class="base-modal__header">
      <h2 :id="titleId">{{ title }}</h2>
      <button
        class="base-modal__close btn-light"
        type="button"
        :aria-label="closeLabel"
        @click="close"
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </header>
    <div class="base-modal__content">
      <slot />
    </div>
  </dialog>
</template>

<style scoped>
.base-modal {
  width: min(42rem, calc(100vw - 2rem));
  max-width: none;
  max-height: calc(100dvh - 2rem);
  padding: 0;
  overflow: auto;
  border: 1px solid var(--dark-light);
  border-radius: var(--border-radius);
  color: var(--dark-dark);
  background: var(--light-light);

  &::backdrop {
    background: rgb(0 0 0 / 55%);
  }

  .base-modal__header {
    position: sticky;
    top: 0;
    z-index: 1;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--spacer-16);
    padding: var(--spacer-16);
    border-bottom: 1px solid var(--dark-light);
    background: var(--light-light);

    h2 {
      margin: 0;
      font-size: 1.25rem;
    }
  }

  .base-modal__close {
    flex: 0 0 auto;
    width: 2.75rem;
    height: 2.75rem;
    padding: 0;
    font-size: 1.5rem;
    line-height: 1;
  }

  .base-modal__content {
    padding: var(--spacer-16);
  }
}
</style>
