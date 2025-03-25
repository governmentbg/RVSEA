USE [DAA]
GO
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
