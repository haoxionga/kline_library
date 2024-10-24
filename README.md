基于flexi_kline再次封装的k线图组件

    flexi_kline： https://pub-web.flutter-io.cn/packages/flexi_kline

效果图:

    ![示例1](/demo/images/1.jpg "图片标题")
    ![示例2](/demo/images/2.jpg "图片标题")
    ![示例3](/demo/images/3.jpg "图片标题")
    ![示例4](/demo/images/4.jpg "图片标题")



使用:

    1依赖kline_library库
        
    2增加klinebrary 需要引用的库，kline_library库中只使用dev_dependencies依赖，真实版本需要自己引用
        shared_preferences  
        flutter_screenutil
        flutter_riverpod
        flutter_smart_dialog

```dart
            KLineWidget(
                ///容器初始化的高度
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