<script setup lang="ts">
definePageMeta({
  middleware: ["auth"],
});
</script>
<template>
  <div class="docs">
    <h2 class="h1">Docs</h2>
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
