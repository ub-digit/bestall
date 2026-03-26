export default {
  scrollBehavior(to, from, savedPosition) {
    // Back/forward button keeps position
    if (savedPosition) {
      return savedPosition;
    }

    // Always scroll to top on route change
    return { top: 0 };
  },
};
