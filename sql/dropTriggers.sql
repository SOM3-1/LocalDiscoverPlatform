-- Drop trigger to check review eligibility
DROP TRIGGER trg_Check_Review_Eligibility;

-- Drop trigger to update Group_Size after a member is added
DROP TRIGGER trg_Update_Group_Size;

-- Drop trigger to prevent the group leader from being added as a regular member
DROP TRIGGER trg_Prevent_Leader_As_Member;

-- Drop trigger to prevent bookings for past dates
DROP TRIGGER trg_Prevent_Past_Bookings;

-- Drop trigger to automatically set Payment_Status to 'Pending'
DROP TRIGGER trg_Default_Payment_Status;

-- Drop trigger to prevent duplicate ratings
DROP TRIGGER trg_Prevent_Duplicate_Ratings;

-- Drop trigger to auto-confirm booking after payment is completed
DROP TRIGGER trg_Auto_Confirm_Booking;

-- Drop trigger to prevent cancellations for past or completed bookings
DROP TRIGGER trg_Prevent_Invalid_Cancellations;

-- Drop trigger to automatically set the Review_Date to today when inserting a new review
DROP TRIGGER trg_Set_Review_Date_Time;

-- Drop trigger to validate that reviews can only be submitted for confirmed bookings
DROP TRIGGER trg_Validate_Review_Status;

-- Drop trigger to automatically mark booking as 'Completed' after the experience date
DROP TRIGGER trg_Auto_Complete_Booking;

-- Drop trigger to ensure guide availability for the booking date
DROP TRIGGER trg_Check_Guide_Availability;

-- Drop trigger to restrict booking modifications within 48 hours of the experience date
DROP TRIGGER trg_Restrict_Booking_Modifications;

-- Drop trigger to prevent ratings for canceled bookings
DROP TRIGGER trg_Prevent_Rating_For_Canceled;

-- Drop trigger to prevent modifications to past bookings
DROP TRIGGER trg_Prevent_Modifications_To_Past_Bookings;
