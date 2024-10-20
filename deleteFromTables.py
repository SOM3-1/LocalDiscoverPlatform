import cx_Oracle
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

username = 'dxg6620'
password = '
dsn = 'localhost:1523/pcse1p.data.uta.edu'

sql_statements = [
    "DROP VIEW Vw_Travelers",

    "DELETE FROM Dg_Ratings",
    "DELETE FROM Dg_Bookings",
    "DELETE FROM Dg_Experience_Tags",
    "DELETE FROM Dg_Group_Members",
    "DELETE FROM Dg_Groups",
    "DELETE FROM Dg_Traveler_Preferences",
    "DELETE FROM Dg_Experience",
    "DELETE FROM Dg_Service_Provider",
    "DELETE FROM Dg_Travelers",

    "DROP TABLE Dg_Ratings",
    "DROP TABLE Dg_Bookings",
    "DROP TABLE Dg_Experience_Tags",
    "DROP TABLE Dg_Group_Members",
    "DROP TABLE Dg_Groups",
    "DROP TABLE Dg_Traveler_Preferences",
    "DROP TABLE Dg_Experience",
    "DROP TABLE Dg_Service_Provider",
    "DROP TABLE Dg_Travelers"
]

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    for sql in sql_statements:
        try:
            logger.info(f"Executing: {sql}")
            cursor.execute(sql)
            logger.info("Executed successfully.")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"An error occurred while executing '{sql}': {e}")

    connection.commit()
    logger.info("All deletions and drops committed successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
