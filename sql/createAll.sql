
-- Creating the Dg_Interest_Categories
CREATE TABLE Dg_Interest_Categories (
    Category_ID VARCHAR2(20) PRIMARY KEY,
    Category_Name VARCHAR2(100) NOT NULL UNIQUE
);

-- Creating the Dg_Locations
CREATE TABLE Dg_Locations (
    Location_ID VARCHAR2(20) PRIMARY KEY,
    Location_Name VARCHAR2(100) NOT NULL UNIQUE
);

-- Creating the Dg_Tags
CREATE TABLE Dg_Tags (
    Tag_ID VARCHAR2(20) PRIMARY KEY,
    Tag_Name VARCHAR2(50) UNIQUE NOT NULL
);

-- Creating the Dg_Group_Types
CREATE TABLE Dg_Group_Types (
    Group_Type_ID VARCHAR2(20) PRIMARY KEY,
    Group_Type_Name VARCHAR2(50) UNIQUE NOT NULL
);

CREATE TABLE Dg_Booking_Methods (
    Method_ID VARCHAR2(20) PRIMARY KEY,
    Method_Name VARCHAR2(50) UNIQUE NOT NULL
);

CREATE TABLE Dg_Booking_Status (
    Status_ID VARCHAR2(20) PRIMARY KEY,
    Status_Name VARCHAR2(50) UNIQUE NOT NULL
);

CREATE TABLE Dg_Payment_Status (
    Payment_Status_ID VARCHAR2(20) PRIMARY KEY,
    Payment_Status_Name VARCHAR2(50) UNIQUE NOT NULL
);

-- Creating the Dg_Travelers table
CREATE TABLE Dg_Travelers (
    T_ID VARCHAR2(20) PRIMARY KEY,
    First_Name VARCHAR2(50) NOT NULL,
    Last_Name VARCHAR2(50) NOT NULL,
    DOB DATE NOT NULL,
    Demographic_Type VARCHAR2(50),
    Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')),
    Location_ID VARCHAR2(20) REFERENCES Dg_Locations(Location_ID),
    Email VARCHAR2(50) UNIQUE NOT NULL,
    Phone VARCHAR2(15) UNIQUE NOT NULL
);

-- Creating the Dg_Traveler_Preferences table with a unique constraint to prevent duplicate preferences
CREATE TABLE Dg_Traveler_Preferences (
    T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Preference_ID VARCHAR2(20) REFERENCES Dg_Interest_Categories(Category_ID),
    PRIMARY KEY (T_ID, Preference_ID)
);

-- Creating the Dg_Groups table
CREATE TABLE Dg_Groups (
    Group_ID VARCHAR2(20) PRIMARY KEY,
    Group_Name VARCHAR2(100),
    Group_Leader_T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Group_Type_ID VARCHAR2(20) REFERENCES Dg_Group_Types(Group_Type_ID),
    Group_Size NUMBER DEFAULT 0
);

-- Creating the Dg_Group_Members table
CREATE TABLE Dg_Group_Members (
    Group_ID VARCHAR2(20) REFERENCES Dg_Groups(Group_ID),
    T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    PRIMARY KEY (Group_ID, T_ID)
);

-- Creating the Dg_Service_Provider table
CREATE TABLE Dg_Service_Provider (
    Service_Provider_ID VARCHAR2(20) PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Email VARCHAR2(50) UNIQUE NOT NULL,
    Phone VARCHAR2(15) UNIQUE NOT NULL,
    Bio VARCHAR2(500),
    Street VARCHAR2(100),
    City VARCHAR2(50),
    Zip VARCHAR2(10),
    Country VARCHAR2(100)
);

-- Creating the  Dg_Service_Provider_Activities table
CREATE TABLE Dg_Service_Provider_Activities (
    Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
    Activity_ID VARCHAR2(20) REFERENCES Dg_Interest_Categories(Category_ID),
    PRIMARY KEY (Service_Provider_ID, Activity_ID)
);

-- Creating the  Dg_Availability_Schedule table
CREATE TABLE Dg_Availability_Schedule (
    Schedule_ID VARCHAR2(20) PRIMARY KEY,
    Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
    Available_Date DATE NOT NULL
);

