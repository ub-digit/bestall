<script setup lang="ts">
// Explicitly type the links as an array
const footerLinks = $tm("footer.links.items") as Array<{
  url: string;
  label: string;
}>;
</script>

<template>
  <footer>
    <div class="container">
      <div class="footer-content-wrapper">
        <section class="footer-logo">
          <a :href="$t('footer.logo.url')">
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
          <div>
            <a :href="`mailto:${$t('footer.contact.email')}`">{{
              $t("footer.contact.email")
            }}</a>
          </div>
          <div>{{ $t("footer.contact.orgNr") }}</div>
        </section>
        <section class="footer-links">
          <h3>{{ $t("footer.links.header") }}</h3>
          <ul>
            <li v-for="(link, index) in footerLinks" :key="link.url + index">
              <a :href="$rt(link.url)">{{ $rt(link.label) }}</a>
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
