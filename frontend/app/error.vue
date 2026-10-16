<script setup lang="ts">
import type { NuxtError } from "#app";
import type { ContactRequest } from "~/shared/types/ContactRequest";
const loading = useLoginLoading();
const route = useRoute();

const showRedirectMessage = computed(() => biblio.value?.redirect_url);

const contactRequest = ref<ContactRequest>({
  subject: "",
  title: "",
  bibid: "",
});

const props = defineProps<{
  error: NuxtError;
}>();

const config = useRuntimeConfig();
const { locale } = useI18n();
const contactUrl = computed(() =>
  locale.value === "en"
    ? config.public.ubContactUrlEn
    : config.public.ubContactUrlSv,
);
const ubHomeUrl = computed(() =>
  locale.value === "en" ? config.public.ubHomeUrlEn : config.public.ubHomeUrlSv,
);

const pageTitle = computed(() => $t("errorPage.title"));
const description = computed(
  () => props.error.statusMessage || $t("errorPage.description"),
);

useHead({
  title: pageTitle,
  meta: [{ name: "description", content: description }],
});

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

const openContactLink = () => {
  window.location.href = contactLink.value;
};

const contactLink = computed(() => {
  const params = new URLSearchParams();
  Object.entries(contactRequest.value).forEach(([key, value]) => {
    if (value) params.append(key, String(value));
  });
  return contactUrl.value + `?${params.toString()}`;
});

try {
  loading.value = true;
  await fetchBiblioDetails();
  if (biblio.value?.redirect_url) {
    window.location.href = biblio.value.redirect_url;
  }
  contactRequest.value.subject = $t("errorPage.contactLink.subject");
  contactRequest.value.title = biblio.value?.title || "";
  contactRequest.value.bibid = bibId.value || "";
} catch (error) {
  console.error("Failed to fetch order details:", error);
} finally {
  loading.value = false;
}
</script>

<template>
  <div class="error-layout">
    <LoadingOverlay />
    <HeaderNew />
    <main id="content" class="container error-page">
      <div class="error-content">
        <svg
          class="error-icon"
          xmlns="http://www.w3.org/2000/svg"
          width="32"
          height="32"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <!-- Icon from Material Symbols by Google - https://github.com/google/material-design-icons/blob/master/LICENSE -->
          <path
            fill="currentColor"
            d="M8 13h8q.425 0 .713-.288T17 12t-.288-.712T16 11H8q-.425 0-.712.288T7 12t.288.713T8 13m4 9q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22"
          />
        </svg>

        <h1>{{ $t("errorPage.title") }}</h1>
        <p v-if="$config.public.debugInfo">{{ error.statusCode }}</p>
        <p v-if="$config.public.debugInfo">{{ description }}</p>
        <pre v-if="$config.public.debugInfo">{{ error }}</pre>
        <p v-if="showRedirectMessage">
          {{ $t("errorPage.redirecting") }} <br />
          <br />
          {{ $t("errorPage.redirectLink") }}
          <a :href="biblio.value?.redirect_url">{{
            $t("errorPage.redirectLink")
          }}</a>
        </p>

        <ul v-if="error?.data?.data?.errors.errors?.length" class="error-list">
          <li
            v-for="(item, index) in error?.data?.data.errors.errors"
            :key="index"
          >
            <i18n-t :keypath="'orderDenied.errors.' + item.code" tag="span">
            </i18n-t>
          </li>
        </ul>
        <div class="error-actions">
          <a class="btn-link" :href="ubHomeUrl">
            {{ $t("errorPage.backHome") }}
          </a>
          <button
            v-if="showForm && config.public.showErrorContactForm"
            class="btn-primary"
            type="button"
            @click="openContactLink()"
          >
            {{ $t("errorPage.contactLink.open") }}
            <svg
              class="external-link-icon"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              aria-hidden="true"
              focusable="false"
            >
              <path
                fill="currentColor"
                d="M19 19H5V5h7V3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7h-2zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3z"
              />
            </svg>
          </button>
        </div>
      </div>
    </main>
    <Footer />
  </div>
</template>

<style scoped>
.error-layout {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.error-page {
  flex: 1 0 auto;
  width: 100%;
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

    .error-icon {
      color: var(--danger-dark);
      width: 3rem;
      height: 3rem;
    }

    .external-link-icon {
      width: 0.7rem;
      height: 0.7rem;
      margin-inline-start: 0.25em;
      vertical-align: baseline;
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
