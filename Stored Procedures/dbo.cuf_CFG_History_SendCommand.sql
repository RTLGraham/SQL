SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_CFG_History_SendCommand]
(
	@VehicleId UNIQUEIDENTIFIER,
	@cmd VARCHAR(1024),
	@expiryDate DATETIME = NULL
)
AS
BEGIN

--DECLARE @vids VARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER
--
--SET @vids = N'74EEE16C-CF22-4DE3-B677-B5BBC86BBDC4'
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'
	
	DECLARE @IVHId UNIQUEIDENTIFIER,
			@cmdBit BINARY(1024)
	
	SET @cmdBit = CAST(@cmd AS BINARY(1024))
	
	SELECT @IVHId = IVHid FROM dbo.Vehicle WHERE VehicleId = @VehicleId
	
	IF @IVHId IS NOT NULL
	BEGIN
		IF @expiryDate IS NULL
		BEGIN
			SET @expiryDate = DATEADD(DAY, 7, GETDATE())
		END
	
		INSERT INTO [dbo].VehicleCommand
				( IVHId ,
				  Command ,
				  ExpiryDate ,
				  AcknowledgedDate ,
				  LastOperation ,
				  Archived
				)
		VALUES  ( @IVHId , -- IVHId - uniqueidentifier
				  @cmdBit , -- Command - binary
				  @expiryDate , -- ExpiryDate - smalldatetime
				  NULL , -- AcknowledgedDate - smalldatetime
				  GETDATE() , -- LastOperation - smalldatetime
				  0  -- Archived - bit
				)
	END
END

GO
