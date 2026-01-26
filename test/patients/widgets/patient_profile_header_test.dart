import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:frontend/patients/widgets/patient_profile_header.dart';
import 'package:frontend/patients/widgets/status_badge.dart';

import '../../helpers/helpers.dart';

void main() {
  final mockProfile = PatientProfile(
    id: 1,
    name: 'Petras',
    surname: 'Petraitis',
    email: 'petras@example.com',
    phone: '+37061234567',
    dateOfBirth: DateTime(1956, 3, 15),
    patientCode: 'JRB-001',
    isActive: true,
    createdAt: DateTime(2026, 1, 10, 8, 30),
  );

  final mockProfileNoCode = PatientProfile(
    id: 2,
    name: 'Jonas',
    surname: 'Jonaitis',
    email: 'jonas@example.com',
    isActive: false,
    createdAt: DateTime(2026, 1, 15),
  );

  group('PatientProfileHeader', () {
    testWidgets('displays patient full name', (tester) async {
      await tester.pumpApp(
        PatientProfileHeader(profile: mockProfile),
      );

      expect(find.text('Petras Petraitis'), findsOneWidget);
    });

    testWidgets('displays patient initials in avatar', (tester) async {
      await tester.pumpApp(
        PatientProfileHeader(profile: mockProfile),
      );

      expect(find.text('PP'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays status badge', (tester) async {
      await tester.pumpApp(
        PatientProfileHeader(profile: mockProfile),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('displays patient code when present', (tester) async {
      await tester.pumpApp(
        PatientProfileHeader(profile: mockProfile),
      );

      expect(find.text('JRB-001'), findsOneWidget);
    });

    testWidgets('hides patient code when null', (tester) async {
      await tester.pumpApp(
        PatientProfileHeader(profile: mockProfileNoCode),
      );

      expect(find.text('JRB-001'), findsNothing);
    });

    testWidgets('avatar has correct size (56dp diameter)', (tester) async {
      await tester.pumpApp(
        PatientProfileHeader(profile: mockProfile),
      );

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 28); // 28 * 2 = 56dp diameter
    });
  });
}
