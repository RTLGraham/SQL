SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_IVH_AdminSoftwareUpdate]
    (
		@ivhid UNIQUEIDENTIFIER,
		@command VARCHAR(1024),
		@expiryDate DATETIME
    )
AS 
    BEGIN
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
			INSERT INTO dbo.VehicleCommand
			        ( IVHId ,
			          Command ,
			          ExpiryDate ,
			          AcknowledgedDate ,
			          LastOperation ,
			          Archived
			        )
			VALUES  ( @ivhid , -- IVHId - uniqueidentifier
			          CAST(@command AS BINARY(1024)), -- Command - binary
			          @expiryDate , -- ExpiryDate - smalldatetime
			          NULL , -- AcknowledgedDate - smalldatetime
			          GETDATE() , -- LastOperation - smalldatetime
			          0  -- Archived - bit
			        )
		END
		ELSE BEGIN
			--Brand New tracker
			RAISERROR('This tracker does not exist.', 16, 1)	
        END
    END

GO
