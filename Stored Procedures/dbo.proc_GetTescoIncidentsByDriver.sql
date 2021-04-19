SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_GetTescoIncidentsByDriver]
(
	@did UNIQUEIDENTIFIER,
	@sdate DATETIME = NULL,
	@edate DATETIME = NULL,
	@uid UNIQUEIDENTIFIER
)
AS
--DECLARE @did UNIQUEIDENTIFIER,
--		@sdate DateTime,
--		@edate DateTime,
--		@uid UNIQUEIDENTIFIER

	SELECT d.DriverId,
		   dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
		   ti.IncidentId ,
           ti.TescoRecordType,
           ti.DriverIntId ,
           ti.VehicleIntId ,
           ti.QuickNumber ,
           ti.Reference ,
           ti.IncidentType ,
           ti.IncidentDateTime ,
           ti.ReportedDateTime ,
           ti.ARBGrade ,
           ti.ARBDate ,
           ti.Description ,
           ti.Outcome ,
           ti.DriverTrainer ,
           ti.TrainingActionedDate ,
           ti.RoadSpeedLimit ,
           ti.Speed ,
           ti.TPApproxSpeed ,
           ti.RoadWidth ,
           ti.RoadType ,
           ti.TPLocation ,
           ti.ParkingLocation ,
           ti.PayloadDoors ,
           ti.Visibility ,
           ti.Weather ,
           ti.OtherInformation ,
           ti.TPWitnessComments ,
           ti.DSCMNextSteps ,
           ti.Notes ,
           ti.CreatedBy ,
           ti.ModifiedBy ,
           ti.DeletedDateTime 
	FROM dbo.TescoIncident ti
	INNER JOIN dbo.Driver d ON d.DriverIntId = ti.DriverIntId
	WHERE d.DriverId = @did
	  AND ti.IncidentDateTime BETWEEN ISNULL(@sdate, '1900-01-01 00:00') AND ISNULL(@edate, '2099-12-31 23:59')



GO
