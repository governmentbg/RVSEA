import { IResponseResult } from "@/interfaces/responseResult";

export class ResponseResult {
  constructor(obj: IResponseResult) {
    Object.assign(this, obj);
    this.success = obj.success;
    this.code = obj.code;
    this.showMessage = obj.showMessage;
    //this.data = obj.data;
  }
  success: boolean;
  code: number;
  message?: string;
  showMessage: boolean;
  data?: unknown;
}
