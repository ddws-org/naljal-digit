import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mgramseva/model/file/file_store.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:path/path.dart' as path;

class FilePickerDemo extends StatefulWidget {
  final Function(List<FileStore>?) callBack;
  final String? moduleName;
  final List<String>? extensions;
  final GlobalKey? contextKey;

  const FilePickerDemo({Key? key, required this.callBack, this.moduleName, this.extensions, this.contextKey}) : super(key: key);
  @override
  FilePickerDemoState createState() => FilePickerDemoState();
}

class FilePickerDemoState extends State<FilePickerDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _selectedFiles = <dynamic>[];
  List<FileStore> _fileStoreList = <FileStore>[];
  String? _directoryPath;
  String? _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;
  TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  FileUploadStatus fileUploading = FileUploadStatus.NOT_ACTIVE;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      var paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: widget.extensions ?? ((_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null),
      ))
          ?.files;

      if(paths != null){
        var isNotValidSize = false;
        for(var path in paths){
          if (!(await CommonMethods.isValidFileSize(path.size))) isNotValidSize = true;
        }

        if(isNotValidSize){
          Notifiers.getToastMessage(context, i18.common.FILE_SIZE, 'ERROR');
          return;
        }
        if(_multiPick){
          _selectedFiles.addAll(paths);
        }else{
          _selectedFiles = paths;
        }

        List<dynamic> files = paths;
        if(!kIsWeb){
          files = paths.map((e) => File(e.path ?? '')).toList();
        }

        uploadFiles(files);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
    });
  }

  uploadFiles(List<dynamic> files) async {
    try{
      setState(() {
        fileUploading = FileUploadStatus.STARTED;
      });
      var response = await CoreRepository().uploadFiles(files, widget.moduleName ?? APIConstants.API_MODULE_NAME);
      setState(() {
        fileUploading = FileUploadStatus.COMPLETED;
      });
      _fileStoreList.addAll(response);
      if(_selectedFiles.isNotEmpty)
        widget.callBack(_fileStoreList);
    }catch(e){
      setState(() {
        fileUploading = FileUploadStatus.NOT_ACTIVE;
      });
      Notifiers.getToastMessage(context, e.toString(), 'ERROR');
    }
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result! ? Colors.green : Colors.red,
          content: Text((result
              ? '${ApplicationLocalizations.of(context).translate(i18.common.TEMPORARY_FILES_REMOVED)}'
              : '${ApplicationLocalizations.of(context).translate(i18.common.FALIED_TO_FETCH_TEMPORARY_FILES)}')),
        ),
      );
    });
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _directoryPath = value);
    });
  }

  _getConatiner(constraints, context) {
    return [
      Container(
          width: constraints.maxWidth > 760
              ? MediaQuery.of(context).size.width / 3
              : MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 18, bottom: 3),
          child: new Align(
              alignment: Alignment.centerLeft,
              child: Text("${ApplicationLocalizations.of(context).translate(i18.common.ATTACH_BILL)}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                  color: Theme.of(context).primaryColorDark)))),
      Container(
          width: constraints.maxWidth > 760
              ? MediaQuery.of(context).size.width / 2.5
              : MediaQuery.of(context).size.width,
          // height: 50,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 4.0, right: 16.0, top: 4.0 , bottom: 4.0),
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0XFFD6D5D4)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        )
                        ),
                    onPressed: () => selectDocumentOrImage(),
                    child: Text(
                      "${ApplicationLocalizations.of(context).translate(i18.common.CHOOSE_FILE)}",
                      style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 16),
                    ),
                  )),
            _selectedFiles.isNotEmpty ?
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 3,
                    children : List.generate(_selectedFiles.length, (index) => Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 2,
                      children: [
                        Text(_selectedFiles[index] is File ? (path.basename(_selectedFiles[index].path)) : _selectedFiles[index].name,
                        maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        IconButton(
                            padding: EdgeInsets.all(5),
                            onPressed: ()=> onClickOfClear(index), icon: Icon(Icons.cancel))
                      ],
                    )).toList()),
              ),
            )
            : Text(
                "${ApplicationLocalizations.of(context).translate(i18.common.NO_FILE_UPLOADED)}",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Row(
                children: [
                  fileUploading==FileUploadStatus.STARTED?Text("${ApplicationLocalizations.of(context).translate(i18.common.UPLOADING_FILE)}",style: TextStyle(
                      color: Colors.black
                  ),):SizedBox(),
                  fileUploading==FileUploadStatus.STARTED?Transform.scale(
                    scale: 0.5,
                    child: CircularProgressIndicator(),
                  )
                      :fileUploading==FileUploadStatus.COMPLETED?Icon(Icons.check_circle,color: Theme.of(context).primaryColor,)
                      :SizedBox(),
                ],
              )
            ],
          ))
    ];
  }

  void onClickOfClear(int index){
    setState(() {
      _selectedFiles.removeAt(index);
      fileUploading = FileUploadStatus.NOT_ACTIVE;
    if(index < _fileStoreList.length)  _fileStoreList.removeAt(index);
    });
    widget.callBack(_fileStoreList);
  }

  void reset(){
    setState(() {
      fileUploading = FileUploadStatus.NOT_ACTIVE;
    });
    _selectedFiles.clear();
    _fileStoreList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SingleChildScrollView(
                child: Container(
                  key: widget.contextKey,
                  margin: constraints.maxWidth > 760 ? const EdgeInsets.only(
                      top: 5.0, bottom: 5, right: 10, left: 10) : const EdgeInsets.only(
                      top: 5.0, bottom: 5, right: 0, left: 0),
                  child: constraints.maxWidth > 760
                      ? Row(children: _getConatiner(constraints, context))
                      : Column(children: _getConatiner(constraints, context))
                  ,
                ),
              )));
    });
  }


  Future<void> selectDocumentOrImage() async {
    FocusScope.of(context).unfocus();
    var list = [
      {
        "label" :  i18.common.CAMERA,
        'icon' : Icons.camera_alt
      },
      {
        "label" :  i18.common.FILE_MANAGER,
        'icon' : Icons.drive_folder_upload
      },
    ];

    if(kIsWeb){
      _openFileExplorer();
      return ;
    }

    callBack(String value){
      Navigator.pop(context);
      if(list.first['label'] == value){
        imagePath(context, selectionMode: 'camera');
      }else{
        imagePath(context, selectionMode: 'filePicker');
      }
    }

    await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
         return Padding(
           padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25, top: 10),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children : [
               Container(
                 padding: EdgeInsets.symmetric(vertical: 8),
                 alignment: Alignment.center,
                 child: Container(
                   height: 2,
                   width: 30,
                   color: Colors.grey,
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(bottom: 16, top: 5),
                 child: Text(ApplicationLocalizations.of(context).translate(i18.common.CHOOSE_AN_ACTION), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: list.map((e) => _buildIcon(e['label'] as String,e['icon'] as IconData, callBack)).toList()
             ),
           ]
           ),
         );
        });
  }


  Future<void> imagePath(BuildContext context, { required String selectionMode}) async {
    FocusScope.of(context).unfocus();
    try {
      if (selectionMode == 'camera') {
        final pickedFile = await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          String newPath = path.join(path.dirname(pickedFile.path), '${CommonMethods.getRandomName()}${path.extension(pickedFile.path)}');
          final File? file = await File(pickedFile.path).copy(newPath);
          if (file != null) {
            if (!(await CommonMethods.isValidFileSize(await file.length()))){
              Notifiers.getToastMessage(context, i18.common.FILE_SIZE, 'ERROR');
              return;
            }
            if(_multiPick){
              _selectedFiles.addAll([file]);
            }else{
              _selectedFiles = [file];
            }
            uploadFiles(<File>[file]);
            return;
          } else {
            return null;
          }
        } else {
          _openFileExplorer();
        }
      } else {
        _openFileExplorer();
      }
    } on Exception catch (e) {
      Notifiers.getToastMessage(context, e.toString(), 'ERROR');
    }
  }


  Widget _buildIcon(String label, IconData icon, Function(String) callBack){
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
       IconButton(onPressed: ()=> callBack(label), iconSize: 45, icon: Icon(icon)),
        Text( ApplicationLocalizations.of(
            context)
            .translate(label),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15
        ),
        )
      ],
    );
  }
}
