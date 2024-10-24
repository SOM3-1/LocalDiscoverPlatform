import cx_Oracle
import logging
from credentials import netid, pwd, connection

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Database connection configuration
username = netid
password = pwd
dsn = connection

# List of view names to drop
view_names = [
    "Vw_Travelers_Location",
    "Vw_Traveler_Preferences",
    "Vw_Groups_With_Types",
    "Vw_Group_Leaders_And_Members",
    "Vw_Service_Provider_Activities",
    "Vw_Availability_Locations",
    "Vw_Schedule_Times",
    "Vw_Service_Providers_Schedule",
    "Vw_Travelers_In_Groups",
    "Vw_Group_Members_Count",
    "Vw_Service_Providers_Activities_Count",
    "Vw_Traveler_Age_Groups"
]

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Drop each view
    for view in view_names:
        try:
            cursor.execute(f"DROP VIEW {view}")
            logger.info(f"Dropped view: {view}")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"Failed to drop view {view}: {e}")

    # Commit the changes
    connection.commit()
    logger.info("All views dropped successfully.")

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
