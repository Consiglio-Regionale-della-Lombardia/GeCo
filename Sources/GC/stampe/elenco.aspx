<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MasterPage.master" CodeFile="elenco.aspx.cs" Inherits="stampe_elenco" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	
        <b>Accesso a stampe di carattere generale</b>
	<ul>
	    <li>
		<asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/stampe/consiglieri_residenze.aspx">Consiglieri + residenze</asp:HyperLink>
	    </li>
	    <li>
		<asp:HyperLink ID="HyperLink3" runat="server" NavigateUrl="~/stampe/consiglieri_gruppi.aspx">Consiglieri + gruppi di appartenenza</asp:HyperLink>
	    </li>
	    <li>
		<asp:HyperLink ID="HyperLink4" runat="server" NavigateUrl="~/stampe/consiglieri_recapiti.aspx">Consiglieri + recapiti</asp:HyperLink>
	    </li>
	    <li>
		<asp:HyperLink ID="HyperLink5" runat="server" NavigateUrl="~/stampe/consiglieri_cariche.aspx">Consiglieri + cariche</asp:HyperLink>
	    </li>
	    <li>
		<asp:HyperLink ID="HyperLink6" runat="server" NavigateUrl="~/stampe/consiglieri_nascita.aspx">Consiglieri + dati nascita</asp:HyperLink>
	    </li>
	    <li>
		<asp:HyperLink ID="HyperLink7" runat="server" NavigateUrl="~/stampe/consiglieri_elezione.aspx">Consiglieri + dati elezione</asp:HyperLink>
	    </li>
	</ul>
	<div align="right">
	    <b><asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="~/persona/persona.aspx">« Indietro</asp:HyperLink></b>
	</div>
	
    </div>
</asp:Content>