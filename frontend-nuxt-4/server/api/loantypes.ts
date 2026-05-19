import type { LoanType } from "#shared/types/LoanType";
import { getServerSession } from "#auth";
import { Item } from "~~/shared/types/Biblio";

export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    throw createError({ statusCode: 401, statusMessage: "Unauthorized" });
  }

  let { locale, current_item } = getQuery(event) as {
    locale?: string; // used to determine which localized name property to use for the loan types, defaults to "sv" if missing
    current_item?: Item;
  };
  if (!locale) {
    locale = "sv"; // if missing add default locale
  }
  const userParsed = session.user; // Use the user data from the session, which is more secure and reliable than the one passed as a query parameter. The query parameter is only used as a fallback if the session user data is not available for some reason.
  console.log("User fetched from session on server:", userParsed);
  const runtimeConfig = useRuntimeConfig();

  const data: any = await $fetch(`${runtimeConfig.apiBase}/loan_types`, {
    method: "POST", // Use POST method to send user data in the request body, which is more secure than sending it as query parameters
    body: {
      current_user: userParsed, // Pass the entire user object from the session to the API for potential user-specific filtering. This is more secure and reliable than passing user data through query parameters.
      current_item: current_item
        ? JSON.parse(JSON.stringify(current_item))
        : null, // Pass current item-type for potential item-specific filtering in the API
    },
    headers: {
      current_username: userParsed?.cardnumber || "", // Pass the username from the session to the API for potential user-specific filtering
    },
  });

  const isLoantypeDisabled = (loanType: LoanType) => {
    // construct array with codes to check
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
        disableLoantypeHomeAndPickupForNotForLoan.includes(not_for_loan) ||
        disableLoantypeHomeAndPickupForItemTypes.includes(item_type)
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
    return extendedLoanTypes;
  } catch (error) {
    console.error("Error fetching loan types:", error);
    return error;
  }
});
