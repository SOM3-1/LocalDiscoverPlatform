import cx_Oracle
import logging
from faker import Faker
from datetime import date
import random

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

username = ''
password = ''
dsn = 'localhost:1523/pcse1p.data.uta.edu'

fake = Faker()

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

travelers_data = []
preferences_data = []
preference_options = [
    'Beach', 'Mountain', 'City Tour', 'Adventure', 'Cruise', 'Hiking', 'Cultural Experience', 'Food & Drink',
    'Wildlife Safari', 'Historical Sites', 'Nightlife', 'Shopping', 'Spa & Wellness', 'Sports Events', 'Road Trip',
    'Camping', 'Photography', 'Music Festival', 'Art & Craft', 'Yoga Retreat', 'Sailing', 'Desert Safari',
    'Skiing', 'Scuba Diving', 'Golfing'
]

for i in range(1, 1001):
    dob = fake.date_of_birth(minimum_age=18, maximum_age=80)
    demographic_type = get_demographic_type(dob)
    phone = fake.unique.phone_number()[:15]
    
    traveler = (
        f"T{i:05d}",
        fake.first_name(),
        fake.last_name(),
        dob.strftime('%Y-%m-%d'),
        demographic_type,
        fake.random_element(elements=['M', 'F', 'O']),
        fake.city(),
        fake.unique.email(),
        phone
    )
    travelers_data.append(traveler)

    num_preferences = random.randint(1, len(preference_options))
    selected_preferences = random.sample(preference_options, num_preferences)
    for preference in selected_preferences:
        preferences_data.append((traveler[0], preference))

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    insert_travelers_sql = """
    INSERT INTO Dg_Travelers (
        T_ID, First_Name, Last_Name, DOB, Demographic_Type, Sex, Location, Email, Phone
    ) VALUES (
        :1, :2, :3, TO_DATE(:4, 'YYYY-MM-DD'), :5, :6, :7, :8, :9
    )
    """
    logger.info(f"Inserting travelers into the database...")

    batch_size = 100  # Insert in batches of 100
    for i in range(0, len(travelers_data), batch_size):
        batch = travelers_data[i:i + batch_size]
        cursor.executemany(insert_travelers_sql, batch)
        logger.info(f"Inserted {i + len(batch)} travelers")

    insert_preferences_sql = """
    INSERT INTO Dg_Traveler_Preferences (
        T_ID, Preference
    ) VALUES (
        :1, :2
    )
    """
    logger.info(f"Inserting traveler preferences into the database...")

    for i in range(0, len(preferences_data), batch_size):
        batch = preferences_data[i:i + batch_size]
        cursor.executemany(insert_preferences_sql, batch)
        logger.info(f"Inserted {i + len(batch)} preferences")

    connection.commit()
    logger.info("Database commit successful.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
