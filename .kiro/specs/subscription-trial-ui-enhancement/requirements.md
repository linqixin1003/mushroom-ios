# Requirements Document

## Introduction

The Subscription Trial UI Enhancement feature will simplify the visual presentation of the yearly subscription with trial offer in the ConvertPage. The current implementation uses a complex HStack approach to display detailed trial information with price interpolation, but needs to be updated to use a simpler, more generic message. This enhancement will make the subscription offer cleaner and easier to understand.

## Requirements

### Requirement 1

**User Story:** As a user, I want to see a simple and clear display of the trial offer, so that I understand the basic subscription terms.

#### Acceptance Criteria

1. WHEN viewing the yearly subscription with trial option THEN the system SHALL display "7 days free trial, then yearly subscription" as a single line of text
2. WHEN displaying the trial offer THEN the system SHALL use consistent styling without price interpolation
3. WHEN the trial text is shown THEN the system SHALL use appropriate font size and weight for readability
4. WHEN displaying the trial offer THEN the system SHALL maintain the existing conditional display logic

### Requirement 2

**User Story:** As a user, I want the subscription information to be visually clean and uncluttered, so that I can quickly understand the offer.

#### Acceptance Criteria

1. WHEN viewing the yearly subscription with trial THEN the system SHALL display only the simplified trial message
2. WHEN displaying the trial information THEN the system SHALL remove complex price formatting and cancellation policy details
3. WHEN showing the trial text THEN the system SHALL use a single Text view instead of multiple components
4. WHEN arranging the text THEN the system SHALL maintain proper spacing with other UI elements