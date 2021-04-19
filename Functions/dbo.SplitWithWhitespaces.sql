SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[SplitWithWhitespaces]
	(
		@List nvarchar(MAX),
		@SplitOn nvarchar(5)
	)  
	RETURNS @RtnValue table 
	(
		
		Id int identity(1,1),
		Value nvarchar(max)
	) 
	AS  
	BEGIN 
		While (Charindex(@SplitOn,@List)>0)
		Begin

			Insert Into @RtnValue (value)
			Select 
				Value = Substring(@List,1,Charindex(@SplitOn,@List)-1)

			Set @List = Substring(@List,Charindex(@SplitOn,@List)+len(@SplitOn),len(@List))
		End

		Insert Into @RtnValue (Value)
		Select Value = @List
	
		Return
	END


GO
