---start
-- Use the msdb database which is used by SQL Server Agent for scheduling and jobs

USE msdb;
GO

-- Create a new job named 'Backup Complete DB2_covid_studies'
EXEC dbo.sp_add_job
    @job_name = N'Backup Complete DB2_covid_studies';
GO

-- Add a new step to the job which performs the backup operation
EXEC sp_add_jobstep
    @job_name = N'Backup Complete DB2_covid_studies',
    @step_name = N'Execute Backup',
    @subsystem = N'TSQL', -- the step is a T-SQL script
	@command = N'BACKUP DATABASE [DB2_covid_studies] TO DISK = ''J:\Backups\DB2_covid_studies_'' + CONVERT(NVARCHAR, GETDATE(), 112) + ''.bak'' WITH FORMAT, MEDIANAME = ''SQLServerBackups'', NAME = ''Full Backup of DB2_covid_studies'';',
    @retry_attempts = 0, -- Number of retry attempts if the step fails
    @retry_interval = 1; -- Interval between retry attempts in minutes
GO

-- Create a schedule named 'Backup Daily' to run the job daily at 2 AM
EXEC sp_add_schedule
    @schedule_name = N'Backup Daily',
    @freq_type = 4,  -- 4 Specifies a daily schedule -- ex. 8 is weekly -- 16 is monthly
    @freq_interval = 1, -- Frequency interval of 1 day
    @active_start_time = 020000;  -- Start time in HHMMSS format -- 02:00:00 AM
GO

-- Attach the schedule 'Backup Daily' to the job 'Backup Complete DB2_covid_studies'
EXEC sp_attach_schedule
    @job_name = N'Backup Complete DB2_covid_studies',
    @schedule_name = N'Backup Daily';
GO

-- Add the job to the SQL Server Agent on the local server
EXEC sp_add_jobserver
    @job_name = N'Backup Complete DB2_covid_studies',
    @server_name = N'(local)';
GO

---end 




-------------------Managemenet part----------------------------
-----------------Disable the job------------------------

USE msdb;
GO

-- Disable the job named 'Backup Complete DB2_covid_studies'
EXEC sp_update_job
    @job_name = N'Backup Complete DB2_covid_studies',
    @enabled = 0;  -- 0 means disabled
GO

-----------------Enable the job------------------------

USE msdb;
GO

-- Enable the job named 'Backup Complete DB2_covid_studies'
EXEC sp_update_job
    @job_name = N'Backup Complete DB2_covid_studies',
    @enabled = 1;  -- 1 means enabled
GO

-----------------Delete the existing job------------------------

USE msdb;
GO

-- Delete the existing job
EXEC sp_delete_job
    @job_name = N'Backup Complete DB2_covid_studies';
GO

-----------------Verify active Backup jobs------------------------

USE msdb;
GO

SELECT
    name AS JobName,
    enabled AS IsEnabled
FROM
    sysjobs
WHERE
	name like '%Bckup%' AND
    enabled = 1;
GO
