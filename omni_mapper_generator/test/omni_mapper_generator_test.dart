import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:omni_mapper_generator/src/omni_mapper_generator.dart';

class MockClassElement extends Mock implements ClassElement {}
class MockMethodElement extends Mock implements MethodElement {}
class MockFormalParameterElement extends Mock implements FormalParameterElement {}
class MockDartType extends Mock implements DartType {}
class MockConstantReader extends Mock implements ConstantReader {}
class MockBuildStep extends Mock implements BuildStep {}
class MockConstructorElement extends Mock implements ConstructorElement {}
class MockFieldElement extends Mock implements FieldElement {}

void main() {
  group('MapperGenerator', () {
    late MapperGenerator generator;
    late MockClassElement mapperClass;
    late MockConstantReader annotation;
    late MockBuildStep buildStep;

    setUp(() {
      generator = MapperGenerator();
      mapperClass = MockClassElement();
      annotation = MockConstantReader();
      buildStep = MockBuildStep();
      when(() => annotation.peek('target')).thenReturn(null);
      when(() => annotation.peek('methodName')).thenReturn(null);
    });

    test('throws error if annotated element is not abstract class and target is not provided', () {
      when(() => mapperClass.isAbstract).thenReturn(false);
      
      expect(
        () => generator.generateForAnnotatedElement(mapperClass, annotation, buildStep),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('successfully generates mapper impl code', () {
      when(() => mapperClass.isAbstract).thenReturn(true);
      when(() => mapperClass.name).thenReturn('UserMapper');

      // Mock Source Class (UserModel)
      final sourceClass = MockClassElement();
      when(() => sourceClass.name).thenReturn('UserModel');
      when(() => sourceClass.fields).thenReturn([]);
      when(() => sourceClass.getters).thenReturn([]);
      
      final sourceType = MockDartType();
      when(() => sourceType.element).thenReturn(sourceClass);

      // Mock Target Class (User)
      final targetClass = MockClassElement();
      when(() => targetClass.name).thenReturn('User');
      when(() => targetClass.fields).thenReturn([]);
      
      final targetConstructor = MockConstructorElement();
      when(() => targetConstructor.name).thenReturn('');
      when(() => targetConstructor.formalParameters).thenReturn([]);
      when(() => targetClass.constructors).thenReturn([targetConstructor]);

      final targetType = MockDartType();
      when(() => targetType.element).thenReturn(targetClass);

      // Mock Mapper Method
      final method = MockMethodElement();
      when(() => method.isAbstract).thenReturn(true);
      when(() => method.name).thenReturn('fromModel');
      when(() => method.returnType).thenReturn(targetType);

      final param = MockFormalParameterElement();
      when(() => param.name).thenReturn('model');
      when(() => param.type).thenReturn(sourceType);
      when(() => method.formalParameters).thenReturn([param]);

      when(() => mapperClass.methods).thenReturn([method]);

      final result = generator.generateForAnnotatedElement(mapperClass, annotation, buildStep);

      expect(result, contains('class UserMapperImpl extends UserMapper'));
      expect(result, contains('User fromModel(UserModel model)'));
      expect(result, contains('return User('));
    });
  });
}
