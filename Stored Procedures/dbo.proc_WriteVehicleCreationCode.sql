SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteVehicleCreationCode] @vid uniqueidentifier, @ccid smallint, @ccname varchar(50)
AS
-- determine default value from CreationCode table
DECLARE @default bit
DECLARE @defaultname varchar(50)
SELECT @defaultname = Name FROM CreationCode WHERE CreationCodeId = @ccid
IF @defaultname = @ccname
	SET @default = 1
ELSE
	SET @default = 0

-- if value passed is default, then there will be no need to update

DECLARE @vccid uniqueidentifier
SELECT @vccid = VehicleCreationCodeId FROM VehicleCreationCode WHERE VehicleId = @vid AND CreationCodeId = @ccid

IF @vccid IS NULL
BEGIN
	-- if not the default but not previously set for this user, write entry into VehicleCreationCode
	IF @default = 0
		INSERT INTO VehicleCreationCode (VehicleId, CreationCodeId, Name) VALUES (@vid, @ccid, @ccname)
END
ELSE
BEGIN
	-- if the default and previously set for this user, delete entry from VehicleCreationCode
	IF @default = 1
		DELETE FROM VehicleCreationCode WHERE VehicleCreationCodeId = @vccid
	-- if not the default but previously set for this user, update the entry in VehicleCreationCode
	ELSE
		UPDATE VehicleCreationCode SET Name=@ccname, LastOperation=GETDATE() WHERE VehicleCreationCodeId = @vccid
END

GO
