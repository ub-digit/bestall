export type { VerifyError };

type VerifyError = {
  code: string;
  detail: string;
  data: any;
  errors: {
    code: string;
    detail: string;
  }[];
};
