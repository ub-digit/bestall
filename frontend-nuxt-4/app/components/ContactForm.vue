<script setup lang="ts">
import type { ContactRequest } from "~/shared/types/ContactRequest";

defineProps<{
  contactRequest: ContactRequest;
  loading: boolean;
  submitted: boolean;
  error: string;
}>();

const emit = defineEmits<{
  submit: [];
  cancel: [];
}>();
</script>

<template>
  <div class="error-form">
    <p v-if="submitted" role="status" aria-live="polite">
      {{ $t("errorPage.contactForm.success") }}
    </p>
    <form v-else class="form" @submit.prevent="emit('submit')">
      <p v-if="error" role="alert" aria-live="assertive">
        {{ error }}
      </p>
      <label for="title">{{ $t("errorPage.contactForm.label.subject") }}</label>
      <input
        id="title"
        v-model="contactRequest.title"
        type="text"
        name="title"
        required
        :placeholder="$t('errorPage.contactForm.label.subject')"
      />
      <label for="bibid">{{ $t("errorPage.contactForm.label.bibid") }}</label>
      <input
        id="bibid"
        v-model="contactRequest.bibid"
        type="text"
        name="bibid"
        required
        disabled
        :placeholder="$t('errorPage.contactForm.label.bibid')"
      />
      <div class="name-section">
        <div class="name-field">
          <label for="firstName">
            {{ $t("errorPage.contactForm.label.firstName") }}
          </label>
          <input
            id="firstName"
            v-model="contactRequest.firstName"
            type="text"
            name="firstName"
            required
            :placeholder="$t('errorPage.contactForm.label.firstName')"
          />
        </div>
        <div class="name-field">
          <label for="lastName">
            {{ $t("errorPage.contactForm.label.lastName") }}
          </label>
          <input
            id="lastName"
            v-model="contactRequest.lastName"
            type="text"
            name="lastName"
            required
            :placeholder="$t('errorPage.contactForm.label.lastName')"
          />
        </div>
      </div>
      <label for="email">{{ $t("errorPage.contactForm.label.email") }}</label>
      <input
        id="email"
        v-model="contactRequest.email"
        type="email"
        name="email"
        required
        :placeholder="$t('errorPage.contactForm.label.email')"
      />
      <label for="message">{{
        $t("errorPage.contactForm.label.message")
      }}</label>
      <textarea
        id="message"
        v-model="contactRequest.message"
        name="message"
        required
        :placeholder="$t('errorPage.contactForm.label.message')"
      ></textarea>
      <div class="form-actions">
        <button
          class="btn-primary"
          type="submit"
          :disabled="
            loading ||
            !contactRequest.email ||
            !contactRequest.title ||
            !contactRequest.bibid ||
            !contactRequest.firstName ||
            !contactRequest.lastName ||
            !contactRequest.message
          "
        >
          {{ $t("errorPage.contactForm.label.submit") }}
        </button>
        <button class="btn-secondary" type="button" @click="emit('cancel')">
          {{ $t("errorPage.contactForm.label.cancel") }}
        </button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.error-form {
  display: flex;
  flex-direction: column;
  gap: var(--spacer-16);
  align-items: center;
  form {
    display: flex;
    flex-direction: column;
    gap: 0;
    margin-inline: auto;
    width: 100%;
    max-width: var(--reading-width);
    border: 1px solid var(--dark-light);
    padding: var(--spacer-16);
    border-radius: var(--border-radius);

    > label {
      margin-top: var(--spacer-16);
    }

    > label:first-child {
      margin-top: 0;
    }

    > label + input,
    > label + textarea {
      margin-top: var(--spacer-8);
    }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--spacer-16);
      margin-top: var(--spacer-16);

      button {
        width: fit-content;
      }
    }

    .name-section {
      display: grid;
      gap: var(--spacer-16);
      margin-top: var(--spacer-16);

      .name-field {
        display: flex;
        flex-direction: column;
      }
    }

    @media (min-width: 48rem) {
      .name-section {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }
  }
}
</style>
