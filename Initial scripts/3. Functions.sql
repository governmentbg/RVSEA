

begin transaction

/****** Object:  UserDefinedFunction [dbo].[FormatDuration]    Script Date: 30.11.2022 г. 11:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FormatDuration] (@Duration int)  
RETURNS NVARCHAR(14) AS  
BEGIN 
	DECLARE @Delimeter1 VARCHAR(1) = ':';

	DECLARE @Hours VARCHAR(10) = CONVERT(varchar, @Duration / 3600, 104);
	IF @Hours = '0'
	BEGIN
		SET @Hours = '';
		SET @Delimeter1 = '';
	END

	DECLARE @Minutes VARCHAR(2) = CONVERT(varchar, @Duration % 3600 / 60);
	IF LEN(@Minutes) = 1 AND @Hours <> ''
	BEGIN
		SET @Minutes = '0' + @Minutes;
	END

	DECLARE @Seconds VARCHAR(2) = CONVERT(varchar, @Duration % 3600 % 60, 104);
	IF LEN(@Seconds) = 1
	BEGIN
		SET @Seconds = '0' + @Seconds;
	END

	DECLARE @Result VARCHAR(14) = @Hours + @Delimeter1 + @Minutes + ':' + @Seconds; 

    RETURN  @Result;  
END   
GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 30.11.2022 г. 11:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[SplitString]
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
GO
/****** Object:  UserDefinedFunction [dbo].[StringSplit2]    Script Date: 30.11.2022 г. 11:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[StringSplit2]
(
@value VARCHAR(1000)
 )
RETURNS nvarchar(1000)
BEGIN

declare @Number nvarchar(1000);


set @Number =	case 
					when @value not like '%[^0-9,-]%' 
						then
							@value
					else '-1'
				end

RETURN '(' + @Number + ')'


END
GO
/****** Object:  UserDefinedFunction [dbo].[StringSplit3]    Script Date: 30.11.2022 г. 11:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[StringSplit3]
(
@value VARCHAR(1000)
 )
RETURNS nvarchar(1000)
BEGIN

declare @Number nvarchar(1000);


set @Number =	case 
					when @value not like '%[^0-9,-]%' 
						then
							@value
					else '-1'
				end

RETURN @Number


END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER FUNCTION [dbo].[ConvertBytesToMB] (@Bytes INT)  
RETURNS FLOAT AS  
BEGIN 
	IF @Bytes IS NULL RETURN NULL;

	IF @Bytes = 0 RETURN 0;

	DECLARE @result FLOAT = CAST(@Bytes AS FLOAT) / 1024 / 1024;

	RETURN CAST((CAST(@Bytes AS FLOAT) / 1024 / 1024) AS DECIMAL(12, 6)) ;  
END
GO


commit
--rollback