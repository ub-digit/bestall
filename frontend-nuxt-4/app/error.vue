<script setup lang="ts">
import type { NuxtError } from "#app";

const props = defineProps<{
  error: NuxtError;
}>();

const { t } = useI18n();

useHead({ title: t("errorPage.title") });

// Nuxt doesn't always provide a statusMessage, so fall back to generic copy.
const description = computed(
  () => props.error.statusMessage || t("errorPage.description"),
);
</script>

<template>
  <div>
    <HeaderNew />
    <main id="content" class="container error-page">
      <div class="error-content">
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
        <h1>{{ error.statusCode }}</h1>
        <p>{{ description }}</p>

        <a class="btn-primary" :href="t('errorPage.backHomeUrl')">
          {{ t("errorPage.backHome") }}
        </a>
      </div>
    </main>
    <Footer />
  </div>
</template>

<style scoped>
.error-page {
  max-width: var(--max-content-width);
  padding-top: var(--spacer-32);
  padding-bottom: var(--spacer-64);
}

.error-content {
  min-height: 50vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: var(--spacer-16);
  text-align: center;

  svg {
    color: var(--danger-dark);
    width: 3rem;
    height: 3rem;
  }

  h1 {
    margin: 0;
    font-size: 2.5rem;
  }

  p {
    margin: 0;
  }
}
</style>
