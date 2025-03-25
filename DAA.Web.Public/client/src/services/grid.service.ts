/* eslint-disable @typescript-eslint/no-explicit-any */
import { appStore } from "@/store/app";
import http from "@/services/http.service";
import { GridColumn, GridExport, GridOptions } from "@/models/grid";

class GridService {
  baseUrl = appStore().getters.baseUrl + "/api/grid";

  exportCurrentPage(
    fileType: string,
    columns: Array<GridColumn>,
    currentData: any[]
  ): Promise<GridExport> {
    return new Promise((resolve, reject) => {
      http
        .post(`${this.baseUrl}/exportCurrentPage`, {
          columns: columns,
          data: currentData,
          fileType: fileType,
        })
        .then((result) => {
          resolve(result.data);
        })
        .catch((error) => {
          reject(error);
        });
    });
  }

  exportAll(
    fileType: string,
    columns: Array<GridColumn>,
    options: any,
    businessObjectType: string,
    exportParams: any,
    exportOptions: GridOptions
  ): Promise<GridExport> {
    return new Promise((resolve, reject) => {
      http
        .post(`${this.baseUrl}/exportAll`, {
          columns: columns,
          options: options,
          businessObjectType: businessObjectType,
          businessObjectParams: exportParams,
          fileType: fileType,
          exportOptions,
        })
        .then((result) => {
          resolve(result.data);
        })
        .catch((error) => {
          reject(error);
        });
    });
  }
}

const gridService = new GridService();
export default gridService;
