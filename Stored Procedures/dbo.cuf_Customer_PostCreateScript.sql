SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Customer_PostCreateScript]
(
	@cid UNIQUEIDENTIFIER
)
AS
	--Create the No Id driver if required
	DECLARE @did UNIQUEIDENTIFIER,
			@dintid INT

	SELECT TOP 1 @did = d.DriverId
	FROM dbo.Driver d
		INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
		INNER JOIN dbo.Customer c ON c.CustomerId = cd.CustomerId
	WHERE c.CustomerId = @cid AND d.Number = 'No ID' AND d.Archived = 0
	ORDER BY d.LastOperation DESC
    
	IF @did IS NULL
	BEGIN
		SET @did = NEWID()
		EXEC proc_WriteDriver @did, @dintid OUTPUT, @cid, 'No ID', 'UNKNOWN'
	END

	--Set the data dispatcher
	DECLARE @dname NVARCHAR(MAX)
	SELECT @dname = Value 
	FROM dbo.DBConfig
	WHERE NameID = 9003 
	
	UPDATE dbo.Customer 
	SET DataDispatcher = @dname 
	WHERE CustomerId = @cid
GO
