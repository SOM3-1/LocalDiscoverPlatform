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

--service provider
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

--group
SELECT 
    g.Group_ID,
    g.Group_Name,
    g.Group_Type,
    g.Group_Leader_T_ID AS Leader_ID,
    leader.First_Name AS Leader_First_Name,
    leader.Last_Name AS Leader_Last_Name,
    gm.T_ID AS Member_ID,
    member.First_Name AS Member_First_Name,
    member.Last_Name AS Member_Last_Name
FROM 
    Dg_Groups g
JOIN 
    Dg_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
LEFT JOIN 
    Dg_Group_Members gm ON g.Group_ID = gm.Group_ID
LEFT JOIN 
    Dg_Travelers member ON gm.T_ID = member.T_ID
ORDER BY 
    g.Group_ID;

--travelers in group
SELECT 
    t.T_ID,
    t.First_Name,
    t.Last_Name,
    t.Email,
    gm.Group_ID
FROM 
    Dg_Group_Members gm
JOIN 
    Dg_Travelers t ON gm.T_ID = t.T_ID
ORDER BY 
    gm.Group_ID, t.T_ID;

--eader and their group members
SELECT 
    g.Group_ID,
    g.Group_Name,
    leader.T_ID AS Leader_ID,
    leader.First_Name AS Leader_First_Name,
    leader.Last_Name AS Leader_Last_Name,
    member.T_ID AS Member_ID,
    member.First_Name AS Member_First_Name,
    member.Last_Name AS Member_Last_Name
FROM 
    Dg_Groups g
JOIN 
    Dg_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
JOIN 
    Dg_Group_Members gm ON g.Group_ID = gm.Group_ID
JOIN 
    Dg_Travelers member ON gm.T_ID = member.T_ID
ORDER BY 
    g.Group_ID, member.T_ID;
