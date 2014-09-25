/**
 * Created by joseph on 9/25/2014.
 */

function doPtr() {
    var ptrIP = document.getElementById('ptrIP').value;
    var queryString = 'cgi-bin/ptr.cgi?host=' + ptrIP;

    $.get(queryString, function (data) {
        document.getElementById('ptrResults').innerHTML = '<pre>' + data + '</pre>';
    });
    return false;
}