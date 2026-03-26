<template>
  <div>
    <h2>{{ $t("biblio.title") }}</h2>
    <div class="biblio-card" :data-id="biblio?.id">
      <div class="biblio-card-common">
        <h4>{{ biblio?.title }}</h4>
        <div v-if="biblio?.isbn" class="isbn">
          {{ $t("biblio.isbn", { isbn: biblio?.isbn }) }}
        </div>
        <div v-if="biblio?.edition">
          {{ biblio?.edition }}
        </div>
        <div v-if="biblio?.origin" class="origin">
          {{ biblio?.origin }}
        </div>
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
