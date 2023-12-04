

import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/models.dart';

class Pagination extends StatefulWidget {
 final int limit;
 final int offSet;
 final int totalCount;
 final Function(PaginationResponse) callBack;
 final bool isDisabled;
 final bool isTotalCountVisible;
 const Pagination({Key? key, required this.limit, required this.offSet, required this.callBack, required this.totalCount, this.isDisabled = false, this.isTotalCountVisible = true}) : super(key: key);

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  @override
  Widget build(BuildContext context) {
    return  Container(
          height: 50,
         alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 18),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(ApplicationLocalizations.of(context)
              .translate(i18.common.ROWS_PER_PAGE)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: DropdownButton(
                  key: Keys.common.PAGINATION_DROPDOWN,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black
                  ),
                    items: dropDownItems,
                value: widget.limit,
                  onChanged:  widget.isDisabled ? null : onChangeOfPageCount,
                ),
              ),
             _buildPageDetails(isTotalCountVisible: widget.isTotalCountVisible)
            ],
          ),
    );
  }

  get dropDownItems {
    return [10, 20, 30, 40, 50].map((value) {
      return DropdownMenuItem(
        key: Key('$value'),
        value: value,
        child: Text('$value'),
      );
    }).toList();
  }

  Widget _buildPageDetails({bool isTotalCountVisible=true}){
    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Visibility(
              visible:  widget.offSet > widget.limit,
              child: IconButton(onPressed: widget.isDisabled ? null : () => onChangeOfPage(false), icon: Icon(Icons.arrow_left))),
        ...isTotalCountVisible?[Text('${widget.offSet} - ${(widget.offSet + widget.limit - 1) <= widget.totalCount ? (widget.offSet + widget.limit -1) : widget.totalCount}'),
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Wrap(
              spacing: 14,
              children: [
                Text('${ApplicationLocalizations.of(context).translate(i18.common.OF)}'),
                Text('${widget.totalCount}'),
              ],
            ),
          )]:[],
          Visibility(
              visible: isTotalCountVisible?((widget.offSet + widget.limit - 1) < widget.totalCount):true,
              child: IconButton(onPressed:  widget.isDisabled ? null : onChangeOfPage, icon:Icon(Icons.arrow_right))),
        ],
      ),
    );
  }

  onChangeOfPage([bool isIncrement = true]) {
    if(isIncrement){
     widget.callBack(PaginationResponse(widget.limit, widget.offSet + widget.limit));
      return;
    }
    widget.callBack(PaginationResponse(widget.limit, widget.offSet - widget.limit));
  }

  onChangeOfPageCount(limit){
    widget.callBack(PaginationResponse(limit, 1, true));
  }
}
