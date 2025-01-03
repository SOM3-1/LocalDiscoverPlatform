create_table_statements = [
    """
    CREATE TABLE Fall24_S003_T8_Interest_Categories (
        Category_ID VARCHAR2(20) PRIMARY KEY,
        Category_Name VARCHAR2(100) NOT NULL UNIQUE
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Locations (
        Location_ID VARCHAR2(20) PRIMARY KEY,
        Location_Name VARCHAR2(100) NOT NULL UNIQUE
    )
    """,
    """
        CREATE TABLE Fall24_S003_T8_Tags (
        Tag_ID VARCHAR2(20) PRIMARY KEY,
        Tag_Name VARCHAR2(50) UNIQUE NOT NULL
    )""",
    """
        CREATE TABLE Fall24_S003_T8_Group_Types (
        Group_Type_ID VARCHAR2(20) PRIMARY KEY,
        Group_Type_Name VARCHAR2(50) UNIQUE NOT NULL)
    """,
    """
    CREATE TABLE Fall24_S003_T8_Booking_Methods (
        Method_ID VARCHAR2(20) PRIMARY KEY,
        Method_Name VARCHAR2(50) UNIQUE NOT NULL
    )""",
        """
    CREATE TABLE Fall24_S003_T8_Booking_Status (
        Status_ID VARCHAR2(20) PRIMARY KEY,
        Status_Name VARCHAR2(50) UNIQUE NOT NULL
    )
    """,
        """CREATE TABLE Fall24_S003_T8_Payment_Status (
        Payment_Status_ID VARCHAR2(20) PRIMARY KEY,
        Payment_Status_Name VARCHAR2(50) UNIQUE NOT NULL
    )""",
    """
    CREATE TABLE Fall24_S003_T8_Travelers (
        T_ID VARCHAR2(20) PRIMARY KEY,
        First_Name VARCHAR2(50) NOT NULL,
        Last_Name VARCHAR2(50) NOT NULL,
        DOB DATE NOT NULL,
        Demographic_Type VARCHAR2(50),
        Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')),
        Location_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Locations(Location_ID),
        Email VARCHAR2(50) UNIQUE NOT NULL,
        Phone VARCHAR2(15) UNIQUE NOT NULL
    )
    """,
    """
   CREATE TABLE Fall24_S003_T8_Traveler_Preferences (
    T_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Travelers(T_ID),
    Preference_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Interest_Categories(Category_ID),
    PRIMARY KEY (T_ID, Preference_ID)
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Groups (
        Group_ID VARCHAR2(20) PRIMARY KEY,
        Group_Name VARCHAR2(100),
        Group_Leader_T_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Travelers(T_ID),
        Group_Type_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Group_Types(Group_Type_ID),
        Group_Size NUMBER DEFAULT 0)
    """,
    """
    CREATE TABLE Fall24_S003_T8_Group_Members (
        Group_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Groups(Group_ID),
        T_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Travelers(T_ID),
        PRIMARY KEY (Group_ID, T_ID)
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Service_Provider (
        Service_Provider_ID VARCHAR2(20) PRIMARY KEY,
        Name VARCHAR2(100) NOT NULL,
        Email VARCHAR2(50) UNIQUE NOT NULL,
        Phone VARCHAR2(15) UNIQUE NOT NULL,
        Bio VARCHAR2(500),
        Street VARCHAR2(100),
        City VARCHAR2(50),
        Zip VARCHAR2(10),
        Country VARCHAR2(100)
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Service_Provider_Activities (
        Service_Provider_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Service_Provider(Service_Provider_ID),
        Activity_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Interest_Categories(Category_ID),
        PRIMARY KEY (Service_Provider_ID, Activity_ID)
    )""",
    """
    CREATE TABLE Fall24_S003_T8_Availability_Schedule (
        Schedule_ID VARCHAR2(20) PRIMARY KEY,
        Service_Provider_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Service_Provider(Service_Provider_ID),
        Available_Date DATE NOT NULL
    )""",
    """
    CREATE TABLE Fall24_S003_T8_Schedule_Locations (
        Schedule_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Availability_Schedule(Schedule_ID),
        Location_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Locations(Location_ID),
        PRIMARY KEY (Schedule_ID, Location_ID)
    )""",
    """
    CREATE TABLE Fall24_S003_T8_Schedule_Times (
        Schedule_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Availability_Schedule(Schedule_ID),
        Start_Time TIMESTAMP NOT NULL,
        End_Time TIMESTAMP NOT NULL,
        PRIMARY KEY (Schedule_ID, Start_Time),
        CHECK (End_Time > Start_Time)
    )

    """,
    """
    CREATE TABLE Fall24_S003_T8_Experience (
        Experience_ID VARCHAR2(20) PRIMARY KEY,
        Title VARCHAR2(100) NOT NULL,
        Description VARCHAR2(500),
        Group_Availability CHAR(1) CHECK (Group_Availability IN ('Y', 'N')), -- 'Y' for Yes, 'N' for No
        Min_Group_Size NUMBER DEFAULT 0,
        Max_Group_Size NUMBER DEFAULT 0,
        Pricing NUMBER CHECK (Pricing >= 0),
        Service_Provider_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Service_Provider(Service_Provider_ID),
        Schedule_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Availability_Schedule(Schedule_ID),
        CHECK (
            (Group_Availability = 'Y' AND Min_Group_Size >= 2 AND Min_Group_Size <= 20 AND Max_Group_Size >= Min_Group_Size AND Max_Group_Size <= 20) OR
            (Group_Availability = 'N' AND Min_Group_Size = 0 AND Max_Group_Size = 0)
        )
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Experience_Tags (
        Experience_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Experience(Experience_ID),
        Tag_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Tags(Tag_ID),
        PRIMARY KEY (Experience_ID, Tag_ID)
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Bookings (
        Booking_ID VARCHAR2(20) PRIMARY KEY,
        Traveler_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Travelers(T_ID),
        Experience_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Experience(Experience_ID),
        Date_Of_Booking TIMESTAMP NOT NULL,
        Experience_Date DATE NOT NULL,
        Amount_Paid NUMBER NOT NULL CHECK (Amount_Paid >= 0),
        Booking_Status_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Booking_Status(Status_ID),
        Booking_Method_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Booking_Methods(Method_ID),
        Payment_Status_ID VARCHAR2(20) DEFAULT 'Pending' REFERENCES Fall24_S003_T8_Payment_Status(Payment_Status_ID)
    )
    """,
    """
    CREATE TABLE Fall24_S003_T8_Ratings (
        Rating_ID VARCHAR2(20) PRIMARY KEY,
        Traveler_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Travelers(T_ID),
        Experience_ID VARCHAR2(20) REFERENCES Fall24_S003_T8_Experience(Experience_ID),
        Rating_Value NUMBER CHECK (Rating_Value BETWEEN 1 AND 10),
        Review_Date_Time TIMESTAMP DEFAULT SYSDATE, -- Set default review date to the current date
        Feedback VARCHAR2(500),
        Review_Title VARCHAR2(100),
        CONSTRAINT unique_traveler_experience UNIQUE (Traveler_ID, Experience_ID)
    )
    """,
]

