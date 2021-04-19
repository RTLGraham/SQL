SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_WriteTripsAndStopsTemp]
    (
      @vehicleid UNIQUEIDENTIFIER,
      @eventid BIGINT,
      @vehiclestate TINYINT,
      @timestamp SMALLDATETIME,
      @lat FLOAT,
      @long FLOAT,
      @previd BIGINT,
      @duration INT,
      @tripdistance INT,
      @totaldistance BIGINT,
      @currentid BIGINT OUTPUT,
      @broken BIT = 0
    )
AS 

--	INSERT INTO dbo.TripsAndStopsTest
--	        ( vehicleid ,
--	          eventid ,
--	          vehiclestate ,
--	          timestamp ,
--	          lat ,
--	          long ,
--	          previd ,
--	          duration ,
--	          tripdistance ,
--	          totaldistance ,
--	          currentid ,
--	          broken
--	        )
--	VALUES  ( @vehicleid ,
--	          @eventid ,
--	          @vehiclestate ,
--	          @timestamp ,
--	          @lat ,
--	          @long ,
--	          @previd ,
--	          @duration ,
--	          @tripdistance ,
--	          @totaldistance ,
--	          @currentid ,
--	          @broken
--	        )

    DECLARE @IVHID UNIQUEIDENTIFIER
    DECLARE @CustomerIntId INT
    DECLARE @CustomerID UNIQUEIDENTIFIER
    DECLARE @DriverID UNIQUEIDENTIFIER

    SELECT  @IVHID = v.ivhid
    FROM    Vehicle v
            INNER JOIN IVH i ON v.ivhid = i.ivhid
    WHERE   v.archived = 0
            AND i.archived = 0
            AND ( istag IS NULL
                  OR istag = 0
                )
            AND v.vehicleid = @vehicleid

    SELECT  @CustomerId = c.CustomerId,
            @CustomerIntId = c.CustomerIntId
    FROM    CustomerVehicle cv
            INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
    WHERE   cv.archived = 0
            AND enddate IS NULL
            AND VehicleID = @VehicleID
	
	
	--Check for the linked driver
	SET @DriverID = dbo.GetLinkedDriverId(@VehicleID)

	IF @DriverID IS NULL
	BEGIN
		--If there is no linked driver - obtain the driver ID from the driver number
		SELECT  @DriverID = vle.DriverID
		FROM    VehiclelatestEvent vle
				INNER JOIN Vehicle v ON vle.vehicleid = v.vehicleid
		WHERE   v.archived = 0
				AND v.VehicleID = @VehicleID
	END
	
    IF @DriverID IS NULL 
        BEGIN
            SELECT TOP 1
                    @DriverID = d.DriverID
            FROM    CustomerDriver cd
                    INNER JOIN dbo.Driver d ON cd.DriverId = d.DriverId
            WHERE   d.archived = 0
                    AND cd.Archived = 0
                    AND d.Number = 'No Id'
                    AND CustomerId = @CustomerId
            ORDER BY d.LastOperation DESC
        END            
            
    INSERT INTO dbo.TripsAndStopsTemp
            ( EventID ,
              CustomerIntID ,
              IVHIntID ,
              VehicleIntID ,
              DriverIntID ,
              VehicleState ,
              Timestamp ,
              Latitude ,
              Longitude ,
              PreviousID ,
              TripDistance ,
              Duration ,
              Archived ,
              BrokenData
            )          
    VALUES  (
			  @EventID,
              @CustomerIntId,
              dbo.GetIVHIntFromId(@IVHID),
              dbo.GetVehicleIntFromId(@VehicleID),
              dbo.GetDriverIntFromId(@DriverID),            
              @vehiclestate,
              @Timestamp,
              @Lat,
              @Long,
              @PrevID,
              @TripDistance,
              @Duration,
              NULL,
              @Broken
            )
    SET @CurrentID = NULL
