SET SERVEROUTPUT ON

-- Step 1: Add bookings for January 2024 for Senior Citizens in a new experience and location
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting Booking for January 2024 for Senior Citizens in a new experience and location...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B30001', 'T00001', 'E00040', TO_DATE('2024-01-10', 'YYYY-MM-DD'), TO_DATE('2024-01-15', 'YYYY-MM-DD'), 1500.00, 'BS001', 'BM001', 'PS002');
    DBMS_OUTPUT.PUT_LINE('Booking for January 2024 added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding January 2024 booking: ' || SQLERRM);
END;
/

-- Step 2: Add more bookings for Senior Citizens in June 2024 to increase the booking count for 'Music Festival'
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting additional bookings for Senior Citizens in June 2024 to increase the booking count for "Music Festival"...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B30002', 'T00011', 'E00018', TO_DATE('2024-06-20', 'YYYY-MM-DD'), TO_DATE('2024-06-25', 'YYYY-MM-DD'), 1800.00, 'BS001', 'BM002', 'PS002');
    DBMS_OUTPUT.PUT_LINE('Booking for June 2024 added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding June 2024 booking: ' || SQLERRM);
END;
/

-- Step 3: Update an existing traveler's demographic to "Group"
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating traveler T00011 demographic to "Group"...');
    UPDATE Fall24_S003_T8_Travelers
    SET Demographic_Type = 'Group'
    WHERE T_ID = 'T00011';
    DBMS_OUTPUT.PUT_LINE('Traveler T00011 demographic updated to Group.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating demographic: ' || SQLERRM);
END;
/

-- Step 4: Add a new traveler with a different demographic type
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new traveler with demographic type "Family"...');
    INSERT INTO Fall24_S003_T8_Travelers (T_ID, First_Name, Last_Name, DOB, Demographic_Type, Sex, Location_ID, Email, Phone)
    VALUES ('T10051', 'Samir', 'Allam', TO_DATE('1980-04-15', 'YYYY-MM-DD'), 'Family', 'M', 'L00003', 'new.traveler@example.com', '555-0001');
    DBMS_OUTPUT.PUT_LINE('New traveler T10051 added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding new traveler: ' || SQLERRM);
END;
/

-- Step 5: Add a new experience to associate with "Scuba Diving" activity
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new experience for "Scuba Diving" activity...');
    INSERT INTO Fall24_S003_T8_Experience (Experience_ID, Title, Description, Group_Availability, Min_Group_Size, Max_Group_Size, Pricing, Service_Provider_ID, Schedule_ID)
    VALUES ('E10051', 'Coral Reef Exploration', 'Scuba Diving at Coral Reefs', 'Y', 5, 20, 2500, 'SP00005', 'SCH00004');
    DBMS_OUTPUT.PUT_LINE('New experience E10051 added for Scuba Diving.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding experience: ' || SQLERRM);
END;
/

-- Step 6: Change location for an existing schedule to a new city
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating location for schedule SCH00004 to Memphis...');
    UPDATE Fall24_S003_T8_Schedule_Locations
    SET Location_ID = 'L00028'  -- Memphis
    WHERE Schedule_ID = 'SCH00004';
    DBMS_OUTPUT.PUT_LINE('Schedule location for SCH00004 updated to Memphis.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating schedule location: ' || SQLERRM);
END;
/

-- Step 7: Link SP00005 to a new activity, C00010 (Historical Sites), if not already associated
BEGIN
    DBMS_OUTPUT.PUT_LINE('Linking SP00005 to new activity C00010 (Historical Sites)...');
    INSERT INTO Fall24_S003_T8_Service_Provider_Activities (Service_Provider_ID, Activity_ID)
    VALUES ('SP00005', 'C00010');
    DBMS_OUTPUT.PUT_LINE('SP00005 linked to new activity C00010 (Historical Sites).');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in linking service provider to new activity: ' || SQLERRM);
END;
/



-- Step 9: Update traveler demographic type to change results in the query
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating traveler demographics for T00020 and T00021...');
    UPDATE Fall24_S003_T8_Travelers
    SET Demographic_Type = 'Young Adult'
    WHERE T_ID IN ('T00020', 'T00021');
    DBMS_OUTPUT.PUT_LINE('Traveler demographics for T00020 and T00021 updated to Young Adult.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating demographic type: ' || SQLERRM);
END;
/

-- Step 10: Assign a different location to an experience by updating the Schedule_Locations table
BEGIN
    DBMS_OUTPUT.PUT_LINE('Assigning a different location to an experience...');
    UPDATE Fall24_S003_T8_Schedule_Locations
    SET Location_ID = 'L00009' -- Assume this is Dallas or another high-demand location
    WHERE Schedule_ID = 'SCH00001';
    DBMS_OUTPUT.PUT_LINE('Schedule location for SCH00001 updated to L00009.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating schedule location: ' || SQLERRM);
