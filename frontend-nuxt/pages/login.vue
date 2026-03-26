<script setup lang="ts">
definePageMeta({
  middleware: "auth",
});
const { signIn } = useAuth();
const route = useRoute();
const runtimeConfig = useRuntimeConfig();
const hideGUAuthParamName = runtimeConfig.public.hideGUAuthParamName;
const hideGUAuthParamValue = runtimeConfig.public.hideGUAuthParamValue;

const enableGUAuth =
  route.query[hideGUAuthParamName] !== hideGUAuthParamValue ? true : false;

const isAuthServiceEnabled = (service: string) => {
  return runtimeConfig.public.enabledAuth.includes(service);
};
</script>
<template>
  <div class="login-wrapper">
    <div class="login">
      <div class="gu-auth" v-if="isAuthServiceEnabled('GU') && enableGUAuth">
        <LoginGU />
      </div>

      <div class="divider" v-if="isAuthServiceEnabled('GU') && enableGUAuth">
        <hr />
        <span>{{ $t("login.or") }}</span>
        <hr />
      </div>

      <div class="koha-auth" v-if="isAuthServiceEnabled('credentials')">
        <LoginCredentials />
      </div>

      <div class="github-auth" v-if="isAuthServiceEnabled('github')">
        <h3>For developers</h3>
        <LoginGithub />
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 80vh;

  .login {
    max-width: 30rem;
    text-align: center;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    gap: var(--spacer-16);
    .koha-auth {
      width: 100%;
    }
    .github-auth {
      margin-top: 5rem;
    }

    .divider {
      margin-top: var(--spacer-16);
      margin-bottom: var(--spacer-16);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: var(--spacer-8);
      width: 100%;
      hr {
        flex-grow: 1;
        border: none;
        border-top: 1px solid var(--dark-light);
      }

      span {
        font-weight: 700;
        color: var(--dark-light);
      }
    }
  }
}
</style>
