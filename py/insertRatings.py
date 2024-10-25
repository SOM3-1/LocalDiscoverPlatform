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

def generate_unique_rating_id(cursor):
    """Generate a unique Rating ID."""
    while True:
        rating_id = f"R{random.randint(1, 99999):05d}"
        cursor.execute("SELECT COUNT(*) FROM Dg_Ratings WHERE Rating_ID = :1", (rating_id,))
        if cursor.fetchone()[0] == 0:  # No existing Rating_ID found
            return rating_id

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Retrieve bookings with 'Completed' status
    cursor.execute("""
        SELECT b.Traveler_ID, b.Experience_ID, b.Experience_Date
        FROM Dg_Bookings b
        JOIN Dg_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
        WHERE bs.Status_Name = 'Confirmed'
    """)
    completed_bookings = cursor.fetchall()
    num_ratings = int(len(completed_bookings) * 0.8)  # 80% of eligible bookings

    # Step 2: Generate ratings
    ratings_data = []
    for _ in range(num_ratings):
        traveler_id, experience_id, experience_date = random.choice(completed_bookings)
        rating_value = round(random.uniform(1.0, 10.0), 1)  # Generate a random rating between 1.0 and 10.0
        review_title = fake.sentence(nb_words=5)
        feedback = fake.paragraph(nb_sentences=3)

        # Ensure the review date is after the experience date
        days_after = random.randint(1, 30)  # Randomly add between 1 and 30 days
        review_date_time = experience_date + timedelta(days=days_after)
        # Add random time to the review date
        review_date_time = datetime.combine(review_date_time, datetime.min.time()) + timedelta(
            hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
        )

        # Generate a unique Rating ID
        rating_id = generate_unique_rating_id(cursor)

        ratings_data.append((
            rating_id, traveler_id, experience_id, rating_value, review_date_time.strftime('%Y-%m-%d %H:%M:%S'),
            feedback, review_title
        ))

    # Step 3: Insert ratings into Dg_Ratings
    logger.info("Inserting ratings into the Dg_Ratings table...")
    insert_query = """
    INSERT INTO Dg_Ratings (
        Rating_ID, Traveler_ID, Experience_ID, Rating_Value, Review_Date_Time, Feedback, Review_Title
    ) VALUES (
        :1, :2, :3, :4, TO_TIMESTAMP(:5, 'YYYY-MM-DD HH24:MI:SS'), :6, :7
    )
    """
    cursor.executemany(insert_query, ratings_data)
    logger.info(f"Inserted {len(ratings_data)} rating records.")

    # Commit the changes
    connection.commit()
    logger.info("All rating records inserted successfully.")

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
