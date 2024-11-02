import cx_Oracle
import logging
import random
import sys
from mocks import preference_options, city_names
from faker import Faker
from datetime import date
from credentials import netid, pwd, connection
from setupConfig import total_travelers, num_preferences

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

    # Step 3: Insert travelers with a reference to Fall24_S003_T8_Locations
    logger.info("Inserting travelers into the Fall24_S003_T8_Travelers table...")
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

        # Insert in batches of 20% and commit
        if i % commit_interval == 0 or i == total_travelers:
            cursor.executemany("""
            INSERT INTO Fall24_S003_T8_Travelers (T_ID, First_Name, Last_Name, DOB, Demographic_Type, Sex, Location_ID, Email, Phone)
            VALUES (:1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), :5, :6, :7, :8, :9)
            """, travelers_data)
            connection.commit()
            logger.info(f"Committed {i} travelers.")
            travelers_data = []  # Clear the list for the next batch

    # Step 4: Insert traveler preferences
    logger.info("Inserting traveler preferences into the Fall24_S003_T8_Traveler_Preferences table...")
    traveler_preferences_data = []
    for traveler_id in range(1, total_travelers + 1):
        t_id = f"T{traveler_id:05d}"
        selected_preferences = random.sample(preference_ids, num_preferences)
        for pref_id in selected_preferences:
            traveler_preferences_data.append((t_id, pref_id))

        # Insert preferences in batches and commit every 20%
        if traveler_id % commit_interval == 0 or traveler_id == total_travelers:
            cursor.executemany("""
            INSERT INTO Fall24_S003_T8_Traveler_Preferences (T_ID, Preference_ID) 
            VALUES (:1, :2)
            """, traveler_preferences_data)
            connection.commit()
            logger.info(f"Committed preferences for {traveler_id} travelers.")
            traveler_preferences_data = []  # Clear for the next batch

    logger.info("All traveler data inserted successfully.")

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
