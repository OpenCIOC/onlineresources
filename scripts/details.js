// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

window['CIOC'] = {};
(function(document, window) {
 window['do_drop_down_navigation'] = function() {
	var target = document.getElementById('ActionList');
	var options = target.options;
	for (var i = 0; i < options.length; i++) {
		if (options[i].selected) {
			var href = options[i].getAttribute('href');
			if (href) {
				if (typeof(options[i].attributes['newwindow']) != "undefined" ) {
					window.open(href);
				} else {
					window.location.href = href;
				}
			}
			return;
		}
	}
};
jQuery(function($) {
	$('[data-toggle=dialog]').each(function() {
		var self = $(this);
		var dialog = $(self.data('target'));
		var args = {
			autoOpen: false,
			title: dialog.data('title'),
			modal: dialog.data('modal')
		}
		dialog.dialog(args);
		self.click(function() {
			if (dialog.dialog('isOpen')) {
				dialog.dialog('close');
			} else {
				dialog.dialog('open');
			}
		});
	});
});
})(document, window);
// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

function CheckAll(name, form) {
	if (!name) {
		name = "IDList";
	}
	var ml = form;
	if (!form) {
		ml = document.RecordList;
	}
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
		var e = ml.elements[i];
		if (e.name === name) {
			e.checked = true;
		}
	}
}

function ClearAll(name, form) {
	if (!name) {
		name = "IDList";
	}
	var ml = form;
	if (!form) {
		ml = document.RecordList;
	}
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
		var e = ml.elements[i];
		if (e.name === name) {
			e.checked = false;
		}
	}
}
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
		if (cn !== classname) {
			newclasses.push(cn);
		}
	}
	el.className = newclasses.join(' ');
}

function hide(el) {
	add_class(el, 'NotVisible');
}

function show(el) {
	remove_class(el, 'NotVisible');
}