END;
/

-- Step 11: Insert new bookings for a popular experience to increase its count
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new bookings for popular experience...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10051', 'T00010', 'E00040', TO_DATE('2024-08-10', 'YYYY-MM-DD'), TO_DATE('2024-08-20', 'YYYY-MM-DD'), 500, 'BS001', 'BM001', 'PS001');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10052', 'T00025', 'E00040', TO_DATE('2024-07-10', 'YYYY-MM-DD'), TO_DATE('2024-07-15', 'YYYY-MM-DD'), 600, 'BS001', 'BM001', 'PS001');
    DBMS_OUTPUT.PUT_LINE('Bookings for popular experience added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding bookings for popular experience: ' || SQLERRM);
END;
/

-- Step 12: Add a new confirmed booking for `T00010` with a high `Amount_Paid` to boost Average_Spend
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new confirmed booking for T00010 with a high Amount_Paid...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10053', 'T00010', 'E00024', TO_DATE('2024-11-10', 'YYYY-MM-DD'), TO_DATE('2024-11-15', 'YYYY-MM-DD'), 2200.00, 'BS001', 'BM001', 'PS002');
    DBMS_OUTPUT.PUT_LINE('Booking for T00010 added to boost Average_Spend.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding booking for T00010: ' || SQLERRM);
END;
/

