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


/*! Copyright (c) 2010 Brandon Aaron (http://brandonaaron.net)
 * Licensed under the MIT License (LICENSE.txt).
 *
 * Version 2.1.2
 */

(function($){

$.fn.bgiframe = ($.browser.msie && /msie 6\.0/i.test(navigator.userAgent) ? function(s) {
    s = $.extend({
        top     : 'auto', // auto == .currentStyle.borderTopWidth
        left    : 'auto', // auto == .currentStyle.borderLeftWidth
        width   : 'auto', // auto == offsetWidth
        height  : 'auto', // auto == offsetHeight
        opacity : true,
        src     : 'javascript:false;'
    }, s);
    var html = '<iframe class="bgiframe"frameborder="0"tabindex="-1"src="'+s.src+'"'+
                   'style="display:block;position:absolute;z-index:-1;'+
                       (s.opacity !== false?'filter:Alpha(Opacity=\'0\');':'')+
                       'top:'+(s.top=='auto'?'expression(((parseInt(this.parentNode.currentStyle.borderTopWidth)||0)*-1)+\'px\')':prop(s.top))+';'+
                       'left:'+(s.left=='auto'?'expression(((parseInt(this.parentNode.currentStyle.borderLeftWidth)||0)*-1)+\'px\')':prop(s.left))+';'+
                       'width:'+(s.width=='auto'?'expression(this.parentNode.offsetWidth+\'px\')':prop(s.width))+';'+
                       'height:'+(s.height=='auto'?'expression(this.parentNode.offsetHeight+\'px\')':prop(s.height))+';'+
                '"/>';
    return this.each(function() {
        if ( $(this).children('iframe.bgiframe').length === 0 )
            this.insertBefore( document.createElement(html), this.firstChild );
    });
} : function() { return this; });

// old alias
$.fn.bgIframe = $.fn.bgiframe;

function prop(n) {
    return n && n.constructor === Number ? n + 'px' : n;
}

})(jQuery);
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

(function($) {
	$.widget("ui.combobox", {
		options: {
			source:null
		},
		_create: function() {
			var self = this;
			var input = this.element;
			// only do something special if we have options
			if (this.options.source) {
				$(input).autocomplete({
						focus:function(e,ui) {
							return false;
						},
						source: self.options.source,
						delay: 0,
						minLength: 0
					})
				$("<span>")
				.insertAfter(input)
				.addClass("SmallButton DownButton")
				.css('margin-left', '1px')
				.click(function(e) {
					// close if already visible
					if (input.autocomplete("widget").is(":visible")) {
						input.autocomplete("close");
						return;
					}
					// pass empty string as value to search for, displaying all results
					input.autocomplete("search", "");
					input.focus();
				});
			}
		}
	});

})(jQuery);
		

