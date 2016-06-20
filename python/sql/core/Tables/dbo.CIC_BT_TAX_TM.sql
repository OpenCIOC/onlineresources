CREATE TABLE [dbo].[CIC_BT_TAX_TM]
(
[BT_TM_ID] [int] NOT NULL IDENTITY(1, 1),
[BT_TAX_ID] [int] NOT NULL,
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_CIC_BT_TAX_TM_d] ON [dbo].[CIC_BT_TAX_TM]
FOR DELETE AS

SET NOCOUNT ON

DELETE pr
	FROM CIC_BT_TAX pr
	WHERE EXISTS(SELECT * FROM Deleted d WHERE pr.BT_TAX_ID=d.BT_TAX_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM fr WHERE fr.BT_TAX_ID=pr.BT_TAX_ID)

SET NOCOUNT OFF

GO
EXEC sp_settriggerorder N'[dbo].[tr_CIC_BT_TAX_TM_d]', 'last', 'delete', null
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BT_TAX_TM_iud] ON [dbo].[CIC_BT_TAX_TM]
FOR INSERT, UPDATE, DELETE AS
BEGIN
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 10-May-2016
	Action: TESTING REQUIRED
*/

IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd INNER JOIN dbo.CIC_BT_TAX tl ON tl.NUM = btd.NUM INNER JOIN Inserted i ON i.BT_TAX_ID = tl.BT_TAX_ID
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable_Description cbtd WHERE cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID)) BEGIN
	INSERT INTO CIC_BaseTable_Description (NUM, LangID)
	SELECT DISTINCT btd.NUM, btd.LangID
		FROM GBL_BaseTable_Description btd
		INNER JOIN dbo.CIC_BT_TAX tl
			ON tl.NUM = btd.NUM
		INNER JOIN Inserted i
			ON i.BT_TAX_ID = tl.BT_TAX_ID
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable_Description cbtd WHERE cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID)
END

UPDATE cbtd
	SET SRCH_Taxonomy_U = 1
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BT_TAX pr
		ON cbtd.NUM=pr.NUM
	WHERE (EXISTS(SELECT * FROM Inserted i WHERE i.BT_TAX_ID=pr.BT_TAX_ID)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.BT_TAX_ID=pr.BT_TAX_ID))
		AND cbtd.SRCH_Taxonomy_U = 0
		
DECLARE @SQL nvarchar(max),
		@GHIDs nvarchar(max),
		@UpdateGUID uniqueidentifier

SET @UpdateGUID = NEWID()

UPDATE pr
	SET GHTaxCache_u = @UpdateGUID
FROM CIC_BT_PB pr
WHERE (
		EXISTS(SELECT * FROM inserted i INNER JOIN CIC_BT_TAX prt ON prt.BT_TAX_ID=i.BT_TAX_ID WHERE pr.NUM=prt.NUM)
		OR EXISTS(SELECT * FROM deleted d INNER JOIN CIC_BT_TAX prt ON prt.BT_TAX_ID=d.BT_TAX_ID WHERE pr.NUM=prt.NUM)
	)
	AND EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE pr.PB_ID=gh.PB_ID AND gh.Used IS NULL)

	SELECT @GHIDs = COALESCE(@GHIDs + ',','') + CAST(gh.GH_ID AS varchar)
		FROM CIC_GeneralHeading gh
		WHERE EXISTS(SELECT * FROM CIC_BT_PB pb WHERE gh.PB_ID=pb.PB_ID AND pb.GHTaxCache_u=@UpdateGUID)
			AND gh.Used IS NULL AND gh.TaxonomyWhereClause IS NOT NULL

	SELECT @SQL = STUFF((SELECT N' INSERT INTO @TmpGHID (GH_ID, BT_PB_ID, NUM_Cache) SELECT ' + CAST(gh.GH_ID AS varchar) + ' AS GH_ID, pb.BT_PB_ID, pb.NUM AS NUM_Cache FROM GBL_BaseTable bt INNER JOIN CIC_BT_PB pb ON bt.NUM=pb.NUM AND pb.PB_ID=' + CAST(gh.PB_ID AS varchar) + ' WHERE pb.GHTaxCache_u=@UpdateGUID AND (' + gh.TaxonomyWhereClause + ')'
		FROM CIC_GeneralHeading gh
		WHERE EXISTS(SELECT * FROM CIC_BT_PB pb WHERE gh.PB_ID=pb.PB_ID AND pb.GHTaxCache_u=@UpdateGUID)
			AND gh.Used IS NULL
		FOR XML PATH(N'')), 1, 1, N'')

IF @SQL IS NOT NULL AND @SQL <> '' BEGIN
	SET @SQL = '
	
	DECLARE @TmpGHID TABLE (
		GH_ID int NOT NULL,
		BT_PB_ID int NOT NULL,
		NUM_Cache varchar(8) NOT NULL
	)
	
	' + @SQL + '
	
	MERGE INTO CIC_BT_PB_GH dst
		USING @TmpGHID src
			ON dst.BT_PB_ID=src.BT_PB_ID AND dst.GH_ID=src.GH_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (BT_PB_ID, GH_ID, NUM_Cache)
				VALUES (src.BT_PB_ID, src.GH_ID, src.NUM_Cache)
		WHEN NOT MATCHED BY SOURCE AND dst.GH_ID IN (' + @GHIDs + ')
				AND EXISTS(SELECT * FROM CIC_BT_PB pb WHERE GHTaxCache_u=@UpdateGUID AND pb.BT_PB_ID=dst.BT_PB_ID) THEN
			DELETE
			;
	'
	
	EXEC sp_executesql @SQL, N'@UpdateGUID uniqueidentifier', @UpdateGUID=@UpdateGUID
	
END

SET NOCOUNT OFF

END
GO



ALTER TABLE [dbo].[CIC_BT_TAX_TM] ADD CONSTRAINT [PK_CIC_BT_TAX_TM] PRIMARY KEY CLUSTERED  ([BT_TM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_TAX_TM] ADD CONSTRAINT [IX_CIC_BT_TAX_TM_UniquePair] UNIQUE NONCLUSTERED  ([BT_TAX_ID], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_BT_TAX_TM_BTTAXID] ON [dbo].[CIC_BT_TAX_TM] ([BT_TAX_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_BT_TAX_TM_Code] ON [dbo].[CIC_BT_TAX_TM] ([Code]) INCLUDE ([BT_TAX_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_TAX_TM] WITH NOCHECK ADD CONSTRAINT [FK_CIC_BT_TAX_TM_CIC_BT_TAX] FOREIGN KEY ([BT_TAX_ID]) REFERENCES [dbo].[CIC_BT_TAX] ([BT_TAX_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_TAX_TM] WITH NOCHECK ADD CONSTRAINT [FK_CIC_BT_TAX_TM_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BT_TAX_TM] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_TAX_TM] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_TAX_TM] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_TAX_TM] TO [cioc_login_role]
GO
