import cx_Oracle
import logging
import random
from faker import Faker
from datetime import datetime, timedelta
from credentials import netid, pwd, connection

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Database connection configuration
username = netid
password = pwd
dsn = connection

fake = Faker()

def generate_unique_booking_id(cursor):
    """Generate a unique Booking ID."""
    while True:
        booking_id = f"B{random.randint(1, 99999):05d}"
        cursor.execute("SELECT COUNT(*) FROM Dg_Bookings WHERE Booking_ID = :1", (booking_id,))
        if cursor.fetchone()[0] == 0:  # No existing Booking_ID found
            return booking_id

def is_duplicate_booking(cursor, traveler_id, experience_id, experience_date):
    """Check if a booking already exists for the given traveler, experience, and date."""
    cursor.execute("""
        SELECT COUNT(*) FROM Dg_Bookings 
        WHERE Traveler_ID = :1 AND Experience_ID = :2 AND Experience_Date = TO_DATE(:3, 'YYYY-MM-DD')
    """, (traveler_id, experience_id, experience_date.strftime('%Y-%m-%d')))
    return cursor.fetchone()[0] > 0  # Return True if a duplicate is found

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Retrieve travelers
    cursor.execute("SELECT T_ID FROM Dg_Travelers")
    travelers = [row[0] for row in cursor.fetchall()]
    num_travelers = len(travelers)
    num_bookings = int(num_travelers * 0.4)  # 40% of travelers

    # Step 2: Retrieve experiences with pricing and their schedules
    cursor.execute("SELECT Experience_ID, Schedule_ID, Pricing FROM Dg_Experience")
    experiences = cursor.fetchall()

    # Step 3: Retrieve booking methods
    cursor.execute("SELECT Method_ID FROM Dg_Booking_Methods")
    booking_methods = [row[0] for row in cursor.fetchall()]

    # Step 4: Retrieve booking statuses
    cursor.execute("SELECT Status_ID, Status_Name FROM Dg_Booking_Status")
    booking_statuses = {row[1]: row[0] for row in cursor.fetchall()}

    # Step 5: Retrieve payment statuses
    cursor.execute("SELECT Payment_Status_ID, Payment_Status_Name FROM Dg_Payment_Status")
    payment_statuses = {row[1]: row[0] for row in cursor.fetchall()}

    # Step 6: Generate bookings
    booking_data = []
    booked_dates = {}  # To track booking dates for each traveler to avoid duplicate bookings on the same date

    for _ in range(num_bookings):
        traveler_id = random.choice(travelers)
        experience_id, schedule_id, pricing = random.choice(experiences)

        # Get available dates for the selected schedule
        cursor.execute("""
            SELECT Available_Date FROM Dg_Availability_Schedule WHERE Schedule_ID = :1
        """, (schedule_id,))
        available_dates = [row[0] for row in cursor.fetchall()]

        if not available_dates:
            continue  # Skip if no available dates for the schedule

        # Choose a booking date and ensure it is before the experience date
        experience_date = random.choice(available_dates)
        date_of_booking = experience_date - timedelta(days=random.randint(1, 30))
        # Add random time to the booking date
        date_of_booking = datetime.combine(date_of_booking, datetime.min.time()) + timedelta(
            hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
        )

        # Check for duplicate booking for the same traveler, experience, and date
        if is_duplicate_booking(cursor, traveler_id, experience_id, experience_date):
            continue  # Skip if a duplicate booking exists

        # Randomly choose payment status and map it to corresponding booking status
        payment_status = random.choice(list(payment_statuses.keys()))
        if payment_status == 'Pending':
            booking_status = 'Pending'
        elif payment_status == 'Completed':
            booking_status = 'Confirmed'
        elif payment_status in ['Failed', 'Refunded']:
            booking_status = 'Cancelled'

        # Get the corresponding status IDs
        payment_status_id = payment_statuses[payment_status]
        booking_status_id = booking_statuses[booking_status]
        booking_method_id = random.choice(booking_methods)
        amount_paid = pricing  # Use the pricing from the experience table

        # Generate a unique Booking ID
        booking_id = generate_unique_booking_id(cursor)

        booking_data.append((
            booking_id, traveler_id, experience_id,
            date_of_booking.strftime('%Y-%m-%d %H:%M:%S'), experience_date.strftime('%Y-%m-%d'),
            amount_paid, booking_status_id, booking_method_id, payment_status_id
        ))

    # Step 7: Insert bookings into Dg_Bookings
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
    # Clean up by closing the cursor and connection
    if cursor:
        cursor.close()
        logger.info("Cursor closed.")
    if connection:
        connection.close()
        logger.info("Database connection closed.")
