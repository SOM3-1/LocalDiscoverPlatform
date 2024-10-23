-- Creating the Dg_Travelers table
CREATE TABLE Dg_Travelers (
    T_ID VARCHAR2(20) PRIMARY KEY,
    First_Name VARCHAR2(50) NOT NULL,
    Last_Name VARCHAR2(50) NOT NULL,
    DOB DATE NOT NULL,
    Demographic_Type VARCHAR2(50),
    Sex CHAR(1) CHECK (Sex IN ('M', 'F', 'O')),
    Location VARCHAR2(100),
    Email VARCHAR2(50) UNIQUE NOT NULL,
    Phone VARCHAR2(15) UNIQUE NOT NULL
);

-- Creating the Dg_Preferences
CREATE TABLE Dg_Preferences (
    Preference_ID VARCHAR2(20) PRIMARY KEY,
    Preference_Name VARCHAR2(100) NOT NULL UNIQUE
);

-- Creating the Dg_Traveler_Preferences table with a unique constraint to prevent duplicate preferences
CREATE TABLE Dg_Traveler_Preferences (
    T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Preference_ID VARCHAR2(20) REFERENCES Dg_Preferences(Preference_ID),
    PRIMARY KEY (T_ID, Preference_ID)
);

-- Creating the view for calculating age dynamically
CREATE OR REPLACE VIEW Vw_Travelers AS
SELECT T_ID, 
       First_Name, 
       Last_Name, 
       DOB,
       FLOOR(MONTHS_BETWEEN(SYSDATE, DOB) / 12) AS Age,
       Demographic_Type, 
       Sex, 
       Location, 
       Email, 
       Phone
FROM Dg_Travelers;

-- Creating the Dg_Groups table
CREATE TABLE Dg_Groups (
    Group_ID VARCHAR2(20) PRIMARY KEY,
    Group_Name VARCHAR2(100),
    Group_Leader_T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Group_Type VARCHAR2(50),
    Group_Size NUMBER DEFAULT 0
);

-- Creating the Dg_Group_Members table
CREATE TABLE Dg_Group_Members (
    Group_ID VARCHAR2(20) REFERENCES Dg_Groups(Group_ID),
    T_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    PRIMARY KEY (Group_ID, T_ID)
);

-- Creating the Dg_Service_Provider table
CREATE TABLE Dg_Service_Provider (
    Service_Provider_ID VARCHAR2(20) PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Email VARCHAR2(50) UNIQUE NOT NULL,
    Phone VARCHAR2(15) UNIQUE NOT NULL,
    Bio VARCHAR2(500),
    Street VARCHAR2(100),
    City VARCHAR2(50),
    Zip VARCHAR2(10),
    Country VARCHAR2(100)
);

-- Creating the Dg_Activity_types table
CREATE TABLE Dg_Activity_Types (
    Activity_ID VARCHAR2(20) PRIMARY KEY,
    Activity_Name VARCHAR2(50) NOT NULL
);

-- Creating the  Dg_Service_Provider_Activities table
CREATE TABLE Dg_Service_Provider_Activities (
    Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
    Activity_ID VARCHAR2(20) REFERENCES Dg_Activity_Types(Activity_ID),
    PRIMARY KEY (Service_Provider_ID, Activity_ID)
);

-- Creating the  Dg_Availability_Schedule table
CREATE TABLE Dg_Availability_Schedule (
    Schedule_ID VARCHAR2(20) PRIMARY KEY,
    Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
    Available_Date DATE NOT NULL
);

-- Creating the  Dg_Schedule_Locations table
CREATE TABLE Dg_Schedule_Locations (
    Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
    Location VARCHAR2(100) NOT NULL,
    PRIMARY KEY (Schedule_ID, Location)
);

-- Creating the  Dg_Schedule_Times table
CREATE TABLE Dg_Schedule_Times (
    Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID),
    Start_Time TIMESTAMP NOT NULL,
    End_Time TIMESTAMP NOT NULL,
    PRIMARY KEY (Schedule_ID, Start_Time)
);

-- Creating the Dg_Experience table
CREATE TABLE Dg_Experience (
    Experience_ID VARCHAR2(20) PRIMARY KEY,
    Title VARCHAR2(100) NOT NULL,
    Description VARCHAR2(500),
    Group_Availability VARCHAR2(50),
    Group_Size_Limits VARCHAR2(50),
    Pricing NUMBER CHECK (Pricing >= 0),
    Service_Provider_ID VARCHAR2(20) REFERENCES Dg_Service_Provider(Service_Provider_ID),
    Schedule_ID VARCHAR2(20) REFERENCES Dg_Availability_Schedule(Schedule_ID)
);

-- Creating the Dg_Experience_Tags table
CREATE TABLE Dg_Experience_Tags (
    Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
    Tag VARCHAR2(50),
    PRIMARY KEY (Experience_ID, Tag)
);

-- Creating the Dg_Bookings table
CREATE TABLE Dg_Bookings (
    Booking_ID VARCHAR2(20) PRIMARY KEY,
    Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
    Date_Of_Booking DATE NOT NULL,
    Experience_Date DATE NOT NULL,
    Amount_Paid NUMBER NOT NULL CHECK (Amount_Paid >= 0),
    Status VARCHAR2(20),
    Booking_Method VARCHAR2(50),
    Payment_Status VARCHAR2(20) DEFAULT 'Pending' -- Default payment status to 'Pending'
);

-- Creating the Dg_Ratings table
CREATE TABLE Dg_Ratings (
    Rating_ID VARCHAR2(20) PRIMARY KEY,
    Traveler_ID VARCHAR2(20) REFERENCES Dg_Travelers(T_ID),
    Experience_ID VARCHAR2(20) REFERENCES Dg_Experience(Experience_ID),
    Rating_Value NUMBER CHECK (Rating_Value BETWEEN 1 AND 10),
    Review_Date_Time TIMESTAMP DEFAULT SYSDATE, -- Automatically set review date to current date
    Feedback VARCHAR2(500),
    Review_Title VARCHAR2(100)
);