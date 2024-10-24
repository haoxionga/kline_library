import 'dart:async';

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kline_library/update_controller.dart';
import 'package:kline_library/theme/flexi_theme.dart';
import 'package:kline_library/util/cache_util.dart';
import 'package:kline_library/widget/flexi_kline_indicator_bar.dart';
import 'package:kline_library/widget/flexi_kline_setting_bar.dart';

import 'config/config.dart';
import 'config/default_kline_config.dart';
import 'data/mock.dart';
import 'landscape_kline_page.dart';
import 'model/market_ticker.dart';
import 'model/string_label_config.dart';
import 'provider/market_candle_provider.dart';
import 'widget/market_tooltip_custom_view.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

////异步获取k线图记录
typedef GetCandleListCallBack = Future<List<CandleModel>> Function(
    CandleReq req);

typedef OnTimeBarChange = Function(TimeBar newTimeBar);
class KLineWidget extends StatefulWidget {
  ///支持的时间周期
  List<TimeBar> supportTimBars;

  ///根据CandleReq，异步返回k线图数据
  GetCandleListCallBack getCandleList;

  ///k线图显示周期改变
  OnTimeBarChange? onTimeBarChange;

  ///更新数据controller，当收到单条数据时，可用这个及时更新k线图
  UpdateController? updateController;

  ///初始化k线图请求
  CandleReq initReq;

  ///是否展示当前价格，开盘，最高，最低等信息
  bool? isShowMarketTooltipCustomView;

  ///24小时交易量等等信息
  final MarketTicker marketTicker;

  ///是否展示底部的指标切换指示器
  bool showBottomIndicator;

  ////显示的文本配置项
  StringLabelConfig labelConfig;

  ///容器初始化的大小
  Size? initSize;

  ///是否允许全屏
  bool isCanFullScreen;

  KLineWidget(
      {required this.supportTimBars,
        required this.getCandleList,
        required this.labelConfig,
        this.isShowMarketTooltipCustomView,
        this.updateController,
        this.onTimeBarChange,
        this.initSize,
        this.isCanFullScreen = false,
        this.showBottomIndicator = true,
        required this.marketTicker,
        required this.initReq});

  @override
  State<StatefulWidget> createState() {
   return _KLineWidgetState();
  }
}
class _KLineWidgetState extends State<KLineWidget> {

  bool isInitCache=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     // FlutterSmartDialog.init();

    _init();


  }
  void _init() async{
   try {
     await CacheUtil.instance.init();
   } catch (e) {
   }
    setState(() {
      isInitCache=true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return isInitCache?ProviderScope(
        child: KlineWidgetPrivate(
      labelConfig: widget.labelConfig,
      supportTimBars: widget.supportTimBars,
      showBottomIndicator: widget.showBottomIndicator,
      getCandleModelHistory: widget.getCandleList,
      marketTicker: widget.marketTicker,
      initSize: widget.initSize,
      onTimeBarChange: widget.onTimeBarChange,
      controller:widget. updateController,
      isCanFullScreen:widget. isCanFullScreen,
      initReq: widget.initReq,
      isShowMarketTooltipCustomView:widget. isShowMarketTooltipCustomView ?? true,
    )):SizedBox();
  }


}

class KlineWidgetPrivate extends ConsumerStatefulWidget {
  KlineWidgetPrivate(
      {required this.supportTimBars,
      required this.initReq,
      required this.marketTicker,
      this.controller,
      this.initSize,
      required this.labelConfig,
      this.onTimeBarChange,
      required this.isCanFullScreen,
      required this.getCandleModelHistory,
      required this.showBottomIndicator,
      this.isShowMarketTooltipCustomView = false});

  ///是否允许全屏
  bool isCanFullScreen;
  Size? initSize;

  ////显示的文本配置项
  StringLabelConfig labelConfig;
  OnTimeBarChange? onTimeBarChange;
  UpdateController? controller;
  bool showBottomIndicator;
  bool isShowMarketTooltipCustomView = false;
  List<TimeBar> supportTimBars;
  GetCandleListCallBack getCandleModelHistory;
  CandleReq initReq;
  final MarketTicker marketTicker;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _KlineWidgetState();
  }
}

class _KlineWidgetState extends ConsumerState<KlineWidgetPrivate> {
  late final FlexiKlineController controller;
  late final DefaultFlexiKlineConfiguration configuration;

  late CandleReq req;

  @override
  void dispose() {
    widget.controller?.removeListener(_dataChanges);
    super.dispose();
  }

  final logger = LogPrintImpl(
    debug: false,
    tag: 'Demo',
  );

  @override
  void initState() {
    req = widget.initReq;
    configuration =
        DefaultFlexiKlineConfiguration(ref: ref, initSize: widget.initSize);
    controller = FlexiKlineController(
      configuration: configuration,
      logger: logger,
    );

    controller.onCrossCustomTooltip = onCrossCustomTooltip;

    // controller.onLoadMoreCandles = loadMoreCandles;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
    widget.controller?.addListener(_dataChanges);
  }

