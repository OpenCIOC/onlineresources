SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_ASrch] @ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

SELECT
    SrchCommunityDefault,
    SrchCommunityDefaultOnly,
    ASrchAddress,
    ASrchAges,
    ASrchBool,
    ASrchEmail,
    ASrchEmployee,
    ASrchLastRequest,
    ASrchNear,
    ASrchOwner,
    ASrchVacancy,
    ASrchVOL,
    CSrch
FROM    dbo.CIC_View vw
WHERE   ViewType = @ViewType;

SELECT
    ISNULL(fod.FieldDisplay, fo.FieldName) AS FieldDisplay,
    fo.CheckListSearch
FROM    dbo.GBL_FieldOption fo
    LEFT JOIN dbo.GBL_FieldOption_Description fod
        ON fo.FieldID = fod.FieldID AND fod.LangID = @@LANGID
    INNER JOIN dbo.CIC_View_ChkField cfd
        ON fo.FieldID = cfd.FieldID AND cfd.ViewType = @ViewType
WHERE   fo.CheckListSearch IS NOT NULL
ORDER BY ISNULL(FieldDisplay, fo.FieldName);

SET NOCOUNT OFF;


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_ASrch] TO [cioc_login_role]
GO
