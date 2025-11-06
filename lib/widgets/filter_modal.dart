import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final List<String> groups;
  final List<String> countries;
  final List<String> selectedGroups;
  final List<String> selectedCountries;
  final void Function(List<String> groups, List<String> countries) onApply;

  const FilterModal({
    super.key,
    required this.groups,
    required this.countries,
    required this.selectedGroups,
    required this.selectedCountries,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late List<String> tempGroups;
  late List<String> tempCountries;

  @override
  void initState() {
    super.initState();
    tempGroups = List.from(widget.selectedGroups);
    tempCountries = List.from(widget.selectedCountries);
  }

  void _openMultiSelectModal(
    String title,
    List<String> items,
    List<String> selectedItems,
    ValueChanged<List<String>> onSelected,
  ) {
    final TextEditingController searchController = TextEditingController();
    final appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search, color: appBarColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 0.8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: BorderSide(color: appBarColor, width: 1.2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: items
                        .where((item) => item
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()))
                        .map(
                          (item) => CheckboxListTile(
                            title: Text(item),
                            value: selectedItems.contains(item),
                            activeColor: appBarColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedItems.add(item);
                                } else {
                                  selectedItems.remove(item);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onPressed: () {
                      onSelected(selectedItems);
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  String _displaySelected(List<String> selected) {
    if (selected.isEmpty) return "All";
    return selected.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Select Groups"),
            subtitle: Text(_displaySelected(tempGroups)),
            trailing: Icon(Icons.arrow_forward_ios, color: appBarColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            onTap: () => _openMultiSelectModal(
              "Select Groups",
              widget.groups,
              tempGroups,
              (selected) => setState(() => tempGroups = List.from(selected)),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text("Select Countries"),
            subtitle: Text(_displaySelected(tempCountries)),
            trailing: Icon(Icons.arrow_forward_ios, color: appBarColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            onTap: () => _openMultiSelectModal(
              "Select Countries",
              widget.countries,
              tempCountries,
              (selected) => setState(() => tempCountries = List.from(selected)),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () {
                widget.onApply(tempGroups, tempCountries);
                Navigator.pop(context);
              },
              child: const Text("Apply Filters"),
            ),
          )
        ],
      ),
    );
  }
}