  void _dataChanges() {
    _update(widget.controller?.data ?? []);
  }

  /// 当crossing时, 自定义Tooltip
  List<TooltipInfo>? onCrossCustomTooltip(
    CandleModel? current, {
    CandleModel? prev,
  }) {
    if (current == null) {
      ref.read(marketCandleProvider.notifier).emitOnCross(null);
      // Cross事件取消了, 更新行情为最新一根蜡烛数据.
      emitLatestMarketCandle();
      return [];
    }

    final candle = current.clone()..confirm = '';
    // 暂存振幅到candle的confirm中.
    if (prev != null) candle.confirm = candle.rangeRate(prev).toString();
    ref.read(marketCandleProvider.notifier).emitOnCross(candle);
    // 返回空数组, 自行定制.
    return [];
  }

  /// 更新最新的蜡烛数据到行情上.
  void emitLatestMarketCandle() {
    if (controller.curKlineData.latest != null) {
      ref.read(marketCandleProvider.notifier).emit(
            controller.curKlineData.latest!,
          );
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ///当前状态信息
        if (widget.isShowMarketTooltipCustomView)
          MarketTooltipCustomView(
            candleReq: req,
            data: controller.curKlineData.latest,
            tooltipOpen: widget.labelConfig.tooltipOpen ?? "",
            tooltipHigh: widget.labelConfig.tooltipHigh ?? "",
            tooltipLow: widget.labelConfig.tooltipLow ?? "",
            tooltipAmount: widget.labelConfig.tooltipAmount ?? "",
          ),

        ///k线周期，设置等等
        FlexiKlineSettingBar(
          controller: controller,
          onTapTimeBar: onTapTimeBar,
          supportTimeBarList: widget.supportTimBars,
          labelConfig: widget.labelConfig,
        ),

        ///具体k线图容器
        FlexiKlineWidget(
          key: const ValueKey('MyKlineDemo'),
          controller: controller,
          onDoubleTap: openLandscapePage,
          mainforegroundViewBuilder: (cx) {
            return Stack(
              children: [
                if (widget.isCanFullScreen)
                  Positioned(
                    left: 8.r,
                    bottom: 8.r,
                    width: 28.r,
                    height: 28.r,
                    child: IconButton(
                      // constraints: BoxConstraints.tight(Size(28.r, 28.r)),
                      padding: EdgeInsets.zero,
                      style: ref.watch(themeProvider).circleBtnStyle(
                          bg: ref.watch(themeProvider).markBg.withOpacity(0.6)),
                      iconSize: 20.r,
                      icon: const Icon(Icons.fullscreen_rounded),
                      onPressed: openLandscapePage,
                    ),
                  ),
              ],
            );
          },
        ),

        if (widget.showBottomIndicator)

          ///底部主副图切换
          FlexiKlineIndicatorBar(
            controller: controller,
          ),
        // InkWell(
        //   child: Container(
        //     child: Text("测试添加"),
        //     padding: EdgeInsets.all(14.w),
        //   ),
        //   onTap: () async {
        //
        //   },
        // )
      ],
    );

    return content;
  }

  void onTapTimeBar(TimeBar bar) {
    if (bar.bar != req.bar) {
      req = req.copyWith(bar: bar.bar);
      if (widget.onTimeBarChange != null) {
        widget.onTimeBarChange!(bar);
      }
      setState(() {});
      initKlineData();
    }
  }

  /// 初始化加载K线蜡烛数据.
  Future<void> initKlineData() async {
    controller.switchKlineData(req);

    ///请求数据
    final list = await widget.getCandleModelHistory(req);
    await _update(list);
  }

  Future<void> _update(List<CandleModel> list) async {
    await controller.updateKlineData(req, list);
    emitLatestMarketCandle();
  }

  void _init() async {
    initKlineData().then((value) {});
  }

  void openLandscapePage() async {
    if (!widget.isCanFullScreen) {
      return;
    }
    controller.storeFlexiKlineConfig();
    // 跳转到横屏页面
    final isUpdate = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProviderScope(
                  child: LandscapeKlinePage(
                labelConfig: widget.labelConfig,
                updateController: widget.controller,
                marketTicker: widget.marketTicker,
                getCandleList: widget.getCandleModelHistory,
                supportTimeBarList: widget.supportTimBars,
                candleReq: controller.curKlineData.req.toInitReq(),
                configuration: controller.configuration,
              ))),
    );
    if (mounted && isUpdate == true) {
      final landConfig = controller.configuration.getFlexiKlineConfig();
      controller.updateFlexiKlineConfig(landConfig);
    }
  }
}
