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

import '../provider/kline_controller_state_provider.dart';
import '../provider/market_candle_provider.dart';
import '../theme/flexi_theme.dart';

class MarketTooltipCustomView extends ConsumerWidget {
  const MarketTooltipCustomView({
    super.key,
    required this.candleReq,
    this.data,
    required this.tooltipOpen,
    required this.tooltipHigh,
    required this.tooltipLow,
    required this.tooltipAmount,
    required this.controller,
  });

  final String tooltipOpen;
  final String tooltipHigh;
  final String tooltipLow;
  final String tooltipAmount;
  final CandleReq candleReq;
  final CandleModel? data;

  final FlexiKlineController controller;
  int get p => candleReq.precision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(marketCandleProvider).when(
          loading: () => _buildMarketInfo(context, ref, data),
          error: (error, stackTrace) => _buildMarketInfo(context, ref, data),
          data: (value) => _buildMarketInfo(context, ref, value),
        );
  }

  Widget _buildMarketInfo(
    BuildContext context,
    WidgetRef ref,
    CandleModel? data,
  ) {
    final theme = ref.watch(themeProvider);
    final changeRate = data?.changeRate;
    Color rateColor;
    Color? marketBg;
    final klineState = ref.watch(klineStateProvider(controller));

    if (changeRate == null || changeRate == 0) {
      rateColor = theme.t1;
    } else if (changeRate > 0) {
      ////涨，
      rateColor = klineState.longRed?theme.long:theme.short;
      marketBg =klineState.longRed?theme.long:theme.short;
    } else {
      rateColor =!klineState.longRed?theme.long:theme.short;
      marketBg = !klineState.longRed?theme.long:theme.short;
    }
    return Container(
      height: 60.r,
      padding: EdgeInsetsDirectional.symmetric(
        vertical: 6.r,
      ),
      child: Row(
        children: [
          Container(
            width: 128.r,
            height: 60.r,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.r,
              vertical: 2.r,
            ),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: marketBg?.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FittedBox(
                    child: Text(
                      formatNumber(
                        data?.c,
                        precision: candleReq.precision,
                        showThousands: true,
                        cutInvalidZero: true,
                      ),
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: rateColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatPercentage(changeRate),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: rateColor,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      formatPercentage(parseDouble(data?.confirm)),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: rateColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 6.r),
          Expanded(
            child: Wrap(

              children: [
                KVItem(
                  label: tooltipOpen,
                  value: formatPrice(
                    data?.o,
                    precision: p,
                    showThousands: true,
                  ),

                ),
                KVItem(
                  label: tooltipLow,
                  value: formatPrice(
                    data?.l,
                    precision: p,
                    showThousands: true,
                  ),
                )
                ,  KVItem(
                  label: tooltipHigh,
                  value: formatPrice(
                    data?.h,
                    precision: p,
                    showThousands: true,
                  ),
                ),
                KVItem(
                  label: tooltipAmount,
                  value: formatPrice(
                    data?.v,
                    precision: p,
                    showThousands: true,
                  ),
                ),



              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KVItem extends ConsumerWidget {
  const KVItem({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 4.r, vertical: 2.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.t2s12w400,
          ),
          SizedBox(width: 2,)
          ,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 150.r, // 设置最大宽度为200
            ),
            child:  Text(
              value,
              style: theme.t1s12w400.copyWith(overflow: TextOverflow.ellipsis),
            ),
          )

        ],
      ),
    );
  }
}
