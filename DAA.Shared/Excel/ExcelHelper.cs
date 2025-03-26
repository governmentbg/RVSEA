using DAA.Shared.DynamicObjects;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using OfficeOpenXml;
using OfficeOpenXml.DataValidation;
using System.Drawing;
using System.Reflection;

namespace DAA.Shared.Excel
{
    public static class ExcelHelper
    {
        public static void FormatHeaderColumns(ExcelWorksheet workSheet, int startRow, int endRow, int startColumn, int endColumn)
        {
            for (int i = startRow; i <= endRow; i++)
            {
                workSheet.Row(i).Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
            }

            Color lightBlue = Color.FromArgb(187, 220, 235);
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Top.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Top.Color.SetColor(lightBlue);
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Right.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Right.Color.SetColor(lightBlue);
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Bottom.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Bottom.Color.SetColor(lightBlue);
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Left.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Border.Left.Color.SetColor(lightBlue);

            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Fill.BackgroundColor.SetColor(Color.FromArgb(233, 244, 249));
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Font.Color.SetColor(Color.FromArgb(0, 63, 89));
        }

        public static void FormatSheet(ExcelWorksheet workSheet, int startColumn, int endColumn, int startRow, int endRow)
        {
            workSheet.Cells[startRow, startColumn, endRow, endColumn].Style.Font.Color.SetColor(Color.FromArgb(0, 63, 89));
            workSheet.Cells[workSheet.Dimension.Address].AutoFitColumns();
        }

        public static void AddGridDataToSheet<T>(ExcelWorksheet workSheet, IEnumerable<T>? gridColumns, IEnumerable<object>? gridData, IStringLocalizer<SharedResources> localizer)
        {
            if (gridColumns == null || !gridColumns.Any() || gridData == null || !gridData.Any())
            {
                return;
            }

            var headers = DynamicObjectHelper.PrepareHeadersForExport(gridColumns);
            if (headers == null || headers.Count == 0)
            {
                return;
            }

            var data = DynamicObjectHelper.GetGridDataForExport(gridColumns, gridData, localizer, false);

            int row = 1;
            int col = 0;
            foreach (dynamic columnItem in headers)
            {
                row = 1;
                col++;

                // set column header
                workSheet.Cells[row, col].Value = columnItem.headerValue;

                // set rows data in that column
                foreach (dynamic rowItem in data)
                {
                    row++;
                    var dictionary = rowItem as IDictionary<string, object>;

                    workSheet.Cells[row, col].Value = dictionary?[columnItem.dataMetaPropertyValue];
                    if (string.Equals(columnItem.typeValue, "date"))
                    {
                        workSheet.Cells[row, col].Style.Numberformat.Format = "dd.MM.yyyy";
                    }
                    else if (string.Equals(columnItem.typeValue, "duration"))
                    {
                        var value = workSheet.Cells[row, col].Value;

                        if (value == null || value.ToString() == "")
                        {
                            workSheet.Cells[row, col].Value = "00:00:00";
                            continue;
                        }

                        int valueInt = int.Parse((string)value);

                        int hours = valueInt / 3600;
                        int minutes = (valueInt % 3600) / 60;
                        int seconds = (valueInt % 3600) % 60;

                        string hoursStr = "";
                        string minutesStr = "";
                        string secondsStr = "";

                        if (hours <= 9) hoursStr = $"0{hours}";
                        else hoursStr = hours.ToString();

                        if (minutes <= 9) minutesStr = $"0{minutes}";
                        else minutesStr = minutes.ToString();

                        if (seconds <= 9) secondsStr = $"0{seconds}";
                        else secondsStr = seconds.ToString();


                        workSheet.Cells[row, col].Value = $"{hoursStr}:{minutesStr}:{secondsStr}";
                    }
                    else if (string.Equals(columnItem.typeValue, "number"))
                    {
                        workSheet.Cells[row, col].Style.Numberformat.Format = "# ##0.00";
                    }
                    else if (string.Equals(columnItem.typeValue, "int"))
                    {
                        workSheet.Cells[row, col].Style.Numberformat.Format = "# ##0";
                    }
                    else if (string.Equals(columnItem.typeValue, "bytes"))
                    {
                        if (workSheet.Cells[row, col].Value != null && workSheet.Cells[row, col].Value != "")
                        {
                            var value = workSheet.Cells[row, col].Value;

                            value = Double.Parse((string)value) / 1024f / 1024f;

                            workSheet.Cells[row, col].Value = value;

                            workSheet.Cells[row, col].Style.Numberformat.Format = "# ##0.00";
                        }
                        else
                        {
                            continue;
                        }
                    }
                }
            }

            FormatHeaderColumns(workSheet, 1, 1, 1, gridColumns.Count());
            workSheet.Cells[workSheet.Dimension.Address].AutoFitColumns();
        }

