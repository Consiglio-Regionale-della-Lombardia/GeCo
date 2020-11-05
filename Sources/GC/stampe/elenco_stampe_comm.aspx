<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="elenco_stampe_comm.aspx.cs" 
         Inherits="stampe_elenco_stampe_comm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <b>
        Elenco Stampe
    </b>
    
    <ul>
        <li>
	        <asp:HyperLink ID="HyperLink1" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_numero.aspx">
	            Numero di Sedute
	        </asp:HyperLink>
        </li>
        
        <li>
	        <asp:HyperLink ID="HyperLink2" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_durate.aspx">
	            Durata delle Sedute
	        </asp:HyperLink>
        </li>
        
        <li>
	        <asp:HyperLink ID="HyperLink3" 
	                       runat="server" 
	                       NavigateUrl="~/stampe/sedute_pres_eff.aspx">
	            Presenze Effettive
	        </asp:HyperLink>
        </li>
        
        <% if (Session.IsVisible_IncExtraCost()) { %>
        <br />
	    
	    <li>
		    <asp:HyperLink ID="HyperLink10" 
		                   runat="server" 
		                   NavigateUrl="~/stampe/report_incarichi_extra.aspx">
		        Incarichi Extra Istituzionali (schede)
		    </asp:HyperLink>
	    </li>
	    
	    <li>
		    <asp:HyperLink ID="HyperLink11" 
		                   runat="server" 
		                   NavigateUrl="~/stampe/report_incarichi_extra_incarichi.aspx">
		        Incarichi Extra Istituzionali (incarichi)
		    </asp:HyperLink>
	    </li>
	    <% } %>
    </ul>
</div>
</asp:Content>