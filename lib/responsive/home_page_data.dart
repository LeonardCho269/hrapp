// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:responsive_ht/components/api_services.dart';
import 'package:responsive_ht/constants.dart';
import 'package:responsive_ht/responsive/details_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ApiService apiService;
  String responseData = '';
  List<String> orderedStatuses = [
    'open',
    'start',
    'consideration',
    'med',
    'wait',
    'close',
    'cancel',
    'no_connection',
    'overdue'
  ];
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  String selectedBranch = '';

  @override
  void initState() {
    super.initState();
    apiService = ApiService(dio: Dio());
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> jsonData = await apiService.fetchDataFromApi();

      if (mounted) {
        groupedData = groupDataByStatus(jsonData);

        setState(() {
          responseData = 'Данные успешно получены!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          responseData = 'Ошибка при получении данных: $e';
        });
      }
      print('Error fetching data: $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> groupDataByStatus(List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in data) {
      String status = item['status'] ?? 'unknown';
      grouped.putIfAbsent(status, () => []);
      grouped[status]!.add(item);
    }

    for (var status in orderedStatuses) {
      grouped.putIfAbsent(status, () => []);
    }

    return grouped;
  }

  Future<void> _refreshData() async {
    await fetchData();
  }

  int getCrossAxisCount(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200) {
      return 4;
    } else {
      return 2;
    }
  }

  Future<void> showBranchesFilter(BuildContext context, List<String> branches) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: branches.length,
            itemBuilder: (BuildContext context, int index) {
              var branch = branches[index];
              return ListTile(
                title: Text(branch),
                onTap: () {
                  setState(() {
                    selectedBranch = branch;
                  });
                  _filterDataByBranch();
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _filterDataByBranch() {
    List<Map<String, dynamic>> filteredData = [];

    if (selectedBranch.isNotEmpty) {
      filteredData = groupedData.entries
          .where((entry) => entry.key == selectedBranch)
          .map((entry) => entry.value)
          .expand((value) => value)
          .where((candidate) => candidate['status'] == selectedBranch)
          .toList();
    } else {
      filteredData = groupedData.values.expand((value) => value).toList();
    }

    setState(() {
      groupedData[selectedBranch] = filteredData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: myDrawer(context),
      backgroundColor: AppColors.mainBlueColor,
      appBar: AppBar(
        title: const Text(
          'Главная',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              List<Map<String, dynamic>> branches = await apiService.fetchPizzaStores();

              List<String> branchNames = branches.map((branch) => branch['name_ru'] as String).toList();
              showBranchesFilter(context, branchNames);
            },
            icon: const Icon(Icons.filter_alt_sharp),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(context),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: orderedStatuses.length,
            itemBuilder: (BuildContext context, int index) {
              var status = orderedStatuses[index];
              int candidateCount = groupedData[status]?.length ?? 0;

              return Card(
                elevation: 1,
                color: Colors.grey[800],
                shadowColor: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                surfaceTintColor: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CandidateListPage(data: groupedData[status] ?? []),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getStatusIcon(status),
                        const SizedBox(height: 8),
                        Text(statusNames[status] ?? status,
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white)),
                        const SizedBox(height: 8),
                        if (candidateCount > 0)
                          Text(
                            'Заявок: $candidateCount',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return const Icon(Icons.add_circle_outline, size: 40, color: Colors.green);
      case 'start':
        return const Icon(Icons.schedule, size: 40, color: Colors.green);
      case 'consideration':
        return const Icon(Icons.published_with_changes_outlined, size: 40, color: Colors.green);
      case 'med':
        return const Icon(Icons.local_hospital, size: 40, color: Colors.green);
      case 'wait':
        return const Icon(Icons.access_time, size: 40, color: Colors.green);
      case 'close':
        return const Icon(Icons.check_circle_outline, size: 40, color: Colors.green);
      case 'cancel':
        return const Icon(Icons.cancel_outlined, size: 40, color: Colors.red);
      case 'no-connection':
        return const Icon(Icons.phone_disabled, size: 40, color: Colors.red);
      case 'overdue':
        return const Icon(Icons.timer_off, size: 40, color: Colors.red);
      default:
        return const Icon(Icons.info_outline, size: 40, color: Colors.red);
    }
  }

  Map<String, String> statusNames = {
    'open': 'Новая заявка',
    'start': 'Назначено собеседование',
    'consideration': 'На рассмотрении',
    'med': 'Отправлен на медосмотр',
    'wait': 'Ожидает оформления',
    'close': 'Оформлен',
    'cancel': 'Отказано',
    'no_connection': 'Не ответил на звонок',
    'overdue': 'Кандидат не пришел',
  };
}

class CandidateListPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CandidateListPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text(
          'Список кандидатов',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          var candidate = data[index];
          return Card(
            elevation: 1,
            color: Colors.grey[800],
            shadowColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            surfaceTintColor: Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(data: candidate),
                  ),
                );
              },
              child: ListTile(
                title: Center(
                  child: Text(
                    '${candidate['applicant_name']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
