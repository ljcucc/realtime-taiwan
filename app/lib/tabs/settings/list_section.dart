import 'package:flutter/material.dart';

class ListSectionWidget extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Icon icon;
  final Widget? trailing;
  final Color? color, textColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const ListSectionWidget({
    super.key,
    required this.title,
    this.subtitle,
    required Icon this.icon,
    this.trailing,
    this.color,
    this.padding,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        onTap: onTap ?? () {},
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: icon,
            ),
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}
