SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TZ_OffsetInMinutes]
	(@Offset INT)
RETURNS FLOAT AS
BEGIN
	RETURN (CAST(@Offset AS FLOAT) / (1080000 / 60))
END

GO
