SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Lockheed_TakeItem]
(
	@id INT,
	@count INT
)
AS
BEGIN
	EXEC Test_Database.dbo.proc_LocheedStatic_TakeItem @id, @count
END

GO
