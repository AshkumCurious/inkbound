class StorySegment {
  final String text;
  final List<String> choices;
  final String? choiceMade;

  const StorySegment({
    required this.text,
    required this.choices,
    this.choiceMade,
  });

  StorySegment copyWith({String? choiceMade}) {
    return StorySegment(
      text: text,
      choices: choices,
      choiceMade: choiceMade ?? this.choiceMade,
    );
  }
}

class StoryState {
  final List<StorySegment> segments;
  final bool isLoading;
  final String? error;

  const StoryState({
    this.segments = const [],
    this.isLoading = false,
    this.error,
  });

  StoryState copyWith({
    List<StorySegment>? segments,
    bool? isLoading,
    String? error,
  }) {
    return StoryState(
      segments: segments ?? this.segments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasStory => segments.isNotEmpty;
  StorySegment? get currentSegment => segments.isEmpty ? null : segments.last;
}
