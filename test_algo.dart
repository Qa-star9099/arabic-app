// ignore_for_file: avoid_print
void main() {
  String arabic = "سَفَر";
  String expectedArabicStripped = arabic.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  print("Stripped: $expectedArabicStripped, Length: ${expectedArabicStripped.length}, Code Units: ${expectedArabicStripped.codeUnits}");
  
  String sttSafar = "سفر";
  print("STT: $sttSafar, Length: ${sttSafar.length}, Code Units: ${sttSafar.codeUnits}");
  
  print("Match: ${expectedArabicStripped == sttSafar}");
}
