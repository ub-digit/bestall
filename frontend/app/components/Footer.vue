<script setup lang="ts">
const { locale, rt, tm } = useI18n();
const runtimeConfig = useRuntimeConfig();
const footerLinks = computed(
  () => tm("footer.links.items") as Array<{ label: string }>,
);
const footerLogoUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.guHomeUrlEn
    : runtimeConfig.public.guHomeUrlSv,
);
const footerLinkUrls = computed(() => {
  if (locale.value === "en") {
    return [
      runtimeConfig.public.footerLibraryUrlEn,
      runtimeConfig.public.footerContactUrlEn,
      runtimeConfig.public.footerAccessibilityUrlEn,
    ];
  }
  return [
    runtimeConfig.public.footerLibraryUrlSv,
    runtimeConfig.public.footerContactUrlSv,
    runtimeConfig.public.footerAccessibilityUrlSv,
  ];
});
</script>

<template>
  <footer>
    <div class="container">
      <div class="footer-content-wrapper">
        <section class="footer-logo">
          <a :href="footerLogoUrl">
            <img :src="$t('footer.logo.src')" :alt="$t('footer.logo.alt')"
          /></a>
        </section>
        <section class="footer-info">
          <h3>
            {{ $t("footer.contact.header") }}
          </h3>
          <address v-html="$t('footer.contact.address')"></address>
          <div>
            {{ $t("footer.contact.phone") }}
          </div>
          <div>{{ $t("footer.contact.orgNr") }}</div>
        </section>
        <section class="footer-links">
          <h3>{{ $t("footer.links.header") }}</h3>
          <ul>
            <li v-for="(link, index) in footerLinks" :key="link.label + index">
              <a :href="footerLinkUrls[index]">{{ rt(link.label) }}</a>
            </li>
          </ul>
        </section>
      </div>
    </div>
  </footer>
</template>

<style scoped>
@import url("~/assets/css/footer.css");
</style>
