SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_FullSpaceAvailable] (
    @SpaceAvailable bit,
    @Description nvarchar(255),
    @DateUpdated smalldatetime
)
RETURNS nvarchar(500)
WITH EXECUTE AS CALLER
AS BEGIN

    DECLARE
        @returnStr nvarchar(500),
        @onText    nvarchar(100),
        @offText   nvarchar(100);

    IF @SpaceAvailable IS NULL AND  @Description IS NULL AND @DateUpdated IS NULL BEGIN
        SET @returnStr = NULL;
    END;
    ELSE IF @SpaceAvailable IS NULL BEGIN
        SET @returnStr = @Description;

    END;
    ELSE BEGIN
        SELECT
            @onText = fod.CheckboxOnText,
            @offText = fod.CheckboxOffText
        FROM    dbo.GBL_FieldOption fo
            LEFT JOIN dbo.GBL_FieldOption_Description fod
                ON fo.FieldID = fod.FieldID AND fod.LangID = @@LANGID
        WHERE   fo.FieldName = 'SPACE_AVAILABLE';

        SET @returnStr = CASE
                WHEN @SpaceAvailable = 1 THEN ISNULL(@onText, cioc_shared.dbo.fn_SHR_STP_ObjectName('Yes'))
                ELSE ISNULL(@offText, cioc_shared.dbo.fn_SHR_STP_ObjectName('No'))
            END;

        IF @Description IS NOT NULL BEGIN
            SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ') + @Description;
        END;
    END;

    IF @DateUpdated IS NOT NULL BEGIN
        IF @returnStr IS NULL BEGIN
            SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown');
        END;
        SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName(' (') + cioc_shared.dbo.fn_SHR_GBL_DateString(@DateUpdated) + cioc_shared.dbo.fn_SHR_STP_ObjectName(')');
    END;

    RETURN @returnStr;

END;

GO
GRANT EXECUTE ON  [dbo].[fn_CCR_FullSpaceAvailable] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CCR_FullSpaceAvailable] TO [cioc_login_role]
GO
