import { NuxtAuthHandler } from "#auth";
import GithubProvider from "next-auth/providers/github";
import CredentialsProvider from "next-auth/providers/credentials";
import { parseStringPromise } from "xml2js";

const runtimeConfig = useRuntimeConfig();

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
      if (account?.provider === "github") {
        const xaccount = runtimeConfig.xaccountMapToGithub;
        token.provider = "github";
        if (token.provider === "github") {
          console.log(
            "Fetching user data from Koha for GitHub user:",
            xaccount,
          );
          const userdata = await fetch(
            runtimeConfig.public.kohaAuthUrl +
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
          token.userData = userdataJson.response.borrower; // Store the entire borrower object in the token for later use
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
      clientId: runtimeConfig.githubClientId,
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
        // You need to provide your own logic here that takes the credentials
        // submitted and returns either a object representing a user or value
        // that is false/null if the credentials are invalid.
        // NOTE: THE BELOW LOGIC IS NOT SAFE OR PROPER FOR AUTHENTICATION!

        /*       const res = await fetch("http://localhost:3000/api/authmock", {
          method: "POST",
          body: JSON.stringify(credentials),
          headers: { "Content-Type": "application/json" },
        });
        const user = await res.json(); */
        const url =
          runtimeConfig.public.kohaAuthUrl +
          `cgi-bin/koha/svc/members/auth_pin?login_userid=${runtimeConfig.kohaUser}&login_password=${runtimeConfig.kohaPwd}&cardnumber=${credentials.username}&pin=${credentials.password}`;
        const res = await fetch(url, {
          method: "GET",
          headers: { "Content-Type": "text/xml" },
        });
        const xml = await res.text();
        const user = { id: null, name: "" };
        console.log("Koha auth response XML:", xml);
        // check if the XML response indicates a successful authentication
        if (xml.includes("true")) {
          const userdata = await fetch(
            runtimeConfig.public.kohaAuthUrl +
              `/cgi-bin/koha/svc/members/get?&login_userid=${runtimeConfig.kohaUser}&login_password=${runtimeConfig.kohaPwd}&borrower=${credentials.username}`,
            {
              method: "GET",
              headers: { "Content-Type": "text/xml" },
            },
          );

          const userdataXml = await userdata.text();
          //console.log("Koha user data XML:", userdataXml);

          const userdataJson = await parseStringPromise(userdataXml, {
            explicitArray: false,
            mergeAttrs: true,
          });
          console.log("Koha user data JSON:", userdataJson.response.borrower);
          user.name =
            userdataJson.response.borrower.firstname +
            " " +
            userdataJson.response.borrower.surname;

          // fetch user details from Koha and add to the user object here if needed
          console.log("Authenticated user:", user);
          return user || null;
        }
        // You can also Reject this callback with an Error thus the user will be sent to the error page with the error message as a query parameter
      },
    }),
  ],
});
