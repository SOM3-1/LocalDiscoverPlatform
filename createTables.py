import cx_Oracle
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Database connection configuration
username = 'dxg6620'
password = 'Dushyanth123'
dsn = "localhost:1523/pcse1p.data.uta.edu"

# Updated list of CREATE TABLE statements
create_table_statements = [
    """
    CREATE TABLE Dg_Interest_Categories (
        Category_ID VARCHAR2(20) PRIMARY KEY,
        Category_Name VARCHAR2(100) NOT NULL UNIQUE
    )
    """,
    """
    CREATE TABLE Dg_Locations (
        Location_ID VARCHAR2(20) PRIMARY KEY,
        Location_Name VARCHAR2(100) NOT NULL UNIQUE
    )
    """,
    """
    CREATE TABLE Dg_Travelers (
        T_ID VARCHAR2(20) PRIMARY KEY,
        First_Name VARCHAR2(50) NOT NULL,
        Last_Name VARCHAR2(50) NOT NULL,
        DOB DATE NOT NULL,
        Demographic_Type VARCHAR2(50),
        Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')),
        Location_ID VARCHAR2(20) REFERENCES Dg_Locations(Location_ID),
        Email VARCHAR2(50) UNIQUE NOT NULL,
        Phone VARCHAR2(15) UNIQUE NOT NULL
    )
    """,
    """
   CREATE TABLE Dg_Traveler_Preferences (
    T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Preference_ID VARCHAR2(20) REFERENCES Dg_Interest_Categories(Category_ID),
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
    CREATE TABLE Dg_Service_Provider_Activities (
        Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
        Activity_ID VARCHAR2(20) REFERENCES Dg_Interest_Categories(Category_ID),
        PRIMARY KEY (Service_Provider_ID, Activity_ID)
    )""",

    """
    CREATE TABLE Dg_Availability_Schedule (
        Schedule_ID VARCHAR2(20) PRIMARY KEY,
        Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
        Available_Date DATE NOT NULL
    )""",

    """
    CREATE TABLE Dg_Schedule_Locations (
        Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
        Location_ID VARCHAR2(20) REFERENCES Dg_Locations(Location_ID),
        PRIMARY KEY (Schedule_ID, Location_ID)
    )""",

    """
    CREATE TABLE Dg_Schedule_Times (
        Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
        Start_Time TIMESTAMP NOT NULL,
        End_Time TIMESTAMP NOT NULL,
        PRIMARY KEY (Schedule_ID, Start_Time),
        CHECK (End_Time > Start_Time)
    )

    """,
    """
    CREATE TABLE Dg_Experience (
        Experience_ID VARCHAR2(20) PRIMARY KEY,
        Title VARCHAR2(100) NOT NULL,
        Description VARCHAR2(500),
        Group_Availability VARCHAR2(50),
        Min_Group_Size NUMBER DEFAULT 0 CHECK (Min_Group_Size >= 0 AND Min_Group_Size <= 20),
        Max_Group_Size NUMBER DEFAULT 20 CHECK (Max_Group_Size >= 0 AND Max_Group_Size <= 20),
        Pricing NUMBER CHECK (Pricing >= 0),
        Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
        Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID)
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
SELECT T.T_ID, 
       T.First_Name, 
       T.Last_Name, 
       T.DOB,
       FLOOR(MONTHS_BETWEEN(SYSDATE, T.DOB) / 12) AS Age,
       T.Demographic_Type, 
       T.Sex, 
       L.Location_Name AS Location, -- Join with Dg_Locations to get the location name
       T.Email, 
       T.Phone
FROM Dg_Travelers T
LEFT JOIN Dg_Locations L ON T.Location_ID = L.Location_ID
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