        public static T GetModelFromRow<T>(ExcelWorksheet workSheet, int startColumn, int endColumn, int dataRow, int rowWithProperty, IEnumerable<ExcelDDL> ddlLists)
        {
            bool isDataRow = false;
            T obj = (T)Activator.CreateInstance(typeof(T), null);
            for (int col = startColumn; col <= endColumn; col++)
            {
                object rawValue = workSheet.Cells[dataRow, col].Value;

                // do not change it any more once we find a non-null value 
                isDataRow = !isDataRow ? (rawValue != null && !String.IsNullOrWhiteSpace(rawValue.ToString())) : isDataRow;

                // first row contains entity properties names
                string propName = workSheet.Cells[rowWithProperty, col].Value != null ? workSheet.Cells[rowWithProperty, col].Value.ToString() : String.Empty;
                ExcelDropDownListType listType = ExportModelHelper.GetPropFKListType<T>(propName);
                string listStringProp = ExportModelHelper.GetPropFKStringProp<T>(propName);

                if (listType != ExcelDropDownListType.None && rawValue != null)
                {
                    ExcelDDL ddl = ddlLists.FirstOrDefault(x => x.ListType == listType);
                    if (ddl != null)
                    {
                        ExcelDDLItem ddlItem = ddl.Collection.Where(x => x.DisplayName.ToLower() == rawValue.ToString().ToLower()).FirstOrDefault();
                        if (ddlItem != null)
                        {
                            rawValue = ddlItem.Value;
                        }

                        if (!String.IsNullOrEmpty(listStringProp))
                        {
                            ExportModelHelper.SetPropertyValue<T>(listStringProp, rawValue, obj);
                        }
                    }
                }

                ExportModelHelper.SetPropertyValue<T>(propName, rawValue, obj);
            }

            return isDataRow ? obj : default;
        }

        public static void AddDisplayNamesRow<T>(ExcelWorksheet workSheet, int colCnt)
        {
            // row for display names
            workSheet.InsertRow(2, 1);
            workSheet.Cells[1, 1, 1, colCnt].Copy(workSheet.Cells[2, 1, 2, colCnt]);

            for (int i = 1; i <= colCnt; i++)
            {
                string propName = workSheet.Cells[1, i].Value.ToString();
                string displayName = ExportModelHelper.GetDisplayName<T>(propName).ToString();
                workSheet.Cells[2, i].Value = displayName;
            }
        }

        public static void AddModelDataToSheet<T>(ExcelWorkbook workBook, ExcelWorksheet workSheet, IEnumerable<T> dataObjects, IEnumerable<ExcelDDL> listsCollection, bool withData, bool doFormat)
        {
            if (dataObjects == null)
                return;

            MemberInfo[] membersToInclude = ExportModelHelper.GetMembersToExport<T>();

            if (workSheet.Dimension == null)
                workSheet.Cells.LoadFromCollection(dataObjects, true, OfficeOpenXml.Table.TableStyles.None, BindingFlags.Instance | BindingFlags.Public, membersToInclude);
            else
                workSheet.Cells[workSheet.Dimension.Rows + 1, 1].LoadFromCollection(dataObjects, false, OfficeOpenXml.Table.TableStyles.None, BindingFlags.Instance | BindingFlags.Public, membersToInclude);

            if (doFormat)
            {
                int propCnt = membersToInclude.Length;
                List<int> columnsToLock = new List<int>();

                AddDisplayNamesRow<T>(workSheet, propCnt);
                FormatHeaderColumns(workSheet, 1, 2, 1, propCnt);
                FormatDataInColumns<T>(workSheet, 1, propCnt, 1);


                int maxDataRowsCnt = 1000;
                if (workSheet.Dimension != null)
                    maxDataRowsCnt += workSheet.Dimension.Rows + 1;

                for (int col = 1; col <= propCnt; col++)
                {
                    string propName = workSheet.Cells[1, col].Value.ToString();
                    ExcelDropDownListType listType = ExportModelHelper.GetPropFKListType<T>(propName);
                    bool lockColumn = ExportModelHelper.IsLocked<T>(propName);
                    bool allowFKValues = ExportModelHelper.AllowFKValues<T>(propName);

                    if (lockColumn)
                        columnsToLock.Add(col);

                    if (listType != ExcelDropDownListType.None)
                    {
                        ExcelDDL list = listsCollection.FirstOrDefault(x => x.ListType == listType);
                        if (list != null)
                        {
                            #region Replace value with ddl display name
                            for (int row = 3; withData && row < workSheet.Dimension.Rows + 3; row++)
                            {
                                object cellValue = workSheet.Cells[row, col].Value;
                                if (cellValue != null)
                                {
                                    string cellDisplayValue = "";
                                    ExcelDDLItem item = null;

                                    if (bool.TryParse(cellValue.ToString(), out bool cellValueBool))
                                    {
                                        item = list.Collection.FirstOrDefault(x => (bool)x.Value == cellValueBool);
                                    }
                                    else if (int.TryParse(cellValue.ToString(), out int cellValueInt))
                                    {
                                        item = list.Collection.FirstOrDefault(x => (int)x.Value == cellValueInt);
                                    }
                                    else
                                    {
                                        item = list.Collection.FirstOrDefault(x => x.Value.ToString() == cellValue.ToString());
                                    }

                                    if (item != null)
                                        cellDisplayValue = item.DisplayName;

                                    workSheet.Cells[row, col].Value = cellDisplayValue;
                                }
                            }
                            #endregion


                            // add drop down list in column
                            string[] ddlList = list.Collection.Select(x => x.DisplayName).ToArray();
                            AddDropDownListInColumn(workBook, workSheet, col, 3, maxDataRowsCnt, ddlList, listType.ToString(), false);
                        }
                    }
                }

                // call this at the end because of the columns autofit
                FormatSheet(workSheet, 1, propCnt, 3, maxDataRowsCnt);

                // lock for editing the headers and the configured columns 
                int[] columnsToLockArray = columnsToLock.Count() > 0 ? columnsToLock.ToArray() : null;
                LockAreas(workSheet, new int[] { 1, 2 }, columnsToLockArray);
            }

        }

