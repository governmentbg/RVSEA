import { AxiosError } from "axios";

export interface IResponseResult {
  success: boolean;
  code: number;
  message?: string;
  showMessage: boolean;
  data?: unknown;
}
