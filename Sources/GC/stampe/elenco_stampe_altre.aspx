<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="elenco_stampe_altre.aspx.cs"
         Title="Altre Stampe"  
         Inherits="stampe_elenco" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <b>Accesso a stampe di carattere generale</b>
    <ul>
        <li>
	    <asp:HyperLink ID="HyperLink_cons_gruppi"
	                   runat="server" 
	                   NavigateUrl="~/stampe/consiglieri_gruppi.aspx">
	        Consiglieri + gruppi di appartenenza
	    </asp:HyperLink>
        </li>
               
        <li>        
	        <asp:HyperLink ID="HyperLink_cons_cariche" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/consiglieri_cariche.aspx">
	            Consiglieri + cariche
	        </asp:HyperLink>
        </li>
        
        <li>
	    <asp:HyperLink ID="HyperLink_cons_elezione" 
	    runat="server" 
	    NavigateUrl="~/stampe/consiglieri_elezione.aspx">
	    Consiglieri + dati elezione
	    </asp:HyperLink>		
        </li>
    </ul>
    
    <div align="right">
        <b>
        <asp:HyperLink ID="HyperLink_back" 
                       runat="server" 
                       NavigateUrl="~/persona/persona.aspx">
        « Indietro
        </asp:HyperLink></b>
    </div>
</div>
</asp:Content>