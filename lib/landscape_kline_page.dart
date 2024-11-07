// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flexi_kline/flexi_kline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kline_library/model/string_label_config.dart';
import 'package:kline_library/provider/market_candle_provider.dart';
import 'package:kline_library/theme/flexi_theme.dart';
import 'package:kline_library/update_controller.dart';
import 'package:kline_library/util/screen_util.dart';
import 'package:kline_library/widget/flexi_kline_landscape_indicator_bar.dart';
import 'package:kline_library/widget/flexi_kline_landscape_setting_bar.dart';
import 'package:kline_library/widget/flexi_kline_mark_view.dart';
import 'package:kline_library/widget/market_ticker_landscape_view.dart';
import 'package:kline_library/util/screen_util.dart';

import 'config/default_kline_config.dart';
import 'data/mock.dart';
import 'kline_widget.dart';
import 'model/market_ticker.dart';

class LandscapeKlinePage extends ConsumerStatefulWidget {
  LandscapeKlinePage({
    super.key,
    required this.candleReq,
    required this.supportTimeBarList,
    required this.getCandleList,
    required this.marketTicker,
    this.configuration,
    required this.labelConfig,
    this.updateController,
  });

  final StringLabelConfig labelConfig;

  ///根据CandleReq，异步返回支持的k线图数据
  final GetCandleListCallBack getCandleList;
  final List<TimeBar> supportTimeBarList;
  final CandleReq candleReq;
  final IConfiguration? configuration;
  final MarketTicker marketTicker;
  UpdateController? updateController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LandscapeKlinePageState();
}

class _LandscapeKlinePageState extends ConsumerState<LandscapeKlinePage> {
  late final Size prevSize;
  late final FlexiKlineController controller;

  @override
  FlexiKlineController get flexiKlineController => controller;
  late CandleReq req;

  Map<TooltipLabel, String> _initTollTipLables() {
    return {
      TooltipLabel.time: widget.labelConfig.tooltipTime ?? "",
      TooltipLabel.open: widget.labelConfig.tooltipOpen ?? "",
      TooltipLabel.high: widget.labelConfig.tooltipHigh ?? "",
      TooltipLabel.low: widget.labelConfig.tooltipLow ?? "",
      TooltipLabel.close: widget.labelConfig.tooltipClose ?? "",
      TooltipLabel.chg: widget.labelConfig.tooltipChg ?? "",
      TooltipLabel.chgRate: widget.labelConfig.tooltipChgRate ?? "",
      TooltipLabel.range: widget.labelConfig.tooltipRange ?? "",
      TooltipLabel.amount: widget.labelConfig.tooltipAmount ?? "",
      TooltipLabel.turnover: widget.labelConfig.tooltipTurnover ?? "",
    };
  }

