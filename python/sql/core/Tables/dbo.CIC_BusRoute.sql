CREATE TABLE [dbo].[CIC_BusRoute]
(
[BR_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[RouteNumber] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Municipality] [int] NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_BusRoute_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BusRoute] ADD CONSTRAINT [PK_CIC_BusRoute] PRIMARY KEY CLUSTERED  ([BR_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BusRoute_UniquePair] ON [dbo].[CIC_BusRoute] ([RouteNumber], [Municipality]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BusRoute] ADD CONSTRAINT [FK_CIC_BusRoute_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_BusRoute] ADD CONSTRAINT [FK_CIC_BusRoute_GBL_Community] FOREIGN KEY ([Municipality]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BusRoute] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BusRoute] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BusRoute] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BusRoute] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BusRoute] TO [cioc_login_role]
GO
