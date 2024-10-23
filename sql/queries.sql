-- All the travelers with location and preferences
SELECT 
    t.T_ID,
    t.First_Name,
    t.Last_Name,
    t.DOB,
    t.Demographic_Type,
    t.Sex,
    l.Location_Name AS Location,
    t.Email,
    t.Phone,
    p.Category_Name AS Preference_Name
FROM 
    Dg_Travelers t
JOIN 
    Dg_Locations l ON t.Location_ID = l.Location_ID
JOIN 
    Dg_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Dg_Interest_Categories p ON tp.Preference_ID = p.Category_ID
ORDER BY 
    t.T_ID, p.Category_Name;


SELECT 
    sp.Service_Provider_ID,
    sp.Name,
    sp.Email,
    sp.Phone,
    sp.Bio,
    sp.Street,
    sp.City,
    sp.Zip,
    sp.Country,
    ic.Category_Name AS Activity_Name,
    asch.Available_Date,
    loc.Location_Name AS Schedule_Location,
    st.Start_Time,
    st.End_Time
FROM 
    Dg_Service_Provider sp
LEFT JOIN 
    Dg_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
LEFT JOIN 
    Dg_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
LEFT JOIN 
    Dg_Availability_Schedule asch ON sp.Service_Provider_ID = asch.Service_Provider_ID
LEFT JOIN 
    Dg_Schedule_Locations sl ON asch.Schedule_ID = sl.Schedule_ID
LEFT JOIN 
    Dg_Locations loc ON sl.Location_ID = loc.Location_ID
LEFT JOIN 
    Dg_Schedule_Times st ON asch.Schedule_ID = st.Schedule_ID
ORDER BY 
    sp.Name, ic.Category_Name, asch.Available_Date, st.Start_Time;
