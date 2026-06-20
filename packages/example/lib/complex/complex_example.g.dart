// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complex_example.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

extension ContactDtoToEntity on ContactDto {
  ContactEntity toEntity() {
    return ContactEntity(
      phone,
      zip_code,
    );
  }
}

extension ContactDtoToEntityList on Iterable<ContactDto> {
  List<ContactEntity> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}

class PaymentMethodMapperImpl extends PaymentMethodMapper {
  PaymentMethodMapperImpl();

  @override
  PaymentMethodEntity toEntity(PaymentMethodDto dto) {
    return switch (dto) {
      final CreditCardDto s => ccToEntity(s),
      final PayPalDto s => ppToEntity(s),
      _ => throw UnsupportedError(
        'Cannot instantiate abstract class PaymentMethodEntity. Did you forget to map all subclasses?',
      ),
    };
  }

  @override
  CreditCardEntity ccToEntity(CreditCardDto dto) {
    return CreditCardEntity(
      dto.id,
      dto.lastFour,
    );
  }

  @override
  PayPalEntity ppToEntity(PayPalDto dto) {
    return PayPalEntity(
      dto.id,
      dto.email,
    );
  }
}

class UserMapperImpl extends UserMapper {
  UserMapperImpl(super.paymentMapper);

  @override
  UserEntity toEntity(UserDto dto) {
    return UserEntity(
      dto.username,
      const AccountStatusConverter().convert(dto.status),
      dto.contact.toEntity(),
      dto.paymentMethods.map((e) => paymentMapper.toEntity(e)).toList(),
    );
  }
}

class UserProfileMapperImpl extends UserProfileMapper {
  UserProfileMapperImpl();

  @override
  UserProfileDocument toDocument(
    UserDto user,
    SettingsDto settings,
  ) {
    return UserProfileDocument(
      user.username,
      settings.receiveEmails,
    );
  }
}
