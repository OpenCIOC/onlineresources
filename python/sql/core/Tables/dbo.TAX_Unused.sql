CREATE TABLE [dbo].[TAX_Unused]
(
[UT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_TAX_Unused_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_TAX_Unused_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_TAX_Unused_LangID] DEFAULT ((0)),
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Term] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Authorized] [bit] NULL CONSTRAINT [DF_TAX_Unused_Authorized] DEFAULT ((0)),
[Active] [bit] NULL CONSTRAINT [DF_TAX_Unused_Active] DEFAULT ((1)),
[Source] [int] NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [TAX_Unused_CodeLangIDActiveIncludeTerm] ON [dbo].[TAX_Unused] ([Code], [LangID], [Active]) INCLUDE ([Term]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_Unused_iud] ON [dbo].[TAX_Unused]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

DECLARE @TermList TABLE (Code varchar(21) COLLATE Latin1_General_100_CI_AI)

/* If the French or English Term name has changed, identify records that use that term,
 directly or indirectly through a broader term, and update the SRCH_Taxonomy field. */
/* List of used terms and their narrower terms that were associated with the terms that have been deleted */
 IF NOT EXISTS(SELECT * FROM Inserted) BEGIN
	INSERT INTO @TermList
		SELECT tm.Code FROM TAX_Term tm
		WHERE EXISTS(SELECT * FROM Deleted d
			WHERE d.Code LIKE tm.Code + '%')

/* List of used terms and their narrower terms that are associated with the terms that have updated names */
END ELSE IF UPDATE(Term) OR UPDATE(LangID) OR UPDATE(Active) BEGIN
	INSERT INTO @TermList
		SELECT tm.Code FROM TAX_Term tm
		WHERE EXISTS(SELECT * FROM Inserted i
			WHERE i.Code LIKE tm.Code + '%')
END

/* Update SRCH_Taxonomy*/
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

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[TAX_Unused] ADD CONSTRAINT [PK_TAX_Unused] PRIMARY KEY CLUSTERED  ([UT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAX_Unused_Term] ON [dbo].[TAX_Unused] ([Code], [LangID], [Term]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Unused] WITH NOCHECK ADD CONSTRAINT [FK_TAX_Unused_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[TAX_Unused] ADD CONSTRAINT [FK_TAX_Unused_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[TAX_Unused] WITH NOCHECK ADD CONSTRAINT [FK_TAX_Unused_TAX_Source] FOREIGN KEY ([Source]) REFERENCES [dbo].[TAX_Source] ([TAX_SRC_ID]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[TAX_Unused] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[TAX_Unused] TO [cioc_login_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[TAX_Unused] KEY INDEX [PK_TAX_Unused] ON [Taxonomy] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO
ALTER FULLTEXT INDEX ON [dbo].[TAX_Unused] ADD ([Term] LANGUAGE 1033)
GO
