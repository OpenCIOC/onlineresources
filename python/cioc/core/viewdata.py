# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================


import logging

from pyramid.decorator import reify

import cioc.core.constants as const
from cioc.core.basetypes import IsIDType
from cioc.core.security import get_remote_ip

log = logging.getLogger(__name__)


non_bool_view_values = {
    "ViewType",
    "ViewName",
    "HidePastDueBy",
    "Template",
    "PrintTemplate",
    "CommSrchWrapAt",
    "PB_ID",
    "QuickListDropDown",
    "QuickListName",
    "QuickListWrapAt",
    "QuickListPubHeadings",
    "TaxDefnLevel",
    "Title",
    "BottomMessage",
    "Culture",
    "CommunitySetID",
    "AreaServed",
    "CanSeeNonPublicPub",
    "AlsoNotify",
    "AssignSuggestionsTo",
    "SearchTitleOverride",
    "OrganizationNames",
    "OrganizationsWithWWW",
    "OrganizationsWithVolOps",
    "BrowseByOrg",
    "FindAnOrgBy",
    "ViewProgramsAndServices",
    "ClickToViewDetails",
    "OrgProgramNames",
    "Organization",
    "MultipleOrgWithSimilarMap",
    "NoResultsMsg",
    "OrgLevel1Name",
    "OrgLevel2Name",
    "OrgLevel3Name",
    "ResultsPageSize",
    "PDFBottomMessage",
    "PDFBottomMargin",
    "GoogleTranslateDisclaimer",
    "TagLine",
    "DefaultPrintProfile",
}


class ViewType:
    def __init__(self, view, cultures, request):
        self.view = view
        self.request = request
        self.Cultures = cultures
        self._cache = {}

    def __getattr__(self, key):
        if key not in self._cache:
            val = self._cache[key] = self._get(key)
            return val  # skip dict lookup

        return self._cache[key]

    def _get(self, key):
        view = self.view

        val = getattr(view, key, None)

        if key in non_bool_view_values:
            return val

        if key == "LimitedView":
            return bool(val and view and view.PB_ID)

        if key == "AlertColumn":
            return bool(self.request.user and val)

        if key == "UseTaxonomy":
            return bool(val and self.request.dboptions.UseTaxonomy)

        return bool(val)

    def __nonzero__(self):
        return bool(self.view)

    __bool__ = __nonzero__


