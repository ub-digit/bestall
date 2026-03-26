<script setup lang="ts">
const { signIn } = useAuth();
</script>
<template>
  <div class="gu-auth">
    <img
      :src="$t('login.guAuth.logo.src')"
      :alt="$t('login.guAuth.logo.alt')"
    />
    <header>{{ $t("login.guAuth.title") }}</header>
    <p class="description">{{ $t("login.guAuth.description") }}</p>
    <button class="btn-primary" @click="signIn('gu')">
      {{ $t("login.guAuth.button") }}
    </button>
  </div>
</template>

<style scoped>
.gu-auth {
  img {
    width: 100%;
    margin-bottom: var(--spacer-16);
  }
  > header {
    font-size: 1.5rem;
    font-weight: 700;
  }
  > button {
    margin-top: var(--spacer-16);
  }
  border: 1px solid var(--dark-light);
  border-radius: 0.25rem;
  padding: var(--spacer-32);
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: var(--spacer-16);
}
</style>
