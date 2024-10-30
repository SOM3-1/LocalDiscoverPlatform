import cx_Oracle
import logging
import random
from faker import Faker
from datetime import datetime, timedelta
from credentials import netid, pwd, connection
from setupConfig import service_provider_percent, num_activities
import sys

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

def ensure_four_digit_year(date_obj):
    """Ensure dates have a four-digit year."""
    if date_obj.year < 100:
        date_obj = date_obj.replace(year=date_obj.year + 2000)
    return date_obj

def generate_phone_number():
    phone = fake.unique.phone_number()
    return phone[:15]  # Ensure the phone number does not exceed 15 characters

def generate_non_conflicting_schedule(existing_schedules, location_id, activity_count):
    """Generates non-conflicting schedules for activities."""
    max_retries = 10
    schedules = []
    for _ in range(activity_count):
        for _ in range(max_retries):
            # Past activity or future activity decision
            if random.choice([True, False]):
                start_time = fake.date_time_between_dates(
                    datetime_start=datetime.now() - timedelta(weeks=52),
                    datetime_end=datetime.now() - timedelta(days=1)
                )
            else:
                start_time = fake.date_time_between_dates(
                    datetime_start=datetime.now() + timedelta(days=1),
                    datetime_end=datetime.now() + timedelta(weeks=10)
                )
            start_time = ensure_four_digit_year(start_time)
            duration_hours = random.randint(5, 24 * 7)
            end_time = ensure_four_digit_year(start_time + timedelta(hours=duration_hours))

            # Conflict checking
            conflict = any(
                existing_start <= end_time and existing_end >= start_time
                for (existing_start, existing_end, existing_location_id) in existing_schedules
                if existing_location_id == location_id
            )
            if not conflict:
                schedules.append((start_time, end_time))
                existing_schedules.append((start_time, end_time, location_id))
                break
    return schedules

try:
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    cursor.execute("SELECT Service_Provider_ID, Activity_ID FROM Dg_Service_Provider_Activities")
    existing_activity_pairs = {(row[0], row[1]) for row in cursor.fetchall()}

    cursor.execute("SELECT Location_ID FROM Dg_Locations")
    location_data = cursor.fetchall()

    cursor.execute("SELECT Category_ID, Category_Name FROM Dg_Interest_Categories")
    activity_data = cursor.fetchall()

    cursor.execute("SELECT COUNT(*) FROM Dg_Travelers")
    total_travelers = cursor.fetchone()[0]
    num_service_providers = max(1, int(total_travelers * service_provider_percent))

    service_providers_data = []
    for i in range(1, num_service_providers + 1):
        sp_id = f"SP{i:05d}"
        email = fake.unique.email()
        phone = generate_phone_number()
        service_provider = (
            sp_id,
            fake.company(),
            email,
            phone,
            fake.text(max_nb_chars=200),
            fake.street_address(),
            fake.city(),
            fake.zipcode(),
            fake.country()
        )
        service_providers_data.append(service_provider)

    # Insert in batches of 25%
    batch_size = max(1, len(service_providers_data) // 4)
    for i in range(0, len(service_providers_data), batch_size):
        batch = service_providers_data[i:i + batch_size]
        cursor.executemany("""
        INSERT INTO Dg_Service_Provider (Service_Provider_ID, Name, Email, Phone, Bio, Street, City, Zip, Country) 
        VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9)
        """, batch)
        connection.commit()
        logger.info(f"Inserted batch of {len(batch)} service providers (committed 25% batch).")

    service_provider_activities_data = []
    activity_schedules_data = []
    schedule_times_data = []
    schedule_locations_data = []
    existing_schedules = []
    schedule_id_counter = 1

    for service_provider in service_providers_data:
        sp_id = service_provider[0]
        location_id = random.choice(location_data)[0]

        schedules = generate_non_conflicting_schedule(existing_schedules, location_id, num_activities)
        for schedule in schedules:
            start_time, end_time = schedule
            schedule_id = f"SCH{schedule_id_counter:05d}"
            activity_id, activity_name = random.choice(activity_data)

            if (sp_id, activity_id) in existing_activity_pairs:
                continue
            service_provider_activities_data.append((sp_id, activity_id))
            available_date = ensure_four_digit_year(start_time.date())
            activity_schedules_data.append((schedule_id, sp_id, available_date.strftime('%Y-%m-%d')))
            schedule_times_data.append((schedule_id, start_time, end_time))
            schedule_locations_data.append((schedule_id, location_id))
            existing_activity_pairs.add((sp_id, activity_id))

            schedule_id_counter += 1

    # Insert activities, schedules, times, and locations in 25% batches
    for data_list, insert_query, data_name in [
        (service_provider_activities_data, """
        INSERT INTO Dg_Service_Provider_Activities (Service_Provider_ID, Activity_ID) 
        VALUES (:1, :2)
        """, "service provider activities"),
        
        (activity_schedules_data, """
        INSERT INTO Dg_Availability_Schedule (Schedule_ID, Service_Provider_ID, Available_Date)
        VALUES (:1, :2, TO_DATE(:3, 'YYYY-MM-DD'))
        """, "availability schedules"),
        
        (schedule_times_data, """
        INSERT INTO Dg_Schedule_Times (Schedule_ID, Start_Time, End_Time)
        VALUES (:1, :2, :3)
        """, "schedule times"),
        
        (schedule_locations_data, """
        INSERT INTO Dg_Schedule_Locations (Schedule_ID, Location_ID)
        VALUES (:1, :2)
        """, "schedule locations")
    ]:
        batch_size = max(1, len(data_list) // 4)
        for i in range(0, len(data_list), batch_size):
            batch = data_list[i:i + batch_size]
            cursor.executemany(insert_query, batch)
            connection.commit()
            logger.info(f"Inserted batch of {len(batch)} {data_name} (committed 25% batch).")

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
