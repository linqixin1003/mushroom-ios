# Implementation Plan

- [ ] 1. Add new localization key for simplified trial UI
  - Add `convert_trial_simple` key to all localization files with value "7 days free trial, then yearly subscription"
  - Update Language.swift to include the new static property for accessing this key
  - _Requirements: 1.1, 1.2_

- [ ] 2. Update ConvertPage trial text display section
  - Replace the existing complex HStack logic (lines 136-165) with simple Text view
  - Implement simplified trial text with proper font styling (15pt, regular, white)
  - Remove price interpolation and loading state logic
  - _Requirements: 1.1, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4_

- [ ] 3. Test the simplified UI implementation
  - Verify simplified trial text displays correctly
  - Test conditional display logic (only shows for yearly with trial)
  - Confirm font styling and layout integration matches design specifications
  - _Requirements: 1.1, 1.3, 1.4, 2.1, 2.4_