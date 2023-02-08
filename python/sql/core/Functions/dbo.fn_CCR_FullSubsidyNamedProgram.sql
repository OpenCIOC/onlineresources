SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CCR_FullSubsidyNamedProgram] (
    @SubsidyNamedProgram bit,
    @Description nvarchar(1000),
    @MemberID int
)
RETURNS nvarchar(1500)
WITH EXECUTE AS CALLER
AS BEGIN

    DECLARE
        @returnStr nvarchar(1500),
        @onText    nvarchar(100),
        @offText   nvarchar(100),
        @programDescription nvarchar(MAX);

    SELECT @programDescription=SubsidyNamedProgramDesc FROM dbo.STP_Member_Description WHERE MemberID=@MemberID AND LangID=@@LANGID

    IF @SubsidyNamedProgram IS NULL AND  @Description IS NULL BEGIN
        SET @returnStr = NULL;
    END;
    ELSE IF @SubsidyNamedProgram IS NULL BEGIN
        SET @returnStr = @Description;
    END;
    ELSE BEGIN
        SELECT
            @onText = fod.CheckboxOnText,
            @offText = fod.CheckboxOffText
        FROM    dbo.GBL_FieldOption fo
            LEFT JOIN dbo.GBL_FieldOption_Description fod
                ON fo.FieldID = fod.FieldID AND fod.LangID = @@LANGID
        WHERE   fo.FieldName = 'SUBSIDY_NAMED_PROGRAM'

        SET @returnStr = CASE
                WHEN @SubsidyNamedProgram = 1 THEN ISNULL(@onText, cioc_shared.dbo.fn_SHR_STP_ObjectName('Yes'))
                ELSE ISNULL(@offText, cioc_shared.dbo.fn_SHR_STP_ObjectName('No'))
            END;

        IF @Description IS NOT NULL BEGIN
            SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ') + @Description;
        END;
    END;

    IF @returnStr IS NOT NULL AND @programDescription IS NOT NULL BEGIN
        SET @returnStr = @programDescription + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + @returnStr;
    END;

    RETURN @returnStr;

END;

GO
GRANT EXECUTE ON  [dbo].[fn_CCR_FullSubsidyNamedProgram] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[fn_CCR_FullSubsidyNamedProgram] TO [cioc_login_role]
GO
