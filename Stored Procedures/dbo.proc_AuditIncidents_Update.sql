SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_AuditIncidents_Update] 
	@EventId BIGINT,
	@IncidentId BIGINT,
	@VehicleIntId INT,
	@Lat FLOAT,
	@Long FLOAT,
	@Speed SMALLINT,
	@Heading SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.CAM_IncidentRecovery
	        ( EventId ,
	          IncidentId ,
	          VehicleIntId ,
	          Lat ,
	          Long ,
	          Speed ,
	          Heading
	        )
	VALUES  ( @EventId, @IncidentId, @VehicleIntId, @Lat, @Long, @Speed, @Heading )

END

GO
