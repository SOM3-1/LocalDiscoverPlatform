import subprocess
import logging
import sys

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s", handlers=[logging.StreamHandler()])
logger = logging.getLogger(__name__)

# List of scripts to execute
scripts = ['insertLookupTables.py', 'insertTravellers.py', 'insertGroups.py', 'insertServiceProviders.py', 'insertExpereinces.py', 'insertBookings.py', 'insertRatings.py'] 

# Execute each script one by one
for script in scripts:
    try:
        logger.info(f"Executing {script}...")
        result = subprocess.run(['python', script], capture_output=True, text=True)

        # Log the output of the script
        logger.info(f"Output of {script}:\n{result.stdout}")
        
        # Check for errors
        if result.returncode != 0 or result.stderr:
            logger.error(f"Error executing {script}:\n{result.stderr}")
            sys.exit(1)  # Stop the script entirely if there's an error
        else:
            logger.info(f"{script} executed successfully.")

    except Exception as e:
        logger.error(f"An error occurred while executing {script}: {e}")
        sys.exit(1)  # Stop the script entirely if there's an error
