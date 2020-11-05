<%@ Page Language="C#" AutoEventWireup="true" CodeFile="stampaGruppo.aspx.cs" Inherits="gruppi_politici_stampaGruppo" %>

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
		    <asp:CheckBox ID="CheckBox1" runat="server" Checked="True" />
		    Visualizza gruppi attivi
		    <br />
		    <asp:CheckBox ID="CheckBox2" runat="server" Checked="True" />
		    Visualizza gruppi inattivi
		    <br />
		    <br />
		    <asp:CheckBox ID="CheckBox3" runat="server" />
		    Visualizza lista componenti
		    <br />
		    <asp:CheckBox ID="CheckBox4" runat="server" />
		    Visualizza lista ex-componenti
		    <br />
		    <br />
		    Imposta data:
		    <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
		    <br />
		    <span style="font-size: 0.8em;">(lasciare vuoto per la data attuale)</span>
		    <br />
		    <br />
		    <asp:Button ID="Button2" runat="server" Text="Applica" OnClick="Button2_Click" />
		</td>
		<td width="600" style="border: 1px solid #666;">
		    <rsweb:ReportViewer ID="ReportViewer1" runat="server" Font-Names="Verdana" Font-Size="8pt"
			Height="500px" Width="100%">
			<LocalReport ReportPath="gruppi_politici\gruppi_politici.rdlc">
			    <DataSources>
				<rsweb:ReportDataSource DataSourceId="ObjectDataSource1" Name="anagrafica_gruppi_politici_gruppi" />
			    </DataSources>
			</LocalReport>
		    </rsweb:ReportViewer>
		    <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" OldValuesParameterFormatString="original_{0}"
			SelectMethod="GetData" TypeName="anagrafica_gruppi_politiciTableAdapters.gruppiTableAdapter">
			<SelectParameters>
			    <asp:ControlParameter ControlID="CheckBox1" Name="showAttivi"
				PropertyName="Checked" Type="Boolean" />
			    <asp:ControlParameter ControlID="CheckBox2" Name="showInattivi"
				PropertyName="Checked" Type="Boolean" />
			    <asp:ControlParameter ControlID="CheckBox3" Name="showComp"
				PropertyName="Checked" Type="Boolean" />
			    <asp:ControlParameter ControlID="CheckBox4" Name="showExComp"
				PropertyName="Checked" Type="Boolean" />
			    <asp:ControlParameter ControlID="TextBox1" DefaultValue="" Name="date" PropertyName="Text"
				Type="DateTime" />
			</SelectParameters>
		    </asp:ObjectDataSource>
		</td>
	    </tr>
	</table>
    </div>
    </form>
</body>
</html>
