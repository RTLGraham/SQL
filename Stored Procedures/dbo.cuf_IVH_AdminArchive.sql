SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_IVH_AdminArchive]
    (
		@cid UNIQUEIDENTIFIER,
		@ivhid UNIQUEIDENTIFIER
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
			SET Archived = 1
			WHERE IVHId = @ivhid
			
			UPDATE dbo.CustomerIVHStock
			SET Archived = 1, EndDate = GETDATE(), LastOperation = GETDATE()
			WHERE IVHId = @ivhid AND CustomerId = @cid
		END
		ELSE BEGIN
			--Brand New tracker
			RAISERROR('This tracker does not exist.', 16, 1)	
        END
        
        COMMIT TRAN
    END



GO
