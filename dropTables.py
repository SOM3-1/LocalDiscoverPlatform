import cx_Oracle
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

username = ''
password = ''
dsn = 'localhost:1523/pcse1p.data.uta.edu'

drop_table_statements = [
    "DROP VIEW Vw_Travelers",
    "DROP TABLE Dg_Ratings CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Bookings CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Experience_Tags CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Experience CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Service_Provider CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Group_Members CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Groups CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Traveler_Preferences CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Travelers CASCADE CONSTRAINTS"
]

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Execute each DROP TABLE statement
    for drop_table_sql in drop_table_statements:
        try:
            logger.info(f"Executing: {drop_table_sql}")
            cursor.execute(drop_table_sql)
            logger.info("Table dropped successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while dropping the table: {e}")

    connection.commit()
    logger.info("All tables dropped successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
