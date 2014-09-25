/**
 * Created by joseph on 9/25/2014.
 */

function doDig() {

    var digHost = document.getElementById('digHost').value;
    var digType = document.getElementById('digType').value;
    var digServer = document.getElementById('digServer').value;
    var digTime = new Date().getTime;

    var queryString = 'cgi-bin/dig.cgi?host=' + digHost + '&type=' + digType + '&fgtld=' + digServer + "&Now=" + digTime;

    $.get(queryString, function (data) {
        document.getElementById('digResults').innerHTML = '<pre>' + data + '</pre>';
    });
    return false;
}