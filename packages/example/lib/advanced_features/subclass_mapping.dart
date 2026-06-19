import 'package:omni_mapper/omni_mapper.dart';

part 'subclass_mapping.g.dart';

// -----------------------------------------------------------------------------
// Source Entities
// -----------------------------------------------------------------------------

@OmniMapper(
  target: VehicleDto,
  subclasses: [
    SubclassMapping(source: Car, target: CarDto, methodName: 'toCarDto'),
    SubclassMapping(
      source: Motorcycle,
      target: MotorcycleDto,
      methodName: 'toMotorcycleDto',
    ),
  ],
)
class Vehicle {
  final int wheels;
  Vehicle({required this.wheels});
}

@OmniMapper(target: CarDto, methodName: 'toCarDto')
class Car extends Vehicle {
  final int doors;
  Car({required super.wheels, required this.doors});
}

@OmniMapper(target: MotorcycleDto, methodName: 'toMotorcycleDto')
class Motorcycle extends Vehicle {
  final bool hasSidecar;
  Motorcycle({required super.wheels, required this.hasSidecar});
}

// -----------------------------------------------------------------------------
// Target DTOs
// -----------------------------------------------------------------------------

class VehicleDto {
  final int wheels;
  VehicleDto({required this.wheels});
}

class CarDto extends VehicleDto {
  final int doors;
  CarDto({required super.wheels, required this.doors});
}

class MotorcycleDto extends VehicleDto {
  final bool hasSidecar;
  MotorcycleDto({required super.wheels, required this.hasSidecar});
}

// -----------------------------------------------------------------------------
// Example 2: Polymorphic Subclass Mapping via Abstract Class
// -----------------------------------------------------------------------------

@OmniMapper()
abstract class VehicleMapper {
  @SubclassMapping(source: Car, target: CarDto)
  @SubclassMapping(source: Motorcycle, target: MotorcycleDto)
  VehicleDto toDto(Vehicle vehicle);

  CarDto carToDto(Car car);
  MotorcycleDto motorcycleToDto(Motorcycle motorcycle);
}
