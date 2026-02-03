/// Mutable form data class for question editing in the survey builder.
/// Not using Freezed because this is local UI state that changes frequently.
class QuestionFormData {
  QuestionFormData({
    this.id,
    this.questionText = '',
    this.questionType = 'single',
    this.isRequired = true,
    this.orderIndex = 0,
    List<OptionFormData>? options,
  }) : options = options ?? [];

  /// The question ID from the server (null for new questions).
  int? id;

  /// The question text.
  String questionText;

  /// The question type: 'single', 'multi', or 'text'.
  String questionType;

  /// Whether this question is required.
  bool isRequired;

  /// The order index for sorting.
  int orderIndex;

  /// The list of options for single/multi choice questions.
  List<OptionFormData> options;

  /// Creates a copy of this QuestionFormData.
  QuestionFormData copyWith({
    int? id,
    String? questionText,
    String? questionType,
    bool? isRequired,
    int? orderIndex,
    List<OptionFormData>? options,
  }) {
    return QuestionFormData(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      isRequired: isRequired ?? this.isRequired,
      orderIndex: orderIndex ?? this.orderIndex,
      options: options ?? this.options.map((o) => o.copyWith()).toList(),
    );
  }

  /// Validates this question data.
  /// Returns null if valid, or an error code if invalid.
  /// Error codes: 'question_text_required', 'options_required', 'option_text_required'
  String? validate() {
    if (questionText.trim().isEmpty) {
      return 'question_text_required';
    }
    if ((questionType == 'single' || questionType == 'multi') &&
        options.length < 2) {
      return 'options_required';
    }
    for (final option in options) {
      if (option.optionText.trim().isEmpty) {
        return 'option_text_required';
      }
    }
    return null;
  }
}

/// Mutable form data class for option editing in the survey builder.
class OptionFormData {
  OptionFormData({
    this.id,
    this.optionText = '',
    this.orderIndex = 0,
  });

  /// The option ID from the server (null for new options).
  int? id;

  /// The option text.
  String optionText;

  /// The order index for sorting.
  int orderIndex;

  /// Creates a copy of this OptionFormData.
  OptionFormData copyWith({
    int? id,
    String? optionText,
    int? orderIndex,
  }) {
    return OptionFormData(
      id: id ?? this.id,
      optionText: optionText ?? this.optionText,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
