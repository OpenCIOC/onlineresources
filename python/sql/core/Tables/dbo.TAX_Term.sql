CREATE TABLE [dbo].[TAX_Term]
(
[TM_ID] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_TAX_Term_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_TAX_Term_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl1] [char] (1) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CdLvl2] [varchar] (1) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl3] [varchar] (4) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl4] [varchar] (4) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl5] [varchar] (3) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl6] [varchar] (2) COLLATE Latin1_General_100_CI_AI NULL,
[CdLocal] [varchar] (1) COLLATE Latin1_General_100_CI_AI NULL,
[ParentCode] [varchar] (16) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl] [tinyint] NOT NULL CONSTRAINT [DF_TAX_Term_CdLvl] DEFAULT ((0)),
[Authorized] [bit] NOT NULL CONSTRAINT [DF_TAX_Term_Authorized] DEFAULT ((0)),
[Active] [bit] NULL CONSTRAINT [DF_TAX_Term_Active] DEFAULT ((1)),
[Source] [int] NULL,
[Facet] [int] NULL,
[IconURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[IconFA] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[PreferredTerm] [bit] NOT NULL CONSTRAINT [DF_TAX_Term_PreferredTerm] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_Term_iu_Code] ON [dbo].[TAX_Term]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

/* If any part of the Code was updated, update the cached copy of the Code to reflect the change */
IF UPDATE(CdLvl1) OR
	UPDATE(CdLvl2) OR
	UPDATE(CdLvl3) OR
	UPDATE(CdLvl4) OR
	UPDATE(CdLvl5) OR
	UPDATE(CdLvl6) OR
	UPDATE(CdLocal) BEGIN
	UPDATE tt
		SET	Code = cioc_shared.dbo.fn_SHR_TAX_FullCode(i.CdLvl1,i.CdLvl2,i.CdLvl3,i.CdLvl4,i.CdLvl5,i.CdLvl6,i.CdLocal),
			ParentCode = CASE
				WHEN EXISTS(SELECT * FROM TAX_Term WHERE Code=cioc_shared.dbo.fn_SHR_TAX_ParentCode(i.CdLvl1,i.CdLvl2,i.CdLvl3,i.CdLvl4,i.CdLvl5,i.CdLvl6))
					THEN cioc_shared.dbo.fn_SHR_TAX_ParentCode(i.CdLvl1,i.CdLvl2,i.CdLvl3,i.CdLvl4,i.CdLvl5,i.CdLvl6)
				WHEN EXISTS(SELECT * FROM TAX_Term WHERE Code=cioc_shared.dbo.fn_SHR_TAX_ParentCode(i.CdLvl1,i.CdLvl2,i.CdLvl3,i.CdLvl4,i.CdLvl5,i.CdLvl6)+ '-L')
					THEN cioc_shared.dbo.fn_SHR_TAX_ParentCode(i.CdLvl1,i.CdLvl2,i.CdLvl3,i.CdLvl4,i.CdLvl5,i.CdLvl6) + '-L'
				ELSE NULL
				END,
			CdLvl = CASE
				WHEN i.CdLvl2 IS NULL THEN 1
				WHEN i.CdLvl3 IS NULL THEN 2
				WHEN i.CdLvl4 IS NULL THEN 3
				WHEN i.CdLvl5 IS NULL THEN 4
				WHEN i.CdLvl6 IS NULL THEN 5
				ELSE 6
			END
		FROM TAX_Term tt
		INNER JOIN Inserted i
			ON tt.TM_ID=i.TM_ID

	UPDATE sa
		SET SA_Code=i.Code
	FROM TAX_SeeAlso sa
	INNER JOIN Deleted d
		ON d.Code=sa.SA_Code
	INNER JOIN TAX_Term tt
		ON d.TM_ID=tt.TM_ID
	INNER JOIN Inserted i
		ON tt.TM_ID=i.TM_ID
END

/* If the Code has been updated, it may create a different Term hierarchy, and a need to update SRCH_Taxonomy */
IF UPDATE(Code) BEGIN
	DECLARE @TermList TABLE (Code varchar(21)  COLLATE Latin1_General_100_CI_AI)

	/* List of terms updated and their current or former narrower terms */
	INSERT INTO @TermList
		SELECT tm.Code FROM TAX_Term tm
		WHERE EXISTS(SELECT * FROM Inserted i WHERE i.Code LIKE tm.Code + '%')
		OR EXISTS(SELECT * FROM Deleted d WHERE d.Code LIKE tm.Code + '%')

	/* Update English SRCH_Taxonomy*/
	UPDATE cbtd
		SET SRCH_Taxonomy_U = 1
		FROM CIC_BaseTable_Description cbtd
		INNER JOIN CIC_BaseTable cbt
			ON cbtd.NUM=cbt.NUM
		INNER JOIN CIC_BT_TAX pr
			ON cbt.NUM=pr.NUM
		INNER JOIN CIC_BT_TAX_TM fr
			ON pr.BT_TAX_ID=fr.BT_TAX_ID
		INNER JOIN @TermList tl
			ON fr.Code=tl.Code
	WHERE cbtd.SRCH_Taxonomy_U <> 1
		AND cbtd.LangID=0

	/* Update French SRCH_Taxonomy*/
	UPDATE cbtd
		SET SRCH_Taxonomy_U = 1
		FROM CIC_BaseTable_Description cbtd
		INNER JOIN CIC_BaseTable cbt
			ON cbtd.NUM=cbt.NUM
		INNER JOIN CIC_BT_TAX pr
			ON cbt.NUM=pr.NUM
		INNER JOIN CIC_BT_TAX_TM fr
			ON pr.BT_TAX_ID=fr.BT_TAX_ID
		INNER JOIN @TermList tl
			ON fr.Code=tl.Code
	WHERE cbtd.SRCH_Taxonomy_U <> 1
		AND cbtd.LangID=2

