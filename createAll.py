import cx_Oracle
import logging

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

username = ''
password = ''
dsn = "localhost:1523/pcse1p.data.uta.edu"

create_table_statements = [
    """
    CREATE TABLE Dg_Travelers (
        T_ID VARCHAR2(20) PRIMARY KEY,
        First_Name VARCHAR2(50) NOT NULL,
        Last_Name VARCHAR2(50) NOT NULL,
        DOB DATE NOT NULL,
        Demographic_Type VARCHAR2(50),
        Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')),
        Location VARCHAR2(100),
        Email VARCHAR2(50) UNIQUE NOT NULL,
        Phone VARCHAR2(15) UNIQUE NOT NULL
    )
    """,
    """
    CREATE TABLE Dg_Traveler_Preferences (
        T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Preference VARCHAR2(100),
        PRIMARY KEY (T_ID, Preference)
    )
    """,
    """
    CREATE TABLE Dg_Groups (
        Group_ID VARCHAR2(20) PRIMARY KEY,
        Group_Name VARCHAR2(100),
        Group_Leader_T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Group_Type VARCHAR2(50),
        Group_Size NUMBER DEFAULT 0
    )
    """,
    """
    CREATE TABLE Dg_Group_Members (
        Group_ID VARCHAR2(20) REFERENCES Dg_Groups(Group_ID),
        T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        PRIMARY KEY (Group_ID, T_ID)
    )
    """,
    """
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
    )
    """,
    """
    CREATE TABLE Dg_Experience (
        Experience_ID VARCHAR2(20) PRIMARY KEY,
        Title VARCHAR2(100) NOT NULL,
        Description VARCHAR2(500),
        Group_Availability VARCHAR2(50),
        Group_Size_Limits VARCHAR2(50),
        Pricing NUMBER CHECK (Pricing >= 0),
        Location VARCHAR2(100),
        Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
        Schedule_Date DATE,
        Schedule_Time VARCHAR2(10)
    )
    """,
    """
    CREATE TABLE Dg_Experience_Tags (
        Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
        Tag VARCHAR2(50),
        PRIMARY KEY (Experience_ID, Tag)
    )
    """,
    """
    CREATE TABLE Dg_Bookings (
        Booking_ID VARCHAR2(20) PRIMARY KEY,
        Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
        Date_Of_Booking DATE NOT NULL,
        Experience_Date DATE NOT NULL,
        Amount_Paid NUMBER NOT NULL CHECK (Amount_Paid >= 0),
        Status VARCHAR2(20),
        Booking_Method VARCHAR2(50),
        Payment_Status VARCHAR2(20) DEFAULT 'Pending' -- Set default payment status to 'Pending'
    )
    """,
    """
    CREATE TABLE Dg_Ratings (
        Rating_ID VARCHAR2(20) PRIMARY KEY,
        Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
        Rating_Value NUMBER CHECK (Rating_Value BETWEEN 1 AND 10),
        Review_Date_Time TIMESTAMP DEFAULT SYSDATE, -- Set default review date to the current date
        Feedback VARCHAR2(500),
        Review_Title VARCHAR2(100)
    )
    """,
]

# Create view statement
create_view_statement = """
CREATE OR REPLACE VIEW Vw_Travelers AS
SELECT T_ID, 
       First_Name, 
       Last_Name, 
       DOB,
       FLOOR(MONTHS_BETWEEN(SYSDATE, DOB) / 12) AS Age,
       Demographic_Type, 
       Sex, 
       Location, 
       Email, 
       Phone
FROM Dg_Travelers
"""

