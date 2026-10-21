<script setup lang="ts">
const { signIn } = useAuth();
const route = useRoute();
const localePath = useLocalePath();

const loginWithLocal = async () => {
  const callbackUrl =
    window.location.origin +
    localePath((route.query.redirect as string) || localePath("/"));
  await signIn("local", { callbackUrl });
};
</script>

<template>
  <div class="local-auth">
    <h2>{{ $t("login.localAuth.title") }}</h2>
    <p class="description">{{ $t("login.localAuth.description") }}</p>
    <button class="btn-secondary" @click="loginWithLocal()">
      {{ $t("login.localAuth.button") }}
    </button>
  </div>
</template>

<style scoped>
.local-auth {
  border: 1px solid var(--dark-light);
  border-radius: 0.25rem;
  padding: var(--spacer-32);

  > h2 {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 700;
  }

  > button {
    margin-top: var(--spacer-16);
  }
}
</style>
