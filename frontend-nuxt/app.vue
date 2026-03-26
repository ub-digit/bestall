<script setup lang="ts">
useHead({
  title: $t("site.title"),
  meta: [{ name: "description", content: $t("site.description") }],
  bodyAttrs: {
    id: "top",
  },
});
</script>

<template>
  <!--
      NuxtRouteAnnouncer is a built-in Nuxt component that provides accessible route change announcements for screen readers.
      It helps improve accessibility by notifying users of navigation changes within the application.
      Typically, you should include this component once in your app layout or root component.
    -->
  <NuxtRouteAnnouncer />
  <a href="#content" class="skip-link">{{ $t("app.skipToMainContent") }}</a>

  <Header />
  <main id="content" class="container fix-viewport-height">
    <NuxtPage />
  </main>
  <Footer />
  <div id="progress"></div>
</template>

<style scoped>
@import url("~/assets/css/progress.css");

#content {
  padding-top: var(--spacer-32);
  padding-bottom: var(--spacer-32);
}

a.skip-link {
  position: absolute;
  top: 0;
  left: 0;
  transform: translateY(-200%);
  padding: 0.75rem 1rem;
  background: var(--brand-base);
  color: var(--light-light) !important;
  z-index: 1000;
  text-decoration: none;

  /* Accessibility improvements */
  font-weight: 600;
  line-height: 1;
  &:focus-visible {
    outline: 2px solid var(--dark-dark);
    transform: translateY(0);
  }
}
</style>
