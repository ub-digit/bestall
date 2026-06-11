// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  runtimeConfig: {
    apiSecret: "",
    authOrigin: "",
    xaccountMapToGithub: "",
    githubClientSecret: "",
    guClientSecret: "",
    apiBase: "",

    public: {
      debugInfo: false,
      reserveNoteMaxLength: "",
      disableLoantypeHomeAndPickupForItemtypes: "",
      disableLoantypeHomeAndPickupForNotforloan: "",
      includeLoantypeSDForUserCategories: "",
      enabledAuth: "",
      showAuthStatus: false,
      hideGUAuthParamName: "",
      hideGUAuthParamValue: "",
      localeParamName: "",
      myLoansUrl: "",
      applicationIsClosed: false /* default to false if not set, since it's a new feature and we don't want to accidentally break things for users who haven't set it up yet. */,
      dateFormat: "sv-SE",
      githubClientId: "",
      guClientId: "",
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

  experimental: {
    // Workaround for Nuxt 4.4.5 + ssr:false regression
    // "No entry found in rollupOptions.input" — see nuxt/nuxt#35033 (fix in #35037, awaiting release)
    viteEnvironmentApi: true,
  },
  ssr: true,
  compatibilityDate: "2025-07-15",
  devtools: { enabled: false },
  modules: ["@nuxtjs/i18n", "@sidebase/nuxt-auth"],
  vite: {
    optimizeDeps: {
      include: ["@vue/devtools-core", "@vue/devtools-kit"],
    },
  },
  i18n: {
    strategy: "prefix_except_default",
    defaultLocale: "sv",
    locales: [
      { code: "en", name: "English", file: "en.json" },
      { code: "sv", name: "Svenska", file: "sv.json" },
    ],
    compilation: {
      strictMessage: false /* allows html in translations */,
      escapeHtml: false, // how to make it secure ask Stefan
    },
  },
  auth: {
    originEnvKey: "AUTH_ORIGIN",
    //baseURL: "http://localhost:3000/api/auth",
    provider: {
      type: "authjs",
    },
    globalAppMiddleware: false,
  },
});
