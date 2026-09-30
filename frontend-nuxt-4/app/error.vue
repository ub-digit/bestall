<script setup lang="ts">
import type { NuxtError } from "#app";
import type { ContactRequest } from "~/shared/types/ContactRequest";
const loading = useLoginLoading();
const route = useRoute();

const contactRequest = ref<ContactRequest>({
  firstName: "",
  lastName: "",
  display_info: [],
  email: "",
  title: "",
  bibid: "",
  message: "",
});

const props = defineProps<{
  error: NuxtError;
}>();

useHead({ title: $t("errorPage.title") });

const description = computed(
  () => props.error.statusMessage || $t("errorPage.description"),
);
const contactSubmitted = ref(false);
const contactError = ref("");
const contactModalOpen = ref(false);

const submitContactForm = async () => {
  try {
    loading.value = true;
    contactError.value = "";
    const result = await $fetch("/api/contact", {
      method: "POST",
      body: contactRequest.value,
    });
    console.log("Contact API result:", result);
    contactSubmitted.value = true;
  } catch (error) {
    console.error("Failed to submit contact form:", error);
    contactError.value = $t("errorPage.contactForm.error");
  } finally {
    loading.value = false;
  }
};

const cancelContactForm = () => {
  contactRequest.value = {
    firstName: "",
    lastName: "",
    display_info: [],
    email: "",
    title: "",
    message: "",
    bibid: "",
  };
  window.location.href = $t("errorPage.backHomeUrl");
};

const firstErrorCode = computed(
  () => props.error?.data?.data?.errors.errors?.[0]?.code,
);

const fetchBiblioDetails = async () => {
  if (bibId.value) {
    try {
      const data = await $fetch(`/api/biblios/${bibId.value}?force=true`);
      biblio.value = data;
    } catch (error) {
      console.error("Failed to fetch order details:", error);
    }
  }
};

const bibId = computed(() => route?.params?.id);
const biblio = ref(null);

const showForm = computed(
  () =>
    firstErrorCode.value === "CAN_NOT_BE_BORROWED" ||
    firstErrorCode.value === "RESTRICTION_AV",
);

if (showForm.value) {
  //fetch order details based on bibId
  try {
    loading.value = true;
    await fetchBiblioDetails();
    contactRequest.value.title = biblio.value?.title || "";
    contactRequest.value.display_info = biblio.value?.display_info || [];
    contactRequest.value.bibid = bibId.value || "";
  } catch (error) {
    console.error("Failed to fetch order details:", error);
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div>
    <LoadingOverlay />
    <HeaderNew />
    <main id="content" class="container error-page">
      <div class="error-content">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="32"
          height="32"
          viewBox="0 0 24 24"
        >
          <!-- Icon from Material Symbols by Google - https://github.com/google/material-design-icons/blob/master/LICENSE -->
          <path
            fill="currentColor"
            d="M8 13h8q.425 0 .713-.288T17 12t-.288-.712T16 11H8q-.425 0-.712.288T7 12t.288.713T8 13m4 9q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22"
          />
        </svg>
        <h1 class="hidden">{{ error.statusCode }}</h1>
        <p class="hidden">{{ description }}</p>
        <ul v-if="error?.data?.data?.errors.errors?.length" class="error-list">
          <li
            v-for="(item, index) in error?.data?.data.errors.errors"
            :key="index"
          >
            <span v-html="$t('orderDenied.errors.' + item.code)"></span>
          </li>
        </ul>
        <div class="error-actions">
          <a class="btn-link" :href="$t('errorPage.backHomeUrl')">
            {{ $t("errorPage.backHome") }}
          </a>
          <button
            v-if="showForm"
            class="btn-primary"
            type="button"
            @click="contactModalOpen = true"
          >
            {{ $t("errorPage.contactForm.open") }}
          </button>
        </div>
      </div>

      <BaseModal
        v-if="showForm"
        v-model="contactModalOpen"
        :title="$t('errorPage.contactForm.title')"
        :close-label="$t('modal.close')"
      >
        <ContactForm
          :contact-request="contactRequest"
          :loading="loading"
          :submitted="contactSubmitted"
          :error="contactError"
          @submit="submitContactForm"
          @cancel="cancelContactForm"
        />
      </BaseModal>
    </main>
    <Footer />
  </div>
</template>

<style scoped>
.error-page {
  max-width: var(--max-content-width);
  padding-top: var(--spacer-32);
  padding-bottom: var(--spacer-32);
  .error-content {
    min-height: 30vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: var(--spacer-16);
    text-align: center;

    .error-list {
      font-size: 0.8rem;
      margin: 0;
      padding: 0;
      list-style: none;
    }

    svg {
      color: var(--danger-dark);
      width: 3rem;
      height: 3rem;
    }

    h1 {
      margin: 0;
      font-size: 2.5rem;
    }

    p {
      margin: 0;
    }

    .debug {
    }

    .error-actions {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: var(--spacer-32);
    }
  }
}
</style>
