<script setup lang="ts">
const { status, data, signOut, signIn } = useAuth();

const handleSignOut = async () => {
  await signOut({ redirect: false });
  // After signing out, you might want to redirect the user to a specific page, e.g., home or login
  const { fullPath, query } = useRoute();

  const hideGUAuthParamName = useRuntimeConfig().public.hideGUAuthParamName;

  navigateTo(
    useLocalePath()(
      "/login" +
        `?redirect=${fullPath}&${hideGUAuthParamName}=${query[hideGUAuthParamName] || ""}`,
    ), // 👈 redirect to login with original path as query param
  );
};
</script>
<template>
  <div v-if="status === 'authenticated'" class="auth-status-container">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="32"
      height="32"
      viewBox="0 0 24 24"
    >
      <!-- Icon from Material Symbols by Google - https://github.com/google/material-design-icons/blob/master/LICENSE -->
      <path
        fill="currentColor"
        d="M18 18q.625 0 1.063-.437T19.5 16.5t-.437-1.062T18 15t-1.062.438T16.5 16.5t.438 1.063T18 18m0 3q.75 0 1.4-.35t1.075-.975q-.575-.35-1.2-.513T18 19t-1.275.162t-1.2.513q.425.625 1.075.975T18 21M9 8h6V6q0-1.25-.875-2.125T12 3t-2.125.875T9 6zm3.25 14H6q-.825 0-1.412-.587T4 20V10q0-.825.588-1.412T6 8h1V6q0-2.075 1.463-3.537T12 1t3.538 1.463T17 6v2h1q.825 0 1.413.588T20 10v1.3q-.45-.15-.937-.225T18 11v-1H6v10h5.3q.2.6.4 1.038t.55.962M18 23q-2.075 0-3.537-1.463T13 18t1.463-3.537T18 13t3.538 1.463T23 18t-1.463 3.538T18 23M6 10v10z"
      />
    </svg>
    <div v-html="$t('authStatus.signedInAs', { name: data?.user?.name })"></div>
    <button
      v-if="status === 'authenticated'"
      class="btn-link"
      @click="handleSignOut()"
    >
      {{ $t("authStatus.signOut") }}
    </button>
  </div>
</template>

<style scoped>
.auth-status-container {
  > svg {
    width: 1rem;
    height: 1rem;
  }
  display: flex;
  align-items: center;
  flex-direction: row;
  gap: var(--spacer-8);
}
</style>
