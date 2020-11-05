<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="gestisciCauseFine.aspx.cs" 
         Inherits="causefine_gestisciCauseFine" 
         Title="Cause Fine > Gestione Cause Fine" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	<b>Gestione cause fine</b>
	<br />
	<br />
	<asp:ScriptManager ID="ScriptManager2" 
	                   runat="server" 
	                   EnableScriptGlobalization="True">
	</asp:ScriptManager>
	
	<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
	    <ContentTemplate>
		<asp:ListView ID="ListView1" 
		              runat="server" 
		              DataKeyNames="id_causa"
		              DataSourceID="SqlDataSource1"
		              InsertItemPosition="LastItem" 
		              
		              OnItemDeleted="ListView1_ItemDeleted" 
		              OnItemUpdated="ListView1_ItemUpdated" 
		              oniteminserting="ListView1_ItemInserting" 
		              onitemdeleting="ListView1_ItemDeleting" 
		              onitemupdating="ListView1_ItemUpdating">
		    
		    <LayoutTemplate>
			    <table runat="server" width="100%">
			        <tr runat="server">
				        <td runat="server">
				            <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
					        <tr runat="server" class="tab_ris_header">
					            <th runat="server">
						        Descrizione della causa di fine
					            </th>
					            <th runat="server">
						        Tipo
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
		    
		    <EmptyDataTemplate>
			    <table id="Table1" runat="server" style="">
			        <tr>
				        <td>
				            Nessun dato disponibile.
				        </td>
			        </tr>
			    </table>
		    </EmptyDataTemplate>
		    
		    <InsertItemTemplate>
			    <tr style="">
			        <td width="50%" valign="middle" align="left" >
				        <asp:TextBox ID="TextBoxDescrizioneInsert" 
				                     runat="server" 
				                     Text='<%# Bind("descrizione_causa") %>'
				                     Width="99%" 
				                     MaxLength='50' />
				        <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxDescrizioneInsert" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="TextBoxDescrizioneInsert"
				                                    Display="Dynamic" 
				                                    ValidationGroup="ValidGroupInsert" />
			        </td>
			        
			        <td width="25%" valign="middle">
				        <asp:DropDownList ID="DropDownListTipoInsert" 
				                          runat="server" 
				                          Width="99%" 				                          
				                          SelectedValue='<%# Bind("tipo_causa") %>'>
				            <asp:ListItem Value="Persona-Sospensioni-Sostituzioni" 
				                          Text="Persona-Sospensioni-Sostituzioni" />
				            <asp:ListItem Value="Persona-Cariche-Organi" 
				                          Text="Persona-Cariche-Organi" />
				            <asp:ListItem Value="Legislature" 
				                          Text="Legislature" />
				            <asp:ListItem Value="Gruppi-Politici" 
				                          Text="Gruppi-Politici" />
				        </asp:DropDownList>
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListTipoInsert" 
				                                    ControlToValidate="DropDownListTipoInsert"
				                                    runat="server" 
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupInsert" />
			        </td>
			        
			        <td width="25%" align="center" valign="middle">
				        <asp:Button ID="InsertButton" 
				                    runat="server" 
				                    CommandName="Insert" 
				                    Text="Inserisci"
				                    ValidationGroup="ValidGroupInsert" 
				                    CssClass="button" />
				                    
				        <asp:Button ID="CancelButton" 
				                    runat="server" 
				                    CommandName="Cancel" 
				                    Text="Cancella"
				                    CssClass="button" />
			        </td>
			    </tr>
		    </InsertItemTemplate>		    
		    
		    <EditItemTemplate>
			    <tr style="">
			        <td width="50%" align="center" >
				        <asp:TextBox ID="TextBoxDescrizioneEdit" 
				                     runat="server" 
				                     Text='<%# Bind("descrizione_causa") %>'
				                     MaxLength='50' 
				                     Width="99%" />
				        <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxDescrizioneEdit" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="TextBoxDescrizioneEdit"
				                                    Display="Dynamic" 
				                                    ValidationGroup="ValidGroupEdit" />
			        </td>
			        <td width="25%" valign="middle" >
				        <asp:DropDownList ID="DropDownListTipoEdit" 
				                          runat="server" 
				                          Width="99%" 
				                          SelectedValue='<%# Bind("tipo_causa") %>'>
				            <asp:ListItem Value="Persona-Sospensioni-Sostituzioni" 
				                          Text="Persona-Sospensioni-Sostituzioni" />
				            <asp:ListItem Value="Persona-Cariche-Organi" 
				                          Text="Persona-Cariche-Organi" />
				            <asp:ListItem Value="Legislature" 
				                          Text="Legislature" />
				            <asp:ListItem Value="Gruppi-Politici" 
				                          Text="Gruppi-Politici" />
				        </asp:DropDownList>
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListTipoEdit" 
				                                    ControlToValidate="DropDownListTipoEdit"
				                                    runat="server" 
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupEdit" />
			        </td>
			        <td width="25%" align="center" valign="middle" >
				        <asp:Button ID="UpdateButton" 
				                    runat="server" 
				                    CommandName="Update" 
				                    Text="Aggiorna"
				                    ValidationGroup="ValidGroupEdit" 
				                    CssClass="button" />
				                    
				        <asp:Button ID="CancelButton" 
				                    runat="server" 
				                    CommandName="Cancel" 
				                    Text="Annulla"
				                    CssClass="button" />
			        </td>
			    </tr>
		    </EditItemTemplate>
		    
		    <ItemTemplate>
			    <tr style="">
			        <td width="50%">
				        <asp:Label ID="descrizione_causaLabel" 
				                   runat="server" 
				                   Text='<%# Eval("descrizione_causa") %>' />
			        </td>
			        <td width="25%">
				        <asp:Label ID="LabelTipoCausa" 
				                   runat="server" 
				                   Text='<%# Eval("tipo_causa") %>' />
			        </td>
			        <td width="25%" align="center" valign="middle">
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
			    </tr>
		    </ItemTemplate>
		</asp:ListView>
		
		<asp:SqlDataSource ID="SqlDataSource1" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   DeleteCommand="DELETE FROM [tbl_cause_fine] 
		                                  WHERE [id_causa] = @id_causa" 
		                   
		                   InsertCommand="INSERT INTO [tbl_cause_fine] ([descrizione_causa], 
		                                                                [tipo_causa]) 
		                                  VALUES (@descrizione_causa, 
		                                          @tipo_causa); 
		                                  SELECT @id_causa = SCOPE_IDENTITY();"
		                   
		                   SelectCommand="SELECT * 
		                                  FROM [tbl_cause_fine] 
		                                  ORDER BY [tipo_causa]" 
		                   
		                   UpdateCommand="UPDATE [tbl_cause_fine] 
		                                  SET [descrizione_causa] = @descrizione_causa, 
		                                      [tipo_causa] = @tipo_causa 
		                                  WHERE [id_causa] = @id_causa"
		                   
		                   OnInserted="SqlDataSource1_Inserted">
		    
		    <DeleteParameters>
			    <asp:Parameter Name="id_causa" Type="Int32" />
		    </DeleteParameters>
		    
		    <UpdateParameters>
			    <asp:Parameter Name="descrizione_causa" Type="String" />
			    <asp:Parameter Name="tipo_causa" Type="String" />
			    <asp:Parameter Name="id_causa" Type="Int32" />
		    </UpdateParameters>
		    
		    <InsertParameters>
			    <asp:Parameter Name="descrizione_causa" Type="String" />
			    <asp:Parameter Name="tipo_causa" Type="String" />
			    <asp:Parameter Direction="Output" Name="id_causa" Type="Int32" />
		    </InsertParameters>
		</asp:SqlDataSource>
	    </ContentTemplate>
	</asp:UpdatePanel>
    </div>
</asp:Content>