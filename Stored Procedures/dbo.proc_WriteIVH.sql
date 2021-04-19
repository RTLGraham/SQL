SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteIVH]
	@ivhid uniqueidentifier = NULL, @ivhintid INT = NULL OUTPUT, @trackerid varchar(50), @mfr varchar(50) = NULL, @mdl varchar(50) = NULL, @pktype varchar(50) = NULL,
	@phone varchar(50) = NULL, @scrdnum varchar(50) = NULL, @svcprvdr varchar(50) = NULL, @serial varchar(50) = NULL,
	@frmwrver varchar(50) = NULL, @atype varchar(50) = NULL, @istag bit = 0
AS
DECLARE @existingivhid uniqueidentifier

IF @ivhid IS NULL
BEGIN
	INSERT INTO IVH 	(TrackerNumber, Manufacturer, Model, PacketType, PhoneNumber, SIMCardNumber,
				ServiceProvider, SerialNumber, FirmwareVersion, AntennaType, IsTag)
	VALUES		(@trackerid, @mfr, @mdl, @pktype, @phone, @scrdnum, @svcprvdr, @serial,
				@frmwrver, @atype, @istag)
	SET @ivhintid = SCOPE_IDENTITY()
END
ELSE
BEGIN
	-- check if IVHId being passed already exists or if a new record needs to be created
	SELECT @existingivhid = IVHId FROM IVH WHERE IVHId = @ivhid AND Archived = 0
	IF @existingivhid IS NULL
	BEGIN
		-- if a new id then write entry into IVH table
		INSERT INTO IVH 	(IVHId, TrackerNumber, Manufacturer, Model, PacketType, PhoneNumber, SIMCardNumber,
					ServiceProvider, SerialNumber, FirmwareVersion, AntennaType, IsTag)
		VALUES		(@ivhid, @trackerid, @mfr, @mdl, @pktype, @phone, @scrdnum, @svcprvdr, @serial,
					@frmwrver, @atype, @istag)
		SET @ivhintid = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		-- if id already exists then update existing entry
		UPDATE IVH SET	IVHId = @ivhid, TrackerNumber = @trackerid, Manufacturer = @mfr, Model = @mdl,
					PacketType = @pktype, PhoneNumber = @phone, SIMCardNumber = @scrdnum,
					ServiceProvider = @svcprvdr, SerialNumber = @serial, FirmwareVersion = @frmwrver,
					AntennaType = @atype, LastOperation = GETDATE(), Archived = 0, IsTag = @istag
		WHERE IVHId = @ivhid
	END
END

GO
