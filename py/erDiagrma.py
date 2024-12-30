import sqlite3
import os
from eralchemy import render_er

sql_file_path = 'createAllTables.sql' 
temp_db_path = 'temp.db' 

try:
    with sqlite3.connect(temp_db_path) as conn:
        with open(sql_file_path, 'r') as f:
            sql_script = f.read()
        conn.executescript(sql_script)

    output_diagram_file = 'ER_Diagram.png'
    render_er(f'sqlite:///{temp_db_path}', output_diagram_file)
    print(f"ER Diagram generated and saved as {output_diagram_file}")

finally:
    if os.path.exists(temp_db_path):
        os.remove(temp_db_path)
        print(f"Temporary database {temp_db_path} has been removed.")
