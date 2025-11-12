class CategoryAI {
  static final Map<String, List<String>> keywords = {
    'Food': ['restaurant','dine','cafe','pizza','burger','meal','coffee'],
    'Travel': ['uber','taxi','bus','flight','train','cab'],
    'Bills': ['electricity','water','bill','net','internet','phone'],
    'Shopping': ['amazon','flipkart','shop','shopping','mall'],
    'Salary': ['salary','payroll']
  };

  static String? suggestCategory(String text) {
    final lower = text.toLowerCase();
    for (final entry in keywords.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) return entry.key;
      }
    }
    return null;
  }
}
