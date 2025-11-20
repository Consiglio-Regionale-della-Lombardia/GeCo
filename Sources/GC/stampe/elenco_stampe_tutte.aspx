<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="elenco_stampe_tutte.aspx.cs" 
         Title="Stampe Generali" 
         Inherits="stampe_elenco" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
	
    <b>Report di carattere generale</b>
    
	<ul>
	    <li>
		<asp:HyperLink ID="HyperLink01" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_consiglieri_dati_anagrafici.aspx">
		    Report Consiglieri (Dati Anagrafici)
		</asp:HyperLink>
	    </li>
	    
	    <li>
		<asp:HyperLink ID="HyperLink02" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_consiglieri_cariche_ricoperte.aspx">
		    Report Consiglieri (Cariche Ricoperte)
		</asp:HyperLink>
	    </li>
	    
	    <li>
		<asp:HyperLink ID="HyperLink03" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_consiglieri_dati_elettorali.aspx">
		    Report Consiglieri (Dati Elettorali)
		</asp:HyperLink>
	    </li>
	    
	    <li>
		<asp:HyperLink ID="HyperLink04" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_consiglieri_sospesi.aspx">
		    Report Consiglieri Dimessi o Sospesi
		</asp:HyperLink>
	    </li>
	    
	    <li>
		<asp:HyperLink ID="HyperLink13" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_consiglieri_sostituiti.aspx">
		    Report Consiglieri Sostituiti
		</asp:HyperLink>
	    </li>
	      	    
	    
	    <br />
	    
	    <li>	    
		<asp:HyperLink ID="HyperLink05" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_gruppi_consiliari.aspx">
		    Report Gruppi Consiliari
		</asp:HyperLink>
	    </li>
	    
	    <li>	    
		<asp:HyperLink ID="HyperLink06" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_elenco_gruppi_consiliari.aspx">
		    Report Elenco Gruppi Consiliari
		</asp:HyperLink>
	    </li>
	    

	    
	    <br />
	    
	    <li>	    
		<asp:HyperLink ID="HyperLink07" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_cariche.aspx">
		    Report Cariche
		</asp:HyperLink>
	    </li>
	    
	    <br />
	    
	    <li>
		<asp:HyperLink ID="HyperLink08" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_aspettative.aspx">
		    Report Aspettative
		</asp:HyperLink>
	    </li>
	    
	    <br />

        <% if (Session.IsVisible_IncExtraCost()) { %>	    
	    <li>
		<asp:HyperLink ID="HyperLink10" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_incarichi_extra.aspx">
		    Report Incarichi Extra Istituzionali (schede)
		</asp:HyperLink>
	    </li>
	    
	    <li>
		<asp:HyperLink ID="HyperLink11" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_incarichi_extra_incarichi.aspx">
		    Report Incarichi Extra Istituzionali (incarichi)
		</asp:HyperLink>
	    </li>
	    <% } %>

	    <br />
	    <br />
	    
	    <li>
		<asp:HyperLink ID="HyperLink09" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_non_consiglieri_dati_anagrafici.aspx" >		               
		    Report Non Consiglieri (Dati Anagrafici)
		</asp:HyperLink>
	    </li>

	    <br />    
	    <li>
		<asp:HyperLink ID="HyperLink12" 
		               runat="server" 
		               NavigateUrl="~/stampe/report_assessori_dati_anagrafici.aspx" >		               
		    Report Assessori (Dati Anagrafici)
		</asp:HyperLink>
	    </li>
	</ul>
</div>
</asp:Content>