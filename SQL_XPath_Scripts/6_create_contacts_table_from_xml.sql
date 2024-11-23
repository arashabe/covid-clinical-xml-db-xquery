USE DB2_covid_studies;

-- Drop the Contacts table if it exists
IF OBJECT_ID('dbo.Contacts', 'U') IS NOT NULL
    DROP TABLE dbo.Contacts;

-- Extract contact information, explicitly setting all fields as NVARCHAR
SELECT
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    overall_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
    overall_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
    overall_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
INTO Contacts
FROM ClinicalStudies
CROSS APPLY StudyXML.nodes('//overall_contact') AS OC(overall_contact);

-- Insert contact information from location/contact node with explicit NVARCHAR for PhoneExt
INSERT INTO Contacts (StudyID, LastName, Phone, Email)
SELECT
    StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
    location_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
    location_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
    location_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
FROM ClinicalStudies
CROSS APPLY StudyXML.nodes('//location/contact') AS LC(location_contact);


SELECT TOP 50 * FROM Contacts where phone is not null;
