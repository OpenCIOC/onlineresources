CREATE TABLE [dbo].[GBL_Community_AltAreaSearch]
(
[CM_ID] [int] NOT NULL,
[Search_CM_ID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Community_AltAreaSearch_iud_Search] ON [dbo].[GBL_Community_AltAreaSearch] 
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON;

WITH ParentList (CM_ID, Parent_CM_ID) AS
(
	SELECT CM_ID, ParentCommunity
		FROM GBL_Community
		WHERE ParentCommunity IS NOT NULL
	UNION
	SELECT aas.Search_CM_ID, aas.CM_ID
		FROM GBL_Community_AltAreaSearch aas
	UNION
	SELECT aas.CM_ID, cm.ParentCommunity
		FROM GBL_Community_AltAreaSearch aas
		INNER JOIN GBL_Community cm
			ON aas.Search_CM_ID=cm.CM_ID AND cm.ParentCommunity IS NOT NULL
	UNION ALL
		SELECT cm1.CM_ID, p.Parent_CM_ID
		FROM GBL_Community cm1
		INNER JOIN ParentList p
			ON cm1.ParentCommunity=p.CM_ID
)

MERGE INTO GBL_Community_ParentList AS cmpl
USING ParentList p
ON cmpl.CM_ID=p.CM_ID AND cmpl.Parent_CM_ID=p.Parent_CM_ID
WHEN NOT MATCHED BY TARGET
	THEN INSERT (CM_ID, Parent_CM_ID) VALUES (p.CM_ID, p.Parent_CM_ID)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE
OPTION (MAXRECURSION 30);

MERGE INTO GBL_Community_ParentList AS cmpl
USING (
	SELECT DISTINCT aas.CM_ID, pl.Parent_CM_ID
		FROM GBL_Community_AltAreaSearch aas
		INNER JOIN GBL_Community_ParentList pl
			ON pl.CM_ID=aas.Search_CM_ID AND pl.Parent_CM_ID<>aas.CM_ID
		) p
	ON cmpl.CM_ID=p.CM_ID AND cmpl.Parent_CM_ID=p.Parent_CM_ID
WHEN NOT MATCHED BY TARGET
	THEN INSERT (CM_ID, Parent_CM_ID) VALUES (p.CM_ID, p.Parent_CM_ID)
	;

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Community_AltAreaSearch] ADD CONSTRAINT [CK_GBL_Community_AltAreaSearch] CHECK (([CM_ID]<>[Search_CM_ID]))
GO
ALTER TABLE [dbo].[GBL_Community_AltAreaSearch] ADD CONSTRAINT [PK_GBL_Community_AltAreaSearch] PRIMARY KEY CLUSTERED  ([CM_ID], [Search_CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_AltAreaSearch] ADD CONSTRAINT [FK_GBL_Community_AltAreaSearch_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_AltAreaSearch] ADD CONSTRAINT [FK_GBL_Community_AltAreaSearch_GBL_Community_Search] FOREIGN KEY ([Search_CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID])
GO