/**
 * jQuery Validation Plugin 1.9.0
 *
 * http://bassistance.de/jquery-plugins/jquery-plugin-validation/
 * http://docs.jquery.com/Plugins/Validation
 *
 * Copyright (c) 2006 - 2011 Jörn Zaefferer
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

(function($) {

$.extend($.fn, {
	// http://docs.jquery.com/Plugins/Validation/validate
	validate: function( options ) {

		// if nothing is selected, return nothing; can't chain anyway
		if (!this.length) {
			options && options.debug && window.console && console.warn( "nothing selected, can't validate, returning nothing" );
			return;
		}

		// check if a validator for this form was already created
		var validator = $.data(this[0], 'validator');
		if ( validator ) {
			return validator;
		}

		// Add novalidate tag if HTML5.
		this.attr('novalidate', 'novalidate');

		validator = new $.validator( options, this[0] );
		$.data(this[0], 'validator', validator);

		if ( validator.settings.onsubmit ) {

			var inputsAndButtons = this.find("input, button");

			// allow suppresing validation by adding a cancel class to the submit button
			inputsAndButtons.filter(".cancel").click(function () {
				validator.cancelSubmit = true;
			});

			// when a submitHandler is used, capture the submitting button
			if (validator.settings.submitHandler) {
				inputsAndButtons.filter(":submit").click(function () {
					validator.submitButton = this;
				});
			}

			// validate the form on submit
			this.submit( function( event ) {
				if ( validator.settings.debug )
					// prevent form submit to be able to see console output
					event.preventDefault();

				function handle() {
					if ( validator.settings.submitHandler ) {
						if (validator.submitButton) {
							// insert a hidden input as a replacement for the missing submit button
							var hidden = $("<input type='hidden'/>").attr("name", validator.submitButton.name).val(validator.submitButton.value).appendTo(validator.currentForm);
						}
						validator.settings.submitHandler.call( validator, validator.currentForm );
						if (validator.submitButton) {
							// and clean up afterwards; thanks to no-block-scope, hidden can be referenced
							hidden.remove();
						}
						return false;
					}
					return true;
				}

				// prevent submit for invalid forms or custom submit handlers
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
			});
		}

		return validator;
	},
	// http://docs.jquery.com/Plugins/Validation/valid
	valid: function() {
        if ( $(this[0]).is('form')) {
            return this.validate().form();
        } else {
            var valid = true;
            var validator = $(this[0].form).validate();
            this.each(function() {
				valid &= validator.element(this);
            });
            return valid;
        }
    },
	// attributes: space seperated list of attributes to retrieve and remove
	removeAttrs: function(attributes) {
		var result = {},
			$element = this;
		$.each(attributes.split(/\s/), function(index, value) {
			result[value] = $element.attr(value);
			$element.removeAttr(value);
		});
		return result;
	},
	// http://docs.jquery.com/Plugins/Validation/rules
	rules: function(command, argument) {
		var element = this[0];

		if (command) {
			var settings = $.data(element.form, 'validator').settings;
			var staticRules = settings.rules;
			var existingRules = $.validator.staticRules(element);
			switch(command) {
			case "add":
				$.extend(existingRules, $.validator.normalizeRule(argument));
				staticRules[element.name] = existingRules;
				if (argument.messages)
					settings.messages[element.name] = $.extend( settings.messages[element.name], argument.messages );
				break;
			case "remove":
				if (!argument) {
					delete staticRules[element.name];
					return existingRules;
				}
				var filtered = {};
				$.each(argument.split(/\s/), function(index, method) {
					filtered[method] = existingRules[method];
					delete existingRules[method];
				});
				return filtered;
			}
		}

		var data = $.validator.normalizeRules(
		$.extend(
			{},
			$.validator.metadataRules(element),
			$.validator.classRules(element),
			$.validator.attributeRules(element),
			$.validator.staticRules(element)
		), element);

		// make sure required is at front
		if (data.required) {
			var param = data.required;
			delete data.required;
			data = $.extend({required: param}, data);
		}

		return data;
	}
});

// Custom selectors
$.extend($.expr[":"], {
	// http://docs.jquery.com/Plugins/Validation/blank
	blank: function(a) {return !$.trim("" + a.value);},
	// http://docs.jquery.com/Plugins/Validation/filled
	filled: function(a) {return !!$.trim("" + a.value);},
	// http://docs.jquery.com/Plugins/Validation/unchecked
	unchecked: function(a) {return !a.checked;}
});

// constructor for validator
$.validator = function( options, form ) {
	this.settings = $.extend( true, {}, $.validator.defaults, options );
	this.currentForm = form;
	this.init();
};

$.validator.format = function(source, params) {
	if ( arguments.length == 1 )
		return function() {
			var args = $.makeArray(arguments);
			args.unshift(source);
			return $.validator.format.apply( this, args );
		};
	if ( arguments.length > 2 && params.constructor != Array  ) {
		params = $.makeArray(arguments).slice(1);
	}
	if ( params.constructor != Array ) {
		params = [ params ];
	}
	$.each(params, function(i, n) {
		source = source.replace(new RegExp("\\{" + i + "\\}", "g"), n);
	});
	return source;
};

$.extend($.validator, {

	defaults: {
		messages: {},
		groups: {},
		rules: {},
		errorClass: "error",
		validClass: "valid",
		errorElement: "label",
		focusInvalid: true,
		errorContainer: $( [] ),
		errorLabelContainer: $( [] ),
		onsubmit: true,
		ignore: ":hidden",
		ignoreTitle: false,
		onfocusin: function(element, event) {
			this.lastActive = element;

			// hide error label and remove error class on focus if enabled
			if ( this.settings.focusCleanup && !this.blockFocusCleanup ) {
				this.settings.unhighlight && this.settings.unhighlight.call( this, element, this.settings.errorClass, this.settings.validClass );
				this.addWrapper(this.errorsFor(element)).hide();
			}
		},
		onfocusout: function(element, event) {
			if ( !this.checkable(element) && (element.name in this.submitted || !this.optional(element)) ) {
				this.element(element);
			}
		},
		onkeyup: function(element, event) {
			if ( element.name in this.submitted || element == this.lastElement ) {
				this.element(element);
			}
		},
		onclick: function(element, event) {
			// click on selects, radiobuttons and checkboxes
			if ( element.name in this.submitted )
				this.element(element);
			// or option elements, check parent select in that case
			else if (element.parentNode.name in this.submitted)
				this.element(element.parentNode);
		},
		highlight: function(element, errorClass, validClass) {
			if (element.type === 'radio') {
				this.findByName(element.name).addClass(errorClass).removeClass(validClass);
			} else {
				$(element).addClass(errorClass).removeClass(validClass);
			}
		},
		unhighlight: function(element, errorClass, validClass) {
			if (element.type === 'radio') {
				this.findByName(element.name).removeClass(errorClass).addClass(validClass);
			} else {
				$(element).removeClass(errorClass).addClass(validClass);
			}
		}
	},

	// http://docs.jquery.com/Plugins/Validation/Validator/setDefaults
	setDefaults: function(settings) {
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
		creditcard: "Please enter a valid credit card number.",
		equalTo: "Please enter the same value again.",
		accept: "Please enter a value with a valid extension.",
		maxlength: $.validator.format("Please enter no more than {0} characters."),
		minlength: $.validator.format("Please enter at least {0} characters."),
		rangelength: $.validator.format("Please enter a value between {0} and {1} characters long."),
		range: $.validator.format("Please enter a value between {0} and {1}."),
		max: $.validator.format("Please enter a value less than or equal to {0}."),
		min: $.validator.format("Please enter a value greater than or equal to {0}.")
	},

	autoCreateRanges: false,

	prototype: {

		init: function() {
			this.labelContainer = $(this.settings.errorLabelContainer);
			this.errorContext = this.labelContainer.length && this.labelContainer || $(this.currentForm);
			this.containers = $(this.settings.errorContainer).add( this.settings.errorLabelContainer );
			this.submitted = {};
			this.valueCache = {};
			this.pendingRequest = 0;
			this.pending = {};
			this.invalid = {};
			this.reset();

			var groups = (this.groups = {});
			$.each(this.settings.groups, function(key, value) {
				$.each(value.split(/\s/), function(index, name) {
					groups[name] = key;
				});
			});
			var rules = this.settings.rules;
			$.each(rules, function(key, value) {
				rules[key] = $.validator.normalizeRule(value);
			});

			function delegate(event) {
				var validator = $.data(this[0].form, "validator"),
					eventType = "on" + event.type.replace(/^validate/, "");
				validator.settings[eventType] && validator.settings[eventType].call(validator, this[0], event);
			}
			$(this.currentForm)
			       .validateDelegate("[type='text'], [type='password'], [type='file'], select, textarea, " +
						"[type='number'], [type='search'] ,[type='tel'], [type='url'], " +
						"[type='email'], [type='datetime'], [type='date'], [type='month'], " +
						"[type='week'], [type='time'], [type='datetime-local'], " +
						"[type='range'], [type='color'] ",
						"focusin focusout keyup", delegate)
				.validateDelegate("[type='radio'], [type='checkbox'], select, option", "click", delegate);

			if (this.settings.invalidHandler)
				$(this.currentForm).bind("invalid-form.validate", this.settings.invalidHandler);
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/form
		form: function() {
			this.checkForm();
			$.extend(this.submitted, this.errorMap);
			this.invalid = $.extend({}, this.errorMap);
			if (!this.valid())
				$(this.currentForm).triggerHandler("invalid-form", [this]);
			this.showErrors();
			return this.valid();
		},

		checkForm: function() {
			this.prepareForm();
			for ( var i = 0, elements = (this.currentElements = this.elements()); elements[i]; i++ ) {
				this.check( elements[i] );
			}
			return this.valid();
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/element
		element: function( element ) {
			element = this.validationTargetFor( this.clean( element ) );
			this.lastElement = element;
			this.prepareElement( element );
			this.currentElements = $(element);
			var result = this.check( element );
			if ( result ) {
				delete this.invalid[element.name];
			} else {
				this.invalid[element.name] = true;
			}
			if ( !this.numberOfInvalids() ) {
				// Hide error containers on last error
				this.toHide = this.toHide.add( this.containers );
			}
			this.showErrors();
			return result;
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/showErrors
		showErrors: function(errors) {
			if(errors) {
				// add items to error list and map
				$.extend( this.errorMap, errors );
				this.errorList = [];
				for ( var name in errors ) {
					this.errorList.push({
						message: errors[name],
						element: this.findByName(name)[0]
					});
				}
				// remove items from success list
				this.successList = $.grep( this.successList, function(element) {
					return !(element.name in errors);
				});
			}
			this.settings.showErrors
				? this.settings.showErrors.call( this, this.errorMap, this.errorList )
				: this.defaultShowErrors();
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/resetForm
		resetForm: function() {
			if ( $.fn.resetForm )
				$( this.currentForm ).resetForm();
			this.submitted = {};
			this.lastElement = null;
			this.prepareForm();
			this.hideErrors();
			this.elements().removeClass( this.settings.errorClass );
		},

		numberOfInvalids: function() {
			return this.objectLength(this.invalid);
		},

		objectLength: function( obj ) {
			var count = 0;
			for ( var i in obj )
				count++;
			return count;
		},

		hideErrors: function() {
			this.addWrapper( this.toHide ).hide();
		},

		valid: function() {
			return this.size() == 0;
		},

		size: function() {
			return this.errorList.length;
		},

		focusInvalid: function() {
			if( this.settings.focusInvalid ) {
				try {
					$(this.findLastActive() || this.errorList.length && this.errorList[0].element || [])
					.filter(":visible")
					.focus()
					// manually trigger focusin event; without it, focusin handler isn't called, findLastActive won't have anything to find
					.trigger("focusin");
				} catch(e) {
					// ignore IE throwing errors when focusing hidden elements
				}
			}
		},

		findLastActive: function() {
			var lastActive = this.lastActive;
			return lastActive && $.grep(this.errorList, function(n) {
				return n.element.name == lastActive.name;
			}).length == 1 && lastActive;
		},

		elements: function() {
			var validator = this,
				rulesCache = {};

			// select all valid inputs inside the form (no submit or reset buttons)
			return $(this.currentForm)
			.find("input, select, textarea")
			.not(":submit, :reset, :image, [disabled]")
			.not( this.settings.ignore )
			.filter(function() {
				!this.name && validator.settings.debug && window.console && console.error( "%o has no name assigned", this);

				// select only the first element for each name, and only those with rules specified
				if ( this.name in rulesCache || !validator.objectLength($(this).rules()) )
					return false;

				rulesCache[this.name] = true;
				return true;
			});
		},

		clean: function( selector ) {
			return $( selector )[0];
		},

		errors: function() {
			return $( this.settings.errorElement + "." + this.settings.errorClass, this.errorContext );
		},

		reset: function() {
			this.successList = [];
			this.errorList = [];
			this.errorMap = {};
			this.toShow = $([]);
			this.toHide = $([]);
			this.currentElements = $([]);
		},

		prepareForm: function() {
			this.reset();
			this.toHide = this.errors().add( this.containers );
		},

		prepareElement: function( element ) {
			this.reset();
			this.toHide = this.errorsFor(element);
		},

		check: function( element ) {
			element = this.validationTargetFor( this.clean( element ) );

			var rules = $(element).rules();
			var dependencyMismatch = false;
			for (var method in rules ) {
				var rule = { method: method, parameters: rules[method] };
				try {
					var result = $.validator.methods[method].call( this, element.value.replace(/\r/g, ""), element, rule.parameters );

					// if a method indicates that the field is optional and therefore valid,
					// don't mark it as valid when there are no other rules
					if ( result == "dependency-mismatch" ) {
						dependencyMismatch = true;
						continue;
					}
					dependencyMismatch = false;

					if ( result == "pending" ) {
						this.toHide = this.toHide.not( this.errorsFor(element) );
						return;
					}

					if( !result ) {
						this.formatAndAdd( element, rule );
						return false;
					}
				} catch(e) {
					this.settings.debug && window.console && console.log("exception occured when checking element " + element.id
						 + ", check the '" + rule.method + "' method", e);
					throw e;
				}
			}
			if (dependencyMismatch)
				return;
			if ( this.objectLength(rules) )
				this.successList.push(element);
			return true;
		},

		// return the custom message for the given element and validation method
		// specified in the element's "messages" metadata
		customMetaMessage: function(element, method) {
			if (!$.metadata)
				return;

			var meta = this.settings.meta
				? $(element).metadata()[this.settings.meta]
				: $(element).metadata();

			return meta && meta.messages && meta.messages[method];
		},

		// return the custom message for the given element name and validation method
		customMessage: function( name, method ) {
			var m = this.settings.messages[name];
			return m && (m.constructor == String
				? m
				: m[method]);
		},

		// return the first defined argument, allowing empty strings
		findDefined: function() {
			for(var i = 0; i < arguments.length; i++) {
				if (arguments[i] !== undefined)
					return arguments[i];
			}
			return undefined;
		},

		defaultMessage: function( element, method) {
			return this.findDefined(
				this.customMessage( element.name, method ),
				this.customMetaMessage( element, method ),
				// title is never undefined, so handle empty string as undefined
				!this.settings.ignoreTitle && element.title || undefined,
				$.validator.messages[method],
				"<strong>Warning: No message defined for " + element.name + "</strong>"
			);
		},

		formatAndAdd: function( element, rule ) {
			var message = this.defaultMessage( element, rule.method ),
				theregex = /\$?\{(\d+)\}/g;
			if ( typeof message == "function" ) {
				message = message.call(this, rule.parameters, element);
			} else if (theregex.test(message)) {
				message = jQuery.format(message.replace(theregex, '{$1}'), rule.parameters);
			}
			this.errorList.push({
				message: message,
				element: element
			});

			this.errorMap[element.name] = message;
			this.submitted[element.name] = message;
		},

		addWrapper: function(toToggle) {
			if ( this.settings.wrapper )
				toToggle = toToggle.add( toToggle.parent( this.settings.wrapper ) );
			return toToggle;
		},

		defaultShowErrors: function() {
			for ( var i = 0; this.errorList[i]; i++ ) {
				var error = this.errorList[i];
				this.settings.highlight && this.settings.highlight.call( this, error.element, this.settings.errorClass, this.settings.validClass );
				this.showLabel( error.element, error.message );
			}
			if( this.errorList.length ) {
				this.toShow = this.toShow.add( this.containers );
			}
			if (this.settings.success) {
				for ( var i = 0; this.successList[i]; i++ ) {
					this.showLabel( this.successList[i] );
				}
			}
			if (this.settings.unhighlight) {
				for ( var i = 0, elements = this.validElements(); elements[i]; i++ ) {
					this.settings.unhighlight.call( this, elements[i], this.settings.errorClass, this.settings.validClass );
				}
			}
			this.toHide = this.toHide.not( this.toShow );
			this.hideErrors();
			this.addWrapper( this.toShow ).show();
		},

		validElements: function() {
			return this.currentElements.not(this.invalidElements());
		},

		invalidElements: function() {
			return $(this.errorList).map(function() {
				return this.element;
			});
		},

		showLabel: function(element, message) {
			var label = this.errorsFor( element );
			if ( label.length ) {
				// refresh error/success class
				label.removeClass( this.settings.validClass ).addClass( this.settings.errorClass );

				// check if we have a generated label, replace the message then
				label.attr("generated") && label.html(message);
			} else {
				// create label
				label = $("<" + this.settings.errorElement + "/>")
					.attr({"for":  this.idOrName(element), generated: true})
					.addClass(this.settings.errorClass)
					.html(message || "");
				if ( this.settings.wrapper ) {
					// make sure the element is visible, even in IE
					// actually showing the wrapped element is handled elsewhere
					label = label.hide().show().wrap("<" + this.settings.wrapper + "/>").parent();
				}
				if ( !this.labelContainer.append(label).length )
					this.settings.errorPlacement
						? this.settings.errorPlacement(label, $(element) )
						: label.insertAfter(element);
			}
			if ( !message && this.settings.success ) {
				label.text("");
				typeof this.settings.success == "string"
					? label.addClass( this.settings.success )
					: this.settings.success( label );
			}
			this.toShow = this.toShow.add(label);
		},

		errorsFor: function(element) {
			var name = this.idOrName(element);
    		return this.errors().filter(function() {
				return $(this).attr('for') == name;
			});
		},

		idOrName: function(element) {
			return this.groups[element.name] || (this.checkable(element) ? element.name : element.id || element.name);
		},

		validationTargetFor: function(element) {
			// if radio/checkbox, validate first element in group instead
			if (this.checkable(element)) {
				element = this.findByName( element.name ).not(this.settings.ignore)[0];
			}
			return element;
		},

		checkable: function( element ) {
			return /radio|checkbox/i.test(element.type);
		},

		findByName: function( name ) {
			// select by name and filter by form for performance over form.find("[name=...]")
			var form = this.currentForm;
			return $(document.getElementsByName(name)).map(function(index, element) {
				return element.form == form && element.name == name && element  || null;
			});
		},

		getLength: function(value, element) {
			switch( element.nodeName.toLowerCase() ) {
			case 'select':
				return $("option:selected", element).length;
			case 'input':
				if( this.checkable( element) )
					return this.findByName(element.name).filter(':checked').length;
			}
			return value.length;
		},

		depend: function(param, element) {
			return this.dependTypes[typeof param]
				? this.dependTypes[typeof param](param, element)
				: true;
		},

		dependTypes: {
			"boolean": function(param, element) {
				return param;
			},
			"string": function(param, element) {
				return !!$(param, element.form).length;
			},
			"function": function(param, element) {
				return param(element);
			}
		},

		optional: function(element) {
			return !$.validator.methods.required.call(this, $.trim(element.value), element) && "dependency-mismatch";
		},

		startRequest: function(element) {
			if (!this.pending[element.name]) {
				this.pendingRequest++;
				this.pending[element.name] = true;
			}
		},

		stopRequest: function(element, valid) {
			this.pendingRequest--;
			// sometimes synchronization fails, make sure pendingRequest is never < 0
			if (this.pendingRequest < 0)
				this.pendingRequest = 0;
			delete this.pending[element.name];
			if ( valid && this.pendingRequest == 0 && this.formSubmitted && this.form() ) {
				$(this.currentForm).submit();
				this.formSubmitted = false;
			} else if (!valid && this.pendingRequest == 0 && this.formSubmitted) {
				$(this.currentForm).triggerHandler("invalid-form", [this]);
				this.formSubmitted = false;
			}
		},

		previousValue: function(element) {
			return $.data(element, "previousValue") || $.data(element, "previousValue", {
				old: null,
				valid: true,
				message: this.defaultMessage( element, "remote" )
			});
		}

	},

	classRuleSettings: {
		required: {required: true},
		email: {email: true},
		url: {url: true},
		date: {date: true},
		dateISO: {dateISO: true},
		dateDE: {dateDE: true},
		number: {number: true},
		numberDE: {numberDE: true},
		digits: {digits: true},
		creditcard: {creditcard: true}
	},

	addClassRules: function(className, rules) {
		className.constructor == String ?
			this.classRuleSettings[className] = rules :
			$.extend(this.classRuleSettings, className);
	},

	classRules: function(element) {
		var rules = {};
		var classes = $(element).attr('class');
		classes && $.each(classes.split(' '), function() {
			if (this in $.validator.classRuleSettings) {
				$.extend(rules, $.validator.classRuleSettings[this]);
			}
		});
		return rules;
	},

	attributeRules: function(element) {
		var rules = {};
		var $element = $(element);

		for (var method in $.validator.methods) {
			var value;
			// If .prop exists (jQuery >= 1.6), use it to get true/false for required
			if (method === 'required' && typeof $.fn.prop === 'function') {
				value = $element.prop(method);
			} else {
				value = $element.attr(method);
			}
			if (value) {
				rules[method] = value;
			} else if ($element[0].getAttribute("type") === method) {
				rules[method] = true;
			}
		}

		// maxlength may be returned as -1, 2147483647 (IE) and 524288 (safari) for text inputs
		if (rules.maxlength && /-1|2147483647|524288/.test(rules.maxlength)) {
			delete rules.maxlength;
		}

		return rules;
	},

	metadataRules: function(element) {
		if (!$.metadata) return {};

		var meta = $.data(element.form, 'validator').settings.meta;
		return meta ?
			$(element).metadata()[meta] :
			$(element).metadata();
	},

	staticRules: function(element) {
		var rules = {};
		var validator = $.data(element.form, 'validator');
		if (validator.settings.rules) {
			rules = $.validator.normalizeRule(validator.settings.rules[element.name]) || {};
		}
		return rules;
	},

	normalizeRules: function(rules, element) {
		// handle dependency check
		$.each(rules, function(prop, val) {
			// ignore rule when param is explicitly false, eg. required:false
			if (val === false) {
				delete rules[prop];
				return;
			}
			if (val.param || val.depends) {
				var keepRule = true;
				switch (typeof val.depends) {
					case "string":
						keepRule = !!$(val.depends, element.form).length;
						break;
					case "function":
						keepRule = val.depends.call(element, element);
						break;
				}
				if (keepRule) {
					rules[prop] = val.param !== undefined ? val.param : true;
				} else {
					delete rules[prop];
				}
			}
		});

		// evaluate parameters
		$.each(rules, function(rule, parameter) {
			rules[rule] = $.isFunction(parameter) ? parameter(element) : parameter;
		});

		// clean number parameters
		$.each(['minlength', 'maxlength', 'min', 'max'], function() {
			if (rules[this]) {
				rules[this] = Number(rules[this]);
			}
		});
		$.each(['rangelength', 'range'], function() {
			if (rules[this]) {
				rules[this] = [Number(rules[this][0]), Number(rules[this][1])];
			}
		});

		if ($.validator.autoCreateRanges) {
			// auto-create ranges
			if (rules.min && rules.max) {
				rules.range = [rules.min, rules.max];
				delete rules.min;
				delete rules.max;
			}
			if (rules.minlength && rules.maxlength) {
				rules.rangelength = [rules.minlength, rules.maxlength];
				delete rules.minlength;
				delete rules.maxlength;
			}
		}

		// To support custom messages in metadata ignore rule methods titled "messages"
		if (rules.messages) {
			delete rules.messages;
		}

		return rules;
	},

	// Converts a simple string to a {string: true} rule, e.g., "required" to {required:true}
	normalizeRule: function(data) {
		if( typeof data == "string" ) {
			var transformed = {};
			$.each(data.split(/\s/), function() {
				transformed[this] = true;
			});
			data = transformed;
		}
		return data;
	},

	// http://docs.jquery.com/Plugins/Validation/Validator/addMethod
	addMethod: function(name, method, message) {
		$.validator.methods[name] = method;
		$.validator.messages[name] = message != undefined ? message : $.validator.messages[name];
		if (method.length < 3) {
			$.validator.addClassRules(name, $.validator.normalizeRule(name));
		}
	},

	methods: {

		// http://docs.jquery.com/Plugins/Validation/Methods/required
		required: function(value, element, param) {
			// check if dependency is met
			if ( !this.depend(param, element) )
				return "dependency-mismatch";
			switch( element.nodeName.toLowerCase() ) {
			case 'select':
				// could be an array for select-multiple or a string, both are fine this way
				var val = $(element).val();
				return val && val.length > 0;
			case 'input':
				if ( this.checkable(element) )
					return this.getLength(value, element) > 0;
			default:
				return $.trim(value).length > 0;
			}
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/remote
		remote: function(value, element, param) {
			if ( this.optional(element) )
				return "dependency-mismatch";

			var previous = this.previousValue(element);
			if (!this.settings.messages[element.name] )
				this.settings.messages[element.name] = {};
			previous.originalMessage = this.settings.messages[element.name].remote;
			this.settings.messages[element.name].remote = previous.message;

			param = typeof param == "string" && {url:param} || param;

			if ( this.pending[element.name] ) {
				return "pending";
			}
			if ( previous.old === value ) {
				return previous.valid;
			}

			previous.old = value;
			var validator = this;
			this.startRequest(element);
			var data = {};
			data[element.name] = value;
			$.ajax($.extend(true, {
				url: param,
				mode: "abort",
				port: "validate" + element.name,
				dataType: "json",
				data: data,
				success: function(response) {
					validator.settings.messages[element.name].remote = previous.originalMessage;
					var valid = response === true;
					if ( valid ) {
						var submitted = validator.formSubmitted;
						validator.prepareElement(element);
						validator.formSubmitted = submitted;
						validator.successList.push(element);
						validator.showErrors();
					} else {
						var errors = {};
						var message = response || validator.defaultMessage( element, "remote" );
						errors[element.name] = previous.message = $.isFunction(message) ? message(value) : message;
						validator.showErrors(errors);
					}
					previous.valid = valid;
					validator.stopRequest(element, valid);
				}
			}, param));
			return "pending";
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/minlength
		minlength: function(value, element, param) {
			return this.optional(element) || this.getLength($.trim(value), element) >= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/maxlength
		maxlength: function(value, element, param) {
			return this.optional(element) || this.getLength($.trim(value), element) <= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/rangelength
		rangelength: function(value, element, param) {
			var length = this.getLength($.trim(value), element);
			return this.optional(element) || ( length >= param[0] && length <= param[1] );
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/min
		min: function( value, element, param ) {
			return this.optional(element) || value >= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/max
		max: function( value, element, param ) {
			return this.optional(element) || value <= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/range
		range: function( value, element, param ) {
			return this.optional(element) || ( value >= param[0] && value <= param[1] );
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/email
		email: function(value, element) {
			// contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
			return this.optional(element) || /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/url
		url: function(value, element) {
			// contributed by Scott Gonzalez: http://projects.scottsplayground.com/iri/
			return this.optional(element) || /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/date
		date: function(value, element) {
			return this.optional(element) || !/Invalid|NaN/.test(new Date(value));
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/dateISO
		dateISO: function(value, element) {
			return this.optional(element) || /^\d{4}[\/-]\d{1,2}[\/-]\d{1,2}$/.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/number
		number: function(value, element) {
			return this.optional(element) || /^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$/.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/digits
		digits: function(value, element) {
			return this.optional(element) || /^\d+$/.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/creditcard
		// based on http://en.wikipedia.org/wiki/Luhn
		creditcard: function(value, element) {
			if ( this.optional(element) )
				return "dependency-mismatch";
			// accept only spaces, digits and dashes
			if (/[^0-9 -]+/.test(value))
				return false;
			var nCheck = 0,
				nDigit = 0,
				bEven = false;

			value = value.replace(/\D/g, "");

			for (var n = value.length - 1; n >= 0; n--) {
				var cDigit = value.charAt(n);
				var nDigit = parseInt(cDigit, 10);
				if (bEven) {
					if ((nDigit *= 2) > 9)
						nDigit -= 9;
				}
				nCheck += nDigit;
				bEven = !bEven;
			}

			return (nCheck % 10) == 0;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/accept
		accept: function(value, element, param) {
			param = typeof param == "string" ? param.replace(/,/g, '|') : "png|jpe?g|gif";
			return this.optional(element) || value.match(new RegExp(".(" + param + ")$", "i"));
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/equalTo
		equalTo: function(value, element, param) {
			// bind to the blur event of the target in order to revalidate whenever the target field is updated
			// TODO find a way to bind the event just once, avoiding the unbind-rebind overhead
			var target = $(param).unbind(".validate-equalTo").bind("blur.validate-equalTo", function() {
				$(element).valid();
			});
			return value == target.val();
		}

	}

});

// deprecated, use $.validator.format instead
$.format = $.validator.format;

})(jQuery);

// ajax mode: abort
// usage: $.ajax({ mode: "abort"[, port: "uniqueport"]});
// if mode:"abort" is used, the previous request on that port (port can be undefined) is aborted via XMLHttpRequest.abort()
;(function($) {
	var pendingRequests = {};
	// Use a prefilter if available (1.5+)
	if ( $.ajaxPrefilter ) {
		$.ajaxPrefilter(function(settings, _, xhr) {
			var port = settings.port;
			if (settings.mode == "abort") {
				if ( pendingRequests[port] ) {
					pendingRequests[port].abort();
				}
				pendingRequests[port] = xhr;
			}
		});
	} else {
		// Proxy ajax
		var ajax = $.ajax;
		$.ajax = function(settings) {
			var mode = ( "mode" in settings ? settings : $.ajaxSettings ).mode,
				port = ( "port" in settings ? settings : $.ajaxSettings ).port;
			if (mode == "abort") {
				if ( pendingRequests[port] ) {
					pendingRequests[port].abort();
				}
				return (pendingRequests[port] = ajax.apply(this, arguments));
			}
			return ajax.apply(this, arguments);
		};
	}
})(jQuery);

// provides cross-browser focusin and focusout events
// IE has native support, in other browsers, use event caputuring (neither bubbles)

// provides delegate(type: String, delegate: Selector, handler: Callback) plugin for easier event delegation
// handler is only called when $(event.target).is(delegate), in the scope of the jquery-object for event.target
;(function($) {
	// only implement if not provided by jQuery core (since 1.4)
	// TODO verify if jQuery 1.4's implementation is compatible with older jQuery special-event APIs
	if (!jQuery.event.special.focusin && !jQuery.event.special.focusout && document.addEventListener) {
		$.each({
			focus: 'focusin',
			blur: 'focusout'
		}, function( original, fix ){
			$.event.special[fix] = {
				setup:function() {
					this.addEventListener( original, handler, true );
				},
				teardown:function() {
					this.removeEventListener( original, handler, true );
				},
				handler: function(e) {
					arguments[0] = $.event.fix(e);
					arguments[0].type = fix;
					return $.event.handle.apply(this, arguments);
				}
			};
			function handler(e) {
				e = $.event.fix(e);
				e.type = fix;
				return $.event.handle.call(this, e);
			}
		});
	};
	$.extend($.fn, {
		validateDelegate: function(delegate, type, handler) {
			return this.bind(type, function(event) {
				var target = $(event.target);
				if (target.is(delegate)) {
					return handler.apply(target, arguments);
				}
			});
		}
	});
})(jQuery);
/*!
 * Globalize
 *
 * http://github.com/jquery/globalize
 *
 * Copyright Software Freedom Conservancy, Inc.
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 */

