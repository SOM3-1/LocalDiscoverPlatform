import subprocess
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# List of scripts to execute
scripts = ['insert_lookup_tables.py', 'insert_travellers.py', 'insert_groups.py', 'insert_service_providers.py'] 

# Execute each script one by one
for script in scripts:
    try:
        logger.info(f"Executing {script}...")
        result = subprocess.run(['python', script], capture_output=True, text=True)

        # Log the output of the script
        logger.info(f"Output of {script}:\n{result.stdout}")
        
        # Check for errors
        if result.returncode != 0:
            logger.error(f"Error executing {script}:\n{result.stderr}")
            break  # Stop executing further scripts if there's an error
        else:
            logger.info(f"{script} executed successfully.")

    except Exception as e:
        logger.error(f"An error occurred while executing {script}: {e}")
        break  # Stop executing further scripts if there's an error
