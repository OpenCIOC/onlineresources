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
			container.find('.repeat-week-of-month-ui, .repeats-on-ui, .recurs-month-label').show();
			container.find('.repeat-every-ui, .repeat-day-of-month-ui, .recurs-week-label').hide();

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

(function() {

var $ = jQuery;
var add_new_community = function(chkid, display) {
	$('#CM_existing_add_table').
		removeClass('NotVisible').
		append($('<tr>').
			append($('<td>').
				append($('<input>').
					prop({
						id: 'CM_ID_' + chkid,
						type: 'checkbox',
						checked: true,
						defaultChecked: true,
						name: 'CM_ID',
						value: chkid
						})
				)
			).
			append($('<td>').
				addClass('FieldLabelLeftClr').
				append(document.createTextNode(' ' + display))
			).
			append($('<td>').
				prop('align', 'center').
				append($('<input>').
					prop({
						id: 'CM_NUM_NEEDED_' + chkid,
						name: 'CM_NUM_NEEDED_' + chkid,
						size: 3,
						maxlength: 3
						})
				)
			)
		);
};
var init_num_needed = function(txt_not_found){
	init_autocomplete_checklist($, {
		field: 'CM',
		source: entryform.community_complete_url,
		add_new_html: add_new_community,
		minLength: 3,
		txt_not_found: txt_not_found
		});
};
window['init_num_needed'] = init_num_needed;

var init_interests = function(txt_not_found) {
	var added_values = [];
	var add_item_fn = only_items_chk_add_html($, 'AI');
	init_autocomplete_checklist($, {field: 'AI',
			source: entryform.interest_complete_url,
			add_new_html: add_item_fn,
			added_values: added_values,
			txt_not_found: txt_not_found
	});

	var interest_group;
	var update_interest_list = function (data) {
		var ai_list_old = $("#AreaOfInterestList");
		if (ai_list_old.length) {
			ai_list_old.prop('id', 'AreaOfInterestListOld');

		}
		var ai_list = $('<ul>').hide().
			insertAfter(interest_group).
			prop('id', 'AreaOfInterestList').
			append($($.map(data, function(item, index) {
					var el =  $('<li>').append(
						$('<input>').
							prop({
							type: 'checkbox',
							value: item.chkid
								}).
							data('cioc_chk_display', item.value)
						).
						append(document.createTextNode(' ' + item.value))[0];
					return el;
					})));


		ai_list.show('slow');
		if (ai_list_old.length) {
			ai_list_old.hide('slow', function ()
						{
							ai_list_old.remove();
						});
		}


	};
	interest_group = $('#InterestGroup').
		change(function() {
			$.getJSON(entryform.interest_complete_url,
				{IGID: interest_group.prop('value')},
				update_interest_list);
		});


	$("#FIELD_INTERESTS").next().on('click', "#AreaOfInterestList input:checkbox",
		{added_values: added_values, add_item_fn: add_item_fn}, function (event) {
			var me = $(this);
			var existing_chk = document.getElementById('AI_ID_' + this.value);
			if (existing_chk) {
				existing_chk.checked = true;
			} else {

				var display = me.data('cioc_chk_display');

				event.data.added_values.push({chkid: this.value, display: display});
				event.data.add_item_fn(this.value, display);
			}

			me.parent().hide('slow',function () { me.remove(); });

		});
};
window['init_interests'] = init_interests;

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

