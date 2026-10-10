import 'package:cucumber_expressions/cucumber_expressions.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../support/fixture_normalization.dart';
import '../../support/test_data_dir.dart';

const Map<String, String> _knownLimitations = <String, String>{
  'capture-group-positions.yaml':
      "Dart's RegExpMatch only exposes the start and end of the overall match, "
          'not of individual capture groups',
};

void main() {
  group('Regular expression conformance', () {
    for (final file
        in yamlFilesIn('$testDataDir/regular-expression/matching')) {
      final expectation = loadYaml(file.readAsStringSync()) as YamlMap;
      test(
        'matches ${file.path}',
        () {
          final arguments = ExpressionFactory(ParameterTypeRegistry())
              .createExpression(RegExp(expectation['expression'] as String))
              .match(expectation['text'] as String);
          expect(
            arguments
                ?.map((argument) => normalizeFixtureValue(argument.getValue()))
                .toList(),
            equals(normalizeExpectedFixtureValue(expectation['expected_args'])),
          );

          final expectedGroups = expectation['expected_groups'] as YamlList?;
          if (expectedGroups != null) {
            expect(
              arguments
                  ?.map(
                    (argument) => <String, Object?>{
                      'value': argument.group.value,
                      'start': argument.group.start,
                      'end': argument.group.end,
                    },
                  )
                  .toList(),
              equals(
                expectedGroups
                    .cast<YamlMap>()
                    .map(
                      (group) => <String, Object?>{
                        'value': group['value'],
                        'start': group['start'],
                        'end': group['end'],
                      },
                    )
                    .toList(),
              ),
            );
          }
        },
        skip: _knownLimitations[file.uri.pathSegments.last],
      );
    }
  });
}
