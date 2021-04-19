SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Reporting table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Reporting_Update]
(

	@ReportingId bigint   ,

	@VehicleIntId int   ,

	@DriverIntId int   ,

	@InSweetSpotDistance float   ,

	@FueledOverRpmDistance float   ,

	@TopGearDistance float   ,

	@CruiseControlDistance float   ,

	@CoastInGearDistance float   ,

	@IdleTime int   ,

	@TotalTime int   ,

	@EngineBrakeDistance float   ,

	@ServiceBrakeDistance float   ,

	@EngineBrakeOverRpmDistance float   ,

	@RopCount int   ,

	@OverSpeedDistance float   ,

	@CoastOutOfGearDistance float   ,

	@PanicStopCount int   ,

	@TotalFuel float   ,

	@TimeNoId float   ,

	@TimeId float   ,

	@DrivingDistance float   ,

	@PtoMovingDistance float   ,

	@Date smalldatetime   ,

	@Rows int   ,

	@DrivingFuel float   ,

	@PtoMovingTime int   ,

	@PtoMovingFuel float   ,

	@PtoNonMovingTime int   ,

	@PtoNonMovingFuel float   ,

	@DigitalInput2Count int   ,

	@RouteId int   ,

	@PassengerComfort float   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Reporting]
				SET
					[VehicleIntId] = @VehicleIntId
					,[DriverIntId] = @DriverIntId
					,[InSweetSpotDistance] = @InSweetSpotDistance
					,[FueledOverRPMDistance] = @FueledOverRpmDistance
					,[TopGearDistance] = @TopGearDistance
					,[CruiseControlDistance] = @CruiseControlDistance
					,[CoastInGearDistance] = @CoastInGearDistance
					,[IdleTime] = @IdleTime
					,[TotalTime] = @TotalTime
					,[EngineBrakeDistance] = @EngineBrakeDistance
					,[ServiceBrakeDistance] = @ServiceBrakeDistance
					,[EngineBrakeOverRPMDistance] = @EngineBrakeOverRpmDistance
					,[ROPCount] = @RopCount
					,[OverSpeedDistance] = @OverSpeedDistance
					,[CoastOutOfGearDistance] = @CoastOutOfGearDistance
					,[PanicStopCount] = @PanicStopCount
					,[TotalFuel] = @TotalFuel
					,[TimeNoID] = @TimeNoId
					,[TimeID] = @TimeId
					,[DrivingDistance] = @DrivingDistance
					,[PTOMovingDistance] = @PtoMovingDistance
					,[Date] = @Date
					,[Rows] = @Rows
					,[DrivingFuel] = @DrivingFuel
					,[PTOMovingTime] = @PtoMovingTime
					,[PTOMovingFuel] = @PtoMovingFuel
					,[PTONonMovingTime] = @PtoNonMovingTime
					,[PTONonMovingFuel] = @PtoNonMovingFuel
					,[DigitalInput2Count] = @DigitalInput2Count
					,[RouteID] = @RouteId
					,[PassengerComfort] = @PassengerComfort
				WHERE
[ReportingId] = @ReportingId 
				
			


GO
