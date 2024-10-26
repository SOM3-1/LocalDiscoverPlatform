-- Trigger to check review eligibility
CREATE OR REPLACE TRIGGER trg_Check_Review_Eligibility
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Ensure the booking exists and is marked as 'Completed'
    SELECT COUNT(*) INTO v_count
    FROM Dg_Bookings
    WHERE Traveler_ID = :NEW.Traveler_ID
      AND Experience_ID = :NEW.Experience_ID
      AND Booking_Status_ID = (SELECT Status_ID FROM Dg_Booking_Status WHERE Status_Name = 'Confirmed');

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Review can only be submitted for completed bookings.');
    END IF;
END;
/

-- Compound trigger to update Group_Size after adding or removing a member
CREATE OR REPLACE TRIGGER trg_Update_Group_Size
FOR INSERT OR DELETE ON Dg_Group_Members
COMPOUND TRIGGER
    v_group_id VARCHAR2(20);

BEFORE EACH ROW IS
BEGIN
    IF INSERTING THEN
        v_group_id := :NEW.Group_ID;
    ELSIF DELETING THEN
        v_group_id := :OLD.Group_ID;
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    UPDATE Dg_Groups
    SET Group_Size = (SELECT COUNT(*) FROM Dg_Group_Members WHERE Group_ID = v_group_id)
    WHERE Group_ID = v_group_id;
END AFTER STATEMENT;
END trg_Update_Group_Size;
/

-- Trigger to prevent the group leader from being added as a regular member
CREATE OR REPLACE TRIGGER trg_Prevent_Leader_As_Member
BEFORE INSERT ON Dg_Group_Members
FOR EACH ROW
DECLARE
    v_group_leader_id VARCHAR2(20);
BEGIN
    SELECT Group_Leader_T_ID INTO v_group_leader_id
    FROM Dg_Groups
    WHERE Group_ID = :NEW.Group_ID
      AND Group_Leader_T_ID IS NOT NULL;

    IF :NEW.T_ID = v_group_leader_id THEN
        RAISE_APPLICATION_ERROR(-20002, 'Group leader cannot be added as a regular member.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
END;
/

-- Trigger to prevent bookings for expereince dates
CREATE OR REPLACE TRIGGER trg_Prevent_Invalid_Booking_Dates
BEFORE INSERT OR UPDATE ON Dg_Bookings
FOR EACH ROW
BEGIN
    -- Check if the booking date is after the experience date
    IF :NEW.Date_Of_Booking > :NEW.Experience_Date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Booking date cannot be after the experience date.');
    END IF;
END;
/

--INSERT INTO Dg_Bookings (  Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID ) VALUES ('B12346', 'T00001', 'E00001', TO_DATE('2024-11-01', 'YYYY-MM-DD'), TO_DATE('2024-10-31', 'YYYY-MM-DD'), 200.00, 'CONFIRMED', 'ONLINE', 'PENDING');


-- Trigger to prevent cancellations for past or completed bookings
CREATE OR REPLACE TRIGGER trg_Prevent_Invalid_Cancellations
BEFORE UPDATE ON Dg_Bookings
FOR EACH ROW
DECLARE
    v_completed_status_id VARCHAR2(20);
BEGIN
    -- Fetch the status ID for 'Completed'
    SELECT Status_ID INTO v_completed_status_id 
    FROM Dg_Booking_Status 
    WHERE Status_Name = 'Completed';

    -- Check if the booking is canceled after experience date or if already completed
    IF :NEW.Booking_Status_ID = v_completed_status_id AND :OLD.Experience_Date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20007, 'Booking cannot be canceled after the experience date or once it is completed.');
    END IF;
END;
/

-- Trigger to validate that reviews can only be submitted for confirmed bookings
CREATE OR REPLACE TRIGGER trg_Validate_Review_Status
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_booking_status VARCHAR2(20);
    v_confirmed_status_id VARCHAR2(20);
BEGIN
    -- Get the status ID for 'Confirmed'
    SELECT Status_ID INTO v_confirmed_status_id 
    FROM Dg_Booking_Status 
    WHERE Status_Name = 'Confirmed';

    -- Retrieve the booking status
    SELECT Booking_Status_ID INTO v_booking_status
    FROM Dg_Bookings
    WHERE Traveler_ID = :NEW.Traveler_ID
      AND Experience_ID = :NEW.Experience_ID;

    -- Ensure the booking status is 'Confirmed'
    IF v_booking_status != v_confirmed_status_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Reviews can only be submitted for confirmed bookings.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20018, 'No booking found for this traveler and experience.');
END;
/

-- Trigger to prevent ratings for canceled bookings
CREATE OR REPLACE TRIGGER trg_Prevent_Rating_For_Canceled
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_booking_status VARCHAR2(20);
    v_canceled_status_id VARCHAR2(20);
BEGIN
    -- Get the status ID for 'Canceled'
    SELECT Status_ID INTO v_canceled_status_id 
    FROM Dg_Booking_Status 
    WHERE Status_Name = 'Cancelled';

    -- Retrieve the booking status
    SELECT Booking_Status_ID INTO v_booking_status
    FROM Dg_Bookings
    WHERE Traveler_ID = :NEW.Traveler_ID
      AND Experience_ID = :NEW.Experience_ID;

    -- Prevent ratings if the booking is canceled
    IF v_booking_status = v_canceled_status_id THEN
        RAISE_APPLICATION_ERROR(-20017, 'Ratings cannot be submitted for canceled bookings.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20018, 'No booking found for this traveler and experience.');
END;

/
