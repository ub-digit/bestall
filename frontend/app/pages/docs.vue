<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});
</script>
<template>
  <div class="docs">
    <h1 class="h1">Docs</h1>
    <DocsNav id="nav" />
    <DocsHero id="hero" />
    <DocsSearch id="search" />
    <DocsColors id="colors" />
    <DocsResponsivness id="responsivness" />
    <DocsTypography id="typography" />
    <DocsButtons id="buttons" />
    <DocsLogotypes id="logotypes" />
    <DocsIcons id="icons" />

    <DocsBackToTopLink />
  </div>
</template>

<style scoped>
.docs {
  > * {
    margin-bottom: var(--spacer-32);
  }
}
</style>
