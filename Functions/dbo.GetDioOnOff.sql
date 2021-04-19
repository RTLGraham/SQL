SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetDioOnOff]
(
	@vid UNIQUEIDENTIFIER,
	@sid SMALLINT,
	@ccid SMALLINT 
) RETURNS BIT
AS
BEGIN
--	DECLARE @vid UNIQUEIDENTIFIER,
--			@sid SMALLINT,
--			@ccid SMALLINT
--	
--	SET @vid = N'2243BCEB-95B2-478D-9F0E-BEF4E8420032'		
--	SET @sid = 8
--	SET @ccid = 8
	
	DECLARE @ccactive SMALLINT,
			@ccinactive SMALLINT,
			@result BIT
					
	SELECT @ccactive = ISNULL(vcci.CreationCodeId, s.CreationCodeIdActive), @ccinactive = ISNULL(vcca.CreationCodeId, s.CreationCodeIdInactive)
	FROM dbo.Sensor s
	LEFT JOIN dbo.VehicleCreationCode vcca ON vcca.VehicleId = @vid AND vcca.CreationCodeId = s.CreationCodeIdActive AND vcca.Archived = 0 AND vcca.CreationCodeHighIsOff = 1
	LEFT JOIN dbo.VehicleCreationCode vcci ON vcci.VehicleId = @vid AND vcci.CreationCodeId = s.CreationCodeIdInactive AND vcci.Archived = 0 AND vcci.CreationCodeHighIsOff = 1
	WHERE s.SensorId = @sid

	IF @ccid = @ccactive
--		PRINT '1'
		SET @result = 1
	ELSE IF @ccid = @ccinactive
--		PRINT '0'
		SET @result = 0 
	ELSE
--		PRINT 'dinna ken' 
		SET @result = NULL
		
	RETURN @result

END
GO
