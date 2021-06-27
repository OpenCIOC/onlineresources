SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxByLvl](
	@NUM VARCHAR(8),
	@CdLvl TINYINT,
	@LangID SMALLINT
)
RETURNS VARCHAR(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@conStr NVARCHAR(3),
		@returnStr NVARCHAR(MAX)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  STUFF((SELECT @conStr + ttd.Term
	FROM dbo.TAX_Term tt
		INNER JOIN dbo.TAX_Term_Description ttd ON tt.Code=ttd.Code AND ttd.LangID=@LangID
	WHERE tt.CdLvl=@CdLvl
		AND EXISTS(SELECT * FROM dbo.CIC_BT_TAX tl
			INNER JOIN dbo.CIC_BT_TAX_TM tlt
				ON tlt.BT_TAX_ID = tl.BT_TAX_ID AND tlt.Code LIKE tt.Code + '%'
			WHERE tl.NUM=@NUM)
	FOR XML PATH(''), TYPE).value('.', 'nvarchar(1000)'), 1, 3, '')

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxByLvl] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxByLvl] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxByLvl] TO [cioc_maintenance_role]
GO
