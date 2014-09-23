/**
 * Created by joseph on 9/23/2014.
 */

var dns360_form_fields = {};

dns360_form_fields.formWhois = {
    "host": "domainNameWhois"
};

function doWhois() {
    var queryString = 'backend/dowhodig.php?host=' + $("#domainNameWhois").val();

    $.get(queryString, function (data) {
        $("#res_1").html(data);
    });
    return false;
}