基于flexi_kline再次封装的flutter 端 k线图组件，支持全平台，全屏模式仅支持手机端

    flexi_kline： https://pub-web.flutter-io.cn/packages/flexi_kline

效果图:

# 分时图

![示例1](/demo/images/1.png "图片标题")

# 周期选择

![示例2](/demo/images/2.png "图片标题")

# 指标选择

![示例3](/demo/images/3.png "图片标题")

# 功能切换（新增，切换蜡烛图实心空心选项，切换蜡烛图：红涨绿跌，绿涨红跌选项）

![示例4](/demo/images/4.png "图片标题")

# 实心蜡烛图

![示例5](/demo/images/5.png "图片标题")

# 空心蜡烛图

![示例6](/demo/images/6.png "图片标题")

# 全指标图

![示例6](/demo/images/7.png "图片标题")

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
                isCanFullScreen: true,
                supportTimBars: [
                  ///配置分时，
                  TimeBar.IntraDay,
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
                  ///根据周期返回k线图数据（初始化使用）
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
                autoCacheConfig: true,
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
                  barColor: "蜡烛图颜色",
                  barColorLongGreen: "红跌绿涨",
                  barColorLongRed: "红涨绿跌",
                  intraDay: "分时"
                ),
                settingChangeCallBack: (SettingConfig setting){
                  ///这里可以读到红涨绿跌，绿涨红跌配置，方便在自己的app中统一其他颜色
                  print("样式改变了:${setting.longRed}");
                },
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