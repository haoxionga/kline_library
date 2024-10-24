
import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/cupertino.dart';

class UpdateController with ChangeNotifier{
  List<CandleModel> _data = [];

  List<CandleModel> get data => _data;

  // 更新数据并通知监听的 Widget
  void updateData(List<CandleModel> newData) {
    _data = newData;
    notifyListeners();
  }

}