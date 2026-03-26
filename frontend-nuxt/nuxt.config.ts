// https://nuxt.com/docs/api/configuration/nuxt-config

export default defineNuxtConfig({
  runtimeConfig: {
    apiSecret: process.env.NUXT_API_SECRET || "NOT_A_SECRET",
    authOrigin: "",
    githubClientId:
      process.env.NUXT_GITHUB_CLIENT_ID || "not_your_github_client_id",
    xaccountMapToGithub:
      process.env.NUXT_XACCOUNT_MAP_TO_GITHUB || "not_your_xaccount",
    githubClientSecret:
      process.env.NUXT_GITHUB_CLIENT_SECRET || "not_your_github_client_secret",
    guClientId: process.env.NUXT_GU_CLIENT_ID || "not_your_gu_client_id",
    guClientSecret:
      process.env.NUXT_GU_CLIENT_SECRET || "not_your_gu_client_secret",

    kohaUser: process.env.NUXT_KOHA_USER || "not_a_user",
    kohaPwd: process.env.NUXT_KOHA_PWD || "not_a_pwd",

    public: {
      debugInfo: process.env.NUXT_PUBLIC_DEBUG_INFO === "true" || false,
      reserveNoteMaxLength: parseInt(
        process.env.NUXT_PUBLIC_RESERVE_NOTE_MAX_LENGTH || "140",
        10,
      ),
      disableLoantypeHomeAndPickupForItemTypes:
        process.env
          .NUXT_PUBLIC_DISABLE_LOANTYPE_HOME_AND_PICKUP_FOR_ITEMTYPES || "",
      disableLoantypeHomeAndPickupForNotForLoan:
        process.env
          .NUXT_PUBLIC_DISABLE_LOANTYPE_HOME_AND_PICKUP_FOR_NOTFORLOAN || "",
      includeLoantypeSDForUserCategories:
        process.env.NUXT_PUBLIC_INCLUDE_LOANTYPE_SD_FOR_USER_CATEGORIES || "",
      enabledAuth: process.env.NUXT_PUBLIC_ENABLED_AUTH || "github",
      kohaAuthUrl:
        process.env.NUXT_PUBLIC_KOHA_AUTH_URL ||
        "https://koha-auth.not-an-auth.com/auth",
      apiBase: process.env.NUXT_PUBLIC_API_BASE || "https://api.not-an-api.com",
      hideGUAuthParamName:
        process.env.NUXT_PUBLIC_HIDE_GU_AUTH_PARAM_NAME || "hideGUAuthParam",
      hideGUAuthParamValue:
        process.env.NUXT_PUBLIC_HIDE_GU_AUTH_PARAM_VALUE || "hideGUAuthValue",
      localeParamName: process.env.NUXT_PUBLIC_LOCALE_PARAM_NAME || "language",
      myLoansUrl:
        process.env.NUXT_PUBLIC_MYLOANS_URL ||
        "https://not-myloans.example.com",
      applicationIsClosed:
        process.env.NUXT_PUBLIC_APPLICATION_IS_CLOSED === "true" ||
        false /* default to false if not set, since it's a new feature and we don't want to accidentally break things for users who haven't set it up yet. */,
      dateFormat: process.env.NUXT_PUBLIC_DATE_FORMAT || "sv-SE",
    },
  },
  app: {
    head: {
      htmlAttrs: {
        lang: "en",
      },
      link: [
        {
          rel: "icon",
          type: "image/x-icon",
          href: "https://assets.ub.gu.se/img/favicons/favicon.ico",
        },
      ],
    },
  },
  css: ["~/assets/css/main.css"],

  ssr: true,
  experimental: { appManifest: false },

  compatibilityDate: "2025-07-15",
  devtools: { enabled: false },
  modules: ["@nuxtjs/i18n", "@sidebase/nuxt-auth"],
  i18n: {
    //vueI18n: "./i18n/i18n.config.ts",
    strategy: "prefix_except_default",
    defaultLocale: "sv",
    locales: [
      { code: "en", name: "English", file: "en.json" },
      { code: "sv", name: "Svenska", file: "sv.json" },
    ],
    compilation: {
      strictMessage: false /* allows html in translations */,
      escapeHtml: false,
    },
  },
  auth: {
    globalAppMiddleware: false,
    originEnvKey: "AUTH_ORIGIN",
    provider: {
      type: "authjs",
    },
  },
});
