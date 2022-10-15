<%doc>
=========================================================================================
 Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.

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

<%def name="header()">
<%

inline_results = str(request.params.get('InlineResults')) == u'on'
culture = request.language.Culture

custom_style_sheet_url = request.template_values['StyleSheetUrl']
basic_style_sheet_url = request.pageinfo.PathToStart + 'styles/d/' + str(request.template_values['VersionDate']) + '/ciocbasic_' + str(request.template_values['Template_ID']) + ('_debug' if request.params.get('Debug') else '') + '.css'
template_style_sheet_url = request.pageinfo.PathToStart + 'styles/d/' + str(request.template_values['VersionDate']) + '/cioctheme_' + str(request.template_values['Template_ID']) + ('_debug' if request.params.get('Debug') else '') + '.css'

%>

%if inline_results:
title=${(renderinfo.doc_title or '').replace('<br>', ' ').replace('&nbsp;', ' ')}
custom_stylesheet=${custom_style_sheet_url if custom_style_sheet_url else ''}
basic_stylesheet=${basic_style_sheet_url}
template_stylesheet=${template_style_sheet_url}
%else:
%if request.template_values["AlmostStandardsMode"] and not request.params.get('HTML5')=='True':
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
%else:
<!doctype html>
%endif

<html lang="${culture}" class="no-js">
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta charset="utf-8">

	%if renderinfo.no_cache:
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache" />
	%endif
	%if renderinfo.no_index:
	<meta name="ROBOTS" content="NOINDEX,FOLLOW">
	%endif


	<!--  Mobile viewport optimized: j.mp/bplateviewport -->
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	${renderinfo.add_to_header or ''}

	%if request.template_values['JavaScriptTopUrl']:
	<script type="text/javascript" src="${request.template_values['JavaScriptTopUrl']}"></script>
	%endif

	<title>${(renderinfo.doc_title or '').replace('<br>', ' ').replace('&nbsp;', ' ')}</title>

	%if request.template_values['ShortCutIcon']:
	<link rel="shortcut icon" id="shortcut_icon" href="${request.template_values['ShortCutIcon']}">
	%endif
	%if request.template_values['AppleTouchIcon']:
	<link rel="apple-touch-icon" href="${request.template_values['AppleTouchIcon']}">
	%endif

	<link rel="search" href="${request.pageinfo.PathToStart}" title="Search Start">
	<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.6.1/css/font-awesome.min.css">

	<link rel="stylesheet" type="text/css" href="${basic_style_sheet_url}" id="basic_style">
	<link rel="stylesheet" type="text/css" href="${template_style_sheet_url}" id="template_style">

	%if hasattr(caller, 'headerextra'):
		${caller.headerextra()}
	%endif


	%if custom_style_sheet_url:
	<link rel="STYLESHEET" id="custom_style" type="text/css" href="${custom_style_sheet_url}">
	%endif

	<!-- All JavaScript at the bottom, except for Modernizr which enables HTML5 elements & feature detects -->
	<script src="${request.pageinfo.PathToStart}scripts/modernizr-2.0.6-custom.min_v206.js" type="text/javascript"></script>
	<!--[if lt IE 9 ]>
	<script src="${request.pageinfo.PathToStart}scripts/respond.min.js" type="text/javascript"></script>
	<![endif]-->


<script type="text/javascript"><!--

function add_class(el, classname) {
	if (!el) {
		return;
	}
	var myRE = new RegExp("\\b" + classname + "\\b");
	if ( !myRE.test(el.className) ) {
		if (el.className) {
			classname = ' ' + classname;
		}
		el.className += classname;
	}
}

function remove_class(el, classname) {
	if (!el) {
		return;
	}
	var classnames = el.className.split(' ');
	var newclasses = [];
	for (var i = 0; i < classnames.length; i++) {
		var cn = classnames[i];
		if (cn != classname) {
			newclasses.push(cn);
		}
	}
	el.className = newclasses.join(' ')
}

function hide(el) {
	add_class(el, 'NotVisible');
}

function show(el) {
	remove_class(el, 'NotVisible');
}

function openWin(pageToOpen,windowName)  {
	popWin = window.open(pageToOpen,windowName,"toolbar=no,width=490,height=485,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

function openWinL(pageToOpen,windowName)  {
	popWin = window.open(pageToOpen,windowName,"toolbar=no,width=650,height=520,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

function openWinXL(pageToOpen,windowName)  {
	popWin = window.open(pageToOpen,windowName,"toolbar=no,width=755,height=550,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

//--></script>

</head>

<% template_values = request.template_values %>
<body ${'' if renderinfo.print_table else 'style="margin: 5px; padding: 5px;" id="no_header_body"' |n} ${template_values['BodyTagExtras'] or '' |n}>
<a class="sr-only" href="#page_content">${_('Skip to main content')}</a>
%endif

	<div id="body_content">

		%if renderinfo.print_table:
		${makeLayoutHeader()|n}
		%endif

		%if request.dboptions.TrainingMode and not request.viewdata.PrintMode and renderinfo.print_table:
		<div class="ui-state-error clearfix ui-corner-all" id="training-mode">${_('The database is in training mode')}</div>
		%endif

		<div id="page_content" role="main">

		<%
		ErrMsg = context.get('ErrMsg')
		Info = context.get('Info')
		errmsg = sanitize_html(request.params.get("ErrMsg"))
		infomsg = sanitize_html(request.params.get("InfoMsg"))
		%>

		%if errmsg or ErrMsg:
			<p class="Alert" role="alert" id="show_page_error_msg">${errmsg or ErrMsg |n}</p>
		%endif
		%if infomsg or Info:
			<p class="Info">${infomsg or Info |n}</p>
		%endif

		${request.viewdata.PageMsgs |n}

</%def>
${header()}