create_trigger_statements = [
    # Validate Review Eligibility - trg_Review_Eligibility
    """
    CREATE OR REPLACE TRIGGER trg_Review_Eligibility
    BEFORE INSERT ON Fall24_S003_T8_Ratings
    FOR EACH ROW
    DECLARE
        v_booking_status VARCHAR2(20);
        v_confirmed_status_id VARCHAR2(20);
        v_canceled_status_id VARCHAR2(20);
    BEGIN
        -- Get the status IDs for 'Confirmed' and 'Canceled'
        SELECT Status_ID INTO v_confirmed_status_id FROM Fall24_S003_T8_Booking_Status WHERE Status_Name = 'Confirmed';
        SELECT Status_ID INTO v_canceled_status_id FROM Fall24_S003_T8_Booking_Status WHERE Status_Name = 'Cancelled';

        -- Retrieve the booking status for the traveler and experience
        SELECT Booking_Status_ID INTO v_booking_status
        FROM Fall24_S003_T8_Bookings
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
    """,
    # Compound Trigger to update Group_Size after adding or removing a member
    """
    CREATE OR REPLACE TRIGGER trg_Update_Group_Size
    FOR INSERT OR DELETE ON Fall24_S003_T8_Group_Members
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
        UPDATE Fall24_S003_T8_Groups
        SET Group_Size = (SELECT COUNT(*) FROM Fall24_S003_T8_Group_Members WHERE Group_ID = v_group_id)
        WHERE Group_ID = v_group_id;
    END AFTER STATEMENT;
    END trg_Update_Group_Size;
    """,
    # Trigger to prevent the group leader from being added as a member
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Leader_As_Member
    BEFORE INSERT ON Fall24_S003_T8_Group_Members
    FOR EACH ROW
    DECLARE
        v_group_leader_id VARCHAR2(20);
    BEGIN
        SELECT Group_Leader_T_ID INTO v_group_leader_id
        FROM Fall24_S003_T8_Groups
        WHERE Group_ID = :NEW.Group_ID
          AND Group_Leader_T_ID IS NOT NULL;

        IF :NEW.T_ID = v_group_leader_id THEN
            RAISE_APPLICATION_ERROR(-20002, 'Group leader cannot be added as a regular member.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
    """,
    # Trigger to prevent bookings for experience dates
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Invalid_Booking_Dates
    BEFORE INSERT OR UPDATE ON Fall24_S003_T8_Bookings
    FOR EACH ROW
    BEGIN
        -- Check if the booking date is after the experience date
        IF :NEW.Date_Of_Booking > :NEW.Experience_Date THEN
            RAISE_APPLICATION_ERROR(-20004, 'Booking date cannot be after the experience date.');
        END IF;
    END;
    """,
    # Trigger to prevent cancellations for past or completed bookings
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Invalid_Cancellations
    BEFORE UPDATE ON Fall24_S003_T8_Bookings
    FOR EACH ROW
    BEGIN
        IF :NEW.Status = 'Canceled' THEN
            IF :OLD.Experience_Date < SYSDATE OR :OLD.Status = 'Completed' THEN
                RAISE_APPLICATION_ERROR(-20007, 'Booking cannot be canceled after the experience date or once it is completed.');
            END IF;
        END IF;
    END;
    """
]

# List of DROP TRIGGER statements
drop_trigger_statements = [
    "DROP TRIGGER trg_Review_Eligibility",
    "DROP TRIGGER trg_Update_Group_Size",
    "DROP TRIGGER trg_Prevent_Leader_As_Member",
    "DROP TRIGGER trg_Prevent_Invalid_Booking_Dates",
    "DROP TRIGGER trg_Prevent_Invalid_Cancellations",
]

# List of DROP TABLES statements
drop_table_statements = [
    "DROP TABLE Fall24_S003_T8_Ratings CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Bookings CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Service_Provider_Activities CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Availability_Schedule CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Schedule_Locations CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Schedule_Times CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Service_Provider CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Experience_Tags CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Experience CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Group_Members CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Groups CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Traveler_Preferences CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Interest_Categories CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Travelers CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Locations CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Group_Types CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Tags CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Booking_Methods CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Booking_Status CASCADE CONSTRAINTS",
    "DROP TABLE Fall24_S003_T8_Payment_Status CASCADE CONSTRAINTS",
    "PURGE RECYCLEBIN"
]

create_view_statements = [
    """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_LOCATION_PREFERENCES AS SELECT 
        t.T_ID,
        t.First_Name,
        t.Last_Name,
        t.DOB,
        t.Demographic_Type,
        t.Sex,
        l.Location_Name AS Location,
        t.Email,
        t.Phone,
        p.Category_Name AS Preference_Name
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Locations l ON t.Location_ID = l.Location_ID
    JOIN 
        Fall24_S003_T8_Traveler_Preferences tp ON t.T_ID = tp.T_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories p ON tp.Preference_ID = p.Category_ID
    ORDER BY 
        t.T_ID, p.Category_Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_IN_GROUPS AS SELECT 
        t.T_ID,
        t.First_Name,
        t.Last_Name,
        t.Email,
        gm.Group_ID
    FROM 
        Fall24_S003_T8_Group_Members gm
    JOIN 
        Fall24_S003_T8_Travelers t ON gm.T_ID = t.T_ID
    ORDER BY 
        gm.Group_ID, t.T_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELER_PREFERENCES AS SELECT 
        t.T_ID,
        t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
        t.Email,
        t.Phone,
        ic.Category_Name AS Preference
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Traveler_Preferences tp ON t.T_ID = tp.T_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories ic ON tp.Preference_ID = ic.Category_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_MOST_BOOKINGS AS SELECT 
        t.T_ID,
        t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
        COUNT(b.Booking_ID) AS Total_Bookings
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name
    ORDER BY 
        Total_Bookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_GROUP_DETAILS_LEADER_MEMBER AS SELECT 
        g.Group_ID,
        g.Group_Name,
        gt.Group_Type_Name AS Group_Type,
        g.Group_Leader_T_ID AS Leader_ID,
        leader.First_Name || ' ' || leader.Last_Name AS Leader_Full_Name,
        LISTAGG(member.First_Name || ' ' || member.Last_Name, ', ') WITHIN GROUP (ORDER BY member.Last_Name) AS Member_Full_Names
    FROM 
        Fall24_S003_T8_Groups g
    JOIN 
        Fall24_S003_T8_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
    LEFT JOIN 
        Fall24_S003_T8_Group_Members gm ON g.Group_ID = gm.Group_ID
    LEFT JOIN 
        Fall24_S003_T8_Travelers member ON gm.T_ID = member.T_ID
    JOIN
        Fall24_S003_T8_Group_Types gt ON g.Group_Type_ID = gt.Group_Type_ID
    GROUP BY 
        g.Group_ID,
        g.Group_Name,
        gt.Group_Type_Name,
        g.Group_Leader_T_ID,
        leader.First_Name || ' ' || leader.Last_Name
    ORDER BY 
        g.Group_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_GROUP_BOOKINGS AS SELECT 
        t.T_ID AS TravelerID,
        t.First_Name || ' ' || t.Last_Name AS TravelerName,
        t.Email AS TravelerEmail,
        g.Group_ID,
        g.Group_Name,
        b.Booking_ID,
        e.Title AS ExperienceTitle
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Group_Members gm ON t.T_ID = gm.T_ID
    JOIN 
        Fall24_S003_T8_Groups g ON gm.Group_ID = g.Group_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    ORDER BY 
        t.T_ID, g.Group_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_GROUP_LEADERS_MEMBERS AS SELECT 
        g.Group_ID,
        g.Group_Name,
        leader.T_ID AS Leader_ID,
        leader.First_Name AS Leader_First_Name,
        leader.Last_Name AS Leader_Last_Name,
        member.T_ID AS Member_ID,
        member.First_Name AS Member_First_Name,
        member.Last_Name AS Member_Last_Name
    FROM 
        Fall24_S003_T8_Groups g
    JOIN 
        Fall24_S003_T8_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
    JOIN 
        Fall24_S003_T8_Group_Members gm ON g.Group_ID = gm.Group_ID
    JOIN 
        Fall24_S003_T8_Travelers member ON gm.T_ID = member.T_ID
    ORDER BY 
        g.Group_ID, member.T_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_FULL_DETAILS AS SELECT 
        sp.Service_Provider_ID,
        sp.Name,
        sp.Email,
        sp.Phone,
        sp.Bio,
        sp.Street,
        sp.City,
        sp.Zip,
        sp.Country,
        ic.Category_Name AS Activity_Name,
        asch.Available_Date,
        loc.Location_Name AS Schedule_Location,
        st.Start_Time,
        st.End_Time
    FROM 
        Fall24_S003_T8_Service_Provider sp
    LEFT JOIN 
        Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
    LEFT JOIN 
        Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
    LEFT JOIN 
        Fall24_S003_T8_Availability_Schedule asch ON sp.Service_Provider_ID = asch.Service_Provider_ID
    LEFT JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON asch.Schedule_ID = sl.Schedule_ID
    LEFT JOIN 
        Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
    LEFT JOIN 
        Fall24_S003_T8_Schedule_Times st ON asch.Schedule_ID = st.Schedule_ID
    ORDER BY 
        sp.Name, ic.Category_Name, asch.Available_Date, st.Start_Time
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_AVAILABILITY_BY_LOCATION_DATE AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        L.Location_Name,
        S.Available_Date,
        ST.Start_Time,
        ST.End_Time
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Availability_Schedule S ON SP.Service_Provider_ID = S.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations SL ON S.Schedule_ID = SL.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations L ON SL.Location_ID = L.Location_ID
    JOIN 
        Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_EXPERIENCES_LIST AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        E.Experience_ID,
        E.Title AS Experience_Title,
        E.Pricing,
        E.Group_Availability,
        E.Min_Group_Size,
        E.Max_Group_Size
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_MOST_BOOKED_SERVICE_PROVIDERS AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        COUNT(B.Booking_ID) AS Bookings_Count
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings B ON E.Experience_ID = B.Experience_ID
    GROUP BY 
        SP.Service_Provider_ID, SP.Name
    ORDER BY 
        Bookings_Count DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_BY_LOCATION AS SELECT 
        L.Location_Name,
        COUNT(DISTINCT SP.Service_Provider_ID) AS Number_Of_Providers
    FROM 
        Fall24_S003_T8_Locations L
    JOIN 
        Fall24_S003_T8_Schedule_Locations SL ON L.Location_ID = SL.Location_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule S ON SL.Schedule_ID = S.Schedule_ID
    JOIN 
        Fall24_S003_T8_Service_Provider SP ON S.Service_Provider_ID = SP.Service_Provider_ID
    GROUP BY 
        L.Location_Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_TOP_RATED_EXPERIENCES AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        E.Experience_ID,
        E.Title AS Experience_Title,
        AVG(R.Rating_Value) AS Average_Rating
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings R ON E.Experience_ID = R.Experience_ID
    GROUP BY 
        SP.Service_Provider_ID, SP.Name, E.Experience_ID, E.Title
    HAVING 
        AVG(R.Rating_Value) >= 8
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_BOOKINGS_OVERVIEW AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        COUNT(B.Booking_ID) AS Total_Bookings
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings B ON E.Experience_ID = B.Experience_ID
    GROUP BY 
        SP.Service_Provider_ID, SP.Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_RATINGS_FEEDBACK_OVERVIEW AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        AVG(R.Rating_Value) AS Average_Rating,
        COUNT(R.Rating_ID) AS Number_Of_Ratings
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings R ON E.Experience_ID = R.Experience_ID
    GROUP BY 
        SP.Service_Provider_ID, SP.Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_AVAILABILITY_SUMMARY AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        L.Location_Name,
        S.Available_Date,
        ST.Start_Time,
        ST.End_Time
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Availability_Schedule S ON SP.Service_Provider_ID = S.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations SL ON S.Schedule_ID = SL.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations L ON SL.Location_ID = L.Location_ID
    JOIN 
        Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_DETAILS_WITH_ACTIVITIES AS SELECT 
        SP.Service_Provider_ID,
        SP.Name AS Service_Provider_Name,
        SP.Email,
        SP.Phone,
        IC.Category_Name AS Activity
    FROM 
        Fall24_S003_T8_Service_Provider SP
    JOIN 
        Fall24_S003_T8_Service_Provider_Activities SPA ON SP.Service_Provider_ID = SPA.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories IC ON SPA.Activity_ID = IC.Category_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_DETAILS_PROVIDER_TAGS_SCHEDULE AS SELECT 
        E.Title AS Experience_Name,
        SP.Name AS Service_Provider_Name,
        T.Tag_Name AS Tag,
        S.Available_Date AS Schedule_Date,
        ST.Start_Time AS Schedule_Start_Time,
        ST.End_Time AS Schedule_End_Time
    FROM 
        Fall24_S003_T8_Experience E
    JOIN 
        Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
    JOIN 
        Fall24_S003_T8_Tags T ON ET.Tag_ID = T.Tag_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
    JOIN 
        Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
    ORDER BY 
        E.Title, T.Tag_Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_COMPLETE_DETAILS_TAGS_SCHEDULE AS SELECT 
        E.Experience_ID,
        E.Title AS Experience_Title,
        E.Description AS Experience_Description,
        E.Group_Availability,
        E.Min_Group_Size,
        E.Max_Group_Size,
        E.Pricing,
        T.Tag_Name AS Tag,
        S.Schedule_ID,
        S.Available_Date,
        ST.Start_Time,
        ST.End_Time
    FROM 
        Fall24_S003_T8_Experience E
    LEFT JOIN 
        Fall24_S003_T8_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
    LEFT JOIN 
        Fall24_S003_T8_Tags T ON ET.Tag_ID = T.Tag_ID
    LEFT JOIN 
        Fall24_S003_T8_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
    LEFT JOIN 
        Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
    ORDER BY 
        E.Experience_ID, T.Tag_Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_SUMMARY_PROVIDER_LOCATION AS SELECT 
        E.Experience_ID,
        E.Title,
        E.Description,
        E.Pricing,
        SP.Name AS Service_Provider,
        L.Location_Name AS Location
    FROM 
        Fall24_S003_T8_Experience E
    JOIN 
        Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations SL ON E.Schedule_ID = SL.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations L ON SL.Location_ID = L.Location_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_DETAILS_CONCATENATED_TAGS AS SELECT 
        E.Title AS Experience_Name,
        SP.Name AS Service_Provider_Name,
        LISTAGG(T.Tag_Name, ', ') WITHIN GROUP (ORDER BY T.Tag_Name) AS Tags,
        S.Available_Date AS Schedule_Date,
        ST.Start_Time AS Schedule_Start_Time,
        ST.End_Time AS Schedule_End_Time
    FROM 
        Fall24_S003_T8_Experience E
    JOIN 
        Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
    JOIN 
        Fall24_S003_T8_Tags T ON ET.Tag_ID = T.Tag_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
    JOIN 
        Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
    GROUP BY 
        E.Title, SP.Name, S.Available_Date, ST.Start_Time, ST.End_Time
    ORDER BY 
        E.Title
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_COUNT_BY_PRICING_RANGE AS SELECT 
        CASE 
            WHEN Pricing < 50 THEN 'Low'
            WHEN Pricing BETWEEN 50 AND 200 THEN 'Medium'
            ELSE 'High'
        END AS Price_Range,
        COUNT(e.Experience_ID) AS Number_Of_Experiences
    FROM 
        Fall24_S003_T8_Experience e
    GROUP BY 
        CASE 
            WHEN Pricing < 50 THEN 'Low'
            WHEN Pricing BETWEEN 50 AND 200 THEN 'Medium'
            ELSE 'High'
        END
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_BOOKING_DETAILS_TRAVELER_EXPERIENCE_STATUS AS SELECT 
        b.Booking_ID,
        b.Traveler_ID,
        t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
        b.Experience_ID,
        e.Title AS Experience_Title,
        TO_CHAR(b.Date_Of_Booking, 'YYYY-MM-DD HH24:MI:SS') AS Date_Of_Booking,
        TO_CHAR(b.Experience_Date, 'YYYY-MM-DD') AS Experience_Date,
        b.Amount_Paid,
        bs.Status_Name AS Booking_Status,
        ps.Payment_Status_Name AS Payment_Status,
        bm.Method_Name AS Booking_Method
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Travelers t ON b.Traveler_ID = t.T_ID
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
    JOIN 
        Fall24_S003_T8_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
    JOIN 
        Fall24_S003_T8_Booking_Methods bm ON b.Booking_Method_ID = bm.Method_ID
    ORDER BY 
        b.Date_Of_Booking DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_BOOKING_PAYMENT_STATUS_TRAVELERS AS SELECT 
        B.Booking_ID,
        T.First_Name || ' ' || T.Last_Name AS Traveler_Name,
        E.Title AS Experience_Title,
        B.Experience_Date,
        B.Amount_Paid,
        PS.Payment_Status_Name AS Payment_Status
    FROM 
        Fall24_S003_T8_Bookings B
    JOIN 
        Fall24_S003_T8_Travelers T ON B.Traveler_ID = T.T_ID
    JOIN 
        Fall24_S003_T8_Experience E ON B.Experience_ID = E.Experience_ID
    JOIN 
        Fall24_S003_T8_Payment_Status PS ON B.Payment_Status_ID = PS.Payment_Status_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_AT_LEAST_ONE_BOOKING AS SELECT 
        t.T_ID, 
        t.First_Name, 
        t.Last_Name, 
        t.Email, 
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name, t.Email
    HAVING 
        COUNT(b.Booking_ID) >= 1
    ORDER BY 
        NumberOfBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_MULTIPLE_BOOKINGS AS SELECT 
        t.T_ID, 
        t.First_Name, 
        t.Last_Name, 
        t.Email, 
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name, t.Email
    HAVING 
        COUNT(b.Booking_ID) > 1
    ORDER BY 
        NumberOfBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_NO_BOOKINGS AS SELECT 
        t.T_ID, 
        t.First_Name, 
        t.Last_Name, 
        t.Email
    FROM 
        Fall24_S003_T8_Travelers t
    LEFT JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    WHERE 
        b.Booking_ID IS NULL
    ORDER BY 
        t.T_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCES_BOOKED_BY_TRAVELER AS SELECT 
        e.Experience_ID,
        e.Title AS ExperienceTitle,
        e.Description AS ExperienceDescription,
        sp.Name AS ServiceProvider,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Experience e
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    GROUP BY 
        e.Experience_ID, e.Title, e.Description, sp.Name
    ORDER BY 
        NumberOfBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_BOOKED_EXPERIENCES_COUNT AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        NumberOfBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDERS_WITH_CANCELED_BOOKINGS AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        COUNT(b.Booking_ID) AS NumberOfCanceledBookings
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    JOIN 
        Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
    WHERE 
        bs.Status_Name = 'Cancelled'
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        NumberOfCanceledBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_CANCELED_BOOKINGS AS SELECT 
        t.T_ID AS TravelerID,
        t.First_Name || ' ' || t.Last_Name AS TravelerName,
        t.Email AS TravelerEmail,
        COUNT(b.Booking_ID) AS NumberOfCancelledBookings
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    JOIN 
        Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
    WHERE 
        bs.Status_Name = 'Cancelled'
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name, t.Email
    ORDER BY 
        NumberOfCancelledBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_BOOKED_EXPERIENCE AS SELECT 
        t.T_ID AS TravelerID,
        t.First_Name || ' ' || t.Last_Name AS TravelerName,
        t.Email AS TravelerEmail,
        b.Booking_ID,
        e.Title AS ExperienceTitle,
        sp.Name AS ServiceProvider,
        r.Rating_Value AS Rating,
        TO_CHAR(r.Review_Date_Time, 'YYYY-MM-DD HH24:MI:SS') AS ReviewDate
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    LEFT JOIN 
        Fall24_S003_T8_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
    ORDER BY 
        t.T_ID, b.Booking_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_REVIEWS AS SELECT 
        t.T_ID, 
        t.First_Name, 
        t.Last_Name, 
        t.Email, 
        COUNT(r.Rating_ID) AS NumberOfReviews
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Ratings r ON t.T_ID = r.Traveler_ID
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name, t.Email
    HAVING 
        COUNT(r.Rating_ID) >= 1
    ORDER BY 
        NumberOfReviews DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_NO_REVIEWS AS SELECT 
        t.T_ID, 
        t.First_Name, 
        t.Last_Name, 
        t.Email
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    LEFT JOIN 
        Fall24_S003_T8_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
    WHERE 
        r.Rating_ID IS NULL
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name, t.Email
    ORDER BY 
        t.T_ID
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELER_REVIEW_DETAILS AS SELECT 
        t.T_ID AS TravelerID,
        t.First_Name || ' ' || t.Last_Name AS TravelerName,
        t.Email AS TravelerEmail,
        b.Booking_ID,
        e.Title AS ExperienceTitle,
        sp.Name AS ServiceProvider,
        r.Rating_Value AS Rating,
        TO_CHAR(r.Review_Date_Time, 'YYYY-MM-DD HH24:MI:SS') AS ReviewDate
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
    ORDER BY 
        t.T_ID, b.Booking_ID
        """, """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_AVERAGE_RATING AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        AVG(r.Rating_Value) AS AverageRating
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        AverageRating DESC
        """, """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_AVERAGE_RATING AS SELECT 
        e.Experience_ID,
        e.Title AS ExperienceTitle,
        e.Description AS ExperienceDescription,
        sp.Name AS ServiceProvider,
        AVG(r.Rating_Value) AS AverageRating
    FROM 
        Fall24_S003_T8_Experience e
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        e.Experience_ID, e.Title, e.Description, sp.Name
    ORDER BY 
        AverageRating DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOP_RATED_EXPERIENCES_LIST AS SELECT 
        e.Experience_ID,
        e.Title,
        AVG(r.Rating_Value) AS Average_Rating,
        COUNT(r.Rating_ID) AS Number_Of_Ratings
    FROM 
        Fall24_S003_T8_Experience e
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        e.Experience_ID, e.Title
    HAVING 
        AVG(r.Rating_Value) >= 8
    ORDER BY 
        Average_Rating DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOTAL_EARNINGS_CONFIRMED AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        SUM(b.Amount_Paid) AS TotalEarnings
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    JOIN 
        Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
    WHERE 
        bs.Status_Name = 'Confirmed' 
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        TotalEarnings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOTAL_REFUNDED_AMOUNT AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        SUM(b.Amount_Paid) AS TotalRefundedEarnings
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    JOIN 
        Fall24_S003_T8_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
    WHERE 
        ps.Payment_Status_Name = 'Refunded'
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        TotalRefundedEarnings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_MOST_BOOKINGS AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        COUNT(b.Booking_ID) AS TotalBookings
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name
    ORDER BY 
        TotalBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_MONTHLY_BOOKING_VOLUME AS SELECT 
        TO_CHAR(Date_Of_Booking, 'YYYY-MM') AS BookingMonth,
        COUNT(Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Bookings
    GROUP BY 
        TO_CHAR(Date_Of_Booking, 'YYYY-MM')
    ORDER BY 
        BookingMonth
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOP_LOCATIONS_AVAILABLE_EXPERIENCES AS SELECT 
        l.Location_ID,
        l.Location_Name,
        COUNT(e.Experience_ID) AS NumberOfAvailableExperiences
    FROM 
        Fall24_S003_T8_Locations l
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule s ON sl.Schedule_ID = s.Schedule_ID
    JOIN 
        Fall24_S003_T8_Experience e ON s.Schedule_ID = e.Schedule_ID
    GROUP BY 
        l.Location_ID, l.Location_Name
    ORDER BY 
        NumberOfAvailableExperiences DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_AVERAGE_RATING_BY_LOCATION AS SELECT 
        l.Location_Name,
        AVG(r.Rating_Value) AS AverageRating
    FROM 
        Fall24_S003_T8_Ratings r
    JOIN 
        Fall24_S003_T8_Experience e ON r.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
    GROUP BY 
        l.Location_Name
    ORDER BY 
        AverageRating DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_GROUP_BOOKING_ANALYSIS AS SELECT 
        gt.Group_Type_Name,
        COUNT(gm.Group_ID) AS NumberOfGroupBookings
    FROM 
        Fall24_S003_T8_Group_Types gt
    JOIN 
        Fall24_S003_T8_Groups g ON gt.Group_Type_ID = g.Group_Type_ID
    JOIN 
        Fall24_S003_T8_Group_Members gm ON g.Group_ID = gm.Group_ID
    GROUP BY 
        gt.Group_Type_Name
    ORDER BY 
        NumberOfGroupBookings DESC
        """, """
    CREATE VIEW VW_Fall24_S003_T8_TRAVELER_DEMOGRAPHIC_ANALYSIS AS SELECT 
        t.Demographic_Type,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    GROUP BY 
        t.Demographic_Type
    ORDER BY 
        NumberOfBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_REFUND_RATE_ANALYSIS AS SELECT 
        (COUNT(CASE WHEN b.Payment_Status_ID = 
            (SELECT Payment_Status_ID FROM Fall24_S003_T8_Payment_Status WHERE Payment_Status_Name = 'Refunded') 
        THEN 1 END) / COUNT(*)) * 100 AS RefundRate
    FROM 
        Fall24_S003_T8_Bookings b
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_LOCATIONS_MOST_BOOKINGS AS SELECT 
        l.Location_ID,
        l.Location_Name,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Locations l
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule s ON sl.Schedule_ID = s.Schedule_ID
    JOIN 
        Fall24_S003_T8_Experience e ON s.Schedule_ID = e.Schedule_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    GROUP BY 
        l.Location_ID, l.Location_Name
    ORDER BY 
        NumberOfBookings DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_HIGHEST_LOWEST_RATED_SERVICE_PROVIDERS AS
    SELECT * FROM (
        SELECT 
            sp.Service_Provider_ID,
            sp.Name AS ServiceProviderName,
            sp.Email AS ServiceProviderEmail,
            sp.Phone AS ServiceProviderPhone,
            sp.City AS ServiceProviderCity,
            AVG(r.Rating_Value) AS AverageRating,
            'Highest' AS RatingType
        FROM 
            Fall24_S003_T8_Service_Provider sp
        JOIN 
            Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
        JOIN 
            Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
        GROUP BY 
            sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
        ORDER BY 
            AverageRating DESC
    ) WHERE ROWNUM = 1

    UNION ALL

    SELECT * FROM (
        SELECT 
            sp.Service_Provider_ID,
            sp.Name AS ServiceProviderName,
            sp.Email AS ServiceProviderEmail,
            sp.Phone AS ServiceProviderPhone,
            sp.City AS ServiceProviderCity,
            AVG(r.Rating_Value) AS AverageRating,
            'Lowest' AS RatingType
        FROM 
            Fall24_S003_T8_Service_Provider sp
        JOIN 
            Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
        JOIN 
            Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
        GROUP BY 
            sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
        ORDER BY 
            AverageRating ASC
    ) WHERE ROWNUM = 1
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOP_10_RATED_SERVICE_PROVIDERS AS
    SELECT * FROM (
        SELECT 
            sp.Service_Provider_ID,
            sp.Name AS ServiceProviderName,
            sp.Email AS ServiceProviderEmail,
            sp.Phone AS ServiceProviderPhone,
            sp.City AS ServiceProviderCity,
            AVG(r.Rating_Value) AS AverageRating,
            'Top 10 Highest' AS RatingCategory
        FROM 
            Fall24_S003_T8_Service_Provider sp
        JOIN 
            Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
        JOIN 
            Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
        GROUP BY 
            sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
        ORDER BY 
            AverageRating DESC
    ) WHERE ROWNUM <= 10

    UNION ALL

    SELECT * FROM (
        SELECT 
            sp.Service_Provider_ID,
            sp.Name AS ServiceProviderName,
            sp.Email AS ServiceProviderEmail,
            sp.Phone AS ServiceProviderPhone,
            sp.City AS ServiceProviderCity,
            AVG(r.Rating_Value) AS AverageRating,
            'Top 10 Lowest' AS RatingCategory
        FROM 
            Fall24_S003_T8_Service_Provider sp
        JOIN 
            Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
        JOIN 
            Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
        GROUP BY 
            sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
        ORDER BY 
            AverageRating ASC
    ) WHERE ROWNUM <= 10
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_MOST_BOOKED_EXPERIENCES AS SELECT 
        e.Experience_ID,
        e.Title AS ExperienceTitle,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Experience e
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    GROUP BY 
        e.Experience_ID, e.Title
    ORDER BY 
        NumberOfBookings DESC
    FETCH FIRST 5 ROWS ONLY
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOP_10_TRAVELERS_BOOKINGS AS SELECT 
        t.T_ID AS TravelerID,
        t.First_Name || ' ' || t.Last_Name AS TravelerName,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    GROUP BY 
        t.T_ID, t.First_Name, t.Last_Name
    ORDER BY 
        NumberOfBookings DESC
    FETCH FIRST 10 ROWS ONLY
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_AVERAGE_AMOUNT_PAID_BY_PAYMENT_STATUS AS SELECT 
        ps.Payment_Status_Name,
        AVG(b.Amount_Paid) AS AverageAmountPaid
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
    GROUP BY 
        ps.Payment_Status_Name
    ORDER BY 
        AverageAmountPaid DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_TOTAL_REVENUE_BY_SERVICE_PROVIDER AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS Service_Provider_Name,
        COUNT(b.Booking_ID) AS Total_Bookings,
        SUM(b.Amount_Paid) AS Total_Revenue
    FROM 
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_DAILY_BOOKING_VOLUME AS SELECT 
        TRUNC(b.Date_Of_Booking) AS Booking_Date,
        COUNT(b.Booking_ID) AS Number_Of_Bookings
    FROM 
        Fall24_S003_T8_Bookings b
    GROUP BY 
        TRUNC(b.Date_Of_Booking)
    ORDER BY 
        Booking_Date
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_GUIDE_SUPPORT_NEEDS AS SELECT 
        sp.Service_Provider_ID,
        sp.Name AS Service_Provider_Name,
        COUNT(b.Booking_ID) AS Booking_Count,
        AVG(r.Rating_Value) AS Average_Rating
    FROM 
        Fall24_S003_T8_Service_Provider sp
    LEFT JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    LEFT JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    LEFT JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name
    HAVING 
        COUNT(b.Booking_ID) < 10 OR AVG(r.Rating_Value) < 3.0
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_QUARTERLY_REVENUE_BREAKDOWN AS SELECT 
        EXTRACT(YEAR FROM b.Date_Of_Booking) AS Year,
        TO_CHAR(b.Date_Of_Booking, 'Q') AS Quarter,
        ic.Category_Name AS Experience_Category,
        loc.Location_Name AS Destination,
        sp.Name AS Service_Provider,
        SUM(b.Amount_Paid) AS Total_Revenue
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
    GROUP BY 
        EXTRACT(YEAR FROM b.Date_Of_Booking),
        TO_CHAR(b.Date_Of_Booking, 'Q'),
        ic.Category_Name,
        loc.Location_Name,
        sp.Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_MONTHLY_BOOKING_TRENDS AS SELECT 
        EXTRACT(MONTH FROM b.Date_Of_Booking) AS Month,
        ic.Category_Name AS Experience_Category,
        COUNT(b.Booking_ID) AS Booking_Count,
        t.Demographic_Type AS Traveler_Demographic
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Travelers t ON b.Traveler_ID = t.T_ID
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
    GROUP BY 
        EXTRACT(MONTH FROM b.Date_Of_Booking),
        ic.Category_Name,
        t.Demographic_Type
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_REPEAT_TRAVELERS_PREFERENCES AS SELECT 
        t.T_ID AS Traveler_ID,
        t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
        COUNT(b.Booking_ID) AS Total_Bookings,
        LISTAGG(ic.Category_Name, ', ') WITHIN GROUP (ORDER BY ic.Category_Name) AS Preferences
    FROM 
        Fall24_S003_T8_Travelers t
    JOIN 
        Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
    JOIN 
        Fall24_S003_T8_Traveler_Preferences tp ON t.T_ID = tp.T_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories ic ON tp.Preference_ID = ic.Category_ID
    GROUP BY 
        t.T_ID,
        t.First_Name,
        t.Last_Name
    HAVING 
        COUNT(b.Booking_ID) > 1
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_EXPERIENCE_DIVERSITY AS SELECT 
        ic.Category_Name AS Experience_Category,
        loc.Location_Name AS Location,
        COUNT(e.Experience_ID) AS Experience_Count
    FROM 
        Fall24_S003_T8_Experience e
    JOIN 
        Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
    JOIN 
        Fall24_S003_T8_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
    GROUP BY 
        ic.Category_Name,
        loc.Location_Name
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_MONTHLY_BOOKING_COUNT_BY_EXPERIENCE AS SELECT 
        EXTRACT(MONTH FROM b.Experience_Date) AS Month,
        COUNT(b.Booking_ID) AS Booking_Count,
        e.Title AS Experience_Title
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    GROUP BY 
        EXTRACT(MONTH FROM b.Experience_Date),
        e.Title
    ORDER BY 
        Booking_Count DESC
        """,
        """
    CREATE VIEW VW_Fall24_S003_T8_AVG_DAYS_BETWEEN_BOOKING_EXPERIENCE AS SELECT 
        AVG(TRUNC(b.Experience_Date) - TRUNC(b.Date_Of_Booking)) AS Avg_Days_Between_Booking,
        e.Title AS Experience_Title
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    GROUP BY 
        e.Title
    """,
    """
    CREATE VIEW VW_Fall24_S003_T8_LOC_WITH_MOST_BOOKINGS AS SELECT 
        l.Location_Name AS Destination,
        COUNT(b.Booking_ID) AS Total_Bookings,
        SUM(b.Amount_Paid) AS Total_Revenue
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
    GROUP BY 
        l.Location_Name
    ORDER BY 
        Total_Bookings DESC, Total_Revenue DESC
    FETCH FIRST 10 ROWS ONLY
    """,
    """
    CREATE VIEW VW_Fall24_S003_T8_TOP_5_MOST_BOOKED_EXPEREINCE AS SELECT 
        e.Experience_ID,
        e.Title AS ExperienceTitle,
        l.Location_Name,
        COUNT(b.Booking_ID) AS NumberOfBookings
    FROM 
        Fall24_S003_T8_Experience e
    JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
    GROUP BY 
        e.Experience_ID, e.Title, l.Location_Name
    ORDER BY 
        NumberOfBookings DESC
    FETCH FIRST 5 ROWS ONLY
    """
]

drop_view_statements = [
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_LOCATION_PREFERENCES",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_IN_GROUPS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELER_PREFERENCES",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_MOST_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_GROUP_DETAILS_LEADER_MEMBER",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_GROUP_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_GROUP_LEADERS_MEMBERS",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_FULL_DETAILS",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_AVAILABILITY_BY_LOCATION_DATE",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_EXPERIENCES_LIST",
    "DROP VIEW VW_Fall24_S003_T8_MOST_BOOKED_SERVICE_PROVIDERS",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_BY_LOCATION",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_TOP_RATED_EXPERIENCES",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_BOOKINGS_OVERVIEW",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_RATINGS_FEEDBACK_OVERVIEW",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_AVAILABILITY_SUMMARY",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_DETAILS_WITH_ACTIVITIES",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_DETAILS_PROVIDER_TAGS_SCHEDULE",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_COMPLETE_DETAILS_TAGS_SCHEDULE",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_SUMMARY_PROVIDER_LOCATION",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_DETAILS_CONCATENATED_TAGS",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_COUNT_BY_PRICING_RANGE",
    "DROP VIEW VW_Fall24_S003_T8_BOOKING_DETAILS_TRAVELER_EXPERIENCE_STATUS",
    "DROP VIEW VW_Fall24_S003_T8_BOOKING_PAYMENT_STATUS_TRAVELERS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_AT_LEAST_ONE_BOOKING",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_MULTIPLE_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_NO_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCES_BOOKED_BY_TRAVELER",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_BOOKED_EXPERIENCES_COUNT",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDERS_WITH_CANCELED_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_CANCELED_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_BOOKED_EXPERIENCE",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_REVIEWS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELERS_WITH_NO_REVIEWS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELER_REVIEW_DETAILS",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_AVERAGE_RATING",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_AVERAGE_RATING",
    "DROP VIEW VW_Fall24_S003_T8_TOP_RATED_EXPERIENCES_LIST",
    "DROP VIEW VW_Fall24_S003_T8_TOTAL_EARNINGS_CONFIRMED",
    "DROP VIEW VW_Fall24_S003_T8_TOTAL_REFUNDED_AMOUNT",
    "DROP VIEW VW_Fall24_S003_T8_SERVICE_PROVIDER_MOST_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_MONTHLY_BOOKING_VOLUME",
    "DROP VIEW VW_Fall24_S003_T8_TOP_LOCATIONS_AVAILABLE_EXPERIENCES",
    "DROP VIEW VW_Fall24_S003_T8_AVERAGE_RATING_BY_LOCATION",
    "DROP VIEW VW_Fall24_S003_T8_GROUP_BOOKING_ANALYSIS",
    "DROP VIEW VW_Fall24_S003_T8_TRAVELER_DEMOGRAPHIC_ANALYSIS",
    "DROP VIEW VW_Fall24_S003_T8_REFUND_RATE_ANALYSIS",
    "DROP VIEW VW_Fall24_S003_T8_LOCATIONS_MOST_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_HIGHEST_LOWEST_RATED_SERVICE_PROVIDERS",
    "DROP VIEW VW_Fall24_S003_T8_TOP_10_RATED_SERVICE_PROVIDERS",
    "DROP VIEW VW_Fall24_S003_T8_MOST_BOOKED_EXPERIENCES",
    "DROP VIEW VW_Fall24_S003_T8_TOP_10_TRAVELERS_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_AVERAGE_AMOUNT_PAID_BY_PAYMENT_STATUS",
    "DROP VIEW VW_Fall24_S003_T8_TOTAL_REVENUE_BY_SERVICE_PROVIDER",
    "DROP VIEW VW_Fall24_S003_T8_DAILY_BOOKING_VOLUME",
    "DROP VIEW VW_Fall24_S003_T8_GUIDE_SUPPORT_NEEDS",
    "DROP VIEW VW_Fall24_S003_T8_QUARTERLY_REVENUE_BREAKDOWN",
    "DROP VIEW VW_Fall24_S003_T8_MONTHLY_BOOKING_TRENDS",
    "DROP VIEW VW_Fall24_S003_T8_REPEAT_TRAVELERS_PREFERENCES",
    "DROP VIEW VW_Fall24_S003_T8_EXPERIENCE_DIVERSITY",
    "DROP VIEW VW_Fall24_S003_T8_MONTHLY_BOOKING_COUNT_BY_EXPERIENCE",
    "DROP VIEW VW_Fall24_S003_T8_AVG_DAYS_BETWEEN_BOOKING_EXPERIENCE",
    "DROP VIEW VW_Fall24_S003_T8_LOC_WITH_MOST_BOOKINGS",
    "DROP VIEW VW_Fall24_S003_T8_TOP_5_MOST_BOOKED_EXPEREINCE"
]