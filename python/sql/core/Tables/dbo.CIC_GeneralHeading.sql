CREATE TABLE [dbo].[CIC_GeneralHeading]
(
[GH_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[PB_ID] [int] NOT NULL,
[HeadingGroup] [int] NULL,
[Used] [bit] NULL,
[TaxonomyRestrict] [bit] NOT NULL CONSTRAINT [DF_CIC_GeneralHeading_TaxonomyRestrict] DEFAULT ((0)),
[TaxonomyName] [bit] NOT NULL CONSTRAINT [DF_CIC_GeneralHeading_TaxonomyName] DEFAULT ((0)),
[TaxonomyWhereClause] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NonPublic] [bit] NOT NULL CONSTRAINT [DF_CIC_GeneralHeading_NonPublic] DEFAULT ((0)),
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_GeneralHeading_DisplayOrder] DEFAULT ((0)),
[IconNameFull] [varchar] (65) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_CIC_GeneralHeading_PBIDUsedInclGHIDTaxonomyWhereClause] ON [dbo].[CIC_GeneralHeading] ([PB_ID], [Used]) INCLUDE ([GH_ID], [TaxonomyWhereClause]) ON [PRIMARY]

GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[tr_CIC_GeneralHeading_u] ON [dbo].[CIC_GeneralHeading]
FOR UPDATE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 15-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @SQL nvarchar(max),
		@GHIDs nvarchar(max)


IF UPDATE(TaxonomyWhereClause) BEGIN

	SELECT @SQL = COALESCE(@SQL,'') + '
	INSERT INTO @TmpGHID (GH_ID, BT_PB_ID, NUM_Cache)
	SELECT ' + CAST(gh.GH_ID AS varchar) + ' AS GH_ID, pb.BT_PB_ID, pb.NUM
	FROM GBL_BaseTable bt
	INNER JOIN CIC_BT_PB pb
		ON bt.NUM=pb.NUM AND pb.PB_ID=' + CAST(gh.PB_ID AS varchar) + '
	WHERE (' + gh.TaxonomyWhereClause + ')
	
	',
		@GHIDs = COALESCE(@GHIDs + ',','') + CAST(gh.GH_ID AS varchar)
		FROM CIC_GeneralHeading gh
		INNER JOIN inserted i
			ON gh.GH_ID=i.GH_ID
		WHERE gh.Used IS NULL AND gh.TaxonomyWhereClause IS NOT NULL

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
			WHEN NOT MATCHED BY SOURCE AND dst.GH_ID IN (' + @GHIDs + ') THEN
				DELETE
				;
		'
		
		EXEC sp_executesql @SQL
		
	END
END

SET NOCOUNT OFF


GO

ALTER TABLE [dbo].[CIC_GeneralHeading] ADD CONSTRAINT [PK_GeneralHeading] PRIMARY KEY CLUSTERED  ([GH_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading] ADD CONSTRAINT [FK_CIC_GeneralHeading_CIC_GeneralHeading_Group] FOREIGN KEY ([HeadingGroup]) REFERENCES [dbo].[CIC_GeneralHeading_Group] ([GroupID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[CIC_GeneralHeading] ADD CONSTRAINT [FK_CIC_GeneralHeading_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_GeneralHeading] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_GeneralHeading] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_GeneralHeading] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_GeneralHeading] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_GeneralHeading] TO [cioc_login_role]
GO