create_trigger_statements = [
    """
    CREATE OR REPLACE TRIGGER trg_Check_Review_Eligibility
    BEFORE INSERT ON Dg_Ratings
    FOR EACH ROW
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM Dg_Bookings
        WHERE Traveler_ID = :NEW.Traveler_ID
          AND Experience_ID = :NEW.Experience_ID
          AND Status = 'Completed';
        
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Review can only be submitted for completed bookings');
        END IF;
    END;
    """,
    # Compound Trigger to update Group_Size after adding or removing a member
    """
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
    """,
    # Trigger to prevent the group leader from being added as a member
    """
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
    """,
    # Compound trigger to prevent duplicate preferences
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Duplicate_Preferences
    FOR INSERT ON Dg_Traveler_Preferences
    COMPOUND TRIGGER
        TYPE PrefSet IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(200);
        preference_map PrefSet;

    BEFORE STATEMENT IS
    BEGIN
        preference_map := PrefSet();
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
        v_key VARCHAR2(200);
    BEGIN
        v_key := :NEW.T_ID || '|' || :NEW.Preference;

        IF preference_map.EXISTS(v_key) THEN
            RAISE_APPLICATION_ERROR(-20003, 'Duplicate preference for the traveler is not allowed.');
        ELSE
            preference_map(v_key) := :NEW.Preference;
        END IF;
    END BEFORE EACH ROW;
    END trg_Prevent_Duplicate_Preferences;
    """,
    # Trigger to prevent bookings for past dates
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Past_Bookings
    BEFORE INSERT OR UPDATE ON Dg_Bookings
    FOR EACH ROW
    BEGIN
        IF :NEW.Experience_Date < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20004, 'Bookings cannot be made for past dates.');
        END IF;
    END;
    """,
    # Trigger to auto-set payment status to 'Pending'
    """
    CREATE OR REPLACE TRIGGER trg_Default_Payment_Status
    BEFORE INSERT ON Dg_Bookings
    FOR EACH ROW
    BEGIN
        IF :NEW.Payment_Status IS NULL THEN
            :NEW.Payment_Status := 'Pending';
        END IF;
    END;
    """,
    # Trigger to prevent duplicate ratings
    """
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
    """,
    # Trigger to prevent cancellations for past or completed bookings
    """
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
    """,
    # Trigger to auto-set the review date to the current date
    """
    CREATE OR REPLACE TRIGGER trg_Set_Review_Date_Time
    BEFORE INSERT ON Dg_Ratings
    FOR EACH ROW
    BEGIN
        :NEW.Review_Date_Time := SYSDATE;
    END;
    """,
    # Trigger to prevent modifications to past bookings
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Modifications_To_Past_Bookings
    BEFORE UPDATE OR DELETE ON Dg_Bookings
    FOR EACH ROW
    BEGIN
        IF :OLD.Experience_Date < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20018, 'Modifications to past bookings are not allowed.');
        END IF;
    END;
    """,
    # Trigger to check group availability
    """
    CREATE OR REPLACE TRIGGER trg_Check_Guide_Availability
    BEFORE INSERT ON Dg_Bookings
    FOR EACH ROW
    DECLARE
        v_available_count NUMBER;
    BEGIN
        -- Check if the guide is available on the selected date for the experience
        SELECT COUNT(*) INTO v_available_count
        FROM Dg_Experience e
        JOIN Dg_Service_Provider s ON e.Service_Provider_ID = s.Service_Provider_ID
        WHERE e.Experience_ID = :NEW.Experience_ID
        AND e.Schedule_Date = :NEW.Experience_Date;

        -- If no guide is available, raise an error
        IF v_available_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20009, 'The guide is not available on the selected date.');
        END IF;
    END;
""",
    # Trigger to restrict booking modifications within 48 hours of the experience date
    """
CREATE OR REPLACE TRIGGER trg_Restrict_Booking_Modifications
BEFORE UPDATE OR DELETE ON Dg_Bookings
FOR EACH ROW
BEGIN
    IF :OLD.Experience_Date - SYSDATE <= 2 THEN
        RAISE_APPLICATION_ERROR(-20016, 'Bookings cannot be modified within 48 hours of the scheduled date.');
    END IF;
END;
""",
    # Trigger to prevent ratings for canceled bookings
    """
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
""",
    # Trigger to automatically mark booking as 'Completed' after the experience date
    """
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
""",
]


try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Execute each CREATE TABLE statement
    for create_table_sql in create_table_statements:
        try:
            logger.info(f"Executing: {create_table_sql.splitlines()[1].strip()}")
            cursor.execute(create_table_sql)
            logger.info("Table created successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while creating the table: {e}")

    # Execute the CREATE VIEW statement
    try:
        logger.info(f"Executing: {create_view_statement.splitlines()[1].strip()}")
        cursor.execute(create_view_statement)
        logger.info("View created successfully.")
    except cx_Oracle.DatabaseError as e:
        logger.error(f"An error occurred while creating the view: {e}")

    for create_trigger_sql in create_trigger_statements:
        try:
            logger.info(f"Executing: {create_trigger_sql.splitlines()[1].strip()}")
            cursor.execute(create_trigger_sql)
            logger.info("Trigger created successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while creating the trigger: {e}")

    logger.info("All triggers created successfully.")

    connection.commit()
    logger.info("All tables and view created successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
