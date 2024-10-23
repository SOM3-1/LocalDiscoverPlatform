import cx_Oracle
import logging
from mocks import preference_options, city_names

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Database connection configuration
username = ''
password = ''
dsn = "localhost:1523/pcse1p.data.uta.edu"

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Insert locations into the Dg_Locations table
    logger.info("Inserting locations into the Dg_Locations table...")
    location_data = [(f"L{i+1:05d}", city) for i, city in enumerate(city_names)]
    cursor.executemany("INSERT INTO Dg_Locations (Location_ID, Location_Name) VALUES (:1, :2)", location_data)
    logger.info(f"Inserted {len(location_data)} locations.")

    # Step 2: Insert preferences into the Dg_Interest_Categories table
    logger.info("Inserting preferences into the Dg_Interest_Categories table...")
    preference_data = [(f"C{i+1:05d}", preference) for i, preference in enumerate(preference_options)]
    cursor.executemany("INSERT INTO Dg_Interest_Categories (Category_ID, Category_Name) VALUES (:1, :2)", preference_data)
    logger.info(f"Inserted {len(preference_data)} preferences.")

    # Step 3: Commit the changes
    connection.commit()
    logger.info("All data inserted successfully.")

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
