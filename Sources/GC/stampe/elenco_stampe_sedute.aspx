<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="elenco_stampe_sedute.aspx.cs"
         Title="Stampe Sedute"  
         Inherits="elenco_stampe_sedute" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <b>STAMPE SEDUTE</b>
    <ul>                
        <li>
	        <asp:HyperLink ID="HyperLink1" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_numero.aspx">
	            Sedute + numero
	        </asp:HyperLink>		
        </li>
        
        <li>
	        <asp:HyperLink ID="HyperLink2" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_durate.aspx">
	            Sedute + durate
	        </asp:HyperLink>		
        </li>
    </ul>
    
    <div align="right">
        <b>
            <asp:HyperLink ID="HyperLink3" 
                           runat="server" 
                           NavigateUrl="~/sedute/gestisciSedute.aspx">
            « Indietro
        </asp:HyperLink></b>
    </div>
</div>
</asp:Content>