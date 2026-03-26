import { LoanType } from "~/types/LoanType";

export default defineEventHandler(async (event) => {
  let { locale, user, itemType, NotForLoan } = getQuery(event) as {
    locale?: string;
    user?: any; // needs to be parsed to json before use, since it's passed as a query parameter. It contains the user data from the session, which is needed to filter loan types based on user category.
    itemType?: string;
    NotForLoan?: string;
  };
  if (!locale) {
    locale = "sv"; // if missing add default locale
  }
  const userParsed = user ? JSON.parse(user) : null; // Parse the user data from the query parameter, if it exists
  const runtimeConfig = useRuntimeConfig();

  const data: any = await $fetch(`${runtimeConfig.public.apiBase}/loan_types`);

  const isLoantypeDisabled = (loanType: LoanType) => {
    const disableLoantypeHomeAndPickupForNotForLoan = runtimeConfig.public
      .disableLoantypeHomeAndPickupForNotForLoan
      ? runtimeConfig.public.disableLoantypeHomeAndPickupForNotForLoan
          .split(",")
          .map((code: string) => code.trim())
      : [];
    const disableLoantypeHomeAndPickupForItemTypes = runtimeConfig.public
      .disableLoantypeHomeAndPickupForItemTypes
      ? runtimeConfig.public.disableLoantypeHomeAndPickupForItemTypes
          .split(",")
          .map((code: string) => code.trim())
      : [];
    if (loanType.id === 1) {
      if (
        disableLoantypeHomeAndPickupForItemTypes.includes(itemType || "") ||
        disableLoantypeHomeAndPickupForNotForLoan.includes(NotForLoan || "")
      ) {
        return true; // Other loan types are not disabled
      }
    }
    return false;
  };
  // Extend original loan types with a localized name property
  const extendedLoanTypes = data.loan_types.map((loanType: LoanType) => ({
    ...loanType,
    name: locale === "sv" ? loanType.name_sv : loanType.name_en,
    isDisabled: isLoantypeDisabled(loanType), // Disable SD loan type for all users by default. It will be enabled later based on user category .
  }));

  // filter ExtendedLoanTypes based on user_category if loanType.id is 5. Only show SD loan type for user categories SD and FT.
  const filteredExtendedLoanTypes = extendedLoanTypes.filter(
    (loanType: LoanType) => {
      if (loanType.id === 5 && userParsed?.categorycode) {
        console.log(
          `Filtering loan type ${loanType.name} for user category ${userParsed.categorycode}`,
        );
        const includeLoantypeSDForUserCategories = runtimeConfig.public
          .includeLoantypeSDForUserCategories
          ? runtimeConfig.public.includeLoantypeSDForUserCategories
              .split(",")
              .map((code: string) => code.trim())
          : [];
        return includeLoantypeSDForUserCategories.includes(
          userParsed.categorycode,
        );
      }
      return true;
    },
  );

  try {
    return filteredExtendedLoanTypes;
  } catch (error) {
    console.error("Error fetching loan types:", error);
    return error;
  }
});
