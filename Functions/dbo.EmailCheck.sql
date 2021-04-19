SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[EmailCheck](@email VARCHAR(255))   
--Returns true if the string is a valid email address.  
RETURNS bit  
as  
BEGIN  
     DECLARE @valid bit  
     IF @email IS NOT NULL   
          SET @email = LOWER(@email)  
          SET @valid = 0  
          IF @email like '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%'  
             AND LEN(@email) = LEN(dbo.StripNonEmail(@email))  
             AND @email NOT like '%@%@%'  
             AND CHARINDEX('.@',@email) = 0  
             AND CHARINDEX('..',@email) = 0  
             AND CHARINDEX(',',@email) = 0  
             AND RIGHT(@email,1) between 'a' AND 'z'  
               SET @valid=1  
     RETURN @valid  
END
GO
