export function useAppSignOut() {
  const { signOut } = useAuth();
  const route = useRoute();
  const localePath = useLocalePath();
  const runtimeConfig = useRuntimeConfig();

  const handleSignOut = async () => {
    await signOut({ redirect: false });

    const hideGUAuthParamName = runtimeConfig.public.hideGUAuthParamName;

    await navigateTo(
      localePath({
        path: "/login",
        query: {
          redirect: route.fullPath,
          [hideGUAuthParamName]:
            route.query[hideGUAuthParamName]?.toString() || "",
        },
      }),
    );
  };

  return {
    handleSignOut,
  };
}
