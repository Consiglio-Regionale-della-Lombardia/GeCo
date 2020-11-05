<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MasterPage.master" CodeFile="consiglieri_nascita.aspx.cs" Inherits="stampe_consiglieri_nascita" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	
        <b>Stampa di tutti i consiglieri con data di nascita</b>
	<br />
	<br />
	<div align="center">
	    <asp:GridView ID="GridView1" runat="server" AllowSorting="True" 
		AutoGenerateColumns="False" CssClass="tab_gen" DataSourceID="SqlDataSource1">
		<Columns>
		    <asp:BoundField DataField="cognome" HeaderText="Cognome" 
			SortExpression="cognome" ItemStyle-HorizontalAlign="left"/>
		    <asp:BoundField DataField="nome" HeaderText="Nome" SortExpression="nome" ItemStyle-HorizontalAlign="left"/>
		    <asp:BoundField DataField="data_nascita" HeaderText="Data di nascita" 
			SortExpression="data_nascita" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		    <asp:BoundField DataField="comune" HeaderText="Comune" 
			SortExpression="comune" ItemStyle-HorizontalAlign="left"/>
		    <asp:BoundField DataField="provincia" HeaderText="Provincia" 
			SortExpression="provincia" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		    <asp:BoundField DataField="cap_nascita" HeaderText="CAP" 
			SortExpression="cap_nascita" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		</Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
		ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		SelectCommand="SELECT persona.cognome, persona.nome, persona.data_nascita, tbl_comuni.comune, tbl_comuni.provincia, persona.cap_nascita FROM persona INNER JOIN tbl_comuni ON persona.id_comune_nascita = tbl_comuni.id_comune">
	    </asp:SqlDataSource>
	
	</div>
	<br />
	<div align="right">
	    <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click"><img src="../img/page_white_excel.png" alt="" align="top" /> Esporta</asp:LinkButton>
	    -
	    <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click"><img src="../img/page_white_acrobat.png" alt="" align="top" /> Esporta</asp:LinkButton>
	</div>
	
    </div>
</asp:Content>
