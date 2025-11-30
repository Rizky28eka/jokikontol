import 'package:flutter_test/flutter_test.dart';
// no widget-specific material imports
import 'package:get/get.dart';
import 'package:tamajiwa/views/genogram_builder_view.dart';

void main() {
  testWidgets('GenogramBuilderView displays members from initialData', (WidgetTester tester) async {
    final initialData = {
      'structure': {
        'members': [
          {'id': 1, 'name': 'John Doe', 'relationship': 'Ayah', 'age': 55},
          {'id': 2, 'name': 'Jane Doe', 'relationship': 'Ibu', 'age': 52},
        ],
        'connections': [
          {'id': 10, 'from': 1, 'to': 2, 'type': 'marriage'},
        ],
      },
      'notes': 'Contoh genogram',
    };

    await tester.pumpWidget(GetMaterialApp(home: GenogramBuilderView(initialData: initialData)));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    // Member names should be present in the builder list
  });
}
