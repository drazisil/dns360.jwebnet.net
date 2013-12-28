<script type="text/javascript">
    function dns360ajax(mode, url, inputId, result) {
        var xmlHttp;
        try
        {  // Firefox, Opera 8.0+, Safari
            xmlHttp = new XMLHttpRequest();
        }
        catch (e)
        {
            // Internet Explorer
            try
            {
                xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
            }
            catch (e)
            {
                try
                {
                    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
                }
                catch (e)
                {
                    alert("Your browser does not support AJAX!");
                    return false;
                }
            }
        }
        xmlHttp.onreadystatechange = function() {
            if (xmlHttp.readyState == 4)
            {
            resultText = "<pre>"+xmlHttp.responseText+"</pre>";    
            $(result).html(resultText);
            }
        }
        param1 = document.getElementById(inputId).value;

        xmlHttp.open(mode, url + param1 + "&Now=" + Date(), true);
        xmlHttp.send(null);
        return false;

    }
    function doclear_whois2() {
        document.form__whois2.res_whois2.value = "";
        return false;
    }
</script>
<div>
    WHOIS is a database that contains information on each registered domain name. 
    This information includes the registrant&#39;s contact information, 
    the administrative and technical contacts, the domain name servers, the creation, 
    expiration, and last updated dates.
    This information is useful when checking that the domain exists, and that the records
    for the name servers (DNS) have not recently changed or expired.
</div>
<form name="form_whois2" action="" onsubmit="
        dns360ajax('GET', 'dowhodig.php?host=', 'whois2input1', '#whoisData');
        return false;">
    <table border="0" cellspacing="0" cellpadding="2">
        <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Domain Name</td>
            <td><input id="whois2input1" name="whois2input1" type="text" value=""></td>
        </tr>
        <tr>
            <td><input name="whois_2" type="submit" value="Whois"></td>
        </tr>
    </table>
</form>
<div id="whoisData"></div>