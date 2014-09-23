var dns360_form_urls = {};

dns360_form_urls = {
    "formWhois": "backend/dowhodig.php?"
};


var dns360_form_fields = {};

dns360_form_fields.formWhois = {
    "host": "domainNameWhois"
};

function doTab(tabId, resultId) {

    //alert(Object.keys(dns360_form_fields[tabId]).length);

    var queryString = '';

    jQuery.each(Object.keys(dns360_form_fields[tabId]), function(i, val) {
        queryString += "&" + val + "=" + $(eval(dns360_form_fields[tabId][val])).val();
    });

    var ajaxUrl = dns360_form_urls[tabId] + queryString.substring(1);

    //alert(ajaxUrl);

    $.get(ajaxUrl, function(data) {
        $(eval(resultId)).val(data);
    });

    return false;
}


