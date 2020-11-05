<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="elenco_sedute.aspx.cs" 
         Inherits="stampe_elenco_sedute" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <b>Accesso a report sulle sedute</b>
    <ul>
        <li>
	        <asp:HyperLink ID="HyperLink1" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_numero.aspx">
	            Numero di sedute
	        </asp:HyperLink>
        </li>
        
        <li>
	        <asp:HyperLink ID="HyperLink3" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_durate.aspx">
	            Durata delle sedute
	        </asp:HyperLink>
        </li>
    </ul>
    
    <div align="right">
        <b>
            <asp:HyperLink ID="HyperLink2" 
                           runat="server" 
                           NavigateUrl="~/organi/dettaglio.aspx">
            « Indietro
            </asp:HyperLink>
        </b>
    </div>

</div>
</asp:Content>