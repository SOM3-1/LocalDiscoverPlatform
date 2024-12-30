import cx_Oracle
import logging
import random
import sys
from faker import Faker
from credentials import netid, pwd, connection
from setupConfig import travelers_to_group
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

try:
    # Establish a connection to the database
    logger.info("Connecting to the database...")
    connection = cx_Oracle.connect(username, password, dsn)
    cursor = connection.cursor()
    logger.info("Database connection established.")

    # Step 1: Retrieve travelers to assign as group leaders and members
    cursor.execute("SELECT T_ID FROM Fall24_S003_T8_Travelers")
    traveler_ids = [row[0] for row in cursor.fetchall()]
    total_travelers = len(traveler_ids)
    logger.info(f"Retrieved {total_travelers} travelers.")

    # Step 2: Retrieve available group types from the Fall24_S003_T8_Group_Types table
    logger.info("Retrieving available group types...")
    cursor.execute("SELECT Group_Type_ID FROM Fall24_S003_T8_Group_Types")
    group_type_ids = [row[0] for row in cursor.fetchall()]
    logger.info(f"Retrieved {len(group_type_ids)} group types.")

    # Step 3: Calculate the number of groups (5% of total travelers)
    num_groups = max(1, int(total_travelers * travelers_to_group))  # Ensure at least one group
    logger.info(f"Generating {num_groups} groups (10% of travelers).")

    # Step 4: Generate fake group data
    group_data = []
    selected_leaders = random.sample(traveler_ids, num_groups)  # Randomly choose leaders

    for i in range(num_groups):
        group_id = f"G{i+1:05d}"
        group_name = fake.company()  # Generate a fake group name
        group_type_id = random.choice(group_type_ids)  # Randomly choose a group type ID
        group_leader = selected_leaders[i]
        group_data.append((group_id, group_name, group_leader, group_type_id))

    # Insert fake group data into the Fall24_S003_T8_Groups table
    cursor.executemany("""
    INSERT INTO Fall24_S003_T8_Groups (Group_ID, Group_Name, Group_Leader_T_ID, Group_Type_ID)
    VALUES (:1, :2, :3, :4)
    """, group_data)
    logger.info(f"Inserted {len(group_data)} groups.")

    # Step 5: Assign travelers to the groups, ensuring each traveler is only assigned to one group
    logger.info("Assigning travelers to groups...")
    group_members_data = []
    assigned_travelers = set(selected_leaders)  # Start with the leaders as already assigned

    for group_id, _, leader_id, _ in group_data:
        # Exclude already assigned travelers
        potential_members = [t_id for t_id in traveler_ids if t_id not in assigned_travelers]

        if potential_members:
            # Randomly determine the number of members for the group (at least 2, max 7 additional members)
            num_members = random.randint(2, min(7, len(potential_members)))  # Ensure it doesn't exceed available travelers

            # Select the members randomly
            selected_travelers = random.sample(potential_members, num_members)

            # Add selected travelers to the group and mark them as assigned
            for t_id in selected_travelers:
                group_members_data.append((group_id, t_id))
                assigned_travelers.add(t_id)

    # Insert group members data into the Fall24_S003_T8_Group_Members table
    if group_members_data:
        cursor.executemany("""
        INSERT INTO Fall24_S003_T8_Group_Members (Group_ID, T_ID) 
        VALUES (:1, :2)
        """, group_members_data)
        logger.info(f"Inserted {len(group_members_data)} group members.")

    # Step 6: Update group sizes in the Fall24_S003_T8_Groups table
    for group_id, _, leader_id, _ in group_data:
        # Count the number of members in the group
        cursor.execute("SELECT COUNT(*) FROM Fall24_S003_T8_Group_Members WHERE Group_ID = :1", (group_id,))
        group_size = cursor.fetchone()[0] + 1  # Include the leader in the group size

        # Update the group size
        cursor.execute("UPDATE Fall24_S003_T8_Groups SET Group_Size = :1 WHERE Group_ID = :2", (group_size, group_id))

    # Commit the changes
    connection.commit()
    logger.info("Group data and members inserted successfully.")

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
