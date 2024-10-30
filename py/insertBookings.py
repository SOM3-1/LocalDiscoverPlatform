import cx_Oracle
import logging
import sys
import random
from faker import Faker
from datetime import datetime, timedelta
from credentials import netid, pwd, connection

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
    """Ensure the date has a four-digit year."""
    if date_obj.year < 100:
        date_obj = date_obj.replace(year=date_obj.year + 2000)
    return date_obj

# Initialize a set to track used Booking IDs
used_booking_ids = set()

def generate_unique_booking_id():
    """Generate a unique Booking ID."""
    while True:
        booking_id = f"B{random.randint(1, 99999):05d}"
        if booking_id not in used_booking_ids:  # Check against in-memory set
            used_booking_ids.add(booking_id)  # Mark as used
            return booking_id

try:
    # Connect to the database once
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Fetch all necessary data with minimal database calls
    cursor.execute("SELECT T_ID FROM Dg_Travelers")
    travelers = [row[0] for row in cursor.fetchall()]

    cursor.execute("SELECT Experience_ID, Schedule_ID, Pricing FROM Dg_Experience")
    experiences = cursor.fetchall()

    cursor.execute("SELECT Method_ID FROM Dg_Booking_Methods")
    booking_methods = [row[0] for row in cursor.fetchall()]

    cursor.execute("SELECT Status_ID, Status_Name FROM Dg_Booking_Status")
    booking_statuses = {row[1]: row[0] for row in cursor.fetchall()}

    cursor.execute("SELECT Payment_Status_ID, Payment_Status_Name FROM Dg_Payment_Status")
    payment_statuses = {row[1]: row[0] for row in cursor.fetchall()}

    # Fetch existing bookings and store in a nested dictionary to avoid duplicates
    cursor.execute("SELECT Traveler_ID, Experience_ID, Experience_Date FROM Dg_Bookings")
    bookings_dict = {traveler_id: {} for traveler_id in travelers}
    for traveler_id, experience_id, experience_date in cursor.fetchall():
        if experience_id not in bookings_dict[traveler_id]:
            bookings_dict[traveler_id][experience_id] = set()
        bookings_dict[traveler_id][experience_id].add(experience_date)

    # Step 2: Fetch all available dates by schedule in one go
    cursor.execute("SELECT Schedule_ID, Available_Date FROM Dg_Availability_Schedule")
    available_dates_dict = {}
    for schedule_id, available_date in cursor.fetchall():
        if schedule_id not in available_dates_dict:
            available_dates_dict[schedule_id] = []
        available_dates_dict[schedule_id].append(ensure_four_digit_year(available_date))

    # Step 3: Generate bookings
    booking_data = []
    num_bookings = int(len(travelers) * 0.4)  # Targeting 40% of travelers

    for _ in range(num_bookings):
        traveler_id = random.choice(travelers)
        experience_id, schedule_id, pricing = random.choice(experiences)
        available_dates = available_dates_dict.get(schedule_id, [])

        if not available_dates:
            continue

        for _ in range(10):  # Attempt up to 10 times to avoid duplicate bookings
            experience_date = random.choice(available_dates)
            if experience_date not in bookings_dict[traveler_id].get(experience_id, set()):
                date_of_booking = experience_date - timedelta(days=random.randint(1, 30))
                date_of_booking = ensure_four_digit_year(date_of_booking)
                date_of_booking = datetime.combine(date_of_booking, datetime.min.time()) + timedelta(
                    hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
                )

                # Assign booking and payment statuses
                if random.random() < 0.7:
                    payment_status = 'Completed'
                    booking_status = 'Confirmed'
                else:
                    payment_status = random.choice(['Pending', 'Failed', 'Refunded'])
                    booking_status = 'Cancelled' if payment_status in ['Failed', 'Refunded'] else 'Pending'

                # Add this booking to the booking data
                booking_id = generate_unique_booking_id()
                booking_data.append((
                    booking_id, traveler_id, experience_id,
                    date_of_booking.strftime('%Y-%m-%d %H:%M:%S'), experience_date.strftime('%Y-%m-%d'),
                    pricing, booking_statuses[booking_status], random.choice(booking_methods), payment_statuses[payment_status]
                ))

                # Update the bookings_dict to avoid duplicates
                if experience_id not in bookings_dict[traveler_id]:
                    bookings_dict[traveler_id][experience_id] = set()
                bookings_dict[traveler_id][experience_id].add(experience_date)

                break  # Exit retry loop after a valid booking is found

    # Step 4: Insert bookings into Dg_Bookings
    logger.info("Inserting bookings into the Dg_Bookings table...")
    insert_query = """
    INSERT INTO Dg_Bookings (
        Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date,
        Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID
    ) VALUES (
        :1, :2, :3, TO_TIMESTAMP(:4, 'YYYY-MM-DD HH24:MI:SS'), TO_DATE(:5, 'YYYY-MM-DD'), :6, :7, :8, :9
    )
    """
    cursor.executemany(insert_query, booking_data)
    logger.info(f"Inserted {len(booking_data)} booking records.")

    # Commit the changes
    connection.commit()
    logger.info("All booking records inserted successfully.")

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
