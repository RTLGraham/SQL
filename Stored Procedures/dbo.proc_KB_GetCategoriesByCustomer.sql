SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_KB_GetCategoriesByCustomer] (@cid UNIQUEIDENTIFIER)
AS
BEGIN

	--DECLARE @cid UNIQUEIDENTIFIER
	--SET @cid = N'C9F5C0CD-FD03-4512-A78A-A10551F91B4B'

	SELECT CategoryId, Name as CategoryName, Description,CustomerId
	FROM dbo.KB_Category
	WHERE CustomerId = @cid

END	


GO
