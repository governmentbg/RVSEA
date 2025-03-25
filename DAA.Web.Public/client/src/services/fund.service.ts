import { IFund } from "@/interfaces/fund";
import http from "@/services/http.service";
import { appStore } from "@/store/app";

class FundService {
  private url = appStore().getters.baseUrl + "/api/funds";

  async displayFund(
    sysId?: string,
    hasExternalSource?: boolean,
    externalIdentifier?: number
  ): Promise<IFund> {
    const url = new URL(`${this.url}/${sysId ?? ""}`);
    if (hasExternalSource) {
      url.searchParams.append(
        "hasExternalSource",
        hasExternalSource.toString()
      );
    }
    if (hasExternalSource && externalIdentifier) {
      url.searchParams.append(
        "externalIdentifier",
        externalIdentifier.toString()
      );
    }
    const response = await http.get(url.toString());
    return response.data.data;
  }
}

const fundService = new FundService();
export default fundService;
