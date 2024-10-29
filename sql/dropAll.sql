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

-- Drop the Dg_Ratings table
DROP TABLE Dg_Ratings CASCADE CONSTRAINTS;

-- Drop the Dg_Bookings table
DROP TABLE Dg_Bookings CASCADE CONSTRAINTS;

-- Drop the Dg_Service_Provider_Activities table
DROP TABLE Dg_Service_Provider_Activities CASCADE CONSTRAINTS;

-- Drop the Dg_Availability_Schedule table
DROP TABLE Dg_Availability_Schedule CASCADE CONSTRAINTS;

-- Drop the Dg_Schedule_Locations table
DROP TABLE Dg_Schedule_Locations CASCADE CONSTRAINTS;

-- Drop the Dg_Schedule_Times table
DROP TABLE Dg_Schedule_Times CASCADE CONSTRAINTS;

-- Drop the Dg_Service_Provider table
DROP TABLE Dg_Service_Provider CASCADE CONSTRAINTS;

-- Drop the Dg_Experience_Tags table
DROP TABLE Dg_Experience_Tags CASCADE CONSTRAINTS;

-- Drop the Dg_Experience table
DROP TABLE Dg_Experience CASCADE CONSTRAINTS;

-- Drop the Dg_Group_Members table
DROP TABLE Dg_Group_Members CASCADE CONSTRAINTS;

-- Drop the Dg_Groups table
DROP TABLE Dg_Groups CASCADE CONSTRAINTS;

-- Drop the Dg_Traveler_Preferences table
DROP TABLE Dg_Traveler_Preferences CASCADE CONSTRAINTS;

-- Drop the Dg_Traveler_Preferences table
DROP TABLE Dg_Interest_Categories CASCADE CONSTRAINTS;

-- Drop the Dg_Travelers table
DROP TABLE Dg_Travelers CASCADE CONSTRAINTS;

-- Drop the Dg_Locations table
DROP TABLE Dg_Locations CASCADE CONSTRAINTS;

-- Drop the Dg_Group_Types table
DROP TABLE Dg_Group_Types CASCADE CONSTRAINTS;

-- Drop the Dg_Tags table
DROP TABLE Dg_Tags CASCADE CONSTRAINTS;

-- Drop the Dg_Booking_Methods table
DROP TABLE Dg_Booking_Methods CASCADE CONSTRAINTS;

-- Drop the Dg_Booking_Status table
DROP TABLE Dg_Booking_Status CASCADE CONSTRAINTS;

-- Drop the Dg_Payment_Status table
DROP TABLE Dg_Payment_Status CASCADE CONSTRAINTS;

