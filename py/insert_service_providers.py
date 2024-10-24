import cx_Oracle
import logging
import random
from faker import Faker
from datetime import datetime, timedelta

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

def generate_non_conflicting_schedule(existing_schedules, location_id, activity_count):
    """
    Generates non-conflicting schedules for activities.
    """
    max_retries = 10  # Limit the number of retries to avoid infinite loops
    schedules = []

    for _ in range(activity_count):
        for _ in range(max_retries):
            # Determine if the activity should be scheduled in the past or future
            if random.choice([True, False]):
                # Past activity: schedule within the past 4 weeks
                start_time = fake.date_time_between_dates(
                    datetime_start=datetime.now() - timedelta(weeks=4),
                    datetime_end=datetime.now() - timedelta(days=1)
                )
            else:
                # Future activity: schedule within the next 4 weeks
                start_time = fake.date_time_between_dates(
                    datetime_start=datetime.now() + timedelta(days=1),
                    datetime_end=datetime.now() + timedelta(weeks=4)
                )
            
            # Random duration between 5 hours and 7 days
            duration_hours = random.randint(5, 24 * 7)
            end_time = start_time + timedelta(hours=duration_hours)

            # Check for conflicts with existing schedules
            conflict = any(
                existing_start <= end_time and existing_end >= start_time
                for (existing_start, existing_end, existing_location_id) in existing_schedules
                if existing_location_id == location_id
            )

            if not conflict:
                # No conflict found, add to schedules
                schedules.append((start_time, end_time))
                existing_schedules.append((start_time, end_time, location_id))  # Track this schedule
                break

    return schedules

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Retrieve existing service provider activities to avoid duplicates
    cursor.execute("SELECT Service_Provider_ID, Activity_ID FROM Dg_Service_Provider_Activities")
    existing_activity_pairs = {(row[0], row[1]) for row in cursor.fetchall()}

    # Step 2: Retrieve location and activity data
    cursor.execute("SELECT Location_ID FROM Dg_Locations")
    location_data = cursor.fetchall()

    cursor.execute("SELECT Category_ID, Category_Name FROM Dg_Interest_Categories")
    activity_data = cursor.fetchall()

    # Step 3: Insert service providers
    logger.info("Inserting service providers into the Dg_Service_Provider table...")
    service_providers_data = []
    for i in range(1, 51):  # Generate 200 service providers
        sp_id = f"SP{i:05d}"
        email = fake.unique.email()
        phone = generate_phone_number()

        # Create the service provider record
        service_provider = (
            sp_id,
            fake.company(),
            email,
            phone,
            fake.text(max_nb_chars=200),  # Bio
            fake.street_address(),
            fake.city(),
            fake.zipcode(),
            fake.country()
        )
        service_providers_data.append(service_provider)

    # Execute the bulk insert for service providers
    cursor.executemany("""
    INSERT INTO Dg_Service_Provider (Service_Provider_ID, Name, Email, Phone, Bio, Street, City, Zip, Country) 
    VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9)
    """, service_providers_data)
    logger.info(f"Inserted {len(service_providers_data)} service providers.")

    # Step 4: Insert service provider activities, schedules, and locations
    logger.info("Inserting activities, availability schedules, and locations for service providers...")
    service_provider_activities_data = []
    activity_schedules_data = []
    schedule_times_data = []
    schedule_locations_data = []
    existing_schedules = []  # Track existing schedules
    schedule_id_counter = 1

    for service_provider in service_providers_data:
        sp_id = service_provider[0]
        location_id = random.choice(location_data)[0]  # Get a random location for the service provider
        num_activities = random.randint(1, 6)  # Each provider can have 1-6 activities

        # Generate non-conflicting schedules for these activities
        schedules = generate_non_conflicting_schedule(existing_schedules, location_id, num_activities)

        for schedule in schedules:
            start_time, end_time = schedule
            schedule_id = f"SCH{schedule_id_counter:05d}"
            activity_id, activity_name = random.choice(activity_data)  # Randomly select an activity

            # Check for uniqueness in the service_provider_activities table
            if (sp_id, activity_id) in existing_activity_pairs:
                continue  # Skip if this pair already exists

            # Add to activity, schedule, times, and locations data
            service_provider_activities_data.append((sp_id, activity_id))
            activity_schedules_data.append((schedule_id, sp_id, start_time.date()))
            schedule_times_data.append((schedule_id, start_time, end_time))
            schedule_locations_data.append((schedule_id, location_id))
            existing_activity_pairs.add((sp_id, activity_id))  # Track this pair

            schedule_id_counter += 1

    # Step 5: Insert service provider activities
    cursor.executemany("""
    INSERT INTO Dg_Service_Provider_Activities (Service_Provider_ID, Activity_ID) 
    VALUES (:1, :2)
    """, service_provider_activities_data)
    logger.info(f"Inserted {len(service_provider_activities_data)} service provider activities.")

    # Step 6: Insert availability schedules
    cursor.executemany("""
    INSERT INTO Dg_Availability_Schedule (Schedule_ID, Service_Provider_ID, Available_Date)
    VALUES (:1, :2, TO_DATE(:3, 'YYYY-MM-DD'))
    """, activity_schedules_data)
    logger.info(f"Inserted {len(activity_schedules_data)} availability schedules.")

    # Step 7: Insert schedule times
    cursor.executemany("""
    INSERT INTO Dg_Schedule_Times (Schedule_ID, Start_Time, End_Time)
    VALUES (:1, :2, :3)
    """, schedule_times_data)
    logger.info(f"Inserted {len(schedule_times_data)} schedule times.")

    # Step 8: Insert schedule locations
    cursor.executemany("""
    INSERT INTO Dg_Schedule_Locations (Schedule_ID, Location_ID)
    VALUES (:1, :2)
    """, schedule_locations_data)
    logger.info(f"Inserted {len(schedule_locations_data)} schedule locations.")

    # Step 9: Commit the changes
    connection.commit()
    logger.info("All service provider data inserted successfully.")

except cx_Oracle.DatabaseError as e:
    logger.error(f"An error occurred: {e}")
finally:
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")