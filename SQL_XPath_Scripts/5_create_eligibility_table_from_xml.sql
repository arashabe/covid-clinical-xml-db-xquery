USE DB2_covid_studies;

-- Drop the Eligibility table if it exists and create it with extracted XML data
IF OBJECT_ID('dbo.Eligibility', 'U') IS NOT NULL
    DROP TABLE dbo.Eligibility;

-- Table for eligibility criteria for participants in each clinical study
SELECT
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    StudyXML.value('(//eligibility/gender)[1]', 'NVARCHAR(10)') AS Gender,
    StudyXML.value('(//eligibility/minimum_age)[1]', 'NVARCHAR(20)') AS MinimumAge,
    StudyXML.value('(//eligibility/maximum_age)[1]', 'NVARCHAR(20)') AS MaximumAge,
    StudyXML.value('(//eligibility/healthy_volunteers)[1]', 'NVARCHAR(50)') AS HealthyVolunteers,
    StudyXML.value('(//eligibility/criteria/textblock)[1]', 'NVARCHAR(MAX)') AS CriteriaText
INTO Eligibility
FROM ClinicalStudies;


--verify
SELECT TOP 10 * FROM Eligibility;