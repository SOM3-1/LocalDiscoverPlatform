import cx_Oracle
import logging
from credentials import netid, pwd, connection

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

username = netid
password = pwd
dsn = connection

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
    # Trigger to prevent bookings for experience dates
    """
    CREATE OR REPLACE TRIGGER trg_Prevent_Invalid_Booking_Dates
    BEFORE INSERT OR UPDATE ON Dg_Bookings
    FOR EACH ROW
    BEGIN
        -- Check if the booking date is after the experience date
        IF :NEW.Date_Of_Booking > :NEW.Experience_Date THEN
            RAISE_APPLICATION_ERROR(-20004, 'Booking date cannot be after the experience date.');
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
    # Trigger to validate that reviews can only be submitted for confirmed bookings
    """
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
    """
]

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    for create_trigger_sql in create_trigger_statements:
        try:
            logger.info(f"Executing: {create_trigger_sql.splitlines()[1].strip()}")
            cursor.execute(create_trigger_sql)
            logger.info("Trigger created successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while creating the trigger: {e}")

    connection.commit()
    logger.info("All triggers created successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
