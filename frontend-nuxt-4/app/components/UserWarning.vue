<template>
  <div class="user-warning-wrapper">
    <!-- Warning content here -->
    <div v-if="user && user.warning" class="user-warning">
      <p class="info">
        {{ $t(`message.userWarning.message`) }}
      </p>
      <i18n-t
        v-if="view !== '46GUB_KOHA'"
        keypath="message.userWarning.action"
        tag="div"
        class="action"
      >
        <template #myLoansLink>
          <a :href="myLoansUrl">
            {{ $t("message.userWarning.myLoansLink") }}
          </a>
        </template>
      </i18n-t>
    </div>
  </div>
</template>

<script setup lang="ts">
const { data: authData } = useAuth();
const user = computed(() => authData.value?.user);
const view = useRoute().query.view;
const runtimeConfig = useRuntimeConfig();
const { locale } = useI18n();
const myLoansUrl = computed(() =>
  locale.value === "en"
    ? runtimeConfig.public.myLoansUrlEn
    : runtimeConfig.public.myLoansUrlSv,
);
</script>

<style scoped>
.user-warning {
  .action a {
    color: var(--info-dark);
    text-decoration: underline;
  }
  p {
    margin: 0;
    margin-bottom: var(--spacer-8);
  }
  border-radius: var(--border-radius);
  padding: var(--spacer-16);
  margin-bottom: var(--spacer-32);
  border: 1px solid var(--info-dark);
  background-color: var(--info-light);
  /* Styles here */
}
</style>
