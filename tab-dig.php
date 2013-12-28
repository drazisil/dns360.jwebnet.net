                <script type="text/javascript">
                    function dodig_3()
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
                                    document.form_3.res_3.value=xmlHttp.responseText;
                                }
                        }
                        moo3 = document.getElementById("host_3").value;
                        type3 = document.getElementById("type_3").value;
                        foo3 = document.getElementById("fgtld_3").value;
              	   	d = new Date();
                        xmlHttp.open("GET","cgi-bin/dig.cgi?host="+moo3+"&type="+type3+"&fgtld="+foo3+"&Now="+d.getTime,true);
                        xmlHttp.send(null);
                        return false;
                    }
                    function doclear_3() {
                        document.form_3.res_3.value="";
                        return false;
                    }
                </script>
				   <div>
				   DIG is a Unix-based program that allows users to learn information from a DNS site. 
				   This is helpful for locating A, NS and MX DNS records and making sure there are no issues.
				   </div>
                <form name="form_3" action="" onSubmit="dodig_3();return false;">
                <table border="0" cellspacing="0" cellpadding="2">
                <tr>
                <td>Host to Dig</td>
                <td><input id="host_3" name="host_3" type="text" value=""><select id="type_3" name="type_3">
                	<option value="any">ANY</option>
                	<option value="mx">MX</option>
                	<option value="all">ANY</option>
                	<option value="a">A</option>
                	<option value="cname">CNAME</option>
                </select></td>
                </tr>
                <tr>
                <td valign="top">DNS Server</td>
                <td><input id="fgtld_3" name="fgtld_3" type="text" value="localhost"> (this can be left as is)</td>
                </tr>
                <tr>
                <td><input name="dig_3" type="submit" value="Dig"></td>
                <td><input name="clear_3" onclick="doclear_3();" type="button" value="Clear"></td>
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
                    </td>
                <td><textarea id="res_3" name="res_3" rows="50" cols="100"></textarea></td>
                </tr>
                </table>
                </form>