/**
 * Created by joseph on 9/23/2014.
 */

function doWhois() {
    var whoisHost = document.getElementById('whoisHost').value;
    var queryString = 'backend/doWho.php?host=' + whoisHost;

    $.get(queryString, function (data) {
        document.getElementById('whoisResults').innerHTML = '<pre>' + data + '</pre>';
    });
    return false;
}