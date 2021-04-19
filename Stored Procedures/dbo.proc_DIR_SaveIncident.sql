SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_DIR_SaveIncident]

(		
		@DriverIntId INT,
		@IncidentDate DATETIME,
		@IncidentTypeID SMALLINT,
		@IncidentDetails VARCHAR(MAX)
		
		)
AS
BEGIN





--DECLARE	@IncidentID INT,
--		@DriverIntId INT,
--		@IncidentDate DATETIME,
--		@IncidentTypeID INT,
--		@IncidentDetails VARCHAR(max)

--SET @DriverIntId = 5900
--SET @IncidentDate = '2020-12-01 00:00'
--SET @IncidentTypeID = 2
--SET @IncidentDetails = '2|Pisa|5|Medium|6|Tower Leaning heavily'
DECLARE	@IncidentID INT
	INSERT INTO dbo.DIR_Incident
	(
	    DriverIntId,
	    IncidentDate,
	    IncidentTypeId,
	    Archived,
	    LastOperation
	)
	VALUES
	(   @driverIntId,         -- DriverIntId - int
	    @IncidentDate, -- IncidentDate - datetime
	    @IncidentTypeID,         -- IncidentTypeId - smallint
	    0,      -- Archived - bit
	    GETDATE()  -- LastOperation - datetime
	    )


SELECT @IncidentID = SCOPE_IDENTITY()




INSERT INTO dbo.DIR_IncidentDetail
(
    IncidentID,
    IncidentFieldID,
    Contents
)
SELECT @IncidentID,odd.Value,even.Value
FROM dbo.Split(@IncidentDetails,'|') odd 
INNER JOIN dbo.Split(@IncidentDetails,'|') even ON even.Id = odd.Id + 1
WHERE (odd.ID % 2) <> 0

SELECT @IncidentID

END







GO
