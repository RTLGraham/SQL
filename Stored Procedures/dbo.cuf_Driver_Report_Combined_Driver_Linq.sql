SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_Report_Combined_Driver_Linq]
(
	@dids varchar(max)
)
AS
BEGIN

--declare	@dids varchar(max)
--SET 	@dids = N'08f993da-981d-4692-9326-fadc82b93051'

SELECT    DriverId ,
			  Number ,
			  NumberAlternate ,
			  NumberAlternate2 ,
			  FirstName ,
			  Surname ,
			  MiddleNames ,
			  LastOperation ,
			  Archived
	FROM dbo.Driver
	WHERE DriverId IN (SELECT VALUE FROM dbo.Split(@dids, ','))

	
END

GO
