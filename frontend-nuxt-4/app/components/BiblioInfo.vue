<template>
  <div>
    <h2>{{ $t("biblio.title") }}</h2>
    <div class="biblio-card" :data-id="biblio?.id">
      <div class="biblio-card-common">
        <h4>{{ biblio?.title }}</h4>
        <ul
          class="display-info list-unstyled"
          v-if="biblio?.display_info && biblio.display_info.length"
        >
          <li v-for="info in biblio?.display_info" :key="info">{{ info }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Biblio } from "~/types/Biblio";
const props = defineProps<{
  biblio: Biblio | null;
}>();
</script>

<style scoped>
.biblio-card {
  max-width: calc(var(--reading-width) * 1.5);
  .biblio-card-common {
    h4 {
      max-width: var(--reading-width);
      margin-bottom: var(--spacer-16);
    }
    margin-bottom: var(--spacer-32);
  }
}
</style>
