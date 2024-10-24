import cx_Oracle
import logging
import random
from mocks import preference_options, city_names
from faker import Faker
from datetime import date

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Database connection configuration
username = ''
password = ''
dsn = "localhost:1523/pcse1p.data.uta.edu"

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
    cursor.execute("SELECT Location_ID FROM Dg_Locations")
    location_ids = [row[0] for row in cursor.fetchall()]

    # Step 2: Retrieve preference data
    cursor.execute("SELECT Category_ID FROM Dg_Interest_Categories")
    preference_ids = [row[0] for row in cursor.fetchall()]

    # Step 3: Insert travelers with a reference to Dg_Locations
    logger.info("Inserting travelers into the Dg_Travelers table...")
    travelers_data = []
    for i in range(1, 1001):  # Generate 1000 travelers
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

    cursor.executemany("""
    INSERT INTO Dg_Travelers (T_ID, First_Name, Last_Name, DOB, Demographic_Type, Sex, Location_ID, Email, Phone)
    VALUES (:1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), :5, :6, :7, :8, :9)
    """, travelers_data)
    logger.info(f"Inserted {len(travelers_data)} travelers.")

    # Step 4: Insert traveler preferences into the Dg_Traveler_Preferences table
    logger.info("Inserting traveler preferences into the Dg_Traveler_Preferences table...")
    traveler_preferences_data = []
    for traveler in travelers_data:
        t_id = traveler[0]
        num_preferences = random.randint(1, 3)  # Each traveler can have 1-3 preferences
        selected_preferences = random.sample(preference_ids, num_preferences)
        for pref_id in selected_preferences:
            traveler_preferences_data.append((t_id, pref_id))

    cursor.executemany("""
    INSERT INTO Dg_Traveler_Preferences (T_ID, Preference_ID) 
    VALUES (:1, :2)
    """, traveler_preferences_data)
    logger.info(f"Inserted {len(traveler_preferences_data)} traveler preferences.")

    # Step 5: Commit the changes
    connection.commit()
    logger.info("All traveler data inserted successfully.")

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