(function( window, undefined ) {

var Globalize,
	// private variables
	regexHex,
	regexInfinity,
	regexParseFloat,
	regexTrim,
	// private JavaScript utility functions
	arrayIndexOf,
	endsWith,
	extend,
	isArray,
	isFunction,
	isObject,
	startsWith,
	trim,
	truncate,
	zeroPad,
	// private Globalization utility functions
	appendPreOrPostMatch,
	expandFormat,
	formatDate,
	formatNumber,
	getTokenRegExp,
	getEra,
	getEraYear,
	parseExact,
	parseNegativePattern;

// Global variable (Globalize) or CommonJS module (globalize)
Globalize = function( cultureSelector ) {
	return new Globalize.prototype.init( cultureSelector );
};

if ( typeof require !== "undefined" &&
	typeof exports !== "undefined" &&
	typeof module !== "undefined" ) {
	// Assume CommonJS
	module.exports = Globalize;
} else {
	// Export as global variable
	window.Globalize = Globalize;
}

Globalize.cultures = {};

Globalize.prototype = {
	constructor: Globalize,
	init: function( cultureSelector ) {
		this.cultures = Globalize.cultures;
		this.cultureSelector = cultureSelector;

		return this;
	}
};
Globalize.prototype.init.prototype = Globalize.prototype;

// 1. When defining a culture, all fields are required except the ones stated as optional.
// 2. Each culture should have a ".calendars" object with at least one calendar named "standard"
//    which serves as the default calendar in use by that culture.
// 3. Each culture should have a ".calendar" object which is the current calendar being used,
//    it may be dynamically changed at any time to one of the calendars in ".calendars".
Globalize.cultures[ "default" ] = {
	// A unique name for the culture in the form <language code>-<country/region code>
	name: "en",
	// the name of the culture in the english language
	englishName: "English",
	// the name of the culture in its own language
	nativeName: "English",
	// whether the culture uses right-to-left text
	isRTL: false,
	// "language" is used for so-called "specific" cultures.
	// For example, the culture "es-CL" means "Spanish, in Chili".
	// It represents the Spanish-speaking culture as it is in Chili,
	// which might have different formatting rules or even translations
	// than Spanish in Spain. A "neutral" culture is one that is not
	// specific to a region. For example, the culture "es" is the generic
	// Spanish culture, which may be a more generalized version of the language
	// that may or may not be what a specific culture expects.
	// For a specific culture like "es-CL", the "language" field refers to the
	// neutral, generic culture information for the language it is using.
	// This is not always a simple matter of the string before the dash.
	// For example, the "zh-Hans" culture is netural (Simplified Chinese).
	// And the "zh-SG" culture is Simplified Chinese in Singapore, whose lanugage
	// field is "zh-CHS", not "zh".
	// This field should be used to navigate from a specific culture to it's
	// more general, neutral culture. If a culture is already as general as it
	// can get, the language may refer to itself.
	language: "en",
	// numberFormat defines general number formatting rules, like the digits in
	// each grouping, the group separator, and how negative numbers are displayed.
	numberFormat: {
		// [negativePattern]
		// Note, numberFormat.pattern has no "positivePattern" unlike percent and currency,
		// but is still defined as an array for consistency with them.
		//   negativePattern: one of "(n)|-n|- n|n-|n -"
		pattern: [ "-n" ],
		// number of decimal places normally shown
		decimals: 2,
		// string that separates number groups, as in 1,000,000
		",": ",",
		// string that separates a number from the fractional portion, as in 1.99
		".": ".",
		// array of numbers indicating the size of each number group.
		// TODO: more detailed description and example
		groupSizes: [ 3 ],
		// symbol used for positive numbers
		"+": "+",
		// symbol used for negative numbers
		"-": "-",
		// symbol used for NaN (Not-A-Number)
		"NaN": "NaN",
		// symbol used for Negative Infinity
		negativeInfinity: "-Infinity",
		// symbol used for Positive Infinity
		positiveInfinity: "Infinity",
		percent: {
			// [negativePattern, positivePattern]
			//   negativePattern: one of "-n %|-n%|-%n|%-n|%n-|n-%|n%-|-% n|n %-|% n-|% -n|n- %"
			//   positivePattern: one of "n %|n%|%n|% n"
			pattern: [ "-n %", "n %" ],
			// number of decimal places normally shown
			decimals: 2,
			// array of numbers indicating the size of each number group.
			// TODO: more detailed description and example
			groupSizes: [ 3 ],
			// string that separates number groups, as in 1,000,000
			",": ",",
			// string that separates a number from the fractional portion, as in 1.99
			".": ".",
			// symbol used to represent a percentage
			symbol: "%"
		},
		currency: {
			// [negativePattern, positivePattern]
			//   negativePattern: one of "($n)|-$n|$-n|$n-|(n$)|-n$|n-$|n$-|-n $|-$ n|n $-|$ n-|$ -n|n- $|($ n)|(n $)"
			//   positivePattern: one of "$n|n$|$ n|n $"
			pattern: [ "($n)", "$n" ],
			// number of decimal places normally shown
			decimals: 2,
			// array of numbers indicating the size of each number group.
			// TODO: more detailed description and example
			groupSizes: [ 3 ],
			// string that separates number groups, as in 1,000,000
			",": ",",
			// string that separates a number from the fractional portion, as in 1.99
			".": ".",
			// symbol used to represent currency
			symbol: "$"
		}
	},
	// calendars defines all the possible calendars used by this culture.
	// There should be at least one defined with name "standard", and is the default
	// calendar used by the culture.
	// A calendar contains information about how dates are formatted, information about
	// the calendar's eras, a standard set of the date formats,
	// translations for day and month names, and if the calendar is not based on the Gregorian
	// calendar, conversion functions to and from the Gregorian calendar.
	calendars: {
		standard: {
			// name that identifies the type of calendar this is
			name: "Gregorian_USEnglish",
			// separator of parts of a date (e.g. "/" in 11/05/1955)
			"/": "/",
			// separator of parts of a time (e.g. ":" in 05:44 PM)
			":": ":",
			// the first day of the week (0 = Sunday, 1 = Monday, etc)
			firstDay: 0,
			days: {
				// full day names
				names: [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ],
				// abbreviated day names
				namesAbbr: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ],
				// shortest day names
				namesShort: [ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" ]
			},
			months: {
				// full month names (13 months for lunar calendards -- 13th month should be "" if not lunar)
				names: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "" ],
				// abbreviated month names
				namesAbbr: [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "" ]
			},
			// AM and PM designators in one of these forms:
			// The usual view, and the upper and lower case versions
			//   [ standard, lowercase, uppercase ]
			// The culture does not use AM or PM (likely all standard date formats use 24 hour time)
			//   null
			AM: [ "AM", "am", "AM" ],
			PM: [ "PM", "pm", "PM" ],
			eras: [
				// eras in reverse chronological order.
				// name: the name of the era in this culture (e.g. A.D., C.E.)
				// start: when the era starts in ticks (gregorian, gmt), null if it is the earliest supported era.
				// offset: offset in years from gregorian calendar
				{
					"name": "A.D.",
					"start": null,
					"offset": 0
				}
			],
			// when a two digit year is given, it will never be parsed as a four digit
			// year greater than this year (in the appropriate era for the culture)
			// Set it as a full year (e.g. 2029) or use an offset format starting from
			// the current year: "+19" would correspond to 2029 if the current year 2010.
			twoDigitYearMax: 2029,
			// set of predefined date and time patterns used by the culture
			// these represent the format someone in this culture would expect
			// to see given the portions of the date that are shown.
			patterns: {
				// short date pattern
				d: "M/d/yyyy",
				// long date pattern
				D: "dddd, MMMM dd, yyyy",
				// short time pattern
				t: "h:mm tt",
				// long time pattern
				T: "h:mm:ss tt",
				// long date, short time pattern
				f: "dddd, MMMM dd, yyyy h:mm tt",
				// long date, long time pattern
				F: "dddd, MMMM dd, yyyy h:mm:ss tt",
				// month/day pattern
				M: "MMMM dd",
				// month/year pattern
				Y: "yyyy MMMM",
				// S is a sortable format that does not vary by culture
				S: "yyyy\u0027-\u0027MM\u0027-\u0027dd\u0027T\u0027HH\u0027:\u0027mm\u0027:\u0027ss"
			}
			// optional fields for each calendar:
			/*
			monthsGenitive:
				Same as months but used when the day preceeds the month.
				Omit if the culture has no genitive distinction in month names.
				For an explaination of genitive months, see http://blogs.msdn.com/michkap/archive/2004/12/25/332259.aspx
			convert:
				Allows for the support of non-gregorian based calendars. This convert object is used to
				to convert a date to and from a gregorian calendar date to handle parsing and formatting.
				The two functions:
					fromGregorian( date )
						Given the date as a parameter, return an array with parts [ year, month, day ]
						corresponding to the non-gregorian based year, month, and day for the calendar.
					toGregorian( year, month, day )
						Given the non-gregorian year, month, and day, return a new Date() object
						set to the corresponding date in the gregorian calendar.
			*/
		}
	},
	// For localized strings
	messages: {}
};

Globalize.cultures[ "default" ].calendar = Globalize.cultures[ "default" ].calendars.standard;

Globalize.cultures.en = Globalize.cultures[ "default" ];

Globalize.cultureSelector = "en";

//
// private variables
//

regexHex = /^0x[a-f0-9]+$/i;
regexInfinity = /^[+\-]?infinity$/i;
regexParseFloat = /^[+\-]?\d*\.?\d*(e[+\-]?\d+)?$/;
regexTrim = /^\s+|\s+$/g;

//
// private JavaScript utility functions
//

arrayIndexOf = function( array, item ) {
	if ( array.indexOf ) {
		return array.indexOf( item );
	}
	for ( var i = 0, length = array.length; i < length; i++ ) {
		if ( array[i] === item ) {
			return i;
		}
	}
	return -1;
};

endsWith = function( value, pattern ) {
	return value.substr( value.length - pattern.length ) === pattern;
};

extend = function() {
	var options, name, src, copy, copyIsArray, clone,
		target = arguments[0] || {},
		i = 1,
		length = arguments.length,
		deep = false;

	// Handle a deep copy situation
	if ( typeof target === "boolean" ) {
		deep = target;
		target = arguments[1] || {};
		// skip the boolean and the target
		i = 2;
	}

	// Handle case when target is a string or something (possible in deep copy)
	if ( typeof target !== "object" && !isFunction(target) ) {
		target = {};
	}

	for ( ; i < length; i++ ) {
		// Only deal with non-null/undefined values
		if ( (options = arguments[ i ]) != null ) {
			// Extend the base object
			for ( name in options ) {
				src = target[ name ];
				copy = options[ name ];

				// Prevent never-ending loop
				if ( target === copy ) {
					continue;
				}

				// Recurse if we're merging plain objects or arrays
				if ( deep && copy && ( isObject(copy) || (copyIsArray = isArray(copy)) ) ) {
					if ( copyIsArray ) {
						copyIsArray = false;
						clone = src && isArray(src) ? src : [];

					} else {
						clone = src && isObject(src) ? src : {};
					}

					// Never move original objects, clone them
					target[ name ] = extend( deep, clone, copy );

				// Don't bring in undefined values
				} else if ( copy !== undefined ) {
					target[ name ] = copy;
				}
			}
		}
	}

	// Return the modified object
	return target;
};

isArray = Array.isArray || function( obj ) {
	return Object.prototype.toString.call( obj ) === "[object Array]";
};

isFunction = function( obj ) {
	return Object.prototype.toString.call( obj ) === "[object Function]";
};

isObject = function( obj ) {
	return Object.prototype.toString.call( obj ) === "[object Object]";
};

startsWith = function( value, pattern ) {
	return value.indexOf( pattern ) === 0;
};

trim = function( value ) {
	return ( value + "" ).replace( regexTrim, "" );
};

truncate = function( value ) {
	if ( isNaN( value ) ) {
		return NaN;
	}
	return Math[ value < 0 ? "ceil" : "floor" ]( value );
};

zeroPad = function( str, count, left ) {
	var l;
	for ( l = str.length; l < count; l += 1 ) {
		str = ( left ? ("0" + str) : (str + "0") );
	}
	return str;
};

//
// private Globalization utility functions
//

appendPreOrPostMatch = function( preMatch, strings ) {
	// appends pre- and post- token match strings while removing escaped characters.
	// Returns a single quote count which is used to determine if the token occurs
	// in a string literal.
	var quoteCount = 0,
		escaped = false;
	for ( var i = 0, il = preMatch.length; i < il; i++ ) {
		var c = preMatch.charAt( i );
		switch ( c ) {
			case "\'":
				if ( escaped ) {
					strings.push( "\'" );
				}
				else {
					quoteCount++;
				}
				escaped = false;
				break;
			case "\\":
				if ( escaped ) {
					strings.push( "\\" );
				}
				escaped = !escaped;
				break;
			default:
				strings.push( c );
				escaped = false;
				break;
		}
	}
	return quoteCount;
};

expandFormat = function( cal, format ) {
	// expands unspecified or single character date formats into the full pattern.
	format = format || "F";
	var pattern,
		patterns = cal.patterns,
		len = format.length;
	if ( len === 1 ) {
		pattern = patterns[ format ];
		if ( !pattern ) {
			throw "Invalid date format string \'" + format + "\'.";
		}
		format = pattern;
	}
	else if ( len === 2 && format.charAt(0) === "%" ) {
		// %X escape format -- intended as a custom format string that is only one character, not a built-in format.
		format = format.charAt( 1 );
	}
	return format;
};

formatDate = function( value, format, culture ) {
	var cal = culture.calendar,
		convert = cal.convert,
		ret;

	if ( !format || !format.length || format === "i" ) {
		if ( culture && culture.name.length ) {
			if ( convert ) {
				// non-gregorian calendar, so we cannot use built-in toLocaleString()
				ret = formatDate( value, cal.patterns.F, culture );
			}
			else {
				var eraDate = new Date( value.getTime() ),
					era = getEra( value, cal.eras );
				eraDate.setFullYear( getEraYear(value, cal, era) );
				ret = eraDate.toLocaleString();
			}
		}
		else {
			ret = value.toString();
		}
		return ret;
	}

	var eras = cal.eras,
		sortable = format === "s";
	format = expandFormat( cal, format );

	// Start with an empty string
	ret = [];
	var hour,
		zeros = [ "0", "00", "000" ],
		foundDay,
		checkedDay,
		dayPartRegExp = /([^d]|^)(d|dd)([^d]|$)/g,
		quoteCount = 0,
		tokenRegExp = getTokenRegExp(),
		converted;

	function padZeros( num, c ) {
		var r, s = num + "";
		if ( c > 1 && s.length < c ) {
			r = ( zeros[c - 2] + s);
			return r.substr( r.length - c, c );
		}
		else {
			r = s;
		}
		return r;
	}

	function hasDay() {
		if ( foundDay || checkedDay ) {
			return foundDay;
		}
		foundDay = dayPartRegExp.test( format );
		checkedDay = true;
		return foundDay;
	}

	function getPart( date, part ) {
		if ( converted ) {
			return converted[ part ];
		}
		switch ( part ) {
			case 0:
				return date.getFullYear();
			case 1:
				return date.getMonth();
			case 2:
				return date.getDate();
			default:
				throw "Invalid part value " + part;
		}
	}

	if ( !sortable && convert ) {
		converted = convert.fromGregorian( value );
	}

	for ( ; ; ) {
		// Save the current index
		var index = tokenRegExp.lastIndex,
			// Look for the next pattern
			ar = tokenRegExp.exec( format );

		// Append the text before the pattern (or the end of the string if not found)
		var preMatch = format.slice( index, ar ? ar.index : format.length );
		quoteCount += appendPreOrPostMatch( preMatch, ret );

		if ( !ar ) {
			break;
		}

		// do not replace any matches that occur inside a string literal.
		if ( quoteCount % 2 ) {
			ret.push( ar[0] );
			continue;
		}

		var current = ar[ 0 ],
			clength = current.length;

		switch ( current ) {
			case "ddd":
				//Day of the week, as a three-letter abbreviation
			case "dddd":
				// Day of the week, using the full name
				var names = ( clength === 3 ) ? cal.days.namesAbbr : cal.days.names;
				ret.push( names[value.getDay()] );
				break;
			case "d":
				// Day of month, without leading zero for single-digit days
			case "dd":
				// Day of month, with leading zero for single-digit days
				foundDay = true;
				ret.push(
					padZeros( getPart(value, 2), clength )
				);
				break;
			case "MMM":
				// Month, as a three-letter abbreviation
			case "MMMM":
				// Month, using the full name
				var part = getPart( value, 1 );
				ret.push(
					( cal.monthsGenitive && hasDay() ) ?
					( cal.monthsGenitive[ clength === 3 ? "namesAbbr" : "names" ][ part ] ) :
					( cal.months[ clength === 3 ? "namesAbbr" : "names" ][ part ] )
				);
				break;
			case "M":
				// Month, as digits, with no leading zero for single-digit months
			case "MM":
				// Month, as digits, with leading zero for single-digit months
				ret.push(
					padZeros( getPart(value, 1) + 1, clength )
				);
				break;
			case "y":
				// Year, as two digits, but with no leading zero for years less than 10
			case "yy":
				// Year, as two digits, with leading zero for years less than 10
			case "yyyy":
				// Year represented by four full digits
				part = converted ? converted[ 0 ] : getEraYear( value, cal, getEra(value, eras), sortable );
				if ( clength < 4 ) {
					part = part % 100;
				}
				ret.push(
					padZeros( part, clength )
				);
				break;
			case "h":
				// Hours with no leading zero for single-digit hours, using 12-hour clock
			case "hh":
				// Hours with leading zero for single-digit hours, using 12-hour clock
				hour = value.getHours() % 12;
				if ( hour === 0 ) hour = 12;
				ret.push(
					padZeros( hour, clength )
				);
				break;
			case "H":
				// Hours with no leading zero for single-digit hours, using 24-hour clock
			case "HH":
				// Hours with leading zero for single-digit hours, using 24-hour clock
				ret.push(
					padZeros( value.getHours(), clength )
				);
				break;
			case "m":
				// Minutes with no leading zero for single-digit minutes
			case "mm":
				// Minutes with leading zero for single-digit minutes
				ret.push(
					padZeros( value.getMinutes(), clength )
				);
				break;
			case "s":
				// Seconds with no leading zero for single-digit seconds
			case "ss":
				// Seconds with leading zero for single-digit seconds
				ret.push(
					padZeros( value.getSeconds(), clength )
				);
				break;
			case "t":
				// One character am/pm indicator ("a" or "p")
			case "tt":
				// Multicharacter am/pm indicator
				part = value.getHours() < 12 ? ( cal.AM ? cal.AM[0] : " " ) : ( cal.PM ? cal.PM[0] : " " );
				ret.push( clength === 1 ? part.charAt(0) : part );
				break;
			case "f":
				// Deciseconds
			case "ff":
				// Centiseconds
			case "fff":
				// Milliseconds
				ret.push(
					padZeros( value.getMilliseconds(), 3 ).substr( 0, clength )
				);
				break;
			case "z":
				// Time zone offset, no leading zero
			case "zz":
				// Time zone offset with leading zero
				hour = value.getTimezoneOffset() / 60;
				ret.push(
					( hour <= 0 ? "+" : "-" ) + padZeros( Math.floor(Math.abs(hour)), clength )
				);
				break;
			case "zzz":
				// Time zone offset with leading zero
				hour = value.getTimezoneOffset() / 60;
				ret.push(
					( hour <= 0 ? "+" : "-" ) + padZeros( Math.floor(Math.abs(hour)), 2 ) +
					// Hard coded ":" separator, rather than using cal.TimeSeparator
					// Repeated here for consistency, plus ":" was already assumed in date parsing.
					":" + padZeros( Math.abs(value.getTimezoneOffset() % 60), 2 )
				);
				break;
			case "g":
			case "gg":
				if ( cal.eras ) {
					ret.push(
						cal.eras[ getEra(value, eras) ].name
					);
				}
				break;
		case "/":
			ret.push( cal["/"] );
			break;
		default:
			throw "Invalid date format pattern \'" + current + "\'.";
		}
	}
	return ret.join( "" );
};

// formatNumber
(function() {
	var expandNumber;

	expandNumber = function( number, precision, formatInfo ) {
		var groupSizes = formatInfo.groupSizes,
			curSize = groupSizes[ 0 ],
			curGroupIndex = 1,
			factor = Math.pow( 10, precision ),
			rounded = Math.round( number * factor ) / factor;

		if ( !isFinite(rounded) ) {
			rounded = number;
		}
		number = rounded;

		var numberString = number+"",
			right = "",
			split = numberString.split( /e/i ),
			exponent = split.length > 1 ? parseInt( split[1], 10 ) : 0;
		numberString = split[ 0 ];
		split = numberString.split( "." );
		numberString = split[ 0 ];
		right = split.length > 1 ? split[ 1 ] : "";

		var l;
		if ( exponent > 0 ) {
			right = zeroPad( right, exponent, false );
			numberString += right.slice( 0, exponent );
			right = right.substr( exponent );
		}
		else if ( exponent < 0 ) {
			exponent = -exponent;
			numberString = zeroPad( numberString, exponent + 1, true );
			right = numberString.slice( -exponent, numberString.length ) + right;
			numberString = numberString.slice( 0, -exponent );
		}

		if ( precision > 0 ) {
			right = formatInfo[ "." ] +
				( (right.length > precision) ? right.slice(0, precision) : zeroPad(right, precision) );
		}
		else {
			right = "";
		}

		var stringIndex = numberString.length - 1,
			sep = formatInfo[ "," ],
			ret = "";

		while ( stringIndex >= 0 ) {
			if ( curSize === 0 || curSize > stringIndex ) {
				return numberString.slice( 0, stringIndex + 1 ) + ( ret.length ? (sep + ret + right) : right );
			}
			ret = numberString.slice( stringIndex - curSize + 1, stringIndex + 1 ) + ( ret.length ? (sep + ret) : "" );

			stringIndex -= curSize;

			if ( curGroupIndex < groupSizes.length ) {
				curSize = groupSizes[ curGroupIndex ];
				curGroupIndex++;
			}
		}

		return numberString.slice( 0, stringIndex + 1 ) + sep + ret + right;
	};

	formatNumber = function( value, format, culture ) {
		if ( !isFinite(value) ) {
			if ( value === Infinity ) {
				return culture.numberFormat.positiveInfinity;
			}
			if ( value === -Infinity ) {
				return culture.numberFormat.negativeInfinity;
			}
			return culture.numberFormat[ "NaN" ];
		}
		if ( !format || format === "i" ) {
			return culture.name.length ? value.toLocaleString() : value.toString();
		}
		format = format || "D";

		var nf = culture.numberFormat,
			number = Math.abs( value ),
			precision = -1,
			pattern;
		if ( format.length > 1 ) precision = parseInt( format.slice(1), 10 );

		var current = format.charAt( 0 ).toUpperCase(),
			formatInfo;

		switch ( current ) {
			case "D":
				pattern = "n";
				number = truncate( number );
				if ( precision !== -1 ) {
					number = zeroPad( "" + number, precision, true );
				}
				if ( value < 0 ) number = "-" + number;
				break;
			case "N":
				formatInfo = nf;
				/* falls through */
			case "C":
				formatInfo = formatInfo || nf.currency;
				/* falls through */
			case "P":
				formatInfo = formatInfo || nf.percent;
				pattern = value < 0 ? formatInfo.pattern[ 0 ] : ( formatInfo.pattern[1] || "n" );
				if ( precision === -1 ) precision = formatInfo.decimals;
				number = expandNumber( number * (current === "P" ? 100 : 1), precision, formatInfo );
				break;
			default:
				throw "Bad number format specifier: " + current;
		}

		var patternParts = /n|\$|-|%/g,
			ret = "";
		for ( ; ; ) {
			var index = patternParts.lastIndex,
				ar = patternParts.exec( pattern );

			ret += pattern.slice( index, ar ? ar.index : pattern.length );

			if ( !ar ) {
				break;
			}

			switch ( ar[0] ) {
				case "n":
					ret += number;
					break;
				case "$":
					ret += nf.currency.symbol;
					break;
				case "-":
					// don't make 0 negative
					if ( /[1-9]/.test(number) ) {
						ret += nf[ "-" ];
					}
					break;
				case "%":
					ret += nf.percent.symbol;
					break;
			}
		}

		return ret;
	};

}());

getTokenRegExp = function() {
	// regular expression for matching date and time tokens in format strings.
	return (/\/|dddd|ddd|dd|d|MMMM|MMM|MM|M|yyyy|yy|y|hh|h|HH|H|mm|m|ss|s|tt|t|fff|ff|f|zzz|zz|z|gg|g/g);
};

getEra = function( date, eras ) {
	if ( !eras ) return 0;
	var start, ticks = date.getTime();
	for ( var i = 0, l = eras.length; i < l; i++ ) {
		start = eras[ i ].start;
		if ( start === null || ticks >= start ) {
			return i;
		}
	}
	return 0;
};

getEraYear = function( date, cal, era, sortable ) {
	var year = date.getFullYear();
	if ( !sortable && cal.eras ) {
		// convert normal gregorian year to era-shifted gregorian
		// year by subtracting the era offset
		year -= cal.eras[ era ].offset;
	}
	return year;
};

// parseExact
(function() {
	var expandYear,
		getDayIndex,
		getMonthIndex,
		getParseRegExp,
		outOfRange,
		toUpper,
		toUpperArray;

	expandYear = function( cal, year ) {
		// expands 2-digit year into 4 digits.
		if ( year < 100 ) {
			var now = new Date(),
				era = getEra( now ),
				curr = getEraYear( now, cal, era ),
				twoDigitYearMax = cal.twoDigitYearMax;
			twoDigitYearMax = typeof twoDigitYearMax === "string" ? new Date().getFullYear() % 100 + parseInt( twoDigitYearMax, 10 ) : twoDigitYearMax;
			year += curr - ( curr % 100 );
			if ( year > twoDigitYearMax ) {
				year -= 100;
			}
		}
		return year;
	};

	getDayIndex = function	( cal, value, abbr ) {
		var ret,
			days = cal.days,
			upperDays = cal._upperDays;
		if ( !upperDays ) {
			cal._upperDays = upperDays = [
				toUpperArray( days.names ),
				toUpperArray( days.namesAbbr ),
				toUpperArray( days.namesShort )
			];
		}
		value = toUpper( value );
		if ( abbr ) {
			ret = arrayIndexOf( upperDays[1], value );
			if ( ret === -1 ) {
				ret = arrayIndexOf( upperDays[2], value );
			}
		}
		else {
			ret = arrayIndexOf( upperDays[0], value );
		}
		return ret;
	};

	getMonthIndex = function( cal, value, abbr ) {
		var months = cal.months,
			monthsGen = cal.monthsGenitive || cal.months,
			upperMonths = cal._upperMonths,
			upperMonthsGen = cal._upperMonthsGen;
		if ( !upperMonths ) {
			cal._upperMonths = upperMonths = [
				toUpperArray( months.names ),
				toUpperArray( months.namesAbbr )
			];
			cal._upperMonthsGen = upperMonthsGen = [
				toUpperArray( monthsGen.names ),
				toUpperArray( monthsGen.namesAbbr )
			];
		}
		value = toUpper( value );
		var i = arrayIndexOf( abbr ? upperMonths[1] : upperMonths[0], value );
		if ( i < 0 ) {
			i = arrayIndexOf( abbr ? upperMonthsGen[1] : upperMonthsGen[0], value );
		}
		return i;
	};

	getParseRegExp = function( cal, format ) {
		// converts a format string into a regular expression with groups that
		// can be used to extract date fields from a date string.
		// check for a cached parse regex.
		var re = cal._parseRegExp;
		if ( !re ) {
			cal._parseRegExp = re = {};
		}
		else {
			var reFormat = re[ format ];
			if ( reFormat ) {
				return reFormat;
			}
		}

		// expand single digit formats, then escape regular expression characters.
		var expFormat = expandFormat( cal, format ).replace( /([\^\$\.\*\+\?\|\[\]\(\)\{\}])/g, "\\\\$1" ),
			regexp = [ "^" ],
			groups = [],
			index = 0,
			quoteCount = 0,
			tokenRegExp = getTokenRegExp(),
			match;

		// iterate through each date token found.
		while ( (match = tokenRegExp.exec(expFormat)) !== null ) {
			var preMatch = expFormat.slice( index, match.index );
			index = tokenRegExp.lastIndex;

			// don't replace any matches that occur inside a string literal.
			quoteCount += appendPreOrPostMatch( preMatch, regexp );
			if ( quoteCount % 2 ) {
				regexp.push( match[0] );
				continue;
			}

			// add a regex group for the token.
			var m = match[ 0 ],
				len = m.length,
				add;
			switch ( m ) {
				case "dddd": case "ddd":
				case "MMMM": case "MMM":
				case "gg": case "g":
					add = "(\\D+)";
					break;
				case "tt": case "t":
					add = "(\\D*)";
					break;
				case "yyyy":
				case "fff":
				case "ff":
				case "f":
					add = "(\\d{" + len + "})";
					break;
				case "dd": case "d":
				case "MM": case "M":
				case "yy": case "y":
				case "HH": case "H":
				case "hh": case "h":
				case "mm": case "m":
				case "ss": case "s":
					add = "(\\d\\d?)";
					break;
				case "zzz":
					add = "([+-]?\\d\\d?:\\d{2})";
					break;
				case "zz": case "z":
					add = "([+-]?\\d\\d?)";
					break;
				case "/":
					add = "(\\/)";
					break;
				default:
					throw "Invalid date format pattern \'" + m + "\'.";
			}
			if ( add ) {
				regexp.push( add );
			}
			groups.push( match[0] );
		}
		appendPreOrPostMatch( expFormat.slice(index), regexp );
		regexp.push( "$" );

		// allow whitespace to differ when matching formats.
		var regexpStr = regexp.join( "" ).replace( /\s+/g, "\\s+" ),
			parseRegExp = { "regExp": regexpStr, "groups": groups };

		// cache the regex for this format.
		return re[ format ] = parseRegExp;
	};

	outOfRange = function( value, low, high ) {
		return value < low || value > high;
	};

	toUpper = function( value ) {
		// "he-IL" has non-breaking space in weekday names.
		return value.split( "\u00A0" ).join( " " ).toUpperCase();
	};

	toUpperArray = function( arr ) {
		var results = [];
		for ( var i = 0, l = arr.length; i < l; i++ ) {
			results[ i ] = toUpper( arr[i] );
		}
		return results;
	};

	parseExact = function( value, format, culture ) {
		// try to parse the date string by matching against the format string
		// while using the specified culture for date field names.
		value = trim( value );
		var cal = culture.calendar,
			// convert date formats into regular expressions with groupings.
			// use the regexp to determine the input format and extract the date fields.
			parseInfo = getParseRegExp( cal, format ),
			match = new RegExp( parseInfo.regExp ).exec( value );
		if ( match === null ) {
			return null;
		}
		// found a date format that matches the input.
		var groups = parseInfo.groups,
			era = null, year = null, month = null, date = null, weekDay = null,
			hour = 0, hourOffset, min = 0, sec = 0, msec = 0, tzMinOffset = null,
			pmHour = false;
		// iterate the format groups to extract and set the date fields.
		for ( var j = 0, jl = groups.length; j < jl; j++ ) {
			var matchGroup = match[ j + 1 ];
			if ( matchGroup ) {
				var current = groups[ j ],
					clength = current.length,
					matchInt = parseInt( matchGroup, 10 );
				switch ( current ) {
					case "dd": case "d":
						// Day of month.
						date = matchInt;
						// check that date is generally in valid range, also checking overflow below.
						if ( outOfRange(date, 1, 31) ) return null;
						break;
					case "MMM": case "MMMM":
						month = getMonthIndex( cal, matchGroup, clength === 3 );
						if ( outOfRange(month, 0, 11) ) return null;
						break;
					case "M": case "MM":
						// Month.
						month = matchInt - 1;
						if ( outOfRange(month, 0, 11) ) return null;
						break;
					case "y": case "yy":
					case "yyyy":
						year = clength < 4 ? expandYear( cal, matchInt ) : matchInt;
						if ( outOfRange(year, 0, 9999) ) return null;
						break;
					case "h": case "hh":
						// Hours (12-hour clock).
						hour = matchInt;
						if ( hour === 12 ) hour = 0;
						if ( outOfRange(hour, 0, 11) ) return null;
						break;
					case "H": case "HH":
						// Hours (24-hour clock).
						hour = matchInt;
						if ( outOfRange(hour, 0, 23) ) return null;
						break;
					case "m": case "mm":
						// Minutes.
						min = matchInt;
						if ( outOfRange(min, 0, 59) ) return null;
						break;
					case "s": case "ss":
						// Seconds.
						sec = matchInt;
						if ( outOfRange(sec, 0, 59) ) return null;
						break;
					case "tt": case "t":
						// AM/PM designator.
						// see if it is standard, upper, or lower case PM. If not, ensure it is at least one of
						// the AM tokens. If not, fail the parse for this format.
						pmHour = cal.PM && ( matchGroup === cal.PM[0] || matchGroup === cal.PM[1] || matchGroup === cal.PM[2] );
						if (
							!pmHour && (
								!cal.AM || ( matchGroup !== cal.AM[0] && matchGroup !== cal.AM[1] && matchGroup !== cal.AM[2] )
							)
						) return null;
						break;
					case "f":
						// Deciseconds.
					case "ff":
						// Centiseconds.
					case "fff":
						// Milliseconds.
						msec = matchInt * Math.pow( 10, 3 - clength );
						if ( outOfRange(msec, 0, 999) ) return null;
						break;
					case "ddd":
						// Day of week.
					case "dddd":
						// Day of week.
						weekDay = getDayIndex( cal, matchGroup, clength === 3 );
						if ( outOfRange(weekDay, 0, 6) ) return null;
						break;
					case "zzz":
						// Time zone offset in +/- hours:min.
						var offsets = matchGroup.split( /:/ );
						if ( offsets.length !== 2 ) return null;
						hourOffset = parseInt( offsets[0], 10 );
						if ( outOfRange(hourOffset, -12, 13) ) return null;
						var minOffset = parseInt( offsets[1], 10 );
						if ( outOfRange(minOffset, 0, 59) ) return null;
						tzMinOffset = ( hourOffset * 60 ) + ( startsWith(matchGroup, "-") ? -minOffset : minOffset );
						break;
					case "z": case "zz":
						// Time zone offset in +/- hours.
						hourOffset = matchInt;
						if ( outOfRange(hourOffset, -12, 13) ) return null;
						tzMinOffset = hourOffset * 60;
						break;
					case "g": case "gg":
						var eraName = matchGroup;
						if ( !eraName || !cal.eras ) return null;
						eraName = trim( eraName.toLowerCase() );
						for ( var i = 0, l = cal.eras.length; i < l; i++ ) {
							if ( eraName === cal.eras[i].name.toLowerCase() ) {
								era = i;
								break;
							}
						}
						// could not find an era with that name
						if ( era === null ) return null;
						break;
				}
			}
		}
		var result = new Date(), defaultYear, convert = cal.convert;
		defaultYear = convert ? convert.fromGregorian( result )[ 0 ] : result.getFullYear();
		if ( year === null ) {
			year = defaultYear;
		}
		else if ( cal.eras ) {
			// year must be shifted to normal gregorian year
			// but not if year was not specified, its already normal gregorian
			// per the main if clause above.
			year += cal.eras[( era || 0 )].offset;
		}
		// set default day and month to 1 and January, so if unspecified, these are the defaults
		// instead of the current day/month.
		if ( month === null ) {
			month = 0;
		}
		if ( date === null ) {
			date = 1;
		}
		// now have year, month, and date, but in the culture's calendar.
		// convert to gregorian if necessary
		if ( convert ) {
			result = convert.toGregorian( year, month, date );
			// conversion failed, must be an invalid match
			if ( result === null ) return null;
		}
		else {
			// have to set year, month and date together to avoid overflow based on current date.
			result.setFullYear( year, month, date );
			// check to see if date overflowed for specified month (only checked 1-31 above).
			if ( result.getDate() !== date ) return null;
			// invalid day of week.
			if ( weekDay !== null && result.getDay() !== weekDay ) {
				return null;
			}
		}
		// if pm designator token was found make sure the hours fit the 24-hour clock.
		if ( pmHour && hour < 12 ) {
			hour += 12;
		}
		result.setHours( hour, min, sec, msec );
		if ( tzMinOffset !== null ) {
			// adjust timezone to utc before applying local offset.
			var adjustedMin = result.getMinutes() - ( tzMinOffset + result.getTimezoneOffset() );
			// Safari limits hours and minutes to the range of -127 to 127.  We need to use setHours
			// to ensure both these fields will not exceed this range.	adjustedMin will range
			// somewhere between -1440 and 1500, so we only need to split this into hours.
			result.setHours( result.getHours() + parseInt(adjustedMin / 60, 10), adjustedMin % 60 );
		}
		return result;
	};
}());

parseNegativePattern = function( value, nf, negativePattern ) {
	var neg = nf[ "-" ],
		pos = nf[ "+" ],
		ret;
	switch ( negativePattern ) {
		case "n -":
			neg = " " + neg;
			pos = " " + pos;
			/* falls through */
		case "n-":
			if ( endsWith(value, neg) ) {
				ret = [ "-", value.substr(0, value.length - neg.length) ];
			}
			else if ( endsWith(value, pos) ) {
				ret = [ "+", value.substr(0, value.length - pos.length) ];
			}
			break;
		case "- n":
			neg += " ";
			pos += " ";
			/* falls through */
		case "-n":
			if ( startsWith(value, neg) ) {
				ret = [ "-", value.substr(neg.length) ];
			}
			else if ( startsWith(value, pos) ) {
				ret = [ "+", value.substr(pos.length) ];
			}
			break;
		case "(n)":
			if ( startsWith(value, "(") && endsWith(value, ")") ) {
				ret = [ "-", value.substr(1, value.length - 2) ];
			}
			break;
	}
	return ret || [ "", value ];
};

//
// public instance functions
//

Globalize.prototype.findClosestCulture = function( cultureSelector ) {
	return Globalize.findClosestCulture.call( this, cultureSelector );
};

Globalize.prototype.format = function( value, format, cultureSelector ) {
	return Globalize.format.call( this, value, format, cultureSelector );
};

Globalize.prototype.localize = function( key, cultureSelector ) {
	return Globalize.localize.call( this, key, cultureSelector );
};

Globalize.prototype.parseInt = function( value, radix, cultureSelector ) {
	return Globalize.parseInt.call( this, value, radix, cultureSelector );
};

Globalize.prototype.parseFloat = function( value, radix, cultureSelector ) {
	return Globalize.parseFloat.call( this, value, radix, cultureSelector );
};

Globalize.prototype.culture = function( cultureSelector ) {
	return Globalize.culture.call( this, cultureSelector );
};

//
// public singleton functions
//

Globalize.addCultureInfo = function( cultureName, baseCultureName, info ) {

	var base = {},
		isNew = false;

	if ( typeof cultureName !== "string" ) {
		// cultureName argument is optional string. If not specified, assume info is first
		// and only argument. Specified info deep-extends current culture.
		info = cultureName;
		cultureName = this.culture().name;
		base = this.cultures[ cultureName ];
	} else if ( typeof baseCultureName !== "string" ) {
		// baseCultureName argument is optional string. If not specified, assume info is second
		// argument. Specified info deep-extends specified culture.
		// If specified culture does not exist, create by deep-extending default
		info = baseCultureName;
		isNew = ( this.cultures[ cultureName ] == null );
		base = this.cultures[ cultureName ] || this.cultures[ "default" ];
	} else {
		// cultureName and baseCultureName specified. Assume a new culture is being created
		// by deep-extending an specified base culture
		isNew = true;
		base = this.cultures[ baseCultureName ];
	}

	this.cultures[ cultureName ] = extend(true, {},
		base,
		info
	);
	// Make the standard calendar the current culture if it's a new culture
	if ( isNew ) {
		this.cultures[ cultureName ].calendar = this.cultures[ cultureName ].calendars.standard;
	}
};

Globalize.findClosestCulture = function( name ) {
	var match;
	if ( !name ) {
		return this.findClosestCulture( this.cultureSelector ) || this.cultures[ "default" ];
	}
	if ( typeof name === "string" ) {
		name = name.split( "," );
	}
	if ( isArray(name) ) {
		var lang,
			cultures = this.cultures,
			list = name,
			i, l = list.length,
			prioritized = [];
		for ( i = 0; i < l; i++ ) {
			name = trim( list[i] );
			var pri, parts = name.split( ";" );
			lang = trim( parts[0] );
			if ( parts.length === 1 ) {
				pri = 1;
			}
			else {
				name = trim( parts[1] );
				if ( name.indexOf("q=") === 0 ) {
					name = name.substr( 2 );
					pri = parseFloat( name );
					pri = isNaN( pri ) ? 0 : pri;
				}
				else {
					pri = 1;
				}
			}
			prioritized.push({ lang: lang, pri: pri });
		}
		prioritized.sort(function( a, b ) {
			if ( a.pri < b.pri ) {
				return 1;
			} else if ( a.pri > b.pri ) {
				return -1;
			}
			return 0;
		});
		// exact match
		for ( i = 0; i < l; i++ ) {
			lang = prioritized[ i ].lang;
			match = cultures[ lang ];
			if ( match ) {
				return match;
			}
		}

		// neutral language match
		for ( i = 0; i < l; i++ ) {
			lang = prioritized[ i ].lang;
			do {
				var index = lang.lastIndexOf( "-" );
				if ( index === -1 ) {
					break;
				}
				// strip off the last part. e.g. en-US => en
				lang = lang.substr( 0, index );
				match = cultures[ lang ];
				if ( match ) {
					return match;
				}
			}
			while ( 1 );
		}

		// last resort: match first culture using that language
		for ( i = 0; i < l; i++ ) {
			lang = prioritized[ i ].lang;
			for ( var cultureKey in cultures ) {
				var culture = cultures[ cultureKey ];
				if ( culture.language == lang ) {
					return culture;
				}
			}
		}
	}
	else if ( typeof name === "object" ) {
		return name;
	}
	return match || null;
};

Globalize.format = function( value, format, cultureSelector ) {
	var culture = this.findClosestCulture( cultureSelector );
	if ( value instanceof Date ) {
		value = formatDate( value, format, culture );
	}
	else if ( typeof value === "number" ) {
		value = formatNumber( value, format, culture );
	}
	return value;
};

Globalize.localize = function( key, cultureSelector ) {
	return this.findClosestCulture( cultureSelector ).messages[ key ] ||
		this.cultures[ "default" ].messages[ key ];
};

Globalize.parseDate = function( value, formats, culture ) {
	culture = this.findClosestCulture( culture );

	var date, prop, patterns;
	if ( formats ) {
		if ( typeof formats === "string" ) {
			formats = [ formats ];
		}
		if ( formats.length ) {
			for ( var i = 0, l = formats.length; i < l; i++ ) {
				var format = formats[ i ];
				if ( format ) {
					date = parseExact( value, format, culture );
					if ( date ) {
						break;
					}
				}
			}
		}
	} else {
		patterns = culture.calendar.patterns;
		for ( prop in patterns ) {
			date = parseExact( value, patterns[prop], culture );
			if ( date ) {
				break;
			}
		}
	}

	return date || null;
};

Globalize.parseInt = function( value, radix, cultureSelector ) {
	return truncate( Globalize.parseFloat(value, radix, cultureSelector) );
};

Globalize.parseFloat = function( value, radix, cultureSelector ) {
	// radix argument is optional
	if ( typeof radix !== "number" ) {
		cultureSelector = radix;
		radix = 10;
	}

	var culture = this.findClosestCulture( cultureSelector );
	var ret = NaN,
		nf = culture.numberFormat;

	if ( value.indexOf(culture.numberFormat.currency.symbol) > -1 ) {
		// remove currency symbol
		value = value.replace( culture.numberFormat.currency.symbol, "" );
		// replace decimal seperator
		value = value.replace( culture.numberFormat.currency["."], culture.numberFormat["."] );
	}

	// trim leading and trailing whitespace
	value = trim( value );

	// allow infinity or hexidecimal
	if ( regexInfinity.test(value) ) {
		ret = parseFloat( value );
	}
	else if ( !radix && regexHex.test(value) ) {
		ret = parseInt( value, 16 );
	}
	else {

		// determine sign and number
		var signInfo = parseNegativePattern( value, nf, nf.pattern[0] ),
			sign = signInfo[ 0 ],
			num = signInfo[ 1 ];

		// #44 - try parsing as "(n)"
		if ( sign === "" && nf.pattern[0] !== "(n)" ) {
			signInfo = parseNegativePattern( value, nf, "(n)" );
			sign = signInfo[ 0 ];
			num = signInfo[ 1 ];
		}

		// try parsing as "-n"
		if ( sign === "" && nf.pattern[0] !== "-n" ) {
			signInfo = parseNegativePattern( value, nf, "-n" );
			sign = signInfo[ 0 ];
			num = signInfo[ 1 ];
		}

		sign = sign || "+";

		// determine exponent and number
		var exponent,
			intAndFraction,
			exponentPos = num.indexOf( "e" );
		if ( exponentPos < 0 ) exponentPos = num.indexOf( "E" );
		if ( exponentPos < 0 ) {
			intAndFraction = num;
			exponent = null;
		}
		else {
			intAndFraction = num.substr( 0, exponentPos );
			exponent = num.substr( exponentPos + 1 );
		}
		// determine decimal position
		var integer,
			fraction,
			decSep = nf[ "." ],
			decimalPos = intAndFraction.indexOf( decSep );
		if ( decimalPos < 0 ) {
			integer = intAndFraction;
			fraction = null;
		}
		else {
			integer = intAndFraction.substr( 0, decimalPos );
			fraction = intAndFraction.substr( decimalPos + decSep.length );
		}
		// handle groups (e.g. 1,000,000)
		var groupSep = nf[ "," ];
		integer = integer.split( groupSep ).join( "" );
		var altGroupSep = groupSep.replace( /\u00A0/g, " " );
		if ( groupSep !== altGroupSep ) {
			integer = integer.split( altGroupSep ).join( "" );
		}
		// build a natively parsable number string
		var p = sign + integer;
		if ( fraction !== null ) {
			p += "." + fraction;
		}
		if ( exponent !== null ) {
			// exponent itself may have a number patternd
			var expSignInfo = parseNegativePattern( exponent, nf, "-n" );
			p += "e" + ( expSignInfo[0] || "+" ) + expSignInfo[ 1 ];
		}
		if ( regexParseFloat.test(p) ) {
			ret = parseFloat( p );
		}
	}
	return ret;
};

Globalize.culture = function( cultureSelector ) {
	// setter
	if ( typeof cultureSelector !== "undefined" ) {
		this.cultureSelector = cultureSelector;
	}
	// getter
	return this.findClosestCulture( cultureSelector ) || this.cultures[ "default" ];
};

}( this ));
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
	/*global google:true Globalize:true pageconstants:true */
	var map_canvas = null;
	var map = null;
	var default_center = [59.888937,-101.601562];
	var geocoder = null;
	var current_overlay = null;
	var was_blank_map = true;
	var last_geocode_address = null;

	// different
	var current_overlay_drag_evt = null;

	var map_default = function() {
		map.setCenter(new google.maps.LatLng(default_center[0],default_center[1]), 2);
	};

	var clear_overlay = function() {
		if (current_overlay) {
			current_overlay.setMap(null);
		}
		current_overlay = null;

		if (current_overlay_drag_evt) {
			google.maps.event.removeListener(current_overlay_drag_evt);
			current_overlay_drag_evt = null;
		}
	};


	var store_coordinates = function(lat, lng) {
		document.getElementById('LATITUDE').value = Globalize.format(lat, 'n6');
		document.getElementById('LONGITUDE').value = Globalize.format(lng, 'n6');
	};

	var map_lat_lng = function(lat, lng) {
		var point = new google.maps.LatLng(lat, lng);
		if (was_blank_map) {
			map.setZoom(14);
		}
		map.setCenter(point);
		was_blank_map = false;
		var marker = new google.maps.Marker({
			position: point,
			map: map,
			clickable:false,
			draggable: draggable
		});
		
		clear_overlay();

		current_overlay = marker;

		if (draggable) {
			var evt = google.maps.event.addListener(marker, "dragend", marker_drag_end);
			current_overlay_drag_evt = evt;
		}
	};
	var marker_drag_end = function() {
		$('#GEOCODE_TYPE_SITE_REFRESH, #GEOCODE_TYPE_INTERSECTION_REFRESH').addClass('NotVisible');
		$('#GEOCODE_TYPE_MANUAL').prop('checked', true);
		var point = this.getPosition();
		store_coordinates(point.lat(), point.lng());
	};

	var store_and_map_point = function(place) {
		if (place) {
			last_geocode_address = pending_geocode_address;
			store_coordinates(place.lat(), place.lng());
			map_lat_lng(place.lat(), place.lng());
		}
	};

	var get_response_message = function(status) {
		var msg = null
		switch (status) {
			case google.maps.GeocoderStatus.ZERO_RESULTS:
				msg = pageconstants.txt_geocode_unknown_address;
				break;
			case google.maps.GeocoderStatus.REQUEST_DENIED:
				msg = pageconstants.txt_geocode_map_key_fail;
				break;
			case google.maps.GeocoderStatus.OVER_QUERY_LIMIT:
				msg = pageconstants.txt_geocode_too_many_queries;
				break;

			default:
				msg = pageconstants.txt_geocode_unknown_error + status;
				break;

		}
		return msg;
	};
	window['get_response_message'] = get_response_message;

	var handle_geocode = function(callback) {
		return function(results, status) {
			if (status !== google.maps.GeocoderStatus.OK) {
				callback(null, status);
			} else {
				callback(results[0].geometry.location, status);
			}
			
		};
	};
	window['handle_geocode'] = handle_geocode;

	var start_geocode = function(address, callback) {
		pending_geocode_address = address;
		if ( !address ) {
			clear_overlay();
			store_coordinates("", "");
			return;
		}
		geocoder.geocode({address: address}, callback);
	};
	
	var create_geocoder = function() {
		if (!geocoder) {
			geocoder = new google.maps.Geocoder();
		}
	};

	var create_map = function() {
		var mapOptions = {
			zoom: 13,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		map_canvas = document.getElementById("map_canvas")
		map = new google.maps.Map(map_canvas, mapOptions);
		map_default();

		create_geocoder();


		var lat = $('#LATITUDE')[0].value, lng = $('#LONGITUDE')[0].value;
		if (lat && lng) {
			map_lat_lng(Globalize.parseFloat(lat), Globalize.parseFloat(lng));
		}
	};


	var maps_loaded_callbacks = [], maps_loaded_done = false;
	

	window['maps_loaded'] = function() {
		maps_loaded_done = true;
		$.each(maps_loaded_callbacks, function(idx, fn) {
			fn();
		});
		maps_loaded_callbacks = [];
	};

	window['add_maps_loaded_callback'] = function(fn) {
		if (maps_loaded_done) {
			fn();
		} else {
			maps_loaded_callbacks.push(fn);
		}
	};
	window['initialize_maps'] = function(culture, key_arg, loaded_fn, add_places) {
		if (!window['cioc_map_script_added']) {
			window['cioc_map_script_added'] = true
			Globalize.culture(culture);
			var places = ''
			if (add_places) {
				places = '&libraries=places';
			}
			$.getScript('//maps.googleapis.com/maps/api/js?v=3&' + key_arg + '&sensor=false&callback=maps_loaded&language=' + culture + places);
		}
		add_maps_loaded_callback(loaded_fn);
	};
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


	var trim_string = function(sInString) {
	  sInString = sInString.replace( /^\s+/g, "" );// strip leading
	  return sInString.replace( /\s+$/g, "" );// strip trailing
	};
	var entryform_handle_geocode = function(callback, skip_postal) {
		return handle_geocode(function (place, status) {
			if (place) {
				if (skip_postal) {
					$('#geocode_no_postal_code').show();
				}
				callback(place)
			} else if (status == google.maps.GeocoderStatus.ZERO_RESULTS && !skip_postal && document.getElementById('GEOCODE_TYPE_SITE').checked) {
				geocode_address(callback, true);
			} else {
				alert(get_response_message(status));
				callback(null);
			}
		})
	}

	var get_address_to_geocode = function(skip_postal) {
		var form = document.getElementById('EntryForm');
		var address_parts = [];

		if (!form.SITE_STREET_NUMBER) {
			return null;
		}

		var val = [form.SITE_STREET_NUMBER.value, form.SITE_STREET.value, 
						form.SITE_STREET_TYPE.value, form.SITE_STREET_DIR.value].join(' ');
		val = trim_string(val);
		if (val) {
			address_parts.push(val);
		}

		var address_fields = ['SITE_CITY', 'SITE_PROVINCE']
		if (!skip_postal) {
			address_fields.push('SITE_POSTAL_CODE');
		}
		for (var i = 0; i < address_fields.length; i++) {
			var val = form[address_fields[i]].value;
			if ( val ) {
				address_parts.push(val);
			}
		}

		val = form.SITE_COUNTRY.value;
		if (val) {
			address_parts.push(val);
		} else { 
			address_parts.push('Canada');
		}

		var address = address_parts.join(', ');

		if (! address || address == 'Canada') {
			return null;
		}

		return address;
	}

	var get_intersection_to_geocode = function() {
		var form = document.EntryForm;
		var address_parts = [];

		if ( !form.INTERSECTION && !form.INTERSECTION.value ) {
			return null;
		}
		
		var address_fields = ['INTERSECTION', 'SITE_CITY', 'SITE_PROVINCE']
		for (var i = 0; i < address_fields.length; i++) {
			var val = form[address_fields[i]].value;
			if ( val ) {
				address_parts.push(val);
			}
		}

		val = form.SITE_COUNTRY.value;
		if (val) {
			address_parts.push(val);
		} else { 
			address_parts.push('Canada');
		}

		return address_parts.join(', ');
		

	}

	var pending_geocode_address = null;
	var entryform_start_geocode = function(address, callback, skip_postal) {
		pending_geocode_address = address;
		start_geocode(address, entryform_handle_geocode(callback, skip_postal));
		if (! address ) {
			callback(null);
			return;
		}
		$('#geocode_no_postal_code').hide();
	};

	var geocode_address = function(callback, skip_postal) {
		var address = get_address_to_geocode(skip_postal);
		entryform_start_geocode(address, callback, skip_postal);
	}

	var geocode_intersection = function(callback) {
		var address = get_intersection_to_geocode();
		entryform_start_geocode(address, callback);
	}

	var handle_geocode_entryform_feedback = function(lat, lng) {
		if (typeof(lat) != 'undefined' && lat !== null && 
				typeof(lng) != 'undefined' && lng !== null) {
			last_geocode_address = pending_geocode_address;
			store_and_map_point(google.maps.LatLng(Globalize.parseFloat(lat), Globalize.parseFloat(lng)));
		}
	}
	window['handle_geocode_entryform_feedback'] = handle_geocode_entryform_feedback;

	var verify_geocode = function(place) {
		store_and_map_point(place);
	}

	var clear_map = function() {
		clear_overlay();
		map_default();
		was_blank_map = true;
		$('#geocode_no_postal_code').hide();
	}


	var do_geocode_type_manual = function(skip_geocode_address) {
		set_lat_lng_readonly(false);
		$('#GEOCODE_TYPE_SITE_REFRESH,#GEOCODE_TYPE_INTERSECTION_REFRESH').hide();
		if (!current_overlay && !skip_geocode_address) {
			geocode_address(function(place) {
				if (place) {
					store_and_map_point(place);
				} else {
					was_blank_map = false;
					var center = map.getCenter()
					center = center.toUrlValue().split(',');
					store_coordinates.apply(null,center);
					map_lat_lng.apply(null,center);
					last_geocode_address = null;
					pending_geocode_address = null;
				}

			});
		} 
	}
	window['do_geocode_type_manual'] = do_geocode_type_manual;

	var set_lat_lng_readonly = function(readonly) {
		var map_refresh_area = document.getElementById('map_refresh_ui_area');
		if (map_refresh_area) {
			document.getElementById('LONGITUDE').readOnly = readonly;
			document.getElementById('LATITUDE').readOnly = readonly;
			if (readonly) {
				$(map_refresh_area).hide();
			} else {
				$(map_refresh_area).show();
			}
		}
	}
	window['entryform_maps_loaded'] = function() {
		draggable = true;
		create_map();

			var geocode_type_intersection_refresh = $('#GEOCODE_TYPE_INTERSECTION_REFRESH'),
				geocode_type_site_refresh = $('#GEOCODE_TYPE_SITE_REFRESH'),
				geocode_type_site = $('#GEOCODE_TYPE_SITE').click(function() {
					geocode_type_intersection_refresh.hide();
					geocode_type_site_refresh.show();
					set_lat_lng_readonly(true);
					geocode_address(store_and_map_point);
				}),
				geocode_type_intersection = $('#GEOCODE_TYPE_INTERSECTION').click( function() {
					geocode_type_intersection_refresh.show();
					geocode_type_site_refresh.hide();
					set_lat_lng_readonly(true);
					geocode_intersection(store_and_map_point);
				});
			$('#GEOCODE_TYPE_MANUAL').click(function() { 
				do_geocode_type_manual(false); 
			});

			$('#GEOCODE_TYPE_BLANK').click( function () {
				$('#GEOCODE_TYPE_SITE_REFRESH,#GEOCODE_TYPE_INTERSECTION_REFRESH').hide();
				set_lat_lng_readonly(true);
				clear_map(); 
				store_coordinates('', '');
				pending_geocode_address = null;
				last_geocode_address = null;
			});
			geocode_type_site_refresh.click( function () { 
				geocode_address(store_and_map_point); 
			});

			geocode_type_intersection_refresh.click( function () { 
				geocode_intersection(store_and_map_point); 
			});

			// Check address and geocode
			var form = document.EntryForm;

			var map_refresh_button = document.getElementById('map_refresh');
			if (map_refresh_button) {
				$(map_refresh_button).click(function() {
					map_lat_lng(Globalize.parseFloat(form.LATITUDE.value), Globalize.parseFloat(form.LONGITUDE.value));
				});
			}



			if (!form.SITE_STREET_NUMBER) {
				form.GEOCODE_TYPE_SITE.disabled = true;
				geocode_type_site_refresh.hide();
			} else if ( document.getElementById('GEOCODE_TYPE_SITE').checked ) {
				geocode_address(verify_geocode);
				geocode_type_site_refresh.show();
			}

			if (!form.INTERSECTION) {
				form.GEOCODE_TYPE_INTERSECTION.disabled = true;
				geocode_type_site_refresh.hide();
			} else if (document.getElementById('GEOCODE_TYPE_INTERSECTION').checked ) {
				geocode_intersection(verify_geocode);
				geocode_type_intersection_refresh.show();
			}

			set_lat_lng_readonly(!form.GEOCODE_TYPE_MANUAL.checked);

			$(form).submit(function (e) {
				var check_address = null;
				var check_msg = null;
				if ( document.getElementById('GEOCODE_TYPE_SITE').checked) {
					check_address = get_address_to_geocode();
					check_msg = pageconstants.txt_geocode_address_changed;
				} else if (document.getElementById('GEOCODE_TYPE_INTERSECTION' ).checked ) {
					check_address = get_intersection_to_geocode();
					check_msg = pageconstants.txt_geocode_intersection_change;
				}

				if (check_msg && check_address != last_geocode_address) {
					if ( ! confirm(check_msg) ) {
						map_canvas.scrollIntoView(true);
						document.documentElement.scrollTop = document.documentElement.scrollTop - 10;
						e.preventDefault();
						e.stopImmediatePropagation();
						$("#SUBMIT_BUTTON").prop('disabled',false);

					}
				}
			});
	}

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
/*global diff_match_patch:true */
var init_history_dialog = function($, field_history) {
    var diff_match_patch_loaded = false;
	var dmp = null;

	var current_revision = null;
	var current_compare = null;
	
	var replace_history = function(data) {
		if (data.fail) {
			$('#HistoryFieldContent').html('<em>' + data.errinfo + '</em>');
		} else if (data.compare) {
			if (dmp === null) {
				dmp = new diff_match_patch();
			}

			var d = dmp.diff_main(data.text2, data.text1);
			dmp.diff_cleanupSemantic(d);
			var ds = dmp.diff_prettyHtml(d);
			$('#HistoryFieldContent').html(ds);
		} else {
			$('#HistoryFieldContent').html(data.text1);
		}
	};
	var history_select_changed = function(field, display, id) {
		return function() {
			var lang = $('#HistoryLanguage').prop('value');
			var revision = $('#HistoryRevision').prop('value');
			var compare = $('#HistoryCompare').prop('value');

			if (compare !== current_compare && (
					(current_compare === '' && compare === revision) ||
					(compare === '' && current_compare === current_revision))) {
				current_revision = revision;
				current_compare = compare;
				return;
			}

			var comp = compare;
			if (compare === '' || compare === revision) {
				comp = '';
			}
			$.getJSON(field_history.fielddiff_url.
					replace('[ID]', id).
					replace('[LANG]', lang).
					replace('[FIELD]', field).
					replace('[REV]', revision).
					replace('[COMP]', comp), replace_history);

			current_revision = revision;
			current_compare = compare;
		};
	};

	var add_history_events = null;
	var change_language = function(field, display, id, lang) {
		$('select.HistorySelect').unbind('change');
		$('#HistoryLanguage').unbind('change');

		$("#field_history").
			html('<p class="Info">' + field_history.txt_loading + '</p>').
			dialog('close').
			dialog('open').
			dialog('option', 'title', field_history.txt_fielddifftitle +
					id + " (" + display + ')').
			load(field_history.fielddiffui_url.
				replace("[ID]", id).
				replace('[FIELD]', field).
				replace('[LANG]', lang),
				add_history_events(field, display, id));
	};

	var language_changed = function(field, display, id) {
		return function() {
			var lang = $(this).prop('value');
			change_language(field, display, id, lang);
		};
	};
	
	add_history_events = function(field, display, id) {
		return function() {
			$('select.HistorySelect').
				change(history_select_changed(field, display, id));

			$('#HistoryLanguage').
				change(language_changed(field, display, id));

			current_revision = $('#HistoryRevision').prop('value');
			current_compare = $('#HistoryCompare').prop('value');
		};
	};


	$(".ShowVersions").click(function() {
		var field = $(this).data('ciocfield');
		var display = $(this).data('ciocfielddisplay');
		var id = $(this).data('ciocid');

		if (!diff_match_patch_loaded) {
			diff_match_patch_loaded = true;
			$.getScript(field_history.path_to_start + "scripts/diff_match_patch.min.js");
		}

		change_language(field, display, id, '');

	});

	var toggle_history_fields = function(e) {


		$(e.currentTarget).parent().children('ul').toggle("fast");
	};
	var go_to_field = function(e) {
		var field = $(e.currentTarget).data('fieldname');
		var td = document.getElementById('FIELD_' + field);
		if (td) {
			td.scrollIntoView(true);
		}
	};
	$(document).on('click', '.FieldHistoryJump', go_to_field);
	$(document).on('click', '.HistoryFieldsToggle', toggle_history_fields);

	var hide_children = function() {
		$('.HistoryFieldsToggle').
			parent().children('ul').hide();
	};
	$(".HistorySummary").click(function() {
		var lang = $(this).data('cioclang');
		var id = $(this).data('ciocid');

		$('#revision_history').
			html('Loading...').
			load(field_history.revhistory_url.
				replace('[ID]', id).
				replace('[LANG]', lang), hide_children).
			dialog('open');

	});

	$("#revision_history").dialog({autoOpen: false, width: 330, height: 280, position: ['right', 'top' ], resizable: false, dialogClass: 'RevHistory'});
	$("#field_history").dialog({autoOpen: false, width: 620, height: 280, position: ['right', 'bottom']});

	$(".RevHistory.ui-dialog").css({position:"fixed"});

};

window['init_history_dialog'] = init_history_dialog;
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
/*global
	confirm:true
*/
window['only_items_chk_add_html'] = function($, field, before_add) {
	return function (chkid, display) {
		if (before_add) {
			before_add();
		}
		$('#' + field + '_existing_add_container').
			append($('<label>').
				append(
					$('<input>').
						prop({
							id: field + '_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: field + '_ID',
							value: chkid
							})
				).
				append('&nbsp;').
				append(document.createTextNode(display))
			).
			append(' ; ');
	};
};

window['init_check_for_autochecklist'] = function(confirm_string) {
	var $ = jQuery;

	var go_to_unadded_check = function() {
		var check_add = $(this).data('jump_location');
		var input = document.getElementById(check_add);
		if (input) {
			input.scrollIntoView(true);
		}
	};

	var create_list_item = function() {
		return $('<li>').
			append($('<span>').
			data('jump_location', this.id).
			addClass('UnaddedChecklistJump SimulateLink').
			append($(this).parentsUntil('td[data-field-display-name]').parent().data('fieldDisplayName')));
	};

	var entry_form_items = $('input[id^=NEW_]');
	if (!entry_form_items.length) {
		// no elements, do nothing
		return;
	}
	$('#EntryForm').submit(function (event) {
			var fields = entry_form_items.map(function () { return this.value ? this : null; }),
				error_box, error_list;
			if (fields.length && !event.isDefaultPrevented()) {
				var docontinue = confirm(confirm_string);
				if (!docontinue) {
					event.preventDefault();
					$("#SUBMIT_BUTTON").prop('disabled',false);

					error_box = $('#unadded_checklist_error_box');
					error_list = $('#unadded_checklist_error_list');
					var error_list_visible = error_box.is(':visible');

					if (error_list_visible) {
						error_list.children('ul:first').hide('slow',
							function() {
								$(this).remove();
							});
					}
					var ul = $("<ul>");

					if (error_list_visible) {
						ul.hide();
					}


					error_list.append(ul);


					$.each( fields.map(create_list_item),
							function () { ul.append(this); });

					if (error_list_visible) {
						ul.show('slow');
					} else {
						error_box.show('slow');
					}

					return;

				}
				return;
			} else if (event.isDefaultPrevented()) {
				error_box = $('#unadded_checklist_error_box');
				error_list = $('#unadded_checklist_error_list');

				error_box.hide('slow',
						function() {
							error_list.children().remove();
						});
			}
		});

	$(document).on('click', ".UnaddedChecklistJump", go_to_unadded_check);


};
window['init_entryform_items'] = function(jqarray, delete_text, undo_text) {
	var $ = jQuery;
	jqarray.each(function() {
		var sortable = null;
		var obj = this;
		var jqobj = $(obj);
		var next_new_id = 1;
		var ids_dom = jqobj.find('.EntryFormItemContainerIds')[0];
		if (!ids_dom) {
			return;
		}

		var max_add = jqobj.data('maxAdd');
		if (max_add) {
			max_add = parseInt(max_add, 10);
		}

		var ids = [];
		if (ids_dom.value) {
			ids = $.map(ids_dom.value.split(','), function(value) {
					if (value.indexOf('NEW') === 0) {
						return null;
					}
					return value;
				});
		}
		var deleted_items = {};



		var update_numbering = function() {
			jqobj.find('.EntryFormItemBox').each(function(i) {
					$(this).find('.EntryFormItemCount').text(i+1);
				});
		};
		var endis_restore_add = function(en) {
			if (max_add) {
				var buttons = jqobj.find(".EntryFormItemContent:hidden").parent().find('button.EntryFormItemDelete').prop('disabled', !en);
				add_button.prop('disabled', !en);

				if (en) {
					buttons.removeClass('ui-state-disabled');
					add_button.removeClass('ui-state-disabled');
				} else {
					buttons.addClass('ui-state-disabled');
					add_button.addClass('ui-state-disabled');
				}
			}
		};
		var disable_restore_add = function() {
			endis_restore_add(false);
		};

		var get_enabled_count = function() {
			var deleted = 0;
			var i;
			for (i in deleted_items) {
				deleted++;
			}
			return ids.length - deleted;
		};

		var add = function(force) {
			var count = 0;
			if (max_add && !force) {
				count = get_enabled_count();
				if (count >= max_add) {
					alert("over");
					return;
				}
			}
			var template = jqobj.data('addTmpl');
			ids.push("NEW" + next_new_id++);
			ids_dom.value = ids.join(",");
			var new_item = $(template.replace(/\[COUNT\]/g, ids.length).replace(/\[ID\]/g, ids[ids.length-1]));
			new_item.find('.DatePicker').autodatepicker();
			new_item.find('.Province').combobox({source: window.cioc_province_source});
			if (entryform.service_titles) {
				new_item.find('.ServiceTitleField').combobox({ source: entryform.service_titles });
			}
			jqobj.append(new_item);
			if (sortable) {
				sortable.sortable('refresh');
				update_numbering();
			}
			if (max_add && !force && (count+1 === max_add)) {
				disable_restore_add();
			}
		};

		var add_button = jqobj.parent().find(".EntryFormItemAdd").click(function() { add(false); });

		jqobj.on('click', 'button.EntryFormItemDelete', function() {
				var self = this;
				var entryformbox = $(this).parents('.EntryFormItemBox');
				var hide_target = entryformbox.find('.EntryFormItemContent');
				var my_id = this.id.split('_');
				my_id = my_id[my_id.length-2];

				if (hide_target.is(':visible')) {
					hide_target.hide('slow', function() {
							deleted_items[my_id] = get_form_values(hide_target);

							$(self).text(undo_text);

							// Clear form elements
							hide_target.find('input,select,textarea').each(function() {
									if (this.nodeName.toLowerCase() === 'input' && ( this.type === 'checkbox' || this.type === 'radio')) {

										this.checked = false;
										return;
									}

									if (this.nodeName.toLowerCase() === 'select') {
										$(this).find('option').each(function () {
												this.selected = false;
											});
										return;
									}

									this.value = '';
								});
							endis_restore_add(true);
						});


				} else {
					var count = 0;
					if (max_add) {
						count = get_enabled_count();
						if (count >= max_add) {
							alert("over");
							return;
						}
					}
					var values = deleted_items[my_id];
					if (!values) {
						// XXX how did we get here?
						return;
					}

					delete deleted_items[my_id];
					restore_form_values ( hide_target, values);

					hide_target.show('slow', function () {
								$(self).text(delete_text);
							});

					if (max_add && (count + 1 === max_add)) {
						disable_restore_add();
					}

				}


			});
		if (jqobj.hasClass('sortable')) {
			sortable = jqobj.sortable({items:'.EntryFormItemBox'});
			sortable.bind('sortstart', function(event, ui) {
					ui.helper.bgiframe();
					jqobj.addClass('sorting');
				});
			sortable.bind('sortstop', function() {
					var order = sortable.sortable('toArray');
					ids = $.map(order, function(item) {
							item = item.split('_');
							return item[item.length-2];
						});
					ids_dom.value = ids.join(',');
					setTimeout(function() {
						jqobj.removeClass('sorting');
						update_numbering();
					},1);
				});
		}

		var onbeforeunload = function(cache) {
			cache[obj.id + '_ids'] = ids;
			cache[obj.id + '_deletes'] = deleted_items;
			if (sortable) {
				cache[obj.id + '_order'] = sortable.sortable('toArray');
			}
		};
		cache_register_onbeforeunload(onbeforeunload);

		var onbeforerestorevalues = function(cache) {
			if (cache[obj.id + '_ids']) {
				$.each(cache[obj.id + '_ids'], function(index, value) {
					if (value.indexOf('NEW') === 0) {
						add(true);
					}
				});
			}

			if (cache[obj.id + '_deletes']) {
				deleted_items = cache[obj.id + '_deletes'];
				jqobj.find('.EntryFormItemContent').each(function() {
					var id = this.id.split('_');
					id = id[id.length-2];
					if (deleted_items[id]) {
						$(this).hide().parent().
							find('button.EntryFormItemDelete').text(undo_text);
					}
				});
			}

			if (max_add) {
				var count = get_enabled_count();
				if (count >= max_add) {
					disable_restore_add();
				}
			}

			if (sortable) {
				var order = cache[obj.id + '_order'];
				if (order) {
					order.reverse();
					$.each(order, function(i, item) {
							$('#' + item).detach().prependTo(jqobj);
						});
					sortable.sortable('refresh');
					update_numbering();
				}

			}
		};

		cache_register_onbeforerestorevalues(onbeforerestorevalues);
	});
};

window['init_schedule'] = function($) {
	var on_recur_type_change = function() {
		var container = $(this).parents('.EntryFormItemBox'), type = this.value;

		if (type === '0') {
			container.find('.recurs-ui').hide();
		} else if (type == '1') {
			container.find('.repeat-every-ui, .repeats-on-ui, .recurs-week-label').show();
			container.find('.repeat-week-of-month-ui, .repeat-day-of-month-ui, .recurs-month-label').hide();
		} else if (type == '2') {
			container.find('.repeat-every-ui, .repeat-day-of-month-ui, .recurs-month-label').show();
			container.find('.repeat-week-of-month-ui, .repeats-on-ui, .recurs-week-label').hide();
		} else {
			container.find('.repeat-every-ui, .repeat-week-of-month-ui, .repeats-on-ui, .recurs-month-label').show();
			container.find('.repeat-day-of-month-ui, .recurs-week-label').hide();

		}
	};
	$('#ScheduleEditArea').on('change', '.recur-type-selector', on_recur_type_change).find('.recur-type-selector').each(on_recur_type_change);
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

(function(){
/*global
	confirm:true
*/
var changeAutoAssign= function(autoBoxObj, newNUMObj, newNUMButtonObj) {
	if (autoBoxObj.checked) {
		newNUMObj.value='';
		newNUMObj.disabled=true;
		newNUMButtonObj.disabled=true;
	} else {
		newNUMObj.disabled=false;
		newNUMButtonObj.disabled=false;
	}
};
window['changeAutoAssign'] = changeAutoAssign;

var $ = jQuery;

var make_required = function(parents) {
	parents.find(':input').not('input[type="hidden"]').filter('[name]').addClass('require-group');
};

var remove_required = function(parents) {
	parents.find(':input').not('input[type="hidden"]').filter('[name]').removeClass('require-group');
};

window['make_required_group'] = make_required;
window['remove_required_group'] = remove_required;

var update_required = function(field, required) {
	var edit_field = field.parent().find('td[data-field-display-name]');
	var display_name = edit_field.data('fieldDisplayName');

	if (required) {
		field.text(display_name).append(' <span class="Alert">*</span>');
		make_required(edit_field);
	} else {
		field.text(display_name);
		remove_required(edit_field);
	}
};

var update_copy_form_required = function() {
	var org_level_2_field = $("#FIELD_ORG_LEVEL_2");
	if (!org_level_2_field.length) {
		return;
	}

	var required = $("#RECORD_TYPE").find(":selected").data('progorbranch');
	update_required(org_level_2_field, required);
};

var update_form_make_required_org_level = function() {
	var orglvl;
	for (var i = 0; i < 6; i++) {
		orglvl = $('#FIELD_ORG_LEVEL_' + i);
		if (orglvl.length) {
			update_required(orglvl, true);
			return;
		}
	}

};
window['update_form_make_required_org_level'] = update_form_make_required_org_level;

var init_client_validation = function(selector, txt_validation_error) {
	var form = $(selector), culture = form.prop('lang') || form.parents('[lang]').first().prop('lang') || 'en-CA';

	var checkable = function(element) {
		return (/radio|checkbox/i).test(element.type);
	};
	/*
	var idOrName = function(element) {
		return this.checkable(element) ? element.name : element.id || element.name;
	};
	*/
	var not_all_empty = function(elements) {
		var one_not_empty = false;
		try {
			elements.each(function() {
				if (!this.name) {
					return;
				}
				if (checkable(this)) {
					if (this.checked && this.value) {
						one_not_empty = true;
						throw { name: 'StopIteration', message:'StopIteration'};
					}
					return;
				}
				if ($.trim(this.value)) {
					one_not_empty = true;
					throw { name: 'StopIteration', message:'StopIteration'};
				}
			});

		} catch (e) {
			if (e.name !== 'StopIteration') {
				throw e;
			}
		}

		return one_not_empty;
	};

	var email_regex = null;
	$.validator.addMethod('email', function(value, element) {
		if (!email_regex) {
			var one_email = "([A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+(\\.[A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+)*@[A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+(\\.[A-Za-z0-9!#-'\\*\\+\\-/=\\?\\^_`\\{-~]+)*)";
			var many_email = "^((" + one_email + "(\\s*,*\\s*))*)$";
			//email_regex = /^([A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*@[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*)$/

			email_regex = new RegExp(many_email);

		}
		return this.optional(element) || email_regex.test(value);

	});
	var url_regex = null;
	$.validator.addMethod('url', function(value, element) {
		if (!url_regex) {
			url_regex = /^((\d{1,3}(\.\d{1,3}){3})|([\w_\-]+(\.[\w\._\-]+)*)(:[0-9]+)?((\/|\?)[^\s]*)?)$/;
		}
		return this.optional(element) || url_regex.test(value);

	});
	var protourl_regex = null;
	$.validator.addMethod('protourl', function(value, element) {
		if (!protourl_regex) {
			protourl_regex = /^(https?:\/\/)?((\d{1,3}(\.\d{1,3}){3})|([\w_\-]+(\.[\w\._\-]+)*)(:[0-9]+)?((\/|\?)[^\s]*)?)$/;
		}
		return this.optional(element) || protourl_regex.test(value);

	});
	var posint_regex = null;
	$.validator.addMethod('posint', function(value, element) {
		if (!posint_regex) {
			posint_regex = /^\d+$/;
		}
		return this.optional(element) || posint_regex.test(value);

	});
	var posdbl_regex = null;
	$.validator.addMethod('posdbl', function(value, element) {
		if (!posdbl_regex) {
			var sep = '\\.';
			if (culture === 'fr-CA') {
				sep = ',';
			}
			posdbl_regex = new RegExp("^((\\d+)|(\\d*" + sep + "\\d+))$");
		}
		return this.optional(element) || posdbl_regex.test(value);

	});
	var num_regex = null;
	$.validator.addMethod('record-num', function(value, element) {
		if (!num_regex) {
			// XXX limit to specific num length?
			num_regex = /^[A-Z]{3}[0-9]{4,5}$/;
		}
		return this.optional(element) || num_regex.test(value);

	});

	$.validator.addMethod('unique', function(value, element, params) {
		if (!value) {
			return true;
		}
		value = string_ci_ai(value);
	    var prefix = params;
		var selector = jQuery.validator.format("[name!='{0}'][unique='{1}']", element.name, prefix);
		var matches = new Array();
		$(selector).each(function(index, item) {
			if (value == string_ci_ai($(item).val())) {
				matches.push(item);
			}
		});

		return matches.length == 0;	
	}, 'A unique value is required.');

	$.validator.addMethod('require-group', function(value, element) {
		var module = $(element).parents('td[data-field-display-name]');

		var fieldname = module.parent().children('td:first').prop('id');
		fieldname = fieldname.slice(-(fieldname.length - 6));
		var fields = module.find(':input').not('[type=hidden]').not('button');
		// alterations to field list
		switch(fieldname) {
			case 'ACCESSIBILITY':
			case 'AREAS_SERVED':
			case 'LANGUAGES':
			case 'FUNDING':
			case 'SCHOOL_ESCORT':
			case 'SCHOOLS_IN_AREA':
			case 'TYPE_OF_CARE':
				fields = fields.not("input:text");
				break;

			case 'ALT_ORG':
			case 'LEGAL_ORG':
				fields = fields.not("input:checkbox");
				break;

			case 'FORMER_ORG':
				fields = fields.not("input:checkbox").not("[name^=FORMER_ORG_DATE]");
				break;

			case 'FEES':
				fields = fields.not("input:text").add('#FEE_ASSISTANCE_FOR, #FEE_ASSISTANCE_FROM');
				break;

			case 'VACANCY_INFO':
				fields = fields.filter("[name!=VUT_ID]");
				break;
		}

		var result = not_all_empty(fields);
		if (result) {
			module.children('div.required-notice').hide();
		}/* else {
			module.find("label[for='" + this.idOrName(element) + "']").remove();
		}*/
		return result;

	}, "Field Required");

	var errorsDialog = $('<div id="a_test"></div>').dialog({
		autoOpen: false,
		title: txt_validation_error,
		closeOnEscape: false,
		position: ['right', 'bottom'],
		resizable: false,
		//width: 200,
		//height: 200,
		dialogClass: 'ValidationErrors'
		});
	var errorsNotice = $('#validation_error_box');

	$(document).on('click', '.FieldErrorJump', function(e) {
				var target = e.currentTarget;
				var field = $(target).prop('fieldname');
				var td = document.getElementById(field);
				if (td) {
					td.scrollIntoView(true);
				}
			});
	$(".ValidationErrors.ui-dialog").css({position: "fixed"}).position({my: 'right bottom', at: 'right bottom', of: window});

	make_required($(selector).find('td[data-field-required]'));

	var validator = $(selector).validate({
			ignore: 'input[type=hidden]',
			ignoreTitle: true,
			errorPlacement: function(error,element) {
				var require_container = [];
				var el = element[0];
				var module = null;
				if (element.hasClass('require-group')) {
					module = element.parents('td[data-field-display-name]');
					require_container = module.children('div.required-notice');
					var empty = false;
					if (checkable(el)) {
						if (!(el.checked && el.value)) {
							empty = true;
						}
					} else if (!$.trim(el.value)) {
						empty = true;
					}
					if (empty) {

						if (require_container.length) {
							require_container.empty();
							require_container.show();
							require_container.append(error);
						} else {
							error.removeAttr('for');

							module.prepend($('<div class="required-notice"></div>').append(error));
						}
						return;
					}
				}
				if (require_container.length) {
					require_container.hide();
				}
				error.insertAfter(element);
			},

			showErrors: function(errorMap, errorList) {
				this.defaultShowErrors();
				if (errorList.length === 0) {
					errorsDialog.dialog('close');
					errorsNotice.hide('slow');
					return;
				}

				var field_map = {};
				var container = $('<ul>');
				jQuery.each(errorList, function(index,el) {
						el = el.element;
						var module = $(el).parents('td[data-field-display-name]');
						var fieldname = module.parent().children('td:first').prop('id');
						if (field_map[fieldname]) {
							return;
						}
						field_map[fieldname] = true;
						container.append($('<li>').append($('<span>').prop({fieldname: fieldname, 'className': 'FieldErrorJump SimulateLink'}).text(module.data('fieldDisplayName'))));

					});
				errorsDialog.empty().append(container);

				errorsDialog.dialog('open');
				errorsNotice.show('slow');
				$('#SUBMIT_BUTTON').prop('disabled', false);

			},
			focusInvalid: false, onfocusout: false,
			onkeyup: false, onclick: false


		});

	if (culture === 'fr-CA') {
		jQuery.extend(jQuery.validator.messages, {
			/* default messages */
			required: "Ce champ est requis.",
			remote: "Veuillez remplir ce champ pour continuer.",
			email: "Veuillez entrer une adresse email valide.",
			url: "Veuillez entrer une URL valide.",
			date: "Veuillez entrer une date valide.",
			dateISO: "Veuillez entrer une date valide (ISO).",
			number: "Veuillez entrer un nombre valide.",
			digits: "Veuillez entrer (seulement) une valeur num\u00e9rique.",
			creditcard: "Veuillez entrer un num\u00e9ro de carte de cr\u00e9dit valide.",
			equalTo: "Veuillez entrer une nouvelle fois la m\u00eame valeur.",
			accept: "Veuillez entrer une valeur avec une extension valide.",
			maxlength: jQuery.validator.format("Veuillez ne pas entrer plus de {0} caract\u00e8res."),
			minlength: jQuery.validator.format("Veuillez entrer au moins {0} caract\u00e8res."),
			rangelength: jQuery.validator.format("Veuillez entrer entre {0} et {1} caract\u00e8res."),
			range: jQuery.validator.format("Veuillez entrer une valeur entre {0} et {1}."),
			max: jQuery.validator.format("Veuillez entrer une valeur inf\u00e9rieure ou \u00e9gale \u00e0 {0}."),
			min: jQuery.validator.format("Veuillez entrer une valeur sup\u00e9rieure ou \u00e9gale \u00e0 {0}."),

			/* new messages */
			protourl: "Veuillez entrer une URL valide.",
			posint: 'Veuillez entrer un nombre positif.',
			posdbl: 'Veuillez entrer un nombre positif.',
			'record-num': 'Please enter a valid record number.',
			'require-group': 'Ce champ est requis.',
			unique: 'Une valeur unique est requise.'

		});
	} else {
		jQuery.extend(jQuery.validator.messages, {
			/* new messages */
			protourl: "Please enter a valid URL.",
			posint: 'Please enter a positive number.',
			posdbl: 'Please enter a positive number.',
			'record-num': 'Please enter a valid record number.',
			'require-group': 'Field Required.',
			unique: 'A unique value is required.'
		});
	}

	return validator;
};
window['init_client_validation'] = init_client_validation;


var init_record_type_form = function(num, url, org_levels) {
	var last_record_type = null;
	var record_type_field_name = null;
	var record_type_form_cache = {};
	var fields = [
		'ORG_LEVEL_1', 'ORG_LEVEL_2', 'ORG_LEVEL_3', 'ORG_LEVEL_4',
		'ORG_LEVEL_5', 'LOCATION_NAME', 'SERVICE_NAME_LEVEL_1', 'SERVICE_NAME_LEVEL_2'
	];

	var onload = function() {
		$('#RecordTypeName').html(record_type_field_name);
		$.each(fields, function(field_name) {
			var org = org_levels[field_name];
			var field = $('#' + field_name);
			if (field.length) {
				field[0].value = org;
				if (org) {
					$('#' + field_name + '_DISPLAY').text(org);
					$('#HIDDEN_' + field).prop('value', org);
				}
			}
		});
		$("#RECORD_TYPE").prop('value', last_record_type[0].value);
		update_copy_form_required();

	};
	var onchange = function() {
		var oldoptval = last_record_type[0].value;
		if(!last_record_type.data('hasform')) {
			oldoptval = null;
		}

		last_record_type = $(this).find('option:selected');
		var newoptval = last_record_type[0].value;
		if(!last_record_type.data('hasform')) {
			newoptval = null;
		}
		if (newoptval !== oldoptval) {
			record_type_form_cache[oldoptval] = $('#copyFieldsForm').contents().detach();
			if (record_type_form_cache[newoptval]) {
				$('#copyFieldsForm').append(record_type_form_cache[newoptval]);
				$("#RECORD_TYPE").prop('value', last_record_type[0].value);
				return;
			}

			$('#copyFieldsForm').load(url + ' #copyFieldsInner', {'NUM': num, 'RT': newoptval || last_record_type[0].value},
				onload);
		} else {
			update_copy_form_required();
		}
	};

	jQuery(function() {
		record_type_field_name = $('#RecordTypeName').html();
		var rt = $('#RECORD_TYPE');

		$(document).on('change', '#RECORD_TYPE', onchange);

		last_record_type = rt.find('option:selected');

		update_copy_form_required();
	});

};

window['init_record_type_form'] = init_record_type_form;

var init_validate_duplicate_org_names = function(options) {
	var opt = $.extend({
		selector: '#EntryForm',
		fields: [
			'#ORG_LEVEL_1', '#ORG_LEVEL_2', '#ORG_LEVEL_3', '#ORG_LEVEL_4',
			'#ORG_LEVEL_5', '#LOCATION_NAME', '#SERVICE_NAME_LEVEL_1', '#SERVICE_NAME_LEVEL_2',
			'#OLS_SELECT input', '#ORG_NUM'
		].join(","),
		only_warn: true,
		num: null,
		org_levels: [],
		url: null // needs to be provided
	}, options), verrified_values = [], valid = opt.num !== null, error_types=[];

	var form = $(opt.selector).submit(function(event) {
		var i, val, changed=false,
			new_values = $(opt.fields).serializeArray();
		
		if (opt.num) {
			new_values.push({name: 'NUM', value: opt.num});
		}

		if (new_values.length !== verrified_values.length) {
			changed = true;
		} else {
			for (i=0; i < new_values.length; i++) {
				val = new_values[i];
				if (val.name !== verrified_values[i].name || val.value !== verrified_values[i].value) {
					changed = true;
					break;
				}
			}
		}

		if (!changed && valid) {
			return true; // continue with submit
		}

		var show_error = function() {
			// XXX show errors specfific to duplicate type
			if (opt.only_warn && confirm(opt.confirm_string)) {
				valid = true;
				$('#duplicate_name_error_box').hide();
				form.submit();
			} else {
				$('#SUBMIT_BUTTON').prop('disabled', false);
				$('#duplicate_name_error_box').show();
			}
		};

		event.stopPropagation();
		event.preventDefault();

		if (!changed) {
			// already checked if valid above,
			// so not changed implies error
			show_error();
			return false;
		}

		// There was a change in the values, check the server
		$.ajax({
			url: opt.url,
			dataType: 'json',
			method: 'get',
			data: new_values,
			success: function(result) {
				valid = true;
				error_types = [];
				for (var i = 0; i < result.length; i++) {
					valid &= result[i].count === 0;
					if (result[i].count !== 0) {
						error_types.push(result[i].type);
					}
				}
				verrified_values = new_values;
				if (valid) {
					$('#duplicate_name_error_box').hide();
					form.submit();
				} else {
					// error condition, show error
					show_error();
				}
			}
		});

		return false;
	});

};

window['init_validate_duplicate_org_names'] = init_validate_duplicate_org_names;
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

(function(){
var $ = jQuery;
var configure_entry_form_button = function() {
	$("#SUBMIT_BUTTON").click(function(evt) { 
		var btn = $('#SUBMIT_BUTTON');
		if (btn.prop('disabled')) {
			return;
		}
		btn.prop('disabled', true);
		setTimeout(function() {
			$("#EntryForm").submit();
		}, 1);
	});

	$(document).bind('keydown', function(evt) {
		if (evt.ctrlKey && String.fromCharCode( evt.which).toLowerCase() === 's') {
			setTimeout(function() {
				$('#SUBMIT_BUTTON').click();
			}, 1);
			evt.preventDefault();
			evt.stopPropagation();
			return false;
		}
	});
	$("#SUBMIT_BUTTON").prop('disabled',false);
}
window['configure_entry_form_button'] = configure_entry_form_button;

var configure_feedback_submit_button = function() {
	 var value = $("#SUBMIT_BUTTON").prop('value');
	$("#SUBMIT_BUTTON").replaceWith($('<input type="button" class="btn btn-default" id="SUBMIT_BUTTON">').prop('value', value));
	$('#EntryForm').submit(function() {
		var retval = validateForm();
		if (retval === false) {
			$("#SUBMIT_BUTTON").prop('disabled', false);
		}
		return retval;
	});
}
window['configure_feedback_submit_button'] = configure_feedback_submit_button;

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
var init_entryform_notes = function(jqarray, show_text, hide_text) {
	var $= jQuery;
	jqarray.each(function() {
		var sortable = null;
		var obj = this;
		var order = [];
		var jqobj = $(obj);
		var parent = jqobj.parent();
		var next_new_id = 1;
		var updates_dom = jqobj.find('.EntryFormNotesUpdateIds')[0];
		if (!updates_dom) {
			return;
		}
		var deletes_dom = jqobj.find('.EntryFormNotesDeleteIds')[0];
		var cancels_dom = jqobj.find('.EntryFormNotesCancelIds')[0];
		var restores_dom = jqobj.find('.EntryFormNotesRestoreIds')[0];

		var updates = [];
		var deletes = [];
		var cancels = [];
		var cancel_reason = {};
		var restores = [];

		var add_templated = function(data, isnew) {
			updates.push(data.id);
			updates_dom.value = updates.join(',');
			var count = jqobj.find('.EntryFormItemBox').length + 1;
				template = jqobj.data('addTmpl'),
				new_item = $(template.replace(/\[COUNT\]/g, count).
						replace(/\[ID\]/g, data.id).
						replace(/\[MODIFIED_DATE\]/g, data.modified_date || '').
						replace(/\[MODIFIED_BY\]/g, data.modified_by || '').
						replace(/\[CREATED_DATE\]/g, data.created_date || '').
						replace(/\[CREATED_BY\]/g, data.created_by || '').
						replace(/\[NOTE_VALUE\]/g, data.note_value || ''));
			if (data.note_type) {
				new_item.find("option[value='" + data.note_type + "']").prop('selected', true);
			}

			if (data.created_date) {
				new_item.find('tr.CreatedField').show();
			}
			if (data.modified_date && (data.modified_date !== data.created_date || data.modified_by !== data.created_by)) {
				new_item.find('tr.ModifiedField').show();
			}

			if (isnew) {
				new_item.find('.NewFlag').show();
			}

			jqobj.append(new_item);

		};

		var add = function() {
			var id = "NEW" + next_new_id++;

			add_templated({id: id}, true);
		};

		var add_button = parent.find(".EntryFormItemAdd").click(function() { add(false); });

		var do_update = function(button) {
			var container = $(button).parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent');

			add_templated(entry.data('formValues'));
			container.hide(); // remove?

		};
		var do_delete = function(button) {
			var id = button.id.split('_'), btn = $(button),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent');

			entry.css('text-decoration', 'line-through');
			deletes.push(id[id.length-2]);
			deletes_dom.value = deletes.join(',');
			container.data('actionToRestore', 'delete');

			// hide button, show restore button
			btn.parent().hide().prev().show();
			
		};
		var do_cancel = function(button, selected_action) {
			var id = button.id.split('_'), btn = $(button),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent'),
				splitpoint = button.id.lastIndexOf('_'),
				fieldname = button.id.substring(0,splitpoint) + '_CANCEL_REASON';

			id = id[id.length-2];
			entry.prepend(selected_action.data('cancelTemplate'));
			cancels.push(id);
			cancels_dom.value = cancels.join(',');
			cancel_reason[id] = selected_action.data('cancelType');
			jqobj.append($('<input>').prop({
				type: 'hidden', 
				id: fieldname, 
				name: fieldname, 
				value: selected_action.data('cancelType')
			}));
			container.data('actionToRestore', 'cancel');

			// hide button, show restore button
			btn.parent().hide().prev().show();
		};
		var menu_actions = { 
			'update': do_update, 
			'delete': do_delete, 
			'cancel': do_cancel
		};
		var menu = parent.find('.EntryFormItemActionMenu').menu({
			select: function(event, ui) {
				$(this).hide();
				menu_actions[ui.item.data('action')](menu.data('activeButton'), ui.item);
			}
		}).hide().css({position: 'absolute', zIndex: 1});
		parent.on('click', '.EntryFormItemAction', function(event) {
			menu.data('activeButton', this);
			if (menu.is(':visible') ){
				menu.hide();
				return false;
			}
			menu.menu('blur').show();
			menu.position({
				my: "right top",
				at: "right bottom",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
			});
			return false;
		});

		parent.find('.EntryFormItemViewHidden').click(function(event) {
			var self = $(this), hide_target = self.next();
			if (hide_target.is(':visible')) {
				self.text(show_text);
				hide_target.hide();
			} else {
				self.text(hide_text);
				hide_target.show();
			}	

		});

		var restore_delete = function(id, btn, container, entry) {
			entry.css('text-decoration', 'none');
			deletes = $.grep(deletes, function(value) { return value !== id;});
			deletes_dom.value = deletes.join(',');

			// hide button, show restore button
			btn.parent().hide().next().show();
		};
		var restore_cancel = function(id, btn, container, entry) {
			var button = btn[0],
				splitpoint = button.id.lastIndexOf('_'),
				fieldname = button.id.substring(0,splitpoint) + '_CANCEL_REASON';

			entry.find('.EntryFormItemCancelledDetails').remove();
			cancels = $.grep(cancels, function(value) { return value !== id;}),
			cancels_dom.value = cancels.join(',');
			delete cancel_reason[id];
			$('#' + fieldname).remove();

			btn.parent().hide().next().show();
		};
		var restore_fns = {
			'delete': restore_delete,
			'cancel': restore_cancel
		};

		parent.on('click', '.EntryFormItemRestoreAction', function(event) {
			var id = this.id.split('_'), btn = $(this),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemContent');

			restore_fns[container.data('actionToRestore')](id[id.length-2], btn, container, entry);
		});

		var do_restore_cancel = function(event) {
			var id = this.id.split('_'), btn = $(this),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemCancelledDetails');

			entry.css('text-decoration', 'line-through');
			btn.parent().hide().prev().show();

			restores.push(id[id.length-2]);
			restores_dom.value = restores.join(',');

		};
		parent.on('click', '.EntryFormItemRestoreCancel', do_restore_cancel);

		parent.on('click', '.EntryFormItemDontRestoreCancel', function(event) {
			var id = this.id.split('_'), btn = $(this),
				container = btn.parents('.EntryFormNotesItem'),
				entry = container.find('.EntryFormItemCancelledDetails');

			entry.css('text-decoration', 'none');
			btn.parent().hide().next().show();
			id = id[id.length - 2];
			restores = $.grep(restores, function(value) { return value !== id;}),
			restores_dom.value = restores.join(',');

		});

		var onbeforeunload = function(cache) {
			cache[obj.id + '_updates'] = updates;
			cache[obj.id + '_deletes'] = deletes;
			cache[obj.id + '_restores'] = restores;
			cache[obj.id + '_cancels'] = cancels;
			cache[obj.id + '_cancel_reason'] = cancel_reason;
		};
		cache_register_onbeforeunload(onbeforeunload);

		var onbeforerestorevalues = function(cache) {
			var id_prefix = obj.id.substring(0, obj.id.lastIndexOf('_')) + '_';
			if (cache[obj.id + '_updates']) {
				
				$.each(cache[obj.id + '_updates'], function(index, value) {
					if (value.indexOf('NEW') === 0) {
						next_new_id++;
						add_templated({id: value}, true);
					} else {
						var entry = $('#' + id_prefix + value + '_DISPLAY');
						add_templated(entry.data('formValues'));
						$('#' + id_prefix + value + '_CONTAINER').hide();
					}
				});
			}
			if (cache[obj.id + '_deletes']) {
				$.each(cache[obj.id + '_deletes'], function(index, value) {
					do_delete(document.getElementById(id_prefix + value + '_ACTION'));
				});
			}
			if (cache[obj.id + '_restores']) {
				$.each(cache[obj.id + '_restores'], function(index, value) {
					do_restore_cancel.call(document.getElementById(id_prefix + value + '_RESTORECANCEL'));
				});
				parent.find('.EntryFormItemViewHidden').click();
			}

			if (cache[obj.id + '_cancels']) {
				var cancel_reason = cache[obj.id + '_cancel_reason'];
				$.each(cache[obj.id + '_cancels'], function(index, value) {
					do_cancel(document.getElementById(id_prefix + value + '_ACTION'), menu.find("li[data-cancel-type='" + cancel_reason[value] + "']"));
				});
				
			}
		};

		cache_register_onbeforerestorevalues(onbeforerestorevalues);
	});
};
window['init_entryform_notes'] = init_entryform_notes;
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
/*global alert:true entryform:true get_form_values:true restore_form_values:true cache_register_onbeforeunload:true cache_register_onbeforerestorevalues:true
  default_cache_search_fn:true init_autocomplete_checklist:true create_caching_source_fn:true only_items_chk_add_html:true create_checklist_onbefore_fns:true make_required_group:true remove_required_group:true basic_chk_add_html:true
  */
function create_org_level_complete($, fields, caches) {
	var my_field = fields.pop();
	var my_cache = caches.shift();

	var source = create_caching_source_fn($,entryform.org_level_complete_url, my_cache, null,
			default_cache_search_fn($, my_cache, null, '^'));
	$(my_field).autocomplete({
			focus:function() {
				return false;
			},
			source: function(request, response) {
				var i;
				for (i = 0; i < fields.length; i++) {
					if (!fields[i].value || (my_cache[fields[i].name] && my_cache[fields[i].name].value && fields[i].value !== my_cache[fields[i].name])) {
						//response([]);
						delete my_cache.term;
						delete my_cache.content;
						for (var j = 0; j < fields.length; j++) {
							delete my_cache[fields[i].name];
						}
						if (!fields[i].value) {
							response([]);
							return;
						}
					}
					request[fields[i].name] = fields[i].value;
				}
				source(request, function(data) {
					for (i = 0; i < fields.length; i++) {
						my_cache[fields[i].name] = fields[i].value;
					}

					response(data);
				});
			},
			minLength: my_field.id.slice(-1) === 1 ? 5 : 3
		}).
	keypress(function (evt) {
			if (evt.keyCode === 13) {
				evt.preventDefault();
				$(my_field).autocomplete('close');
			}
		});

}
window['init_orglevels'] = function($) {

	var org_levels = $.makeArray($("#ORG_LEVEL_1, #ORG_LEVEL_2, #ORG_LEVEL_3, #ORG_LEVEL_4"));
	var caches = [];
	var i;
	for (i = 0; i < org_levels.length; i++) {
		caches.push({});
	}

	for (i = 0; i < org_levels.length; i++) {
		if (org_levels[i].name !== 'ORG_LEVEL_' + (i + 1)) {
			return;
		}

		create_org_level_complete($, $.makeArray(org_levels).slice(0, i+1), $.makeArray(caches).slice(i));

	}

// Service name 1 completes with matching ORG_Name
// service name 2 completes with matching location_name
	org_levels = $.makeArray($("#ORG_LEVEL_1, #ORG_LEVEL_2, #ORG_LEVEL_3, #ORG_LEVEL_4, #ORG_LEVEL_5, #ORG_NUM, #NUM, #SERVICE_NAME_LEVEL_1"));
	caches = [{}];
	if (!org_levels.length || org_levels[org_levels.length-1].name !== 'SERVICE_NAME_LEVEL_1') {
		return;
	}
	create_org_level_complete($, org_levels, caches);
};

window['init_areas_served'] = function($, txt_not_found) {
	var base_add_new_html = basic_chk_add_html($, 'CM');
	var add_new_html = function(chkid, display, label) {
		return base_add_new_html(chkid, label);
	};
	init_autocomplete_checklist($, {
			field:'CM',
			source: entryform.community_complete_url,
			minLength: 3,
			txt_not_found: txt_not_found,
			add_new_html: add_new_html
		});
};

window['init_inarea_schools'] = function($, txt_not_found) {
	init_autocomplete_checklist($, {field: 'INAREA_SCH', source: entryform.sch_source, txt_not_found: txt_not_found});
};

window['init_escort_schools'] = function($, txt_not_found) {
	init_autocomplete_checklist($, {field: 'ESCORT_SCH', source: entryform.sch_source, txt_not_found: txt_not_found});
};

window['init_distribution'] = function($, txt_not_found) {
	init_autocomplete_checklist($, {field: 'DST',
			source: entryform.dst_complete_url,
			add_new_html: only_items_chk_add_html($, 'DST'),
			match_prop: 'label',
			txt_not_found: txt_not_found
			});
};

window['init_busroutes'] = function($) {
	var added_values = [];
	var add_fn = function (chkid, display) {
		var existing_val = $('#BR_ID_' + chkid);
		if (existing_val.length) {
			existing_val[0].checked = true;
			return;
		}
		added_values.push({chkid: chkid, display: display});
		$('#BR_existing_add_table').
			append($('<tr>').
				append($('<td>').
					append($('<input>').
						prop({
							id: 'BR_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: 'BR_ID',
							value: chkid
							})
					).
					append(document.createTextNode(' ' + display))
				));
	};

	var new_br = $('#NEW_BR');
	$('#add_BR').click(function() {
			var value = new_br[0].value;
			var label = new_br.children('[value=' + value + ']').text();
			add_fn(value, label);
		});

	create_checklist_onbefore_fns ($, 'BR', added_values, add_fn);
};

window['init_subjects'] = function($, txt_not_found) {
	var show_subject_added_title = function() {
		$('#Subj_existing_add_title').removeClass('NotVisible');
	};
	init_autocomplete_checklist($, {field: 'Subj',
			source: entryform.subj_complete_url,
			add_new_html: only_items_chk_add_html(
				$, 'Subj', show_subject_added_title
			),
			txt_not_found: txt_not_found});
};

window['init_fees'] = function($) {
	var assistance_targets = $('#FEE_ASSISTANCE_FOR, #FEE_ASSISTANCE_FROM'),
		disable_fee_assistance = function() {
			assistance_targets.prop('disabled', !$(this).prop('checked'));
		};
	$('#FEE_ASSISTANCE_AVAILABLE').click(disable_fee_assistance).each(disable_fee_assistance);
};

window['init_org_num'] = function($) {
	$('#FIELD_ORG_NUM').next().on('click', '.suggested-num', function() {
		$('#ORG_NUM').val(this.value).trigger('change');
		
		return false;
	});
};

window['init_locations_services'] = function($, txt_invalid_record) {
	var new_entry_template_template = '<li><label><input type="checkbox" name="[FIELD]" value="[VALUE]" id="[FIELD]_[VALUE]" checked> [VALUE]</label></li>',
	create_locations_services_widget = function (loc_services_list, field, needs_ols_type) {
		var new_entry_template = new_entry_template_template.replace(/\[FIELD\]/g, field),
		add_locations_services_container = loc_services_list.siblings('.locations-services-new-container'),
		new_value_el = add_locations_services_container.find('.locations-services-new'),
		add_location_services_button = add_locations_services_container.find('.locations-services-add'),
		suggestions_container = loc_services_list.siblings('.locations-services-list-suggestions'),
		ols_checkbox = $(needs_ols_type),
		onbeforeunload = function(cache) {
			cache[field + '_STATE'] = loc_services_list.html();
		}, onbeforerestorevalues = function(cache) {
			var state = cache[field + '_STATE'];
			if (state){
				loc_services_list.html(state);
			}
		}, do_show_error = function() {
			if (!loc_services_list.siblings(".locations-services-error").length) {
				//console.log('error');
				$('<p>').
					hide().
					addClass('Alert').
					addClass('locations-services-error').
					append(document.createTextNode(txt_invalid_record)).
					insertBefore(add_locations_services_container).
					show('slow');
			}
		}, add_new_entry = function(new_value) {
				var existing_el = $('#' + field + '_' + new_value), new_entry;
				if (existing_el.length) {
					existing_el[0].checked = true;
				} else {
					new_entry = new_entry_template.replace(/\[VALUE\]/g, new_value);
					loc_services_list.append($(new_entry));
				}
		};

		if(loc_services_list.length) {
			cache_register_onbeforeunload(onbeforeunload);
			cache_register_onbeforerestorevalues(onbeforerestorevalues);
		}

		add_locations_services_container.on('click', '.locations-services-add', function() {
			var new_value = $.trim(new_value_el[0].value);
			if (new_value) {
				if (!/^[A-Z]{3}[0-9]{4,5}$/.test(new_value)) {
					do_show_error();
					return false;
				}

				add_new_entry(new_value);

				loc_services_list.siblings('.locations-services-error').hide('slow', function() {
					$(this).remove();
				});
				new_value_el[0].value = '';
			}

			return false;
		}).on('keypress', '.locations-services-new', function(evt) {
			if (evt.keyCode === 13) {
				evt.preventDefault();
				add_location_services_button.trigger('click');
			}
		});

		suggestions_container.on('click', '.locations-services-suggestion', function(evt) {
			evt.preventDefault();
			add_new_entry(this.value);
			return false;
		});

		if (!ols_checkbox.length) { // || ols_checkbox.attr('disabled') || loc_services_list.children().length) {
			return;
		}

		// Handle dynamically showing hiding location services
		var my_table_row = loc_services_list.parents('tr').first(),
		on_ols_checkbox_clicked = function() {
			var self = $(this), other;
			if (this.checked) {
				my_table_row.show();
				if (self.data('maybeRequired')) {
					if (self.is('.ols-type-TOPIC,.ols-type-SERVICE')) {
						if (self.is('.ols-type-TOPIC')) {
							other = $('.ols-type-SERVICE');
						} else {
							other = $('.ols-type-TOPIC');
						}

						if (other.prop('checked')) {
							if (other.prop('disabled')) {
								other.prop('disabled', false);
								$('#OLS_ID_' + other.prop('value') + '_forceon').remove();
							}
							if (this.disabled) {
								this.disabled = false;
								$('#OLS_ID_' + this.value + '_forceon').remove();
							}
						} else {
							if (!this.disabled) {
								this.disabled = true;
								self.parent().after($('<input type="hidden" name="OLS_ID" id="OLS_ID_' + this.value + '_forceon" value="' + this.value + '">'));
							}
						}
					} else {
						if (!this.disabled) {
							this.disabled = true;
							self.parent().after($('<input type="hidden" name="OLS_ID" id="OLS_ID_' + this.value + '_forceon" value="' + this.value + '">'));
						}
					}
				}
			} else {
				if (self.is('.ols-type-SITE')) {
					my_table_row.hide();
				} else if (!$( self.is('.ols-type-SERVICE') ? '.ols-type-TOPIC' : '.ols-type-SERVICE').prop('checked')) {
					my_table_row.hide();
				}
				if (self.data('maybeRequired')) {
					if (self.is('.ols-type-TOPIC,.ols-type-SERVICE')) {
						this.disabled = false;
						if (self.is('.ols-type-TOPIC')) {
							other = $('.ols-type-SERVICE');
						} else {
							other = $('.ols-type-TOPIC');
						}
						if (other.prop('checked')) {
							var value = other.prop('value');
							if (!other.prop('disabled')) {
								other.prop('disabled', 'true');
								other.parent().after($('<input type="hidden" name="OLS_ID" id="OLS_ID_' + value + '_forceon" value="' + value + '">'));
							}
						} else {
							$('#ols-type-SERVICE-warning').show();
						}
					}
				}
			}
		};
		ols_checkbox.click(on_ols_checkbox_clicked);
		setTimeout(function() {
			ols_checkbox.each(function(i, el) {
				on_ols_checkbox_clicked.call(el);
			});
		}, 1);

	};

	$('.locations-services-list').each(function() {
		var self = $(this), field_name = self.data('fieldName'), needs_ols_type = self.data('needsOlsType');
		create_locations_services_widget(self, field_name, needs_ols_type);
	});
};

if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement, fromIndex) {
      if ( this === undefined || this === null ) {
        throw new TypeError( '"this" is null or not defined' );
      }

      var length = this.length >>> 0; // Hack to convert object.length to a UInt32

      fromIndex = +fromIndex || 0;

      if (Math.abs(fromIndex) === Infinity) {
        fromIndex = 0;
      }

      if (fromIndex < 0) {
        fromIndex += length;
        if (fromIndex < 0) {
          fromIndex = 0;
        }
      }

      for (;fromIndex < length; fromIndex++) {
        if (this[fromIndex] === searchElement) {
          return fromIndex;
        }
      }

      return -1;
    };
}

window['init_name_editable_toggle'] = function(defaults) {
	var org_num=$('#ORG_NUM'), display_org_name=$('#DISPLAY_ORG_NAME');
	var check_disable_org_names = function() {
		if ((org_num.length && !org_num.val()) || (!org_num.length && !defaults.org_num)) {
			display_org_name.prop('disabled', true);
			return false;
		}
		display_org_name.prop('disabled', false);
		return (display_org_name.length && display_org_name.prop('checked')) || (!display_org_name.length && defaults.display_org_name);
	};
	var disable_other = function(targets) {
		return function(toggle_trigger) {
			var not_display_org_name = toggle_trigger.not('#DISPLAY_ORG_NAME');

			var checked_triggers = not_display_org_name.filter(':checked');
			if (!not_display_org_name.length) {
				checked_triggers = $.map(targets, function(val) { return defaults[val] ? val : null; });
			}
			if (!checked_triggers.length) {
				return true;
			}

			if (not_display_org_name.length) {
				if (checked_triggers.is(':not(.ols-type-TOPIC)')) {
					return false;
				}
			} else {
				if ($.map(checked_triggers, function(val) { return val === 'TOPIC' ? null: val; }).length) {
					return false;
				}
			}
			
			// only ols-type-TOPIC disable if not display org name
			var retval = !check_disable_org_names();
			return retval;
		};
	};
	var after_location_site_names = function() {
		var first=true,
		after_disable_function = function(disabled, toggle_items) {
			if (first) {
				toggle_items.each(function() {
					var self = $(this);
					self.data('was_required', self.hasClass('require-group'));
				});
				first = false;
			}

			toggle_items.each(function() {
				var self = $(this);
				if (self.data('was_required')) {
					var parent = self.parents('td[data-field-display-name]');
					if (disabled) {
						remove_required_group(parent);
					} else {
						make_required_group(parent);
					}
				}
			});
		};
		return after_disable_function;
	};
	var register_toggle_events = function(toggle_trigger, toggle_items, check_fn, after_fn) {
		var toggle;

		toggle_trigger = $(toggle_trigger);
		toggle_items = $(toggle_items);
		toggle = function() {
			var disabled = check_fn(toggle_trigger);
			toggle_items.prop('disabled', disabled);
			if (after_fn) {
				after_fn(disabled, toggle_items);
			}
		},
		toggle_trigger.on('click keyup change', toggle);
		toggle();
	};

	register_toggle_events('#DISPLAY_ORG_NAME,#ORG_NUM', '#ORG_LEVEL_1,#ORG_LEVEL_2,#ORG_LEVEL_3,#ORG_LEVEL_4,#ORG_LEVEL_5', check_disable_org_names);
	register_toggle_events('.ols-type-SITE', '#LOCATION_NAME', disable_other(['SITE']), after_location_site_names());
	register_toggle_events('.ols-type-SERVICE,.ols-type-TOPIC,#DISPLAY_ORG_NAME', '#SERVICE_NAME_LEVEL_1,#SERVICE_NAME_LEVEL_2', disable_other(['SERVICE','TOPIC']), after_location_site_names());

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

jQuery(function($) {
	var source = ['AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT' ]
	$('.Province').combobox({source: source});
	window['cioc_province_source'] = source;
});

