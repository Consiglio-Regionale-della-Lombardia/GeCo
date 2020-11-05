<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MasterPage.master" CodeFile="consiglieri_recapiti.aspx.cs" Inherits="stampe_consiglieri_recapiti" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	
        <b>Stampa di tutti i consiglieri con recapiti</b>
	<br />
	<br />
	<div align="center">
	    <asp:GridView ID="GridView1" runat="server" AllowSorting="True" 
		AutoGenerateColumns="False" CssClass="tab_gen" DataSourceID="SqlDataSource1">
		<Columns>
		    <asp:BoundField DataField="cognome" HeaderText="Cognome" 
			SortExpression="cognome" ItemStyle-HorizontalAlign="left"/>
		    <asp:BoundField DataField="nome" HeaderText="Nome" SortExpression="nome" ItemStyle-HorizontalAlign="left"/>
		    <asp:BoundField DataField="telefono" HeaderText="Telefono" 
			SortExpression="telefono" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		    <asp:BoundField DataField="email" HeaderText="Email" SortExpression="email" ItemStyle-HorizontalAlign="left"/>
		    <asp:BoundField DataField="fax" HeaderText="Fax" SortExpression="fax" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		</Columns>
	    </asp:GridView>

	    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
		ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		SelectCommand="SELECT persona.cognome, persona.nome, join_persona_recapiti_1.recapito AS telefono, join_persona_recapiti_2.recapito AS email, join_persona_recapiti_3.recapito AS fax FROM persona LEFT OUTER JOIN join_persona_recapiti AS join_persona_recapiti_1 ON persona.id_persona = join_persona_recapiti_1.id_persona AND join_persona_recapiti_1.tipo_recapito = 'T1' LEFT OUTER JOIN join_persona_recapiti AS join_persona_recapiti_2 ON persona.id_persona = join_persona_recapiti_2.id_persona AND join_persona_recapiti_2.tipo_recapito = 'E1' LEFT OUTER JOIN join_persona_recapiti AS join_persona_recapiti_3 ON persona.id_persona = join_persona_recapiti_3.id_persona AND join_persona_recapiti_3.tipo_recapito = 'F1'">
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