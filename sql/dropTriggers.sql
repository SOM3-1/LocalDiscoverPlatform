-- Drop trigger to check review eligibility
DROP TRIGGER trg_Check_Review_Eligibility;

-- Drop trigger to update Group_Size after a member is added
DROP TRIGGER trg_Update_Group_Size;

-- Drop trigger to prevent the group leader from being added as a regular member
DROP TRIGGER trg_Prevent_Leader_As_Member;

-- Drop trigger to prevent bookings for experience dates
DROP TRIGGER trg_Prevent_Invalid_Booking_Dates;

-- Drop trigger to prevent duplicate ratings
DROP TRIGGER trg_Prevent_Duplicate_Ratings;

-- Drop trigger to prevent cancellations for past or completed bookings
DROP TRIGGER trg_Prevent_Invalid_Cancellations;

-- Drop trigger to validate that reviews can only be submitted for confirmed bookings
DROP TRIGGER trg_Validate_Review_Status;

-- Drop trigger to prevent ratings for canceled bookings
DROP TRIGGER trg_Prevent_Rating_For_Canceled;
