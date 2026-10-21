# Nuxt Minimal Starter

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

## Setup

Make sure to install dependencies:

```bash
# npm
npm install

```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev
```

## Local OAuth sign-in

The Docker Compose development override starts a mock OpenID Connect server
at `http://localhost:8090` and enables the **Local mock sign-in** button. The
mock server's interactive login lets you choose a test identity; the identity
is used as the account name when loading user data. The browser uses `localhost`
for authorization, while the frontend container uses `host.docker.internal`
for token and key requests. The mock server is only included in the local
development override, not in the base or release Compose configurations.

## Production

Build the application for production:

````bash
# npm
npm run build



Locally preview production build:

```bash
# npm
npm run preview


Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
````
