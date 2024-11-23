USE DB2_covid_studies;

-- Drop the Conditions table if it exists and create it with extracted XML data
IF OBJECT_ID('dbo.Conditions', 'U') IS NOT NULL
    DROP TABLE dbo.Conditions;

-- Table for conditions and diseases that are the focus of each clinical study
SELECT
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    condition.value('.', 'NVARCHAR(255)') AS Condition
INTO Conditions
FROM ClinicalStudies
CROSS APPLY StudyXML.nodes('//condition') AS C(condition);

--verify
SELECT TOP 10 * FROM Conditions;