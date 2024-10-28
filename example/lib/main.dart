import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:kline_library/kline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: false,
      splitScreenMode: true,
      fontSizeResolver: FontSizeResolvers.radius,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          initialRoute: "/",
          routes: {
            "/": (cx) => MyHomePage(title: "232"),
          },
          debugShowCheckedModeBanner: false,

          builder: FlutterSmartDialog.init(),
          supportedLocales: [Locale('en')],
          title: 'First Method',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          // home: child,
        );
      },
      child: const MyHomePage(title: 'First Method'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer.periodic(Duration(seconds: 1), (_) async {
      // ///生成随机k线图数据
      // final newList = await genRandomCandleList(
      //   count: 1,
      //   bar: timebar,
      //   isHistory: false,
      // );
      //
      // ///更新k线图实时数据
      // updateController.updateData(newList);
    });
  }

  int lastTs = 0;
  UpdateController updateController = UpdateController();

  TimeBar timebar = TimeBar.s1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("k线图DEMO"),
      ),
      body: Container(
        height: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              KLineWidget(
                ///是否允许全屏，允许的话，会显示一个按钮和双击图表变成全屏
                isCanFullScreen: true,
                supportTimBars: [
                  TimeBar.m1,
                  TimeBar.s1,
                  TimeBar.m3,
                  TimeBar.m5,
                  TimeBar.m15,
                  TimeBar.m30,
                  TimeBar.H1,
                  TimeBar.D1,
                  TimeBar.M1
                ],
                updateController: updateController,
                onTimeBarChange: (TimeBar newT) {
                  timebar = newT;
                },
                isShowMarketTooltipCustomView: true,
                getCandleList: (CandleReq req) async {
                  final list = await genRandomCandleList(
                    count: 500,
                    bar: req.timeBar!,
                  );

                  lastTs = list.last.ts;

                  return list;
                },
                marketTicker: MarketTicker(),
                initReq: CandleReq(
                  instId: '000001',
                  bar: timebar.bar,
                  precision: 4,
                  displayName: '测试股票',
                ),
                labelConfig: StringLabelConfig(
                  tooltipTime: "时间",
                  tooltipOpen: "开盘",
                  tooltipHigh: "最高",
                  tooltipLow: "最低",
                  tooltipClose: "收盘",
                  tooltipChg: "涨跌额",
                  tooltipChgRate: "涨跌幅",
                  tooltipRange: "振幅",
                  tooltipAmount: "成交量",
                  tooltipTurnover: "成交额",
                  preferredIntervals: "周期偏好",
                  intervals: "全部周期",
                  mainChartIndicators: "主图指标",
                  subChartIndicators: "副图指标",
                  indicatorSetting: "指标设置",
                  indicators: "指标",
                  more: "更多",
                  chartSettings: "图表设置",
                  landscape: "横屏",
                  drawings: "画图",
                  lastPrice: "最新价",
                  yAxisPriceScale: "Y轴坐标",
                  countdown: "倒计时",
                  chartHeight: "图表高度",
                  chartWidth: "图表宽度",
                  highPrice: "最高价",
                  lowPrice: "最低价",
                  h24High: "24小时最高",
                  h24Low: "24小时最低",
                  h24Vol: "24小时量",
                  h24Turnover: "24小时额",
                  barTypeName: "蜡烛图类型",
                  barTypeFill: "全实心",
                  barTypeEmpty: "全空心",
                  barTypeEmptyLong: "涨空心",
                  barTypeEmptyShort: "跌空心",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
