DROP VIEW Vw_Travelers;

DELETE FROM Dg_Ratings;

DELETE FROM Dg_Bookings;

DELETE FROM Dg_Experience_Tags;

DELETE FROM Dg_Group_Members;

DELETE FROM Dg_Groups;

DELETE FROM Dg_Traveler_Preferences;

DELETE FROM Dg_Experience;

DELETE FROM Dg_Service_Provider;

DELETE FROM Dg_Travelers;

COMMIT;

DROP TABLE Dg_Ratings;
DROP TABLE Dg_Bookings;
DROP TABLE Dg_Experience_Tags;
DROP TABLE Dg_Group_Members;
DROP TABLE Dg_Groups;
DROP TABLE Dg_Traveler_Preferences;
DROP TABLE Dg_Experience;
DROP TABLE Dg_Service_Provider;
DROP TABLE Dg_Travelers;
