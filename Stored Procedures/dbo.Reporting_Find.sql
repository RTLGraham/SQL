SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Reporting table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Reporting_Find]
(

	@SearchUsingOR bit   = null ,

	@ReportingId bigint   = null ,

	@VehicleIntId int   = null ,

	@DriverIntId int   = null ,

	@InSweetSpotDistance float   = null ,

	@FueledOverRpmDistance float   = null ,

	@TopGearDistance float   = null ,

	@CruiseControlDistance float   = null ,

	@CoastInGearDistance float   = null ,

	@IdleTime int   = null ,

	@TotalTime int   = null ,

	@EngineBrakeDistance float   = null ,

	@ServiceBrakeDistance float   = null ,

	@EngineBrakeOverRpmDistance float   = null ,

	@RopCount int   = null ,

	@OverSpeedDistance float   = null ,

	@CoastOutOfGearDistance float   = null ,

	@PanicStopCount int   = null ,

	@TotalFuel float   = null ,

	@TimeNoId float   = null ,

	@TimeId float   = null ,

	@DrivingDistance float   = null ,

	@PtoMovingDistance float   = null ,

	@Date smalldatetime   = null ,

	@Rows int   = null ,

	@DrivingFuel float   = null ,

	@PtoMovingTime int   = null ,

	@PtoMovingFuel float   = null ,

	@PtoNonMovingTime int   = null ,

	@PtoNonMovingFuel float   = null ,

	@DigitalInput2Count int   = null ,

	@RouteId int   = null ,

	@PassengerComfort float   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [ReportingId]
	, [VehicleIntId]
	, [DriverIntId]
	, [InSweetSpotDistance]
	, [FueledOverRPMDistance]
	, [TopGearDistance]
	, [CruiseControlDistance]
	, [CoastInGearDistance]
	, [IdleTime]
	, [TotalTime]
	, [EngineBrakeDistance]
	, [ServiceBrakeDistance]
	, [EngineBrakeOverRPMDistance]
	, [ROPCount]
	, [OverSpeedDistance]
	, [CoastOutOfGearDistance]
	, [PanicStopCount]
	, [TotalFuel]
	, [TimeNoID]
	, [TimeID]
	, [DrivingDistance]
	, [PTOMovingDistance]
	, [Date]
	, [Rows]
	, [DrivingFuel]
	, [PTOMovingTime]
	, [PTOMovingFuel]
	, [PTONonMovingTime]
	, [PTONonMovingFuel]
	, [DigitalInput2Count]
	, [RouteID]
	, [PassengerComfort]
    FROM
	[dbo].[Reporting]
    WHERE 
	 ([ReportingId] = @ReportingId OR @ReportingId IS NULL)
	AND ([VehicleIntId] = @VehicleIntId OR @VehicleIntId IS NULL)
	AND ([DriverIntId] = @DriverIntId OR @DriverIntId IS NULL)
	AND ([InSweetSpotDistance] = @InSweetSpotDistance OR @InSweetSpotDistance IS NULL)
	AND ([FueledOverRPMDistance] = @FueledOverRpmDistance OR @FueledOverRpmDistance IS NULL)
	AND ([TopGearDistance] = @TopGearDistance OR @TopGearDistance IS NULL)
	AND ([CruiseControlDistance] = @CruiseControlDistance OR @CruiseControlDistance IS NULL)
	AND ([CoastInGearDistance] = @CoastInGearDistance OR @CoastInGearDistance IS NULL)
	AND ([IdleTime] = @IdleTime OR @IdleTime IS NULL)
	AND ([TotalTime] = @TotalTime OR @TotalTime IS NULL)
	AND ([EngineBrakeDistance] = @EngineBrakeDistance OR @EngineBrakeDistance IS NULL)
	AND ([ServiceBrakeDistance] = @ServiceBrakeDistance OR @ServiceBrakeDistance IS NULL)
	AND ([EngineBrakeOverRPMDistance] = @EngineBrakeOverRpmDistance OR @EngineBrakeOverRpmDistance IS NULL)
	AND ([ROPCount] = @RopCount OR @RopCount IS NULL)
	AND ([OverSpeedDistance] = @OverSpeedDistance OR @OverSpeedDistance IS NULL)
	AND ([CoastOutOfGearDistance] = @CoastOutOfGearDistance OR @CoastOutOfGearDistance IS NULL)
	AND ([PanicStopCount] = @PanicStopCount OR @PanicStopCount IS NULL)
	AND ([TotalFuel] = @TotalFuel OR @TotalFuel IS NULL)
	AND ([TimeNoID] = @TimeNoId OR @TimeNoId IS NULL)
	AND ([TimeID] = @TimeId OR @TimeId IS NULL)
	AND ([DrivingDistance] = @DrivingDistance OR @DrivingDistance IS NULL)
	AND ([PTOMovingDistance] = @PtoMovingDistance OR @PtoMovingDistance IS NULL)
	AND ([Date] = @Date OR @Date IS NULL)
	AND ([Rows] = @Rows OR @Rows IS NULL)
	AND ([DrivingFuel] = @DrivingFuel OR @DrivingFuel IS NULL)
	AND ([PTOMovingTime] = @PtoMovingTime OR @PtoMovingTime IS NULL)
	AND ([PTOMovingFuel] = @PtoMovingFuel OR @PtoMovingFuel IS NULL)
	AND ([PTONonMovingTime] = @PtoNonMovingTime OR @PtoNonMovingTime IS NULL)
	AND ([PTONonMovingFuel] = @PtoNonMovingFuel OR @PtoNonMovingFuel IS NULL)
	AND ([DigitalInput2Count] = @DigitalInput2Count OR @DigitalInput2Count IS NULL)
	AND ([RouteID] = @RouteId OR @RouteId IS NULL)
	AND ([PassengerComfort] = @PassengerComfort OR @PassengerComfort IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [ReportingId]
	, [VehicleIntId]
	, [DriverIntId]
	, [InSweetSpotDistance]
	, [FueledOverRPMDistance]
	, [TopGearDistance]
	, [CruiseControlDistance]
	, [CoastInGearDistance]
	, [IdleTime]
	, [TotalTime]
	, [EngineBrakeDistance]
	, [ServiceBrakeDistance]
	, [EngineBrakeOverRPMDistance]
	, [ROPCount]
	, [OverSpeedDistance]
	, [CoastOutOfGearDistance]
	, [PanicStopCount]
	, [TotalFuel]
	, [TimeNoID]
	, [TimeID]
	, [DrivingDistance]
	, [PTOMovingDistance]
	, [Date]
	, [Rows]
	, [DrivingFuel]
	, [PTOMovingTime]
	, [PTOMovingFuel]
	, [PTONonMovingTime]
	, [PTONonMovingFuel]
	, [DigitalInput2Count]
	, [RouteID]
	, [PassengerComfort]
    FROM
	[dbo].[Reporting]
    WHERE 
	 ([ReportingId] = @ReportingId AND @ReportingId is not null)
	OR ([VehicleIntId] = @VehicleIntId AND @VehicleIntId is not null)
	OR ([DriverIntId] = @DriverIntId AND @DriverIntId is not null)
	OR ([InSweetSpotDistance] = @InSweetSpotDistance AND @InSweetSpotDistance is not null)
	OR ([FueledOverRPMDistance] = @FueledOverRpmDistance AND @FueledOverRpmDistance is not null)
	OR ([TopGearDistance] = @TopGearDistance AND @TopGearDistance is not null)
	OR ([CruiseControlDistance] = @CruiseControlDistance AND @CruiseControlDistance is not null)
	OR ([CoastInGearDistance] = @CoastInGearDistance AND @CoastInGearDistance is not null)
	OR ([IdleTime] = @IdleTime AND @IdleTime is not null)
	OR ([TotalTime] = @TotalTime AND @TotalTime is not null)
	OR ([EngineBrakeDistance] = @EngineBrakeDistance AND @EngineBrakeDistance is not null)
	OR ([ServiceBrakeDistance] = @ServiceBrakeDistance AND @ServiceBrakeDistance is not null)
	OR ([EngineBrakeOverRPMDistance] = @EngineBrakeOverRpmDistance AND @EngineBrakeOverRpmDistance is not null)
	OR ([ROPCount] = @RopCount AND @RopCount is not null)
	OR ([OverSpeedDistance] = @OverSpeedDistance AND @OverSpeedDistance is not null)
	OR ([CoastOutOfGearDistance] = @CoastOutOfGearDistance AND @CoastOutOfGearDistance is not null)
	OR ([PanicStopCount] = @PanicStopCount AND @PanicStopCount is not null)
	OR ([TotalFuel] = @TotalFuel AND @TotalFuel is not null)
	OR ([TimeNoID] = @TimeNoId AND @TimeNoId is not null)
	OR ([TimeID] = @TimeId AND @TimeId is not null)
	OR ([DrivingDistance] = @DrivingDistance AND @DrivingDistance is not null)
	OR ([PTOMovingDistance] = @PtoMovingDistance AND @PtoMovingDistance is not null)
	OR ([Date] = @Date AND @Date is not null)
	OR ([Rows] = @Rows AND @Rows is not null)
	OR ([DrivingFuel] = @DrivingFuel AND @DrivingFuel is not null)
	OR ([PTOMovingTime] = @PtoMovingTime AND @PtoMovingTime is not null)
	OR ([PTOMovingFuel] = @PtoMovingFuel AND @PtoMovingFuel is not null)
	OR ([PTONonMovingTime] = @PtoNonMovingTime AND @PtoNonMovingTime is not null)
	OR ([PTONonMovingFuel] = @PtoNonMovingFuel AND @PtoNonMovingFuel is not null)
	OR ([DigitalInput2Count] = @DigitalInput2Count AND @DigitalInput2Count is not null)
	OR ([RouteID] = @RouteId AND @RouteId is not null)
	OR ([PassengerComfort] = @PassengerComfort AND @PassengerComfort is not null)
	SELECT @@ROWCOUNT			
  END
				


GO
