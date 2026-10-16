import 'package:flutter_test/flutter_test.dart';
import 'package:roomly_app/main.dart';

void main() {
  testWidgets('Muestra la pantalla de bienvenida de Roomly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RoomlyApp());

    expect(find.text('Roomly'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Ya tengo una cuenta'), findsOneWidget);
  });
}