import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luxlog/app/theme.dart';

class SkeletonGridWidget extends StatelessWidget {
  final int itemCount;

  const SkeletonGridWidget({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.surfaceContainerHigh,
          highlightColor: AppColors.surfaceContainerHighest,
          child: Container(
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class SkeletonFeedWidget extends StatelessWidget {
  const SkeletonFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: AppColors.surfaceContainerHigh,
                    highlightColor: AppColors.surfaceContainerHighest,
                    child: const CircleAvatar(radius: 16),
                  ),
                  const SizedBox(width: 12),
                  Shimmer.fromColors(
                    baseColor: AppColors.surfaceContainerHigh,
                    highlightColor: AppColors.surfaceContainerHighest,
                    child: Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Shimmer.fromColors(
                baseColor: AppColors.surfaceContainerHigh,
                highlightColor: AppColors.surfaceContainerHighest,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
