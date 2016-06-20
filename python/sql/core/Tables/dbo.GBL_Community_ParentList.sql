CREATE TABLE [dbo].[GBL_Community_ParentList]
(
[CM_ID] [int] NOT NULL,
[Parent_CM_ID] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_Community_ParentList] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Community_ParentList] TO [cioc_login_role]
GO

ALTER TABLE [dbo].[GBL_Community_ParentList] ADD CONSTRAINT [PK_GBL_Community_ParentList] PRIMARY KEY CLUSTERED  ([CM_ID], [Parent_CM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Community_ParentList_CMIDInclParentCMID] ON [dbo].[GBL_Community_ParentList] ([CM_ID]) INCLUDE ([Parent_CM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Community_ParentList_ParentCMID] ON [dbo].[GBL_Community_ParentList] ([Parent_CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_ParentList] ADD CONSTRAINT [FK_GBL_Community_ParentList_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_ParentList] ADD CONSTRAINT [FK_GBL_Community_ParentList_GBL_Community_Parent] FOREIGN KEY ([Parent_CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID])
GO
