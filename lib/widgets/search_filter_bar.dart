import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedGroup;
  final List<String> groups;
  final ValueChanged<String> onGroupChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedGroup,
    required this.groups,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 6.0;
    final TextEditingController dropdownSearchController =
    TextEditingController();
    const double buttonHeight = 48;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search channel...",
                hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey.shade600),
                prefixIcon: Icon(Icons.search,
                    color: isDark ? Colors.white70 : Colors.grey.shade700),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide:
                  BorderSide(color: Colors.grey.shade400, width: 0.8),
                ),
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                value: selectedGroup,
                items: groups
                    .map(
                      (group) => DropdownMenuItem<String>(
                    value: group,
                    child: Text(
                      group,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onGroupChanged(value);
                },
                buttonStyleData: ButtonStyleData(
                  height: buttonHeight,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border:
                    Border.all(color: Colors.grey.shade400, width: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.arrow_drop_down,
                      color:
                      isDark ? Colors.white70 : Colors.grey.shade700),
                  iconSize: 24,
                ),
                dropdownStyleData: DropdownStyleData(
                  width: screenWidth,
                  maxHeight: 500,
                  offset: const Offset(0, 56),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color:
                        isDark ? Colors.black54 : Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 42,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: dropdownSearchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: dropdownSearchController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Search Group...',
                        hintStyle: TextStyle(
                            color:
                            isDark ? Colors.white54 : Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search,
                            size: 18,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade700),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value!
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
                onMenuStateChange: (isOpen) {
                  if (!isOpen) dropdownSearchController.clear();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
