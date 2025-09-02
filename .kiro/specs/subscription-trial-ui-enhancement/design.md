# Design Document: Subscription Trial UI Enhancement

## Overview

The Subscription Trial UI Enhancement will simplify the display of the yearly subscription with trial offer in the ConvertPage. The current implementation uses a complex HStack approach to parse and display localized text with price interpolation. The new design will provide a single, clean line of text that communicates the basic trial offer without detailed pricing or policy information, improving readability and reducing visual clutter.

## Architecture

The enhancement will modify the existing ConvertPage SwiftUI view to replace the current complex trial text display with a simple, single-line message:

1. **Simplified Message**: "7 days free trial, then yearly subscription" - displayed as a clean, generic message

The implementation will maintain the existing conditional display logic (only shown when yearly with trial is selected) but will remove the price loading states and complex text parsing logic.

## Components and Interfaces

### ConvertPage Modifications

The trial text section (lines 136-165) will be replaced with a simple single Text view:

```swift
// Simplified trial information display
if self.selectedSku == LocalPurchaseManager.ProductID.yearlyWithTrial {
    Text(Language.convert_trial_simple)
        .font(.system(size: 15, weight: .regular))
        .foregroundColor(.white)
        .padding(.top, 16)
}
```

### Localization Updates

A new localization key will be added to support the simplified UI:

- `convert_trial_simple`: "7 days free trial, then yearly subscription"

### Visual Design Specifications

- **Simplified Trial Text**: 
  - Font: System, 15pt, Regular
  - Color: White
  - Alignment: Center (default)

- **Layout**:
  - Top padding: 16pt (maintains existing spacing)
  - No additional horizontal padding (uses default)

## Data Models

No new data models are required. The existing price retrieval logic from LocalPurchaseManager will continue to be used.

## Error Handling

Error handling will be simplified since the new implementation doesn't depend on price loading:
- The simplified trial text will always be displayed when the yearly with trial option is selected
- No price-dependent error states need to be handled

## Testing Strategy

### Manual Testing
1. **Text Display**: Verify that the simplified trial text displays correctly
2. **Conditional Logic**: Confirm that the text only appears when yearly with trial is selected
3. **Font Styling**: Test that the font size and color match the design specifications
4. **Layout Integration**: Verify that the simplified text integrates well with surrounding UI elements

### Localization Testing
1. Test the simplified text with different language translations
2. Verify that the text displays properly across all supported languages
3. Confirm that the layout remains clean and readable with different text lengths

## Implementation Notes

- The current complex HStack logic for parsing localized strings with `%@` placeholders will be completely removed
- The new implementation uses a simple Text view with a static localization key for better maintainability
- No price interpolation or complex text parsing is required
- The simplified approach reduces code complexity and potential localization issues

## Migration Considerations

- The existing `convert_free_trial_yearly` localization key will be replaced with one new key: `convert_trial_simple`
- The change is backward compatible as it only affects the UI presentation, not the underlying purchase logic
- No database or persistent storage changes are required
- The simplified implementation reduces maintenance overhead