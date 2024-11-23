USE DB2_covid_studies;

-- Drop the Locations table if it exists and create it with extracted XML data
IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL
    DROP TABLE dbo.Locations;

-- Table for locations where the clinical study is being conducted
SELECT
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    location.value('(facility/name)[1]', 'NVARCHAR(255)') AS FacilityName,
    location.value('(facility/address/city)[1]', 'NVARCHAR(100)') AS City,
    location.value('(facility/address/state)[1]', 'NVARCHAR(100)') AS State,
    location.value('(facility/address/country)[1]', 'NVARCHAR(100)') AS Country,
    location.value('(status)[1]', 'NVARCHAR(50)') AS Status
INTO Locations
FROM ClinicalStudies
CROSS APPLY StudyXML.nodes('//location') AS L(location);

--verify
SELECT TOP 10 * FROM Locations;