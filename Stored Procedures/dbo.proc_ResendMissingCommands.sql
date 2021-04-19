SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ResendMissingCommands]
AS

-- Declare some variables that can be tweaked
DECLARE @timedelay INT, -- number of minutes to wait before resending command, plus
		@eventcount INT -- number of events to check for once time delay elapsed
SET @timedelay = 10
SET @eventcount = 5

-- Create temporary table to hold list of commands to be resent
DECLARE @commands TABLE	(CommandId INT, EventCount INT)

-- Identify the commands which should have been received by the unit but which have not, and store in the @commands table

-- First handle Cheetah units
--> Needs additional check against date software was upgraded to 1.4.147 or above
INSERT INTO @commands (CommandId, EventCount)
SELECT vc.CommandId, COUNT(*)
FROM dbo.VehicleCommand vc
INNER JOIN dbo.IVH i ON i.IVHId = vc.IVHId
INNER JOIN dbo.Vehicle v ON v.IVHId = vc.IVHId
INNER JOIN dbo.Event e ON e.VehicleIntId = v.VehicleIntId AND e.EventDateTime > DATEADD(mi, @timedelay, dbo.TZ_ToUtc(vc.AcknowledgedDate,'GMT Time',NULL))
WHERE vc.ReceivedDate IS NULL -- command not received by unit
  AND vc.AcknowledgedDate > DATEADD(dd, -4, GETDATE()) -- commands sent within the last 4 days
  AND vc.AcknowledgedDate > i.Firmware147Date -- command sent after upgrade to firmware 1.4.147
  AND vc.ExpiryDate > GETDATE() -- command has not expired
  AND vc.Archived = 0
  AND (CAST(vc.Command AS VARCHAR(1024)) LIKE '#WRITE%' -- commands of type #WRITE
		OR CAST(vc.Command AS VARCHAR(1024)) LIKE '#ACTION%' -- commands of type #ACTION
		OR CAST(vc.Command AS VARCHAR(1024)) LIKE '>STCXAT%') -- commands of type >STCXAT
  AND CAST(vc.Command AS VARCHAR(1024)) NOT LIKE '%+RTLE%' -- RTLE commands should NOT be resent
  AND CAST(vc.Command AS VARCHAR(1024)) NOT LIKE '%+DBGX%' -- DBGX commands should NOT be resent
  AND i.IVHTypeId = 5 -- cheetah units
	AND ((CASE WHEN ISNUMERIC(dbo.fnParseString(3,'.',i.FirmwareVersion) + '.e0') = 1 AND LEN(i.FirmwareVersion) < 12 THEN CAST(dbo.fnParseString(3,'.',i.FirmwareVersion) AS BIGINT) ELSE 0 END >= 147 
	AND CASE WHEN ISNUMERIC(dbo.fnParseString(2,'.',i.FirmwareVersion) + '.e0') = 1 AND LEN(i.FirmwareVersion) < 12 THEN CAST(dbo.fnParseString(2,'.',i.FirmwareVersion) AS BIGINT) ELSE 0 END = 4) 
		OR CASE WHEN ISNUMERIC(dbo.fnParseString(2,'.',i.FirmwareVersion) + '.e0') = 1 AND LEN(i.FirmwareVersion) < 12 THEN CAST(dbo.fnParseString(2,'.',i.FirmwareVersion) AS BIGINT) ELSE 0 END > 4) -- firmware version >= 1.4.147	
GROUP BY vc.CommandId
HAVING COUNT(*) > @eventcount -- have received at least this many events since timedelay elapsed after command sent

-- Now handle A9/A11 units
INSERT INTO @commands (CommandId, EventCount)
SELECT vc.CommandId, COUNT(*)
FROM dbo.VehicleCommand vc
INNER JOIN dbo.IVH i ON i.IVHId = vc.IVHId
INNER JOIN dbo.Vehicle v ON v.IVHId = vc.IVHId
INNER JOIN dbo.Event e ON e.VehicleIntId = v.VehicleIntId AND e.EventDateTime > DATEADD(mi, @timedelay, dbo.TZ_ToUtc(vc.AcknowledgedDate,'GMT Time',NULL))
WHERE vc.ReceivedDate IS NULL -- command not received by unit
  AND vc.AcknowledgedDate > DATEADD(dd, -4, GETDATE()) -- commands sent within the last 4 days
  AND vc.ExpiryDate > GETDATE() -- command has not expired
  AND vc.Archived = 0
  AND CAST(vc.Command AS VARCHAR(1024)) NOT LIKE '%OTAP%' -- OTAP commands should NOT be resent
  AND CAST(vc.Command AS VARCHAR(1024)) NOT LIKE '%REBOOT%' -- REBOOT commands should NOT be resent
  AND i.IVHTypeId IN (8, 9) -- A9 / A11 units
  --AND i.IsDev = 1 -- for testing, limit to Dev units only  put into production 19/11/2019
GROUP BY vc.CommandId
HAVING COUNT(*) > @eventcount -- have received at least this many events since timedelay elapsed after command sent

-- Resend the commands by issuing a new command. No need to worry about continually resend as we only resend if a unit has responded with events (see above)
-- Use SELECT DISTINCT so that only one of the same command will ever be resent
INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived, ProcessInd, ReceivedDate)
SELECT DISTINCT vc.IVHId,
       vc.Command,
       DATEADD(dd, 1, GETDATE()),
       NULL,
       GETDATE(),
       0,
       NULL,
       NULL
FROM dbo.VehicleCommand vc
INNER JOIN @commands c ON c.CommandId = vc.CommandId
INNER JOIN dbo.Vehicle v ON v.IVHId = vc.IVHId

-- Mark the original commands as resent by setting the ReceivedDate to '2099-12-31'
UPDATE dbo.VehicleCommand
SET ReceivedDate = '2099-12-31'
FROM dbo.VehicleCommand vc
INNER JOIN @commands c ON c.CommandId = vc.CommandId





GO
