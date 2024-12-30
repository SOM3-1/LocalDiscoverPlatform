## README

### Prerequisites

1. **Omega Account:**
   - You need an account on the Omega server at the University of Texas at Arlington.

2. **SQL*Plus Access (optional):**
   - If you plan to use SQL*Plus, SQL Workbench, or SQL Developer, make sure you have one of these tools installed and configured.

3. **Python 3:**
   - Python 3 must be installed on your system for running Python scripts.

4. **cx_Oracle Python Package:**
   - Required for connecting to Oracle databases from Python scripts.

### Running SQL Scripts Using SQL Developer, SQL Workbench, or SQL*Plus

1. **Setup the SSH Tunnel:**
   - To connect to the Oracle database from SQL Developer, SQL Workbench, SQL*Plus, or Python scripts, you need an SSH tunnel.
   - Run the following command to create the SSH tunnel:
     ```
     ssh -L 1523:acaddbprod.uta.edu:1523 username@omega.uta.edu
     ```
   - Replace `username` with your Omega username.
   - This command forwards port 1523 to the Oracle server, making it accessible from your local machine.

2. **Keep the SSH Tunnel Open:**
   - Make sure the SSH tunnel is running while using SQL tools or Python scripts to connect to the database.

3. **SQL Tools Setup:**
   - Configure your SQL tool (SQL Developer, SQL Workbench, or SQL*Plus):
     - **Host:** `localhost`
     - **Port:** `1523`
     - **Service name:** `pcse1p.data.uta.edu`

### 4. **Run the SQL Scripts:**

- Use the provided `.sql` files to set up and manage the database:
  - `projectDBdrop.sql`: Drops existing tables, views, and triggers to reset the database.
  - `projectDBcreate.sql`: Creates the necessary tables, views, and triggers for the project.
  - `adhocQueries.sql`: Contains ad-hoc queries for various data operations and testing.
  - `projectDBqueries.sql`: Contains queries required for project submission.
  - `businessGoals.sql`: Contains queries related to buisness goals.

- Open each `.sql` file in your SQL tool and execute them as needed to perform the required operations. 

### Running Python Scripts in the Terminal

1. **SSH Tunnel Requirement:**
   - **An SSH tunnel is required** if you are running the Python scripts from your local machine. The `dsn` in the script should be set to `localhost`, which forwards to the Omega database through the SSH tunnel.

