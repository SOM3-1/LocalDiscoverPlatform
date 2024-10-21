import cx_Oracle
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

username = ''
password = ''
dsn = 'localhost:1523/pcse1p.data.uta.edu'

drop_table_statements = [
    "DROP TRIGGER trg_Check_Review_Eligibility",
    "DROP TRIGGER trg_Update_Group_Size",
    "DROP TRIGGER trg_Prevent_Leader_As_Member",
    "DROP TRIGGER trg_Prevent_Duplicate_Preferences",
    "DROP TRIGGER trg_Prevent_Past_Bookings",
    "DROP TRIGGER trg_Default_Payment_Status",
    "DROP TRIGGER trg_Prevent_Duplicate_Ratings",
    "DROP TRIGGER trg_Prevent_Invalid_Cancellations",
    "DROP TRIGGER trg_Set_Review_Date_Time",
    "DROP TRIGGER trg_Check_Guide_Availability",
    "DROP TRIGGER trg_Prevent_Modifications_To_Past_Bookings",
    "DROP TRIGGER trg_Auto_Complete_Booking",
    "DROP TRIGGER trg_Prevent_Rating_For_Canceled",
    "DROP TRIGGER trg_Restrict_Booking_Modifications",
    "DROP VIEW Vw_Travelers",
    "DROP TABLE Dg_Ratings CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Bookings CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Experience_Tags CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Experience CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Service_Provider CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Group_Members CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Groups CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Traveler_Preferences CASCADE CONSTRAINTS",
    "DROP TABLE Dg_Travelers CASCADE CONSTRAINTS",
]

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

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
