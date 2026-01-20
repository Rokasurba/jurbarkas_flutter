import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/dashboard/data/models/user_profile.dart';
import 'package:frontend/dashboard/widgets/patient_profile_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('PatientProfileCard', () {
    const fullProfile = UserProfile(
      id: 1,
      name: 'Jonas',
      surname: 'Petraitis',
      email: 'jonas@example.com',
      phone: '+370 123 45678',
      dateOfBirth: '1990-05-15',
      role: 'patient',
    );

    const minimalProfile = UserProfile(
      id: 2,
      name: 'Petras',
      surname: 'Jonaitis',
      email: 'petras@example.com',
      role: 'patient',
    );

    testWidgets('displays full name', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: fullProfile),
      );

      expect(find.text('Jonas Petraitis'), findsOneWidget);
    });

    testWidgets('displays initials in avatar', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: fullProfile),
      );

      expect(find.text('JP'), findsOneWidget);
    });

    testWidgets('displays date of birth with label prefix', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: fullProfile),
      );

      // Should show label prefix and date
      expect(find.textContaining('Date of birth:'), findsOneWidget);
      expect(find.textContaining('1990-05-15'), findsOneWidget);
    });

    testWidgets('displays phone with label prefix', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: fullProfile),
      );

      // Should show label prefix and phone
      expect(find.textContaining('Phone number:'), findsOneWidget);
      expect(find.textContaining('+370 123 45678'), findsOneWidget);
    });

    testWidgets('does not display date of birth when null', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: minimalProfile),
      );

      // Only the name should be visible
      expect(find.text('Petras Jonaitis'), findsOneWidget);
      // Date of birth should not appear
      expect(find.text('1990-05-15'), findsNothing);
    });

    testWidgets('does not display phone when null', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: minimalProfile),
      );

      expect(find.text('+370 123 45678'), findsNothing);
    });

    testWidgets('renders CircleAvatar', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: fullProfile),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders Card widget', (tester) async {
      await tester.pumpApp(
        const PatientProfileCard(profile: fullProfile),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles empty name gracefully', (tester) async {
      const emptyNameProfile = UserProfile(
        id: 3,
        name: '',
        surname: '',
        email: 'empty@example.com',
        role: 'patient',
      );

      await tester.pumpApp(
        const PatientProfileCard(profile: emptyNameProfile),
      );

      // Should still render without crashing
      expect(find.byType(PatientProfileCard), findsOneWidget);
      // Initials should be empty
      expect(find.text(' '), findsOneWidget);
    });
  });
}
