<script setup lang="ts">
definePageMeta({});
const runtimeConfig = useRuntimeConfig();
const route = useRoute();
const localePath = useLocalePath();
const errorObj = ref(null);
if (runtimeConfig.public.applicationIsClosed) {
  navigateTo(localePath("/closed"));
}

if (!route?.params?.id) {
  errorObj.value = {
    statusCode: 400,
    statusMessage: "Bad request, missing id parameter",
  };
} else {
}
</script>

<template>
  <div>
    <!-- handle case where id parameter is missing and /id/ will not be rendered -->
    <OrderDenied v-if="errorObj" :error="errorObj">
      <template #description>
        <p v-html="$t('orderDenied.descriptionWithMissingId')"></p>
      </template>
    </OrderDenied>
    <NuxtPage />
  </div>
</template>

<style scoped></style>
