<template>
  <div class="user-warning-wrapper">
    <!-- Warning content here -->
    <div v-if="user && user.warning" class="user-warning">
      <p class="info">
        {{ $t(`message.userWarning.message`) }}
      </p>
      <div
        v-if="view !== '46GUB_KOHA'"
        class="action"
        v-html="$t('message.userWarning.action')"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { data: authData } = useAuth();
const user = computed(() => authData.value?.user);
const view = useRoute().query.view;
</script>

<style scoped>
.user-warning {
  .action a {
    color: var(--info-dark);
    text-decoration: underline;
    background-color: red;
    &:visited {
      color: red !important;
    }
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
