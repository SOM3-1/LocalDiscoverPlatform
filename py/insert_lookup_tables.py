import cx_Oracle
import logging
from mocks import preference_options, city_names, group_types, experience_tags

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

    # Step 3: Insert group types into the Dg_Group_Types table
    logger.info("Inserting group types into the Dg_Group_Types table...")
    group_types_with_ids = [(f"GT{i+1:03d}", group_type) for i, group_type in enumerate(group_types)]
    cursor.executemany("INSERT INTO Dg_Group_Types (Group_Type_ID, Group_Type_Name) VALUES (:1, :2)", group_types_with_ids)
    logger.info(f"Inserted {len(group_types_with_ids)} group types.")

    # Step 4: Insert experience tags into the Dg_Tags table
    logger.info("Inserting experience tags into the Dg_Tags table...")
    tags_data = [(f"T{i+1:03d}", tag) for i, tag in enumerate(experience_tags)]
    cursor.executemany("INSERT INTO Dg_Tags (Tag_ID, Tag_Name) VALUES (:1, :2)", tags_data)
    logger.info(f"Inserted {len(tags_data)} experience tags into the Dg_Tags table.")

    # Step 5: Commit the changes
    connection.commit()
    logger.info("All data inserted successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
    if connection:
        connection.rollback()
finally:
    # Clean up by closing the cursor and connection
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
