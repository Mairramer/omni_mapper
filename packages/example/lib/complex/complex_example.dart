import 'package:omni_mapper/omni_mapper.dart';

part 'complex_example.g.dart';

// ============================================================================
// A COMPREHENSIVE OMNI_MAPPER EXAMPLE
// Features demonstrated:
// 1. fieldMaps - Renaming source fields to target fields seamlessly.
// 2. OmniConverter - Custom type converters registered in `converters`.
// 3. Decentralized Extensions - Using @OmniMapper directly on the source.
// 4. Centralized Mappers - Defining abstract mapper classes.
// 5. Subclass Mapping - Mapping an abstract class and routing to subclasses.
// 6. Uses (Dependency Injection) - Reusing mappers for nested objects/lists.
// 7. Multiple Sources - Mapping two distinct models into a single target.
// ============================================================================

// --- 1. Enums & Custom Converters ---

enum AccountStatus { active, inactive, suspended }

class AccountStatusConverter implements OmniConverter<String, AccountStatus> {
  const AccountStatusConverter();

  @override
  AccountStatus convert(String source) {
    try {
      return AccountStatus.values.byName(source);
    } catch (_) {
      return AccountStatus.inactive;
    }
  }
}

// --- 2. Targets (Domain Entities) ---

class ContactEntity {
  final String phone;
  final String zipCode;
  ContactEntity(this.phone, this.zipCode);
}

abstract class PaymentMethodEntity {
  final String id;
  PaymentMethodEntity(this.id);
}

class CreditCardEntity extends PaymentMethodEntity {
  final String lastFour;
  CreditCardEntity(super.id, this.lastFour);
}

class PayPalEntity extends PaymentMethodEntity {
  final String email;
  PayPalEntity(super.id, this.email);
}

class UserEntity {
  final String username;
  final AccountStatus status;
  final ContactEntity contact;
  final List<PaymentMethodEntity> paymentMethods;

  UserEntity(this.username, this.status, this.contact, this.paymentMethods);
}

class UserProfileDocument {
  final String username;
  final bool receiveEmails;

  UserProfileDocument(this.username, this.receiveEmails);
}

// --- 3. Sources (DTOs) & Mappers ---

// Feature: Decentralized Extension Mapper & fieldMaps (renaming)
@OmniMapper(
  target: ContactEntity,
  mappings: [
    MappingRule('zipCode', source: 'zip_code'),
  ],
)
class ContactDto {
  final String phone;
  // ignore: non_constant_identifier_names
  final String zip_code;

  ContactDto(this.phone, this.zip_code);
}

abstract class PaymentMethodDto {
  final String id;
  PaymentMethodDto(this.id);
}

class CreditCardDto extends PaymentMethodDto {
  final String lastFour;
  CreditCardDto(super.id, this.lastFour);
}

class PayPalDto extends PaymentMethodDto {
  final String email;
  PayPalDto(super.id, this.email);
}

// Feature: Centralized Abstract Mapper & Subclass Mapping
@OmniMapper()
abstract class PaymentMethodMapper {
  // The generator will detect subclasses and generate a `switch` statement!
  @SubclassMapping(source: CreditCardDto, target: CreditCardEntity)
  @SubclassMapping(source: PayPalDto, target: PayPalEntity)
  PaymentMethodEntity toEntity(PaymentMethodDto dto);

  CreditCardEntity ccToEntity(CreditCardDto dto);
  PayPalEntity ppToEntity(PayPalDto dto);
}

class UserDto {
  final String username;
  final String status;

  final ContactDto contact;
  final List<PaymentMethodDto> paymentMethods;

  UserDto(this.username, this.status, this.contact, this.paymentMethods);
}

// Feature: Dependency Injection via `uses` & Custom Converters
@OmniMapper(
  uses: [PaymentMethodMapper],
  converters: [AccountStatusConverter],
)
abstract class UserMapper {
  final PaymentMethodMapper paymentMapper;

  UserMapper(this.paymentMapper);

  // The generator will use `ContactDto`'s extension to map `contact` implicitly.
  // The generator will use `PaymentMethodMapper` to map `paymentMethods` cleanly.
  UserEntity toEntity(UserDto dto);
}

class SettingsDto {
  final bool receiveEmails;
  SettingsDto(this.receiveEmails);
}

// Feature: Multiple Sources Mapping
@OmniMapper()
abstract class UserProfileMapper {
  // Combines fields from both `UserDto` and `SettingsDto` into a single class!
  UserProfileDocument toDocument(UserDto user, SettingsDto settings);
}

// --- 4. Execution / Usage ---

void main() {
  // 1. Dependency Initialization
  final paymentMapper = PaymentMethodMapperImpl();
  final userMapper = UserMapperImpl(paymentMapper);
  final profileMapper = UserProfileMapperImpl();

  // 2. Mocking Data
  final userDto = UserDto(
    'john_doe',
    'active',
    ContactDto('555-1234', '90210'),
    [
      CreditCardDto('pm_1', '4242'),
      PayPalDto('pm_2', 'john@example.com'),
    ],
  );

  final settingsDto = SettingsDto(true);

  // 3. Mapping execution
  final userEntity = userMapper.toEntity(userDto);
  final document = profileMapper.toDocument(userDto, settingsDto);

  // 4. Output Results
  print('User: ${userEntity.username} is ${userEntity.status.name}');
  print('Contact ZIP: ${userEntity.contact.zipCode}');
  for (var pm in userEntity.paymentMethods) {
    switch (pm) {
      case final CreditCardEntity c:
        print('Payment: Credit Card ending in ${c.lastFour}');
      case final PayPalEntity p:
        print('Payment: PayPal (${p.email})');
      default:
        break;
    }
  }

  print('\nDocument:');
  print('User: ${document.username}');
  print('Emails Enabled: ${document.receiveEmails}');
}
