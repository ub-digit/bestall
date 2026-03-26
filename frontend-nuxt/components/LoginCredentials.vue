<script setup lang="ts">
const { status, data, signIn } = useAuth();
const { t } = useI18n();
const cardnumber = ref("");
const pin = ref("");
const errorLogin = ref("");

const handleSignIn = async () => {
  const { error, url } = await signIn("credentials", {
    username: cardnumber.value,
    password: pin.value,
    redirect: false,
  });
  if (error) {
    errorLogin.value = t("login.kohaAuth.invalidCredentials");
  } else {
    // No error, continue with the sign in, e.g., by following the returned redirect:
    errorLogin.value = "";
    return navigateTo(url, { external: true });
  }
};
</script>
<template>
  <div class="login-credentials">
    <header>{{ $t("login.kohaAuth.title") }}</header>
    <p class="description">{{ $t("login.kohaAuth.description") }}</p>
    <form @submit.prevent="handleSignIn()">
      <div v-if="errorLogin" class="danger-base-text">{{ errorLogin }}</div>
      <div>
        <label for="cardnumber">{{
          $t("login.kohaAuth.labelCardnumber")
        }}</label>
        <input
          v-model="cardnumber"
          type="text"
          inputmode="numeric"
          pattern="[0-9]+"
          name="cardnumber"
          id="cardnumber"
          :placeholder="t('login.kohaAuth.labelCardnumber')"
          required
        />
      </div>
      <div>
        <label for="pin">{{ $t("login.kohaAuth.labelPin") }}</label>
        <input
          v-model="pin"
          type="password"
          inputmode="numeric"
          pattern="[0-9]+"
          maxlength="4"
          name="pin"
          id="pin"
          :placeholder="t('login.kohaAuth.labelPin')"
          required
        />
      </div>

      <button type="submit" class="btn-secondary">
        {{ $t("login.kohaAuth.button") }}
      </button>
    </form>

    <div class="links">
      <NuxtLink external :to="t('login.kohaAuth.links.forgotPin.url')">
        {{ $t("login.kohaAuth.links.forgotPin.label") }}
      </NuxtLink>
      <NuxtLink external :to="t('login.kohaAuth.links.register.url')">
        {{ $t("login.kohaAuth.links.register.label") }}
      </NuxtLink>
    </div>
  </div>
</template>

<style scoped>
.login-credentials {
  > header {
    font-size: 1.5rem;
    font-weight: 700;
  }

  .links {
    margin-top: var(--spacer-16);
    display: flex;
    flex-direction: column;
    gap: var(--spacer-16);
  }
  form {
    display: flex;
    flex-direction: column;
    gap: var(--spacer-16);
    padding: 1rem;

    color: var(--dark-dark);

    > button {
      margin-top: var(--spacer-16);
    }
  }
}
</style>
