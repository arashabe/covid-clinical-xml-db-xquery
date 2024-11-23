-- Switch to the new database
USE DB2_covid_studies;
GO
--Verify the data load:
SELECT COUNT(*) AS TotalRecords FROM ClinicalStudies;


GO


--Extract study name and status:

SELECT 
    StudyXML.value('(/clinical_study/official_title)[1]', 'NVARCHAR(MAX)') AS StudyTitle,
    StudyXML.value('(/clinical_study/overall_status)[1]', 'NVARCHAR(MAX)') AS StudyStatus
FROM 
    ClinicalStudies;

GO
--Extract conditions and researchers

SELECT 
    StudyXML.value('(/clinical_study/condition)[1]', 'NVARCHAR(MAX)') AS Condition,
    StudyXML.value('(/clinical_study/overall_official/last_name)[1]', 'NVARCHAR(MAX)') AS InvestigatorLastName,
    StudyXML.value('(/clinical_study/overall_official/role)[1]', 'NVARCHAR(MAX)') AS InvestigatorRole
FROM 
    ClinicalStudies;

GO
--Filter studies based on conditions


SELECT 
    StudyXML.value('(/clinical_study/official_title)[1]', 'NVARCHAR(MAX)') AS StudyTitle,
    StudyXML.value('(/clinical_study/overall_status)[1]', 'NVARCHAR(MAX)') AS StudyStatus
FROM 
    ClinicalStudies
WHERE 
    StudyXML.exist('/clinical_study/condition[text()="COVID-19"]') = 1;

GO



--Update XML data

DECLARE @newStatus NVARCHAR(MAX) = 'Completed';
DECLARE @studyId NVARCHAR(50) = 'NCT00571389'; 

UPDATE ClinicalStudies
SET StudyXML.modify('replace value of (/clinical_study/overall_status/text())[1] with sql:variable("@newStatus")')
WHERE StudyXML.exist('/clinical_study/nct_id[text()=sql:variable("@studyId")]') = 1; -- Change to the ID of the study we want to update.




GO
--Example query

SELECT 
    StudyXML.value('(/clinical_study/id_info/nct_id)[1]', 'NVARCHAR(MAX)') AS StudyID,
    StudyXML.value('(/clinical_study/official_title)[1]', 'NVARCHAR(MAX)') AS StudyTitle,
    StudyXML.value('(/clinical_study/overall_status)[1]', 'NVARCHAR(MAX)') AS StudyStatus,
    StudyXML.value('(/clinical_study/start_date)[1]', 'NVARCHAR(MAX)') AS StartDate,
    StudyXML.value('(/clinical_study/completion_date)[1]', 'NVARCHAR(MAX)') AS CompletionDate
FROM 
    ClinicalStudies

WHERE 
    StudyXML.value('(/clinical_study/completion_date)[1]', 'NVARCHAR(MAX)') IS NULL
    AND StudyXML.value('(/clinical_study/start_date)[1]', 'NVARCHAR(MAX)') = 'March 15, 2011';