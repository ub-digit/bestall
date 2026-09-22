<script setup lang="ts">
definePageMeta({});
const { handleSignOut } = useAppSignOut();
const route = useRoute();
const localePath = useLocalePath();

const { setLocale } = useI18n();
const localeParamName = useRuntimeConfig().public.localeParamName;

if (route.query?.[localeParamName] === "swe") {
  setLocale("sv");
} else if (route.query?.[localeParamName] === "eng") {
  setLocale("en");
}

// always invalidate login if sökdator view is used, to prevent GU-auth from showing up when it shouldn't
const hideGUAuthParamName = useRuntimeConfig().public.hideGUAuthParamName;
const hideGUAuthParamValue = useRuntimeConfig().public.hideGUAuthParamValue;

const handleSignOutIfNeeded = async () => {
  if (route.query?.[hideGUAuthParamName] === hideGUAuthParamValue) {
    await handleSignOut({ redirect: false });
  }
};

const { status, signOut } = useAuth();
const { fetchUserData, userData } = useCurrentUserData();
const callbackUrl = (route.query.redirect as string) || useLocalePath()("/");

const { data, error } = await useFetch(
  `/api/verifyMaterial/${route.params.id}`,
);
if (error.value) {
  showError({
    statusCode: error?.value?.statusCode || "unknown code",
    statusMessage: error.value?.statusMessage || "Unknown message",
    data: error.value?.data || null,
  });
} else {
  await handleSignOutIfNeeded();
  await navigateTo(
    localePath({
      path: "/order/" + route.params.id,
      query: {
        [hideGUAuthParamName]: route.query[hideGUAuthParamName] || null,
      }, // pass the hideGUAuth param if it exists in the original route
      replace: true,
    }),
  );
}
</script>

<template>
  <div></div>
</template>

<style scoped></style>
