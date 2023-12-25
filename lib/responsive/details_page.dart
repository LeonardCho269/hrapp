// ignore_for_file: library_private_types_in_public_api

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:responsive_ht/components/api_services.dart';
import 'package:responsive_ht/components/datetime_picker.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPage({super.key, required this.data});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String selectedStatus;
  late DateTime selectedDateTime;
  static const List<MapEntry<String, String>> statusChoices = [
    MapEntry('open', 'Новая заявка'),
    MapEntry('start', 'Назначено собеседование'),
    MapEntry('consideration', 'На рассмотрении'),
    MapEntry('med', 'Отправлен на медосмотр'),
    MapEntry('wait', 'Ожидает оформления'),
    MapEntry('close', 'Оформлен'),
    MapEntry('cancel', 'Отказано'),
    MapEntry('no_connection', 'Не ответил на звонок'),
    MapEntry('overdue', 'Кандидат не пришел'),
  ];

  late ApiService apiService;
  bool statusUpdated = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(dio: Dio());
    selectedStatus = widget.data['status'] ?? statusChoices[0].value;
    selectedDateTime = DateTime.now();
  }

  Future<void> _updateStatus() async {
    try {
      await apiService.updateStatus(
        widget.data['id'],
        selectedStatus.toString(),
        dateTime: selectedDateTime,
      );
      setState(() {
        statusUpdated = true;
      });
    } catch (e) {
      if (e is DioException) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text(
          'Подробная информация',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.data['applicant_photo'] != null && widget.data['applicant_photo'] != '')
                Image.network(
                  widget.data['applicant_photo'],
                  height: 200,
                ),
              Text(
                '${widget.data['applicant_name']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'ID заявки: ${widget.data['id']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Создана: ${widget.data['created_at']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'День рождения: ${widget.data['applicant_birthday']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Пол: ${widget.data['applicant_gender']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Адрес: ${widget.data['applicant_address']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Телефон: ${widget.data['applicant_phone']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Язык: ${widget.data['applicant_language']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Позиция: ${widget.data['position_name']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Название филиала: ${widget.data['pizza_store_name']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Регион: ${widget.data['region_name']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Источник вакансии: ${widget.data['find_job_way']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Инвалидность: ${widget.data['is_disabled_person']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Ожидаемая зарплата: ${widget.data['expected_salary']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Является студентом: ${widget.data['is_student']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Формат обучения: ${widget.data['education_format']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Образование: ${widget.data['education_level']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Владение русским языком: ${widget.data['ru_lang_level']}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Владение узбекским языком: ${widget.data['uz_lang_level']}',
                style: const TextStyle(color: Colors.white),
              ),
              DropdownButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 36.0,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                dropdownColor: Colors.grey[800],
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
                items: statusChoices.map<DropdownMenuItem<String>>((MapEntry<String, String> entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              if (selectedStatus == 'start' || selectedStatus == 'wait')
                DateTimePickerWidget(onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    selectedDateTime = dateTime;
                  });
                }),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateStatus,
                child: const Text('Обновить статус'),
              ),
              if (statusUpdated)
                Column(
                  children: [
                    const SizedBox(height: 16.0),
                    const Text(
                      'Статус успешно обновлен',
                      style: TextStyle(color: Colors.green),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Закрываем текущую страницу
                      },
                      child: const Text('Вернуться к списку'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
