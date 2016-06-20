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

	$(window).on('beforeunload', function() {
		var values = get_form_values(formselector);
		var cache= {form_values :values};

		$.each(onbeforeunload_fns, function(index, item) {
			item(cache);
		});

		var cache_dom = document.getElementById('cache_form_values');
		cache_dom.value = JSON.stringify(cache);

	});

	var cache_register_onbeforeunload = function(fn) {
		onbeforeunload_fns.push(fn);
	};

	window['cache_register_onbeforeunload'] = cache_register_onbeforeunload;

	var cache_register_onbeforerestorevalues = function(fn) {
		onbeforerestorevalues_fns.push(fn);
	};

	window['cache_register_onbeforerestorevalues'] = cache_register_onbeforerestorevalues;

	var restore_cached_state = function() {
		var cache_dom = document.getElementById('cache_form_values');
		if (!cache_dom || !cache_dom.value) {
			return;
		}

		var cache = JSON.parse(cache_dom.value);

		$.each(onbeforerestorevalues_fns, function(index,item) {
			item(cache);
		});

		restore_form_values(formselector, cache.form_values);

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
var $ = jQuery
var init_municipality_autocomplete = function(fields, url, errmsg) {
	fields.each(function() {
		var cache = {}, self = this, my_id = this.id,
			shadow_id = my_id.replace('Web', ''), 
			shadow_el = $('#' + shadow_id),
			input_el = $(this).
				data('cm_info', {'value': this.value, 'chkid': shadow_el[0].value}).
				autocomplete({
					focus:function(event,ui) {
						return false;
					},
					source: create_caching_source_fn($,url, cache),
					minLength: 1,
                    close: function() {
                        if (!input_el.is(':focus')) {
                            on_blur_timeout();
                        }
                    }
				}).
				keypress(function (evt) {
					if (evt.keyCode == '13') {
						evt.preventDefault();
						input_el.autocomplete('close');
					}
				}),
            on_blur_timeout = function() {
                var info = input_el.data('cm_info'), value=self.value,
                    testvalue, content;
                if (!value) {
                    shadow_el[0].value = '';
                    return;
                }
                if (info && info['chkid'] && info['value'] && info['value'] === value) {
                    shadow_el[0].value = info['chkid'];
                    return;
                }
                 
                testvalue = string_ci_ai(value);
                if (cache.content) {
                    var values = $.grep(cache.content, function(value) {
                        return string_ci_ai(value['value']) === testvalue;
                    });
                    if (values.length === 1) {
                        shadow_el[0].value = values[0]['chkid'];
                        input_el.data('cm_info', values[0])
                        return
                    }
                }

                setTimeout(function() { input_el[0].focus(); }, 1);
                alert(errmsg);
            }

            input_el.blur(function() {
                if (! (input_el.autocomplete('widget')).is(':visible')) {
                    on_blur_timeout();
                }
            });
				

	});
	
};
window['init_municipality_autocomplete'] = init_municipality_autocomplete;
})();
