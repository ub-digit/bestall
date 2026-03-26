<script setup lang="ts">
// No script logic needed for this component
</script>
<template>
  <header>
    <!-- header spans full width -->
    <div class="container">
      <div class="header-content-wrapper">
        <div class="header-left">
          <div class="header-logo" alt="logotype">
            <a class="link-reset" :href="$t('header.logo.url')"
              ><img :src="$t('header.logo.src')" :alt="$t('header.logo.alt')"
            /></a>
          </div>
          <div class="header-site-description">
            <h1 class="header-title">
              <a
                :href="$t('header.mainTitle.url')"
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
          <div class="auth-status">
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
