USE [DAA]
GO

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