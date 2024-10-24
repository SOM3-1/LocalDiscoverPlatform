import cx_Oracle
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Database connection configuration
username = ''
password = ''
dsn = "localhost:1523/pcse1p.data.uta.edu"

# List of view creation statements
view_statements = [
    # View for Travelers and Their Locations
    """
    CREATE OR REPLACE VIEW Vw_Travelers_Location AS
    SELECT T.T_ID, 
           T.First_Name, 
           T.Last_Name, 
           T.DOB,
           FLOOR(MONTHS_BETWEEN(SYSDATE, T.DOB) / 12) AS Age,
           T.Demographic_Type, 
           T.Sex, 
           L.Location_Name AS Location,
           T.Email, 
           T.Phone
    FROM Dg_Travelers T
    LEFT JOIN Dg_Locations L ON T.Location_ID = L.Location_ID
    """,

    # View for Travelers and Their Preferences
    """
    CREATE OR REPLACE VIEW Vw_Traveler_Preferences AS
    SELECT T.T_ID, 
           T.First_Name, 
           T.Last_Name, 
           IC.Category_Name AS Preference
    FROM Dg_Travelers T
    JOIN Dg_Traveler_Preferences TP ON T.T_ID = TP.T_ID
    JOIN Dg_Interest_Categories IC ON TP.Preference_ID = IC.Category_ID
    """,

    # View for Groups and Their Types
    """
    CREATE OR REPLACE VIEW Vw_Groups_With_Types AS
    SELECT G.Group_ID, 
           G.Group_Name, 
           GT.Group_Type_Name, 
           G.Group_Leader_T_ID, 
           G.Group_Size
    FROM Dg_Groups G
    JOIN Dg_Group_Types GT ON G.Group_Type_ID = GT.Group_Type_ID
    """,

    # View for Group Leaders and Their Members
    """
    CREATE OR REPLACE VIEW Vw_Group_Leaders_And_Members AS
    SELECT G.Group_ID, 
           G.Group_Name, 
           Leader.T_ID AS Leader_ID, 
           Leader.First_Name AS Leader_First_Name, 
           Leader.Last_Name AS Leader_Last_Name, 
           Member.T_ID AS Member_ID, 
           Member.First_Name AS Member_First_Name, 
           Member.Last_Name AS Member_Last_Name
    FROM Dg_Groups G
    JOIN Dg_Travelers Leader ON G.Group_Leader_T_ID = Leader.T_ID
    JOIN Dg_Group_Members GM ON G.Group_ID = GM.Group_ID
    JOIN Dg_Travelers Member ON GM.T_ID = Member.T_ID
    """,

    # View for Service Providers and Their Activities
    """
    CREATE OR REPLACE VIEW Vw_Service_Provider_Activities AS
    SELECT SP.Service_Provider_ID, 
           SP.Name AS Service_Provider_Name, 
           IC.Category_Name AS Activity
    FROM Dg_Service_Provider SP
    JOIN Dg_Service_Provider_Activities SPA ON SP.Service_Provider_ID = SPA.Service_Provider_ID
    JOIN Dg_Interest_Categories IC ON SPA.Activity_ID = IC.Category_ID
    """,

    # View for Availability Schedules and Locations
    """
    CREATE OR REPLACE VIEW Vw_Availability_Locations AS
    SELECT ASCH.Schedule_ID, 
           ASCH.Service_Provider_ID, 
           ASCH.Available_Date, 
           L.Location_Name
    FROM Dg_Availability_Schedule ASCH
    JOIN Dg_Schedule_Locations SL ON ASCH.Schedule_ID = SL.Schedule_ID
    JOIN Dg_Locations L ON SL.Location_ID = L.Location_ID
    """,

    # View for Schedule Times and Service Providers
    """
    CREATE OR REPLACE VIEW Vw_Schedule_Times AS
    SELECT ASCH.Schedule_ID, 
           SP.Service_Provider_ID, 
           SP.Name AS Service_Provider_Name, 
           ST.Start_Time, 
           ST.End_Time
    FROM Dg_Availability_Schedule ASCH
    JOIN Dg_Service_Provider SP ON ASCH.Service_Provider_ID = SP.Service_Provider_ID
    JOIN Dg_Schedule_Times ST ON ASCH.Schedule_ID = ST.Schedule_ID
    """,

    # View for Service Providers and Available Dates
    """
    CREATE OR REPLACE VIEW Vw_Service_Providers_Schedule AS
    SELECT SP.Service_Provider_ID,
           SP.Name AS Service_Provider_Name,
           ASCH.Available_Date,
           L.Location_Name
    FROM Dg_Service_Provider SP
    JOIN Dg_Availability_Schedule ASCH ON SP.Service_Provider_ID = ASCH.Service_Provider_ID
    JOIN Dg_Schedule_Locations SL ON ASCH.Schedule_ID = SL.Schedule_ID
    JOIN Dg_Locations L ON SL.Location_ID = L.Location_ID
    """,

    # View for Travelers Who Are Group Members
    """
    CREATE OR REPLACE VIEW Vw_Travelers_In_Groups AS
    SELECT GM.Group_ID,
           G.Group_Name,
           T.T_ID AS Traveler_ID,
           T.First_Name,
           T.Last_Name,
           GT.Group_Type_Name
    FROM Dg_Group_Members GM
    JOIN Dg_Groups G ON GM.Group_ID = G.Group_ID
    JOIN Dg_Travelers T ON GM.T_ID = T.T_ID
    JOIN Dg_Group_Types GT ON G.Group_Type_ID = GT.Group_Type_ID
    """,

    # View for Groups with Their Members Count
    """
    CREATE OR REPLACE VIEW Vw_Group_Members_Count AS
    SELECT G.Group_ID,
           G.Group_Name,
           GT.Group_Type_Name,
           COUNT(GM.T_ID) AS Member_Count
    FROM Dg_Groups G
    JOIN Dg_Group_Types GT ON G.Group_Type_ID = GT.Group_Type_ID
    LEFT JOIN Dg_Group_Members GM ON G.Group_ID = GM.Group_ID
    GROUP BY G.Group_ID, G.Group_Name, GT.Group_Type_Name
    """,

    # View for Service Providers with Their Activities Count
    """
    CREATE OR REPLACE VIEW Vw_Service_Providers_Activities_Count AS
    SELECT SP.Service_Provider_ID,
           SP.Name AS Service_Provider_Name,
           COUNT(SPA.Activity_ID) AS Activity_Count
    FROM Dg_Service_Provider SP
    LEFT JOIN Dg_Service_Provider_Activities SPA ON SP.Service_Provider_ID = SPA.Service_Provider_ID
    GROUP BY SP.Service_Provider_ID, SP.Name
    """,

    # View for Travelers’ Age Groups
    """
    CREATE OR REPLACE VIEW Vw_Traveler_Age_Groups AS
    SELECT T.T_ID,
           T.First_Name,
           T.Last_Name,
           FLOOR(MONTHS_BETWEEN(SYSDATE, T.DOB) / 12) AS Age,
           CASE
               WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, T.DOB) / 12) < 18 THEN 'Child'
               WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, T.DOB) / 12) BETWEEN 18 AND 35 THEN 'Young Adult'
               WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, T.DOB) / 12) BETWEEN 36 AND 55 THEN 'Middle-aged'
               ELSE 'Senior'
           END AS Age_Group
    FROM Dg_Travelers T
    """
]

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Execute each view creation statement
    for statement in view_statements:
        try:
            cursor.execute(statement)
            logger.info(f"Executed view creation successfully: {statement.split()[2]}")
        except cx_Oracle.DatabaseError as e:
            logger.error(f"Failed to create view: {e}")

    # Commit the changes
    connection.commit()
    logger.info("All views created successfully.")

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
