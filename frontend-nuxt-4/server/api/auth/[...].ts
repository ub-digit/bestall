import { NuxtAuthHandler } from "#auth";
import GithubProvider from "next-auth/providers/github";
import CredentialsProvider from "next-auth/providers/credentials";
import { parseStringPromise } from "xml2js";

const runtimeConfig = useRuntimeConfig();

const getUserData = async (xaccount: string) => {
  const userdata = await fetch(
    runtimeConfig.kohaAuthUrl +
      `/cgi-bin/koha/svc/members/get?&login_userid=${runtimeConfig.kohaUser}&login_password=${runtimeConfig.kohaPwd}&borrower=${xaccount}`,
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
  console.log("Koha user data JSON:", userdataJson);
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
        /* ### URL should point to bestall-server and have it return json to avoid this xml-to-json conversion ### */
        const kohaMemberUrl =
          runtimeConfig.kohaAuthUrl +
          `/cgi-bin/koha/svc/members/get?&login_userid=${runtimeConfig.kohaUser}&login_password=${runtimeConfig.kohaPwd}&borrower=${credentials?.username}`;
        console.log("Fetching user data from Koha at URL:", kohaMemberUrl);
        const userdata = await fetch(kohaMemberUrl, {
          method: "GET",
          headers: {
            Accept: "text/xml",
            "current-username": credentials?.username || "",
          },
        });
        const userdataXml = await userdata.text();
        const userdataJson = await parseStringPromise(userdataXml, {
          explicitArray: false,
          mergeAttrs: true,
        });
        console.log("Koha user data XML:", userdataXml);
        console.log("Koha user data JSON:", userdataJson.response.borrower);
        user.name =
          userdataJson.response.borrower.firstname +
          " " +
          userdataJson.response.borrower.surname;

        // fetch user details from Koha and add to the user object here if needed
        console.log("Authenticated user:", user);
      }
      return true;
    },
    /* on redirect to another url */
    async redirect({ url, baseUrl }) {
      console.log("Redirecting to:", url);
      return url.startsWith(baseUrl) ? url : baseUrl;
    },
    /* on session retrival */
    async session({ session, user, token }) {
      console.log("Session callback called with session:", session);
      console.log("Session callback called with user:", user);
      console.log("Session callback called with token:", token);
      // fetch all user details from koha
      if (token.provider === "github") {
        session.user.categorycode = token.userData.categorycode;
        session.user.borrowernumber = token.userData.borrowernumber;
        session.user.cardnumber = token.userData.cardnumber;
        session.user.userid = token.userData.userid;
      } else if (token.provider === "GU") {
        // Handle GU-specific session data if needed
      } else if (token.provider === "credentials") {
        // Handle credentials-specific session data if needed
      }
      return session;
    },
    /* on JWT token creation or mutation */
    async jwt({ token, user, account, profile, isNewUser }) {
      console.log("JWT callback called with token:", token);
      console.log("JWT callback called with user:", user);
      console.log("JWT callback called with account:", account);
      console.log("JWT callback called with profile:", profile); //?.login
      ("");
      if (account?.provider === "github") {
        const xaccount = runtimeConfig.xaccountMapToGithub;
        token.provider = "github";
        if (token.provider === "github") {
          console.log(
            "Fetching user data from Koha for GitHub user:",
            xaccount,
          );
          token.userData = await getUserData(xaccount); // Store the entire borrower object in the token for later use
          return token;
        }
      } else if (account?.provider === "GU") {
        token.provider = "GU";
      } else if (account?.provider === "credentials") {
        token.provider = "credentials";
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
        console.log("Koha auth url:", url);
        const xml = await res.text();
        if (xml.includes("true")) {
          return { id: credentials.username, name: credentials.username };
        }
        return false; // or null
      },
    }),
  ],
});
