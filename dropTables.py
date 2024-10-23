import cx_Oracle
import logging

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

username = 'dxg6620'
password = 'Dushyanth123'
dsn = "localhost:1523/pcse1p.data.uta.edu"

drop_view_statements = [
    "DROP VIEW Vw_Travelers"
]

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
]

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Drop views
    for drop_view_sql in drop_view_statements:
        try:
            logger.info(f"Executing: {drop_view_sql}")
            cursor.execute(drop_view_sql)
            logger.info("View dropped successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.warning(f"View does not exist or could not be dropped: {e}")

    # Drop tables
    for drop_table_sql in drop_table_statements:
        try:
            logger.info(f"Executing: {drop_table_sql}")
            cursor.execute(drop_table_sql)
            logger.info("Table dropped successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.warning(f"Table does not exist or could not be dropped: {e}")

    connection.commit()
    logger.info("All tables and views dropped successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