-- Step 13: Increase the number of bookings for T00040 to raise Repeat_Bookings
BEGIN
    DBMS_OUTPUT.PUT_LINE('Increasing the number of bookings for T00040...');
    
    -- Use a new unique Booking_ID (e.g., B10064)
    INSERT INTO Fall24_S003_T8_Bookings 
    (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES 
    ('B10064', 'T00040', 'E00050', TO_DATE('2024-09-18', 'YYYY-MM-DD'), TO_DATE('2024-09-22', 'YYYY-MM-DD'), 1600.00, 'BS001', 'BM001', 'PS001');
    
    -- Use another new unique Booking_ID (e.g., B10065)
    INSERT INTO Fall24_S003_T8_Bookings 
    (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES 
    ('B10065', 'T00040', 'E00016', TO_DATE('2024-09-20', 'YYYY-MM-DD'), TO_DATE('2024-09-25', 'YYYY-MM-DD'), 2500.00, 'BS001', 'BM001', 'PS002');
    
    DBMS_OUTPUT.PUT_LINE('Bookings for T00040 increased to raise Repeat_Bookings.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding bookings for T00040: ' || SQLERRM);
END;
/


-- Step 15: Add a new booking for `T00027` with a lower `Amount_Paid` to decrease Average_Spend
BEGIN
    DBMS_OUTPUT.PUT_LINE('Adding new booking for T00027 with lower Amount_Paid...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10056', 'T00027', 'E00009', TO_DATE('2024-10-05', 'YYYY-MM-DD'), TO_DATE('2024-10-10', 'YYYY-MM-DD'), 1800.00, 'BS001', 'BM004', 'PS002');
    DBMS_OUTPUT.PUT_LINE('Booking for T00027 added with lower Amount_Paid.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding booking for T00027: ' || SQLERRM);
END;
/

-- Step 16: Remove a booking from `T00036` to lower their `Repeat_Bookings`
BEGIN
    DBMS_OUTPUT.PUT_LINE('Removing booking B00042 for T00036...');
    DELETE FROM Fall24_S003_T8_Bookings
    WHERE Booking_ID = 'B00042' AND Traveler_ID = 'T00036';
    DBMS_OUTPUT.PUT_LINE('Booking B00042 removed for T00036.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in deleting booking for T00036: ' || SQLERRM);
END;
/

-- Step 17: Add a new booking for T00050 with a higher payment
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new booking for T00050 with a higher Amount_Paid...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10060', 'T00050', 'E00012', TO_DATE('2024-10-01', 'YYYY-MM-DD'), TO_DATE('2024-10-05', 'YYYY-MM-DD'), 3000.00, 'BS001', 'BM001', 'PS002');
    DBMS_OUTPUT.PUT_LINE('Booking for T00050 added successfully with higher Amount_Paid.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding booking for T00050: ' || SQLERRM);
END;
/

-- Step 18: Add a new booking for T00027 with a medium payment
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new booking for T00027 with medium Amount_Paid...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10061', 'T00027', 'E00033', TO_DATE('2024-09-12', 'YYYY-MM-DD'), TO_DATE('2024-09-15', 'YYYY-MM-DD'), 2200.00, 'BS001', 'BM003', 'PS001');
    DBMS_OUTPUT.PUT_LINE('Booking for T00027 added successfully with medium Amount_Paid.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding booking for T00027: ' || SQLERRM);
END;
/

-- Step 19: Add a booking for T00050 with a low payment to decrease their Average_Spend
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new booking for T00050 with low Amount_Paid...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10062', 'T00050', 'E00033', TO_DATE('2024-09-01', 'YYYY-MM-DD'), TO_DATE('2024-09-03', 'YYYY-MM-DD'), 1500.00, 'BS001', 'BM002', 'PS001');
    DBMS_OUTPUT.PUT_LINE('Booking for T00050 added successfully with low Amount_Paid.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding booking for T00050: ' || SQLERRM);
END;
/

-- Step 20: Add a new experience for "Mountain Hiking" activity
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new experience for "Mountain Hiking" activity...');
    INSERT INTO Fall24_S003_T8_Experience (Experience_ID, Title, Description, Group_Availability, Min_Group_Size, Max_Group_Size, Pricing, Service_Provider_ID, Schedule_ID)
    VALUES ('E10052', 'Mountain Hiking Adventure', 'Experience an exhilarating hike in the mountains', 'Y', 4, 12, 1200, 'SP00040', 'SCH00005');
    DBMS_OUTPUT.PUT_LINE('New experience E10052 for Mountain Hiking added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding Mountain Hiking experience: ' || SQLERRM);
END;
/

-- Step 21: Add a new experience for "Cooking Class" activity
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new experience for "Cooking Class" activity...');
    INSERT INTO Fall24_S003_T8_Experience (Experience_ID, Title, Description, Group_Availability, Min_Group_Size, Max_Group_Size, Pricing, Service_Provider_ID, Schedule_ID)
    VALUES ('E10053', 'Gourmet Cooking Class', 'Learn how to cook gourmet meals with expert chefs', 'Y', 2, 8, 800, 'SP00041', 'SCH00006');
    DBMS_OUTPUT.PUT_LINE('New experience E10053 for Cooking Class added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding Cooking Class experience: ' || SQLERRM);
END;
/


-- Step 22: Add a new rating for the experience "Scuba Diving"
BEGIN
    DBMS_OUTPUT.PUT_LINE('Adding a new rating for the "Scuba Diving" experience...');
    INSERT INTO Fall24_S003_T8_Ratings (Rating_ID, Traveler_ID, Experience_ID, Rating_Value, REVIEW_DATE_TIME, FEEDBACK, REVIEW_TITLE)
    VALUES ('R10013', 'T00050', 'E00012', 9, SYSDATE, 'Great experience, would love to go again!', 'Amazing Scuba Diving Experience');
    DBMS_OUTPUT.PUT_LINE('New rating for Scuba Diving experience added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding rating for Scuba Diving: ' || SQLERRM);
END;
/

-- Step 23: Update the rating for the experience "Desert Safari"
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating rating for Desert Safari experience...');
    UPDATE Fall24_S003_T8_Ratings
    SET Rating_Value = 8.5, Feedback = 'Very good, but could use some improvements in guides'
    WHERE Rating_ID = 'R00015';  -- Assuming R00015 exists
    DBMS_OUTPUT.PUT_LINE('Rating for Desert Safari updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating rating for Desert Safari: ' || SQLERRM);
END;
/

-- Step 24: Update the demographic type for a traveler
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating demographic type for traveler T00020 to "Senior Citizen"...');
    UPDATE Fall24_S003_T8_Travelers
    SET Demographic_Type = 'Senior Citizen'
    WHERE T_ID = 'T00020';
    DBMS_OUTPUT.PUT_LINE('Traveler T00020 demographic updated to Senior Citizen.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in updating demographic type for T00020: ' || SQLERRM);
END;
/

-- Step 25: Add a new booking for T00040 with "Historical Sites" activity
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserting new booking for T00040 with Historical Sites experience...');
    INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
    VALUES ('B10063', 'T00040', 'E00050', TO_DATE('2024-09-18', 'YYYY-MM-DD'), TO_DATE('2024-09-22', 'YYYY-MM-DD'), 1600.00, 'BS001', 'BM001', 'PS001');
    DBMS_OUTPUT.PUT_LINE('Booking for T00040 with Historical Sites experience added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding booking for T00040: ' || SQLERRM);
END;
/   

-- Step 26: Add additional high-value bookings with unique IDs
BEGIN
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('Inserting high-value booking for increasing Average Spend...');
        INSERT INTO Fall24_S003_T8_Bookings (Booking_ID, Traveler_ID, Experience_ID, Date_Of_Booking, Experience_Date, Amount_Paid, Booking_Status_ID, Booking_Method_ID, Payment_Status_ID)
        VALUES ('B400' || TO_CHAR(i), 'T0002' || i, 'E00018', TO_DATE('2024-06-22', 'YYYY-MM-DD'), TO_DATE('2024-06-27', 'YYYY-MM-DD'), 3500.00, 'BS001', 'BM001', 'PS002');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('High-value bookings for June 2024 added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in adding high-value bookings: ' || SQLERRM);
END;
/

-- Final Commit
COMMIT;