END

SET NOCOUNT OFF
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_Term_iud_Search] ON [dbo].[TAX_Term] 
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

IF UPDATE(ParentCode) BEGIN

	WITH ParentList (Code, ParentCode) AS
	(
		SELECT tm.Code, tm2.Code AS ParentCode
			FROM TAX_Term tm
			INNER JOIN TAX_Term tm2
				ON tm.ParentCode=tm2.Code
		UNION ALL
			SELECT cm1.Code, p.ParentCode
			FROM TAX_Term cm1
			INNER JOIN ParentList p
				ON cm1.ParentCode=p.Code
	)
	
	MERGE INTO TAX_Term_ParentList AS cmpl
	USING ParentList p
		ON cmpl.Code=p.Code AND cmpl.ParentCode=p.ParentCode
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (Code, ParentCode) VALUES (p.Code, p.ParentCode)
	WHEN NOT MATCHED BY SOURCE
		THEN DELETE
	OPTION (MAXRECURSION 30);

END

SET NOCOUNT OFF
GO

ALTER TABLE [dbo].[TAX_Term] ADD 
CONSTRAINT [PK_TAX_Term] PRIMARY KEY CLUSTERED  ([Code]) ON [PRIMARY]
GO
CREATE STATISTICS [ST_TAX_Term_CodeCdLvl1ParentCode] ON [dbo].[TAX_Term] ([Code], [CdLvl1], [ParentCode])

GO
CREATE STATISTICS [ST_Tax_Term_ParentCodeCodeCdLvl] ON [dbo].[TAX_Term] ([ParentCode], [Code], [CdLvl])

GO
CREATE STATISTICS [ST_TAX_Term_ParentCodeCdLvl1] ON [dbo].[TAX_Term] ([ParentCode], [CdLvl1])

GO
ALTER TABLE [dbo].[TAX_Term] ADD CONSTRAINT [IX_TAX_Term_Code] UNIQUE NONCLUSTERED  ([CdLvl1], [CdLvl2], [CdLvl3], [CdLvl4], [CdLvl5], [CdLvl6], [CdLocal]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_CdLvl] ON [dbo].[TAX_Term] ([TM_ID], [CdLvl]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_ActiveCdLvl2InclCode] ON [dbo].[TAX_Term] ([Active], [CdLvl2]) INCLUDE ([Code]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_ActiveCodeCdLvl1CdLvl] ON [dbo].[TAX_Term] ([Active], [Code], [CdLvl1], [CdLvl]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_CdLvl1CodeCdLvl] ON [dbo].[TAX_Term] ([CdLvl1], [Code], [CdLvl]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_FullCode] ON [dbo].[TAX_Term] ([Code]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_ParentCodeCode] ON [dbo].[TAX_Term] ([ParentCode], [Code]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_ParentCode] ON [dbo].[TAX_Term] ([ParentCode]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_ParentCodeActive] ON [dbo].[TAX_Term] ([ParentCode], [Active]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TAX_Term_Active] ON [dbo].[TAX_Term] ([Active]) ON [PRIMARY]

ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLocal] CHECK (([dbo].[fn_TAX_CheckLocal]([CdLocal],[Authorized])=(0)))
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLvl1] CHECK (([CdLvl1] like '[A-Z]'))
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLvl2] CHECK (([CdLvl2] like '[A-Z]'))
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLvl3] CHECK (([CdLvl3] like '[0-9][0-9][0-9][0-9]'))
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLvl4] CHECK (([CdLvl4] like '[0-9][0-9][0-9][0-9]'))
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLvl5] CHECK (([CdLvl5] like '[0-9][0-9][0-9]'))
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD
CONSTRAINT [CK_TAX_Term_CdLvl] CHECK (([CdLvl]>=(1) AND [CdLvl]<=(6)))
ALTER TABLE [dbo].[TAX_Term] ADD
CONSTRAINT [CK_TAX_Term_CdLvl6] CHECK (([CdLvl6] like '[0-9][0-9]'))
GO

ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD CONSTRAINT [FK_TAX_Term_TAX_Facet] FOREIGN KEY ([Facet]) REFERENCES [dbo].[TAX_Facet] ([FC_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[TAX_Term] WITH NOCHECK ADD CONSTRAINT [FK_TAX_Term_TAX_SourceType] FOREIGN KEY ([Source]) REFERENCES [dbo].[TAX_Source] ([TAX_SRC_ID])
GO
GRANT SELECT ON  [dbo].[TAX_Term] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[TAX_Term] TO [cioc_login_role]
GO
