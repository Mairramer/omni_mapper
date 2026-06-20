import 'package:omni_mapper/omni_mapper.dart';
import 'package:source_gen_test/annotations.dart';

// Target Class
class TargetUser {
  final String id;
  final String fullName;

  TargetUser(this.id, this.fullName);
}

// -----------------------------------------------------------------------------
// Test 1: @OmniField on a Source Class (mapping TO a Target)
// -----------------------------------------------------------------------------
@ShouldGenerate(
  r'''
extension SourceUserToEntity on SourceUser {
  TargetUser toEntity() {
    return TargetUser(userId, name);
  }
}

extension SourceUserToEntityList on Iterable<SourceUser> {
  List<TargetUser> toEntityList() {
    return map((e) => e.toEntity()).toList();
  }
}
''',
)
@OmniMapper(target: TargetUser)
class SourceUser {
  @OmniField(name: 'id')
  final String userId;

  @OmniField(name: 'fullName')
  final String name;

  SourceUser(this.userId, this.name);
}

// -----------------------------------------------------------------------------
// Test 2: @OmniField on a Target Class (mapping FROM a Source)
// -----------------------------------------------------------------------------

class SourceAdmin {
  final String adminId;
  final String adminName;

  SourceAdmin(this.adminId, this.adminName);
}

@ShouldGenerate(
  r'''
extension SourceAdminToModel on SourceAdmin {
  TargetAdmin toModel() {
    return TargetAdmin(adminId, adminName);
  }
}

extension SourceAdminToModelList on Iterable<SourceAdmin> {
  List<TargetAdmin> toModelList() {
    return map((e) => e.toModel()).toList();
  }
}
''',
)
@OmniMapper(from: SourceAdmin, methodName: 'toModel')
class TargetAdmin {
  @OmniField(name: 'adminId')
  final String id;

  @OmniField(name: 'adminName')
  final String name;

  TargetAdmin(this.id, this.name);
}

// -----------------------------------------------------------------------------
// Test 3: @OmniField on an Abstract Mapper's DTOs
// -----------------------------------------------------------------------------

class AbstractTarget {
  final String targetId;
  AbstractTarget(this.targetId);
}

class AbstractSource {
  @OmniField(name: 'targetId')
  final String sourceId;
  AbstractSource(this.sourceId);
}

@ShouldGenerate(
  r'''
class TestAbstractMapperImpl extends TestAbstractMapper {
  TestAbstractMapperImpl();

  @override
  AbstractTarget toTarget(AbstractSource source) {
    return AbstractTarget(source.sourceId);
  }
}
''',
)
@OmniMapper()
abstract class TestAbstractMapper {
  AbstractTarget toTarget(AbstractSource source);
}
