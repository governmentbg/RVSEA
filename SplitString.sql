USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SplitString]
(
	@vcDelimitedString varchar(max),
	@vcDelimiter varchar(10)
)
RETURNS @tblArray TABLE   
(
--    ElementID smallint  IDENTITY(1,1), --Array index    
	Element varchar(1000) --Array element contents   
)
AS
BEGIN    
	DECLARE @siIndex smallint, @siStart smallint, @siDelSize smallint    
	SET @siDelSize = LEN(@vcDelimiter)    --loop through source string and add elements to destination table array    
	
	WHILE LEN(@vcDelimitedString) > 0    
		BEGIN        
			SET @siIndex = CHARINDEX(@vcDelimiter, @vcDelimitedString)        
			IF @siIndex = 0        
				BEGIN                
					INSERT INTO @tblArray VALUES(@vcDelimitedString)                
					BREAK        
				END        
			ELSE        
				BEGIN                
					INSERT INTO @tblArray VALUES(SUBSTRING(@vcDelimitedString, 1,@siIndex - 1))                
					SET @siStart = @siIndex + @siDelSize                
					SET @vcDelimitedString = SUBSTRING(@vcDelimitedString, @siStart , LEN(@vcDelimitedString) - @siStart + 1)        
				END    
		END    
	RETURN
END
