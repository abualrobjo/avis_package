import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

/// Draggable bottom sheet wrapper for map cards
/// Allows swiping down to minimize and up to expand
class DraggableMapCard extends StatefulWidget {
  final Widget child;
  final double minHeightFactor;
  final double maxHeightFactor;
  final double initialHeightFactor;

  // For black container
  final bool showBlackContainer;
  final String? text;
  final String? time;
  final String? subtext;

  const DraggableMapCard({
    super.key,
    required this.child,
    this.minHeightFactor = 0.08, // Small peek when minimized
    this.maxHeightFactor = 0.7, // Maximum height
    this.initialHeightFactor = 0.45, // Starting height
    this.showBlackContainer = false,
    this.text,
    this.time,
    this.subtext,
  });

  @override
  State<DraggableMapCard> createState() => _DraggableMapCardState();
}

class _DraggableMapCardState extends State<DraggableMapCard> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Positioned(
      bottom: bottomInset,
      left: AppSpaces.onSides,
      right: AppSpaces.onSides,
      top:
          (MediaQuery.sizeOf(context).height * (1 - widget.maxHeightFactor)) -
          bottomInset,
      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: widget.initialHeightFactor / widget.maxHeightFactor,
        minChildSize: widget.minHeightFactor / widget.maxHeightFactor,
        maxChildSize: 1.0,
        snap: true,
        snapSizes: [
          widget.minHeightFactor / widget.maxHeightFactor,
          widget.initialHeightFactor / widget.maxHeightFactor,
        ],
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Opacity(
                  opacity: widget.showBlackContainer?1:0,
                  child: Container(
                    height: 60,
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpaces.medium,
                      horizontal: AppSpaces.onSides,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.grey900,
                          child: Padding(
                            padding: EdgeInsets.all(9.0),
                            child: SvgIconWidget(
                              name: 'clock',
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpaces.medium),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  if (widget.text != null)
                                    Expanded(
                                      child: Text(
                                        widget.text!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: AppTextStyles.bodySmallBold
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),

                                  if (widget.time != null)
                                    Text(
                                      widget.time!,
                                      style: AppTextStyles.bodySmallBold
                                          .copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                ],
                              ),

                              if (widget.subtext != null)
                                Text(
                                  widget.subtext!,
                                  style: AppTextStyles.bodyXSmall.copyWith(
                                    color: context.colors.secondaryText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                widget.child,
              ],
            ),
          );
        },
      ),
    );
  }
}
