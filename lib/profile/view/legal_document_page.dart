import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/core.dart';

@RoutePage()
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    required this.title,
    required this.documentType,
    super.key,
  });

  final String title;
  final String documentType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _getDocumentContent(documentType),
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  String _getDocumentContent(String type) {
    if (type == 'privacy') {
      return '''
PRIVATUMO POLITIKA

Paskutinis atnaujinimas: 2026 m. sausio mėn.

1. BENDROSIOS NUOSTATOS

Ši privatumo politika aprašo, kaip „Jurbarkas" sveikatos stebėjimo programa (toliau – „Programa") renka, naudoja ir saugo jūsų asmens duomenis.

2. RENKAMI DUOMENYS

Mes renkame šiuos duomenis:
• Registracijos duomenys: vardas, pavardė, el. pašto adresas, telefono numeris, gimimo data
• Sveikatos duomenys: kraujo spaudimo rodmenys, kūno masės indeksas (KMI), cukraus kiekis kraujyje
• Komunikacijos duomenys: žinutės tarp pacientų ir gydytojų
• Techniniai duomenys: prisijungimo laikas, IP adresas

3. DUOMENŲ NAUDOJIMAS

Jūsų duomenys naudojami:
• Sveikatos stebėjimui ir analizei
• Komunikacijai su sveikatos priežiūros specialistais
• Priminimų siuntimui
• Apklausų vykdymui
• Sistemos saugumo užtikrinimui

4. DUOMENŲ SAUGOJIMAS

• Visi duomenys saugomi šifruotu pavidalu
• Prieiga prie duomenų suteikiama tik įgaliotiems asmenims
• Duomenys saugomi Europos Sąjungos teritorijoje

5. JŪSŲ TEISĖS

Pagal BDAR, jūs turite teisę:
• Gauti informaciją apie savo duomenis
• Prašyti ištaisyti netikslius duomenis
• Pateikti skundą priežiūros institucijai

Pastaba: Dėl sveikatos priežiūros reikalavimų, sveikatos duomenys negali būti ištrinti.

6. KONTAKTAI

Dėl privatumo klausimų kreipkitės: privacy@jurbarkas.lt
''';
    } else {
      return '''
TAISYKLĖS IR SĄLYGOS

Paskutinis atnaujinimas: 2026 m. sausio mėn.

1. PASLAUGOS APRAŠYMAS

„Jurbarkas" yra sveikatos stebėjimo programa, skirta pacientams registruoti ir stebėti savo sveikatos rodiklius bei bendrauti su sveikatos priežiūros specialistais.

2. NAUDOJIMOSI SĄLYGOS

Naudodamiesi programa, jūs sutinkate:
• Pateikti teisingą ir tikslią informaciją
• Saugoti savo prisijungimo duomenis
• Nenaudoti programos neteisėtais tikslais
• Nepažeisti kitų naudotojų privatumo

3. PASKYROS REGISTRACIJA

• Registruodamiesi turite būti ne jaunesni kaip 18 metų
• Kiekvienas asmuo gali turėti tik vieną paskyrą
• Esate atsakingas už visą veiklą, vykdomą per jūsų paskyrą

4. SVEIKATOS DUOMENYS

• Programa nėra skirta diagnozėms nustatyti
• Visada konsultuokitės su gydytoju dėl sveikatos klausimų
• Skubiais atvejais kreipkitės į greitąją medicinos pagalbą

5. ATSAKOMYBĖS RIBOJIMAS

• Programa teikiama „tokia, kokia yra"
• Negarantuojame nepertraukiamo paslaugos veikimo
• Neprisiimame atsakomybės už neteisingą duomenų interpretavimą

6. PAKEITIMAI

Pasiliekame teisę bet kada keisti šias taisykles. Apie esminius pakeitimus informuosime el. paštu.

7. GALIOJANTI TEISĖ

Šioms taisyklėms taikoma Lietuvos Respublikos teisė.

8. KONTAKTAI

Klausimai: info@jurbarkas.lt
''';
    }
  }
}
