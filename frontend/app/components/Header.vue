<script setup lang="ts">
const runtimeConfig = useRuntimeConfig();
const { locale } = useI18n();
const guHomeUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.guHomeUrlEn
    : runtimeConfig.public.guHomeUrlSv,
);
const ubHomeUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.ubHomeUrlEn
    : runtimeConfig.public.ubHomeUrlSv,
);
</script>
<template>
  <header>
    <!-- header spans full width -->
    <div class="container">
      <div class="header-content-wrapper">
        <div class="header-left">
          <div class="header-logo" alt="logotype">
            <a class="link-reset" :href="guHomeUrl"
              ><img :src="$t('header.logo.src')" :alt="$t('header.logo.alt')"
            /></a>
          </div>
          <div class="header-site-description">
            <h1 class="header-title">
              <a
                :href="ubHomeUrl"
                :title="$t('header.mainTitle.label')"
                >{{ $t("header.mainTitle.title") }}</a
              >
            </h1>
            <div class="header-description">
              {{ $t("header.subTitle") }}
            </div>
          </div>
        </div>
        <div class="header-right">
          <div class="lang">
            <LocaleSwitcher />
          </div>
          <div class="auth-status" v-if="$config.public.showAuthStatus">
            <AuthStatus />
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<style scoped>
@import url("~/assets/css/header.css");
</style>