        public static void AddDropDownListInColumn(ExcelWorkbook workBook, ExcelWorksheet workSheet, int column, int startRow, int endRow, string[] list, string listName, bool allowNonFKValues = false)
        {
            if (workBook.Worksheets.FirstOrDefault(s => s.Name == listName) == null)
            {
                // add the list in a separate sheet and then reference it in the formula
                var listSheet = workBook.Worksheets.Add(listName);
                listSheet.Cells.LoadFromCollection(list, false);
                listSheet.Cells[listSheet.Dimension.Address].AutoFitColumns();

                // lock the list for editing 
                LockAreas(listSheet, null, new int[] { 1 });
            }

            string formula = $"={listName}!$A$1:$A${list.Length}";

            var excelDDL = workSheet.Cells[startRow, column, endRow, column].DataValidation.AddListDataValidation() as ExcelDataValidationList;
            excelDDL.AllowBlank = true;
            excelDDL.Formula.ExcelFormula = formula;
            if (allowNonFKValues)
            {
                excelDDL.ErrorStyle = ExcelDataValidationWarningStyle.information;
            }
            else
            {
                excelDDL.ErrorStyle = ExcelDataValidationWarningStyle.stop;
                excelDDL.ShowErrorMessage = true;
                excelDDL.Error = "Моля изберете валидна стойност от списъка!";
            }
        }

        public static void FormatDataInColumns<T>(ExcelWorksheet workSheet, int startColumn, int endColumn, int rowWithProperties)
        {
            for (int i = startColumn; i <= endColumn; i++)
            {
                string propName = workSheet.Cells[rowWithProperties, i].Value.ToString();

                var propType = typeof(T).GetProperty(propName).PropertyType;
                if (propType == typeof(decimal) || propType == typeof(decimal?))
                    workSheet.Column(i).Style.Numberformat.Format = "# ##0.00";
                else if (propType == typeof(DateTime) || propType == typeof(DateTime?))
                    workSheet.Column(i).Style.Numberformat.Format = Constants.DateTimeFormatStr;
                else if (propType == typeof(int) || propType == typeof(int?))
                    workSheet.Column(i).Style.Numberformat.Format = "# ##0";

            }
        }

        public static void LockAreas(ExcelWorksheet workSheet, int[] rowsToLock, int[] columnsToLock)
        {
            workSheet.Cells.Style.Locked = false;

            if (rowsToLock != null && rowsToLock.Length > 0)
            {
                foreach (int row in rowsToLock)
                    workSheet.Row(row).Style.Locked = true;
            }

            if (columnsToLock != null && columnsToLock.Length > 0)
            {
                foreach (int column in columnsToLock)
                    workSheet.Column(column).Style.Locked = true;
            }

            workSheet.Protection.IsProtected = true;
            workSheet.Protection.AllowFormatColumns = true;
        }


    }
}
