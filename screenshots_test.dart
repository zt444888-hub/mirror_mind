import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Take App Store screenshots', (tester) async {
    // This will launch the app
    // Screenshots are saved by Codemagic as artifacts
    await tester.pumpAndSettle();
    await tester.takeScreenshot('1_home');
    
    // Navigate to settings
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.takeScreenshot('2_settings');
  });
}
