                <script type="text/javascript">
                    function dowhois_2()
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
                                    document.form_2.res_2.value=xmlHttp.responseText;
                                }
                        }
                        moo2 = document.getElementById("domain_2").value;
                        foo2 = document.getElementById("fgtld_2").value;
                    
                        xmlHttp.open("GET","dowhodig.php?host="+moo2+"&fgtld="+foo2+"&type=whodig"+"&Now="+Date(),true);
                        xmlHttp.send(null);
                        return false;
                    }
                    function doclear_2() {
                        document.form_2.res_2.value="";
                        return false;
                    }
                </script>
                   <div style="margin-bottom: 5px;">
				   WHOIS is a database that contains information on each registered domain name. 
				   This information includes the registrant&#39;s contact information, 
				   the administrative and technical contacts, the domain name servers, the creation, 
				   expiration, and last updated dates.
				   This information is useful when checking that the domain exists, and that the records
				   for the name servers (DNS) have not recently changed or expired.
				   </div>
				   <div>
				   DIG is a Unix-based program that allows users to learn information from a DNS site. 
				   This is helpful for locating A, NS and MX DNS records and making sure there are no issues.
				   </div>
                   <form name="form_2" action="" onSubmit="dowhois_2();return false;">
                    <table border="0" cellspacing="0" cellpadding="2">
                    <tr>
                    <td>Domain Name</td>
                    <td><input id="domain_2" name="domain_2" type="text" value=""></td>
                    </tr>
                    <tr>
                    <td valign="top">DNS Server</td>
                    <td><input id="fgtld_2" name="fgtld_2" type="text" value="ns1.rr.com"> (can be left as is)</td>
                    </tr>
                    <tr>
                    <td><input name="whodig_2" type="submit" value="Whois + Dig"></td>
                    <td><input name="clear_2" onclick="doclear_2();" type="button" value="Clear"></td>
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
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                        <p><a class="big" href="#top"><span>&nbsp;&uarr;</span></a>
                    </td>
                    <td><textarea id="res_2" name="res_2" rows="120" cols="100"></textarea></td>
                    </tr>
                    </table>
                    </form>
