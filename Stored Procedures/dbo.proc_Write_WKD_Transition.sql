SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- This stored proc manages transitions to be inserted into WKD_WorkDiaryTransition by the Listener.
-- It currently does NOT handle transitions moving from 1up to 2up and vice versa for the second driver as there is
-- insufficient data in the parameter list to handle this efficiently.

CREATE PROCEDURE [dbo].[proc_Write_WKD_Transition]
    @transitionId BIGINT OUTPUT,
    @trackerid VARCHAR(50),
    @driverid VARCHAR(32),
    @transitionDateTime DATETIME,
    @state INT,
    @odo INT,
    @long FLOAT,
    @lat FLOAT,
    @location NVARCHAR(200),
    @twoUpDriverid VARCHAR(32),
    @note NVARCHAR(200)
AS 

    BEGIN

--		DECLARE @transitionId bigint
--		DECLARE @trackerid varchar(50)
--		DECLARE @driverid varchar(32)
--		DECLARE @transitionDateTime datetime
--		DECLARE @state int
--		DECLARE @odo int
--		DECLARE @long float
--		DECLARE @lat float
--		DECLARE @location nvarchar(200)
--		DECLARE @twoUpDriverId varchar(32)
--		DECLARE @note nvarchar(200)
--
--		SET @transitionId = NULL
--		SET @trackerid = '4332151199'
--		SET @driverid = 'ATTACKST1G'
--		SET @transitionDateTime = '2013-08-17 16:00'
--		SET @state = 0
--		SET @odo = 100
--		SET @long = 25.0
--		SET @lat = -25.0
--		SET @location = 'Someplace'
--		SET @twoUpDriverId = 'AFR1CANST1G'
--		SET @note = NULL

        DECLARE @customerid UNIQUEIDENTIFIER,
				@vid UNIQUEIDENTIFIER,
				@vintid INT,
				@dintid INT,
				@dint2id INT,
				@customerintid INT,
				@sdateinthepast DATETIME,
				@edateinthefuture DATETIME,
				@twoUp BIT,
				@workDiaryId INT,
				@twoUpWorkDiaryId INT,
				@workDiaryPageId INT,
				@twoUpWorkDiaryPageId INT,
				@prevTwoUpWorkDiaryPageId INT
				
		SET @twoUp = 0 -- initialise Two Up indicator

        SET @sdateinthepast = '1900-01-01 00:00'
        SET @edateinthefuture = '2100-01-01 00:00'
-------------------------------------------------------- Find Vehicle / customer 
	
        SELECT TOP 1
                @vintid = Vehicle.VehicleIntId,
                @vid = Vehicle.VehicleId,
                @customerid = Customer.CustomerId,
                @customerintid = Customer.CustomerIntId
        FROM    IVH
                INNER JOIN Vehicle ON IVH.IVHId = Vehicle.IVHId
                INNER JOIN CustomerVehicle ON Vehicle.VehicleId = CustomerVehicle.VehicleId
                INNER JOIN dbo.Customer ON dbo.CustomerVehicle.CustomerId = dbo.Customer.CustomerId
        WHERE   TrackerNumber = @trackerid
                AND IVH.Archived = 0
                AND Vehicle.Archived = 0
                AND Customer.Archived = 0
                AND ( IVH.IsTag = 0
                      OR IVH.IsTag IS NULL
                    )
                AND ( GETDATE() BETWEEN ISNULL(StartDate, @sdateinthepast)
                                AND     ISNULL(EndDate, @edateinthefuture) )
	
------------------------------------------------------- Find Driver - 
        IF @driverid = '' 
            BEGIN
                SET @driverid = 'No ID'
            END

        DECLARE @did UNIQUEIDENTIFIER

		--Check for the linked driver
        SET @did = dbo.GetLinkedDriverId(@vid)

        IF @did IS NULL 
            BEGIN
		--If there is no linked driver - obtain the driver ID from the driver number
                SET @did = dbo.GetDriverIdFromNumberAndCustomer(@driverid, @customerid)
            END

        IF @did IS NULL 
            BEGIN
                SET @did = NEWID()
                EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerid,
                    @driverid, 'UNKNOWN'
            END
        ELSE 
            BEGIN
                SET @dintid = dbo.GetDriverIntFromId(@did)
            END
            
------------------------------------------------------- Find Second Driver if number is present - 

		IF @twoUpDriverid IS NOT NULL AND @twoUpDriverid NOT IN ('', 'No ID')
		-- Need to also create new page for twoup driver
		BEGIN
			SET @twoUP = 1
			-- Get DriverId for second driver
			DECLARE @did2 UNIQUEIDENTIFIER
			SET @did2 = dbo.GetDriverIdFromNumberAndCustomer(@twoupdriverid, @customerid)
			IF @did2 IS NULL 
				BEGIN
					SET @did2 = NEWID()
					EXEC proc_WriteDriver @did2, @dint2id OUTPUT, @customerid, @twoupdriverid, 'UNKNOWN'
				END
			ELSE 
				BEGIN
					SET @dint2id = dbo.GetDriverIntFromId(@did2)
				END
		END
		
