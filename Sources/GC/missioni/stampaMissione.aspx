<%@ Page Language="C#" AutoEventWireup="true" CodeFile="stampaMissione.aspx.cs" Inherits="missioni_stampaMissione" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=9.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pagina senza titolo</title>
    <link href="../css/stampe.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
	<table cellpadding="20">
	    <tr>
		<td width="250" valign="top">
		    <img src="../img/printer.png" alt="" />
		    <b>Opzioni stampa</b>
		    <br />
		    <br />
		    <asp:CheckBox ID="CheckBox3" runat="server" />
		    Visualizza lista partecipanti
		    <br />
		    <br />
		    Visualizza per legislatura:
		    <br />
		    <asp:DropDownList ID="DropDownListLegislature" runat="server" DataSourceID="SqlDataSource5"
			DataTextField="num_legislatura" DataValueField="id_legislatura" Width="150px" AppendDataBoundItems="True">
			<asp:ListItem Text="(nessuna)" Value="" Selected="True" />
		    </asp:DropDownList>
		    <asp:Button ID="ButtonSetLegislatura" runat="server" Text="Aggiorna" OnClick="ButtonSetLegislatura_Click" />
		    <asp:SqlDataSource ID="SqlDataSource5" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
		    </asp:SqlDataSource>
		    <br />
		    <br />
		    Visualizza per città:
		    <br />
		    <asp:TextBox ID="TextBoxCitta" runat="server" Width="150px"></asp:TextBox>
		    <asp:Button ID="ButtonSetCitta" runat="server" Text="Aggiorna" OnClick="ButtonSetCitta_Click" />
		    <br />
		    <br />
		    Visualizza per anno:
		    <br />
		    <asp:DropDownList ID="DropDownListAnni" runat="server" DataSourceID="SqlDataSource1"
			DataTextField="anno" DataValueField="anno" Width="150px">
		    </asp:DropDownList>
		    <asp:Button ID="ButtonSetAnno" runat="server" Text="Aggiorna" OnClick="ButtonSetAnno_Click" />
		    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			SelectCommand="SELECT anno FROM tbl_anni WHERE (anno > YEAR(GETDATE()) - 25) AND (anno <= YEAR(GETDATE()))">
		    </asp:SqlDataSource>
		</td>
		<td width="600" style="border: 1px solid #666;">
		    <rsweb:ReportViewer ID="ReportViewer1" runat="server" Font-Names="Verdana" Font-Size="8pt"
			Height="500px" Width="100%">
			<LocalReport ReportPath="missioni\missioni.rdlc">
			    <DataSources>
				<rsweb:ReportDataSource DataSourceId="ObjectDataSource1" Name="anagrafica_missioni_missioni" />
			    </DataSources>
			</LocalReport>
		    </rsweb:ReportViewer>
		    <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" OldValuesParameterFormatString="original_{0}"
			SelectMethod="GetData" TypeName="anagrafica_missioniTableAdapters.missioniTableAdapter">
			<SelectParameters>
			    <asp:ControlParameter ControlID="DropDownListAnni" Name="id_leg" PropertyName="SelectedValue"
				Type="String" />
			    <asp:ControlParameter ControlID="TextBoxCitta" Name="citta" PropertyName="Text" Type="String" />
			    <asp:ControlParameter ControlID="DropDownListAnni" Name="anno" PropertyName="SelectedValue"
				Type="String" />
			    <asp:ControlParameter ControlID="CheckBox3" Name="showComp" PropertyName="Checked"
				Type="Boolean" />
			</SelectParameters>
		    </asp:ObjectDataSource>
		</td>
	    </tr>
	</table>
    </div>
    </form>
</body>
</html>
