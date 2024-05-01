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
from functools import partial

from cioc.web.admin.userapicreds import AdminUserApiCredsContext


def includeme(config):
    urlprefix = "/admin/"

    # /admin/billinginfo
    config.add_route("admin_billinginfo", urlprefix + "billinginfo")

    # /admin/checklist
    checklist_factory = "cioc.web.admin.checklists.ChecklistContext"
    # config.add_route('admin_checklists_other', urlprefix + 'checklist/other', factory=checklist_factory)
    config.add_route(
        "admin_checklists_hide", urlprefix + "checklist/hide", factory=checklist_factory
    )
    config.add_route(
        "admin_checklists_sharedstate",
        urlprefix + "checklist/sharedstate",
        factory=checklist_factory,
    )
    config.add_route(
        "admin_checklists_local",
        urlprefix + "checklist/local",
        factory=checklist_factory,
    )
    config.add_route(
        "admin_checklists_shared",
        urlprefix + "checklist/shared",
        factory=checklist_factory,
    )
    config.add_route(
        "admin_checklists", urlprefix + "checklist", factory=checklist_factory
    )

    # /admin/community/*
    config.add_route("admin_community_index", urlprefix + "community")
    config.add_route("admin_community", urlprefix + "community/{action}")

    # /admin/domainmap
    config.add_route("admin_domainmap", urlprefix + "domainmap")

    # /admin/datafeedapikey/*
    config.add_route("admin_datafeedapikey_index", urlprefix + "datafeedapikey")
    config.add_route("admin_datafeedapikey", urlprefix + "datafeedapikey/{action}")

    # /admin/email/*
    config.add_route("admin_email_index", urlprefix + "email")
    config.add_route("admin_email", urlprefix + "email/{action}")

    # /admin/excelprofile/*
    config.add_route("admin_excelprofile_index", urlprefix + "excelprofile")
    config.add_route("admin_excelprofile", urlprefix + "excelprofile/{action}")

    # /admin/fielddisplay
    config.add_route("admin_fielddisplay", urlprefix + "fielddisplay")

    config.add_route("admin_fieldhide", urlprefix + "fieldhide")

    # /admin/fieldhelp/*
    config.add_route("admin_fieldhelp", urlprefix + "fieldhelp/{action}")

    # /admin/fieldradio
    config.add_route("admin_fieldradio", urlprefix + "fieldradio")

    # /admin/ganalytics
    config.add_route("admin_ganalytics", urlprefix + "ganalytics")

    # /admin/general
    config.add_route("admin_generalsetup", urlprefix + "general")

    # /admin/icarol/unmatched
    config.add_route("admin_icarolunmatched_index", urlprefix + "icarol/unmatched")

    # /admin/interests/*
    config.add_route("admin_interests_index", urlprefix + "interests")
    config.add_route("admin_interests", urlprefix + "interests/{action}")

    # /admin/pagehelp
    config.add_route("admin_pagehelp", urlprefix + "pagehelp")

    # /admin/pages
    config.add_route("admin_pages_index", urlprefix + "pages")
    config.add_route("admin_pages", urlprefix + "pages/{action}")

    # /admin/layout/*
    config.add_route("admin_template_layout_index", urlprefix + "layout")
    config.add_route("admin_template_layout", urlprefix + "layout/{action}")

    # /admin/listsvalues
    config.add_route(
        "admin_listvalues",
        urlprefix + "listvalues",
        factory="cioc.web.admin.listvalues.ListValuesContext",
    )

    # /admin/mappingsystem/*
    config.add_route("admin_mappingsystem_index", urlprefix + "mappingsystem")
    config.add_route("admin_mappingsystem", urlprefix + "mappingsystem/{action}")

    # /admin/naics/*
    config.add_route("admin_naics_index", urlprefix + "naics")
    config.add_route("admin_naics", urlprefix + "naics/{action}")

    # /admin/notices/*
    config.add_route("admin_notices_index", urlprefix + "notices")
    config.add_route("admin_notices", urlprefix + "notices/{action}")

    # /admin/offlinetools/*
    config.add_route("admin_offlinetools", urlprefix + "offlinetools"),

    # /admin/pagetitle/*
    config.add_route("admin_pagetitle_index", urlprefix + "pagetitle")
    config.add_route("admin_pagetitle", urlprefix + "pagetitle/{action}")

    # /admin/sharingprofile/*
    config.add_route("admin_sharingprofile_index", urlprefix + "sharingprofile")
    config.add_route(
        "admin_sharingprofile",
        urlprefix + "sharingprofile/{action}",
        factory="cioc.web.admin.sharingprofile.SharingProfileContext",
    )

    # /admin/mappingsystem/*
    config.add_route("admin_socialmedia_index", urlprefix + "socialmedia")
    config.add_route("admin_socialmedia", urlprefix + "socialmedia/{action}")

    # /admin/sysinfo
    config.add_route("admin_sysinfo", urlprefix + "sysinfo")

    # /admin/template/*
    config.add_route("admin_template_index", urlprefix + "template")
    config.add_route("admin_template", urlprefix + "template/{action}")

    # /admin/thesaurus/*
    # config.add_route('admin_thesaurus_index', urlprefix + 'thesaurus')
    config.add_route(
        "admin_thesaurus",
        urlprefix + "thesaurus/{action}",
        factory="cioc.web.admin.thesaurus.ThesaurusContext",
    )

    factory = partial(AdminUserApiCredsContext, list_page=True)
    config.add_route(
        "admin_userapicreds_index", urlprefix + "userapicreds", factory=factory
    )
    config.add_route(
        "admin_userapicreds",
        urlprefix + "userapicreds/{action}",
        factory="cioc.web.admin.userapicreds.AdminUserApiCredsContext",
    )

    # /admin/vacancy
    config.add_route("admin_vacancy", urlprefix + "vacancy/{action}")

    # /admin/view/*
    config.add_route("admin_view_index", urlprefix + "view")
    config.add_route("admin_view", urlprefix + "view/{action}")

    # /admin/applicationsurvey/*
    config.add_route("admin_applicationsurvey_index", urlprefix + "applicationsurvey")
    config.add_route("admin_applicationsurvey", urlprefix + "applicationsurvey/{action}")