function openWin(pageToOpen,windowName)  {
	var popWin = window.open(pageToOpen,windowName,"toolbar=no,width=490,height=485,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

function openWinL(pageToOpen,windowName)  {
	var popWin = window.open(pageToOpen,windowName,"toolbar=no,width=650,height=520,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

function openWinXL(pageToOpen,windowName)  {
	var popWin = window.open(pageToOpen,windowName,"toolbar=no,width=755,height=550,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

jQuery(function($) {
	var popfns = {
		sm: openWin,
		lg: openWinL,
		xl: openWinXL
	};
	$(document).on('click', 'a.poplink', function() {
		var args = $(this).data('popargs'), link = this.href,
			fn = (popfns[args.size || 'sm'] || openWin);
		
		fn(link, args.name || 'popwin');

		return false;
	});
});

// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================


(function() {
var $ = jQuery;

var options = {};

var check_list_link = function(count) {
	if (count !== null && typeof count !== 'undefined') {
		$("#myListCount").text(count);
	} else {
		count = $('#myListCount').text();
		if (count) {
			count = parseInt(count, 10);
		}
	}
	if (count) {
		options.myListLink.show();
	} else {
		options.myListLink.hide();
	}
}
var mark_added = function(ids) {
	$.each(ids, function(index, item) {
		$("#added_to_list_" + item).show();
		$("#add_to_list_" + item).hide();
	});
}

var item_added_to_list = function(id){
	return function(result) {
		if (result.fail) {
			alert(result.errinfo);
			return;
		}

		if (result.ids) {
			check_list_link($.grep(result.ids, grep_fns[options.domain]).length);
		} else if (result.count) {
			check_list_link(result.count);
		} else {
			check_list_link(0);
		}

		mark_added([id]);
	};
}

var add_to_list_clicked = function(evt) {
	var target = evt.currentTarget;
	var id = $(target).data('id');

	$.ajax({
			success: item_added_to_list(id),
			dataType: 'json', 
			error: function() {alert("Error");},
			data: {id:id},
			type: 'POST',
			url: options.current_list_url
		});
}

var item_removed_from_list = function(id){
	return function(result) {
		if (result.fail) {
			alert(result.errinfo);
			return;
		}

		var table_results = true;
		if (id) {
			var el = $("#results_table #remove_from_list_" + id);
			if (!el.length) {
				table_results = false;
				el = $("#results_container #remove_from_list_" + id);
				el.parents('.dlist-result').remove();
			} else {
				el.parent().parent().remove();
			}
		}

		var hide = false;
		if (table_results) {
			hide = $('#results_table tr').length === 1;
		} else {
			hide = $('#results_container .dlist-result').length === 0;
		}

		if (hide || !id) {
			$("#records_ui").hide();
			$("#no_records_message").show();
		}
	};
}

var remove_from_list_clicked = function(evt) {
	var target = evt.currentTarget;
	var id = $(target).data('id');

	$.ajax({
			success: item_removed_from_list(id),
			dataType: 'json', 
			error: function() {alert("Error");},
			data: {ID:id, RemoveItem: options.domain},
			type: 'POST',
			url: options.current_list_url
		});
}

var remove_all_from_list_clicked = function(evt) {
	$.ajax({
			success: item_removed_from_list(),
			dataType: 'json', 
			error: function() {alert("Error");},
			data: {ID:'all', RemoveItem: options.domain},
			type: 'POST',
			url: options.current_list_url
		});
}

var grep_fns = {
CIC: function(el) { return /^[A-Za-z]{3}[0-9]{4,5}$/.test(el); },
VOL: function(el) { return /^[1-9][0-9]*$/.test(el); }
};

var init_ct_list_ui = function(result) {
		if (result.fail) {
			init_base_list_ui();
			return;
		}
		if ( !result.inrequest) {
			init_base_list_ui();
			return;
		}
		var ids = $.grep(result.ids, grep_fns[options.domain]);
		mark_added(ids);

		// XXX show link for clienttracker list
		check_list_link(ids.length);

		var previous_ids = result.previous_ids;
		if (previous_ids) {
			$.each(previous_ids, function(index, item) {
					$("#ct_added_to_previous_request_" + item).show();
				});
		}

		$('.ListUI img').prop('src', function(index, src) { 
				return src.replace('list', 'referral');
				} );

		$("#list_header_text").hide();
		$("#ct_header_text").show();

		options.current_list_url = options.ct_update_url;

		finalize_init();
}

var init_base_list_ui = function() {

	var run_setup = function(){
		if(!options.list_view_mode) {
			mark_added(options.already_added || []);
		}
		if (options.list_view_mode && options.list_view_mode === 'ct') {
			options.current_list_url = options.ct_update_url;
		} else {
			options.current_list_url = options.list_update_url;
		}
		check_list_link((options.already_added || []).length);

		finalize_init();
	}

	if (!options.list_view_mode && !options.has_session) {
		$.ajax({
			dataType: 'json', 
			error: null,
			url: options.list_update_url,
			data: { SessionTest: 'on' },
			type: 'POST',
			success: function(result) {
				if (result.has_session) {
					run_setup();
				}
			}
			});
	} else {
		run_setup();
	}
}

var finalize_init = function() {
	$('.HideListUI').
		delegate(".add_to_list", "click", add_to_list_clicked).
		delegate(".remove_from_list", "click", remove_from_list_clicked).
		removeClass('HideListUI');

	$("#remove_all_from_list").click(remove_all_from_list_clicked);
	

	if($.browser.msie && $.browser.msie < "8.0") {
		$(".ListUI").removeClass("FixIE");
	}
}

var init_list_adder = function(opt)
{
	options = opt;
	options.myListLink = $('#myListLink').parent(':hidden').add('#myListLink')
	if (opt.in_request) {
		$.ajax({
			success: init_ct_list_ui,
			dataType: 'json', 
			error: null,
			type: 'POST',
			url: opt.in_request
			});
		return;
	}

	init_base_list_ui();
}
window['init_list_adder'] = init_list_adder;
})();
/*
    http://www.JSON.org/json2.js
    2010-03-20

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html


    This code should be minified before deployment.
    See http://javascript.crockford.com/jsmin.html

    USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
    NOT CONTROL.


    This file creates a global JSON object containing two methods: stringify
    and parse.

        JSON.stringify(value, replacer, space)
            value       any JavaScript value, usually an object or array.

            replacer    an optional parameter that determines how object
                        values are stringified for objects. It can be a
                        function or an array of strings.

            space       an optional parameter that specifies the indentation
                        of nested structures. If it is omitted, the text will
                        be packed without extra whitespace. If it is a number,
                        it will specify the number of spaces to indent at each
                        level. If it is a string (such as '\t' or '&nbsp;'),
                        it contains the characters used to indent at each level.

            This method produces a JSON text from a JavaScript value.

            When an object value is found, if the object contains a toJSON
            method, its toJSON method will be called and the result will be
            stringified. A toJSON method does not serialize: it returns the
            value represented by the name/value pair that should be serialized,
            or undefined if nothing should be serialized. The toJSON method
            will be passed the key associated with the value, and this will be
            bound to the value

            For example, this would serialize Dates as ISO strings.

                Date.prototype.toJSON = function (key) {
                    function f(n) {
                        // Format integers to have at least two digits.
                        return n < 10 ? '0' + n : n;
                    }

                    return this.getUTCFullYear()   + '-' +
                         f(this.getUTCMonth() + 1) + '-' +
                         f(this.getUTCDate())      + 'T' +
                         f(this.getUTCHours())     + ':' +
                         f(this.getUTCMinutes())   + ':' +
                         f(this.getUTCSeconds())   + 'Z';
                };

            You can provide an optional replacer method. It will be passed the
            key and value of each member, with this bound to the containing
            object. The value that is returned from your method will be
            serialized. If your method returns undefined, then the member will
            be excluded from the serialization.

            If the replacer parameter is an array of strings, then it will be
            used to select the members to be serialized. It filters the results
            such that only members with keys listed in the replacer array are
            stringified.

            Values that do not have JSON representations, such as undefined or
            functions, will not be serialized. Such values in objects will be
            dropped; in arrays they will be replaced with null. You can use
            a replacer function to replace those with JSON values.
            JSON.stringify(undefined) returns undefined.

            The optional space parameter produces a stringification of the
            value that is filled with line breaks and indentation to make it
            easier to read.

            If the space parameter is a non-empty string, then that string will
            be used for indentation. If the space parameter is a number, then
            the indentation will be that many spaces.

            Example:

            text = JSON.stringify(['e', {pluribus: 'unum'}]);
            // text is '["e",{"pluribus":"unum"}]'


            text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
            // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

            text = JSON.stringify([new Date()], function (key, value) {
                return this[key] instanceof Date ?
                    'Date(' + this[key] + ')' : value;
            });
            // text is '["Date(---current time---)"]'


        JSON.parse(text, reviver)
            This method parses a JSON text to produce an object or array.
            It can throw a SyntaxError exception.

            The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.

            Example:

            // Parse the text. Values that look like ISO date strings will
            // be converted to Date objects.

            myData = JSON.parse(text, function (key, value) {
                var a;
                if (typeof value === 'string') {
                    a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                    if (a) {
                        return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                            +a[5], +a[6]));
                    }
                }
                return value;
            });

            myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                var d;
                if (typeof value === 'string' &&
                        value.slice(0, 5) === 'Date(' &&
                        value.slice(-1) === ')') {
                    d = new Date(value.slice(5, -1));
                    if (d) {
                        return d;
                    }
                }
                return value;
            });


    This is a reference implementation. You are free to copy, modify, or
    redistribute.
*/

/*jslint evil: true, strict: false */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
    call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
    getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
    lastIndex, length, parse, prototype, push, replace, slice, stringify,
    test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (!this.JSON) {
    this.JSON = {};
}

(function () {

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                   this.getUTCFullYear()   + '-' +
                 f(this.getUTCMonth() + 1) + '-' +
                 f(this.getUTCDate())      + 'T' +
                 f(this.getUTCHours())     + ':' +
                 f(this.getUTCMinutes())   + ':' +
                 f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON =
        Number.prototype.toJSON =
        Boolean.prototype.toJSON = function (key) {
            return this.valueOf();
        };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ?
            '"' + string.replace(escapable, function (a) {
                var c = meta[a];
                return typeof c === 'string' ? c :
                    '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
            }) + '"' :
            '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0 ? '[]' :
                    gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                                mind + ']' :
                          '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    k = rep[i];
                    if (typeof k === 'string') {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0 ? '{}' :
                gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                     typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
}());
﻿// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
window['get_form_values'] = function(selector) {
	var values = {};
	jQuery(selector).find('input,select,textarea').each(function (index) {
		if ( !this.name ) {
			return;
		}
		if (! values[this.name]) {
			values[this.name] = [];
		}
		if ( this.nodeName.toLowerCase() === 'select') {
			var valarray = values[this.name];
			$(this).find('option').each(function(index) {
					if(this.selected) {
						valarray.push(this.value);
					}
				});
			return;
		}
		if ( this.nodeName.toLowerCase() === 'input' && (this.type === 'checkbox' || 
				this.type === 'radio') && !this.checked ) {
			return;
		}
		values[this.name].push(this.value || '');
	});
	return values;
};

window['restore_form_values'] = function(selector, form_values) {
	var $ = jQuery;
	$(selector).find('input,select,textarea').each(function (index) {
		if ( !this.name ) {
			return;
		}
		var val = form_values[this.name];
		if ( typeof(val) == 'undefined' || val === null) {
			return;
		}
		
		var length = val.length;
		if ( this.nodeName.toLowerCase() === 'input' && ( this.type === 'checkbox' ||
				this.type === 'radio') )  {
			if (val.length > 1) {
				this.checked = $.inArray(this.value, val) >= 0;
			} else if (val.length === 0) {
				this.checked = false;
			} else {
				this.checked = this.value === val[0];
			}
			return;
		}

		if (this.nodeName.toLowerCase() === 'select') {
			$(this).find('option').each(function (index) {
				if (val.length > 1) {
					this.selected = $.inArray(this.value, val) >= 0;
				} else if (val.length === 0) {
					this.selected = false;
				} else {
					this.selected = this.value === val[0];
				}
			});
			return;
		}

		if ( val.length ) {
			this.value = val[0];
		} else {
			this.value = "";
		}
	});
};

window['init_cached_state'] = function(formselector) {
	var $ = jQuery;
	formselector = formselector || "#EntryForm";
	onbeforeunload_fns = [];
	onbeforerestorevalues_fns = [];

	var save_cache_values = function() {
		var cache_dom = document.getElementById('cache_form_values');
		if (! cache_dom) {
			return;
		}
		var values = get_form_values(formselector);
		var cache = {form_values :values};

		$.each(onbeforeunload_fns, function(index, item) {
			item(cache);
		});

		cache_dom.value = JSON.stringify(cache);

	};
	document.addEventListener('visibilitychange', function() {
		if (document.visibilityState == 'hidden') {
			save_cache_values();
		}
	})
	document.addEventListener('freeze', save_cache_values);
	window.addEventListener('pagehide', save_cache_values);

	var cache_register_onbeforeunload = function(fn) {
		onbeforeunload_fns.push(fn);
	};

	window['cache_register_onbeforeunload'] = cache_register_onbeforeunload;

	var cache_register_onbeforerestorevalues = function(fn) {
		onbeforerestorevalues_fns.push(fn);
	};

	window['cache_register_onbeforerestorevalues'] = cache_register_onbeforerestorevalues;

	var restore_cached_state = function() {
		$(window).on('pageshow', function(evt) {
		if(evt.originalEvent.persisted) {
			return;
		}
		var cache_dom = document.getElementById('cache_form_values');
		if (!cache_dom || !cache_dom.value) {
			return;
		}

		var cache = JSON.parse(cache_dom.value);

		$.each(onbeforerestorevalues_fns, function(index,item) {
			item(cache);
		});

		restore_form_values(formselector, cache.form_values);

		});
	};
	window['restore_cached_state'] = restore_cached_state;
};

})();
// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
	var $ = jQuery,
		dateformat = {
			'en-CA': 'd M yy',
			'de': 'dd.mm.yy',
			'fr': 'd M yy',
			'it': 'd M yy',
			'nl': 'd M yy',
			'no': 'd M yy',
			'pt': 'd-mm-yy',
			'sv': 'd M yy',
			'hu': 'M d. yy',
			'ro': 'd M yy',
			'hr': 'd M yy',
			'sl': 'd M yy',
			'bg': 'd MM yy',
			'ru': 'd M yy',
			'tr': 'd M yy',
			'lv': 'd M yy',
			'lt': 'd M yy',
			'ko': 'yy/mm/dd',
			'zh-CN': 'yy/mm/dd',
			'th': 'd M yy'
		},
		loaded = {'en-CA': true, '': true},
		loading = {},
		culture_map = {'fr-CA': 'fr', 'es-MX': 'es'},
		fix_culture = function(culture) {
			return culture_map[culture] || culture;
		},
		load_datepicker = function() {
				var self = $(this), culture = self.data('culture'),
					format = dateformat[culture] || $.datepicker.regional[culture].dateFormat,
					args = {};
				
				if (self.hasClass('NoYear')) {
					format = format.replace(/[\- .\/]*yy[\/]?/, '');
					args = {
						beforeShow: function (input, inst) {
							inst.dpDiv.addClass('NoYearDatePicker');
						},
						onClose: function(dateText, inst){
							inst.dpDiv.removeClass('NoYearDatePicker');
						},
						changeYear: false
					};
				}
				args['dateFormat'] = format;
				self.datepicker($.extend({},$.datepicker.regional[culture],
						args)).prop('autocomplete', 'off');
		},
		load_culture = function(culture) {
			$.getScript("//ajax.googleapis.com/ajax/libs/jqueryui/" + $.ui.version + "/i18n/jquery.ui.datepicker-" + culture + '.min.js',
				function() {
					loaded[culture] = true;
					$.each(loading[culture], function() {
						load_datepicker.call(this);
					});
					delete loading[culture];
				});
		};

	
	$.datepicker.regional['en-CA'] = $.extend({},$.datepicker.regional['']);
	


	$.fn.extend({
		autodatepicker: function() {
			return this.each(function() {
				var self = $(this), culture = fix_culture(self.parents('[lang]').first().prop('lang') || 'en-CA');
				self.data('culture', culture);
				if (loaded[culture]) {
					load_datepicker.call(this);
					return;
				}
				
				var arr = loading[culture];
				if (!arr) {
					arr = loading[culture] = [];
					load_culture(culture);
				}

				arr.push(this);
			});
		}

	});

	jQuery(function() {
		$("input.DatePicker").autodatepicker();
	});
})();


/*!
 * jQuery Validation Plugin v1.20.0
 *
 * https://jqueryvalidation.org/
 *
 * Copyright (c) 2023 Jörn Zaefferer
 * Released under the MIT license
 */
(function( factory ) {
	if ( typeof define === "function" && define.amd ) {
		define( ["jquery"], factory );
	} else if (typeof module === "object" && module.exports) {
		module.exports = factory( require( "jquery" ) );
	} else {
		factory( jQuery );
	}
}(function( $ ) {

$.extend( $.fn, {

	// https://jqueryvalidation.org/validate/
	validate: function( options ) {

		// If nothing is selected, return nothing; can't chain anyway
		if ( !this.length ) {
			if ( options && options.debug && window.console ) {
				console.warn( "Nothing selected, can't validate, returning nothing." );
			}
			return;
		}

		// Check if a validator for this form was already created
		var validator = $.data( this[ 0 ], "validator" );
		if ( validator ) {
			return validator;
		}

		// Add novalidate tag if HTML5.
		this.attr( "novalidate", "novalidate" );

		validator = new $.validator( options, this[ 0 ] );
		$.data( this[ 0 ], "validator", validator );

		if ( validator.settings.onsubmit ) {

			this.on( "click.validate", ":submit", function( event ) {

				// Track the used submit button to properly handle scripted
				// submits later.
				validator.submitButton = event.currentTarget;

				// Allow suppressing validation by adding a cancel class to the submit button
				if ( $( this ).hasClass( "cancel" ) ) {
					validator.cancelSubmit = true;
				}

				// Allow suppressing validation by adding the html5 formnovalidate attribute to the submit button
				if ( $( this ).attr( "formnovalidate" ) !== undefined ) {
					validator.cancelSubmit = true;
				}
			} );

			// Validate the form on submit
			this.on( "submit.validate", function( event ) {
				if ( validator.settings.debug ) {

					// Prevent form submit to be able to see console output
					event.preventDefault();
				}

				function handle() {
					var hidden, result;

					// Insert a hidden input as a replacement for the missing submit button
					// The hidden input is inserted in two cases:
					//   - A user defined a `submitHandler`
					//   - There was a pending request due to `remote` method and `stopRequest()`
					//     was called to submit the form in case it's valid
					if ( validator.submitButton && ( validator.settings.submitHandler || validator.formSubmitted ) ) {
						hidden = $( "<input type='hidden'/>" )
							.attr( "name", validator.submitButton.name )
							.val( $( validator.submitButton ).val() )
							.appendTo( validator.currentForm );
					}

					if ( validator.settings.submitHandler && !validator.settings.debug ) {
						result = validator.settings.submitHandler.call( validator, validator.currentForm, event );
						if ( hidden ) {

							// And clean up afterwards; thanks to no-block-scope, hidden can be referenced
							hidden.remove();
						}
						if ( result !== undefined ) {
							return result;
						}
						return false;
					}
					return true;
				}

				// Prevent submit for invalid forms or custom submit handlers
				if ( validator.cancelSubmit ) {
					validator.cancelSubmit = false;
					return handle();
				}
				if ( validator.form() ) {
					if ( validator.pendingRequest ) {
						validator.formSubmitted = true;
						return false;
					}
					return handle();
				} else {
					validator.focusInvalid();
					return false;
				}
			} );
		}

		return validator;
	},

	// https://jqueryvalidation.org/valid/
	valid: function() {
		var valid, validator, errorList;

		if ( $( this[ 0 ] ).is( "form" ) ) {
			valid = this.validate().form();
		} else {
			errorList = [];
			valid = true;
			validator = $( this[ 0 ].form ).validate();
			this.each( function() {
				valid = validator.element( this ) && valid;
				if ( !valid ) {
					errorList = errorList.concat( validator.errorList );
				}
			} );
			validator.errorList = errorList;
		}
		return valid;
	},

	// https://jqueryvalidation.org/rules/
	rules: function( command, argument ) {
		var element = this[ 0 ],
			isContentEditable = typeof this.attr( "contenteditable" ) !== "undefined" && this.attr( "contenteditable" ) !== "false",
			settings, staticRules, existingRules, data, param, filtered;

		// If nothing is selected, return empty object; can't chain anyway
		if ( element == null ) {
			return;
		}

		if ( !element.form && isContentEditable ) {
			element.form = this.closest( "form" )[ 0 ];
			element.name = this.attr( "name" );
		}

		if ( element.form == null ) {
			return;
		}

		if ( command ) {
			settings = $.data( element.form, "validator" ).settings;
			staticRules = settings.rules;
			existingRules = $.validator.staticRules( element );
			switch ( command ) {
			case "add":
				$.extend( existingRules, $.validator.normalizeRule( argument ) );

				// Remove messages from rules, but allow them to be set separately
				delete existingRules.messages;
				staticRules[ element.name ] = existingRules;
				if ( argument.messages ) {
					settings.messages[ element.name ] = $.extend( settings.messages[ element.name ], argument.messages );
				}
				break;
			case "remove":
				if ( !argument ) {
					delete staticRules[ element.name ];
					return existingRules;
				}
				filtered = {};
				$.each( argument.split( /\s/ ), function( index, method ) {
					filtered[ method ] = existingRules[ method ];
					delete existingRules[ method ];
				} );
				return filtered;
			}
		}

		data = $.validator.normalizeRules(
		$.extend(
			{},
			$.validator.classRules( element ),
			$.validator.attributeRules( element ),
			$.validator.dataRules( element ),
			$.validator.staticRules( element )
		), element );

		// Make sure required is at front
		if ( data.required ) {
			param = data.required;
			delete data.required;
			data = $.extend( { required: param }, data );
		}

		// Make sure remote is at back
		if ( data.remote ) {
			param = data.remote;
			delete data.remote;
			data = $.extend( data, { remote: param } );
		}

		return data;
	}
} );

// JQuery trim is deprecated, provide a trim method based on String.prototype.trim
var trim = function( str ) {

	// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/trim#Polyfill
	return str.replace( /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "" );
};

// Custom selectors
$.extend( $.expr.pseudos || $.expr[ ":" ], {		// '|| $.expr[ ":" ]' here enables backwards compatibility to jQuery 1.7. Can be removed when dropping jQ 1.7.x support

	// https://jqueryvalidation.org/blank-selector/
	blank: function( a ) {
		return !trim( "" + $( a ).val() );
	},

	// https://jqueryvalidation.org/filled-selector/
	filled: function( a ) {
		var val = $( a ).val();
		return val !== null && !!trim( "" + val );
	},

	// https://jqueryvalidation.org/unchecked-selector/
	unchecked: function( a ) {
		return !$( a ).prop( "checked" );
	}
} );

// Constructor for validator
$.validator = function( options, form ) {
	this.settings = $.extend( true, {}, $.validator.defaults, options );
	this.currentForm = form;
	this.init();
};

// https://jqueryvalidation.org/jQuery.validator.format/
$.validator.format = function( source, params ) {
	if ( arguments.length === 1 ) {
		return function() {
			var args = $.makeArray( arguments );
			args.unshift( source );
			return $.validator.format.apply( this, args );
		};
	}
	if ( params === undefined ) {
		return source;
	}
	if ( arguments.length > 2 && params.constructor !== Array  ) {
		params = $.makeArray( arguments ).slice( 1 );
	}
	if ( params.constructor !== Array ) {
		params = [ params ];
	}
	$.each( params, function( i, n ) {
		source = source.replace( new RegExp( "\\{" + i + "\\}", "g" ), function() {
			return n;
		} );
	} );
	return source;
};

$.extend( $.validator, {

	defaults: {
		messages: {},
		groups: {},
		rules: {},
		errorClass: "error",
		pendingClass: "pending",
		validClass: "valid",
		errorElement: "label",
		focusCleanup: false,
		focusInvalid: true,
		errorContainer: $( [] ),
		errorLabelContainer: $( [] ),
		onsubmit: true,
		ignore: ":hidden",
		ignoreTitle: false,
		onfocusin: function( element ) {
			this.lastActive = element;

			// Hide error label and remove error class on focus if enabled
			if ( this.settings.focusCleanup ) {
				if ( this.settings.unhighlight ) {
					this.settings.unhighlight.call( this, element, this.settings.errorClass, this.settings.validClass );
				}
				this.hideThese( this.errorsFor( element ) );
			}
		},
		onfocusout: function( element ) {
			if ( !this.checkable( element ) && ( element.name in this.submitted || !this.optional( element ) ) ) {
				this.element( element );
			}
		},
		onkeyup: function( element, event ) {

			// Avoid revalidate the field when pressing one of the following keys
			// Shift       => 16
			// Ctrl        => 17
			// Alt         => 18
			// Caps lock   => 20
			// End         => 35
			// Home        => 36
			// Left arrow  => 37
			// Up arrow    => 38
			// Right arrow => 39
			// Down arrow  => 40
			// Insert      => 45
			// Num lock    => 144
			// AltGr key   => 225
			var excludedKeys = [
				16, 17, 18, 20, 35, 36, 37,
				38, 39, 40, 45, 144, 225
			];

			if ( event.which === 9 && this.elementValue( element ) === "" || $.inArray( event.keyCode, excludedKeys ) !== -1 ) {
				return;
			} else if ( element.name in this.submitted || element.name in this.invalid ) {
				this.element( element );
			}
		},
		onclick: function( element ) {

			// Click on selects, radiobuttons and checkboxes
			if ( element.name in this.submitted ) {
				this.element( element );

			// Or option elements, check parent select in that case
			} else if ( element.parentNode.name in this.submitted ) {
				this.element( element.parentNode );
			}
		},
		highlight: function( element, errorClass, validClass ) {
			if ( element.type === "radio" ) {
				this.findByName( element.name ).addClass( errorClass ).removeClass( validClass );
			} else {
				$( element ).addClass( errorClass ).removeClass( validClass );
			}
		},
		unhighlight: function( element, errorClass, validClass ) {
			if ( element.type === "radio" ) {
				this.findByName( element.name ).removeClass( errorClass ).addClass( validClass );
			} else {
				$( element ).removeClass( errorClass ).addClass( validClass );
			}
		}
	},

	// https://jqueryvalidation.org/jQuery.validator.setDefaults/
	setDefaults: function( settings ) {
		$.extend( $.validator.defaults, settings );
	},

	messages: {
		required: "This field is required.",
		remote: "Please fix this field.",
		email: "Please enter a valid email address.",
		url: "Please enter a valid URL.",
		date: "Please enter a valid date.",
		dateISO: "Please enter a valid date (ISO).",
		number: "Please enter a valid number.",
		digits: "Please enter only digits.",
		equalTo: "Please enter the same value again.",
		maxlength: $.validator.format( "Please enter no more than {0} characters." ),
		minlength: $.validator.format( "Please enter at least {0} characters." ),
		rangelength: $.validator.format( "Please enter a value between {0} and {1} characters long." ),
		range: $.validator.format( "Please enter a value between {0} and {1}." ),
		max: $.validator.format( "Please enter a value less than or equal to {0}." ),
		min: $.validator.format( "Please enter a value greater than or equal to {0}." ),
		step: $.validator.format( "Please enter a multiple of {0}." )
	},

	autoCreateRanges: false,

	prototype: {

		init: function() {
			this.labelContainer = $( this.settings.errorLabelContainer );
			this.errorContext = this.labelContainer.length && this.labelContainer || $( this.currentForm );
			this.containers = $( this.settings.errorContainer ).add( this.settings.errorLabelContainer );
			this.submitted = {};
			this.valueCache = {};
			this.pendingRequest = 0;
			this.pending = {};
			this.invalid = {};
			this.reset();

			var currentForm = this.currentForm,
				groups = ( this.groups = {} ),
				rules;
			$.each( this.settings.groups, function( key, value ) {
				if ( typeof value === "string" ) {
					value = value.split( /\s/ );
				}
				$.each( value, function( index, name ) {
					groups[ name ] = key;
				} );
			} );
			rules = this.settings.rules;
			$.each( rules, function( key, value ) {
				rules[ key ] = $.validator.normalizeRule( value );
			} );

			function delegate( event ) {
				var isContentEditable = typeof $( this ).attr( "contenteditable" ) !== "undefined" && $( this ).attr( "contenteditable" ) !== "false";

				// Set form expando on contenteditable
				if ( !this.form && isContentEditable ) {
					this.form = $( this ).closest( "form" )[ 0 ];
					this.name = $( this ).attr( "name" );
				}

				// Ignore the element if it belongs to another form. This will happen mainly
				// when setting the `form` attribute of an input to the id of another form.
				if ( currentForm !== this.form ) {
					return;
				}

				var validator = $.data( this.form, "validator" ),
					eventType = "on" + event.type.replace( /^validate/, "" ),
					settings = validator.settings;
				if ( settings[ eventType ] && !$( this ).is( settings.ignore ) ) {
					settings[ eventType ].call( validator, this, event );
				}
			}

			$( this.currentForm )
				.on( "focusin.validate focusout.validate keyup.validate",
					":text, [type='password'], [type='file'], select, textarea, [type='number'], [type='search'], " +
					"[type='tel'], [type='url'], [type='email'], [type='datetime'], [type='date'], [type='month'], " +
					"[type='week'], [type='time'], [type='datetime-local'], [type='range'], [type='color'], " +
					"[type='radio'], [type='checkbox'], [contenteditable], [type='button']", delegate )

				// Support: Chrome, oldIE
				// "select" is provided as event.target when clicking a option
				.on( "click.validate", "select, option, [type='radio'], [type='checkbox']", delegate );

			if ( this.settings.invalidHandler ) {
				$( this.currentForm ).on( "invalid-form.validate", this.settings.invalidHandler );
			}
		},

		// https://jqueryvalidation.org/Validator.form/
		form: function() {
			this.checkForm();
			$.extend( this.submitted, this.errorMap );
			this.invalid = $.extend( {}, this.errorMap );
			if ( !this.valid() ) {
				$( this.currentForm ).triggerHandler( "invalid-form", [ this ] );
			}
			this.showErrors();
			return this.valid();
		},

		checkForm: function() {
			this.prepareForm();
			for ( var i = 0, elements = ( this.currentElements = this.elements() ); elements[ i ]; i++ ) {
				this.check( elements[ i ] );
			}
			return this.valid();
		},

		// https://jqueryvalidation.org/Validator.element/
		element: function( element ) {
			var cleanElement = this.clean( element ),
				checkElement = this.validationTargetFor( cleanElement ),
				v = this,
				result = true,
				rs, group;

			if ( checkElement === undefined ) {
				delete this.invalid[ cleanElement.name ];
			} else {
				this.prepareElement( checkElement );
				this.currentElements = $( checkElement );

				// If this element is grouped, then validate all group elements already
				// containing a value
				group = this.groups[ checkElement.name ];
				if ( group ) {
					$.each( this.groups, function( name, testgroup ) {
						if ( testgroup === group && name !== checkElement.name ) {
							cleanElement = v.validationTargetFor( v.clean( v.findByName( name ) ) );
							if ( cleanElement && cleanElement.name in v.invalid ) {
								v.currentElements.push( cleanElement );
								result = v.check( cleanElement ) && result;
							}
						}
					} );
				}

				rs = this.check( checkElement ) !== false;
				result = result && rs;
				if ( rs ) {
					this.invalid[ checkElement.name ] = false;
				} else {
					this.invalid[ checkElement.name ] = true;
				}

				if ( !this.numberOfInvalids() ) {

					// Hide error containers on last error
					this.toHide = this.toHide.add( this.containers );
				}
				this.showErrors();

				// Add aria-invalid status for screen readers
				$( element ).attr( "aria-invalid", !rs );
			}

			return result;
		},

		// https://jqueryvalidation.org/Validator.showErrors/
		showErrors: function( errors ) {
			if ( errors ) {
				var validator = this;

				// Add items to error list and map
				$.extend( this.errorMap, errors );
				this.errorList = $.map( this.errorMap, function( message, name ) {
					return {
						message: message,
						element: validator.findByName( name )[ 0 ]
					};
				} );

				// Remove items from success list
				this.successList = $.grep( this.successList, function( element ) {
					return !( element.name in errors );
				} );
			}
			if ( this.settings.showErrors ) {
				this.settings.showErrors.call( this, this.errorMap, this.errorList );
			} else {
				this.defaultShowErrors();
			}
		},

		// https://jqueryvalidation.org/Validator.resetForm/
		resetForm: function() {
			if ( $.fn.resetForm ) {
				$( this.currentForm ).resetForm();
			}
			this.invalid = {};
			this.submitted = {};
			this.prepareForm();
			this.hideErrors();
			var elements = this.elements()
				.removeData( "previousValue" )
				.removeAttr( "aria-invalid" );

			this.resetElements( elements );
		},

		resetElements: function( elements ) {
			var i;

			if ( this.settings.unhighlight ) {
				for ( i = 0; elements[ i ]; i++ ) {
					this.settings.unhighlight.call( this, elements[ i ],
						this.settings.errorClass, "" );
					this.findByName( elements[ i ].name ).removeClass( this.settings.validClass );
				}
			} else {
				elements
					.removeClass( this.settings.errorClass )
					.removeClass( this.settings.validClass );
			}
		},

		numberOfInvalids: function() {
			return this.objectLength( this.invalid );
		},

		objectLength: function( obj ) {
			/* jshint unused: false */
			var count = 0,
				i;
			for ( i in obj ) {

				// This check allows counting elements with empty error
				// message as invalid elements
				if ( obj[ i ] !== undefined && obj[ i ] !== null && obj[ i ] !== false ) {
					count++;
				}
			}
			return count;
		},

		hideErrors: function() {
			this.hideThese( this.toHide );
		},

		hideThese: function( errors ) {
			errors.not( this.containers ).text( "" );
			this.addWrapper( errors ).hide();
		},

		valid: function() {
			return this.size() === 0;
		},

		size: function() {
			return this.errorList.length;
		},

		focusInvalid: function() {
			if ( this.settings.focusInvalid ) {
				try {
					$( this.findLastActive() || this.errorList.length && this.errorList[ 0 ].element || [] )
					.filter( ":visible" )
					.trigger( "focus" )

					// Manually trigger focusin event; without it, focusin handler isn't called, findLastActive won't have anything to find
					.trigger( "focusin" );
				} catch ( e ) {

					// Ignore IE throwing errors when focusing hidden elements
				}
			}
		},

		findLastActive: function() {
			var lastActive = this.lastActive;
			return lastActive && $.grep( this.errorList, function( n ) {
				return n.element.name === lastActive.name;
			} ).length === 1 && lastActive;
		},

		elements: function() {
			var validator = this,
				rulesCache = {};

			// Select all valid inputs inside the form (no submit or reset buttons)
			return $( this.currentForm )
			.find( "input, select, textarea, [contenteditable]" )
			.not( ":submit, :reset, :image, :disabled" )
			.not( this.settings.ignore )
			.filter( function() {
				var name = this.name || $( this ).attr( "name" ); // For contenteditable
				var isContentEditable = typeof $( this ).attr( "contenteditable" ) !== "undefined" && $( this ).attr( "contenteditable" ) !== "false";

				if ( !name && validator.settings.debug && window.console ) {
					console.error( "%o has no name assigned", this );
				}

				// Set form expando on contenteditable
				if ( isContentEditable ) {
					this.form = $( this ).closest( "form" )[ 0 ];
					this.name = name;
				}

				// Ignore elements that belong to other/nested forms
				if ( this.form !== validator.currentForm ) {
					return false;
				}

				// Select only the first element for each name, and only those with rules specified
				if ( name in rulesCache || !validator.objectLength( $( this ).rules() ) ) {
					return false;
				}

				rulesCache[ name ] = true;
				return true;
			} );
		},

		clean: function( selector ) {
			return $( selector )[ 0 ];
		},

		errors: function() {
			var errorClass = this.settings.errorClass.split( " " ).join( "." );
			return $( this.settings.errorElement + "." + errorClass, this.errorContext );
		},

		resetInternals: function() {
			this.successList = [];
			this.errorList = [];
			this.errorMap = {};
			this.toShow = $( [] );
			this.toHide = $( [] );
		},

		reset: function() {
			this.resetInternals();
			this.currentElements = $( [] );
		},

		prepareForm: function() {
			this.reset();
			this.toHide = this.errors().add( this.containers );
		},

		prepareElement: function( element ) {
			this.reset();
			this.toHide = this.errorsFor( element );
		},

		elementValue: function( element ) {
			var $element = $( element ),
				type = element.type,
				isContentEditable = typeof $element.attr( "contenteditable" ) !== "undefined" && $element.attr( "contenteditable" ) !== "false",
				val, idx;

			if ( type === "radio" || type === "checkbox" ) {
				return this.findByName( element.name ).filter( ":checked" ).val();
			} else if ( type === "number" && typeof element.validity !== "undefined" ) {
				return element.validity.badInput ? "NaN" : $element.val();
			}

			if ( isContentEditable ) {
				val = $element.text();
			} else {
				val = $element.val();
			}

			if ( type === "file" ) {

				// Modern browser (chrome & safari)
				if ( val.substr( 0, 12 ) === "C:\\fakepath\\" ) {
					return val.substr( 12 );
				}

				// Legacy browsers
				// Unix-based path
				idx = val.lastIndexOf( "/" );
				if ( idx >= 0 ) {
					return val.substr( idx + 1 );
				}

				// Windows-based path
				idx = val.lastIndexOf( "\\" );
				if ( idx >= 0 ) {
					return val.substr( idx + 1 );
				}

				// Just the file name
				return val;
			}

			if ( typeof val === "string" ) {
				return val.replace( /\r/g, "" );
			}
			return val;
		},

		check: function( element ) {
			element = this.validationTargetFor( this.clean( element ) );

			var rules = $( element ).rules(),
				rulesCount = $.map( rules, function( n, i ) {
					return i;
				} ).length,
				dependencyMismatch = false,
				val = this.elementValue( element ),
				result, method, rule, normalizer;

			// Abort any pending Ajax request from a previous call to this method.
			this.abortRequest( element );

			// Prioritize the local normalizer defined for this element over the global one
			// if the former exists, otherwise user the global one in case it exists.
			if ( typeof rules.normalizer === "function" ) {
				normalizer = rules.normalizer;
			} else if (	typeof this.settings.normalizer === "function" ) {
				normalizer = this.settings.normalizer;
			}

			// If normalizer is defined, then call it to retreive the changed value instead
			// of using the real one.
			// Note that `this` in the normalizer is `element`.
			if ( normalizer ) {
				val = normalizer.call( element, val );

				// Delete the normalizer from rules to avoid treating it as a pre-defined method.
				delete rules.normalizer;
			}

			for ( method in rules ) {
				rule = { method: method, parameters: rules[ method ] };
				try {
					result = $.validator.methods[ method ].call( this, val, element, rule.parameters );

					// If a method indicates that the field is optional and therefore valid,
					// don't mark it as valid when there are no other rules
					if ( result === "dependency-mismatch" && rulesCount === 1 ) {
						dependencyMismatch = true;
						continue;
					}
					dependencyMismatch = false;

					if ( result === "pending" ) {
						this.toHide = this.toHide.not( this.errorsFor( element ) );
						return;
					}

					if ( !result ) {
						this.formatAndAdd( element, rule );
						return false;
					}
				} catch ( e ) {
					if ( this.settings.debug && window.console ) {
						console.log( "Exception occurred when checking element " + element.id + ", check the '" + rule.method + "' method.", e );
					}
					if ( e instanceof TypeError ) {
						e.message += ".  Exception occurred when checking element " + element.id + ", check the '" + rule.method + "' method.";
					}

					throw e;
				}
			}
			if ( dependencyMismatch ) {
				return;
			}
			if ( this.objectLength( rules ) ) {
				this.successList.push( element );
			}
			return true;
		},

		// Return the custom message for the given element and validation method
		// specified in the element's HTML5 data attribute
		// return the generic message if present and no method specific message is present
		customDataMessage: function( element, method ) {
			return $( element ).data( "msg" + method.charAt( 0 ).toUpperCase() +
				method.substring( 1 ).toLowerCase() ) || $( element ).data( "msg" );
		},

		// Return the custom message for the given element name and validation method
		customMessage: function( name, method ) {
			var m = this.settings.messages[ name ];
			return m && ( m.constructor === String ? m : m[ method ] );
		},

		// Return the first defined argument, allowing empty strings
		findDefined: function() {
			for ( var i = 0; i < arguments.length; i++ ) {
				if ( arguments[ i ] !== undefined ) {
					return arguments[ i ];
				}
			}
			return undefined;
		},

		// The second parameter 'rule' used to be a string, and extended to an object literal
		// of the following form:
		// rule = {
		//     method: "method name",
		//     parameters: "the given method parameters"
		// }
		//
		// The old behavior still supported, kept to maintain backward compatibility with
		// old code, and will be removed in the next major release.
		defaultMessage: function( element, rule ) {
			if ( typeof rule === "string" ) {
				rule = { method: rule };
			}

			var message = this.findDefined(
					this.customMessage( element.name, rule.method ),
					this.customDataMessage( element, rule.method ),

					// 'title' is never undefined, so handle empty string as undefined
					!this.settings.ignoreTitle && element.title || undefined,
					$.validator.messages[ rule.method ],
					"<strong>Warning: No message defined for " + element.name + "</strong>"
				),
				theregex = /\$?\{(\d+)\}/g;
			if ( typeof message === "function" ) {
				message = message.call( this, rule.parameters, element );
			} else if ( theregex.test( message ) ) {
				message = $.validator.format( message.replace( theregex, "{$1}" ), rule.parameters );
			}

			return message;
		},

		formatAndAdd: function( element, rule ) {
			var message = this.defaultMessage( element, rule );

			this.errorList.push( {
				message: message,
				element: element,
				method: rule.method
			} );

			this.errorMap[ element.name ] = message;
			this.submitted[ element.name ] = message;
		},

		addWrapper: function( toToggle ) {
			if ( this.settings.wrapper ) {
				toToggle = toToggle.add( toToggle.parent( this.settings.wrapper ) );
			}
			return toToggle;
		},

		defaultShowErrors: function() {
			var i, elements, error;
			for ( i = 0; this.errorList[ i ]; i++ ) {
				error = this.errorList[ i ];
				if ( this.settings.highlight ) {
					this.settings.highlight.call( this, error.element, this.settings.errorClass, this.settings.validClass );
				}
				this.showLabel( error.element, error.message );
			}
			if ( this.errorList.length ) {
				this.toShow = this.toShow.add( this.containers );
			}
			if ( this.settings.success ) {
				for ( i = 0; this.successList[ i ]; i++ ) {
					this.showLabel( this.successList[ i ] );
				}
			}
			if ( this.settings.unhighlight ) {
				for ( i = 0, elements = this.validElements(); elements[ i ]; i++ ) {
					this.settings.unhighlight.call( this, elements[ i ], this.settings.errorClass, this.settings.validClass );
				}
			}
			this.toHide = this.toHide.not( this.toShow );
			this.hideErrors();
			this.addWrapper( this.toShow ).show();
		},

		validElements: function() {
			return this.currentElements.not( this.invalidElements() );
		},

		invalidElements: function() {
			return $( this.errorList ).map( function() {
				return this.element;
			} );
		},

		showLabel: function( element, message ) {
			var place, group, errorID, v,
				error = this.errorsFor( element ),
				elementID = this.idOrName( element ),
				describedBy = $( element ).attr( "aria-describedby" );

			if ( error.length ) {

				// Refresh error/success class
				error.removeClass( this.settings.validClass ).addClass( this.settings.errorClass );

				// Replace message on existing label
				if ( this.settings && this.settings.escapeHtml ) {
					error.text( message || "" );
				} else {
					error.html( message || "" );
				}
			} else {

				// Create error element
				error = $( "<" + this.settings.errorElement + ">" )
					.attr( "id", elementID + "-error" )
					.addClass( this.settings.errorClass );

				if ( this.settings && this.settings.escapeHtml ) {
					error.text( message || "" );
				} else {
					error.html( message || "" );
				}

				// Maintain reference to the element to be placed into the DOM
				place = error;
				if ( this.settings.wrapper ) {

					// Make sure the element is visible, even in IE
					// actually showing the wrapped element is handled elsewhere
					place = error.hide().show().wrap( "<" + this.settings.wrapper + "/>" ).parent();
				}
				if ( this.labelContainer.length ) {
					this.labelContainer.append( place );
				} else if ( this.settings.errorPlacement ) {
					this.settings.errorPlacement.call( this, place, $( element ) );
				} else {
					place.insertAfter( element );
				}

				// Link error back to the element
				if ( error.is( "label" ) ) {

					// If the error is a label, then associate using 'for'
					error.attr( "for", elementID );

					// If the element is not a child of an associated label, then it's necessary
					// to explicitly apply aria-describedby
				} else if ( error.parents( "label[for='" + this.escapeCssMeta( elementID ) + "']" ).length === 0 ) {
					errorID = error.attr( "id" );

					// Respect existing non-error aria-describedby
					if ( !describedBy ) {
						describedBy = errorID;
					} else if ( !describedBy.match( new RegExp( "\\b" + this.escapeCssMeta( errorID ) + "\\b" ) ) ) {

						// Add to end of list if not already present
						describedBy += " " + errorID;
					}
					$( element ).attr( "aria-describedby", describedBy );

					// If this element is grouped, then assign to all elements in the same group
					group = this.groups[ element.name ];
					if ( group ) {
						v = this;
						$.each( v.groups, function( name, testgroup ) {
							if ( testgroup === group ) {
								$( "[name='" + v.escapeCssMeta( name ) + "']", v.currentForm )
									.attr( "aria-describedby", error.attr( "id" ) );
							}
						} );
					}
				}
			}
			if ( !message && this.settings.success ) {
				error.text( "" );
				if ( typeof this.settings.success === "string" ) {
					error.addClass( this.settings.success );
				} else {
					this.settings.success( error, element );
				}
			}
			this.toShow = this.toShow.add( error );
		},

		errorsFor: function( element ) {
			var name = this.escapeCssMeta( this.idOrName( element ) ),
				describer = $( element ).attr( "aria-describedby" ),
				selector = "label[for='" + name + "'], label[for='" + name + "'] *";

			// 'aria-describedby' should directly reference the error element
			if ( describer ) {
				selector = selector + ", #" + this.escapeCssMeta( describer )
					.replace( /\s+/g, ", #" );
			}

			return this
				.errors()
				.filter( selector );
		},

		// See https://api.jquery.com/category/selectors/, for CSS
		// meta-characters that should be escaped in order to be used with JQuery
		// as a literal part of a name/id or any selector.
		escapeCssMeta: function( string ) {
			if ( string === undefined ) {
				return "";
			}

			return string.replace( /([\\!"#$%&'()*+,./:;<=>?@\[\]^`{|}~])/g, "\\$1" );
		},

		idOrName: function( element ) {
			return this.groups[ element.name ] || ( this.checkable( element ) ? element.name : element.id || element.name );
		},

		validationTargetFor: function( element ) {

			// If radio/checkbox, validate first element in group instead
			if ( this.checkable( element ) ) {
				element = this.findByName( element.name );
			}

			// Always apply ignore filter
			return $( element ).not( this.settings.ignore )[ 0 ];
		},

		checkable: function( element ) {
			return ( /radio|checkbox/i ).test( element.type );
		},

		findByName: function( name ) {
			return $( this.currentForm ).find( "[name='" + this.escapeCssMeta( name ) + "']" );
		},

		getLength: function( value, element ) {
			switch ( element.nodeName.toLowerCase() ) {
			case "select":
				return $( "option:selected", element ).length;
			case "input":
				if ( this.checkable( element ) ) {
					return this.findByName( element.name ).filter( ":checked" ).length;
				}
			}
			return value.length;
		},

		depend: function( param, element ) {
			return this.dependTypes[ typeof param ] ? this.dependTypes[ typeof param ]( param, element ) : true;
		},

		dependTypes: {
			"boolean": function( param ) {
				return param;
			},
			"string": function( param, element ) {
				return !!$( param, element.form ).length;
			},
			"function": function( param, element ) {
				return param( element );
			}
		},

		optional: function( element ) {
			var val = this.elementValue( element );
			return !$.validator.methods.required.call( this, val, element ) && "dependency-mismatch";
		},

		elementAjaxPort: function( element ) {
			return "validate" + element.name;
		},

		startRequest: function( element ) {
			if ( !this.pending[ element.name ] ) {
				this.pendingRequest++;
				$( element ).addClass( this.settings.pendingClass );
				this.pending[ element.name ] = true;
			}
		},

		stopRequest: function( element, valid ) {
			this.pendingRequest--;

			// Sometimes synchronization fails, make sure pendingRequest is never < 0
			if ( this.pendingRequest < 0 ) {
				this.pendingRequest = 0;
			}
			delete this.pending[ element.name ];
			$( element ).removeClass( this.settings.pendingClass );
			if ( valid && this.pendingRequest === 0 && this.formSubmitted && this.form() && this.pendingRequest === 0 ) {
				$( this.currentForm ).trigger( "submit" );

				// Remove the hidden input that was used as a replacement for the
				// missing submit button. The hidden input is added by `handle()`
				// to ensure that the value of the used submit button is passed on
				// for scripted submits triggered by this method
				if ( this.submitButton ) {
					$( "input:hidden[name='" + this.submitButton.name + "']", this.currentForm ).remove();
				}

				this.formSubmitted = false;
			} else if ( !valid && this.pendingRequest === 0 && this.formSubmitted ) {
				$( this.currentForm ).triggerHandler( "invalid-form", [ this ] );
				this.formSubmitted = false;
			}
		},

		abortRequest: function( element ) {
			var port;

			if ( this.pending[ element.name ] ) {
				port = this.elementAjaxPort( element );
				$.ajaxAbort( port );

				this.pendingRequest--;

				// Sometimes synchronization fails, make sure pendingRequest is never < 0
				if ( this.pendingRequest < 0 ) {
					this.pendingRequest = 0;
				}

				delete this.pending[ element.name ];
				$( element ).removeClass( this.settings.pendingClass );
			}
		},

		previousValue: function( element, method ) {
			method = typeof method === "string" && method || "remote";

			return $.data( element, "previousValue" ) || $.data( element, "previousValue", {
				old: null,
				valid: true,
				message: this.defaultMessage( element, { method: method } )
			} );
		},

		// Cleans up all forms and elements, removes validator-specific events
		destroy: function() {
			this.resetForm();

			$( this.currentForm )
				.off( ".validate" )
				.removeData( "validator" )
				.find( ".validate-equalTo-blur" )
					.off( ".validate-equalTo" )
					.removeClass( "validate-equalTo-blur" )
				.find( ".validate-lessThan-blur" )
					.off( ".validate-lessThan" )
					.removeClass( "validate-lessThan-blur" )
				.find( ".validate-lessThanEqual-blur" )
					.off( ".validate-lessThanEqual" )
					.removeClass( "validate-lessThanEqual-blur" )
				.find( ".validate-greaterThanEqual-blur" )
					.off( ".validate-greaterThanEqual" )
					.removeClass( "validate-greaterThanEqual-blur" )
				.find( ".validate-greaterThan-blur" )
					.off( ".validate-greaterThan" )
					.removeClass( "validate-greaterThan-blur" );
		}

	},

	classRuleSettings: {
		required: { required: true },
		email: { email: true },
		url: { url: true },
		date: { date: true },
		dateISO: { dateISO: true },
		number: { number: true },
		digits: { digits: true },
		creditcard: { creditcard: true }
	},

	addClassRules: function( className, rules ) {
		if ( className.constructor === String ) {
			this.classRuleSettings[ className ] = rules;
		} else {
			$.extend( this.classRuleSettings, className );
		}
	},

	classRules: function( element ) {
		var rules = {},
			classes = $( element ).attr( "class" );

		if ( classes ) {
			$.each( classes.split( " " ), function() {
				if ( this in $.validator.classRuleSettings ) {
					$.extend( rules, $.validator.classRuleSettings[ this ] );
				}
			} );
		}
		return rules;
	},

	normalizeAttributeRule: function( rules, type, method, value ) {

		// Convert the value to a number for number inputs, and for text for backwards compability
		// allows type="date" and others to be compared as strings
		if ( /min|max|step/.test( method ) && ( type === null || /number|range|text/.test( type ) ) ) {
			value = Number( value );

			// Support Opera Mini, which returns NaN for undefined minlength
			if ( isNaN( value ) ) {
				value = undefined;
			}
		}

		if ( value || value === 0 ) {
			rules[ method ] = value;
		} else if ( type === method && type !== "range" ) {

			// Exception: the jquery validate 'range' method
			// does not test for the html5 'range' type
			rules[ type === "date" ? "dateISO" : method ] = true;
		}
	},

	attributeRules: function( element ) {
		var rules = {},
			$element = $( element ),
			type = element.getAttribute( "type" ),
			method, value;

		for ( method in $.validator.methods ) {

			// Support for <input required> in both html5 and older browsers
			if ( method === "required" ) {
				value = element.getAttribute( method );

				// Some browsers return an empty string for the required attribute
				// and non-HTML5 browsers might have required="" markup
				if ( value === "" ) {
					value = true;
				}

				// Force non-HTML5 browsers to return bool
				value = !!value;
			} else {
				value = $element.attr( method );
			}

			this.normalizeAttributeRule( rules, type, method, value );
		}

		// 'maxlength' may be returned as -1, 2147483647 ( IE ) and 524288 ( safari ) for text inputs
		if ( rules.maxlength && /-1|2147483647|524288/.test( rules.maxlength ) ) {
			delete rules.maxlength;
		}

		return rules;
	},

	dataRules: function( element ) {
		var rules = {},
			$element = $( element ),
			type = element.getAttribute( "type" ),
			method, value;

		for ( method in $.validator.methods ) {
			value = $element.data( "rule" + method.charAt( 0 ).toUpperCase() + method.substring( 1 ).toLowerCase() );

			// Cast empty attributes like `data-rule-required` to `true`
			if ( value === "" ) {
				value = true;
			}

			this.normalizeAttributeRule( rules, type, method, value );
		}
		return rules;
	},

	staticRules: function( element ) {
		var rules = {},
			validator = $.data( element.form, "validator" );

		if ( validator.settings.rules ) {
			rules = $.validator.normalizeRule( validator.settings.rules[ element.name ] ) || {};
		}
		return rules;
	},

	normalizeRules: function( rules, element ) {

		// Handle dependency check
		$.each( rules, function( prop, val ) {

			// Ignore rule when param is explicitly false, eg. required:false
			if ( val === false ) {
				delete rules[ prop ];
				return;
			}
			if ( val.param || val.depends ) {
				var keepRule = true;
				switch ( typeof val.depends ) {
				case "string":
					keepRule = !!$( val.depends, element.form ).length;
					break;
				case "function":
					keepRule = val.depends.call( element, element );
					break;
				}
				if ( keepRule ) {
					rules[ prop ] = val.param !== undefined ? val.param : true;
				} else {
					$.data( element.form, "validator" ).resetElements( $( element ) );
					delete rules[ prop ];
				}
			}
		} );

		// Evaluate parameters
		$.each( rules, function( rule, parameter ) {
			rules[ rule ] = typeof parameter === "function" && rule !== "normalizer" ? parameter( element ) : parameter;
		} );

		// Clean number parameters
		$.each( [ "minlength", "maxlength" ], function() {
			if ( rules[ this ] ) {
				rules[ this ] = Number( rules[ this ] );
			}
		} );
		$.each( [ "rangelength", "range" ], function() {
			var parts;
			if ( rules[ this ] ) {
				if ( Array.isArray( rules[ this ] ) ) {
					rules[ this ] = [ Number( rules[ this ][ 0 ] ), Number( rules[ this ][ 1 ] ) ];
				} else if ( typeof rules[ this ] === "string" ) {
					parts = rules[ this ].replace( /[\[\]]/g, "" ).split( /[\s,]+/ );
					rules[ this ] = [ Number( parts[ 0 ] ), Number( parts[ 1 ] ) ];
				}
			}
		} );

		if ( $.validator.autoCreateRanges ) {

			// Auto-create ranges
			if ( rules.min != null && rules.max != null ) {
				rules.range = [ rules.min, rules.max ];
				delete rules.min;
				delete rules.max;
			}
			if ( rules.minlength != null && rules.maxlength != null ) {
				rules.rangelength = [ rules.minlength, rules.maxlength ];
				delete rules.minlength;
				delete rules.maxlength;
			}
		}

		return rules;
	},

	// Converts a simple string to a {string: true} rule, e.g., "required" to {required:true}
	normalizeRule: function( data ) {
		if ( typeof data === "string" ) {
			var transformed = {};
			$.each( data.split( /\s/ ), function() {
				transformed[ this ] = true;
			} );
			data = transformed;
		}
		return data;
	},

	// https://jqueryvalidation.org/jQuery.validator.addMethod/
	addMethod: function( name, method, message ) {
		$.validator.methods[ name ] = method;
		$.validator.messages[ name ] = message !== undefined ? message : $.validator.messages[ name ];
		if ( method.length < 3 ) {
			$.validator.addClassRules( name, $.validator.normalizeRule( name ) );
		}
	},

	// https://jqueryvalidation.org/jQuery.validator.methods/
	methods: {

		// https://jqueryvalidation.org/required-method/
		required: function( value, element, param ) {

			// Check if dependency is met
			if ( !this.depend( param, element ) ) {
				return "dependency-mismatch";
			}
			if ( element.nodeName.toLowerCase() === "select" ) {

				// Could be an array for select-multiple or a string, both are fine this way
				var val = $( element ).val();
				return val && val.length > 0;
			}
			if ( this.checkable( element ) ) {
				return this.getLength( value, element ) > 0;
			}
			return value !== undefined && value !== null && value.length > 0;
		},

		// https://jqueryvalidation.org/email-method/
		email: function( value, element ) {

			// From https://html.spec.whatwg.org/multipage/forms.html#valid-e-mail-address
			// Retrieved 2014-01-14
			// If you have a problem with this implementation, report a bug against the above spec
			// Or use custom methods to implement your own email validation
			return this.optional( element ) || /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/.test( value );
		},

		// https://jqueryvalidation.org/url-method/
		url: function( value, element ) {

			// Copyright (c) 2010-2013 Diego Perini, MIT licensed
			// https://gist.github.com/dperini/729294
			// see also https://mathiasbynens.be/demo/url-regex
			// modified to allow protocol-relative URLs
			return this.optional( element ) || /^(?:(?:(?:https?|ftp):)?\/\/)(?:(?:[^\]\[?\/<~#`!@$^&*()+=}|:";',>{ ]|%[0-9A-Fa-f]{2})+(?::(?:[^\]\[?\/<~#`!@$^&*()+=}|:";',>{ ]|%[0-9A-Fa-f]{2})*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test( value );
		},

		// https://jqueryvalidation.org/date-method/
		date: ( function() {
			var called = false;

			return function( value, element ) {
				if ( !called ) {
					called = true;
					if ( this.settings.debug && window.console ) {
						console.warn(
							"The `date` method is deprecated and will be removed in version '2.0.0'.\n" +
							"Please don't use it, since it relies on the Date constructor, which\n" +
							"behaves very differently across browsers and locales. Use `dateISO`\n" +
							"instead or one of the locale specific methods in `localizations/`\n" +
							"and `additional-methods.js`."
						);
					}
				}

				return this.optional( element ) || !/Invalid|NaN/.test( new Date( value ).toString() );
			};
		}() ),

		// https://jqueryvalidation.org/dateISO-method/
		dateISO: function( value, element ) {
			return this.optional( element ) || /^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])$/.test( value );
		},

		// https://jqueryvalidation.org/number-method/
		number: function( value, element ) {
			return this.optional( element ) || /^(?:-?\d+|-?\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test( value );
		},

		// https://jqueryvalidation.org/digits-method/
		digits: function( value, element ) {
			return this.optional( element ) || /^\d+$/.test( value );
		},

		// https://jqueryvalidation.org/minlength-method/
		minlength: function( value, element, param ) {
			var length = Array.isArray( value ) ? value.length : this.getLength( value, element );
			return this.optional( element ) || length >= param;
		},

		// https://jqueryvalidation.org/maxlength-method/
		maxlength: function( value, element, param ) {
			var length = Array.isArray( value ) ? value.length : this.getLength( value, element );
			return this.optional( element ) || length <= param;
		},

		// https://jqueryvalidation.org/rangelength-method/
		rangelength: function( value, element, param ) {
			var length = Array.isArray( value ) ? value.length : this.getLength( value, element );
			return this.optional( element ) || ( length >= param[ 0 ] && length <= param[ 1 ] );
		},

		// https://jqueryvalidation.org/min-method/
		min: function( value, element, param ) {
			return this.optional( element ) || value >= param;
		},

		// https://jqueryvalidation.org/max-method/
		max: function( value, element, param ) {
			return this.optional( element ) || value <= param;
		},

		// https://jqueryvalidation.org/range-method/
		range: function( value, element, param ) {
			return this.optional( element ) || ( value >= param[ 0 ] && value <= param[ 1 ] );
		},

		// https://jqueryvalidation.org/step-method/
		step: function( value, element, param ) {
			var type = $( element ).attr( "type" ),
				errorMessage = "Step attribute on input type " + type + " is not supported.",
				supportedTypes = [ "text", "number", "range" ],
				re = new RegExp( "\\b" + type + "\\b" ),
				notSupported = type && !re.test( supportedTypes.join() ),
				decimalPlaces = function( num ) {
					var match = ( "" + num ).match( /(?:\.(\d+))?$/ );
					if ( !match ) {
						return 0;
					}

					// Number of digits right of decimal point.
					return match[ 1 ] ? match[ 1 ].length : 0;
				},
				toInt = function( num ) {
					return Math.round( num * Math.pow( 10, decimals ) );
				},
				valid = true,
				decimals;

			// Works only for text, number and range input types
			// TODO find a way to support input types date, datetime, datetime-local, month, time and week
			if ( notSupported ) {
				throw new Error( errorMessage );
			}

			decimals = decimalPlaces( param );

			// Value can't have too many decimals
			if ( decimalPlaces( value ) > decimals || toInt( value ) % toInt( param ) !== 0 ) {
				valid = false;
			}

			return this.optional( element ) || valid;
		},

		// https://jqueryvalidation.org/equalTo-method/
		equalTo: function( value, element, param ) {

			// Bind to the blur event of the target in order to revalidate whenever the target field is updated
			var target = $( param );
			if ( this.settings.onfocusout && target.not( ".validate-equalTo-blur" ).length ) {
				target.addClass( "validate-equalTo-blur" ).on( "blur.validate-equalTo", function() {
					$( element ).valid();
				} );
			}
			return value === target.val();
		},

		// https://jqueryvalidation.org/remote-method/
		remote: function( value, element, param, method ) {
			if ( this.optional( element ) ) {
				return "dependency-mismatch";
			}

			method = typeof method === "string" && method || "remote";

			var previous = this.previousValue( element, method ),
				validator, data, optionDataString;

			if ( !this.settings.messages[ element.name ] ) {
				this.settings.messages[ element.name ] = {};
			}
			previous.originalMessage = previous.originalMessage || this.settings.messages[ element.name ][ method ];
			this.settings.messages[ element.name ][ method ] = previous.message;

			param = typeof param === "string" && { url: param } || param;
			optionDataString = $.param( $.extend( { data: value }, param.data ) );
			if ( previous.old === optionDataString ) {
				return previous.valid;
			}

			previous.old = optionDataString;
			validator = this;
			this.startRequest( element );
			data = {};
			data[ element.name ] = value;
			$.ajax( $.extend( true, {
				mode: "abort",
				port: this.elementAjaxPort( element ),
				dataType: "json",
				data: data,
				context: validator.currentForm,
				success: function( response ) {
					var valid = response === true || response === "true",
						errors, message, submitted;

					validator.settings.messages[ element.name ][ method ] = previous.originalMessage;
					if ( valid ) {
						submitted = validator.formSubmitted;
						validator.toHide = validator.errorsFor( element );
						validator.formSubmitted = submitted;
						validator.successList.push( element );
						validator.invalid[ element.name ] = false;
						validator.showErrors();
					} else {
						errors = {};
						message = response || validator.defaultMessage( element, { method: method, parameters: value } );
						errors[ element.name ] = previous.message = message;
						validator.invalid[ element.name ] = true;
						validator.showErrors( errors );
					}
					previous.valid = valid;
					validator.stopRequest( element, valid );
				}
			}, param ) );
			return "pending";
		}
	}

} );

// Ajax mode: abort
// usage: $.ajax({ mode: "abort"[, port: "uniqueport"]});
//        $.ajaxAbort( port );
// if mode:"abort" is used, the previous request on that port (port can be undefined) is aborted via XMLHttpRequest.abort()

var pendingRequests = {},
	ajax;

// Use a prefilter if available (1.5+)
if ( $.ajaxPrefilter ) {
	$.ajaxPrefilter( function( settings, _, xhr ) {
		var port = settings.port;
		if ( settings.mode === "abort" ) {
			$.ajaxAbort( port );
			pendingRequests[ port ] = xhr;
		}
	} );
} else {

	// Proxy ajax
	ajax = $.ajax;
	$.ajax = function( settings ) {
		var mode = ( "mode" in settings ? settings : $.ajaxSettings ).mode,
			port = ( "port" in settings ? settings : $.ajaxSettings ).port;
		if ( mode === "abort" ) {
			$.ajaxAbort( port );
			pendingRequests[ port ] = ajax.apply( this, arguments );
			return pendingRequests[ port ];
		}
		return ajax.apply( this, arguments );
	};
}

// Abort the previous request without sending a new one
$.ajaxAbort = function( port ) {
	if ( pendingRequests[ port ] ) {
		pendingRequests[ port ].abort();
		delete pendingRequests[ port ];
	}
};
return $;
}));/*!
 * jQuery throttle / debounce - v1.1 - 3/7/2010
 * http://benalman.com/projects/jquery-throttle-debounce-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */

// Script: jQuery throttle / debounce: Sometimes, less is more!
//
// *Version: 1.1, Last updated: 3/7/2010*
// 
// Project Home - http://benalman.com/projects/jquery-throttle-debounce-plugin/
// GitHub       - http://github.com/cowboy/jquery-throttle-debounce/
// Source       - http://github.com/cowboy/jquery-throttle-debounce/raw/master/jquery.ba-throttle-debounce.js
// (Minified)   - http://github.com/cowboy/jquery-throttle-debounce/raw/master/jquery.ba-throttle-debounce.min.js (0.7kb)
// 
// About: License
// 
// Copyright (c) 2010 "Cowboy" Ben Alman,
// Dual licensed under the MIT and GPL licenses.
// http://benalman.com/about/license/
// 
// About: Examples
// 
// These working examples, complete with fully commented code, illustrate a few
// ways in which this plugin can be used.
// 
// Throttle - http://benalman.com/code/projects/jquery-throttle-debounce/examples/throttle/
// Debounce - http://benalman.com/code/projects/jquery-throttle-debounce/examples/debounce/
// 
// About: Support and Testing
// 
// Information about what version or versions of jQuery this plugin has been
// tested with, what browsers it has been tested in, and where the unit tests
// reside (so you can test it yourself).
// 
// jQuery Versions - none, 1.3.2, 1.4.2
// Browsers Tested - Internet Explorer 6-8, Firefox 2-3.6, Safari 3-4, Chrome 4-5, Opera 9.6-10.1.
// Unit Tests      - http://benalman.com/code/projects/jquery-throttle-debounce/unit/
// 
// About: Release History
// 
// 1.1 - (3/7/2010) Fixed a bug in <jQuery.throttle> where trailing callbacks
//       executed later than they should. Reworked a fair amount of internal
//       logic as well.
// 1.0 - (3/6/2010) Initial release as a stand-alone project. Migrated over
//       from jquery-misc repo v0.4 to jquery-throttle repo v1.0, added the
//       no_trailing throttle parameter and debounce functionality.
// 
// Topic: Note for non-jQuery users
// 
// jQuery isn't actually required for this plugin, because nothing internal
// uses any jQuery methods or properties. jQuery is just used as a namespace
// under which these methods can exist.
// 
// Since jQuery isn't actually required for this plugin, if jQuery doesn't exist
// when this plugin is loaded, the method described below will be created in
// the `Cowboy` namespace. Usage will be exactly the same, but instead of
// $.method() or jQuery.method(), you'll need to use Cowboy.method().

(function(window,undefined){
  '$:nomunge'; // Used by YUI compressor.
  
  // Since jQuery really isn't required for this plugin, use `jQuery` as the
  // namespace only if it already exists, otherwise use the `Cowboy` namespace,
  // creating it if necessary.
  var $ = window.jQuery || window.Cowboy || ( window.Cowboy = {} ),
    
    // Internal method reference.
    jq_throttle;
  
  // Method: jQuery.throttle
  // 
  // Throttle execution of a function. Especially useful for rate limiting
  // execution of handlers on events like resize and scroll. If you want to
  // rate-limit execution of a function to a single time, see the
  // <jQuery.debounce> method.
  // 
  // In this visualization, | is a throttled-function call and X is the actual
  // callback execution:
  // 
  // > Throttled with `no_trailing` specified as false or unspecified:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // > X    X    X    X    X    X        X    X    X    X    X    X
  // > 
  // > Throttled with `no_trailing` specified as true:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // > X    X    X    X    X             X    X    X    X    X
  // 
  // Usage:
  // 
  // > var throttled = jQuery.throttle( delay, [ no_trailing, ] callback );
  // > 
  // > jQuery('selector').bind( 'someevent', throttled );
  // > jQuery('selector').unbind( 'someevent', throttled );
  // 
  // This also works in jQuery 1.4+:
  // 
  // > jQuery('selector').bind( 'someevent', jQuery.throttle( delay, [ no_trailing, ] callback ) );
  // > jQuery('selector').unbind( 'someevent', callback );
  // 
  // Arguments:
  // 
  //  delay - (Number) A zero-or-greater delay in milliseconds. For event
  //    callbacks, values around 100 or 250 (or even higher) are most useful.
  //  no_trailing - (Boolean) Optional, defaults to false. If no_trailing is
  //    true, callback will only execute every `delay` milliseconds while the
  //    throttled-function is being called. If no_trailing is false or
  //    unspecified, callback will be executed one final time after the last
  //    throttled-function call. (After the throttled-function has not been
  //    called for `delay` milliseconds, the internal counter is reset)
  //  callback - (Function) A function to be executed after delay milliseconds.
  //    The `this` context and all arguments are passed through, as-is, to
  //    `callback` when the throttled-function is executed.
  // 
  // Returns:
  // 
  //  (Function) A new, throttled, function.
  
  $.throttle = jq_throttle = function( delay, no_trailing, callback, debounce_mode ) {
    // After wrapper has stopped being called, this timeout ensures that
    // `callback` is executed at the proper times in `throttle` and `end`
    // debounce modes.
    var timeout_id,
      
      // Keep track of the last time `callback` was executed.
      last_exec = 0;
    
    // `no_trailing` defaults to falsy.
    if ( typeof no_trailing !== 'boolean' ) {
      debounce_mode = callback;
      callback = no_trailing;
      no_trailing = undefined;
    }
    
    // The `wrapper` function encapsulates all of the throttling / debouncing
    // functionality and when executed will limit the rate at which `callback`
    // is executed.
    function wrapper() {
      var that = this,
        elapsed = +new Date() - last_exec,
        args = arguments;
      
      // Execute `callback` and update the `last_exec` timestamp.
      function exec() {
        last_exec = +new Date();
        callback.apply( that, args );
      };
      
      // If `debounce_mode` is true (at_begin) this is used to clear the flag
      // to allow future `callback` executions.
      function clear() {
        timeout_id = undefined;
      };
      
      if ( debounce_mode && !timeout_id ) {
        // Since `wrapper` is being called for the first time and
        // `debounce_mode` is true (at_begin), execute `callback`.
        exec();
      }
      
      // Clear any existing timeout.
      timeout_id && clearTimeout( timeout_id );
      
      if ( debounce_mode === undefined && elapsed > delay ) {
        // In throttle mode, if `delay` time has been exceeded, execute
        // `callback`.
        exec();
        
      } else if ( no_trailing !== true ) {
        // In trailing throttle mode, since `delay` time has not been
        // exceeded, schedule `callback` to execute `delay` ms after most
        // recent execution.
        // 
        // If `debounce_mode` is true (at_begin), schedule `clear` to execute
        // after `delay` ms.
        // 
        // If `debounce_mode` is false (at end), schedule `callback` to
        // execute after `delay` ms.
        timeout_id = setTimeout( debounce_mode ? clear : exec, debounce_mode === undefined ? delay - elapsed : delay );
      }
    };
    
    // Set the guid of `wrapper` function to the same of original callback, so
    // it can be removed in jQuery 1.4+ .unbind or .die by using the original
    // callback as a reference.
    if ( $.guid ) {
      wrapper.guid = callback.guid = callback.guid || $.guid++;
    }
    
    // Return the wrapper function.
    return wrapper;
  };
  
  // Method: jQuery.debounce
  // 
  // Debounce execution of a function. Debouncing, unlike throttling,
  // guarantees that a function is only executed a single time, either at the
  // very beginning of a series of calls, or at the very end. If you want to
  // simply rate-limit execution of a function, see the <jQuery.throttle>
  // method.
  // 
  // In this visualization, | is a debounced-function call and X is the actual
  // callback execution:
  // 
  // > Debounced with `at_begin` specified as false or unspecified:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // >                          X                                 X
  // > 
  // > Debounced with `at_begin` specified as true:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // > X                                 X
  // 
  // Usage:
  // 
  // > var debounced = jQuery.debounce( delay, [ at_begin, ] callback );
  // > 
  // > jQuery('selector').bind( 'someevent', debounced );
  // > jQuery('selector').unbind( 'someevent', debounced );
  // 
  // This also works in jQuery 1.4+:
  // 
  // > jQuery('selector').bind( 'someevent', jQuery.debounce( delay, [ at_begin, ] callback ) );
  // > jQuery('selector').unbind( 'someevent', callback );
  // 
  // Arguments:
  // 
  //  delay - (Number) A zero-or-greater delay in milliseconds. For event
  //    callbacks, values around 100 or 250 (or even higher) are most useful.
  //  at_begin - (Boolean) Optional, defaults to false. If at_begin is false or
  //    unspecified, callback will only be executed `delay` milliseconds after
  //    the last debounced-function call. If at_begin is true, callback will be
  //    executed only at the first debounced-function call. (After the
  //    throttled-function has not been called for `delay` milliseconds, the
  //    internal counter is reset)
  //  callback - (Function) A function to be executed after delay milliseconds.
  //    The `this` context and all arguments are passed through, as-is, to
  //    `callback` when the debounced-function is executed.
  // 
  // Returns:
  // 
  //  (Function) A new, debounced, function.
  
  $.debounce = function( delay, at_begin, callback ) {
    return callback === undefined
      ? jq_throttle( delay, at_begin, false )
      : jq_throttle( delay, callback, at_begin !== false );
  };
  
})(this);
/*!
 * jQuery blockUI plugin
 * Version 2.70.0-2014.11.23
 * Requires jQuery v1.7 or later
 *
 * Examples at: http://malsup.com/jquery/block/
 * Copyright (c) 2007-2013 M. Alsup
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * Thanks to Amir-Hossein Sobhi for some excellent contributions!
 */

;(function() {
/*jshint eqeqeq:false curly:false latedef:false */
"use strict";

	function setup($) {
		$.fn._fadeIn = $.fn.fadeIn;

		var noOp = $.noop || function() {};

		// this bit is to ensure we don't call setExpression when we shouldn't (with extra muscle to handle
		// confusing userAgent strings on Vista)
		var msie = /MSIE/.test(navigator.userAgent);
		var ie6  = /MSIE 6.0/.test(navigator.userAgent) && ! /MSIE 8.0/.test(navigator.userAgent);
		var mode = document.documentMode || 0;
		var setExpr = $.isFunction( document.createElement('div').style.setExpression );

		// global $ methods for blocking/unblocking the entire page
		$.blockUI   = function(opts) { install(window, opts); };
		$.unblockUI = function(opts) { remove(window, opts); };

		// convenience method for quick growl-like notifications  (http://www.google.com/search?q=growl)
		$.growlUI = function(title, message, timeout, onClose) {
			var $m = $('<div class="growlUI"></div>');
			if (title) $m.append('<h1>'+title+'</h1>');
			if (message) $m.append('<h2>'+message+'</h2>');
			if (timeout === undefined) timeout = 3000;

			// Added by konapun: Set timeout to 30 seconds if this growl is moused over, like normal toast notifications
			var callBlock = function(opts) {
				opts = opts || {};

				$.blockUI({
					message: $m,
					fadeIn : typeof opts.fadeIn  !== 'undefined' ? opts.fadeIn  : 700,
					fadeOut: typeof opts.fadeOut !== 'undefined' ? opts.fadeOut : 1000,
					timeout: typeof opts.timeout !== 'undefined' ? opts.timeout : timeout,
					centerY: false,
					showOverlay: false,
					onUnblock: onClose,
					css: $.blockUI.defaults.growlCSS
				});
			};

			callBlock();
			var nonmousedOpacity = $m.css('opacity');
			$m.mouseover(function() {
				callBlock({
					fadeIn: 0,
					timeout: 30000
				});

				var displayBlock = $('.blockMsg');
				displayBlock.stop(); // cancel fadeout if it has started
				displayBlock.fadeTo(300, 1); // make it easier to read the message by removing transparency
			}).mouseout(function() {
				$('.blockMsg').fadeOut(1000);
			});
			// End konapun additions
		};

		// plugin method for blocking element content
		$.fn.block = function(opts) {
			if ( this[0] === window ) {
				$.blockUI( opts );
				return this;
			}
			var fullOpts = $.extend({}, $.blockUI.defaults, opts || {});
			this.each(function() {
				var $el = $(this);
				if (fullOpts.ignoreIfBlocked && $el.data('blockUI.isBlocked'))
					return;
				$el.unblock({ fadeOut: 0 });
			});

			return this.each(function() {
				if ($.css(this,'position') == 'static') {
					this.style.position = 'relative';
					$(this).data('blockUI.static', true);
				}
				this.style.zoom = 1; // force 'hasLayout' in ie
				install(this, opts);
			});
		};

		// plugin method for unblocking element content
		$.fn.unblock = function(opts) {
			if ( this[0] === window ) {
				$.unblockUI( opts );
				return this;
			}
			return this.each(function() {
				remove(this, opts);
			});
		};

		$.blockUI.version = 2.70; // 2nd generation blocking at no extra cost!

		// override these in your code to change the default behavior and style
		$.blockUI.defaults = {
			// message displayed when blocking (use null for no message)
			message:  '<h1>Please wait...</h1>',

			title: null,		// title string; only used when theme == true
			draggable: true,	// only used when theme == true (requires jquery-ui.js to be loaded)

			theme: false, // set to true to use with jQuery UI themes

			// styles for the message when blocking; if you wish to disable
			// these and use an external stylesheet then do this in your code:
			// $.blockUI.defaults.css = {};
			css: {
				padding:	0,
				margin:		0,
				width:		'30%',
				top:		'40%',
				left:		'35%',
				textAlign:	'center',
				color:		'#000',
				border:		'3px solid #aaa',
				backgroundColor:'#fff',
				cursor:		'wait'
			},

			// minimal style set used when themes are used
			themedCSS: {
				width:	'30%',
				top:	'40%',
				left:	'35%'
			},

			// styles for the overlay
			overlayCSS:  {
				backgroundColor:	'#000',
				opacity:			0.6,
				cursor:				'wait'
			},

			// style to replace wait cursor before unblocking to correct issue
			// of lingering wait cursor
			cursorReset: 'default',

			// styles applied when using $.growlUI
			growlCSS: {
				width:		'350px',
				top:		'10px',
				left:		'',
				right:		'10px',
				border:		'none',
				padding:	'5px',
				opacity:	0.6,
				cursor:		'default',
				color:		'#fff',
				backgroundColor: '#000',
				'-webkit-border-radius':'10px',
				'-moz-border-radius':	'10px',
				'border-radius':		'10px'
			},

			// IE issues: 'about:blank' fails on HTTPS and javascript:false is s-l-o-w
			// (hat tip to Jorge H. N. de Vasconcelos)
			/*jshint scripturl:true */
			iframeSrc: /^https/i.test(window.location.href || '') ? 'javascript:false' : 'about:blank',

			// force usage of iframe in non-IE browsers (handy for blocking applets)
			forceIframe: false,

			// z-index for the blocking overlay
			baseZ: 1000,

			// set these to true to have the message automatically centered
			centerX: true, // <-- only effects element blocking (page block controlled via css above)
			centerY: true,

			// allow body element to be stetched in ie6; this makes blocking look better
			// on "short" pages.  disable if you wish to prevent changes to the body height
			allowBodyStretch: true,

			// enable if you want key and mouse events to be disabled for content that is blocked
			bindEvents: true,

			// be default blockUI will supress tab navigation from leaving blocking content
			// (if bindEvents is true)
			constrainTabKey: true,

			// fadeIn time in millis; set to 0 to disable fadeIn on block
			fadeIn:  200,

			// fadeOut time in millis; set to 0 to disable fadeOut on unblock
			fadeOut:  400,

			// time in millis to wait before auto-unblocking; set to 0 to disable auto-unblock
			timeout: 0,

			// disable if you don't want to show the overlay
			showOverlay: true,

			// if true, focus will be placed in the first available input field when
			// page blocking
			focusInput: true,

            // elements that can receive focus
            focusableElements: ':input:enabled:visible',

			// suppresses the use of overlay styles on FF/Linux (due to performance issues with opacity)
			// no longer needed in 2012
			// applyPlatformOpacityRules: true,

			// callback method invoked when fadeIn has completed and blocking message is visible
			onBlock: null,

			// callback method invoked when unblocking has completed; the callback is
			// passed the element that has been unblocked (which is the window object for page
			// blocks) and the options that were passed to the unblock call:
			//	onUnblock(element, options)
			onUnblock: null,

			// callback method invoked when the overlay area is clicked.
			// setting this will turn the cursor to a pointer, otherwise cursor defined in overlayCss will be used.
			onOverlayClick: null,

			// don't ask; if you really must know: http://groups.google.com/group/jquery-en/browse_thread/thread/36640a8730503595/2f6a79a77a78e493#2f6a79a77a78e493
			quirksmodeOffsetHack: 4,

			// class name of the message block
			blockMsgClass: 'blockMsg',

			// if it is already blocked, then ignore it (don't unblock and reblock)
			ignoreIfBlocked: false
		};

		// private data and functions follow...

		var pageBlock = null;
		var pageBlockEls = [];

		function install(el, opts) {
			var css, themedCSS;
			var full = (el == window);
			var msg = (opts && opts.message !== undefined ? opts.message : undefined);
			opts = $.extend({}, $.blockUI.defaults, opts || {});

			if (opts.ignoreIfBlocked && $(el).data('blockUI.isBlocked'))
				return;

			opts.overlayCSS = $.extend({}, $.blockUI.defaults.overlayCSS, opts.overlayCSS || {});
			css = $.extend({}, $.blockUI.defaults.css, opts.css || {});
			if (opts.onOverlayClick)
				opts.overlayCSS.cursor = 'pointer';

			themedCSS = $.extend({}, $.blockUI.defaults.themedCSS, opts.themedCSS || {});
			msg = msg === undefined ? opts.message : msg;

			// remove the current block (if there is one)
			if (full && pageBlock)
				remove(window, {fadeOut:0});

			// if an existing element is being used as the blocking content then we capture
			// its current place in the DOM (and current display style) so we can restore
			// it when we unblock
			if (msg && typeof msg != 'string' && (msg.parentNode || msg.jquery)) {
				var node = msg.jquery ? msg[0] : msg;
				var data = {};
				$(el).data('blockUI.history', data);
				data.el = node;
				data.parent = node.parentNode;
				data.display = node.style.display;
				data.position = node.style.position;
				if (data.parent)
					data.parent.removeChild(node);
			}

			$(el).data('blockUI.onUnblock', opts.onUnblock);
			var z = opts.baseZ;

			// blockUI uses 3 layers for blocking, for simplicity they are all used on every platform;
			// layer1 is the iframe layer which is used to supress bleed through of underlying content
			// layer2 is the overlay layer which has opacity and a wait cursor (by default)
			// layer3 is the message content that is displayed while blocking
			var lyr1, lyr2, lyr3, s;
			if (msie || opts.forceIframe)
				lyr1 = $('<iframe class="blockUI" style="z-index:'+ (z++) +';display:none;border:none;margin:0;padding:0;position:absolute;width:100%;height:100%;top:0;left:0" src="'+opts.iframeSrc+'"></iframe>');
			else
				lyr1 = $('<div class="blockUI" style="display:none"></div>');

			if (opts.theme)
				lyr2 = $('<div class="blockUI blockOverlay ui-widget-overlay" style="z-index:'+ (z++) +';display:none"></div>');
			else
				lyr2 = $('<div class="blockUI blockOverlay" style="z-index:'+ (z++) +';display:none;border:none;margin:0;padding:0;width:100%;height:100%;top:0;left:0"></div>');

			if (opts.theme && full) {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockPage ui-dialog ui-widget ui-corner-all" style="z-index:'+(z+10)+';display:none;position:fixed">';
				if ( opts.title ) {
					s += '<div class="ui-widget-header ui-dialog-titlebar ui-corner-all blockTitle">'+(opts.title || '&nbsp;')+'</div>';
				}
				s += '<div class="ui-widget-content ui-dialog-content"></div>';
				s += '</div>';
			}
			else if (opts.theme) {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockElement ui-dialog ui-widget ui-corner-all" style="z-index:'+(z+10)+';display:none;position:absolute">';
				if ( opts.title ) {
					s += '<div class="ui-widget-header ui-dialog-titlebar ui-corner-all blockTitle">'+(opts.title || '&nbsp;')+'</div>';
				}
				s += '<div class="ui-widget-content ui-dialog-content"></div>';
				s += '</div>';
			}
			else if (full) {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockPage" style="z-index:'+(z+10)+';display:none;position:fixed"></div>';
			}
			else {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockElement" style="z-index:'+(z+10)+';display:none;position:absolute"></div>';
			}
			lyr3 = $(s);

			// if we have a message, style it
			if (msg) {
				if (opts.theme) {
					lyr3.css(themedCSS);
					lyr3.addClass('ui-widget-content');
				}
				else
					lyr3.css(css);
			}

			// style the overlay
			if (!opts.theme /*&& (!opts.applyPlatformOpacityRules)*/)
				lyr2.css(opts.overlayCSS);
			lyr2.css('position', full ? 'fixed' : 'absolute');

			// make iframe layer transparent in IE
			if (msie || opts.forceIframe)
				lyr1.css('opacity',0.0);

			//$([lyr1[0],lyr2[0],lyr3[0]]).appendTo(full ? 'body' : el);
			var layers = [lyr1,lyr2,lyr3], $par = full ? $('body') : $(el);
			$.each(layers, function() {
				this.appendTo($par);
			});

			if (opts.theme && opts.draggable && $.fn.draggable) {
				lyr3.draggable({
					handle: '.ui-dialog-titlebar',
					cancel: 'li'
				});
			}

			// ie7 must use absolute positioning in quirks mode and to account for activex issues (when scrolling)
			var expr = setExpr && (!$.support.boxModel || $('object,embed', full ? null : el).length > 0);
			if (ie6 || expr) {
				// give body 100% height
				if (full && opts.allowBodyStretch && $.support.boxModel)
					$('html,body').css('height','100%');

				// fix ie6 issue when blocked element has a border width
				if ((ie6 || !$.support.boxModel) && !full) {
					var t = sz(el,'borderTopWidth'), l = sz(el,'borderLeftWidth');
					var fixT = t ? '(0 - '+t+')' : 0;
					var fixL = l ? '(0 - '+l+')' : 0;
				}

				// simulate fixed position
				$.each(layers, function(i,o) {
					var s = o[0].style;
					s.position = 'absolute';
					if (i < 2) {
						if (full)
							s.setExpression('height','Math.max(document.body.scrollHeight, document.body.offsetHeight) - (jQuery.support.boxModel?0:'+opts.quirksmodeOffsetHack+') + "px"');
						else
							s.setExpression('height','this.parentNode.offsetHeight + "px"');
						if (full)
							s.setExpression('width','jQuery.support.boxModel && document.documentElement.clientWidth || document.body.clientWidth + "px"');
						else
							s.setExpression('width','this.parentNode.offsetWidth + "px"');
						if (fixL) s.setExpression('left', fixL);
						if (fixT) s.setExpression('top', fixT);
					}
					else if (opts.centerY) {
						if (full) s.setExpression('top','(document.documentElement.clientHeight || document.body.clientHeight) / 2 - (this.offsetHeight / 2) + (blah = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + "px"');
						s.marginTop = 0;
					}
					else if (!opts.centerY && full) {
						var top = (opts.css && opts.css.top) ? parseInt(opts.css.top, 10) : 0;
						var expression = '((document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + '+top+') + "px"';
						s.setExpression('top',expression);
					}
				});
			}

			// show the message
			if (msg) {
				if (opts.theme)
					lyr3.find('.ui-widget-content').append(msg);
				else
					lyr3.append(msg);
				if (msg.jquery || msg.nodeType)
					$(msg).show();
			}

			if ((msie || opts.forceIframe) && opts.showOverlay)
				lyr1.show(); // opacity is zero
			if (opts.fadeIn) {
				var cb = opts.onBlock ? opts.onBlock : noOp;
				var cb1 = (opts.showOverlay && !msg) ? cb : noOp;
				var cb2 = msg ? cb : noOp;
				if (opts.showOverlay)
					lyr2._fadeIn(opts.fadeIn, cb1);
				if (msg)
					lyr3._fadeIn(opts.fadeIn, cb2);
			}
			else {
				if (opts.showOverlay)
					lyr2.show();
				if (msg)
					lyr3.show();
				if (opts.onBlock)
					opts.onBlock.bind(lyr3)();
			}

			// bind key and mouse events
			bind(1, el, opts);

			if (full) {
				pageBlock = lyr3[0];
				pageBlockEls = $(opts.focusableElements,pageBlock);
				if (opts.focusInput)
					setTimeout(focus, 20);
			}
			else
				center(lyr3[0], opts.centerX, opts.centerY);

			if (opts.timeout) {
				// auto-unblock
				var to = setTimeout(function() {
					if (full)
						$.unblockUI(opts);
					else
						$(el).unblock(opts);
				}, opts.timeout);
				$(el).data('blockUI.timeout', to);
			}
		}

		// remove the block
		function remove(el, opts) {
			var count;
			var full = (el == window);
			var $el = $(el);
			var data = $el.data('blockUI.history');
			var to = $el.data('blockUI.timeout');
			if (to) {
				clearTimeout(to);
				$el.removeData('blockUI.timeout');
			}
			opts = $.extend({}, $.blockUI.defaults, opts || {});
			bind(0, el, opts); // unbind events

			if (opts.onUnblock === null) {
				opts.onUnblock = $el.data('blockUI.onUnblock');
				$el.removeData('blockUI.onUnblock');
			}

			var els;
			if (full) // crazy selector to handle odd field errors in ie6/7
				els = $('body').children().filter('.blockUI').add('body > .blockUI');
			else
				els = $el.find('>.blockUI');

			// fix cursor issue
			if ( opts.cursorReset ) {
				if ( els.length > 1 )
					els[1].style.cursor = opts.cursorReset;
				if ( els.length > 2 )
					els[2].style.cursor = opts.cursorReset;
			}

			if (full)
				pageBlock = pageBlockEls = null;

			if (opts.fadeOut) {
				count = els.length;
				els.stop().fadeOut(opts.fadeOut, function() {
					if ( --count === 0)
						reset(els,data,opts,el);
				});
			}
			else
				reset(els, data, opts, el);
		}

		// move blocking element back into the DOM where it started
		function reset(els,data,opts,el) {
			var $el = $(el);
			if ( $el.data('blockUI.isBlocked') )
				return;

			els.each(function(i,o) {
				// remove via DOM calls so we don't lose event handlers
				if (this.parentNode)
					this.parentNode.removeChild(this);
			});

			if (data && data.el) {
				data.el.style.display = data.display;
				data.el.style.position = data.position;
				data.el.style.cursor = 'default'; // #59
				if (data.parent)
					data.parent.appendChild(data.el);
				$el.removeData('blockUI.history');
			}

			if ($el.data('blockUI.static')) {
				$el.css('position', 'static'); // #22
			}

			if (typeof opts.onUnblock == 'function')
				opts.onUnblock(el,opts);

			// fix issue in Safari 6 where block artifacts remain until reflow
			var body = $(document.body), w = body.width(), cssW = body[0].style.width;
			body.width(w-1).width(w);
			body[0].style.width = cssW;
		}

		// bind/unbind the handler
		function bind(b, el, opts) {
			var full = el == window, $el = $(el);

			// don't bother unbinding if there is nothing to unbind
			if (!b && (full && !pageBlock || !full && !$el.data('blockUI.isBlocked')))
				return;

			$el.data('blockUI.isBlocked', b);

			// don't bind events when overlay is not in use or if bindEvents is false
			if (!full || !opts.bindEvents || (b && !opts.showOverlay))
				return;

			// bind anchors and inputs for mouse and key events
			var events = 'mousedown mouseup keydown keypress keyup touchstart touchend touchmove';
			if (b)
				$(document).bind(events, opts, handler);
			else
				$(document).unbind(events, handler);

		// former impl...
		//		var $e = $('a,:input');
		//		b ? $e.bind(events, opts, handler) : $e.unbind(events, handler);
		}

		// event handler to suppress keyboard/mouse events when blocking
		function handler(e) {
			// allow tab navigation (conditionally)
			if (e.type === 'keydown' && e.keyCode && e.keyCode == 9) {
				if (pageBlock && e.data.constrainTabKey) {
					var els = pageBlockEls;
					var fwd = !e.shiftKey && e.target === els[els.length-1];
					var back = e.shiftKey && e.target === els[0];
					if (fwd || back) {
						setTimeout(function(){focus(back);},10);
						return false;
					}
				}
			}
			var opts = e.data;
			var target = $(e.target);
			if (target.hasClass('blockOverlay') && opts.onOverlayClick)
				opts.onOverlayClick(e);

			// allow events within the message content
			if (target.parents('div.' + opts.blockMsgClass).length > 0)
				return true;

			// allow events for content that is not being blocked
			return target.parents().children().filter('div.blockUI').length === 0;
		}

		function focus(back) {
			if (!pageBlockEls)
				return;
			var e = pageBlockEls[back===true ? pageBlockEls.length-1 : 0];
			if (e)
				e.focus();
		}

		function center(el, x, y) {
			var p = el.parentNode, s = el.style;
			var l = ((p.offsetWidth - el.offsetWidth)/2) - sz(p,'borderLeftWidth');
			var t = ((p.offsetHeight - el.offsetHeight)/2) - sz(p,'borderTopWidth');
			if (x) s.left = l > 0 ? (l+'px') : '0';
			if (y) s.top  = t > 0 ? (t+'px') : '0';
		}

		function sz(el, p) {
			return parseInt($.css(el,p),10)||0;
		}

	}


	/*global define:true */
	if (typeof define === 'function' && define.amd && define.amd.jQuery) {
		define(['jquery'], setup);
	} else {
		setup(jQuery);
	}

})();
﻿// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
/*global cache_register_onbeforerestorevalues:true cache_register_onbeforeunload:true */
/*jshint sub:true */
var string_ci_ai = function(s) {
	var r=s.toLowerCase();
	r = r.replace(new RegExp("[àáâãäå]", "g"),"a");
	r = r.replace(new RegExp("æ","g"),"ae");
	r = r.replace(new RegExp("ç","g"),"c");
	r = r.replace(new RegExp("[èéêë]","g"),"e");
	r = r.replace(new RegExp("[ìíîï]","g"),"i");
	r = r.replace(new RegExp("ñ","g"),"n");
	r = r.replace(new RegExp("[òóôõö]","g"),"o");
	r = r.replace(new RegExp("","g"),"oe");
	r = r.replace(new RegExp("[ùúûü]","g"),"u");
	r = r.replace(new RegExp("[ýÿ]","g"),"y");
	return r;
};
window['string_ci_ai'] = string_ci_ai;

var slugify = function(s) {
	s = string_ci_ai(s);
	s = s.replace(/-/g, ' ').replace(/[^a-z0-9\s]/g, '');
	s = s.trim();
	return s.replace(/\s+/g, '-');
};
window['slugify'] = slugify;

var default_cache_search_fn = function($, cache, prop, regex_pre, regex_post) {
	prop = prop || 'value';
	regex_pre = regex_pre || '';
	regex_post = regex_post || '';
	return function (request, response) {
		if (cache.term && (new RegExp(regex_pre + $.ui.autocomplete.escapeRegex(cache.term) + regex_post, "i")).test(request.term) && cache.content && cache.content.length < 13) {
			var matcher = new RegExp(regex_pre + $.ui.autocomplete.escapeRegex(request.term) + regex_post, "i");
			response($.grep(cache.content, function(value) {
				return matcher.test(string_ci_ai(value[prop]));
			}));
			return true;
		}

		return false;
	};
};

window['default_cache_search_fn'] = default_cache_search_fn;

var create_caching_source_fn = function($, url, cache, prop, cache_search_fn) {
	cache = cache || {};
	prop = prop || 'value';
	cache_search_fn = cache_search_fn || default_cache_search_fn($, cache, prop);
	return function (request, response, override_url) {
		request.term = string_ci_ai(request.term);
		if (cache.term === request.term && cache.content) {
			response(cache.content);
			return;
		}
		if (cache_search_fn(request, response)) {
			return;
		}
		$.ajax({
			url: override_url || url,
			dataType: "json",
			data: request,
			cache: false,
			success: function(data) {
				cache.term = request.term;
				cache.content = data;
				response(data);
			}
		});
	};
};

window['create_caching_source_fn'] = create_caching_source_fn;

var init_community_autocomplete = function($, id, url, minLength, cmidfield) {
	var cache = {};
	if (cmidfield) {
		cmidfield = $(cmidfield);
	}
	if (cmidfield && !cmidfield.length) {
		cmidfield = null;
	}
	var input_el = $("#" + id).
		autocomplete({
			focus:function(event,ui) {
				return false;
			},
			select: function(event, ui) {
				input_el.data({
					chkid: ui.item.chkid,
					display: ui.item.value
				});
			},
			source: create_caching_source_fn($,url,cache),
			minLength: minLength}).
		keypress(function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				input_el.autocomplete('close');
			}
		});

	if (cmidfield) {
		input_el.parents('form').on('submit', function() {
			var input_el_val = input_el.val();
			if (input_el.data('display') === input_el_val) {
				cmidfield.val(input_el.data('chkid'));
				return;
			}
			if (cache.content) {
				var testvalue = string_ci_ai(input_el_val);
				var values = $.grep(cache.content, function(value) {
					return string_ci_ai(value['value']) === testvalue;
				});
				if (values.length === 1) {
					cmidfield.val(values[0].chkid);
					input_el.data({chkid: values[0].chkid, display: values[0].value}).val(values[0].value);
					return;
				}
			}

			cmidfield.val('');
		});

		cache_register_onbeforerestorevalues(function(csh) {
			if (!input_el.length) {
				return;
			}
			var data = csh['autocomplete_data_' + input_el[0].id];
			if (data) {
				input_el.data(data);
			}
		});

		cache_register_onbeforeunload(function(csh) {
			if (!input_el.length) {
				return;
			}
			var data = input_el.data();
			if (data.display && data.chkid) {
				csh['autocomplete_data_' + input_el[0].id] = {
					display: data.display,
					chkid: data.chkid
				};
			}
		});
	}



};

window['init_community_autocomplete'] = init_community_autocomplete;
})();
// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
window['entryform'] = window['entryform'] || {};

window['create_checklist_onbefore_fns'] = function($, field, added_values, add_new_value) {
	cache_register_onbeforeunload(function(cache) {
		cache[field + '_added'] = added_values;
	});
	cache_register_onbeforerestorevalues(function (cache) {
		var array = cache[field + '_added'];
		if (!array) {
			return;
		}
		$.each(array, function (index, item) {
			add_new_value(item.chkid, item.display, "");
		});
	});
};

window['basic_chk_add_html'] = function($, field) {
	return function (chkid, display) {
		var new_row = $('<tr>').
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: field + '_ID',
							value: chkid
							})
					).
					append(document.createTextNode(' ' + display))
				).
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_NOTES_' + chkid,
							name: field + '_NOTES_' + chkid,
							size: entryform.chk_notes_size,
							maxlength: entryform.chk_notes_maxlen
							})
					)
				);
		$('#' + field + '_existing_add_table').append(new_row);
		return new_row.find('input[type="checkbox"]')[0];
		
	};
};

