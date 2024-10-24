基于flexi_kline再次封装的flutter 端 k线图组件，支持全平台，全屏模式仅支持手机端

    flexi_kline： https://pub-web.flutter-io.cn/packages/flexi_kline

效果图:

![示例1](/demo/images/1.jpg "图片标题")
![示例2](/demo/images/2.jpg "图片标题")
![示例3](/demo/images/3.jpg "图片标题")
![示例4](/demo/images/4.jpg "图片标题")


为什么用他：

    1 证券数据图表支持的很全面（无需自己再去了解每种指标如何计算构图）

    2 容器嵌套在上下滑动的布局中没有太多的事件冲突（体验感较好）

    3 纯flutter的库，无需使用webview加载网页的形式，还要处理webview和scrollview的滑动事件冲突

为什么要再次封装？
    
    flexi_kline的demo功能较为全面，切换周期和指标，图标设置的功能想直接移植进来，但是对项目改动的就会比较多，所以才有了这个库，



使用:

    1依赖kline_library库

        kline_library:
            git:
              url: https://github.com/haoxionga/kline_library.git
        
    2增加klinebrary 需要引用的库，kline_library库中只使用dev_dependencies依赖，真实版本需要自己引用
            shared_preferences: ^2.2.3 #用于缓存用户点击的设置
            flutter_screenutil: ^5.9.3
            flutter_riverpod: ^2.5.1
            flutter_smart_dialog: ^4.9.8+3

    3配置screenutil，增加         fontSizeResolver: FontSizeResolvers.radius,否则横屏字号显示不对 

            

            ScreenUtilInit(
                designSize: const Size(393, 852),
                minTextAdapt: false,
                splitScreenMode: true,
                fontSizeResolver: FontSizeResolvers.radius,
    4 配置flutter_smart_dialog
                      builder: FlutterSmartDialog.init(),

```dart
            UpdateController updateController = UpdateController();
            
           ///k线图容器
            KLineWidget(
                ///是否允许全屏，允许的话，会显示一个按钮和双击图表变成全屏
                isCanFullScreen: false,
                ///容器初始化的尺寸
                initSize:Size(300,400),
                ///用于自选的k线周期
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
                ///用于更新单条数据的controller
                updateController: updateController,
                ///当用户点击k线图周期的函数
                onTimeBarChange: (TimeBar newT) {
                },
                ///是否展示顶部股票信息
                isShowMarketTooltipCustomView: true,
                ///获取历史k线图数据，在这里可以自己做网络请求
                getCandleList: (CandleReq req) async {
                  final list = await genRandomCandleList(
                    count: 500,
                    bar: req.timeBar!,
                  );

                  lastTs = list.last.ts;

                  return list;
                },
                ///全屏时，显示的24小时成交额，量等信息
                marketTicker: MarketTicker(),
                ///初始化信息，股票id，名称，周期
                initReq: CandleReq(
                  instId: '000001',
                  bar: timebar.bar,
                  precision: 4,
                  displayName: '测试股票',
                ),
                ///应用内的文本字符串，自己传入
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
                    h24Turnover: "24小时额"
                ),
              )

        ///更新实时k线图数据
             Timer.periodic(Duration(seconds: 1), (_) async {
                  ///生成随机k线图数据
                  final newList = await genRandomCandleList(
                    count: 1,
                    bar: timebar,
                    isHistory: false,
                  );
                  
                  ///更新k线图实时数据
                  updateController.updateData(newList);
                });
              }