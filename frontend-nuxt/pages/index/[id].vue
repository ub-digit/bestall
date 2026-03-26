<script setup lang="ts">
// contact backend to check if order is valid, if not show error message, otherwise redirect to orderform
definePageMeta({});
const route = useRoute();

const errorObj = ref(null);
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

const handleSignOut = async () => {
  const { signOut } = useAuth();
  if (route.query?.[hideGUAuthParamName] === hideGUAuthParamValue) {
    await signOut({ redirect: false });
  }
};

try {
  const { data, error } = await useFetch(
    `/api/verifyMaterial/${route.params.id}`,
  );
  if (error.value) {
    errorObj.value = error.value as any;
  } else {
    await handleSignOut();
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
} finally {
  // do nothing
}
</script>

<template>
  <div>
    <OrderDenied v-if="errorObj" :error="errorObj" />
  </div>
</template>

<style scoped></style>
