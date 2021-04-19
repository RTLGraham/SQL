SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_WriteTescoIncident]
(
	@TescoRecordType INT,
	@DriverId UNIQUEIDENTIFIER,
	@VehicleId UNIQUEIDENTIFIER = NULL,
	@QuickNumber INT = NULL,
	@Reference VARCHAR(50) = NULL,
	@IncidentType VARCHAR(30) = NULL,
	@IncidentDateTime DATETIME = NULL,
	@ReportedDateTime DATETIME = NULL,
	@ARBGrade SMALLINT = NULL, 
	@ARBDate SMALLDATETIME = NULL,
	@Description NVARCHAR(MAX) = NULL,
	@Outcome NVARCHAR(MAX) = NULL,
	@DriverTrainer NVARCHAR(1024) = NULL,
	@TrainingActionedDate SMALLDATETIME = NULL,
	@RoadSpeedLimit SMALLINT = NULL,
	@Speed SMALLINT = NULL,
	@TPApproxSpeed SMALLINT = NULL,
	@RoadWidth  SMALLINT = NULL,
	@RoadType  VARCHAR(30) = NULL,
	@TPLocation NVARCHAR(1024) = NULL,
	@ParkingLocation NVARCHAR(1024) = NULL,
	@PayloadDoors NVARCHAR(100) = NULL,
	@Visibility NVARCHAR(100) = NULL,
	@Weather NVARCHAR(100) = NULL,
	@OtherInformation NVARCHAR(MAX) = NULL,
	@TPWitnessComments NVARCHAR(MAX) = NULL,
	@DSCMNextSteps NVARCHAR(MAX) = NULL,
	@Notes NVARCHAR(MAX) = NULL,
	@CreatedBy UNIQUEIDENTIFIER
)
AS
	DECLARE @incidentId INT,
			@vehicleintid INT

	--Identify vehicle if known
	SELECT @vehicleintid = VehicleIntId
	FROM dbo.Vehicle
	WHERE VehicleId = @VehicleId

	INSERT INTO dbo.TescoIncident
	        ( TescoRecordType,
	          DriverIntId,
	          VehicleIntId,
	          QuickNumber,
	          Reference,
	          IncidentType,
	          IncidentDateTime,
	          ReportedDateTime,
	          ARBGrade,
	          ARBDate,
	          [Description],
	          Outcome,
	          DriverTrainer,
	          TrainingActionedDate,
	          RoadSpeedLimit,
	          Speed,
	          TPApproxSpeed,
	          RoadWidth,
	          RoadType,
	          TPLocation,
	          ParkingLocation,
	          PayloadDoors,
	          Visibility,
	          Weather,
	          OtherInformation,
	          TPWitnessComments,
	          DSCMNextSteps,
	          Notes,
	          CreatedBy
	        )

	SELECT @TescoRecordType,
           d.DriverIntId,
		   @vehicleintid,
           @QuickNumber,
           @Reference,
           @IncidentType,
           @IncidentDateTime,
           @ReportedDateTime,
           @ARBGrade,
           @ARBDate,
           @Description,
           @Outcome,
           @DriverTrainer,
           @TrainingActionedDate,
           @RoadSpeedLimit,
           @Speed,
           @TPApproxSpeed,
           @RoadWidth,
           @RoadType,
           @TPLocation,
           @ParkingLocation,
           @PayloadDoors,
           @Visibility,
           @Weather,
           @OtherInformation,
           @TPWitnessComments,
           @DSCMNextSteps,
           @Notes,
           @CreatedBy
	FROM dbo.Driver d
	WHERE d.DriverId = @DriverId

	SELECT @incidentId = SCOPE_IDENTITY()

GO
