USE DB2_covid_studies;

-- Drop the Studies table if it exists and create it with extracted XML data
IF OBJECT_ID('dbo.Studies', 'U') IS NOT NULL
    DROP TABLE dbo.Studies;
    
-- Table for general information about clinical studies
SELECT 
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    StudyXML.value('(//org_study_id)[1]', 'NVARCHAR(50)') AS OrgStudyID,
    StudyXML.value('(//brief_title)[1]', 'NVARCHAR(500)') AS BriefTitle,
    StudyXML.value('(//official_title)[1]', 'NVARCHAR(1000)') AS OfficialTitle,
    StudyXML.value('(//overall_status)[1]', 'NVARCHAR(50)') AS Status,
    StudyXML.value('(//study_type)[1]', 'NVARCHAR(50)') AS StudyType,
    TRY_CAST(StudyXML.value('(//start_date)[1]', 'NVARCHAR(50)') AS DATE) AS StartDate,
    TRY_CAST(StudyXML.value('(//completion_date)[1]', 'NVARCHAR(50)') AS DATE) AS CompletionDate,
    TRY_CAST(StudyXML.value('(//primary_completion_date)[1]', 'NVARCHAR(50)') AS DATE) AS PrimaryCompletionDate
INTO Studies
FROM ClinicalStudies;

--verify
SELECT TOP 10 * FROM Studies;