import { NuxtAuthHandler } from "#auth";
import GithubProvider from "next-auth/providers/github";
import CredentialsProvider from "next-auth/providers/credentials";

const runtimeConfig = useRuntimeConfig();

const getUserData = async (userid: string) => {
  console.log("Fetching user data for user ID:", userid);
  // users/current
  const data = await fetch(runtimeConfig.apiBase + `/users/current`, {
    method: "GET",
    headers: { "current-username": userid },
  });
  const userdataJson = await data.json();
  return userdataJson;
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
      return true;
    },
    /* on redirect to another url */
    async redirect({ url, baseUrl }) {
      console.log("Redirect to:", url);
      return url.startsWith(baseUrl) ? url : baseUrl;
    },
    /* on session retrival */
    async session({ session, user, token }) {
      console.log("Session callback called with session:", token);
      session.user.categorycode = token.userData.user_category;
      session.user.cardnumber = token.userData.cardnumber;
      session.user.fullname =
        token.userData.first_name + " " + token.userData.last_name;
      session.user.userid = token.userData.id;
      session.user.warning = token.userData.warning;
      session.user.pickupCode = token.userData.pickup_code;

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
      console.log("JWT callback called with token:", token);
      console.log("JWT callback called with user:", user);
      console.log("JWT callback called with account:", account);
      console.log("JWT callback called with profile:", profile);
      switch (account?.provider) {
        case "github": {
          const xaccount = runtimeConfig.xaccountMapToGithub;
          token.provider = "github";
          console.log(
            "Fetching user data from Koha for GitHub user:",
            xaccount,
          );
          const data = await getUserData(xaccount); // Store the entire borrower object in the token for later use
          token.userData = data.user;
          return token;
        }
        case "GU":
          token.provider = "GU";
          console.log(
            "Fetching user data from Koha for GU user:",
            profile.account,
          );
          const data = await getUserData(profile.account); // Store the entire borrower object in the token for later use
          token.userData = data.user;
          return token;
          break;
        case "credentials":
          token.provider = "credentials";
          console.log("User ID from credentials provider:", user.id);
          const data_cred = await getUserData(user.id); // Store the entire borrower object in the token for later use
          token.userData = data_cred.user;
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
      clientId: runtimeConfig.public.guClientId,
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
        const url = `${runtimeConfig.apiBase}/users/authenticate?username=${credentials.username}&password=${credentials.password}`;
        const res = await fetch(url, {
          method: "GET",
        });
        console.log("Koha authentication response status:", res);
        const data = await res.json();
        console.log("Koha authentication response data:", data);
        if (data.authenticated) {
          return { id: credentials.username, name: credentials.username }; // ends up as user in the session callback, and as user in the jwt callback, where you can fetch additional user data from Koha and add it to the token for use in the session callback later on.
        }
        return false; // or null
      },
    }),
  ],
});
