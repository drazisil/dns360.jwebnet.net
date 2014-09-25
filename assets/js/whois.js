/**
 * Created by joseph on 9/23/2014.
 */

function doWhois() {
    var queryString = 'backend/doWho.php?host=' + $("#domainNameWhois").val();

    $.get(queryString, function (data) {
        $("#res_1").html(data);
    });
    return false;
}