import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final bool primary;
  final bool excludeHeaderSemantics;
  final double? toolbarHeight;
  final double? leadingWidth;
  final ShapeBorder? shape;
  final Color? shadowColor;
  final bool forceMaterialTransparency;
  final Color? iconThemeColor;
  final Color? titleTextStyleColor;
  final double? titleTextStyleFontSize;
  final FontWeight? titleTextStyleFontWeight;

  const AppBarWidget({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.flexibleSpace,
    this.bottom,
    this.titleSpacing,
    this.primary = true,
    this.excludeHeaderSemantics = false,
    this.toolbarHeight,
    this.leadingWidth,
    this.shape,
    this.shadowColor,
    this.forceMaterialTransparency = false,
    this.iconThemeColor,
    this.titleTextStyleColor,
    this.titleTextStyleFontSize,
    this.titleTextStyleFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          : null,
      actions: actions,
      leading:
          leading ??
          (automaticallyImplyLeading
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      automaticallyImplyLeading: false, // We handle leading manually
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      titleSpacing: titleSpacing,
      primary: primary,
      excludeHeaderSemantics: excludeHeaderSemantics,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      shape: shape,
      shadowColor: shadowColor,
      forceMaterialTransparency: forceMaterialTransparency,
      iconTheme: IconThemeData(
        color: iconThemeColor ?? theme.appBarTheme.iconTheme?.color,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
