SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteVehicleNonId]
	@trackerid varchar(50), @reg varchar(20), @mkemdl varchar(100), @bdymfr varchar(50),
	@bdytyp varchar(50), @chsnum varchar(50), @fltnum varchar(20), @clr varchar(6), @iid int,
	@notes varchar(8000)
AS
DECLARE @ivhid uniqueidentifier

SELECT @ivhid = IVHId FROM IVH WHERE TrackerNumber = @trackerid AND Archived = 0

IF @ivhid IS NULL
BEGIN
	SET @ivhid = NEWID()
	INSERT INTO IVH (IVHId, TrackerNumber) VALUES (@ivhid, @trackerid)
END

EXEC proc_WriteVehicle 	@ivhid = @ivhid, @reg = @reg, @mkemdl = @mkemdl, @bdymfr = @bdymfr, @bdytyp = @bdytyp,
				@chsnum = @chsnum, @fltnum = @fltnum, @clr = @clr, @iid = @iid, @notes = @notes

GO