class ViewData:
    def __init__(self, request):
        self.request = request

        passvars = request.passvars
        use_view_cic = request.params.get("UseCICVwTmp", None)
        use_view_cic_tmp = None
        try:
            use_view_cic = int(use_view_cic)
            if not IsIDType(use_view_cic):
                raise ValueError(use_view_cic)

            use_view_cic_tmp = use_view_cic

        except (ValueError, TypeError):
            use_view_cic = passvars.UseViewCIC

        use_view_vol = request.params.get("UseVOLVwTmp", None)
        use_view_vol_tmp = None
        try:
            use_view_vol = int(use_view_vol)
            if not IsIDType(use_view_vol):
                raise ValueError(use_view_vol)

            use_view_vol_tmp = use_view_vol

        except (ValueError, TypeError):
            use_view_vol = passvars.UseViewVOL

        with request.connmgr.get_connection() as conn:
            cursor = conn.execute(
                """
                        DECLARE @RC int, @ErrMsg nvarchar(500)
                        EXEC @RC = dbo.sp_GBL_Users_s_View ?,?,?,?,?,?,?,?, @ErrMsg=@ErrMsg OUTPUT
                        """,
                request.dboptions.MemberID,
                request.user.User_ID,
                request.pageinfo.ThisPageFull,
                use_view_cic,
                use_view_vol,
                request.host,
                not bool(passvars.RequestLn),
                get_remote_ip(request),
            )

            culture = cursor.fetchone()
            if culture:
                passvars.setDefaultCultureVars(culture.Culture)

            cursor.nextset()

            self.cic = _get_view_type(cursor, request)

            if (
                self.cic.ViewType != passvars.UseViewCIC
                and self.cic.ViewType != request.params.get("UseCICVwTmp", None)
            ):
                passvars.UseViewCIC = None
                passvars._clear_cached_values()
                passvars._notify()

            cursor.nextset()

            self.vol = _get_view_type(cursor, request)

            cursor.nextset()

            tmpl = '<div id="page-message-%s" class="page-message">%s</div>'
            page_messages = (
                (x.PageMsgID, x.PageMsg)
                for x in cursor.fetchall()
                if x.VisiblePrintMode or not self.PrintMode
            )
            self.PageMsgs = "".join(tmpl % x for x in page_messages)

            cursor.close()

        pv_use_cic_vw = passvars.UseViewCIC

        if (use_view_cic_tmp is not None and use_view_cic_tmp != self.cic.ViewType) or (
            pv_use_cic_vw is not None and pv_use_cic_vw != self.cic.ViewType
        ):
            passvars.UseViewCIC = None

        pv_use_vol_vw = passvars.UseViewVOL
        if (use_view_vol_tmp is not None and use_view_cic_tmp != self.vol.ViewType) or (
            pv_use_vol_vw is not None and pv_use_vol_vw != self.vol.ViewType
        ):
            passvars.UseViewVOL = None

    def UpdateCulture(self):
        """this should be run as soon as pageinfo is available"""
        culture = None
        db_area = self.request.pageinfo.DbArea
        if db_area == const.DM_CIC and self.cic:
            culture = self.cic.Culture

        if db_area == const.DM_VOL and self.vol:
            culture = self.vol.Culture

        if culture:
            self.request.language.setSystemLanguage(culture)

    @reify
    def dom(self):
        db_area = self.request.pageinfo.DbArea
        if db_area == const.DM_CIC:
            return self.cic
        if db_area == const.DM_VOL:
            return self.vol

        return None

    @property
    def ViewType(self):
        db_area = self.request.pageinfo.DbArea
        if db_area == const.DM_CIC:
            return self.cic.ViewType
        if db_area == const.DM_VOL:
            return self.vol.ViewType

        return None

    @reify
    def CanSeeDeleted(self):
        db_area = self.request.pageinfo.DbArea

        if db_area == const.DM_CIC:
            return self.cic.CanSeeDeleted
        if db_area == const.DM_VOL:
            return self.vol.CanSeeDeleted

    # Begin CIC "WHERE" Clause Setup

    _no_del_cic_sql = "(btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())"

    @reify
    def WhereClauseCIC(self):
        parts = []
        cic = self.cic

        if self.request.dboptions.OtherMembersActive:
            parts.append(
                "(bt.MemberID=%d OR EXISTS(SELECT * FROM GBL_BT_SharingProfile pr "
                "INNER JOIN GBL_SharingProfile shp ON pr.ProfileID=shp.ProfileID AND shp.Active=1 AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=%d)) "
                "WHERE NUM=bt.NUM AND ShareMemberID_Cache=%d))"
                % (
                    self.request.dboptions.MemberID,
                    self.cic.ViewType,
                    self.request.dboptions.MemberID,
                )
            )
        elif self.request.dboptions.OtherMembers:
            parts.append("(bt.MemberID=%d)" % self.request.dboptions.MemberID)

        if not cic.CanSeeNonPublic:
            parts.append("(btd.NON_PUBLIC=0)")

        pbid = cic.PB_ID
        if pbid:
            parts.append(
                "(EXISTS(SELECT pb.BT_PB_ID FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=%d))"
                % pbid
            )

        past_due = cic.HidePastDueBy
        if past_due is not None:
            parts.append(
                "(btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < %d))"
                % past_due
            )

        if not cic.CanSeeDeleted:
            parts.append(self._no_del_cic_sql)

        if parts:
            return "(" + " AND ".join(parts) + ")"

        return ""

    @reify
    def WhereClauseCICNoDel(self):
        sql = self.WhereClauseCIC
        if not self.cic.CanSeeDeleted:
            return sql

        if sql:
            sql = "".join((sql[:-1], " AND ", self._no_del_cic_sql, ")"))
            return sql

        return "(" + self._no_del_cic_sql + ")"

    # Begin Volunteer "WHERE" Clause Setup

    _no_del_vol_sql = "(vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE())"

    @reify
    def WhereClauseVOL(self):
        if not self.request.dboptions.UseVOL:
            return ""

        parts = []
        vol = self.vol

        if self.request.dboptions.OtherMembersActive:
            parts.append(
                "(vo.MemberID=%d OR EXISTS(SELECT * FROM VOL_OP_SharingProfile pr "
                "INNER JOIN GBL_SharingProfile shp ON pr.ProfileID=shp.ProfileID AND shp.Active=1 AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View WHERE ProfileID=shp.ProfileID AND ViewType=%d)) "
                "WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=%d))"
                % (
                    self.request.dboptions.MemberID,
                    self.vol.ViewType,
                    self.request.dboptions.MemberID,
                )
            )
        elif self.request.dboptions.OtherMembers:
            parts.append("(vo.MemberID=%d)" % self.request.dboptions.MemberID)

        com_set = vol.CommunitySetID
        if com_set:
            parts.append(
                "EXISTS(SELECT * FROM VOL_OP_CommunitySet vcs "
                "WHERE vcs.VNUM=vo.VNUM AND vcs.CommunitySetID=%d)" % com_set
            )

        if not vol.CanSeeNonPublic:
            parts.append("(vod.NON_PUBLIC=0)")

        past_due = vol.HidePastDueBy
        if past_due is not None:
            parts.append(
                "(vod.UPDATE_SCHEDULE IS NOT NULL AND "
                "(DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < %d))" % past_due
            )

        if not vol.CanSeeExpired:
            parts.append("(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())")

        if not vol.CanSeeDeleted:
            parts.append(self._no_del_vol_sql)

        if parts:
            return "(" + " AND ".join(parts) + ")"

        return ""

    @reify
    def WhereClauseVOLNoDel(self):
        if not self.request.dboptions.UseVOL:
            return ""

        sql = self.WhereClauseVOL
        if not self.vol.CanSeeDeleted:
            return sql

        if sql:
            sql = "".join((sql[:-1], " AND ", self._no_del_vol_sql, ")"))
            return sql

        return "(" + self._no_del_vol_sql + ")"

    @reify
    def PrintMode(self):
        request = self.request

        # getattr to smooth over upgrade
        context = getattr(self.request, "context", None)
        force_print_mode = False
        if context:
            force_print_mode = context.force_print_mode

        print_mode = request.params.get("PrintMd") == "on" and (
            request.user or request.dboptions.PrintModePublic
        )
        if print_mode:
            # log.debug('ThisPageFull: %s, %s', request.pageinfo.ThisPageFull, request.pageinfo.ThisPage)
            if request.pageinfo.ThisPageFull.startswith("record/"):
                # log.debug('Check _printmode_cic_details_re')
                print_mode = bool(
                    _printmode_cic_details_re.match(request.pageinfo.ThisPage)
                )
            elif request.pageinfo.ThisPageFull.startswith("volunteer/record/"):
                print_mode = bool(
                    _printmode_cic_details_re.match(request.pageinfo.ThisPage)
                )
            else:
                print_mode = bool(_printmode_re.match(request.pageinfo.ThisPage))

        # log.debug('print mode: %s', print_mode)
        return print_mode or force_print_mode


import re

_printmode_re = re.compile(
    "^(details.asp)|(browseby.*)|(mailform.asp)|(processRecordList.asp)|(report_.*)|(.*results.asp)|(.*_list.asp)|(.*stats.*)|(whatsnew.asp)|(chklst_edit.asp)|(users(_history)?.asp)|(viewlist.asp)|(checklist)|(listvalues)|(interests)|(publication)$",
    re.I,
)
_printmode_cic_details_re = re.compile("^[A-Z]{3}[0-9]{4,5}$", re.I)
_printmode_vol_details_re = re.compile("^V-[A-Z]{3}[0-9]{4,5}$", re.I)


def _get_view_type(cursor, request):
    view = cursor.fetchone()

    cursor.nextset()

    cultures = {x.Culture: x.LanguageName for x in cursor}

    return ViewType(view, cultures, request)
