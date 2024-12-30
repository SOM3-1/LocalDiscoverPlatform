import cx_Oracle
import logging
import random
import sys
from mocks import preference_options, city_names
from faker import Faker
from datetime import date
from credentials import netid, pwd, connection
from setupConfig import total_travelers

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

fake = Faker()

def generate_phone_number():
    phone = fake.unique.phone_number()
    return phone[:15]  # Ensure the phone number does not exceed 15 characters

def get_demographic_type(dob):
    today = date.today()
    age = today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))

    if age > 55:
        return "Senior Citizen"
    elif 18 <= age <= 25:
        return "Student"
    elif 26 <= age <= 40:
        return "Couple"
    elif 41 <= age <= 55:
        return "Group"
    else:
        return "Other"

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Retrieve location data
    cursor.execute("SELECT Location_ID FROM Fall24_S003_T8_Locations")
    location_ids = [row[0] for row in cursor.fetchall()]

    # Step 2: Retrieve preference data
    cursor.execute("SELECT Category_ID FROM Fall24_S003_T8_Interest_Categories")
    preference_ids = [row[0] for row in cursor.fetchall()]

    commit_interval = int(total_travelers * 0.2)  # Commit every 20% of total records

    # Open a text file to write the INSERT ALL statements
    with open("travelers_and_preference_statements.txt", "w") as file:
        # Step 3: Insert travelers with a reference to Fall24_S003_T8_Locations
        logger.info("Writing traveler insert statements to the text file...")
        
        travelers_data = []
        for i in range(1, total_travelers + 1):
            location_id = random.choice(location_ids)
            dob = fake.date_of_birth(minimum_age=18, maximum_age=80)
            demographic_type = get_demographic_type(dob)
            traveler = (
                f"T{i:05d}",
                fake.first_name(),
                fake.last_name(),
                dob.strftime('%Y-%m-%d'),
                demographic_type,
                fake.random_element(elements=['M', 'F', 'O']),
                location_id,
                fake.unique.email(),
                generate_phone_number()
            )
            travelers_data.append(traveler)

            # Write to the file in INSERT ALL format every commit interval
            if i % commit_interval == 0 or i == total_travelers:
                file.write("INSERT ALL\n")
                for traveler in travelers_data:
                    file.write(f"INTO Fall24_S003_T8_Travelers (T_ID, First_Name, Last_Name, DOB, Demographic_Type, Sex, Location_ID, Email, Phone) "
                               f"VALUES ('{traveler[0]}', '{traveler[1]}', '{traveler[2]}', TO_DATE('{traveler[3]}', 'YYYY-MM-DD'), '{traveler[4]}', '{traveler[5]}', '{traveler[6]}', '{traveler[7]}', '{traveler[8]}')\n")
                file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
                
                # Insert into the database and commit
                cursor.executemany("""
                INSERT INTO Fall24_S003_T8_Travelers (T_ID, First_Name, Last_Name, DOB, Demographic_Type, Sex, Location_ID, Email, Phone)
                VALUES (:1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), :5, :6, :7, :8, :9)
                """, travelers_data)
                connection.commit()
                logger.info(f"Committed {i} travelers to the database.")
                travelers_data = []  # Clear the list for the next batch

        # Step 4: Insert traveler preferences
        logger.info("Writing traveler preferences insert statements to the text file...")
        
        traveler_preferences_data = []
        for traveler_id in range(1, total_travelers + 1):
            num_preferences = random.randint(1, 2)
            t_id = f"T{traveler_id:05d}"
            selected_preferences = random.sample(preference_ids, num_preferences)
            for pref_id in selected_preferences:
                traveler_preferences_data.append((t_id, pref_id))

            # Write to file in INSERT ALL format every commit interval
            if traveler_id % commit_interval == 0 or traveler_id == total_travelers:
                file.write("INSERT ALL\n")
                for pref in traveler_preferences_data:
                    file.write(f"INTO Fall24_S003_T8_Traveler_Preferences (T_ID, Preference_ID) "
                               f"VALUES ('{pref[0]}', '{pref[1]}')\n")
                file.write("SELECT * FROM dual;\n\nCOMMIT;\n\n")
                
                # Insert into the database and commit
                cursor.executemany("""
                INSERT INTO Fall24_S003_T8_Traveler_Preferences (T_ID, Preference_ID) 
                VALUES (:1, :2)
                """, traveler_preferences_data)
                connection.commit()
                logger.info(f"Committed preferences for {traveler_id} travelers to the database.")
                traveler_preferences_data = []  # Clear for the next batch

    logger.info("All traveler data and preferences written to text file and inserted into the database.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
    if connection:
        connection.rollback()
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
