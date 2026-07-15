SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_iCarolExport_Deleted_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SET NOCOUNT ON

DECLARE    @Error        INT
SET @Error = 0

DECLARE @nLine char(2),
        @nLine10 char(1)

SET @nLine = CHAR(13) + CHAR(10)
SET @nLine10 = CHAR(10)

DECLARE @DistCode NVARCHAR(20)
SET @DistCode = 'AIRSEXPORT-O211-'

DECLARE @DST_ID INT
IF @DistCode IS NOT NULL BEGIN
    SELECT @DST_ID=DST_ID FROM dbo.CIC_Distribution WHERE DistCode=@DistCode
    SET @DST_ID=ISNULL(@DST_ID,-1)
END




SELECT  
    bt.NUM, (SELECT TOP 1 btd.DELETION_DATE FROM GBL_BaseTable_Description btd WHERE bt.NUM=btd.NUM AND btd.LangID=0) AS DELETION_DATE, CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_DST dst WHERE dst.DST_ID=@DST_ID AND dst.NUM=bt.NUM) THEN 0 ELSE 1 END AS NOT_TAGGED,
        ols.Code,btols.EXTERNAL_ID,ii.ResourceAgencyNum, ii.TaxonomyLevelName,
    (SELECT 

       bt.NUM AS "@uniquePriorID",
       CASE WHEN btd.LangID=0 THEN 'en' ELSE 'fr' END AS "@cultureCode",
       CASE 
            WHEN ols.Code = 'AGENCY' THEN 'Agency'
            WHEN ols.Code = 'SITE' THEN 'Site'
            WHEN ols.Code = 'SERVICE' THEN 'Program'
            WHEN ols.Code = 'TOPIC' THEN 'Program'
        END AS "@type",
        CASE WHEN btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE() THEN 'Active' ELSE 'Inactive' END AS "@status",
        CASE WHEN btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE() THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS "@excludeFromDirectory",
        CASE WHEN btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE() THEN btd.NON_PUBLIC ELSE CAST(1 AS BIT) END AS "@isConfidential",
        -- Description Field:
        CASE WHEN btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE() THEN '' ELSE 
                CASE WHEN btd.LangID=0 
                    THEN '<span style="color:#FF0000"><strong>This is a deleted resource and is only kept for archive purposes.</strong> </span><br />' 
                    ELSE '<span style="color:#FF0000"><strong>Cette ressource est supprimée et n''est conservée qu''à des fins d''archivage.</strong> </span><br />'
                END
            END + 
            CASE WHEN cbtd.PUBLIC_COMMENTS IS NOT NULL AND ols.Code IN ('SERVICE', 'TOPIC') THEN cbtd.PUBLIC_COMMENTS + '<br/ >' ELSE '' END +
            CASE 
                WHEN ols.Code = 'AGENCY' THEN ISNULL(
                    CASE WHEN btd.ORG_DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN REPLACE(btd.ORG_DESCRIPTION,'<br>','<br />') ELSE REPLACE(btd.ORG_DESCRIPTION,@nLine10,@nLine10 + '<br />') END,
                    '')
                WHEN ols.Code = 'SITE' THEN ISNULL(btd.LOCATION_DESCRIPTION,'') + CASE WHEN cbtd.INTERSECTION IS NOT NULL THEN (
                        (CASE WHEN btd.LOCATION_DESCRIPTION IS NOT NULL THEN '<br />' ELSE '' END ) + 
                        (CASE WHEN btd.LangID=0 THEN 'Cross Street: ' ELSE 'Rue transversale : ' END) + cbtd.INTERSECTION 
                    ) ELSE '' END 
                WHEN ols.Code IN ('SERVICE', 'TOPIC') THEN CASE WHEN btd.DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN REPLACE(btd.DESCRIPTION,'<br>','<br />') ELSE REPLACE(btd.DESCRIPTION,@nLine10,@nLine10 + '<br />') END 
                
        END AS "@description",
        (SELECT 
            (SELECT
                rbtols.EXTERNAL_ID AS "@id",
                rbtols.NUM AS "@uniquePriorID",
                'Agency' AS "@type"
            FROM dbo.GBL_BT_OLS rbtols
                INNER JOIN dbo.GBL_OrgLocationService rols
                    ON rbtols.OLS_ID=rols.OLS_ID
            WHERE ols.Code <> 'Agency' AND rbtols.NUM=ISNULL(bt.ORG_NUM, bt.NUM) AND rols.Code = 'AGENCY'
            FOR XML PATH('item'), TYPE
            ),
            (SELECT
                rbtols.EXTERNAL_ID AS "@id",
                rbtols.NUM AS "@uniquePriorID",
                'Site' AS "@type",
            (SELECT TOP(1) ibtd.LOCATION_NAME
                FROM dbo.GBL_BaseTable_Description ibtd WHERE ibtd.NUM=rbtols.NUM ORDER BY CASE WHEN ibtd.LangID=btd.LangID THEN 0 ELSE 1 END, ibtd.LangID
            ) + STUFF(
                COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
                COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,''),
                1, 2, ' - '
            ) AS "@name"
            FROM dbo.GBL_BT_OLS rbtols
                INNER JOIN dbo.GBL_OrgLocationService rols
                    ON rbtols.OLS_ID=rols.OLS_ID
            WHERE ols.Code IN ('SERVICE', 'TOPIC') AND rols.Code='SITE' AND (rbtols.NUM=bt.NUM OR EXISTS(SELECT * FROM dbo.GBL_BT_LOCATION_SERVICE ls WHERE ls.LOCATION_NUM=rbtols.NUM AND ls.SERVICE_NUM=bt.NUM))
            FOR XML PATH ('item'), TYPE
            )
         FOR XML PATH('related'), TYPE),

        (SELECT 

            (SELECT 'Deleted Record' AS "@label",
                CASE WHEN btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE() THEN '' ELSE 'Yes' END AS "@item"
                FOR XML PATH('item'), TYPE)
        FOR XML PATH('customFields'), TYPE)
        


    FROM dbo.GBL_BaseTable_Description btd
    LEFT JOIN dbo.CIC_BaseTable_Description cbtd
    ON bt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID
    WHERE bt.NUM=btd.NUM AND btd.LangID = 0
    ORDER BY btd.LangID
    FOR XML PATH('item'), ROOT('root'), TYPE
) AS datachange

    FROM dbo.GBL_BaseTable bt
    INNER JOIN dbo.GBL_BT_OLS btols ON btols.NUM = bt.NUM AND btols.EXTERNAL_ID IS NOT NULL
    INNER JOIN dbo.GBL_OrgLocationService ols ON ols.OLS_ID = btols.OLS_ID
    INNER JOIN dbo.CIC_iCarolImport ii ON 
        ii.LangID=0 AND (
            (ols.Code IN ('Agency', 'Site') AND ii.ResourceAgencyNum = btols.EXTERNAL_ID) 
            OR (ols.Code IN ('Service', 'Topic') AND btols.EXTERNAL_ID LIKE ii.ResourceAgencyNum + ';%')
         )
WHERE bt.MemberID IN (800,1700,5000)
    AND bt.SOURCE_FROM_ICAROL=0
    AND (
        EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.LangID=0 AND btd.NUM=bt.NUM AND btd.DELETION_DATE IS NOT NULL)
        OR NOT EXISTS(SELECT * FROM dbo.CIC_BT_DST dst WHERE dst.DST_ID=@DST_ID AND dst.NUM=bt.NUM)
    )
    AND ii.[Custom_Deleted Record] IS DISTINCT FROM 'Yes'
ORDER BY bt.NUM, ols.OLS_ID

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolExport_Deleted_l] TO [cioc_login_role]
GO
