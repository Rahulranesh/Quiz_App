import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../utils/debug_export.dart';

class DebugDataView extends StatefulWidget {
  const DebugDataView({super.key});

  @override
  State<DebugDataView> createState() => _DebugDataViewState();
}

class _DebugDataViewState extends State<DebugDataView> {
  Map<String, String> storedData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStoredData();
  }

  Future<void> loadStoredData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await StorageService.getFormattedStoredData();
      setState(() {
        storedData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load stored data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Data Debug'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              await DebugExport.exportToDesktop();
              Get.snackbar(
                'Exported',
                'Data exported to desktop as JSON file',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Export to Desktop',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadStoredData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : storedData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storage_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No data stored yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Complete some quizzes to see stored data',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: storedData.length,
                  itemBuilder: (context, index) {
                    final key = storedData.keys.elementAt(index);
                    final value = storedData[key]!;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Tap to expand',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Data Type: ${_getDataType(value)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 16),
                                      onPressed: () {
                                        // Copy to clipboard
                                        // You can add clipboard functionality here
                                        Get.snackbar(
                                          'Copied',
                                          'Data copied to clipboard',
                                          snackPosition: SnackPosition.BOTTOM,
                                          duration: const Duration(seconds: 1),
                                        );
                                      },
                                      tooltip: 'Copy Data',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: SelectableText(
                                    value,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clear All Data'),
              content: const Text(
                'Are you sure you want to clear all stored data? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Clear All'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await StorageService.clearAllData();
            loadStoredData();
            Get.snackbar(
              'Cleared',
              'All stored data has been cleared',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        tooltip: 'Clear All Data',
        child: const Icon(Icons.delete_forever),
      ),
    );
  }

  String _getDataType(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return 'List (${decoded.length} items)';
      } else if (decoded is Map) {
        return 'Map (${decoded.length} keys)';
      } else {
        return decoded.runtimeType.toString();
      }
    } catch (e) {
      return 'String (${value.length} chars)';
    }
  }
} 