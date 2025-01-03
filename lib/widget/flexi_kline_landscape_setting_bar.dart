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

import '../model/string_label_config.dart';
import '../theme/flexi_theme.dart';

class FlexiKlineLandscapeSettingBar extends ConsumerWidget {
  const FlexiKlineLandscapeSettingBar({
    super.key,
    required this.controller,
    required this.supportTimeBars,
    required this.onTapTimeBar,
    this.onTapDraw,
    required this.labelConfig,
  });
  final StringLabelConfig labelConfig;

  final List<TimeBar> supportTimeBars;
  final FlexiKlineController controller;
  final ValueChanged<TimeBar> onTapTimeBar;
  final VoidCallback? onTapDraw;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsetsDirectional.only(start: 4.r),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: _buildPreferTimeBarList(context, ref),
            ),
          ),

        ],
      ),
    );
  }
  String getBarName(TimeBar bar) {
    String str = bar.bar;
    if (bar == TimeBar.IntraDay) {
      //分时
      str = labelConfig.intraDay ?? bar.bar;
    }
    return str;
  }
  Widget _buildPreferTimeBarList(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.timeBarListener,
      builder: (context, value, child) {
        final theme = ref.watch(themeProvider);
        return Row(
          children: (supportTimeBars.length==0?TimeBar.values:supportTimeBars).map((bar) {
            final selected = value == bar;
            return GestureDetector(
              onTap: () => onTapTimeBar(bar),
              child: Container(
                key: ValueKey(bar),
                constraints: BoxConstraints(minWidth: 28.r),
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(
                  color: selected ? theme.markBg : null,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 6.r,
                  vertical: 4.r,
                ),
                margin: EdgeInsetsDirectional.symmetric(horizontal: 6.r),
                child: Text(
                 getBarName(bar),
                  style: selected ? theme.t1s14w700 : theme.t1s14w400,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
