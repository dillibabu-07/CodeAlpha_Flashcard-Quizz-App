// lib/utils/validators.dart

class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.trim().length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }
    return null;
  }

  static String? questionValidator(String? value) {
    return required(value, 'Question') ?? minLength(value, 3, 'Question');
  }

  static String? answerValidator(String? value) {
    return required(value, 'Answer') ?? minLength(value, 1, 'Answer');
  }

  static String? categoryNameValidator(String? value) {
    return required(value, 'Category name') ??
        minLength(value, 2, 'Category name') ??
        maxLength(value, 50, 'Category name');
  }
}
