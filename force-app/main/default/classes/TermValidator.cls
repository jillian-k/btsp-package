/**
 * TermValidator
 * Validates free-text term values from affiliate orgs and normalizes them
 * to match Affiliate_Term__c picklist values in National.
 *
 * Valid formats:
 *   School Year: "2024/2025 SY" or "2024 / 2025 SY" (spaces both sides or neither)
 *   Summer:      "2024 Summer"
 *
 * Invalid terms are flagged for Manual Review with a descriptive reason.
 */
public with sharing class TermValidator {

    public class TermResult {
        public Boolean isValid;
        public String termType;      // 'School Year', 'Summer', or 'Manual Review'
        public String year;           // e.g. '2024' or '0000' for invalid
        public String normalizedTerm; // e.g. '2024/2025 SY' or '2024 Summer' or 'Manual Review'
        public String invalidReason;  // null if valid, descriptive reason if invalid

        public TermResult(Boolean isValid, String termType, String year, String normalizedTerm, String invalidReason) {
            this.isValid = isValid;
            this.termType = termType;
            this.year = year;
            this.normalizedTerm = normalizedTerm;
            this.invalidReason = invalidReason;
        }
    }

    /**
     * Validate and normalize a raw term string.
     * @param rawTerm The free-text term from the affiliate
     * @return TermResult with validation outcome
     */
    public static TermResult validate(String rawTerm) {
        if (String.isBlank(rawTerm)) {
            return manualReview('Empty string');
        }

        String trimmed = rawTerm.trim();

        // --- Summer pattern: "2024 Summer" ---
        Pattern summerPattern = Pattern.compile('^(\\d{4})\\s+Summer$');
        Matcher summerMatcher = summerPattern.matcher(trimmed);
        if (summerMatcher.matches()) {
            String yr = summerMatcher.group(1);
            return new TermResult(true, 'Summer', yr, yr + ' Summer', null);
        }

        // --- School Year pattern: "2024/2025 SY" or "2024 / 2025 SY" ---
        // Valid: spaces on BOTH sides of slash or NEITHER side
        Pattern syValidPattern = Pattern.compile('^(\\d{4})\\s*/\\s*(\\d{4})\\s+SY$');
        Matcher syMatcher = syValidPattern.matcher(trimmed);
        if (syMatcher.matches()) {
            // Check spacing consistency around the slash
            Pattern noSpaces = Pattern.compile('^\\d{4}/\\d{4}\\s+SY$');
            Pattern bothSpaces = Pattern.compile('^\\d{4}\\s+/\\s+\\d{4}\\s+SY$');

            if (noSpaces.matcher(trimmed).matches() || bothSpaces.matcher(trimmed).matches()) {
                String yr1 = syMatcher.group(1);
                String yr2 = syMatcher.group(2);
                String normalized = yr1 + '/' + yr2 + ' SY';
                return new TermResult(true, 'School Year', yr1, normalized, null);
            }

            // Asymmetric spacing around slash
            Pattern spaceAfterOnly = Pattern.compile('^\\d{4}/\\s+\\d{4}\\s+SY$');
            Pattern spaceBeforeOnly = Pattern.compile('^\\d{4}\\s+/\\d{4}\\s+SY$');

            if (spaceAfterOnly.matcher(trimmed).matches()) {
                return manualReview('Space only after slash');
            }
            if (spaceBeforeOnly.matcher(trimmed).matches()) {
                return manualReview('Space only before slash');
            }

            return manualReview('Inconsistent spacing around slash');
        }

        // --- Common invalid patterns with descriptive reasons ---

        // Hyphen instead of slash: "2020-2021 SY"
        Pattern hyphenPattern = Pattern.compile('^\\d{4}\\s*-\\s*\\d{4}\\s+SY$');
        if (hyphenPattern.matcher(trimmed).matches()) {
            return manualReview('Uses hyphen instead of slash');
        }

        // Year only: "2020"
        Pattern yearOnly = Pattern.compile('^\\d{4}$');
        if (yearOnly.matcher(trimmed).matches()) {
            return manualReview('Missing term type');
        }

        // Year at end: "Summer 2020" or "SY 2020/2021"
        Pattern yearAtEnd = Pattern.compile('^(Summer|SY)\\s+\\d{4}');
        if (yearAtEnd.matcher(trimmed).matches()) {
            return manualReview('Year not at start');
        }

        // Wordy: "School Year 2020" or "School Year 2020/2021"
        Pattern wordy = Pattern.compile('(?i)^school\\s+year\\s+\\d{4}');
        if (wordy.matcher(trimmed).matches()) {
            return manualReview('Wrong format entirely');
        }

        // Catch-all
        return manualReview('No valid pattern');
    }

    private static TermResult manualReview(String reason) {
        return new TermResult(false, 'Manual Review', '0000', 'Manual Review', reason);
    }
}
