<script setup lang="ts"></script>
<template>
  <div class="site-closed">
    <h2>{{ $t("site.closed.title") }}</h2>
    <p v-html="$t('site.closed.description')"></p>
  </div>
</template>

<style scoped></style>
