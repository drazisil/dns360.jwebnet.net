                <script type="text/javascript">
                    function dowhois_1()
                    {
                        var xmlHttp;
                        try
                        {  // Firefox, Opera 8.0+, Safari
                            xmlHttp=new XMLHttpRequest();
                        }
                        catch (e)
                        {  
                            // Internet Explorer
                            try
                            {
                                xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
                            }
                            catch (e)
                            {
                                try
                                {
                                    xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
                                }
                                catch (e)
                                {
                                    alert("Your browser does not support AJAX!");
                                    return false;
                                }
                            }
                        }
                        xmlHttp.onreadystatechange=function() {
                                if(xmlHttp.readyState==4)
                                {
                                    document.form_1.res_1.value=xmlHttp.responseText;
                                }
                        }
                        moo1 = document.getElementById("domain_1").value;
                    
                        xmlHttp.open("GET","dowhodig.php?host="+moo1+"&Now="+Date(),true);
                        xmlHttp.send(null);
                        return false;
                    }
                    function doclear_1() {
                        document.form_1.res_1.value="";
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
				   <form name="form_1" action="" onsubmit="dowhois_1();return false;">
                    <table border="0" cellspacing="0" cellpadding="2">
                    <tr>
                    <td></td>
                    <td></td>
                    </tr>
                    <tr>
                    <td>Domain Name</td>
                    <td><input id="domain_1" name="domain_1" type="text" value=""></td>
                    </tr>
                    <tr>
                    <td><input name="whois_1" type="submit" value="Whois"></td>
                    <td><input name="clear_1" onclick="doclear_1();" type="button" value="Clear"></td>
                    </tr>
                    <tr>
                    <td>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                    </td>
                    <td><textarea id="res_1" name="res_1" rows="80" cols="100"></textarea></td>
                    </tr>
                    </table>
                    </form>