  @override
  void initState() {
    super.initState();
    setScreenLandscape();

    req = widget.candleReq;
    IConfiguration configuration = widget.configuration ??
        DefaultFlexiKlineConfiguration(
          ref: ref,
        );
    controller = FlexiKlineController(
      configuration: configuration,
      autoSave: true,
    );

    controller.onCrossI18nTooltipLables = _initTollTipLables;

    // controller.onLoadMoreCandles = loadMoreCandles;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initKlineData(req);
    });
    widget.updateController?.addListener(_dataChange);
  }

  void _dataChange() {
    _update(widget.updateController?.data ?? []);
  }

  @override
  void dispose() {
    setScreenPortrait();

    widget.updateController?.removeListener(_dataChange);
    super.dispose();
  }

  /// 初始化加载K线蜡烛数据.
  Future<void> initKlineData(CandleReq request) async {
    controller.switchKlineData(request);

    final list = await widget.getCandleList(request);

    _update(list);
  }

  Future<void> _update(List<CandleModel> list) async {
    await controller.updateKlineData(req, list);
    emitLatestMarketCandle();
  }

  /// 更新最新的蜡烛数据到行情上.
  void emitLatestMarketCandle() {
    if (controller.curKlineData.latest != null) {
      ref.read(marketCandleProvider.notifier).emit(
            controller.curKlineData.latest!,
          );
    }
  }

  bool isExit = false;

  Future<void> exitPage() async {
    isExit = true;

    controller.storeFlexiKlineConfig();
    await setScreenPortrait();

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        controller.logd('zp::: LandscapeKlinePage onPopInvoked:$didPop');
        // exitPage();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox.shrink(),
          leadingWidth: 4.r,
          title: MarketTickerLandscapeView(
            instId: req.instId,
            marketTicker: widget.marketTicker,
            precision: req.precision,
            long: controller.settingConfig.longColor,
            short: controller.settingConfig.shortColor,
            labelConfig: widget.labelConfig,
          ),
          centerTitle: false,
          titleSpacing: 0,
          toolbarHeight: 30.r,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          actions: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: exitPage,
              child: Container(
                margin: EdgeInsets.only(right: 10.r),
                width: 30.r,
                height: double.maxFinite,
                child: Icon(
                  Icons.fullscreen_exit_rounded,
                  size: 25.r,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size(ScreenUtil().screenWidth, 10.w),
            child: FlexiKlineLandscapeSettingBar(
              controller: controller,
              supportTimeBars: widget.supportTimeBarList,
              onTapTimeBar: onTapTimerBar,
              labelConfig: widget.labelConfig,
            ),
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            ///判断设备是否是ipad
            // if (orientation == Orientation.portrait) {
            //   return Center(
            //     child: CircularProgressIndicator(
            //       strokeWidth: controller.settingConfig.loading.strokeWidth,
            //       backgroundColor: controller.settingConfig.loading.background,
            //       valueColor: AlwaysStoppedAnimation<Color>(
            //         controller.settingConfig.loading.valueColor,
            //       ),
            //     ),
            //   );
            // }
            return SafeArea(
              top: false,
              left: true,
              right: false,
              bottom: true,
              child: _buildBodyView(context),
            );
          },
        ),
      ),
    );
  }

  /// TimerBar变更回调
  void onTapTimerBar(TimeBar bar) {
    if (bar.bar != req.bar) {
      req = req.copyWith(bar: bar.bar);
      initKlineData(req);
      setState(() {});
    }
  }

  Widget _buildBodyView(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Container(
      color: theme.pageBg,
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                controller.logd('zp::: LandscapeKlinePage:$constraints');
                controller.setFixedSize(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );
                return FlexiKlineWidget(
                  controller: controller,
                  mainBackgroundView: FlexiKlineMarkView(
                    margin: EdgeInsetsDirectional.only(
                      bottom: 10.r,
                      start: 36.r,
                    ),
                  ),
                  mainforegroundViewBuilder: _buildKlineMainForgroundView,
                );
              },
            ),
          ),
          SizedBox(
            width: 50.r,
            child: Stack(
              children: [
                FlexiKlineLandscapeIndicatorBar(
                  controller: controller,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKlineMainForgroundView(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.candleRequestListener,
      builder: (context, request, child) {
        return Offstage(
          offstage: !request.state.showLoading,
          child: Container(
            key: const ValueKey('loadingView'),
            alignment: request.state == RequestState.initLoading
                ? AlignmentDirectional.center
                : AlignmentDirectional.centerStart,
            padding: EdgeInsetsDirectional.all(32.r),
            child: SizedBox.square(
              dimension: controller.settingConfig.loading.size,
              // child: CircularProgressIndicator(
              //   strokeWidth: controller.settingConfig.loading.strokeWidth,
              //   backgroundColor: controller.settingConfig.loading.background,
              //   valueColor: AlwaysStoppedAnimation<Color>(
              //     controller.settingConfig.loading.valueColor,
              //   ),
              // ),
              child: Container(),
            ),
          ),
        );
      },
    );
  }
}
