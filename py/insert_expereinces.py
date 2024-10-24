import cx_Oracle
import logging
import random
from faker import Faker
from mocks import preference_options

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Database connection configuration
username = ''
password = ''
dsn = "localhost:1523/pcse1p.data.uta.edu"

fake = Faker()

# Function to determine group availability and size
def determine_group_availability():
    group_avail = random.choice(['Y', 'N'])  # Randomly choose 'Y' or 'N'
    if group_avail == 'Y':
        min_size = random.randint(2, 10)
        max_size = random.randint(min_size, 20)
    else:
        min_size = 0
        max_size = 0
    return group_avail, min_size, max_size

# Function to generate an experience title based on the activity type
def generate_experience_title(activity_type):
    title_templates = [
        f"Exciting {activity_type} Adventure",
        f"Guided {activity_type} Experience",
        f"{activity_type} Exploration Journey",
        f"Unforgettable {activity_type} Trip",
        f"{activity_type} Escape",
        f"Ultimate {activity_type} Experience",
        f"{activity_type} Discovery Tour"
    ]
    return random.choice(title_templates)

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Retrieve the number of travelers
    cursor.execute("SELECT COUNT(*) FROM Dg_Travelers")
    traveler_count = cursor.fetchone()[0]
    logger.info(f"Retrieved traveler count: {traveler_count}")

    # Determine the number of experiences based on traveler count (e.g., 1 experience for every 5 travelers)
    num_experiences = max(1, traveler_count // 5)  # Ensure at least 1 experience is created

    # Step 2: Retrieve Service Provider IDs and their activities
    cursor.execute("""
        SELECT SPA.Service_Provider_ID, IC.Category_Name
        FROM Dg_Service_Provider_Activities SPA
        JOIN Dg_Interest_Categories IC ON SPA.Activity_ID = IC.Category_ID
    """)
    service_provider_activities = cursor.fetchall()
    available_activities = len(service_provider_activities)

    if not service_provider_activities:
        raise ValueError("No service provider activities found. Cannot create experiences.")
    logger.info(f"Retrieved {available_activities} service provider activities.")

    # Limit the number of experiences to the number of distinct activities if necessary
    num_experiences = min(num_experiences, available_activities)
    logger.info(f"Number of experiences to create: {num_experiences}")

    # Step 3: Retrieve Schedule IDs
    cursor.execute("SELECT Schedule_ID FROM Dg_Availability_Schedule")
    schedule_ids = [row[0] for row in cursor.fetchall()]
    if not schedule_ids:
        raise ValueError("No schedules found. Cannot create experiences.")
    logger.info(f"Retrieved {len(schedule_ids)} schedules.")

    # Shuffle the service provider activities to ensure random selection
    random.shuffle(service_provider_activities)

    # Step 4: Generate and insert experiences
    experiences_data = []

    for i in range(num_experiences):
        experience_id = f"E{i+1:05d}"
        service_provider_id, activity_type = service_provider_activities[i]
        title = generate_experience_title(activity_type)  # Generate a title based on the activity type
        description = f"Join us for an amazing {activity_type.lower()} where you will {fake.sentence(nb_words=10)}."
        group_availability, min_group_size, max_group_size = determine_group_availability()
        pricing = round(random.uniform(100, 5000), 2)  # Random pricing between 50 and 500
        schedule_id = random.choice(schedule_ids)

        experiences_data.append((
            experience_id, title, description, group_availability,
            min_group_size, max_group_size, pricing,
            service_provider_id, schedule_id
        ))

    # Insert the generated experiences into the Dg_Experience table
    cursor.executemany("""
    INSERT INTO Dg_Experience (
        Experience_ID, Title, Description, Group_Availability,
        Min_Group_Size, Max_Group_Size, Pricing,
        Service_Provider_ID, Schedule_ID
    ) VALUES (
        :1, :2, :3, :4, :5, :6, :7, :8, :9
    )
    """, experiences_data)
    logger.info(f"Inserted {len(experiences_data)} experiences into the Dg_Experience table.")

    # Commit the changes
    connection.commit()
    logger.info("All experience records committed successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
    if connection:
        connection.rollback()
finally:
    # Clean up by closing the cursor and connection
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
