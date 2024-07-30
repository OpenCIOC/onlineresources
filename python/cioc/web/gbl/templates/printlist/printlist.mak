<%doc>
=========================================================================================
 Copyright 2024 KCL Software Solutions Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
=========================================================================================
</%doc>
<!doctype html>
<%!
FTYPE_HEADING = 1
FTYPE_BASIC = 2
FTYPE_FULL = 3
FTYPE_CONTINUE = 4

from markupsafe import Markup
%>

<html>
    <head>
	<title>${profile.PageTitle}</title>
%if profile.StyleSheet:
<link rel="STYLESHEET" type="text/css" href="${profile.StyleSheet}">
%endif

<style>
@page{
  @bottom-right {
    content: counter(page);
  }
}

ol.toc-list li a::after {
    content: ' ' leader(dotted) target-counter(attr(href), page);
}

.toc-list, .toc-list ol {
  list-style-type: none;
}

.toc-list {
  padding: 0;
}

.toc-list ol {
  padding-inline-start: 2ch;
}

.toc-list li > a {
    text-decoration: none;
    display: grid;
    grid-template-columns: auto max-content;
    align-items: end;
}

.toc-list li > a > .page {
    text-align: right;
}

.visually-hidden {
    clip: rect(0 0 0 0);
    clip-path: inset(100%);
    height: 1px;
    overflow: hidden;
    position: absolute;
    width: 1px;
    white-space: nowrap;
}

.toc-list li > a > .title {
    position: relative;
    overflow: hidden;
}

</style>
    </head>
    <body bgcolor="#FFFFFF" text="#000000">
${profile.Header or "" |n}
%if message and not profile.MsgBeforeRecord:
<p>${message}</p>
%endif

%if include_toc:
<h1>${_('Contents')}</h1>
<ol class="toc-list" role="list">
%for (group_order, group_name, group_id), headings in heading_groups:
    %if group_id:
    <li>
	<a href="#heading-group-${group_id}"><span class="title">${group_name}</span></a>
	<ol role="list">
    %endif
	%for heading in headings:
	    <li><a href="#heading-${heading.GH_ID}"><span class="title">${heading.GeneralHeading}<span class="leaders" aria-hidden="true"></span></span><span class="xref page" href="#heading-${heading.GH_ID}"></span></a></li>
	%endfor
    %if group_id:
	</ol>
    </li>
    %endif
%endfor
</ol>
<div style="page-break-before: always"></div>
%endif

<% record_ids_seen = set() %>

%for group, headings in grouped_records:
%if group:
<% group_order, group_name, group_id = group %>
%if group_id:
<div class="printlist-heading-group" id="heading-group-${group_id}">
<h1 class="printlist-heading-group-name" id="heading-group-name-${group_id}">${group_name}</h1>
%endif
%else:
<% group_id = group_name = group_order = None %>
%endif

%for heading, records in headings:
%if heading:
<% heading_order, heading_name, heading_id = heading %>
%if heading_id:
%if group_id:
<div class="printlist-heading" id="heading-${heading_id}">
<h2 class="printlist-heading-name" id="heading-name-${heading_id}">${heading_name}</h2>
%else:
<div class="printlist-heading-group" id="heading-${heading_id}">
<h1 class="printlist-heading-group-name" id="heading-name-${heading_id}">${heading_name}</h1>
%endif
%endif
%else:
<% heading_id = heading_name = heading_order = None %>
%endif

<% is_first = True %>

%for full_record, record in records:
<%
record_id = getattr(full_record, "XVNUM" if request.pageinfo.DbArea == const.DM_VOL else "XNUM")
div_id = Markup(f'id="printlist-record-{record_id}"') if (record_id not in record_ids_seen) else ""
record_ids_seen.add(record_id)
%>
    %if not is_first:
	%if profile.PageBreak:
	<div style="page-break-before: always"></div>
	%endif
	${profile.Separator or "" |n}
    %else:
    <% is_first = False %>
    %endif

<div class="printlist-record" ${div_id}>

    %if message and profile.MsgBeforeRecord:
    <p>${message}</p>
    %endif
<%
prev_content = False
prev_in_table = False
prev_start_tags = ""
prev_end_tags = ""
table_tag = Markup(f'<table class="{profile.TableClass}">' if profile.TableClass else '<table class="NoBorder cell-padding-4">')
%>
    %for i, field in enumerate(fields):
	%if prev_content and not field.FieldTypeID == FTYPE_CONTINUE:
	    ${prev_end_tags}
	%endif
	<%
	fldcontent = record[i]
	class_ = f' class="{field.ContentStyle}"' if field.ContentStyle else ""
	%>
	%if field.FieldTypeID == FTYPE_HEADING:
	    %if prev_in_table:
		</table>
		<% prev_in_table = False %>
	    %endif
	    <%
	    prev_start_tags = Markup(f"<h{field.HeadingLevel}{class_}>")
	    prev_end_tags = Markup(f"</h{field.HeadingLevel}>")
	    %>
	    %if fldcontent:
	    ${prev_start_tags}${fldcontent}
	    %endif
	%elif field.FieldTypeID == FTYPE_BASIC:
	    %if not prev_in_table:
		${table_tag}
		<% prev_in_table = True %>
	    %endif
	    <%
	    label = field.Label or ""
	    label_class = f' class="{field.LabelStyle}"' if field.LabelStyle else ""
	    prev_start_tags = Markup(f'<tr valign="top"><td{label_class}>{label}</td><td width="100%"{class_}>')
	    prev_end_tags = Markup('</td></tr>')
	    %>
	    %if fldcontent:
		${prev_start_tags}${fldcontent}
	    %endif
	%elif field.FieldTypeID == FTYPE_FULL:
	    %if not prev_in_table:
		${table_tag}
		<% prev_in_table = True %>
	    %endif
	    <%
	    label = field.Label or ""
	    if label and field.LabelStyle:
		label = f'<span class="{field.LabelStyle}">{label}</span>'
	    if label:
		label += "<br>"
	    prev_start_tags = Markup(f'<tr valign="top"><td colspan="2"{class_}>{label}')
	    prev_end_tags = Markup('</td></tr>')
	    %>
	    %if fldcontent:
		${prev_start_tags}${fldcontent}
	    %endif
	%elif field.FieldTypeID == FTYPE_CONTINUE:
	    %if fldcontent:
		%if prev_content:
		    ${field.Separator or "; " |n}
		%else:
		    ${prev_start_tags}
		%endif
		${fldcontent}
	    %endif
	%endif
	%if fldcontent:
	    <% prev_content = True %>
	%elif not field.FieldTypeID == FTYPE_CONTINUE:
	    <% prev_content = False %>
	%endif
    %endfor
    %if prev_content:
	${prev_end_tags}
	<% prev_end_tags = "" %>
    %endif
    %if prev_in_table:
	</table>
	<% prev_in_table = False %>
    %endif

</div>
%endfor

%if heading and heading_id:
</div>
%endif

%endfor

%if group and group_id:
</div>
%endif

%endfor

%if include_index:
<div style="page-break-before: always"></div>
<h1>${_('Index by Name')}</h1>
<ol class="toc-list" role="list">
%for name in org_names:
    <li>
	<a href="#printlist-record-${name.XNUM}"><span class="title">${name.ORG_NAME_FULL}</span></a>
    </li>
%endfor
</ol>

%endif

${profile.Footer or "" |n}


    </body>
</html>
