import cx_Oracle
import logging
import sys
from credentials import netid, pwd, connection
from tables import drop_trigger_statements, drop_table_statements, drop_view_statements

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)] 
)
logger = logging.getLogger(__name__)

# Database connection configuration
username = netid
password = pwd
dsn = connection

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

# Execute each DROP VIEWS statement
    for drop_view_sql in drop_view_statements:
        try:
            logger.info(f"Executing: {drop_view_sql}")
            cursor.execute(drop_view_sql)
            logger.info("View dropped successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while dropping the views: {e}")
            # Continue to the next view even if one fails\

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
            # Continue to the next table even if one fails

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
