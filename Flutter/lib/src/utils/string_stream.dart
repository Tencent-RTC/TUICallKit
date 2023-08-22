class StringStream {
  static String makeNull(String? str, String defaultValue) {
    String nonNullableString = str?.isEmpty == false ? str! : defaultValue;
    return nonNullableString;
  }

  static String makeNonNull(String str, String defaultValue) {
    String nonNullableString = str.isEmpty ? defaultValue : str;
    return nonNullableString;
  }
}