--Select @CurrentID = SCOPE_IDENTITY()
    SELECT  @CurrentID = @@IDENTITY

    DECLARE @vc INT
    SELECT  @vc = COUNT(*)
    FROM    TripsAndStopsState
    WHERE   VehicleID = @VehicleID
            AND ( Archived = 0
                  OR Archived IS NULL
                )

    IF @vehiclestate = 0--stationary
        BEGIN
            IF @vc = 0 
                BEGIN
                    INSERT  INTO TripsAndStopsState
                            (
                              MovingState,
                              LastMovingTime,
                              LastMovingTotalDistance,
                              PrevMovingID,
                              VehicleID,
                              Archived,
                              LastPointTotalDistance
                            )
                    VALUES  (
                              0,
                              @Timestamp,
                              @TotalDistance,
                              @CurrentID,
                              @VehicleID,
                              0,
                              @TotalDistance
                            )
                END
            IF @vc = 1 
                BEGIN
                    UPDATE  TripsAndStopsState
                    SET     MovingState = 0,
                            LastMovingTime = @Timestamp,
                            LastMovingTotalDistance = @TotalDistance,
                            PrevMovingID = @CurrentID--, LastPointTotalDistance = @TotalDistance
                    WHERE   VehicleID = @VehicleID
                            AND ( Archived = 0
                                  OR Archived IS NULL
                                )
                END
        END
    IF @vehiclestate = 1--moving
        BEGIN
            IF @vc = 0 
                BEGIN
                    INSERT  INTO TripsAndStopsState
                            (
                              MovingState,
                              LastMovingTime,
                              LastMovingTotalDistance,
                              PrevMovingID,
                              VehicleID,
                              Archived,
                              LastPointTotalDistance
                            )
                    VALUES  (
                              1,
                              @Timestamp,
                              @TotalDistance,
                              @CurrentID,
                              @VehicleID,
                              0,
                              @TotalDistance
                            )
                END
            IF @vc = 1 
                BEGIN
                    UPDATE  TripsAndStopsState
                    SET     MovingState = 1,
                            LastMovingTime = @Timestamp,
                            LastMovingTotalDistance = @TotalDistance,
                            PrevMovingID = @CurrentID--, LastPointTotalDistance = @TotalDistance
                    WHERE   VehicleID = @VehicleID
                            AND ( Archived = 0
                                  OR Archived IS NULL
                                )
                END
        END
    IF @vehiclestate = 4--key on
        BEGIN
            IF @vc = 0 
                BEGIN
                    INSERT  INTO TripsAndStopsState
                            (
                              KeyState,
                              LastKeyTime,
                              LastKeyTotalDistance,
                              PrevKeyID,
                              VehicleID,
                              Archived,
                              LastPointTotalDistance
                            )
                    VALUES  (
                              1,
                              @Timestamp,
                              @TotalDistance,
                              @CurrentID,
                              @VehicleID,
                              0,
                              @TotalDistance
                            )
                END
            IF @vc = 1 
                BEGIN
                    UPDATE  TripsAndStopsState
                    SET     KeyState = 1,
                            LastKeyTime = @Timestamp,
                            LastKeyTotalDistance = @TotalDistance,
                            PrevKeyID = @CurrentID--, LastPointTotalDistance = @TotalDistance
                    WHERE   VehicleID = @VehicleID
                            AND ( Archived = 0
                                  OR Archived IS NULL
                                )
                END
        END
    IF @vehiclestate = 5--key off
        BEGIN
            IF @vc = 0 
                BEGIN
                    INSERT  INTO TripsAndStopsState
                            (
                              KeyState,
                              LastKeyTime,
                              LastKeyTotalDistance,
                              PrevKeyID,
                              VehicleID,
                              Archived,
                              LastPointTotalDistance
                            )
                    VALUES  (
                              0,
                              @Timestamp,
                              @TotalDistance,
                              @CurrentID,
                              @VehicleID,
                              0,
                              @TotalDistance
                            )
                END
            IF @vc = 1 
                BEGIN
                    UPDATE  TripsAndStopsState
                    SET     KeyState = 0,
                            LastKeyTime = @Timestamp,
                            LastKeyTotalDistance = @TotalDistance,
                            PrevKeyID = @CurrentID--, LastPointTotalDistance = @TotalDistance
                    WHERE   VehicleID = @VehicleID
                            AND ( Archived = 0
                                  OR Archived IS NULL
                                )
                END
        END

GO
