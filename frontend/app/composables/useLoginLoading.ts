// Shared across all login methods so a single overlay reflects any in-flight sign-in.
export const useLoginLoading = () => useState<boolean>("login-loading", () => false);
