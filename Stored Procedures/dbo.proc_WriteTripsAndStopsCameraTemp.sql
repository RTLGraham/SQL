SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_WriteTripsAndStopsCameraTemp]
    (
      @cameraNumber NVARCHAR(50),
      @eventid BIGINT,
      @vehiclestate TINYINT,
      @timestamp SMALLDATETIME,
      @lat FLOAT,
      @long FLOAT,
      @previd BIGINT=NULL,
      @duration INT,
      @tripdistance INT,
      @totaldistance BIGINT,
      @currentid BIGINT OUTPUT,
      @broken BIT = 0
    )
AS 

/*
	Creation codes:
			Trip Start: 77
			Trip End: 78
	Vehicle State:
			KeyOn = 4,
			KeyOff = 5,
			Moving = 1,
			Stopped = 0,
			None = -1,
*/
	--DECLARE	  @cameraNumber NVARCHAR(50),
	--		  @eventid BIGINT,
	--		  @vehiclestate TINYINT,
	--		  @timestamp SMALLDATETIME,
	--		  @lat FLOAT,
	--		  @long FLOAT,
	--		  @previd BIGINT=NULL,
	--		  @duration INT,
	--		  @tripdistance INT,
	--		  @totaldistance BIGINT,
	--		  @currentid BIGINT,
	--		  @broken BIT = 0

	--Set @cameraNumber = '359326028859177'
	--Set @eventid = 223903530
	--Set @vehiclestate = 4
	--Set @timestamp = '2020-02-06T18:00:08.236Z'


	--Set @lat = 48.4684483333333
	--Set @long = 35.0286233333333
	----Set @previd = ''
	--Set @duration = 0
	--Set @tripdistance = 0
	--Set @totaldistance = 0
	--Set @broken = 0

		  
	DECLARE @VehicleIntID INT
	DECLARE @VehicleID UNIQUEIDENTIFIER
    DECLARE @CustomerIntId INT
    DECLARE @CustomerID UNIQUEIDENTIFIER
    DECLARE @DriverID UNIQUEIDENTIFIER

    SELECT  @VehicleIntID = v.VehicleIntId,
			@VehicleID = v.VehicleId,
			@CustomerIntId = cust.CustomerIntId,
			@CustomerID = cust.CustomerId
    FROM    Vehicle v
			INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId AND cv.Archived = 0 AND cv.EndDate IS NULL
			INNER JOIN dbo.Customer cust ON cust.CustomerId = cv.CustomerId
			INNER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL
            INNER JOIN dbo.Camera c ON c.CameraId = vc.CameraId AND c.Archived = 0
    WHERE   v.archived = 0
            AND c.archived = 0
            AND c.Serial = @cameraNumber


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
              NULL,
              @VehicleIntID,
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
