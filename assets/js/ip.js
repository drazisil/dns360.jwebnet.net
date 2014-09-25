/**
 * Created by joseph on 9/24/2014.
 */
function doArin() {
    var arinIP = document.getElementById('arinIP').value;
    var queryString = 'backend/doArin.php?host=' + arinIP;

    $.get(queryString, function (data) {
        document.getElementById('arinResults').innerHTML = '<pre>' + data + '</pre>';
    });
    return false;
}
