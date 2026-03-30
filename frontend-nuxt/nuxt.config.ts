// https://nuxt.com/docs/api/configuration/nuxt-config

export default defineNuxtConfig({
  runtimeConfig: {
    apiSecret: "NOT_A_SECRET",
    authOrigin: "",
    baseUrl: "",
    xaccountMapToGithub: "not_your_xaccount",
    githubClientSecret: "not_your_github_client_secret",
    guClientSecret: "not_your_gu_client_secret",
    kohaUser: "not_a_user",
    kohaPwd: "not_a_pwd",
    kohaAuthUrl: "https://koha-auth.not-an-auth.com/auth",
    apiBase: "https://api.not-an-api.com",

    public: {
      debugInfo: false,
      reserveNoteMaxLength: parseInt(
        "140",
        10,
      ) /* default to 140 if not set or set to an invalid value */,
      disableLoantypeHomeAndPickupForItemTypes: "",
      disableLoantypeHomeAndPickupForNotForLoan: "",
      includeLoantypeSDForUserCategories: "",
      enabledAuth: "github",
      hideGUAuthParamName: "hideGUAuthParam",
      hideGUAuthParamValue: "hideGUAuthValue",
      localeParamName: "language",
      myLoansUrl: "https://not-myloans.example.com",
      applicationIsClosed: false /* default to false if not set, since it's a new feature and we don't want to accidentally break things for users who haven't set it up yet. */,
      dateFormat: "sv-SE",
      githubClientId: "not_your_github_client_id",
      guClientId: "not_your_gu_client_id",
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
    originEnvKey: "AUTH_ORIGIN",
    provider: {
      type: "authjs",
    },
    globalAppMiddleware: false,
    baseURL: "",
  },
});
