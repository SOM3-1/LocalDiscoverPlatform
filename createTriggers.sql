-- Trigger to check review eligibility
CREATE OR REPLACE TRIGGER trg_Check_Review_Eligibility
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
BEGIN
    -- Ensure the booking exists and is marked as 'Completed'
    IF NOT EXISTS (
        SELECT 1
        FROM Dg_Bookings
        WHERE Traveler_ID = :NEW.Traveler_ID
          AND Experience_ID = :NEW.Experience_ID
          AND Status = 'Completed'
    ) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Review can only be submitted for completed bookings.');
    END IF;
END;
/

-- Trigger to update Group_Size after a member is added
CREATE OR REPLACE TRIGGER trg_Update_Group_Size_After_Insert
AFTER INSERT ON Dg_Group_Members
FOR EACH ROW
BEGIN
    UPDATE Dg_Groups
    SET Group_Size = (SELECT COUNT(*) FROM Dg_Group_Members WHERE Group_ID = :NEW.Group_ID)
    WHERE Group_ID = :NEW.Group_ID;
END;
/

-- Trigger to update Group_Size after a member is deleted
CREATE OR REPLACE TRIGGER trg_Update_Group_Size_After_Delete
AFTER DELETE ON Dg_Group_Members
FOR EACH ROW
BEGIN
    UPDATE Dg_Groups
    SET Group_Size = (SELECT COUNT(*) FROM Dg_Group_Members WHERE Group_ID = :OLD.Group_ID)
    WHERE Group_ID = :OLD.Group_ID;
END;
/

-- Trigger to prevent the group leader from being added as a regular member
CREATE OR REPLACE TRIGGER trg_Prevent_Leader_As_Member
BEFORE INSERT ON Dg_Group_Members
FOR EACH ROW
BEGIN
    IF :NEW.T_ID = (SELECT Group_Leader_T_ID FROM Dg_Groups WHERE Group_ID = :NEW.Group_ID) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Group leader cannot be added as a regular member.');
    END IF;
END;
/

-- Trigger to prevent duplicate preferences
CREATE OR REPLACE TRIGGER trg_Prevent_Duplicate_Preferences
BEFORE INSERT ON Dg_Traveler_Preferences
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Dg_Traveler_Preferences
    WHERE T_ID = :NEW.T_ID AND Preference = :NEW.Preference;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Duplicate preference for the traveler is not allowed.');
    END IF;
END;
/

-- Trigger to prevent bookings for past dates
CREATE OR REPLACE TRIGGER trg_Prevent_Past_Bookings
BEFORE INSERT OR UPDATE ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :NEW.Experience_Date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20004, 'Bookings cannot be made for past dates.');
    END IF;
END;
/

-- Trigger to automatically set Payment_Status to 'Pending' if not specified
CREATE OR REPLACE TRIGGER trg_Default_Payment_Status
BEFORE INSERT ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :NEW.Payment_Status IS NULL THEN
        :NEW.Payment_Status := 'Pending';
    END IF;
END;
/

-- Trigger to prevent duplicate ratings
CREATE OR REPLACE TRIGGER trg_Prevent_Duplicate_Ratings
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Dg_Ratings
    WHERE Traveler_ID = :NEW.Traveler_ID
      AND Experience_ID = :NEW.Experience_ID;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'A rating for this experience by the traveler already exists.');
    END IF;
END;
/

-- Trigger to auto-confirm booking after payment is completed
CREATE OR REPLACE TRIGGER trg_Auto_Confirm_Booking
AFTER UPDATE ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :NEW.Payment_Status = 'Completed' AND :OLD.Payment_Status != 'Completed' THEN
        UPDATE Dg_Bookings
        SET Status = 'Confirmed'
        WHERE Booking_ID = :NEW.Booking_ID;
    END IF;
END;
/

-- Trigger to prevent cancellations for past or completed bookings
CREATE OR REPLACE TRIGGER trg_Prevent_Invalid_Cancellations
BEFORE UPDATE ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :NEW.Status = 'Canceled' THEN
        IF :OLD.Experience_Date < SYSDATE OR :OLD.Status = 'Completed' THEN
            RAISE_APPLICATION_ERROR(-20007, 'Booking cannot be canceled after the experience date or once it is completed.');
        END IF;
    END IF;
END;
/

-- Trigger to automatically set the Review_Date to today when inserting a new review
CREATE OR REPLACE TRIGGER trg_Set_Review_Date_Time
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
BEGIN
    :NEW.Review_Date_Time := SYSDATE;
END;
/

-- Trigger to validate that reviews can only be submitted for confirmed bookings
CREATE OR REPLACE TRIGGER trg_Validate_Review_Status
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_booking_status VARCHAR2(20);
BEGIN
    -- Get the booking status for the corresponding traveler and experience
    SELECT Status INTO v_booking_status
    FROM Dg_Bookings
    WHERE Traveler_ID = :NEW.Traveler_ID
    AND Experience_ID = :NEW.Experience_ID;
    
    -- Ensure the booking status is 'Confirmed'
    IF v_booking_status != 'Confirmed' THEN
        RAISE_APPLICATION_ERROR(-20008, 'Reviews can only be submitted for confirmed bookings.');
    END IF;
END;
/

-- Trigger to automatically mark booking as 'Completed' after the experience date
CREATE OR REPLACE TRIGGER trg_Auto_Complete_Booking
AFTER UPDATE OF Experience_Date ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :NEW.Experience_Date < SYSDATE AND :OLD.Status != 'Completed' THEN
        UPDATE Dg_Bookings
        SET Status = 'Completed'
        WHERE Booking_ID = :NEW.Booking_ID;
    END IF;
END;
/

-- Trigger to ensure guide availability for the booking date
CREATE OR REPLACE TRIGGER trg_Check_Guide_Availability
BEFORE INSERT ON Dg_Bookings
FOR EACH ROW
DECLARE
    v_available_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_available_count
    FROM Dg_Experience e
    JOIN Dg_Service_Provider s ON e.Service_Provider_ID = s.Service_Provider_ID
    WHERE e.Experience_ID = :NEW.Experience_ID
    AND e.Schedule_Date = :NEW.Experience_Date;
    
    IF v_available_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'The guide is not available on the selected date.');
    END IF;
END;
/

-- Trigger to restrict booking modifications within 48 hours of the experience date
CREATE OR REPLACE TRIGGER trg_Restrict_Booking_Modifications
BEFORE UPDATE OR DELETE ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :OLD.Experience_Date - SYSDATE <= 2 THEN
        RAISE_APPLICATION_ERROR(-20016, 'Bookings cannot be modified within 48 hours of the scheduled date.');
    END IF;
END;
/

-- Trigger to prevent ratings for canceled bookings
CREATE OR REPLACE TRIGGER trg_Prevent_Rating_For_Canceled
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_booking_status VARCHAR2(20);
BEGIN
    SELECT Status INTO v_booking_status
    FROM Dg_Bookings
    WHERE Traveler_ID = :NEW.Traveler_ID
      AND Experience_ID = :NEW.Experience_ID;
      
    IF v_booking_status = 'Canceled' THEN
        RAISE_APPLICATION_ERROR(-20017, 'Ratings cannot be submitted for canceled bookings.');
    END IF;
END;
/

-- Trigger to prevent modifications to past bookings
CREATE OR REPLACE TRIGGER trg_Prevent_Modifications_To_Past_Bookings
BEFORE UPDATE OR DELETE ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :OLD.Experience_Date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20018, 'Modifications to past bookings are not allowed.');
    END IF;
END;
/

