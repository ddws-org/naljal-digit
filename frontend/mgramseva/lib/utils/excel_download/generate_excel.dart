import 'package:mgramseva/utils/excel_download/save_file_mobile.dart'
    if (dart.library.html) 'package:mgramseva/utils/excel_download/save_file_web.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<void> generateExcel(
    List<String> headers, List<List<String>> tableData,{String title='HouseholdRegister'}) async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  // sheet.showGridlines = false;

  // Enable calculation for worksheet.
  sheet.enableSheetCalculations();

  // //Set data in the worksheet.
  sheet.getRangeByName('A1:D1').columnWidth = 32.5;
  sheet.getRangeByName('A1:D1').cellStyle.hAlign = HAlignType.center;

  for (int i = 0; i < headers.length; i++) {
    sheet
        .getRangeByName('${CommonMethods.getAlphabetsWithKeyValue()[i].label}1')
        .setText(headers[CommonMethods.getAlphabetsWithKeyValue()[i].key]);
  }

  for (int i = 2; i < tableData.length + 2; i++) {
    for (int j = 0; j < headers.length; j++) {
      sheet
          .getRangeByName(
              '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
          .setText(tableData[i - 2][j]);
      sheet
          .getRangeByName(
              '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
          .cellStyle
          .hAlign = HAlignType.center;
      sheet
          .getRangeByName(
              '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
          .cellStyle
          .vAlign = VAlignType.center;
    }
  }

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(bytes, '$title.xlsx');
}
