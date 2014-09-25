/**
 * Created by joseph on 9/25/2014.
 */

function doDig() {
    var queryString = 'cgi-bin/dig.cgi?host=' + $("#digHost").val() + '&type=' + $("#digType").val() + '&fgtld=' + $("#digServer").val() + "&Now=" + new Date().getTime;

    $.get(queryString, function (data) {
        $("#digResults").html('<pre>' + data + '</pre>');
    });
    return false;
}