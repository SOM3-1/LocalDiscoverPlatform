import cx_Oracle
import logging
import sys
from credentials import netid, pwd, connection
from tables import create_table_statements, create_trigger_statements, create_view_statements

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

    # Execute each CREATE TABLE statement
    for create_table_sql in create_table_statements:
        try:
            logger.info(f"Executing: {create_table_sql.splitlines()[1].strip()}")
            cursor.execute(create_table_sql)
            logger.info("Table created successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while creating the table: {e}")

    # Execute each CREATE VIEW statement
    # for create_view_sql in create_view_statements:
    #     try:
    #         logger.info(f"Executing: {create_view_sql.splitlines()[1].strip()}")
    #         cursor.execute(create_view_sql)
    #         logger.info("View created successfully.")
    #     except cx_Oracle.DatabaseError as e:
    #         logger.error(f"An error occurred while creating the view: {e}")

    # Execute each CREATE TRIGGER statement
    for create_trigger_sql in create_trigger_statements:
        try:
            logger.info(f"Executing: {create_trigger_sql.splitlines()[1].strip()}")
            cursor.execute(create_trigger_sql)
            logger.info("Trigger created successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while creating the trigger: {e}")

    # Commit the changes
    connection.commit()
    logger.info("All tables and triggers created successfully.")

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
