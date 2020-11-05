<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true"
    CodeFile="gestisciTipiDelibere.aspx.cs" Inherits="delibere_gestisciTipiDelibere"
    Title="Delibere > Gestione Tipi Delibere" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	<b>Gestione tipi di delibere</b>
	<br />
	<br />
	<asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
	</asp:ScriptManager>
	<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
	    <ContentTemplate>
		<asp:ListView ID="ListView1" runat="server" DataKeyNames="id_delibera" DataSourceID="SqlDataSource1"
		    InsertItemPosition="LastItem" OnItemDeleted="ListView1_ItemDeleted" OnItemUpdated="ListView1_ItemUpdated">
		    <LayoutTemplate>
			<table runat="server" width="100%">
			    <tr runat="server">
				<td runat="server">
				    <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
					<tr runat="server" class="tab_ris_header">
					    <th runat="server">
						Tipo Delibera
					    </th>
					    <th id="Th1" runat="server">
					    </th>
					</tr>
					<tr id="itemPlaceholder" runat="server">
					</tr>
				    </table>
				</td>
			    </tr>
			    <tr runat="server">
				<td runat="server" style="" align="center">
				    <asp:DataPager ID="DataPager1" runat="server">
					<Fields>
					    <asp:NextPreviousPagerField ButtonType="Button" 
					                                ShowFirstPageButton="False" 
					                                ShowNextPageButton="False"
						                            ShowPreviousPageButton="False" />
					    <asp:NumericPagerField />
					    <asp:NextPreviousPagerField ButtonType="Button" 
					                                ShowLastPageButton="False" 
					                                ShowNextPageButton="False"
						                            ShowPreviousPageButton="False" />
					</Fields>
				    </asp:DataPager>
				</td>
			    </tr>
			</table>
		    </LayoutTemplate>
		    <InsertItemTemplate>
			<tr style="">
			    <td>
				<asp:TextBox ID="tipo_deliberaTextBox" runat="server" Text='<%# Bind("tipo_delibera") %>'
				    Width="100%" MaxLength='50' />
				<asp:RequiredFieldValidator ID="RequiredFieldValidatortipo_deliberaTextBox" runat="server"
				    ErrorMessage="Campo obbligatorio." ControlToValidate="tipo_deliberaTextBox" Display="Dynamic"
				    ValidationGroup="ValidGroupInsert" />
			    </td>
			    <td width="23%" align="center" valign="top">
				<asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Inserisci"
				    ValidationGroup="ValidGroupInsert" CssClass="button" />
				<asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancella"
				    CssClass="button" />
			    </td>
			</tr>
		    </InsertItemTemplate>
		    <EmptyDataTemplate>
			<table runat="server" style="">
			    <tr>
				<td>
				    Non è stato restituito alcun dato.
				</td>
			    </tr>
			</table>
		    </EmptyDataTemplate>
		    <EditItemTemplate>
			<tr style="">
			    <td>
				<asp:TextBox ID="tipo_deliberaTextBox" runat="server" Text='<%# Bind("tipo_delibera") %>'
				    Width="100%" MaxLength='50' />
				<asp:RequiredFieldValidator ID="RequiredFieldValidatortipo_deliberaTextBox" runat="server"
				    ErrorMessage="Campo obbligatorio." ControlToValidate="tipo_deliberaTextBox" Display="Dynamic"
				    ValidationGroup="ValidGroupEdit" />
			    </td>
			    <td width="23%" align="center" valign="top">
				<asp:Button ID="UpdateButton" runat="server" CommandName="Update" Text="Aggiorna"
				    ValidationGroup="ValidGroupEdit" CssClass="button" />
				<asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Annulla"
				    CssClass="button" />
			    </td>
			</tr>
		    </EditItemTemplate>
		    <ItemTemplate>
			<tr style="">
			    <td>
				<asp:Label ID="tipo_deliberaLabel" runat="server" Text='<%# Eval("tipo_delibera") %>' />
			    </td>
			    <td width="23%" align="center" valign="top">
				<asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica" CssClass="button" />
				<asp:Button ID="DeleteButton" runat="server" CommandName="Delete" Text="Elimina"
				    CssClass="button" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
			    </td>
			</tr>
		    </ItemTemplate>
		</asp:ListView>
		<asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		    DeleteCommand="DELETE FROM [tbl_delibere] WHERE [id_delibera] = @id_delibera"
		    InsertCommand="INSERT INTO [tbl_delibere] ([tipo_delibera]) VALUES (@tipo_delibera); SELECT @id_delibera = SCOPE_IDENTITY();"
		    SelectCommand="SELECT * FROM [tbl_delibere]" UpdateCommand="UPDATE [tbl_delibere] SET [tipo_delibera] = @tipo_delibera WHERE [id_delibera] = @id_delibera"
		    OnInserted="SqlDataSource1_Inserted">
		    <DeleteParameters>
			<asp:Parameter Name="id_delibera" Type="Int32" />
		    </DeleteParameters>
		    <UpdateParameters>
			<asp:Parameter Name="tipo_delibera" Type="String" />
			<asp:Parameter Name="id_delibera" Type="Int32" />
		    </UpdateParameters>
		    <InsertParameters>
			<asp:Parameter Name="tipo_delibera" Type="String" />
			<asp:Parameter Direction="Output" Name="id_delibera" Type="Int32" />
		    </InsertParameters>
		</asp:SqlDataSource>
	    </ContentTemplate>
	</asp:UpdatePanel>
    </div>
</asp:Content>
