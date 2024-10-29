import cx_Oracle
import logging
from credentials import netid, pwd, connection

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Database connection configuration
username = netid
password = pwd
dsn = connection

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
    "DROP TABLE Dg_Ratings CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Bookings CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Service_Provider_Activities CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Availability_Schedule CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Schedule_Locations CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Schedule_Times CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Service_Provider CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Experience_Tags CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Experience CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Group_Members CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Groups CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Traveler_Preferences CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Interest_Categories CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Travelers CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Locations CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Group_Types CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Tags CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Booking_Methods CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Booking_Status CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Payment_Status CASCADE CONSTRAINTS",
    "PURGE RECYCLEBIN"
]


try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Execute each DROP TRIGGER statement
    for drop_trigger_sql in drop_trigger_statements:
        try:
            logger.info(f"Executing: {drop_trigger_sql}")
            cursor.execute(drop_trigger_sql)
            logger.info("Trigger dropped successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while dropping the trigger: {e}")
            # Continue to the next trigger even if one fails

     # Drop tables
    for drop_table_sql in drop_table_statements:
        try:
            logger.info(f"Executing: {drop_table_sql}")
            cursor.execute(drop_table_sql)
            logger.info("Table dropped successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.warning(f"Table does not exist or could not be dropped: {e}")

    # Commit the changes
    connection.commit()
    logger.info("All triggers and tables dropped successfully.")

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
