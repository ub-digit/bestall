<template>
  <div class="forbidden">
    <OrderDenied v-if="userError" :error="userError">
      <template #description><span></span></template>
    </OrderDenied>
  </div>
</template>

<script setup lang="ts">
const { data, signIn, signOut } = useAuth();
const userError = {
  data: {
    data: data.value?.user?.errors.errors ?? [],
  },
};
</script>

<style scoped></style>
