<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="elenco_stampe_segrcons.aspx.cs" 
         Title="Stampe della Segreteria del Consiglio" 
         Inherits="stampe_elenco_stampe_segrcons" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <b>Report della Segreteria del Consiglio</b>
    
	<ul>
	    <li>
		    <asp:HyperLink ID="HyperLink01" 
		                   runat="server" 
		                   NavigateUrl="~/stampe/report_segrcons_presenze_sedute.aspx">
		        Report Presenze alle Sedute
		    </asp:HyperLink>
	    </li>
	    
	    <li>
		    <asp:HyperLink ID="HyperLink02" 
		                   runat="server" 
		                   NavigateUrl="~/stampe/report_segrcons_presenze_legislature.aspx">
		        Report Presenze in Legislatura
		    </asp:HyperLink>
	    </li>
	    
	    <li>
		    <asp:HyperLink ID="HyperLink03" 
		                   runat="server" 
		                   NavigateUrl="~/stampe/report_segrcons_presenze_legislature_gruppo.aspx">
		        Report Presenze in Legislatura per Gruppo Consiliare
		    </asp:HyperLink>
	    </li>
	    
	    <li>
		    <asp:HyperLink ID="HyperLink04" 
		                   runat="server" 
		                   NavigateUrl="~/stampe/report_segrcons_assenze_congedi.aspx">
		        Report Assenze e Congedi
		    </asp:HyperLink>
	    </li>
	</ul>
</div>
</asp:Content>