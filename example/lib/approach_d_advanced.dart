import 'package:omni_mapper/omni_mapper.dart';

part 'approach_d_advanced.g.dart';

class AdvancedEntity {
  final int id;
  final String title;
  final String status;
  final DateTime createdAt;

  AdvancedEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });
}

class DateTimeStringConverter extends OmniConverter<String, DateTime> {
  const DateTimeStringConverter();

  @override
  DateTime convert(String source) => DateTime.parse(source);
}

class StringDateTimeConverter extends OmniConverter<DateTime, String> {
  const StringDateTimeConverter();

  @override
  String convert(DateTime source) => source.toIso8601String();
}

@OmniMappers([
  OmniMapper(
    target: AdvancedEntity,
    fieldMaps: {'userId': 'id'},
    defaultValues: {'status': '"active"'},
    converters: [DateTimeStringConverter],
    generateListMapper: true,
    generateUpdateMethod: true,
  ),
  OmniMapper(
    from: AdvancedEntity,
    methodName: 'toModel',
    fieldMaps: {'id': 'userId'}, // O source agora é o Entity (id), e o target é o Model (userId)
    converters: [StringDateTimeConverter],
    generateListMapper: true,
    generateUpdateMethod: true,
  )
])
class AdvancedModel {
  final int userId;
  final String title;
  final String createdAt;

  AdvancedModel({
    required this.userId,
    required this.title,
    required this.createdAt,
  });
}
