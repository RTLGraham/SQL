SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Customer_GetCustomer]
(
	@cid UNIQUEIDENTIFIER
)
AS
	SELECT c.*
	FROM [dbo].[Customer] c
	WHERE CustomerId = @cid

	SELECT a.*,
		   [dbo].[GetLatFromPostcode] (a.PostCode) AS Lat,
		   [dbo].[GetLongFromPostcode] (a.PostCode) AS Long
	FROM [dbo].[Addresses] a
	INNER JOIN [dbo].[LocationsAddresses] la ON a.AddressId = la.AddressId
	INNER JOIN [dbo].[CustomerLocations] cl ON la.LocationId = cl.LocationId
	INNER JOIN [dbo].[Customer] c ON cl.CustomerId = c.CustomerId AND cl.CustomerId = @cid
	WHERE c.CustomerId = @cid
	AND a.Archived = 0 AND c.Archived = 0

GO
