SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FormatVehicleIdentifierByUser]
(
	@vid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER = NULL,
	@format VARCHAR(MAX) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	--DECLARE @vid UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER,
	--		@format NVARCHAR(MAX)
	--SET @vid = N'D1F21E8D-E371-4EA5-860C-0458E88909FC'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @format = '{0} ({4})'

	DECLARE @registration NVARCHAR(MAX),
			@fleetnumber NVARCHAR(MAX),
			@identifier NVARCHAR(MAX),
			@chassis NVARCHAR(MAX),
			@tracker NVARCHAR(MAX),
			@result VARCHAR(MAX)
	
	IF @format IS NULL		
		SELECT @format = [dbo].UserPref(@uid, 216)
		
	SET @format = ISNULL(@format, '{0}') -- set default format (registration only) if no format supplied and user has no preference
	
	SELECT	@registration = Registration,
			@fleetnumber = FleetNumber,
			@identifier = Identifier,
			@chassis = ChassisNumber,
			@tracker = TrackerNumber
	FROM	dbo.Vehicle
	LEFT JOIN dbo.IVH ON IVH.IVHId = Vehicle.IVHId
	WHERE	VehicleId = @vid	

	SET @format = REPLACE(@format, '{0}', @registration)
	SET @format = REPLACE(@format, '{1}', ISNULL(@fleetnumber,''))
	SET @format = REPLACE(@format, '{2}', ISNULL(@identifier,''))
	SET @format = REPLACE(@format, '{3}', ISNULL(@chassis,''))
	SET @format = REPLACE(@format, '{4}', ISNULL(@tracker,''))
	SET @result = LTRIM(RTRIM(REPLACE(@format, '  ', ' '))) -- clean up additional spaces
	
	RETURN	 @result

END




GO
