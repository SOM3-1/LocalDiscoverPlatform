import cx_Oracle
import logging
import random
import sys
from faker import Faker
from datetime import datetime, timedelta
from credentials import netid, pwd, connection
from setupConfig import travelers_to_bookings_ratings

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

def generate_unique_rating_ids(count):
    """Generate exactly `count` unique Rating IDs."""
    unique_ids = set()
    while len(unique_ids) < count:
        unique_ids.add(f"R{random.randint(1, 99999):05d}")
    return list(unique_ids)

def generate_rating_data(rating_value):
    """Generate review title and feedback based on rating value."""
    if rating_value <= 4:
        title = random.choice(["Disappointing experience", "Not worth it", "Could be better"])
        feedback = f"{fake.sentence()} Unfortunately, the experience did not meet my expectations. The {fake.word()} part was underwhelming and needs improvement."
    elif 5 <= rating_value <= 7:
        title = random.choice(["Decent experience", "It was okay", "Average outing"])
        feedback = f"{fake.sentence()} The experience was alright but could use some enhancements. The {fake.word()} section was satisfactory but nothing extraordinary."
    else:
        title = random.choice(["Amazing experience!", "Highly recommended", "Would do it again"])
        feedback = f"{fake.sentence()} The experience exceeded my expectations! I particularly enjoyed the {fake.word()} aspect and would recommend it to others."
    return title, feedback

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Retrieve eligible bookings with 'Confirmed' status
    cursor.execute("""
        SELECT b.Traveler_ID, b.Experience_ID, b.Experience_Date
        FROM Fall24_S003_T8_Bookings b
        JOIN Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
        WHERE bs.Status_Name = 'Confirmed'
    """)
    completed_bookings = cursor.fetchall()
    num_ratings = int(len(completed_bookings) * travelers_to_bookings_ratings)  # Targeting 80% of eligible bookings

    # Pre-generate unique Rating IDs
    rating_ids = list(generate_unique_rating_ids(num_ratings))

    ratings_data = []
    eligible_reviews = {(traveler_id, experience_id): experience_date for traveler_id, experience_id, experience_date in completed_bookings}

    for i in range(num_ratings):
        # Select a random (Traveler_ID, Experience_ID) pair
        traveler_experience_pair = random.choice(list(eligible_reviews.keys()))
        traveler_id, experience_id = traveler_experience_pair
        experience_date = eligible_reviews[traveler_experience_pair]

        rating_value = round(random.uniform(2, 10), 1)  # Generate a rating between 2 and 10
        review_title, feedback = generate_rating_data(rating_value)  # Generate title and feedback based on rating

        # Ensure the review date is after the experience date
        days_after = random.randint(1, 30)  # Randomly add 1-30 days after experience
        review_date_time = experience_date + timedelta(days=days_after)
        review_date_time = datetime.combine(review_date_time, datetime.min.time()) + timedelta(
            hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59)
        )

        # Use a pre-generated unique Rating ID
        rating_id = rating_ids[i]

        ratings_data.append((
            rating_id, traveler_id, experience_id, rating_value, review_date_time.strftime('%Y-%m-%d %H:%M:%S'),
            feedback, review_title
        ))

        # Remove the used traveler-experience pair to avoid duplicate ratings
        del eligible_reviews[traveler_experience_pair]

    # Insert ratings into Fall24_S003_T8_Ratings
    logger.info("Inserting ratings into the Fall24_S003_T8_Ratings table...")
    insert_query = """
    INSERT INTO Fall24_S003_T8_Ratings (
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
