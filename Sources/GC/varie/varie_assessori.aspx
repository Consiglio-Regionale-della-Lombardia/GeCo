<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="varie_assessori.aspx.cs" 
         Inherits="varie_assessori" 
         Title="Assessori > Varie" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	<asp:DataList ID="DataList1" 
	              runat="server" 
	              DataSourceID="SqlDataSourceHead" 
	              Width="50%" >
	    <ItemTemplate>
		<table>
		    <tr>
			<td width="50">
			    <img alt="" 
			         src="<%= photoName %>" 
			         width="50" 
			         height="50" 
			         style="border: 1px solid #99cc99; margin-right: 10px;" 
			         align="middle" />
			</td>
			<td>
			    <span style="font-size: 1.5em; font-weight: bold; color: #50B306;">
			    <asp:Label ID="LabelHeadNome" 
			    runat="server" 
			    Text='<%# Eval("nome") + " " + Eval("cognome") %>' /></span>
			    <br />
			    <asp:Label ID="LabelHeadDataNascita" 
			    runat="server" 
			    Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' >
			    </asp:Label>
			</td>
		    </tr>
		</table>
	    </ItemTemplate>
	</asp:DataList>
	<asp:SqlDataSource ID="SqlDataSourceHead" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	                   
	                   SelectCommand="SELECT pp.nome, 
	                                         pp.cognome, 
	                                         pp.data_nascita
			                          FROM persona AS pp 
			                          WHERE (pp.id_persona = @id_persona)">
	    <SelectParameters>
		    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
	    </SelectParameters>
	</asp:SqlDataSource>
    </td>
</tr>
<tr>
    <td>
	&nbsp;
    </td>
