with open('lib/screens/calendar_screen.dart', 'r') as f:
    c = f.read()

# Fix 1: provider -> context.watch
old1 = "if (provider.monthRecords.isNotEmpty)\n            _buildMoodPersonalityBadge(isDark, provider.monthRecords)"
new1 = "if (context.watch<EmotionProvider>().monthRecords.isNotEmpty)\n            _buildMoodPersonalityBadge(isDark, context.watch<EmotionProvider>().monthRecords)"
c = c.replace(old1, new1)

# Fix 2: monthRecords -> context.watch
old2 = "if (monthRecords.isNotEmpty)\n            _buildMonthSummary(isDark, monthRecords)"
new2 = "if (context.watch<EmotionProvider>().monthRecords.isNotEmpty)\n            _buildMonthSummary(isDark, context.watch<EmotionProvider>().monthRecords)"
c = c.replace(old2, new2)

with open('lib/screens/calendar_screen.dart', 'w') as f:
    f.write(c)
print('Fixed)
