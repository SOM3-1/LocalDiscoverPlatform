import cx_Oracle
import logging
import sys
from mocks import preference_options, city_names, group_types, experience_tags, payment_statuses, booking_statuses, booking_methods
from credentials import netid, pwd, connection

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

    # Open a file to write the insert statements
    with open("lookup_tables_insert_statement.txt", "w") as file:
        # Step 1: Insert locations into the Fall24_S003_T8_Locations table
        logger.info("Writing locations insert statements...")
        location_data = [(f"L{i+1:05d}", city) for i, city in enumerate(city_names)]
        file.write("INSERT ALL\n")
        for loc_id, city in location_data:
            file.write(f"INTO Fall24_S003_T8_Locations (Location_ID, Location_Name) VALUES ('{loc_id}', '{city}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Locations (Location_ID, Location_Name) VALUES (:1, :2)", location_data)
        logger.info(f"Inserted {len(location_data)} locations.")

        # Step 2: Insert preferences into the Fall24_S003_T8_Interest_Categories table
        logger.info("Writing preferences insert statements...")
        preference_data = [(f"C{i+1:05d}", preference) for i, preference in enumerate(preference_options)]
        file.write("INSERT ALL\n")
        for cat_id, preference in preference_data:
            file.write(f"INTO Fall24_S003_T8_Interest_Categories (Category_ID, Category_Name) VALUES ('{cat_id}', '{preference}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Interest_Categories (Category_ID, Category_Name) VALUES (:1, :2)", preference_data)
        logger.info(f"Inserted {len(preference_data)} preferences.")

        # Step 3: Insert group types into the Fall24_S003_T8_Group_Types table
        logger.info("Writing group types insert statements...")
        group_types_with_ids = [(f"GT{i+1:03d}", group_type) for i, group_type in enumerate(group_types)]
        file.write("INSERT ALL\n")
        for gt_id, group_type in group_types_with_ids:
            file.write(f"INTO Fall24_S003_T8_Group_Types (Group_Type_ID, Group_Type_Name) VALUES ('{gt_id}', '{group_type}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Group_Types (Group_Type_ID, Group_Type_Name) VALUES (:1, :2)", group_types_with_ids)
        logger.info(f"Inserted {len(group_types_with_ids)} group types.")

        # Step 4: Insert experience tags into the Fall24_S003_T8_Tags table
        logger.info("Writing experience tags insert statements...")
        tags_data = [(f"T{i+1:03d}", tag) for i, tag in enumerate(experience_tags)]
        file.write("INSERT ALL\n")
        for tag_id, tag in tags_data:
            file.write(f"INTO Fall24_S003_T8_Tags (Tag_ID, Tag_Name) VALUES ('{tag_id}', '{tag}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Tags (Tag_ID, Tag_Name) VALUES (:1, :2)", tags_data)
        logger.info(f"Inserted {len(tags_data)} experience tags.")

        # Step 5: Insert booking methods into the Fall24_S003_T8_Booking_Methods table
        logger.info("Writing booking methods insert statements...")
        booking_methods_data = [(f"BM{i+1:03d}", method) for i, method in enumerate(booking_methods)]
        file.write("INSERT ALL\n")
        for bm_id, method in booking_methods_data:
            file.write(f"INTO Fall24_S003_T8_Booking_Methods (Method_ID, Method_Name) VALUES ('{bm_id}', '{method}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Booking_Methods (Method_ID, Method_Name) VALUES (:1, :2)", booking_methods_data)
        logger.info(f"Inserted {len(booking_methods_data)} booking methods.")

        # Step 6: Insert booking statuses into the Fall24_S003_T8_Booking_Status table
        logger.info("Writing booking statuses insert statements...")
        booking_statuses_data = [(f"BS{i+1:03d}", status) for i, status in enumerate(booking_statuses)]
        file.write("INSERT ALL\n")
        for bs_id, status in booking_statuses_data:
            file.write(f"INTO Fall24_S003_T8_Booking_Status (Status_ID, Status_Name) VALUES ('{bs_id}', '{status}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Booking_Status (Status_ID, Status_Name) VALUES (:1, :2)", booking_statuses_data)
        logger.info(f"Inserted {len(booking_statuses_data)} booking statuses.")

        # Step 7: Insert payment statuses into the Fall24_S003_T8_Payment_Status table
        logger.info("Writing payment statuses insert statements...")
        payment_statuses_data = [(f"PS{i+1:03d}", status) for i, status in enumerate(payment_statuses)]
        file.write("INSERT ALL\n")
        for ps_id, status in payment_statuses_data:
            file.write(f"INTO Fall24_S003_T8_Payment_Status (Payment_Status_ID, Payment_Status_Name) VALUES ('{ps_id}', '{status}')\n")
        file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
        cursor.executemany("INSERT INTO Fall24_S003_T8_Payment_Status (Payment_Status_ID, Payment_Status_Name) VALUES (:1, :2)", payment_statuses_data)
        logger.info(f"Inserted {len(payment_statuses_data)} payment statuses.")

    # Step 8: Commit the changes
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
