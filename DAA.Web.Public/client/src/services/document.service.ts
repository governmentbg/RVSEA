import { GridOptions } from "@/models/grid";
import http from "@/services/http.service";
import { appStore } from "@/store/app";
import { IDocument } from "@/interfaces/document";
import { defaultGuidString } from "@/helpers/format.helper";

class DocumentService {
  private url = appStore().getters.baseUrl + "/api/documents";

  async getArchivalEntityDocuments(
    options: GridOptions,
    archivalEntitySysId?: string,
    archivalEntityHasExternalSource?: boolean,
    archivalEntityExternalIdentifier?: number,
    searchArchivalEntityNumber?: string,
    searchArchivalEntityStartSheet?: number,
    searchArchivalEntityEndSheet?: number
  ) {
    const url = new URL(
      `${this.url}/listByArchivalEntity/${archivalEntitySysId ?? ""}`
    );
    if (archivalEntityHasExternalSource) {
      url.searchParams.append(
        "archivalEntityHasExternalSource",
        archivalEntityHasExternalSource.toString()
      );
    }
    if (archivalEntityHasExternalSource && archivalEntityExternalIdentifier) {
      url.searchParams.append(
        "archivalEntityExternalIdentifier",
        archivalEntityExternalIdentifier.toString()
      );
    }
    if (searchArchivalEntityNumber) {
      url.searchParams.append(
        "searchArchivalEntityNumber",
        searchArchivalEntityNumber
      );
    }
    if (searchArchivalEntityStartSheet) {
      url.searchParams.append(
        "searchArchivalEntityStartSheet",
        searchArchivalEntityStartSheet.toString()
      );
    }
    if (searchArchivalEntityEndSheet) {
      url.searchParams.append(
        "searchArchivalEntityEndSheet",
        searchArchivalEntityEndSheet.toString()
      );
    }

    const response = await http.post(url.toString(), options);
    return response.data.data;
  }

  async displayDocument(
    sysId?: string,
    hasExternalSource?: boolean,
    externalIdentifier?: number
  ): Promise<IDocument> {
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

  async displayDocumentDraft(sysId: string): Promise<IDocument> {
    const url = new URL(`${this.url}/getDraft/${sysId ?? defaultGuidString}`);
    
    const response = await http.get(url.toString());
    return response.data.data;
  }

  async modifyDocumentDraft(data: IDocument) {
    const response = await http.post(`${this.url}`, { ...data});
    return response;
  }
}

const documentService = new DocumentService();
export default documentService;