-------------------------------------------------------- Work Diary Processing		
		SET @transitionId = 0 -- Iniialise transition id
		
		SELECT TOP 1 @workDiaryId = WorkDiaryId
		FROM dbo.WKD_WorkDiary
		WHERE DriverIntId = @dintid
		  AND @transitionDateTime BETWEEN StartDate AND ISNULL(EndDate, @edateinthefuture)
		
		IF @workDiaryId IS NULL
		BEGIN	
			--error: no Valid Work Diary Exists for this timestamp for driver 1
			SET @transitionId = -1
		END ELSE
		BEGIN	
			-- Now get work diary page for driver 1
			SELECT TOP 1 @workDiaryPageId = WorkDiaryPageId
			FROM dbo.WKD_WorkDiaryPage
			WHERE WorkDiaryId = @workDiaryId
				AND Date = CAST(FLOOR(CAST(@transitionDateTime AS FLOAT)) AS DATETIME)
			ORDER BY Date DESC
			
			IF @twoUp = 1
			BEGIN
				-- get twoUpWorkDiaryId of second driver if exists
				SELECT TOP 1 @twoUpWorkDiaryId = WorkDiaryId
				FROM dbo.WKD_WorkDiary
				WHERE DriverIntId = @dint2id
				  AND @transitionDateTime BETWEEN StartDate AND ISNULL(EndDate, @edateinthefuture)
				  
				IF @twoUpWorkDiaryId IS NULL
				BEGIN	
					--error: no Valid Work Diary Exists for this timestamp for the second driver
					SET @transitionId = -2
				END	ELSE
				BEGIN
					-- Get work diary page for second driver
					SELECT TOP 1 @twoUpWorkDiaryPageId = WorkDiaryPageId
					FROM dbo.WKD_WorkDiaryPage
					WHERE WorkDiaryId = @twoUpWorkDiaryId
						AND Date = CAST(FLOOR(CAST(@transitionDateTime AS FLOAT)) AS DATETIME)
					ORDER BY Date DESC
				END				  
			END	
		END -- of getting work diaries and pages
		
		IF @transitionid = 0
		BEGIN
			IF @workDiaryPageId IS NULL
			BEGIN
				-- No page exists for this date for driver 1, so need to create one
				INSERT INTO dbo.WKD_WorkDiaryPage (WorkDiaryId, Date)
				VALUES (@workDiaryId, CAST(FLOOR(CAST(@transitionDateTime AS FLOAT)) AS DATETIME))
				SET @workDiaryPageId = SCOPE_IDENTITY()	
								
				IF @twoUp = 1 
				BEGIN
					IF @twoUpWorkDiaryPageId IS NULL
					BEGIN
						-- No page exists for this date and driver, so need to create one
						INSERT INTO dbo.WKD_WorkDiaryPage (WorkDiaryId, Date, TwoUpWorkDiaryPageId)
						VALUES (@twoUpWorkDiaryId, CAST(FLOOR(CAST(@transitionDateTime AS FLOAT)) AS DATETIME), @WorkDiaryPageId)
						SET @twoUpWorkDiaryPageId = SCOPE_IDENTITY()
					END ELSE
					BEGIN
						-- now update driver two's original work diary page with the driver one two up page id
						UPDATE dbo.WKD_WorkDiaryPage
						SET TwoUpWorkDiaryPageId = @WorkDiaryPageId
						WHERE WorkDiaryPageId = @twoUpWorkDiaryPageId					
					END
					-- now update driver one's new work diary page with the two up page id
					UPDATE dbo.WKD_WorkDiaryPage
					SET TwoUpWorkDiaryPageId = @twoUpWorkDiaryPageId
					WHERE WorkDiaryPageId = @workDiaryPageId
				END -- of two up processing
			END -- of new diary page creation

	-------------------------------------------------------- Write Data

			INSERT INTO dbo.WKD_WorkDiaryTransition (WorkDiaryPageId, VehicleIntId, WorkStateTypeId, TransitionDateTime, Odometer, Lat, Long, Location, TwoUpInd, Note)
			VALUES (@workDiaryPageId, @vintid, @state, @transitionDateTime, @odo, @lat, @long, @location, @twoUp, @note)
			
			SET @transitionid = SCOPE_IDENTITY()	
				
		END
	END

GO
