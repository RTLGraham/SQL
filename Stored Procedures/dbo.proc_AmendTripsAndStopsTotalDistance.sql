SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_AmendTripsAndStopsTotalDistance]
    (
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
            @oldtripdistance = LastPointTotalDistance
    FROM    TripsAndStopsState
    WHERE   vehicleid = @vehicleid
    IF @oldtripdistance IS NOT NULL 
        BEGIN
            IF @oldtripdistance < @tripdistance 
                BEGIN
                    UPDATE  dbo.TripsAndStopsState
                    SET     LastPointTotalDistance = @TripDistance
                    WHERE   VehicleID = @VehicleID
                            AND ( Archived = 0
                                  OR Archived IS NULL
                                )
                END
        END

GO
