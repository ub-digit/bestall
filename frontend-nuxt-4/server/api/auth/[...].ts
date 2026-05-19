import { NuxtAuthHandler } from "#auth";
import GithubProvider from "next-auth/providers/github";
import CredentialsProvider from "next-auth/providers/credentials";
import { parseStringPromise } from "xml2js";

const runtimeConfig = useRuntimeConfig();

const getUserData = async (userid: string) => {
  const userdata = await fetch(
    runtimeConfig.kohaAuthUrl +
      `/cgi-bin/koha/svc/members/get?&login_userid=${runtimeConfig.kohaUser}&login_password=${runtimeConfig.kohaPwd}&borrower=${userid}`,
    {
      method: "GET",
      headers: { "Content-Type": "text/xml" },
    },
  );
  const userdataXml = await userdata.text();
  const userdataJson = await parseStringPromise(userdataXml, {
    explicitArray: false,
    mergeAttrs: true,
  });
  return userdataJson.response.borrower;
};

export default NuxtAuthHandler({
  pages: {
    // Change the default behavior to use `/login` as the path for the sign-in page
    signIn: "/login",
  },
  events: {
    async signIn(message) {
      /* on successful sign in */
      // console.log("singed In", message);
    },
    async signOut(message) {
      //console.log("signed out:", message);
    },
  },

  callbacks: {
    /* on before signin */
    async signIn({ user, account, profile, email, credentials }) {
      console.log("SignIn callback called with user:", user);
      console.log("SignIn callback called with account:", account);
      console.log("SignIn callback called with profile:", profile);
      console.log("SignIn callback called with email:", email);
      console.log("SignIn callback called with credentials:", credentials);

      if (account?.provider === "credentials") {
        //user = await getUserData(credentials?.username || ""); // Fetch user data from Koha using the username from the credentials.
        // fetch user details from Koha and add to the user object here if needed
        // console.log("Authenticated user:", user);
      }
      return true;
    },
    /* on redirect to another url */
    async redirect({ url, baseUrl }) {
      console.log("Redirect to:", url);
      return url.startsWith(baseUrl) ? url : baseUrl;
    },
    /* on session retrival */
    async session({ session, user, token }) {
      /*       console.log("Session callback called with session:", session);
      console.log("Session callback called with user:", user);
      console.log("Session callback called with token:", token); */
      // extend session object
      session.user.categorycode = token.userData.categorycode;
      session.user.borrowernumber = token.userData.borrowernumber;
      session.user.cardnumber = token.userData.cardnumber;
      session.user.fullname =
        token.userData.firstname + " " + token.userData.surname;
      session.user.userid = token.userData.userid;

      // provider specific session handling can be done here
      switch (token.provider) {
        case "github":
          break;
        case "GU":
          break;
        case "credentials":
          break;
      }
      return session;
    },
    /* on JWT token creation or mutation */
    async jwt({ token, user, account, profile, isNewUser }) {
      /*       console.log("JWT callback called with token:", token);
      console.log("JWT callback called with user:", user);
      console.log("JWT callback called with account:", account);
      console.log("JWT callback called with profile:", profile); //?.login */
      ("");
      switch (account?.provider) {
        case "github": {
          const xaccount = runtimeConfig.xaccountMapToGithub;
          token.provider = "github";
          console.log(
            "Fetching user data from Koha for GitHub user:",
            xaccount,
          );
          token.userData = await getUserData(xaccount); // Store the entire borrower object in the token for later use
          return token;
        }
        case "GU":
          token.provider = "GU";
          break;
        case "credentials":
          token.provider = "credentials";
          console.log("User ID from credentials provider:", user.id);
          token.userData = await getUserData(user.id);
          break;
      }
      return token;
    },
  },
  // A secret string you define, to ensure correct encryption
  secret: runtimeConfig.apiSecret,
  providers: [
    // @ts-expect-error Use .default here for it to work during SSR.
    GithubProvider.default({
      clientId: runtimeConfig.public.githubClientId,
      clientSecret: runtimeConfig.githubClientSecret,
      async profile(profile: any) {
        return {
          id: profile.id,
          name: profile.name || profile.login,
          email: profile.email,
          xaccount: profile.login,
        };
      },
    }),
    {
      id: "GU",
      name: "GU",
      type: "oauth",
      wellKnown: "https://idp.auth.gu.se/adfs/.well-known/openid-configuration",
      authorization: { params: { scope: "openid email profile" } },
      idToken: true,
      clientId: runtimeConfig.guClientId,
      clientSecret: runtimeConfig.guClientSecret,
      async profile(profile) {
        return {
          id: profile.sub,
          name: profile.account,
          email: profile.email,
          account: profile.account,
        };
      },
    },
    CredentialsProvider.default({
      // The name to display on the sign in form (e.g. 'Sign in with...')
      name: "Credentials",
      async authorize(credentials: any) {
        console.log("Authorize with credentials:", credentials);
        const url =
          runtimeConfig.kohaAuthUrl +
          `cgi-bin/koha/svc/members/auth_pin?login_userid=${runtimeConfig.kohaUser}&login_password=${runtimeConfig.kohaPwd}&cardnumber=${credentials.username}&pin=${credentials.password}`;
        console.log("Authenticating user with Koha at URL:", url);
        const res = await fetch(url, {
          method: "GET",
          headers: { "Content-Type": "text/xml" },
        });
        const xml = await res.text();
        if (xml.includes("true")) {
          return { id: credentials.username, name: credentials.username };
        }
        return false; // or null
      },
    }),
  ],
});
