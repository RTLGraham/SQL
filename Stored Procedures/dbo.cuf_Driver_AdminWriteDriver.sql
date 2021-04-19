SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_AdminWriteDriver]
    (
      @customerintid INT ,
      @drivername VARCHAR(50) ,
      @drivernumber VARCHAR(32)
    )
AS 
    BEGIN
        BEGIN TRAN
	
        DECLARE @did UNIQUEIDENTIFIER, @customerid UNIQUEIDENTIFIER
        DECLARE @dintid INT
        SET @customerid = dbo.GetCustomerIdFromInt(@customerintid)
        SET @did = NEWID()
        EXECUTE [dbo].[proc_WriteDriver] @did, @dintid OUTPUT, @customerid, @drivernumber,
            @drivername
            
        COMMIT TRAN
    END


GO
