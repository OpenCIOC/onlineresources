CREATE TABLE [dbo].[NAICS_Example]
(
[Example_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[Description] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_NAICS_Example_iud] ON [dbo].[NAICS_Example] 
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

UPDATE ncd
	SET	CMP_Examples = dbo.fn_NAICS_FullExamples(ncd.Code,ncd.LangID)
	FROM NAICS_Description ncd
	LEFT JOIN Inserted i
		ON ncd.Code=i.Code AND i.LangID=ncd.LangID
	LEFT JOIN Deleted d
		ON ncd.Code=d.Code AND d.LangID=ncd.LangID
	WHERE i.Code IS NOT NULL OR d.Code IS NOT NULL

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[NAICS_Example] ADD CONSTRAINT [PK_NAICS_Example] PRIMARY KEY CLUSTERED  ([Example_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Example] WITH NOCHECK ADD CONSTRAINT [FK_NAICS_Example_NAICS] FOREIGN KEY ([Code]) REFERENCES [dbo].[NAICS] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[NAICS_Example] ADD CONSTRAINT [FK_NAICS_Example_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[NAICS_Example] TO [cioc_cic_search_role]
GO
