SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Reporting table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Reporting_Insert]
(

	@ReportingId bigint    OUTPUT,

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


				
				INSERT INTO [dbo].[Reporting]
					(
					[VehicleIntId]
					,[DriverIntId]
					,[InSweetSpotDistance]
					,[FueledOverRPMDistance]
					,[TopGearDistance]
					,[CruiseControlDistance]
					,[CoastInGearDistance]
					,[IdleTime]
					,[TotalTime]
					,[EngineBrakeDistance]
					,[ServiceBrakeDistance]
					,[EngineBrakeOverRPMDistance]
					,[ROPCount]
					,[OverSpeedDistance]
					,[CoastOutOfGearDistance]
					,[PanicStopCount]
					,[TotalFuel]
					,[TimeNoID]
					,[TimeID]
					,[DrivingDistance]
					,[PTOMovingDistance]
					,[Date]
					,[Rows]
					,[DrivingFuel]
					,[PTOMovingTime]
					,[PTOMovingFuel]
					,[PTONonMovingTime]
					,[PTONonMovingFuel]
					,[DigitalInput2Count]
					,[RouteID]
					,[PassengerComfort]
					)
				VALUES
					(
					@VehicleIntId
					,@DriverIntId
					,@InSweetSpotDistance
					,@FueledOverRpmDistance
					,@TopGearDistance
					,@CruiseControlDistance
					,@CoastInGearDistance
					,@IdleTime
					,@TotalTime
					,@EngineBrakeDistance
					,@ServiceBrakeDistance
					,@EngineBrakeOverRpmDistance
					,@RopCount
					,@OverSpeedDistance
					,@CoastOutOfGearDistance
					,@PanicStopCount
					,@TotalFuel
					,@TimeNoId
					,@TimeId
					,@DrivingDistance
					,@PtoMovingDistance
					,@Date
					,@Rows
					,@DrivingFuel
					,@PtoMovingTime
					,@PtoMovingFuel
					,@PtoNonMovingTime
					,@PtoNonMovingFuel
					,@DigitalInput2Count
					,@RouteId
					,@PassengerComfort
					)
				
				-- Get the identity value
				SET @ReportingId = SCOPE_IDENTITY()
									
							
			


GO
