/**
 * Created by joseph on 9/24/2014.
 */
function doArin() {
    var queryString = 'backend/doArin.php?host=' + $("#inIPAddress").val();

    $.get(queryString, function (data) {
        $("#res_6").html(data);
    });
    return false;
}
