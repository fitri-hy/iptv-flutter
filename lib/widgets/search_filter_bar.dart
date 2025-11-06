import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  final String selectedGroup;
  final List<String> groups;
  final ValueChanged<String> onGroupChanged;

  final String selectedCountry;
  final List<String> countries;
  final ValueChanged<String> onCountryChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedGroup,
    required this.groups,
    required this.onGroupChanged,
    required this.selectedCountry,
    required this.countries,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 6.0;
    const double buttonHeight = 44;

    final TextEditingController groupSearchController = TextEditingController();
    final TextEditingController countrySearchController = TextEditingController();

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "Search channels...",
              hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.grey.shade700),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    value: selectedGroup,
                    items: groups
                        .map(
                          (group) => DropdownMenuItem<String>(
                            value: group,
                            child: Text(group, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => val != null ? onGroupChanged(val) : null,
                    buttonStyleData: ButtonStyleData(
                      height: buttonHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: Colors.grey.shade400, width: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.grey.shade700),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      width: screenWidth * 0.45,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black54 : Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: groupSearchController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: groupSearchController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Search group...',
                            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                            prefixIcon: Icon(Icons.search, size: 18, color: isDark ? Colors.white70 : Colors.grey.shade700),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value!.toLowerCase().contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) groupSearchController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    value: selectedCountry,
                    items: countries
                        .map(
                          (country) => DropdownMenuItem<String>(
                            value: country,
                            child: Text(country, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => val != null ? onCountryChanged(val) : null,
                    buttonStyleData: ButtonStyleData(
                      height: buttonHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: Colors.grey.shade400, width: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.grey.shade700),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      width: screenWidth * 0.45,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black54 : Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: countrySearchController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: countrySearchController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Search country...',
                            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                            prefixIcon: Icon(Icons.search, size: 18, color: isDark ? Colors.white70 : Colors.grey.shade700),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value!.toLowerCase().contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) countrySearchController.clear();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
