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

4. **Run the SQL Scripts:**
   - Open the provided `.sql` files (e.g., `createTables.sql`) in your SQL tool and execute the scripts to perform the required operations.

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
     - Edit the Python script to add your Omega username, password, and connection string.
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
       python createTables.py
       ```
     - To drop tables, execute:
       ```
       python dropTables.py
       ```
     - To create triggers, execute:
       ```
       python createTriggers.py
       ```
     - To drop triggers, execute:
       ```
       python dropTriggers.py
       ```

### Available Scripts

#### 1. `createTables.sql` and `createTables.py`
   - These scripts are used to create the database tables.
   - Use `.sql` files with SQL tools or `.py` files with Python.

#### 2. `dropTables.sql` and `dropTables.py`
   - These scripts drop all tables from the database.
   - Use `.sql` files with SQL tools or `.py` files with Python.

#### 3. `createTriggers.sql` and `createTriggers.py`
   - These scripts create the triggers for the database.
   - Use `.sql` files with SQL tools or `.py` files with Python.

#### 4. `dropTriggers.sql` and `dropTriggers.py`
   - These scripts drop all the triggers from the database.
   - Use `.sql` files with SQL tools or `.py` files with Python.

### Summary

- **SSH Tunnel Requirement:** 
  - An SSH tunnel is required for both SQL tools and Python scripts when running them from your local machine. This is because the Omega database is not directly accessible from outside.
- **Option 1 (SQL Tools):** Run the `.sql` scripts using SQL*Plus, SQL Workbench, or SQL Developer with the SSH tunnel open.
- **Option 2 (Python Scripts):** Run the `.py` scripts directly from the terminal. The SSH tunnel must be open, and the connection string should use `localhost` as the host.

### Notes

- **Deactivating the Virtual Environment:**
  - After completing the operations, deactivate the virtual environment:
    ```
    deactivate
    ```

- **SSH Tunnel Reminder:**
  - Always ensure that the SSH tunnel is open if you are running scripts from your local machine and connecting to Omega's database.
