--All the travelers
SELECT 
    t.T_ID,
    t.First_Name,
    t.Last_Name,
    t.DOB,
    t.Demographic_Type,
    t.Sex,
    t.Location,
    t.Email,
    t.Phone,
    p.Preference_Name
FROM 
    Dg_Travelers t
JOIN 
    Dg_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Dg_Preferences p ON tp.Preference_ID = p.Preference_ID
ORDER BY 
    t.T_ID, p.Preference_Name;
