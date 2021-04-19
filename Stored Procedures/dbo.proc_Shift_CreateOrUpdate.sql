SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Shift_CreateOrUpdate]
(
	@shiftId BIGINT = NULL,
	@shiftNumber VARCHAR(100) = NULL,
	@truckId NVARCHAR(100),
	@seq SMALLINT,
	@siteId NVARCHAR(30),
	@estDateTime DATETIME = NULL
)
AS
BEGIN
	-- A shift will be received over a number of calls for each leg
	-- The first call will have a NULL ShiftId so we determine if we are creating or updating a shift and return a new/existing ShiftId to be used for the subsequent calls
	-- If we determine that we are updating a shift all the current open legs will be deleted before adding new ones

--DECLARE	@shiftId BIGINT,
--		@shiftNumber VARCHAR(100),
--		@truckId NVARCHAR(100),
--		@seq SMALLINT,
--		@siteId NVARCHAR(30),
--		@estDateTime DATETIME

--SET	@shiftId = NULL
--SET @shiftNumber = NULL
--SET @truckId = '123'
--SET @seq = 1
--SET	@siteId = '97531'
--SET	@estDateTime = '2018-01-22 12:00'

	DECLARE @vintid INT,
			@customerId UNIQUEIDENTIFIER,
			@geofenceId UNIQUEIDENTIFIER

	-- Check the Vehicle details and get the VehicleIntId, and CustomerId
	SET @vintid = NULL
	SELECT @vintid = v.VehicleIntId, @customerId = cv.CustomerId
	FROM dbo.Vehicle v
	INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
	WHERE v.FleetNumber = @truckId
	  AND v.Archived = 0
	  AND cv.EndDate IS NULL	
	  AND cv.Archived = 0

	IF @vintid IS NULL -- The TruckId provided does not exist
	BEGIN;
		THROW 51000, 'Invalid Truck Id', 1
	END	

	-- Is the ShiftId present? - If not we are processing the first call for a shift
	IF @shiftId IS NULL	-- This is the first call for a shift transaction
	BEGIN	
		-- Does an open Shift already exist for the vehicle?
		SELECT @shiftId = sh.ShiftId
		FROM dbo.ShiftHeader sh
		WHERE sh.VehicleIntId = @vintid AND sh.ShiftStatus IN (0,1) AND sh.Archived = 0

		IF @shiftId IS NULL -- This is a brand new shift so insert the header
		BEGIN
			-- Insert the header row first
			INSERT INTO dbo.ShiftHeader (ShiftNumber, VehicleIntId, ShiftStatus, LastOperation, Archived)
			VALUES (@shiftNumber, @vintid, 0, GETDATE(), 0)
			SET @shiftId = SCOPE_IDENTITY()
		END	-- finished inserting new shift details and first leg
		ELSE -- we are processing the first call for an existing shift - need to delete any existing open shift details
		BEGIN
			-- Delete any unfinished legs for the shift
			UPDATE dbo.ShiftDetail
			SET Archived = 1
			WHERE ShiftId = @shiftId
			  AND SeqStatus IN (0,1)
			  AND Archived = 0
		END	
	END -- of Initial shift call

	-- Now add the new leg that has been provided - determine if the geofence exists
	SET @geofenceId = NULL
	SELECT TOP 1 @geofenceId = geo.GeofenceId
	FROM dbo.Geofence geo
	INNER JOIN dbo.[User] u ON geo.CreationUserId = u.UserID AND u.CustomerID = @customerId
	WHERE geo.SiteId = @siteId
	  AND geo.GeofenceTypeId = 5

	IF @geofenceId IS NULL -- The insert didn't find a geofence so throw an arror
	BEGIN;
		THROW 52000, 'Invalid Site Id', 1
	END	

	INSERT INTO dbo.ShiftDetail (ShiftId, Seq, SiteId, GeofenceId, EstDateTime, SeqStatus, LastOperation, Archived)
	VALUES  (@shiftId, @seq, @siteId, @geofenceId, @estDateTime, 0, GETDATE(), 0)

	-- Return the Shift Id for subsequent calls
	SELECT @shiftId

END




GO
