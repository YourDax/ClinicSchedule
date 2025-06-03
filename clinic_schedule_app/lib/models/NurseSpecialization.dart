enum NurseSpecialization {
  general,       // Общая медсестра
  pediatric,     // Педиатрия
  surgical,      // Хирургия
  intensiveCare, // Реанимация
  oncology,      // Онкология
  maternity,     // Акушерство
}

extension NurseSpecializationExtension on NurseSpecialization {
  String get displayName {
    switch (this) {
      case NurseSpecialization.general:
        return 'Общая';
      case NurseSpecialization.pediatric:
        return 'Педиатрия';
      case NurseSpecialization.surgical:
        return 'Хирургия';
      case NurseSpecialization.intensiveCare:
        return 'Реанимация';
      case NurseSpecialization.oncology:
        return 'Онкология';
      case NurseSpecialization.maternity:
        return 'Акушерство';
    }
  }

  static NurseSpecialization? fromString(String value) {
    try {
      return NurseSpecialization.values.firstWhere(
            (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return null; // если не найдено — возвращаем null
    }
  }

}
