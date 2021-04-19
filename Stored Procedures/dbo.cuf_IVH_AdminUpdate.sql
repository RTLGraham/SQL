SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_AdminUpdate]
    (
		@ivhid UNIQUEIDENTIFIER,
				
		@Manufacturer varchar(50),
		@Model varchar(50),
		@ServiceProvider varchar(50),
		@SIMCardNumber varchar(50),
		@SerialNumber varchar(50),
		@FirmwareVersion varchar(50),
		@PhoneNumber varchar(50),
		@IVHTypeId int,
		@isDev BIT = NULL
    )
AS 
    BEGIN
        BEGIN TRAN
		DECLARE @count INT
		SET @count = 0
		
		--Is there a tracker number already in DB
		SELECT @count = COUNT(*)
		FROM dbo.IVH i
		WHERE i.IVHId = @ivhid
			AND i.Archived = 0
		
		IF @count > 0
		BEGIN 
			--Tracker Exists
			UPDATE dbo.IVH
			SET Manufacturer = @Manufacturer,
				Model = @Model,
				SIMCardNumber = @SIMCardNumber,
				ServiceProvider = @ServiceProvider,
				SerialNumber = @SerialNumber,
				FirmwareVersion = @FirmwareVersion,
				PhoneNumber = @PhoneNumber,
				IVHTypeId = @IVHTypeId,
				IsDev = @isDev
			WHERE IVHId = @ivhid
		END
		ELSE BEGIN
			--Brand New tracker
			RAISERROR('This tracker does not exist.', 16, 1)	
        END
        
        COMMIT TRAN
    END




GO
