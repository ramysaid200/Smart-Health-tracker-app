/// Form validation utilities
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final err = password(value);
    if (err != null) return err;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return 'Enter a valid positive number';
    return null;
  }

  static String? optionalPositiveNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null || n <= 0) return 'Enter a valid positive number';
    return null;
  }

  static String? bloodPressure(String? value, {required bool isSystolic}) {
    if (value == null || value.isEmpty) return 'Required';
    final n = int.tryParse(value);
    if (n == null) return 'Enter a whole number';
    if (isSystolic && (n < 60 || n > 250)) return 'Range: 60–250';
    if (!isSystolic && (n < 40 || n > 150)) return 'Range: 40–150';
    return null;
  }

  static String? heartRate(String? value) {
    if (value == null || value.isEmpty) return 'Heart rate is required';
    final n = int.tryParse(value);
    if (n == null || n < 30 || n > 250) return 'Enter a value between 30–250';
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.isEmpty) return 'Weight is required';
    final n = double.tryParse(value);
    if (n == null || n < 20 || n > 500) return 'Enter a valid weight (20–500)';
    return null;
  }

  static String? height(String? value) {
    if (value == null || value.isEmpty) return 'Height is required';
    final n = double.tryParse(value);
    if (n == null || n < 50 || n > 300) return 'Enter a valid height (50–300 cm)';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final n = int.tryParse(value);
    if (n == null || n < 1 || n > 120) return 'Enter a valid age (1–120)';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? dosage(String? value) {
    if (value == null || value.trim().isEmpty) return 'Dosage is required';
    return null;
  }

  static String? foodCalories(String? value) {
    if (value == null || value.isEmpty) return 'Calories required';
    final n = double.tryParse(value);
    if (n == null || n < 0) return 'Enter a valid calorie amount';
    return null;
  }
}
