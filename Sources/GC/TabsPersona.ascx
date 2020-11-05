<%@ Control Language="C#" AutoEventWireup="true" CodeFile="TabsPersona.ascx.cs" Inherits="TabsPersona" %>
<div>
    <input type="hidden" id="hidSelection" runat="server" />
    <ul>
        <li><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
        <li><a id="a_gruppi_politici" runat="server" >GRUPPI POL.</a></li>
        <li><a id="a_cariche" runat="server" >CARICHE</a></li>
        <li><a id="a_sospensioni" runat="server" >SOSPENS.</a></li>
        <li><a id="a_sostituzioni" runat="server" >SOSTITUZ.</a></li>
        <li><a id="a_missioni" runat="server" >MISSIONI</a></li>
        <li><a id="a_certificati" runat="server" >CERTIFICATI</a></li>
        <li><a id="a_aspettative" runat="server" >ASPETT.</a></li>
        <li><a id="a_risultati_elettorali" runat="server" >RIS.ELETT.</a></li>
        <li><a id="a_pratiche" runat="server" >PRATICHE</a></li>
        <li><a id="a_trasparenza" runat="server" >TRASPARENZA</a></li>
        <li><a id="a_presenze_assenze" runat="server" >PRES./ASS.</a></li>
        <li><a id="a_varie" runat="server" >VARIE</a></li>
        <li><a id="a_incarichi_extra_istituzionali" runat="server" >INC.EXTRA-IST.</a></li>
    </ul>

    <script type="text/javascript">
        $(document).ready(function () {
            try
            {

                var sel = $("input[id$='_hidSelection']").val();
                //alert('sel: ' + sel);

                var elem = $("[id$='_" + sel + "']");
                //alert('elem: ' + elem.html());

                var parent = elem.parent();
                //alert('parent: ' + parent.html());
                //alert('parent id 1: ' + parent.attr("id"));

                parent.attr("id", "selected");
                //alert('parent id 2: ' + parent.attr("id"));
            }
            catch(e)
            {
                alert(e.message);
            }
        });
    </script>
</div>