2. **Setting Up the Python Environment:**

   - Install Python 3 from the official [Python website](https://www.python.org/downloads/).
   
   - Create a virtual environment (recommended):
     ```
     python3 -m venv venv
     ```
     - This will create a virtual environment named `venv`.

   - Activate the virtual environment:
     - On Windows:
       ```
       .\venv\Scripts\activate
       ```
     - On macOS/Linux:
       ```
       source venv/bin/activate
       ```

   - Install `cx_Oracle`:
     ```
     pip install cx_Oracle
     ```

3. **Running the Python Scripts:**

   - **Add Database Credentials:**
     - Edit the `credentials.py` file to enter your Omega username, password, and connection string.
     - Example:
       ```python
       username = 'your_username'
       password = 'your_password'
       dsn = 'localhost:1523/pcse1p.data.uta.edu'
       ```
     - Ensure the SSH tunnel is open, as the script connects through `localhost`.

   - **Run the Scripts:**
     - To create tables, execute:
       ```
       python createAll.py
       ```
     - To drop tables, execute:
       ```
       python dropAll.py
       ```

### Creaetin Tables and Inserting Data in a Single Run

If you want to insert all the necessary table, views, triggers and data into the database tables in a single run, you should use the `runAllScripts.py` script. This script automates the process of executing multiple create, insert scripts sequentially, populating all the required tables.

To insert data in a single run, execute:
   ```
   python runAllScripts.py
   ```
### Script Execution Order

1. `dropll.py`: Drops existing tables, views, and triggers.
2. `createAll.py`: Creates all tables, views, and triggers in the database.

#### Data Insertion Scripts:

3. `insertLookupTables.py`: Inserts reference or lookup data.
4. `insertTravellers.py`: Inserts traveler data.
5. `insertGroups.py`: Inserts group data.
6. `insertServiceProviders.py`: Inserts service provider data.
7. `insertExpereinces.py`: Inserts experience data.
8. `insertBookings.py`: Inserts booking data.
9. `insertRatings.py`: Inserts rating data.

Make sure that:
   - The SSH tunnel is open.
   - You have configured `credentials.py` with the correct database credentials.
   - All insert scripts are present and properly configured.

### Available Scripts

#### 1. `credentials.py`
   - Stores database connection credentials such as the username, password, and connection string. **Remember to edit this file to enter your database credentials before running any scripts.**

#### 2. `createAll.py`
   - Creates the necessary database tables and triggers for the project. It contains the SQL commands to define the schema for each table.

#### 3. `createViews.py`
   - Creates views in the database, which are virtual tables representing the result of a query. Views can simplify data retrieval and improve query readability.

#### 4. `dropAll.py`
   - Drops (deletes) the triggers and tables from the database. Useful for cleaning up or resetting the schema.

#### 5. `dropViews.py`
   - Drops the views from the database, removing any virtual tables created with `createViews.py`.

#### 6. `insertExperiences.py`
   - Inserts data into the `Fall24_S003_T8_Experience` table. This script adds records for different experiences using data generated from the `mocks.py` file or other sources.

#### 7. `insertGroups.py`
   - Adds data to the table that manages group-related information, such as group bookings or categories.

#### 8. `insertLookuptables.py`
   - Populates the lookup tables with reference data used across different tables. The data for these tables is typically provided in `mocks.py`.

#### 9. `insertServiceProviders.py`
   - Inserts records into the `Fall24_S003_T8_Service_Providers` table, which stores information about service providers who offer various experiences.

#### 10. `insertTravellers.py`
   - Adds records to the `Fall24_S003_T8_Travelers` table, representing travelers or users who participate in the experiences.

#### 11. `insertBookings.py`
   - Adds records to the `Fall24_S003_T8_Bookings` table, representing bookings done by travelers.

#### 12. `insertRatings.py`
   - Adds records to the `Fall24_S003_T8_Ratings` table, representing reviews recorded by travelers.

#### 13. `mocks.py`
   - Contains mock data used for populating the database. Includes lists of sample data such as city names, experience tags, categories, and other reference data.

#### 14. `setupConfig.py`
   - Contains config file where we can set number of travelers, service providers and so on.

#### 15. `tables.py`
   - Contains table, views, triggers names to create or drop.

#### 16. `runAllScripts.py`
   - Automates the process of running multiple insert scripts in a sequence to populate the database tables with initial data. **If you want to insert all the data in a single run, use this script.**

### Summary

- **SSH Tunnel Requirement:** 
  - An SSH tunnel is required for both SQL tools and Python scripts when running them from your local machine. This is because the Omega database is not directly accessible from outside.
- **Option 1 (SQL Tools):** Run the `.sql` scripts using SQL*Plus, SQL Workbench, or SQL Developer with the SSH tunnel open.
- **Option 2 (Python Scripts):** Run the `.py` scripts directly from the terminal. The SSH tunnel must be open, and the connection string should use `localhost` as the host.
- **Single Run Data Insertion:** Use `run_scripts_insert.py` to insert all data in one go.

### Notes

- **Deactivating the Virtual Environment:**
  - After completing the operations, deactivate the virtual environment:
    ```
    deactivate
    ```

- **SSH Tunnel Reminder:**
  - Always ensure that the SSH tunnel is open if you are running scripts from your local machine and connecting to Omega's database.


### Order of Execution

To ensure the database is set up correctly, follow these steps in the specified order:

1. **Create Tables and Triggers**
   - Start by creating the necessary database tables and triggers. This defines the schema for each table that will be populated.

2. **Lookup Tables**
   - Populate lookup tables with reference data, such as booking statuses, payment methods, and categories.

3. **Travelers**
   - Insert traveler information, including personal details, preferences, and associated locations.

4. **Traveler Groups**
   - Set up traveler groups, including group categories and membership information.

5. **Service Providers**
   - Add service providers, including details about the services they offer.

6. **Experiences**
   - Insert data related to experiences, including schedules, pricing, and associated service providers.

7. **Bookings**
   - Populate the bookings table, associating travelers with their booked experiences.

8. **Ratings**
   - Insert traveler ratings and feedback for the experiences they've participated in.

9. **Drop Triggers and Tables**
   - If needed, you can drop the triggers and tables to clean up the database. This step removes all the data, trigger and table definitions. 
