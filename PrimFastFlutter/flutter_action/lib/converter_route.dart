import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'widget/unit.dart';
import 'package:meta/meta.dart';

final _padding = EdgeInsets.all(16.0);

class ConverterRoute extends StatefulWidget {
  ///Units for this [CategoryWidget]
  final List<Unit> units;

  ///color for this [CategoryWidget]
  final Color color;

  ///This [CategoryWidget]'s name
  final String name;

  const ConverterRoute(
      {@required this.units, @required this.color, @required this.name})
      : assert(units != null),
        assert(color != null),
        assert(name != null);

  @override
  State<StatefulWidget> createState() {
    return new ConverterPage();
  }
}

class ConverterPage extends State<ConverterRoute> {
//TODO Set some variables,such as for keeping track of the user's input
//value and units
  Unit _fromValue;
  Unit _toValue;
  double _inputValue;
  String _convertedValue = '';
  bool _showValidationError = false;
  List<DropdownMenuItem> _unitMenuItems;

//TODO :Determine whether you need to override anything,such as initState()

  @override
  void initState() {
    super.initState();
    _createDropdownMenuItems();
    _setDefaults();
  }

  void _createDropdownMenuItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.units) {
      newItems.add(DropdownMenuItem(
        child: Container(
          child: Text(
            unit.name,
            softWrap: true, //文本是否应该在软换行符处中断
          ),
        ),
        value: unit.name,
      ));
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  void _setDefaults() {
    setState(() {
      _fromValue = widget.units[0];
      _toValue = widget.units[1];
    });
  }

  /// 监听TextFiled 输入的text
  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
      } else {
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          //更新转换信息
          _updateConversion();
        } on Exception catch (e) {
          print('Error:$e');
          _showValidationError = true;
        }
      }
    });
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateConversion() {
    setState(() {
      _convertedValue =
          _format(_inputValue * (_toValue.conversion / _fromValue.conversion));
    });
  }

  Unit _getUnit(String unitName) {
    return widget.units.firstWhere(
      (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }

  /// ValueChanged 其实就是一个内部函数
  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(
            color: Colors.grey[400],
            width: 1.0,
          )),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
              child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              items: _unitMenuItems,
              onChanged: onChanged,
              value: currentValue,
              style: Theme.of(context).textTheme.title,
            ),
          ))),
    );
  }

  //TODO: Add other helper functions. We've given you one,_format()

  ///Clean up conversion;trim trailing zeros, e.g. 5.500 -> 5.5 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7); //??
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, outputNum.length - 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      leading: Builder(builder: (BuildContext context) {
        return IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            });
      }),
      title: Text(
        widget.name,
        style: Theme.of(context).textTheme.title,
      ),
      centerTitle: true,
      backgroundColor: widget.color,
      elevation: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitWidgets = widget.units.map((Unit unit) {
      return Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              unit.name,
              style: Theme.of(context).textTheme.headline,
            ),
            Text(
              'Conversion: ${unit.conversion}',
              style: Theme.of(context).textTheme.subhead,
            )
          ],
        ),
      );
    }).toList();

    final input = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              //set input decoration
              labelText: 'Input', //set text hint
              labelStyle: Theme.of(context).textTheme.display1,
              errorText: _showValidationError ? 'Invalid number enterd' : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            style: Theme.of(context).textTheme.display1, //set style
            keyboardType: TextInputType.number, //set input type
            onChanged: _updateInputValue,
          ),
          _createDropdown(_fromValue.name, _updateFromConversion),
        ],
      ),
    );

    final output = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme.of(context).textTheme.display1,
            ),
            decoration: InputDecoration(
              //set input decoration
              labelText: 'Output', //set text hint
              labelStyle: Theme.of(context).textTheme.display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          _createDropdown(_toValue.name, _updateToConversion),
        ],
      ),
    );

    final arrows = RotatedBox(
      quarterTurns: 1, //旋转90度(1/4圈)
      child: Icon(
        Icons.compare_arrows,
        size: 40,
      ),
    );

    final converter = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        input,
        arrows,
        output,
      ],
    );

    return Scaffold(
        appBar: appBar(context),
        body: Padding(
          padding: _padding,
          child: converter,
        ));
  }
}