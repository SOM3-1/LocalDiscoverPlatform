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
    "DROP TRIGGER trg_Check_Review_Eligibility",
    "DROP TRIGGER trg_Update_Group_Size",
    "DROP TRIGGER trg_Prevent_Leader_As_Member",
    "DROP TRIGGER trg_Prevent_Invalid_Booking_Dates",
    "DROP TRIGGER trg_Prevent_Duplicate_Ratings",
    "DROP TRIGGER trg_Prevent_Invalid_Cancellations",
    "DROP TRIGGER trg_Prevent_Rating_For_Canceled",
    "DROP TRIGGER trg_Validate_Review_Status",
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

    # Commit the changes
    connection.commit()
    logger.info("All triggers dropped successfully.")

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