var already_added_checklists = {};
var do_autocomplete_call = function(field) {
		$('#NEW_' + field).autocomplete(already_added_checklists[field]);
};
window['init_autocomplete_checklist'] = function($, options) {
	var field = options.field;

	if (already_added_checklists[field]) {
		do_autocomplete_call(field);
		return;
	}

	var source = options.source;
	options.minLength = options.minLength || 1;
	options.delay = options.delay || 300;
	options.add_new_html = options.add_new_html || basic_chk_add_html($, field);
	options.match_prop = options.match_prop || 'value';
	options.txt_not_found = options.txt_not_found || 'Not Found';

	var delegate_root = $(options.delegate_root || document);

	var added_values = options.added_values || [];
	var add_new_value = function(chkid, display, label) {
		//console.log('add');
		var existing_chk = document.getElementById(field + '_ID_' + chkid);
		if (existing_chk) {
			existing_chk.checked = true;
			if (options.after_add_new_value) {
				options.after_add_new_value.call(existing_chk);
			}
			//already exists
			return;
		}

		added_values.push({chkid: chkid, display: display, label: label});

		var new_chk = options.add_new_html(chkid, display, label);
		if (options.after_add_new_value) {
			options.after_add_new_value.call(new_chk);
		}

	};

	create_checklist_onbefore_fns($, field, added_values, add_new_value);

	var cache = {};

	var after_add = function(evt) {
		//console.log('after add');
		$('#NEW_' + field).
			data({chkid: "", display: "", label: ""}).
			prop('value', "").
			focus();

		$('#' + field + '_error').hide('slow', function() {
				$(this).remove();
		});
	};

	var look_for_value = null;
	var source_fn = null;
	(function (source) {
		var array, url;
		if ( $.isArray(source) ) {
			array = source;
			source_fn = function( request, response ) {
				// escape regex characters
				var matcher = new RegExp( $.ui.autocomplete.escapeRegex(string_ci_ai(request.term)));
				response( $.grep( array, function(value) {
					return matcher.test( string_ci_ai(value[options.match_prop] || value));
				}) );
			};
			look_for_value = function(invalue, response) {
				var inputvalue = string_ci_ai(invalue);
				var values = $.grep(array, function(value) {
							return string_ci_ai(string_ci_ai(value[options.match_prop] || value)) === inputvalue;
						});
				if (values.length === 1) {
					response(values[0]);
					return true;
				} else {
					response();
				}

			};
		} else if ( typeof source === "string" ) {
			url = source;
			source_fn = create_caching_source_fn($, url, cache, options.match_prop),
			look_for_value = function(invalue, response, dont_source) {
				var inputvalue = string_ci_ai(invalue);
				var content = cache.content;
				if (cache.content) {
					var values = $.grep(cache.content, function(value) {
								return string_ci_ai(value[options.match_prop]) === inputvalue;
							});
					if (values.length === 1) {
						response(values[0]);
						return;
					}
				}
				if (dont_source || string_ci_ai(cache.term || "") === inputvalue) {
					response();
					return;
				}

				source_fn({term: inputvalue}, function(data) {
							look_for_value(invalue, response, true);
						});
			};
		} else {
			source_fn = source;
			look_for_value = options.look_for_fn;
		}
	})(source);

	var do_show_error = function() {
		if ($("#" + field + "_error").length === 0) {
			//console.log('error');
			$('#' + field + '_new_input_table').before($('<p>').
					hide().
					addClass('Alert').
					prop('id', field + '_error').
					append(document.createTextNode(options.txt_not_found)));

			$("#" + field + "_error").show('slow');
		}
	};

	var on_add_click = function(evt) {
		//console.log('onclick');
		var newfield = $('#NEW_' + field);
		var chkid = newfield.data('chkid');
		var display = newfield.data('display');
		var label = newfield.data('label');
		var newfieldval = newfield[0].value;
		if (chkid && display && display == newfieldval) {
			add_new_value(chkid, display, label);
			after_add();
			return false;

		}
		look_for_value(newfield[0].value, function(item) {
			if (item) {
				add_new_value(item.chkid, item.value, item.label);
				after_add();
			} else {
				do_show_error();
			}
		});
		return false;

	};
	delegate_root.on('click', "#add_" + field, on_add_click);

	already_added_checklists[field] = {
		focus: function(e,ui) {
			return false;
		},
		source: source_fn,
		minLength: options.minLength,
		delay: options.delay,
		select: function(evt, ui) {
			$('#NEW_' + field).data({
				chkid: ui.item.chkid,
				display: ui.item.value,
				label: ui.item.label
				});
		}
	};

	delegate_root.on('keypress', '#NEW_' + field, function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				$('#NEW_' + field).autocomplete('close');
				$('#add_' + field).trigger('click');
			}
		});

	do_autocomplete_call(field);

};
window['init_languages'] = function($, txt_not_found) {
	var add_button = null, template = null, table = $('#LN_existing_add_table');
	var change_fn = function() {
		var self = $(this), entry = self.parents('.language-entry'), details = entry.find('.language-details-notes');
		if (this.checked) {
			details.slideDown();
		} else {
			details.slideUp();
		}
	}
	var options = {
		field: 'LN',
		source: entryform.languages_source,
		txt_not_found: txt_not_found,
		after_add_new_value: change_fn,
		add_new_html: function(chkid, display) {
			if (add_button === null) {
				add_button = $('#add_LN');
				template = add_button.data('newTemplate');
			}

			var html = template.replace(/LANGNAMELANGNAME/g, display).replace(/IDIDID/g, chkid);
			table.append(html);

		}

	};
	init_autocomplete_checklist($, options);
	table.on('change', '.language-primary', change_fn).uitooltip({
		items: '[data-help-text]',
		content: function() {
			var self = $(this);
			return '<div class="language-help-text">' + self.data('helpText') + "</div>";
		},
		position: {
			my: "center bottom-20",
			at: "center top",
			using: function( position, feedback ) {
			  $( this ).css( position );
			  $( "<div>" )
				.addClass( "arrow" )
				.addClass( feedback.vertical )
				.addClass( feedback.horizontal )
				.appendTo( this );
			}
		}
	});
	
	window['languages_check_state'] = change_fn;
	
};

})();
﻿// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
/*global
 init_autocomplete_checklist:true
*/
	jQuery.fn.autoShorten = function(max, more, less) {
		return this.each(function(){
			max = max || 350;
			more = more || '[read more]';
			less = less || '[less]';
			var self = $(this), html = self.html();
			if (html.length > max) {
				var words = html.substring(0,max).split(" ");
				var shortText = $('<div>').html(words.slice(0, words.length - 1).join(" ") + ' ').append('<span class="ellipse-toggle SimulateLink">&hellip; ' + more +'</span>').html();
				$(this).data('replacementText', html + ' <span class="ellipse-toggle SimulateLink">' + less + '</span>')
				.html(shortText)
				.on('click', 'span.ellipse-toggle', function() {
					var tempText = self.html();
					self.html(self.data('replacementText'));
					self.data('replacementText', tempText);
				});
			}
		});
	};

	var add_new_html = function($, field, name) {
		name = name || (field + '_ID');
		return function(chkid, display) {
			var button = $('#add_' + field), my_cell = button.parent(), my_row = my_cell.parent(), last_row = my_row.prev('tr'),
				col_target = parseInt(my_cell.prop("colspan"), 10), last_row_cols = last_row.find('td').length;
			if (!last_row.length || col_target === last_row_cols) {
				last_row = $('<tr>').insertBefore(my_row);
			}
			last_row.append(
				$('<td>').append(
					$('<label>').
					text(' ' + display).
					prepend(
						$('<input type="checkbox" checked>').prop({
							id: field +'_ID_' + chkid,
							value: chkid,
							name: name
						})
					)
				)
			);
		};
	};

	var init_user_autocomplete = function(url, txt_not_found) {
		init_autocomplete_checklist($, {
			source: url,
			field: 'reminder_user',
			add_new_html: add_new_html($, 'reminder_user'),
			txt_not_found: txt_not_found
		});
	};

	var initialize_reminders_form = function() {
		$(document).on('click', '#add_reminder_agency', function(evt) {
			evt.preventDefault();
			var agency_select = $('#NEW_reminder_agency');
			var agency_add_html = add_new_html($, 'reminder_agency');
			var val = agency_select[0].value;
			if (val) {
				var target_input = $('#reminder_agency_ID_' + val);
				if (target_input.length) {
					target_input.prop('checked', true);
				} else {
					agency_add_html(val, val);
				}
				agency_select.find('option').first().prop({selected: true});
			}
			return false;
		});
		$.each(['NUM', 'VNUM'], function(index, field) {
			$(document).on('click', '#add_' + field, function(evt) {
				evt.preventDefault();
				var field_input = $('#NEW_' + field);
				var field_add_html = add_new_html($, field, field);
				var val = field_input[0].value;
				if (val) {
					var target_input = $('#' + field + '_ID_' + val);
					if (target_input.length) {
						target_input.prop('checked', true);
					} else {
						field_add_html(val, val);
					}
				}
				field_input[0].value = '';
				return false;
			}).on('keypress', '#NEW_' + field, function(evt) {
				if (evt.keyCode === 13) {
					evt.preventDefault();
					$('#add_' + field).trigger('click');
				}
			});

		});
	};
	var hide_empty_headers = function() {
		$('.reminder-section').each(function() {
			if (!$(this).find('.reminder-item:not(.dismissed)').length) {
				$(this).hide();
			}
		});
	};
	var initialize_reminder_list = function(existing_reminders, txt_more, txt_less) {
		$('#reminder-items-inactive').hide();
		hide_empty_headers();
		$('#reminder-header-inactive').addClass("SimulateLink").prepend($('<span class="ui-icon ui-icon-triangle-1-e" style="display: inline-block">'));
		$('#reminder-add-link, #reminder-show-dismissed, #show-closed-notices').uibutton();

		if (!$('#existing-reminders-page').addClass('hide-dismissed').find('.dismissed').length) {
			$('#reminder-dismiss-ui').hide();
		}
		existing_reminders.find('.AutoShorten').autoShorten(null, txt_more, txt_less);
	};

	window['initialize_reminders'] = function(title, userurl, reminder_url, reminder_dismiss_url, txt_colon, txt_more, txt_less, txt_loading, delete_link, txt_not_found) {
		var reminder_dialog = null;
		init_user_autocomplete(userurl, txt_not_found);
		initialize_reminders_form();
		initialize_reminder_list($('#existing-reminders-page'), txt_more, txt_less);
		var reminders_list_div = $('#existing-reminders-page').on('click', '#reminder-header-inactive', function() {
			var inactive = $('#reminder-items-inactive'),
				icon = $(this).find('span.ui-icon');
			if ( inactive.is(':hidden') ) {
				inactive.slideDown('slow');
				icon.removeClass('ui-icon-triangle-1-e').addClass('ui-icon-triangle-1-s');
			} else {
				inactive.slideUp('slow');
				icon.removeClass('ui-icon-triangle-1-s').addClass('ui-icon-triangle-1-e');
			}
		}).on('click', '#reminder-show-dismissed', function() {
			if (this.checked) {
				reminders_list_div.removeClass('hide-dismissed');
				$('.reminder-section').show();
			} else {
				reminders_list_div.addClass('hide-dismissed');
				hide_empty_headers();
			}
		}).uitooltip({
			items: 'span.details-link',
			content: function() {
				return $(this).data('tooltip');
			}
		}).on('click', '.dismiss-reminder,.restore-reminder', function() {
			var self = $(this), is_dismiss = self.is('.dismiss-reminder'),
				reminder_id = self.data('reminderId');
			$.when($.ajax(reminder_dismiss_url.replace('IDIDID', reminder_id), {
				dataType: 'json',
				type: 'post',
				cache: false,
				data: {dismiss: is_dismiss ? 'on' : null, json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					var row = self.parents('tr').first();
					if (data.dismissed) {
						row.addClass('dismissed');
						$('#reminder-dismiss-ui').show();
					} else {
						row.removeClass('dismissed');
						if (!$('#existing-reminders-page .dismissed').length) {
							$('#reminder-dismiss-ui').hide();
						}
					}
				} else {
					/// XXX
				}
			});

		});
		var reminders_popup_link = $('#reminders').click(function() {
			var existing_reminders = $('#existing-reminders-page').empty().text(txt_loading);
			$.when($.ajax(reminder_url, {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					existing_reminders[0].innerHTML = data.reminders;
					initialize_reminder_list(existing_reminders, txt_more, txt_less);
					if (reminder_dialog.height() > $(window).height() - 10) {
						reminder_dialog.dialog('option', 'height', $(window).height() - 10);
					}
					reminder_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			if ( ! reminder_dialog ) {
				reminder_dialog = $('#reminder-dialog').dialog({
					title: title,
					width: 500,
					maxHeight: $(window).height() - 10,
					open: function() {
						$(this).dialog({position: "center"});
					}
				});
				$(window).resize($.throttle(250, function() {
					reminder_dialog.dialog('option', 'maxHeight', $(this).height() - 10);
				}));
			} else {
				reminder_dialog.dialog('option', 'height', 'auto');
				reminder_dialog.dialog('open');
			}
		});
		var reminder_edit_dialog = null;
		$('#reminder-dialog').on('click', '.edit-link', function(evt) {
			evt.preventDefault();
			$('#reminder-edit-dialog').empty().text(txt_loading);
			$.when($.ajax(this.href, {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.find('.DatePicker').css('zIndex', reminder_edit_dialog.css('zIndex')).autodatepicker();
					init_user_autocomplete(userurl);
					reminder_edit_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_edit_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			if (!reminder_edit_dialog) {
				reminder_edit_dialog = $('#reminder-edit-dialog').dialog({width: 'auto', height: 'auto'});
			} else {
				reminder_edit_dialog.dialog('open');
			}
			return false;
		});
		$('#reminder-edit-dialog').on('submit', 'form', function(evt) {
			evt.preventDefault();
			var form = $(this);
			$.when($.ajax(form.prop('action'), {
				dataType: 'json',
				data: form.serialize(),
				type: form.prop('method')
			})).done(function(data) {
				if (!data.success) {
					//error condition
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.find('.DatePicker').css('zIndex', reminder_edit_dialog.css('zIndex')).autodatepicker();
					init_user_autocomplete(userurl);
				} else {
					reminders_popup_link.trigger('click');
					reminder_edit_dialog.dialog('close');
				}
			});
			return false;
		}).on('click', '#delete-reminder', function(evt) {
			evt.preventDefault();
			$('#reminder-edit-dialog').empty().text(txt_loading);
			$.when($.ajax(delete_link.replace('IDIDID', $(this).data('reminderId')), {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_edit_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			return false;
		});
	};
})();
﻿// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
	/*global google:true */
	var map = null;
	var map_canvas = null;

	var draw_map_start = function(keyarg, culture) {

		var iframeurl = 'https://www.google.com/maps/embed/v1/place?' + keyarg;
		var myLatlng = map_canvas.attr('latitude') + ',' + map_canvas.attr('longitude');
		var mapOptions = {
			center: myLatlng,
			zoom: 13,
			q: myLatlng,
			maptype: 'roadmap',
			language: culture
		};
		iframeurl = iframeurl + '&' + $.param(mapOptions)

		map_canvas.show();
		map_canvas.append(
			$('<iframe>').prop({
				src: iframeurl,
				frameborder: 0
			}).css({border: 0, height: '100%', width: '100%'})
		);

		return;
	};

	window['initialize_record_maps'] = function(keyarg, culture) {
		map_canvas = $('div#map_canvas');
		if (map_canvas.length) {
			draw_map_start(keyarg, culture);
		}
	};

})();
// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
/*global */
	var config = {}, $=jQuery, vacancy_elements=null;
	var initialize_vacancy_options = function(options) {
		config = options;
	};
	var inserted_incrementers = {};
	var edit_button_sets = {};
	var bt_vut_ids_to_refresh = '';

	var set_button_icon = function() {
		var self = $(this);
		self.uibutton({
			icons: {
				primary: self.data('icon')
			},
			text: false
		});
	};

	var apply_vacancy_ui = function(data) {
		vacancy_elements = vacancy_elements.map(function() { return data.indexOf($(this).data('vutId')) >= 0 ? this : null ; });
		vacancy_elements.each(function() {
			var self = $(this), vut_id = self.data('vutId');
			if (!self.data('uiAdded')) {
				self.data('uiAdded', true);
				var buttonset = $('<span class="vacancy-ui vacancy-buttonset"><button class="vacancy-edit" id="vacancy-edit-' + vut_id + '" data-vut-id="' + vut_id + '" title="' + config.edit_txt + '" data-icon="ui-icon-pencil">' + config.edit_txt + '</button><button class="vacancy-history" data-icon="ui-icon-note" data-vut-id="' + vut_id + '" title="' + config.history_txt + '">' + config.history_txt + '</button></span>').buttonset().insertAfter(self);
				buttonset.find('button').each(set_button_icon);
			}
		});
	};

	var insert_incrementer_ui = function(edit_button_set, vut_id) {
		var buttonset = $('<span class="vacancy-incrementer-ui vacancy-buttonset" style="display: none;" id="vacancy-incrementer-' + vut_id + '" data-vut-id="' + vut_id + '"><button class="vacancy-incrementer-up" data-icon="ui-icon-plusthick">' + config.up_txt + '</button><button class="vacancy-incrementer-down" data-icon="ui-icon-minusthick">' + config.down_txt + '</button><button class="vacancy-incrementer-done" data-icon="ui-icon-check">' + config.done_txt + '</button></span>').buttonset().insertAfter(edit_button_set);
		buttonset.find('button').each(set_button_icon);
		return buttonset;
	};

	var insert_notification = function(vacancy_notify, className, text) {
		var notification = $(
				'<div class="alert alert-dismissable ' + className + '" style="display: none"></div>'
			).text(text).append(
				'<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
			),
			first_child = vacancy_notify.children().first();
		if (first_child.length) {
			first_child.before(notification);
		} else {
			vacancy_notify.append(notification);
		}

		notification.slideDown('slow');
	};

	var handle_vacancy_updates = function(updates) {
		$.each(updates, function(idx, data) {
			$('#vacancy-count-' + data.bt_vut_id).text(data.text);
		});
	};
	var handle_vacancy_increment_result = function(vut_id, vacancy, td, vacancy_notify) {
		return function(data) {
			td.unblock();
			if (data.updates) {
				handle_vacancy_updates(data.updates);
			}
			insert_notification(vacancy_notify, (data.success ? 'alert-highlight' : 'alert-error') + ' vacancy-notification', data.msg);
		};
	};

	var handle_vacancy_increment_failure = function(vut_id, vacancy, td, vacancy_notify) {
		return function(jqXHR, textStatus) {
			td.unblock();
			insert_notification(vacancy_notify, 'alert-error vacancy-notification', config.server_error_txt + (textStatus !== 'error' ? textStatus : jqXHR.statusText));
		};
	};

	var timeoutID;
	var request_vacancy_update = function() {
		if (!bt_vut_ids_to_refresh) {
			return;
		}
		if (timeoutID) {
			clearTimeout(timeoutID);
		}
		timeoutID = setTimeout(get_updated_vacancy, 15000);
	};

	var get_updated_vacancy = function() {
		timeoutID = null;
		$.ajax({
			dataType: "json",
			url: config.refresh_url,
			cache: false,
			data: {
				ids: bt_vut_ids_to_refresh
			}
		}).done(function(data) {
			if (data.success) {
				handle_vacancy_updates(data.updates);
			}
		}).always(request_vacancy_update);
	};

	var increment = function(value, buttonset) {
		var td = buttonset.parent().block({message: null});
		var vut_id = buttonset.data('vutId');
		var vacancy = td.find('.vacancy-count');
		var vacancy_notify = td.find('.vacancy-notify-area');
		if (!vacancy_notify.length) {
			vacancy_notify = $('<div class="vacancy-notify-area alert-stack"></div>');
			vacancy_notify.appendTo(td);
		}
		$.ajax({
			dataType: "json",
			url: config.increment_url,
			type: 'POST',
			data: {
				BT_VUT_ID: vut_id,
				Value: value
			}
		}).done(
			handle_vacancy_increment_result(vut_id, vacancy, td, vacancy_notify)
		).fail(
			handle_vacancy_increment_failure(vut_id, vacancy, td, vacancy_notify)
		);
	};

	var initialize_vacancy_ui =  function() {
		if (!config.permission_url) {
			return;
		}
		vacancy_elements = $('.vacancy-count');
		var ids = vacancy_elements.map(function() { return $(this).data('vutId'); }).get();
		ids = ids.join();
		bt_vut_ids_to_refresh = ids;
		if (!ids) {
			return;
		}
		$.ajax({
			dataType: "json",
			url: config.permission_url,
			cache: false,
			data: {ids: ids}
		}).done(apply_vacancy_ui);

		request_vacancy_update();
	};

	var vacancy_dialog = null;
	var get_dialog = function() {
		if (!vacancy_dialog) {
			vacancy_dialog = $('<div id="vacancy-dialog" style="display:none;"></div>').appendTo($('body')).dialog({
				autoOpen: false,
				closeText: config.close_txt,
				title: config.history_title_txt,
				minWidth: 500
			});

		}

		return vacancy_dialog;
	};

	var dialog_error = function(dialog, msg) {
		var error_p = $('<p class="Alert"></p>').text(msg);
		dialog.empty().append(error_p);
	};
	var handle_history_success = function(data) {
		var dialog = get_dialog();
		if (data.success) {
			dialog.empty().html(data.content);
			dialog.dialog('option', 'title', data.title);
		} else {
			dialog_error(dialog, data.content);
			dialog.dialog('option', 'title', data.title);
		}
	};

	var handle_history_fail = function(jqXHR, textStatus) {
		var dialog = get_dialog();
		dialog_error(dialog, config.server_error_txt + (textStatus !== 'error' ? textStatus : jqXHR.statusText));
	};
	var initialize_vacancy_events = function() {

		$(document).on('click', '.vacancy-edit', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var self = $(this), vut_id = self.data('vutId'), buttonset = self.parent(), incrementer_ui = inserted_incrementers[vut_id];

			if (!incrementer_ui) {
				incrementer_ui = insert_incrementer_ui(buttonset, vut_id);
				edit_button_sets[vut_id] = buttonset;
			}

			self.parent().hide();
			incrementer_ui.show();
		}).on('click', '.vacancy-incrementer-done', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var buttonset = $(this).parent(), vut_id = buttonset.data('vutId'), edit_button_set = edit_button_sets[vut_id];
			buttonset.hide();
			edit_button_set.show();

			var toremove = buttonset.parent().parent().find('.vacancy-notify-area');
			toremove.slideUp('fast', function() {
				toremove.remove();
			});

		}).on('click', '.vacancy-incrementer-up', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			increment(1, $(this).parent());
		}).on('click', '.vacancy-incrementer-down', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			increment(-1, $(this).parent());
		}).on('click', '.vacancy-history', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var self = $(this), vut_id = self.data('vutId');
			var dialog = get_dialog();

			dialog.html('<p class="Info">' + config.loading_txt + '</p>').dialog('close').dialog('open').dialog('option', 'title', config.history_title_txt);

			$.ajax({
				dataType: 'json',
				url: config.history_url,
				cache: false,
				data: {BT_VUT_ID: vut_id}
			}).done(handle_history_success).fail(handle_history_fail);

		}).on('click', '.close', function(evt) {
			evt.preventDefault();
			evt.stopPropagation();
			var self = $(this),
				toremove = self.parents('.' + self.data('dismiss')).first();
			toremove.slideUp('slow', function() { toremove.remove(); });
		});
	};

	window['initialize_vacancy'] = function(options) {
		initialize_vacancy_options(options);
		initialize_vacancy_ui();
		initialize_vacancy_events();
	};

	window['initialize_vacancy_options'] = initialize_vacancy_options;
	window['initialize_vacancy_ui'] = initialize_vacancy_ui;
	window['initialize_vacancy_events'] = initialize_vacancy_events;


})();

// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
	var add_details_last_visible_class = function() {
		$('.agency-overview').each(function() {
			$(this).find('.related-row:visible').last().addClass('last-visible');
		});
	};
	window['initialize_listing_toggle'] = function(show_listings_txt, hide_listings_txt, show_deleted_txt, hide_deleted_txt) {
		$(document).on('click', '.show-toggle', function() {
			var self = $(this);
			var related_records = self.parents('.related-records');
			var details = related_records.find('.details');
			var agency_overview = related_records.parents('.agency-overview');
			if (details.is(':visible')) {
				details.slideUp(function(){
					self.text(show_listings_txt);
					agency_overview.find('.related-row').removeClass('last-visible').filter(':visible').last().addClass('last-visible');
				});
			} else {
				var related_rows = agency_overview.find('.related-row').removeClass('last-visible');
				details.slideDown(function(){
					self.text(hide_listings_txt);
					related_rows.filter(':visible').last().addClass('last-visible');
				});
			}
			return false;
		}).on('click', '.deleted-toggle', function() {
			var self = $(this);
			var related_records = self.parents('.related-records');
			var details = related_records.find('.deleted-records');
			var agency_overview = related_records.parents('.agency-overview');
			if (details.is(':visible')) {
				details.slideUp(function(){
					self.text(show_deleted_txt);
					agency_overview.find('.related-row').removeClass('last-visible').filter(':visible').last().addClass('last-visible');
				});
			} else {
				var related_rows = agency_overview.find('.related-row').removeClass('last-visible');
				details.slideDown(function(){
					self.text(hide_deleted_txt);
					related_rows.filter(':visible').last().addClass('last-visible');
				});
			}
			return false;
		});
		add_details_last_visible_class();
	};

	window['add_details_last_visible_class'] = add_details_last_visible_class;

})();
