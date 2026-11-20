<script setup lang="ts"></script>
<template>
  <div id="back-to-top-link">
    <a href="#top">Up ↑</a>
  </div>
</template>

<style scoped>
#back-to-top-link {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  background-color: var(--brand-base);
  padding: 0.5rem 1rem;
  border-radius: 4px;
  z-index: 1000;
  a {
    color: var(--light-light);
    text-decoration: none;
    &:hover {
      text-decoration: underline;
    }
  }
}
</style>
