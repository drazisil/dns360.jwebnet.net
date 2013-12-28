                <script type="text/javascript">
                    function doarin_6()
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
                                    document.form_6.res_6.value=xmlHttp.responseText;
                                }
                        }
                        moo6 = document.getElementById("domain_6").value;
                    
                        xmlHttp.open("GET","doarin.php?host="+moo6+"&Now="+Date(),true);
                        xmlHttp.send(null);
                        return false;
                    }
                    function doclear_6() {
                        document.form_6.res_6.value="";
                        return false;
                    }
                </script>
                   <div>
				   American Registry for Internet Numbers (ARIN) is a non-profit registry responsible for the 
				   administration and registration of Internet Protocol (IP) numbers in North and South America, 
				   South Africa, the Caribbean and all other regions administered currently managed by 
				   Network Solutions, Inc. This lookup will tell you who controls the block of IP addresses.
				   </div>
				   <form name="form_6" action="" onSubmit="doarin_6();return false;">
                    <table border="0" cellspacing="0" cellpadding="2">
                    <tr>
                    <td></td>
                    <td></td>
                    </tr>
                    <tr>
                    <td>IP Address</td>
                    <td><input id="domain_6" name="domain_6" type="text" value=""></td>
                    </tr>
                    <tr>
                    <td><input name="whois_6" type="submit" value="ARIN Lookup"></td>
                    <td><input name="clear_6" onclick="doclear_6();" type="button" value="Clear"></td>
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
                    <td><textarea id="res_6" name="res_6" rows="80" cols="100"></textarea></td>
                    </tr>
                    </table>
                    </form>
