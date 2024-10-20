import cx_Oracle
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

username = ''
password = ''
dsn = 'localhost:1523/pcse1p.data.uta.edu'

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
    
    # Combined Trigger to update Group_Size after adding or removing a member
    """
    CREATE OR REPLACE TRIGGER trg_Update_Group_Size
    AFTER INSERT OR DELETE ON Dg_Group_Members
    FOR EACH ROW
    BEGIN
        DECLARE
            v_group_id VARCHAR2(20);
        BEGIN
            v_group_id := CASE
                            WHEN INSERTING THEN :NEW.Group_ID
                            WHEN DELETING THEN :OLD.Group_ID
                          END;

            UPDATE Dg_Groups
            SET Group_Size = (SELECT COUNT(*) FROM Dg_Group_Members WHERE Group_ID = v_group_id)
            WHERE Group_ID = v_group_id;
        END;
    END;
    """,
    
    # Trigger to prevent group leader from being added as a member
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Leader_As_Member
    BEFORE INSERT ON Dg_Group_Members
    FOR EACH ROW
    BEGIN
        IF :NEW.T_ID = (SELECT Group_Leader_T_ID FROM Dg_Groups WHERE Group_ID = :NEW.Group_ID) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Group leader cannot be added as a regular member.');
        END IF;
    END;
    """,
    
    # Trigger to prevent duplicate preferences
    """
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
    
    # Trigger to prevent cancellation if the experience date has passed
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
    
    # Trigger to ensure guide availability for the booking date
    """
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
    """
]

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Execute each CREATE TRIGGER statement
    for create_trigger_sql in create_trigger_statements:
        try:
            logger.info(f"Executing: {create_trigger_sql.splitlines()[1].strip()}")
            cursor.execute(create_trigger_sql)
            logger.info("Trigger created successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while creating the trigger: {e}")
            # Continue to the next trigger even if one fails

    # Commit the changes
    connection.commit()
    logger.info("All triggers created successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    # Clean up by closing the cursor and connection
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
