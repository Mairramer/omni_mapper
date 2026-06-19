import os
import re

files = [
    'packages/omni_mapper_generator/test/src/abstract_class_inputs.dart',
    'packages/omni_mapper_generator/test/src/extension_mapping_inputs.dart',
    'packages/omni_mapper_generator/test/src/advanced_features_inputs.dart',
    'packages/omni_mapper_generator/test/src/strict_mode_inputs.dart',
    'packages/omni_mapper_generator/test/src/error_inputs.dart',
]

regex = re.compile(r'final target = ([\s\S]*?);\s*return target;')

for file in files:
    if not os.path.exists(file): continue
    with open(file, 'r') as f:
        content = f.read()
    
    new_content = regex.sub(r'return \1;', content)
    
    if new_content != content:
        with open(file, 'w') as f:
            f.write(new_content)
        print(f"Updated {file}")
