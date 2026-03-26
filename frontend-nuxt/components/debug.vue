<script setup lang="ts">
import type { Order } from "~/types/Order";
import type { Biblio } from "~/types/Biblio";

const props = defineProps<{
  order: Order | null;
  biblio: any; // Replace with actual Biblio type if available
}>();
const { status, data: authData } = useAuth();
</script>
<template>
  <div>
    <div v-if="$config.public.debugInfo" class="debug">
      <h4>Debug Information</h4>

      <h5>User</h5>
      <pre class="json-debug">{{ JSON.stringify(authData, null, 2) }}</pre>
      <h5>Raw Order</h5>
      <pre class="json-debug">{{ JSON.stringify(order, null, 2) }}</pre>

      <h5>Raw Biblio</h5>
      <pre class="json-debug">{{ JSON.stringify(biblio, null, 2) }}</pre>
    </div>
  </div>
</template>

<style scoped>
.debug {
  margin-top: 10rem;
  .json-debug {
    background: #f6f8fa;
    color: #24292e;
    font-family: "Fira Mono", "Menlo", "Monaco", "Consolas", monospace;
    font-size: 0.5em;
    padding: 1em;
    border-radius: 6px;
    overflow-x: auto;
    white-space: pre-wrap;

    margin-bottom: 1em;
    border: 1px solid #e1e4e8;
  }
}
</style>
