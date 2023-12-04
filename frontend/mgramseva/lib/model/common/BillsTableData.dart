import '../../utils/models.dart';

class BillsTableData{
  List<TableHeader> tableHeaders;
  List<TableDataRow> tableData;
  bool isEmpty(){
    return tableData.isEmpty;
  }
  BillsTableData(this.tableHeaders, this.tableData);
}