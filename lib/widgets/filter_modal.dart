import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  Map<String, String> countryMap = {};
  List<Map<String, String>> countryList = [];

  @override
  void initState() {
    super.initState();
    tempGroups = List.from(widget.selectedGroups);
    tempCountries = List.from(widget.selectedCountries);
    _loadCountryJson();
  }

  Future<void> _loadCountryJson() async {
    try {
      final String response = await rootBundle.loadString('assets/json/country.json');
      final List data = json.decode(response);
      setState(() {
        countryList = data.map<Map<String, String>>((c) {
          return {'code': c['code'], 'name': c['name']};
        }).toList();
        countryMap = {
          for (var c in data) c['code']: c['name'],
        };
      });
    } catch (e) {
      debugPrint("Failed get countries.");
    }
  }

  void _openMultiSelectModal(
    String title,
    List<String> codes,
    List<String> selectedCodes,
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
        final filteredCountries = countryList
            .where((c) => c['name']!
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();

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
                    hintText: "Search country...",
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
                  child: countryList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = filteredCountries[index];
                            final code = country['code']!;
                            final name = country['name']!;
                            final isSelected = selectedCodes.contains(code);

                            return CheckboxListTile(
                              title: Text(name),
                              value: isSelected,
                              activeColor: appBarColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    selectedCodes.add(code);
                                  } else {
                                    selectedCodes.remove(code);
                                  }
                                });
                              },
                            );
                          },
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
                      onSelected(selectedCodes);
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

  String _displaySelected(List<String> selectedCodes) {
    if (selectedCodes.isEmpty) return "All";
    return selectedCodes.map((code) => countryMap[code] ?? code).join(", ");
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
            subtitle: Text(tempGroups.isEmpty ? "All" : tempGroups.join(", ")),
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
