-----------------Restore the database from the backup file----------------

USE master;
GO

-- Restore the database from the backup file
RESTORE DATABASE [DB2_covid_studies]
FROM DISK = 'J:\Backups\DB2_covid_studies_20241125.bak' --example bak file 
WITH REPLACE,  -- Overwrites the existing database
RECOVERY;
GO


-----------------Restore the deleted database from the backup file----------------

USE master;
GO

-- Restore the deleted database from the backup file
RESTORE DATABASE [DB2_covid_studies]
FROM DISK = 'J:\Backups\DB2_covid_studies_20241125.bak'
WITH RECOVERY;
GO



