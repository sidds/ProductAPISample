
// Posts JSON via AJAX
$.postJSON = function (url, data, callback) {
    $.ajax({
        'url': url,
        'type': 'post',
        'processData': false,
        'data': JSON.stringify(data),
        contentType: 'application/json',
        success: function (data) { if (null != callback) { callback(data); } }
    });
};

function GetTabString(tabLevel) {
    var returnString = '';
    for (i = 0; i < tabLevel; i++) {
        returnString += '\t';
    }
    return returnString;
};

// HACK: perhaps this should use encodeUriComponent()
function htmlEncode(value) {
    if (value) {
        return $('<div/>').text(value).html();
    } else {
        return '';
    }
}

// HACK: perhaps this should use decodeUriComponent()
function htmlDecode(value) {
    return $('<div/>').html(value).text();
} 

$.printableJSON = function (JSONObject, tabLevel) {
    var printString = "";
    if (null == JSONObject) {
        return printString;
    }
    if (typeof JSONObject == 'object') {
        printString += "{ \n";
        $.each(JSONObject, function (key, value) {
            printString += GetTabString(tabLevel) + key + ":\t" + $.printableJSON(value, tabLevel + 1) + "\n";
        });
        printString += GetTabString(tabLevel) + " } \n";
    }
    else {
        printString += JSONObject;
    }
    return printString;
};

function GetHTMLTabString(tabLevel) {
    var returnString = '';
    for (i = 0; i < tabLevel; i++) {
        returnString += '&nbsp;';
    }
    return returnString;
};

$.printJSONToHTML = function (JSONObject, tabLevel) {
    var printString = "";
    if (null == JSONObject) {
        return printString;
    }
    if (typeof JSONObject == 'object') {
        printString += "{ <br/>";
        $.each(JSONObject, function (key, value) {
            printString += GetHTMLTabString(tabLevel) + key + ":&nbsp;" + $.printJSONToHTML(value, tabLevel + 1) + "<br/>";
        });
        printString += GetHTMLTabString(tabLevel) + " } <br/>";
    }
    else {
	var tmpString = '' + JSONObject;
        printString += tmpString.replace(/<\/?[^>]+>/gi, '');
    }
    return printString;
};



