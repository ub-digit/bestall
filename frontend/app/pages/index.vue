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
  showError({
    statusCode: 400,
    statusMessage: "Bad request, missing id parameter",
    data: {
      data: {
        errors: {
          errors: [
            {
              code: "MISSING_ID",
              message: "The id parameter is missing",
            },
          ],
        },
      },
    },
  });
}
</script>

<template>
  <div>
    <NuxtPage />
  </div>
</template>

<style scoped></style>
