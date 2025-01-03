
# FlexiKline


## 架构设计

### 绘制图层

#### 1. GridBackgroundPainter
负责绘制网格线与背景

#### 2. IndicatorChartPainter
负责绘制所有指标图

#### 3. DrawPainter
负责画图工具

#### 4. CrossPainter
负责Cross时, 命中的指标状态.

### 指标配置定义


### 指标图的绘制边界接口
```dart
abstract interface class IIndicatorBounding {
  bool get drawInMain;
  bool get drawInSub;

  /// 当前指标索引(仅对副图有效)
  /// <0 代表在主图绘制
  /// >=0 代表在副图绘制
  int get index => -1;

  /// 当前指标图paint内的padding.
  /// 增加padding后tipsRect和chartRect将在此以内绘制.
  /// 一些额外的信息可以通过padding在左上右下方向上增加扩展的绘制区域.
  /// 1. 主图的XAxis上的时间刻度绘制在pading.bottom上.
  EdgeInsets get paintPadding => EdgeInsets.zero;

  /// 当前指标图画笔可以绘制的范围
  Rect get drawBounding;

  /// 当前指标图tooltip信息绘制区域
  Rect get tipsRect;

  /// 当前指标图绘制区域
  Rect get chartRect;
}
```

### 指标图绘制接口

```dart
abstract interface class IPaintChart {
  /// 计算指标需要的数据
  void calculateIndicatorData();

  /// 将某个指标数据的值转换为dy坐标值
  double valueToDy(Decimal value);

  /// 将某个指标数据的index转换为dx坐标值
  double? indexToDx(int index);

  /// 绘制指标图
  void paintIndicatorChart(Canvas cnavas, Size size);

  /// 绘制XAxis与YAxis刻度值
  void paintAxisTickMark(Canvas canvas, Size size);

  /// 绘制顶部tips信息
  // void paintTips(Canvas canvas, Size size);
}
```

### 指标图的Cross绘制接口

```dart
abstract interface class IPaintCross {
  /// 将dy坐标值转换为YAxis轴对应的值.
  Decimal? dyToValue(double dy);

  /// 将dx坐标值转换为XAxis轴对应的下标.
  int dxToIndex(double dx);

  /// 绘制Cross上的刻度值
  void paintCrossTickMark(Canvas canvas, Offset offset);

  /// 绘制Cross命中的指标信息
  void paintCrossTips(Canvas canvas, Offset offset);
}
```
