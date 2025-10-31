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
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 6.0;
    final TextEditingController dropdownSearchController = TextEditingController();
    const double buttonHeight = 48;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search channel...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onGroupChanged(value);
                },

                buttonStyleData: ButtonStyleData(
                  height: buttonHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                ),

                dropdownStyleData: DropdownStyleData(
                  width: screenWidth,
                  maxHeight: 500,
                  offset: const Offset(0, 56),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
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
                      decoration: InputDecoration(
                        hintText: 'Search Group...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
