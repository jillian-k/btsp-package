/**
 * TermValidatorTest
 * Tests all term validation patterns including valid and invalid formats.
 */
@IsTest
private class TermValidatorTest {

    // ── Valid School Year ──

    @IsTest
    static void testValidSchoolYear_NoSpaces() {
        TermValidator.TermResult result = TermValidator.validate('2020/2021 SY');
        System.assertEquals(true, result.isValid, 'Should be valid');
        System.assertEquals('School Year', result.termType);
        System.assertEquals('2020', result.year);
        System.assertEquals('2020/2021 SY', result.normalizedTerm);
        System.assertEquals(null, result.invalidReason);
    }

    @IsTest
    static void testValidSchoolYear_BothSpaces() {
        TermValidator.TermResult result = TermValidator.validate('2020 / 2021 SY');
        System.assertEquals(true, result.isValid, 'Should be valid');
        System.assertEquals('School Year', result.termType);
        System.assertEquals('2020', result.year);
        System.assertEquals('2020/2021 SY', result.normalizedTerm, 'Should normalize to no spaces');
        System.assertEquals(null, result.invalidReason);
    }

    // ── Valid Summer ──

    @IsTest
    static void testValidSummer() {
        TermValidator.TermResult result = TermValidator.validate('2024 Summer');
        System.assertEquals(true, result.isValid, 'Should be valid');
        System.assertEquals('Summer', result.termType);
        System.assertEquals('2024', result.year);
        System.assertEquals('2024 Summer', result.normalizedTerm);
        System.assertEquals(null, result.invalidReason);
    }

    // ── Invalid: Space only after slash ──

    @IsTest
    static void testInvalid_SpaceAfterSlash() {
        TermValidator.TermResult result = TermValidator.validate('2020/ 2021 SY');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('0000', result.year);
        System.assertEquals('Manual Review', result.normalizedTerm);
        System.assertEquals('Space only after slash', result.invalidReason);
    }

    // ── Invalid: Space only before slash ──

    @IsTest
    static void testInvalid_SpaceBeforeSlash() {
        TermValidator.TermResult result = TermValidator.validate('2020 /2021 SY');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Space only before slash', result.invalidReason);
    }

    // ── Invalid: Hyphen instead of slash ──

    @IsTest
    static void testInvalid_Hyphen() {
        TermValidator.TermResult result = TermValidator.validate('2020-2021 SY');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Uses hyphen instead of slash', result.invalidReason);
    }

    // ── Invalid: Year only ──

    @IsTest
    static void testInvalid_YearOnly() {
        TermValidator.TermResult result = TermValidator.validate('2020');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Missing term type', result.invalidReason);
    }

    // ── Invalid: Year not at start ──

    @IsTest
    static void testInvalid_YearNotAtStart() {
        TermValidator.TermResult result = TermValidator.validate('Summer 2020');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Year not at start', result.invalidReason);
    }

    // ── Invalid: Wrong format entirely ──

    @IsTest
    static void testInvalid_WrongFormat() {
        TermValidator.TermResult result = TermValidator.validate('School Year 2020');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Wrong format entirely', result.invalidReason);
    }

    // ── Invalid: Empty string ──

    @IsTest
    static void testInvalid_Empty() {
        TermValidator.TermResult result = TermValidator.validate('');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Empty string', result.invalidReason);
    }

    @IsTest
    static void testInvalid_Null() {
        TermValidator.TermResult result = TermValidator.validate(null);
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Empty string', result.invalidReason);
    }

    // ── Invalid: No valid pattern ──

    @IsTest
    static void testInvalid_NoPattern() {
        TermValidator.TermResult result = TermValidator.validate('TBD');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('No valid pattern', result.invalidReason);
    }

    // ── Invalid: Whitespace only ──

    @IsTest
    static void testInvalid_WhitespaceOnly() {
        TermValidator.TermResult result = TermValidator.validate('   ');
        System.assertEquals(false, result.isValid, 'Should be invalid');
        System.assertEquals('Manual Review', result.termType);
        System.assertEquals('Empty string', result.invalidReason);
    }
}
