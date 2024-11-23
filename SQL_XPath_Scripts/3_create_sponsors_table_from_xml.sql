USE DB2_covid_studies;

-- Drop the Sponsors table if it exists and create it with extracted XML data
IF OBJECT_ID('dbo.Sponsors', 'U') IS NOT NULL
    DROP TABLE dbo.Sponsors;

-- Table for sponsors related to each clinical study
SELECT
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    sponsor.value('(agency)[1]', 'NVARCHAR(255)') AS Agency,
    sponsor.value('(agency_class)[1]', 'NVARCHAR(50)') AS AgencyClass
INTO Sponsors
FROM ClinicalStudies
CROSS APPLY StudyXML.nodes('//sponsors/lead_sponsor') AS S(sponsor);


--verify
SELECT TOP 10 * FROM Sponsors;