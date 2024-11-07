-- Triggers
-- Drop trigger to check review eligibility
DROP TRIGGER trg_Review_Eligibility;

-- Drop trigger to update Group_Size after a member is added
DROP TRIGGER trg_Update_Group_Size;

-- Drop trigger to prevent the group leader from being added as a regular member
DROP TRIGGER trg_Prevent_Leader_As_Member;

-- Drop trigger to prevent bookings for experience dates
DROP TRIGGER trg_Prevent_Invalid_Booking_Dates;

-- Drop trigger to prevent cancellations for past or completed bookings
DROP TRIGGER trg_Prevent_Invalid_Cancellations;

-- Drop the Fall24_S003_T8_Ratings table
DROP TABLE Fall24_S003_T8_Ratings CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Bookings table
DROP TABLE Fall24_S003_T8_Bookings CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Service_Provider_Activities table
DROP TABLE Fall24_S003_T8_Service_Provider_Activities CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Availability_Schedule table
DROP TABLE Fall24_S003_T8_Availability_Schedule CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Schedule_Locations table
DROP TABLE Fall24_S003_T8_Schedule_Locations CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Schedule_Times table
DROP TABLE Fall24_S003_T8_Schedule_Times CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Service_Provider table
DROP TABLE Fall24_S003_T8_Service_Provider CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Experience_Tags table
DROP TABLE Fall24_S003_T8_Experience_Tags CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Experience table
DROP TABLE Fall24_S003_T8_Experience CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Group_Members table
DROP TABLE Fall24_S003_T8_Group_Members CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Groups table
DROP TABLE Fall24_S003_T8_Groups CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Traveler_Preferences table
DROP TABLE Fall24_S003_T8_Traveler_Preferences CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Traveler_Preferences table
DROP TABLE Fall24_S003_T8_Interest_Categories CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Travelers table
DROP TABLE Fall24_S003_T8_Travelers CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Locations table
DROP TABLE Fall24_S003_T8_Locations CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Group_Types table
DROP TABLE Fall24_S003_T8_Group_Types CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Tags table
DROP TABLE Fall24_S003_T8_Tags CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Booking_Methods table
DROP TABLE Fall24_S003_T8_Booking_Methods CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Booking_Status table
DROP TABLE Fall24_S003_T8_Booking_Status CASCADE CONSTRAINTS;

-- Drop the Fall24_S003_T8_Payment_Status table
DROP TABLE Fall24_S003_T8_Payment_Status CASCADE CONSTRAINTS;

-- Clear recycle bin
PURGE RECYCLEBIN;