-- Creating the  Dg_Schedule_Locations table
CREATE TABLE Dg_Schedule_Locations (
    Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
    Location_ID VARCHAR2(20) REFERENCES Dg_Locations(Location_ID),
    PRIMARY KEY (Schedule_ID, Location_ID)
);

-- Creating the  Dg_Schedule_Times table
CREATE TABLE Dg_Schedule_Times (
    Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
    Start_Time TIMESTAMP NOT NULL,
    End_Time TIMESTAMP NOT NULL,
    PRIMARY KEY (Schedule_ID, Start_Time),
    CHECK (End_Time > Start_Time) 
);

-- Creating the Dg_Experience table
CREATE TABLE Dg_Experience (
        Experience_ID VARCHAR2(20) PRIMARY KEY,
        Title VARCHAR2(100) NOT NULL,
        Description VARCHAR2(500),
        Group_Availability CHAR(1) CHECK (Group_Availability IN ('Y', 'N')), -- 'Y' for Yes, 'N' for No
        Min_Group_Size NUMBER DEFAULT 0,
        Max_Group_Size NUMBER DEFAULT 0,
        Pricing NUMBER CHECK (Pricing >= 0),
        Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
        Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
        CHECK (
            (Group_Availability = 'Y' AND Min_Group_Size >= 2 AND Min_Group_Size <= 20 AND Max_Group_Size >= Min_Group_Size AND Max_Group_Size <= 20) OR
            (Group_Availability = 'N' AND Min_Group_Size = 0 AND Max_Group_Size = 0)
        )
    );

-- Creating the Dg_Experience_Tags table
CREATE TABLE Dg_Experience_Tags (
    Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
    Tag_ID VARCHAR2(20) REFERENCES Dg_Tags(Tag_ID),
    PRIMARY KEY (Experience_ID, Tag_ID)
);

-- Creating the Dg_Bookings table
CREATE TABLE Dg_Bookings (
    Booking_ID VARCHAR2(20) PRIMARY KEY,
    Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
    Date_Of_Booking TIMESTAMP NOT NULL,
    Experience_Date DATE NOT NULL,
    Amount_Paid NUMBER NOT NULL CHECK (Amount_Paid >= 0),
    Booking_Status_ID VARCHAR2(20) REFERENCES Dg_Booking_Status(Status_ID),
    Booking_Method_ID VARCHAR2(20) REFERENCES Dg_Booking_Methods(Method_ID),
    Payment_Status_ID VARCHAR2(20) DEFAULT 'Pending' REFERENCES Dg_Payment_Status(Payment_Status_ID)
);

-- Creating the Dg_Ratings table
CREATE TABLE Dg_Ratings (
    Rating_ID VARCHAR2(20) PRIMARY KEY,
    Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
    Rating_Value NUMBER CHECK (Rating_Value BETWEEN 1 AND 10),
    Review_Date_Time TIMESTAMP DEFAULT SYSDATE, -- Automatically set review date to current date
    Feedback VARCHAR2(500),
    Review_Title VARCHAR2(100)
);

-- Consolidated Trigger: Validate Review Eligibility - trg_Review_Eligibility
CREATE OR REPLACE TRIGGER trg_Review_Eligibility
BEFORE INSERT ON Dg_Ratings
FOR EACH ROW
DECLARE
    v_booking_status VARCHAR2(20);
    v_confirmed_status_id VARCHAR2(20);
    v_canceled_status_id VARCHAR2(20);
BEGIN
    -- Get the status IDs for 'Confirmed' and 'Canceled'
    SELECT Status_ID INTO v_confirmed_status_id FROM Dg_Booking_Status WHERE Status_Name = 'Confirmed';
    SELECT Status_ID INTO v_canceled_status_id FROM Dg_Booking_Status WHERE Status_Name = 'Cancelled';

    -- Retrieve the booking status for the traveler and experience
    SELECT Booking_Status_ID INTO v_booking_status
    FROM Dg_Bookings
    WHERE Traveler_ID = :NEW.Traveler_ID
      AND Experience_ID = :NEW.Experience_ID;

    -- Ensure the booking is confirmed and not canceled
    IF v_booking_status != v_confirmed_status_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Reviews can only be submitted for confirmed bookings.');
    ELSIF v_booking_status = v_canceled_status_id THEN
        RAISE_APPLICATION_ERROR(-20017, 'Ratings cannot be submitted for canceled bookings.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20018, 'No booking found for this traveler and experience.');
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
