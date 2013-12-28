                <script type="text/javascript">
                    function doptr_4()
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
                                    document.form_4.res_4.value=xmlHttp.responseText;
                                }
                        }
                        moo4 = document.getElementById("host_4").value;
                    
                        xmlHttp.open("GET","/cgi-bin/ptr.cgi?host="+moo4,true);
                        xmlHttp.send(null);
                        return false;
                    }
                    function doclear_4() {
                        document.form_4.res_4.value="";
                        return false;
                    }
                </script>
                    <div>
					Pointer Record. Also called a reverse record. 
					A PTR record associates an IP address with a canonical name. 
					PTR records should point to a name that can be resolved back to the IP address.
					This is useful for trouble-shooting email and DNS issues.
					</div>
					<form name="form_4" action="" onSubmit="doptr_4();return false;">
                    <table border="0" cellspacing="0" cellpadding="2">
                    <tr>
                    <td></td>
                    <td></td>
                    </tr>
                    <tr>
                    <td>IP Address</td>
                    <td><input id="host_4" name="host_4" type="text" value=""></td>
                    </tr>
                    <tr>
                    <td><input name="ptr_4" type="submit" value="Lookup PTR"></td>
                    <td><input name="clear_4" onclick="doclear_4();" type="button" value="Clear"></td>
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
                    <td><textarea id="res_4" name="res_4" rows="50" cols="100"></textarea></td>
                    </tr>
                    </table>
                </form>