</tr>
<tr>
    <td>
        <div id="tab">
            <tab:TabsPersona runat="server" ID="tabsPersona" />
        </div>
	<div id="tab_content">
	    <div id="tab_content_content">
		<asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
		</asp:ScriptManager>
		
		<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		    <ContentTemplate>
			<asp:ListView ID="ListView1" 
			              runat="server" 
			              DataSourceID="SqlDataSource1" 
			              DataKeyNames="id_rec"
			              InsertItemPosition="LastItem" 
			              OnItemInserting="ListView1_ItemInserting" 
			              OnItemUpdating="ListView1_ItemUpdating"
			              OnItemDeleted="ListView1_ItemDeleted" 
			              OnItemUpdated="ListView1_ItemUpdated" >
			              
			    <LayoutTemplate>
				<table runat="server" width="100%">
				    <tr runat="server">
					<td runat="server">
					    <table id="itemPlaceholderContainer" runat="server" width="100%" class="tab_gen">
						<tr runat="server">
						    <th runat="server">
							Note
						    </th>
						    <th id="Th1" runat="server">
						    </th>
						</tr>
						<tr id="itemPlaceholder" runat="server">
						</tr>
					    </table>
					</td>
				    </tr>
				</table>
			    </LayoutTemplate>
			    <InsertItemTemplate>
				<% if (role <= 2) { %>
				<tr style="">
				    <td valign="top">
					<asp:TextBox ID="TextBoxNote" 
					             runat="server" Text='<%# Bind("note") %>' Width="99%" >
					</asp:TextBox>
					<asp:RequiredFieldValidator ID="RequiredFieldValidatorNote" 
					runat="server" 
					ErrorMessage="Campo obbligatorio."
					    ControlToValidate="TextBoxNote" 
					    Display="Dynamic" 
					    ValidationGroup="ValidGroupInsert" >
					</asp:RequiredFieldValidator>
				    </td>
				    <td width="23%" valign="top" align="center">
					<asp:Button ID="InsertButton" 
					            runat="server" 
					            CommandName="Insert" 
					            Text="Inserisci"
					    CssClass="button" 
					    ValidationGroup="ValidGroupInsert" />
					<asp:Button ID="CancelButton" 
					runat="server" 
					CommandName="Cancel" 
					Text="Cancella"
					    CssClass="button" />
				    </td>
				</tr>
				<% } %>
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
				    <td valign="top">
					<asp:TextBox ID="TextBoxNote" 
					runat="server" 
					Text='<%# Bind("note") %>' 
					Width="99%" >
					</asp:TextBox>
					<asp:RequiredFieldValidator ID="RequiredFieldValidatorNote" 
					runat="server" 
					ErrorMessage="Campo obbligatorio."
					    ControlToValidate="TextBoxNote" 
					    Display="Dynamic" 
					    ValidationGroup="ValidGroupEdit" >
					</asp:RequiredFieldValidator>
				    </td>
				    <% if (role <= 2) { %>
				    <td width="23%" valign="top" align="center">
					<asp:Button ID="UpdateButton" 
					runat="server" 
					CommandName="Update" 
					Text="Aggiorna"
					    CssClass="button" 
					    ValidationGroup="ValidGroupEdit" />
					<asp:Button ID="CancelButton" 
					runat="server" 
					CommandName="Cancel" 
					Text="Annulla"
					    CssClass="button" />
				    </td>
				    <% } %>
				</tr>
			    </EditItemTemplate>
			    <ItemTemplate>
				<tr style="">
				    <td>
					<asp:Label ID="noteLabel" runat="server" Text='<%# Eval("note") %>' />
				    </td>
				    <% if (role <= 2) { %>
				    <td width="23%" valign="top" align="center">
					<asp:Button ID="EditButton" 
					            runat="server" 
					            CommandName="Edit" 
					            Text="Modifica" 
					            CssClass="button" />
					<asp:Button ID="DeleteButton" 
					            runat="server" 
					            CommandName="Delete" 
					            Text="Elimina" 
					            CssClass="button" 
					            OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
				    </td>
				    <% } %>
				</tr>
			    </ItemTemplate>
			</asp:ListView>
			<asp:SqlDataSource ID="SqlDataSource1" 
			                   runat="server" 
			                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                   
			                   DeleteCommand="UPDATE [join_persona_varie] 
			                                  SET [deleted] = 1 
			                                  WHERE [id_rec] = @id_rec"
			                   
			                   InsertCommand="INSERT INTO [join_persona_varie] ([id_persona], 
			                                                                    [note]) 
			                                  VALUES (@id_persona, @note); 
			                                  SELECT @id_rec = SCOPE_IDENTITY();"
			                   
			                   SelectCommand="SELECT * 
			                                  FROM [join_persona_varie] 
			                                  WHERE ([deleted] = 0) 
			                                    AND ([id_persona] = @id_persona)"
			                   
			                   UpdateCommand="UPDATE [join_persona_varie] 
			                                  SET [id_persona] = @id_persona, 
			                                      [note] = @note 
			                                  WHERE [id_rec] = @id_rec"
			                   
			                   OnInserted="SqlDataSource1_Inserted" >
			    <SelectParameters>
				<asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
			    </SelectParameters>
			    <DeleteParameters>
				<asp:Parameter Name="id_rec" Type="Int32" />
			    </DeleteParameters>
			    <UpdateParameters>
				<asp:Parameter Name="id_persona" Type="Int32" />
				<asp:Parameter Name="note" Type="String" />
				<asp:Parameter Name="id_rec" Type="Int32" />
			    </UpdateParameters>
			    <InsertParameters>
				<asp:Parameter Name="id_persona" Type="Int32" />
				<asp:Parameter Name="note" Type="String" />
				<asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
			    </InsertParameters>
			</asp:SqlDataSource>
		    </ContentTemplate>
		</asp:UpdatePanel>
	    </div>
	</div>
    </td>
</tr>
<tr>
    <td>
	&nbsp;
    </td>
</tr>
<tr>
    <td align="right">
	    <b>
	        <a id="a_back" 
	          runat="server" 
	          href="../persona/persona_assessori.aspx">
	            « Indietro
	        </a>
	    </b>
    </td>
</tr>
<tr>
    <td>
	&nbsp;
    </td>
</tr>
</table>
</asp:Content>