import type { LoanType } from "#shared/types/LoanType";

export const useLoanTypes = () => {
  const loanTypes = useState<LoanType[]>("loanTypes", () => [] as LoanType[]);
  /**
   * Updates the loan types state with the provided partial data.
   * @param data - Partial loan type object containing the properties to update
   */
  const setLoanTypes = (data: Partial<LoanType>) => {
    Object.assign(loanTypes.value, data);
  };

  const resetLoanTypes = () => {
    Object.assign(loanTypes.value, []);
  };

  return {
    loanTypes,
    setLoanTypes,
    resetLoanTypes,
  };
};
