import cx_Oracle
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Database connection configuration
username = ""
password = ""
dsn = "localhost:1523/pcse1p.data.uta.edu"

# Updated list of CREATE TABLE statements
create_table_statements = [
    """
    CREATE TABLE Dg_Travelers (
        T_ID VARCHAR2(20) PRIMARY KEY,
        First_Name VARCHAR2(50) NOT NULL,
        Last_Name VARCHAR2(50) NOT NULL,
        DOB DATE NOT NULL,
        Demographic_Type VARCHAR2(50),
        Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')),
        Location VARCHAR2(100),
        Email VARCHAR2(50) UNIQUE NOT NULL,
        Phone VARCHAR2(15) UNIQUE NOT NULL
    )
    """,
    """
    CREATE TABLE Dg_Preferences (
        Preference_ID VARCHAR2(20) PRIMARY KEY,
        Preference_Name VARCHAR2(100) NOT NULL UNIQUE
    )
    """,
    """
   CREATE TABLE Dg_Traveler_Preferences (
    T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Preference_ID VARCHAR2(20) REFERENCES Dg_Preferences(Preference_ID),
    PRIMARY KEY (T_ID, Preference_ID)
    )
    """,
    """
    CREATE TABLE Dg_Groups (
        Group_ID VARCHAR2(20) PRIMARY KEY,
        Group_Name VARCHAR2(100),
        Group_Leader_T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Group_Type VARCHAR2(50),
        Group_Size NUMBER DEFAULT 0
    )
    """,
    """
    CREATE TABLE Dg_Group_Members (
        Group_ID VARCHAR2(20) REFERENCES Dg_Groups(Group_ID),
        T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        PRIMARY KEY (Group_ID, T_ID)
    )
    """,
    """
    CREATE TABLE Dg_Service_Provider (
        Service_Provider_ID VARCHAR2(20) PRIMARY KEY,
        Name VARCHAR2(100) NOT NULL,
        Email VARCHAR2(50) UNIQUE NOT NULL,
        Phone VARCHAR2(15) UNIQUE NOT NULL,
        Bio VARCHAR2(500),
        Street VARCHAR2(100),
        City VARCHAR2(50),
        Zip VARCHAR2(10),
        Country VARCHAR2(100)
    )
    """,
    """
    CREATE TABLE Dg_Experience (
        Experience_ID VARCHAR2(20) PRIMARY KEY,
        Title VARCHAR2(100) NOT NULL,
        Description VARCHAR2(500),
        Group_Availability VARCHAR2(50),
        Group_Size_Limits VARCHAR2(50),
        Pricing NUMBER CHECK (Pricing >= 0),
        Location VARCHAR2(100),
        Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
        Schedule_Date DATE,
        Schedule_Time VARCHAR2(10)
    )
    """,
    """
    CREATE TABLE Dg_Experience_Tags (
        Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
        Tag VARCHAR2(50),
        PRIMARY KEY (Experience_ID, Tag)
    )
    """,
    """
    CREATE TABLE Dg_Bookings (
        Booking_ID VARCHAR2(20) PRIMARY KEY,
        Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
        Date_Of_Booking DATE NOT NULL,
        Experience_Date DATE NOT NULL,
        Amount_Paid NUMBER NOT NULL CHECK (Amount_Paid >= 0),
        Status VARCHAR2(20),
        Booking_Method VARCHAR2(50),
        Payment_Status VARCHAR2(20) DEFAULT 'Pending' -- Set default payment status to 'Pending'
    )
    """,
    """
    CREATE TABLE Dg_Ratings (
        Rating_ID VARCHAR2(20) PRIMARY KEY,
        Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
        Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
        Rating_Value NUMBER CHECK (Rating_Value BETWEEN 1 AND 10),
        Review_Date_Time TIMESTAMP DEFAULT SYSDATE, -- Set default review date to the current date
        Feedback VARCHAR2(500),
        Review_Title VARCHAR2(100)
    )
    """,
]

# Create view statement
create_view_statement = """
CREATE OR REPLACE VIEW Vw_Travelers AS
SELECT T_ID, 
       First_Name, 
       Last_Name, 
       DOB,
       FLOOR(MONTHS_BETWEEN(SYSDATE, DOB) / 12) AS Age,
       Demographic_Type, 
       Sex, 
       Location, 
       Email, 
       Phone
FROM Dg_Travelers
"""

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

    # Execute the CREATE VIEW statement
    try:
        logger.info(f"Executing: {create_view_statement.splitlines()[1].strip()}")
        cursor.execute(create_view_statement)
        logger.info("View created successfully.")
    except cx_Oracle.DatabaseError as e:
        logger.error(f"An error occurred while creating the view: {e}")

    # Commit the changes
    connection.commit()
    logger.info("All tables and view created successfully.")

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
