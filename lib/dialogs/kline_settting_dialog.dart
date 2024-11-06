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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../componets/flexi_kline_size_slider.dart';
import '../kline_widget.dart';
import '../model/string_label_config.dart';
import '../provider/kline_controller_state_provider.dart';
import '../theme/flexi_theme.dart';
import '../util/device_util.dart';
import '../util/dialog_manager.dart';

class KlineSettingDialog extends ConsumerStatefulWidget {
  static const String dialogTag = "KlineSettingDialog";

   KlineSettingDialog({
    super.key,
    required this.controller,
    required this.labelConfig,
    required this.settingChangeCallBack,
  });
  SettingChangeCallBack? settingChangeCallBack;
  final StringLabelConfig labelConfig;
  final FlexiKlineController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KlineSettingDialogState();
}

class _KlineSettingDialogState extends ConsumerState<KlineSettingDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 使用 ref.listen 在 initState 中监听 provider 的数据变化
      ref.read(klineStateProvider(widget.controller)).addListener(() {
        if (widget.settingChangeCallBack != null) {
          widget.settingChangeCallBack!(widget.controller.settingConfig);
        }
      });
    });
  }
  bool klineHeightChanging = false;
  bool klineWidthChanging = false;

  bool get klineSizeChanging => klineHeightChanging || klineWidthChanging;

  Future<void> openLandscapePage() async {}


  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Stack(
      children: [
        Visibility.maintain(
          visible: !klineSizeChanging,
          child: DialogWrapper(
            bgColor: theme.pageBg,
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingTab(context),
                  _buildDisplaySetting(context),

                  /// 图表宽高调整点位
                  SizedBox(height: DeviceUtil.isMobile ? 160.r : 80.r),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              Offstage(
                offstage: !DeviceUtil.isMobile,
                child: Visibility.maintain(
                  visible: !klineSizeChanging || klineWidthChanging,
                  child: Container(
                    // height: 80.r,
                    margin: EdgeInsetsDirectional.symmetric(horizontal: 8.r),
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 8.r,
                      vertical: 10.r,
                    ),
                    decoration: BoxDecoration(
                      color: theme.pageBg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _buildKlineWidthSetting(context),
                  ),
                ),
              ),
              Visibility.maintain(
                visible: !klineSizeChanging || klineHeightChanging,
                child: Container(
                  // height: 80.r,
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 8.r),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 8.r,
                    vertical: 10.r,
                  ),
                  decoration: BoxDecoration(
                    color: theme.pageBg.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: _buildKlineHeightSetting(context),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTab(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final s = widget.labelConfig;
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.r,
        vertical: 10.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.chartSettings ?? "",
            style: theme.t1s18w700,
          ),
          // SizedBox(height: 20.r),
          // Row(
          //   mainAxisSize: MainAxisSize.max,
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     TextButton(
          //       style: theme.roundBtnStyle,
          //       onPressed: openLandscapePage,
          //       child: Column(
          //         children: [
          //           Icon(Icons.screen_rotation_rounded, color: theme.t1),
          //           Text(s.landscape, style: theme.t1s14w500),
          //         ],
          //       ),
          //     ),
          //     TextButton(
          //       style: theme.roundBtnStyle,
          //       onPressed: () {
          //         // ref.read(routerProvider).pushNamed('indicatorSetting');
          //       },
          //       child: Column(
          //         children: [
          //           Icon(Icons.legend_toggle_rounded, color: theme.t1),
          //           Text(s.indicators, style: theme.t1s14w500),
          //         ],
          //       ),
          //     ),
          //     TextButton(
          //       style: theme.roundBtnStyle,
          //       onPressed: () {},
          //       child: Column(
          //         children: [
          //           Icon(Icons.draw_rounded, color: theme.t1),
          //           Text(s.drawings, style: theme.t1s14w500),
          //         ],
          //       ),
          //     ),
          //     TextButton(
          //       style: theme.roundBtnStyle,
          //       onPressed: () {
          //         // ref.read(routerProvider).pushNamed(
          //         //       'klineSetting',
          //         //       extra: widget.controller,
          //         //     );
          //       },
          //       child: Column(
          //         children: [
          //           Icon(Icons.settings_rounded, color: theme.t1),
          //           Text(s.more, style: theme.t1s14w500),
          //         ],
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }

  /// 设置图表区域显示设置
  Widget _buildDisplaySetting(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final s = widget.labelConfig;
    final klineState = ref.watch(klineStateProvider(widget.controller));
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.r,
        vertical: 10.r,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: klineState.isShowLatestPrice,
                  contentPadding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    klineState.setShowLatestPrice(
                      !klineState.isShowLatestPrice,
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    s.lastPrice ?? "",
                    style: theme.t1s14w500,
                  ),
                  activeColor: theme.t1,
                  selected: true,
                  checkColor: theme.tlight,
                  // shape: theme.defaultShape,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: klineState.isShowCountDown,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    klineState.setShowCountDown(!klineState.isShowCountDown);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    s.countdown ?? "",
                    style: theme.t1s14w500,
                  ),
                  activeColor: theme.t1,
                  selected: true,
                  checkColor: theme.tlight,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: klineState.isShowCandleHighPrice,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    klineState.setShowCandleHighPrice(
                      !klineState.isShowCandleHighPrice,
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    s.highPrice ?? "",
                    style: theme.t1s14w500,
                  ),
                  activeColor: theme.t1,
                  selected: true,
                  checkColor: theme.tlight,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: klineState.isShowCandleLowPrice,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    klineState.setShowCandleLowPrice(
                      !klineState.isShowCandleLowPrice,
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    s.lowPrice ?? "",
                    style: theme.t1s14w500,
                  ),
                  activeColor: theme.t1,
                  selected: true,
                  checkColor: theme.tlight,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  value: klineState.isShowYAxisTick,
                  contentPadding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    klineState.setShowYAxisTick(!klineState.isShowYAxisTick);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    s.yAxisPriceScale ?? "",
                    style: theme.t1s14w500,
                  ),
                  activeColor: theme.t1,
                  selected: true,
                  checkColor: theme.tlight,
                  // shape: theme.defaultShape,
                ),
              ),
            ],
          ),
          _build_candle_type(),
          _build_candle_color(),
          SizedBox(
            height: 6.r,
          ),
        ],
      ),
    );
  }

  Widget _build_check_item(
      {required bool value,
      required String? title,
      Function(bool value)? onChange}) {
    final theme = ref.watch(themeProvider);
    return CheckboxListTile(
      dense: true,
      value: value,
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        if (onChange != null) {
          onChange(value ?? false);
        }
      },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        title ?? "",
        style: theme.t1s14w500,
      ),
      activeColor: theme.t1,
      selected: true,
      checkColor: theme.tlight,
    );
  }

  Widget _build_bar_setitem(int index, String? title) {
    final theme = ref.watch(themeProvider);
    final klineState = ref.watch(klineStateProvider(widget.controller));
    return Expanded(
        child: _build_check_item(
            value: klineState.barType == index,
            title: title,
            onChange: (value) {
              klineState.setCandleBarType(index);
            }));

  }

  Widget _build_candle_color() {
    final theme = ref.watch(themeProvider);
    final s = widget.labelConfig;
    final klineState = ref.watch(klineStateProvider(widget.controller));

    List<String?> titles = [s.barColorLongGreen??"", s.barColorLongRed??""];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.barColor??"",
          style: theme.t1s14w500,
        ),
        Row(
          children: [
         Expanded(child: _build_check_item(value: !klineState.longRed , title: titles[0],onChange: (value){
           klineState.setCandleBarColor(false);

         })),
         Expanded(child: _build_check_item(value: klineState.longRed , title: titles[1],onChange: (value){
           klineState.setCandleBarColor(true);

         })),
          ],
        ),
      ],
    );
  }

  Widget _build_candle_type() {
    final theme = ref.watch(themeProvider);
    final s = widget.labelConfig;
    List<String?> titles = [
      s.barTypeFill,
      s.barTypeEmpty,
      s.barTypeEmptyLong,
      s.barTypeEmptyShort
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.barTypeName ?? "",
          style: theme.t1s14w500,
        ),
        Row(
          children: [
            _build_bar_setitem(0, titles[0]),
            _build_bar_setitem(1, titles[1]),
          ],
        ),
        Row(
          children: [
            _build_bar_setitem(2, titles[2]),
            _build_bar_setitem(3, titles[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildKlineWidthSetting(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final s = widget.labelConfig;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.chartWidth ?? "",
          style: theme.t1s14w400,
        ),
        FlexiKlineSizeSlider(
          controller: widget.controller,
          maxSize: Size(
            ScreenUtil().screenWidth,
            ScreenUtil().screenHeight * 2 / 3,
          ),
          axis: Axis.horizontal,
          onStateChanged: (value) {
            setState(() {
              klineWidthChanging = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildKlineHeightSetting(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final s = widget.labelConfig;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.chartHeight ?? "",
          style: theme.t1s14w400,
        ),
        FlexiKlineSizeSlider(
          controller: widget.controller,
          maxSize: Size(
            ScreenUtil().screenWidth,
            ScreenUtil().screenHeight * 2 / 3,
          ),
          axis: Axis.vertical,
          onStateChanged: (value) {
            setState(() {
              klineHeightChanging = value;
            });
          },
        ),
      ],
    );
  }
}
