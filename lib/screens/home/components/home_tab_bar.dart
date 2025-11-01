import 'package:flutter/material.dart';

class HomeTabBar extends StatefulWidget {
  final int currentIndex;
  final int allCount;
  final int favoritesCount;
  final int categoriesCount;
  final ValueChanged<int> onTabChanged;

  const HomeTabBar({
    super.key,
    required this.currentIndex,
    required this.allCount,
    required this.favoritesCount,
    required this.categoriesCount,
    required this.onTabChanged,
  });

  @override
  State<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentIndex.toDouble();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _positionAnimation =
        Tween<double>(begin: _currentPosition, end: _currentPosition).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(HomeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final distance = (widget.currentIndex - oldWidget.currentIndex).abs();

      // Adjust duration based on distance
      _animationController.duration = Duration(
        milliseconds: 300 + (distance > 1 ? 50 : 0),
      );

      _positionAnimation =
          Tween<double>(
            begin: oldWidget.currentIndex.toDouble(),
            end: widget.currentIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutCubic,
            ),
          );

      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final tabWidth = availableWidth / 3;

          return Stack(
            children: [
              // Animated sliding indicator
              AnimatedBuilder(
                animation: _positionAnimation,
                builder: (context, child) {
                  final position = _positionAnimation.value;

                  return Positioned(
                    left: position * tabWidth,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withOpacity(0.9),
                            colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Tab buttons
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'All',
                      count: widget.allCount,
                      icon: Icons.all_inclusive_rounded,
                      isSelected: widget.currentIndex == 0,
                      onTap: () => widget.onTabChanged(0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Starred',
                      count: widget.favoritesCount,
                      icon: Icons.star_rounded,
                      isSelected: widget.currentIndex == 1,
                      onTap: () => widget.onTabChanged(1),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Categories',
                      count: widget.categoriesCount,
                      icon: Icons.category_rounded,
                      isSelected: widget.currentIndex == 2,
                      onTap: () => widget.onTabChanged(2),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        color: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant.withOpacity(0.7),
                    letterSpacing: 0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : colorScheme.onSurfaceVariant.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.4)
                          : colorScheme.onSurfaceVariant.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white.withOpacity(0.95)
                            : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
