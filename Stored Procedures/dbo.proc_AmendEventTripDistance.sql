SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_AmendEventTripDistance]
    (
      @EventID BIGINT,
      @TripDistance BIGINT,
      @VehicleID UNIQUEIDENTIFIER
    )
AS 
/*
Get the event from the events temp table that corresponds to the data just created
If the distance is not the same as that from the unit then the distance is amended
This procedure is used only for units that report incremental distances only
*/
    DECLARE @oldtripdistance BIGINT
    DECLARE @eventdatetime DATETIME
    SELECT TOP 1
            @oldtripdistance = OdoGPS,
            @eventdatetime = EventDateTime
    FROM    dbo.EventTemp
    WHERE   EventId = @eventid
            AND VehicleIntId = dbo.GetVehicleIntFromId(@VehicleID)
    ORDER BY EventDateTime DESC
    
    IF @oldtripdistance < @tripdistance 
    BEGIN
        UPDATE  dbo.EventTemp
        SET     OdoGPS = @TripDistance
        WHERE   EventId = @eventid
                AND VehicleIntId = dbo.GetVehicleIntFromId(@VehicleID)
                AND OdoGPS = @oldtripdistance
                AND EventDateTime = @eventdatetime
    END

GO
