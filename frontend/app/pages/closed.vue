<script setup lang="ts">
const runtimeConfig = useRuntimeConfig();
const { locale } = useI18n();
const contactUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.ubContactUrlEn
    : runtimeConfig.public.ubContactUrlSv,
);
</script>
<template>
  <div class="site-closed">
    <h2>{{ $t("site.closed.title") }}</h2>
    <i18n-t keypath="site.closed.description" tag="p">
      <template #contactLink>
        <a :href="contactUrl">
          {{ $t("site.closed.contactLink") }}
        </a>
      </template>
    </i18n-t>
  </div>
</template>

<style scoped></style>
