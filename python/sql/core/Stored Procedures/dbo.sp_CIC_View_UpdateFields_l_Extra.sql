SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_UpdateFields_l_Extra]
	@ViewType int,
	@InclDate bit,
	@InclRadio BIT,
	@InclWWW BIT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 01-Dec-2013
	Action:	NO ACTION REQUIRED
*/

SELECT DISTINCT FieldName, ExtraFieldType
	FROM GBL_FieldOption fo
	INNER JOIN CIC_View_UpdateField uf
		ON fo.FieldID=uf.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
WHERE ExtraFieldType IN ('e','t') OR (@InclWWW=1 AND fo.ExtraFieldType='w') OR (@InclRadio=1 AND ExtraFieldType='r') OR (@InclDate=1 AND ExtraFieldType IN ('a','d'))
ORDER BY FieldName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_UpdateFields_l_Extra] TO [cioc_login_role]
GO
