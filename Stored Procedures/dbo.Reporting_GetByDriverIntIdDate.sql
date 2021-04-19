SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Reporting table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Reporting_GetByDriverIntIdDate]
(

	@DriverIntId int   ,

	@Date smalldatetime   
)
AS


				SELECT
					[ReportingId],
					[VehicleIntId],
					[DriverIntId],
					[InSweetSpotDistance],
					[FueledOverRPMDistance],
					[TopGearDistance],
					[CruiseControlDistance],
					[CoastInGearDistance],
					[IdleTime],
					[TotalTime],
					[EngineBrakeDistance],
					[ServiceBrakeDistance],
					[EngineBrakeOverRPMDistance],
					[ROPCount],
					[OverSpeedDistance],
					[CoastOutOfGearDistance],
					[PanicStopCount],
					[TotalFuel],
					[TimeNoID],
					[TimeID],
					[DrivingDistance],
					[PTOMovingDistance],
					[Date],
					[Rows],
					[DrivingFuel],
					[PTOMovingTime],
					[PTOMovingFuel],
					[PTONonMovingTime],
					[PTONonMovingFuel],
					[DigitalInput2Count],
					[RouteID],
					[PassengerComfort]
				FROM
					[dbo].[Reporting]
				WHERE
					[DriverIntId] = @DriverIntId
					AND [Date] = @Date
				SELECT @@ROWCOUNT
					
			


GO
