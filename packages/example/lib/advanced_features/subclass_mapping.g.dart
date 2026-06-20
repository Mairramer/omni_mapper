// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subclass_mapping.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension VehicleToEntity on Vehicle {
  VehicleDto toEntity() {
    return switch (this) {
      final Car s => s.toCarDto(),
      final Motorcycle s => s.toMotorcycleDto(),
      _ => VehicleDto(
        wheels: wheels,
      ),
    };
  }

  void updateVehicleDto(VehicleDto target) {}
}

extension VehicleToEntityList on Iterable<Vehicle> {
  List<VehicleDto> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}

extension CarToCarDto on Car {
  CarDto toCarDto() {
    return CarDto(
      wheels: wheels,
      doors: doors,
    );
  }

  void updateCarDto(CarDto target) {}
}

extension CarToCarDtoList on Iterable<Car> {
  List<CarDto> toCarDtoList() {
    return map((e) => e.toCarDto()).toList();
  }
}

extension MotorcycleToMotorcycleDto on Motorcycle {
  MotorcycleDto toMotorcycleDto() {
    return MotorcycleDto(
      wheels: wheels,
      hasSidecar: hasSidecar,
    );
  }

  void updateMotorcycleDto(MotorcycleDto target) {}
}

extension MotorcycleToMotorcycleDtoList on Iterable<Motorcycle> {
  List<MotorcycleDto> toMotorcycleDtoList() {
    return map((e) => e.toMotorcycleDto()).toList();
  }
}

class VehicleMapperImpl extends VehicleMapper {
  VehicleMapperImpl();

  @override
  VehicleDto toDto(Vehicle vehicle) {
    return switch (vehicle) {
      final Car s => carToDto(s),
      final Motorcycle s => motorcycleToDto(s),
      _ => VehicleDto(
        wheels: vehicle.wheels,
      ),
    };
  }

  @override
  CarDto carToDto(Car car) {
    return CarDto(
      wheels: car.wheels,
      doors: car.doors,
    );
  }

  @override
  MotorcycleDto motorcycleToDto(Motorcycle motorcycle) {
    return MotorcycleDto(
      wheels: motorcycle.wheels,
      hasSidecar: motorcycle.hasSidecar,
    );
  }
}
