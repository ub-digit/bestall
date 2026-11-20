<script setup lang="ts">
const { status, data, signIn, signOut } = useAuth();
const { t, locale } = useI18n();
const props = defineProps<{
  kohaView: boolean;
}>();
const runtimeConfig = useRuntimeConfig();
const myLoansBaseUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.myLoansUrlEn
    : runtimeConfig.public.myLoansUrlSv,
);
const libraryCardBaseUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.libraryCardUrlEn
    : runtimeConfig.public.libraryCardUrlSv,
);
const myLoansUrl = computed(
  () => `${myLoansBaseUrl.value.replace(/\/$/, "")}/login?lang=${locale.value}`,
);
const libraryCardUrl = computed(
  () => `${libraryCardBaseUrl.value}?lang=${locale.value}`,
);
const cardnumber = ref("");
const pin = ref("");
const errorLogin = ref("");
const route = useRoute();

const localePath = useLocalePath();

const loading = useLoginLoading();

const handleSignIn = async () => {
  loading.value = true;
  try {
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
      const callbackUrl =
        (route.query.redirect as string) || useLocalePath()("/");
      navigateTo(localePath(callbackUrl));
    }
  } finally {
    loading.value = false;
  }
};
</script>
<template>
  <div class="login-credentials">
    <h2>{{ $t("login.kohaAuth.title") }}</h2>
    <p v-if="!props.kohaView" class="description">
      {{ $t("login.kohaAuth.description") }}
    </p>
    <form @submit.prevent="handleSignIn()">
      <div v-if="errorLogin" class="danger-base-text" role="alert">
        {{ errorLogin }}
      </div>
      <div class="input-group">
        <label for="cardnumber">
          {{
            props.kohaView
              ? $t("login.kohaAuth.labelKohaCardnumber")
              : $t("login.kohaAuth.labelCardnumber")
          }}</label
        >
        <div class="extra-info">
          {{
            props.kohaView
              ? $t("login.kohaAuth.labelKohaCardnumber_description")
              : $t("login.kohaAuth.labelCardnumber_description")
          }}
        </div>
        <input
          v-model="cardnumber"
          type="text"
          inputmode="numeric"
          pattern="[0-9]+"
          name="cardnumber"
          id="cardnumber"
          :placeholder="
            props.kohaView
              ? t('login.kohaAuth.labelKohaCardnumber')
              : t('login.kohaAuth.labelCardnumber')
          "
          required
        />
      </div>
      <div class="input-group">
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
    <div class="info-links-container">
      <div class="info" v-if="props.kohaView">
        <p class="description" v-html="$t('login.kohaAuth.info.header')"></p>
        <p
          class="description"
          v-html="$t('login.kohaAuth.info.body_first')"
        ></p>
        <p
          class="description"
          v-html="$t('login.kohaAuth.info.body_second')"
        ></p>
      </div>
      <div v-else class="links">
        <NuxtLink external :to="myLoansUrl">
          {{ $t("login.kohaAuth.links.forgotPin.label") }}
        </NuxtLink>
        <NuxtLink external :to="libraryCardUrl">
          {{ $t("login.kohaAuth.links.register.label") }}
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-credentials {
  > h2 {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 700;
  }
  .info-links-container {
    color: var(--dark-dark);
    opacity: 0.8;
    .links {
      margin-top: var(--spacer-16);
      display: flex;
      flex-direction: column;
      gap: var(--spacer-16);
    }
  }
  form {
    display: flex;
    flex-direction: column;
    text-align: left;
    .input-group {
      label {
        display: flex;
        justify-content: flex-start;
      }

      .extra-info {
        font-size: 0.875rem;
        color: var(--light-dark);
        margin-top: var(--spacer-8);
      }
    }
    gap: var(--spacer-16);
    padding: 1rem;

    color: var(--dark-dark);

    > button {
      margin-top: var(--spacer-16);
    }
  }
}
</style>
