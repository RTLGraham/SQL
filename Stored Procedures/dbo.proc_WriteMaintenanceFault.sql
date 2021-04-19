SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_WriteMaintenanceFault]
(
	@maintenanceJobId INT,
	@faultTypeId SMALLINT,
	@assetTypeId SMALLINT NULL,
	@assetReference NVARCHAR(100) NULL,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

	DECLARE @result INT

	INSERT INTO dbo.MaintenanceFault
	        ( MaintenanceJobId ,
	          FaultTypeId ,
	          FaultDateTime ,
			  AssetTypeId ,
			  AssetReference ,
	          AcknowledgedBy ,
	          Archived ,
	          LastOperation
	        )
	VALUES  ( @maintenanceJobId , -- MaintenanceJobId - int
	          @faultTypeId , -- FaultTypeId - smallint
	          GETUTCDATE() , -- FaultDateTime - datetime
			  @assetTypeId , -- AssetTypeId - smallint
			  @assetReference , -- AssetReference - NVARCHAR(100)
	          @uid , -- AcknowledgedBy - uniqueidentifier
	          0 , -- Archived - bit
	          GETDATE()  -- LastOperation - smalldatetime
	        )

	SET @result = SCOPE_IDENTITY()
	SELECT @result

END


	



GO
