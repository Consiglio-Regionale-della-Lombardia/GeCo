<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true"
    CodeFile="aggiungiTitoloStudio.aspx.cs" Inherits="titolistudio_aggiungiTitoloStudio" Title="Persona > Titoli di Studio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	<asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSource1" Width="50%">
	    <ItemStyle Font-Bold="True" />
	    <ItemTemplate>
		Gestione titoli di studio di:&nbsp;<asp:Label ID="nomeLabel" runat="server" Text='<%# Eval("nome") + " " + Eval("cognome") %>' />
	    </ItemTemplate>
	</asp:DataList>
	<br />
	<asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	    SelectCommand="SELECT [nome], [cognome] FROM [persona] WHERE ([id_persona] = @id_persona)">
	    <SelectParameters>
		<asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
	    </SelectParameters>
	</asp:SqlDataSource>
	<br />
	<asp:ListView ID="ListViewTitoliStudio" runat="server" DataKeyNames="id_rec" DataSourceID="SqlDataSourceTitoliStudio"
	    InsertItemPosition="LastItem" OnItemInserted="ListViewTitoliStudio_ItemInserted" 
	    OnItemInserting="ListViewTitoliStudio_ItemInserting" 
	    onitemupdating="ListViewTitoliStudio_ItemUpdating">
	    <LayoutTemplate>
		<table runat="server" width="100%">
		    <tr runat="server">
			<td runat="server">
			    <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
				<tr runat="server" class="tab_ris_header">
				    <th runat="server">
					Titolo di studio
				    </th>
				    <th id="Th1" runat="server">
					Conseguito nel
				    </th>
				    <th id="Th3" runat="server">
					Note
				    </th>
				    <th id="Th2" runat="server">
				    </th>
				</tr>
				<tr id="itemPlaceholder" runat="server">
				</tr>
			    </table>
			</td>
		    </tr>
		    <tr runat="server">
			<td runat="server" style="">
			</td>
		    </tr>
		</table>
	    </LayoutTemplate>
	    <InsertItemTemplate>
		<tr style="">
		    <td width="260px" align="center">
			<asp:DropDownList ID="DropDownListTitoloStudioInsert" runat="server" DataSourceID="SqlDataSource3"
			    DataTextField="descrizione_titolo_studio" DataValueField="id_titolo_studio" Width="250px">
			</asp:DropDownList>
		    </td>
		    <td width="160" align="center">
			<asp:DropDownList ID="DropDownListAnniInsert" runat="server" DataSourceID="SqlDataSource2"
			    DataTextField="anno" DataValueField="anno" Width="150px">
			</asp:DropDownList>
		    </td>
		    <td>
			<asp:TextBox ID="noteTextBox" runat="server" Text='<%# Bind("note") %>' Width="250px"
			    MaxLength="30" />      
		    </td>
		    <td width="23%" valign="top" align="center">
			<asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Inserisci" ValidationGroup="InsertGroup"
			    CssClass="button" />
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
		    <td width="260" align="center">
			<asp:DropDownList ID="DropDownListTitoloStudioEdit" runat="server" SelectedValue='<%# Bind("id_titolo_studio") %>'
			    DataSourceID="SqlDataSource3" DataTextField="descrizione_titolo_studio" DataValueField="id_titolo_studio"
			    Width="250px">
			</asp:DropDownList>
		    </td>
		    <td width="160" align="center">
			<asp:DropDownList ID="DropDownListAnniEdit" runat="server" SelectedValue='<%# Bind("anno_conseguimento") %>'
			    DataSourceID="SqlDataSource2" DataTextField="anno" DataValueField="anno" Width="150px">
			</asp:DropDownList>
		    </td>
		    <td>
			<asp:TextBox ID="noteTextBox" runat="server" Text='<%# Bind("note") %>' Width="250px"
			    MaxLength="30" />
		    </td>
		    <td width="23%" valign="top" align="center">
			<asp:Button ID="UpdateButton" runat="server" CommandName="Update" Text="Aggiorna" ValidationGroup="ValidGroupEdit"
			    CssClass="button" />
			<asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Annulla"
			    CssClass="button" />
		    </td>
		</tr>
	    </EditItemTemplate>
	    <ItemTemplate>
		<tr style="">
		    <td width="260">
			<asp:Label ID="descrizione_titolo_studioLabel" runat="server" Text='<%# Eval("descrizione_titolo_studio") %>'
			    Width="250px" />
		    </td>
		    <td width="160">
			<asp:Label ID="anno_conseguimentoLabel" runat="server" Text='<%# Eval("anno_conseguimento") %>'
			    Width="100px" />
		    </td>
		    <td>
			<asp:Label ID="noteLabel" runat="server" Text='<%# Eval("note") %>' />
		    </td>
		    <td width="23%" valign="top" align="center">
			<asp:Button ID="DeleteButton" runat="server" CommandName="Delete" Text="Elimina"
			    CssClass="button" />
			<asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica" CssClass="button" />
		    </td>
		</tr>
	    </ItemTemplate>
	</asp:ListView>
	<asp:SqlDataSource ID="SqlDataSourceTitoliStudio" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	    DeleteCommand="DELETE FROM [join_persona_titoli_studio] WHERE [id_rec] = @id_rec"
	    InsertCommand="INSERT INTO [join_persona_titoli_studio] ([id_titolo_studio], [id_persona], [anno_conseguimento], [note]) VALUES (@id_titolo_studio, @id_persona, @anno_conseguimento, @note)"
	    SelectCommand="SELECT * FROM join_persona_titoli_studio AS jj INNER JOIN 
			    tbl_titoli_studio AS tt ON jj.id_titolo_studio = tt.id_titolo_studio 
			    WHERE ([id_persona] = @id_persona) ORDER BY [anno_conseguimento] DESC"
	    UpdateCommand="UPDATE [join_persona_titoli_studio] SET [id_titolo_studio] = @id_titolo_studio, [id_persona] = @id_persona, [anno_conseguimento] = @anno_conseguimento, [note] = @note WHERE [id_rec] = @id_rec">
	    <SelectParameters>
		<asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
	    </SelectParameters>
	    <DeleteParameters>
		<asp:Parameter Name="id_rec" Type="Int32" />
	    </DeleteParameters>
	    <UpdateParameters>
		<asp:Parameter Name="id_titolo_studio" Type="Int32" />
		<asp:Parameter Name="id_persona" Type="Int32" />
		<asp:Parameter Name="anno_conseguimento" Type="Int32" />
		<asp:Parameter Name="note" Type="String" />
		<asp:Parameter Name="id_rec" Type="Int32" />
	    </UpdateParameters>
	    <InsertParameters>
		<asp:Parameter Name="id_rec" Type="Int32" />
		<asp:Parameter Name="id_titolo_studio" Type="Int32" />
		<asp:Parameter Name="id_persona" Type="Int32" />
		<asp:Parameter Name="anno_conseguimento" Type="Int32" />
		<asp:Parameter Name="note" Type="String" />
	    </InsertParameters>
	</asp:SqlDataSource>
	<asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	    SelectCommand="SELECT anno FROM tbl_anni WHERE (anno > YEAR(GETDATE()) - 50) AND (anno <= YEAR(GETDATE())) ORDER BY anno DESC">
	</asp:SqlDataSource>
	<asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	    SelectCommand="SELECT * FROM [tbl_titoli_studio] ORDER BY [descrizione_titolo_studio]">
	</asp:SqlDataSource>
	<div align="right">
	    <b><a href="../persona/dettaglio.aspx">« Indietro</a></b>
	</div>
    </div>
</asp:Content>
