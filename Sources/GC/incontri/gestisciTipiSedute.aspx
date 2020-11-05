<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="gestisciTipiSedute.aspx.cs" 
         Inherits="incontri_gestisciTipiSedute" 
         Title="Incontri > Gestisci Tipi di Sedute" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	<b>Gestione tipi di sedute</b>
	<br />
	<br />
	<asp:ScriptManager ID="ScriptManager" runat="server" EnableScriptGlobalization="True">
	</asp:ScriptManager>
	<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
	    <ContentTemplate>
		<asp:ListView ID="ListView1" 
		              runat="server" 
		              DataKeyNames="id_incontro" 
		              DataSourceID="SqlDataSource1" 
		              InsertItemPosition="LastItem" 
		              
		              OnItemDeleted="ListView1_ItemDeleted" 
		              OnItemUpdated="ListView1_ItemUpdated">
		    
		    <EmptyDataTemplate>
			    <table id="Table1" runat="server" style="">
			        <tr>
				        <td>Non è stato restituito alcun dato.</td>
			        </tr>
			    </table>
		    </EmptyDataTemplate>
		    
		    <LayoutTemplate>
			    <table runat="server" width="100%">
			    <tr runat="server">
				    <td runat="server">
				        <table ID="itemPlaceholderContainer" runat="server" class="tab_gen">
					    <tr runat="server" class="tab_ris_header">
					        <th runat="server">
						    Tipo Seduta</th>
					        <th runat="server">
						    Incontro consultazione ecc?</th>
					        <th id="Th1" runat="server">
					        </th>
					    </tr>
					    <tr ID="itemPlaceholder" runat="server">
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
			        <td>
				    <asp:TextBox ID="TextBoxTipoIncontro" 
				                 runat="server" 
				                 Text='<%# Bind("tipo_incontro") %>' 
				                 Width="99%" 
				                 MaxLength='50' />
				    <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxTipoIncontro" 
				                                runat="server"
				                                ErrorMessage="Campo obbligatorio." 
				                                ControlToValidate="TextBoxTipoIncontro" 
				                                Display="Dynamic"
				                                ValidationGroup="ValidGroupInsert" />
			        </td>
			        
			        <td width="10%" align="center">
				        <asp:CheckBox ID="consultazioneCheckBox" 
				                      runat="server" 
				                      Checked='<%# Bind("consultazione") %>' />
			        </td>
			        
			        <td width="25%" align="center" valign="middle">    			    
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
		    </InsertItemTemplate>
		    
		    <EditItemTemplate>
			    <tr style="">
			        <td>
				        <asp:TextBox ID="TextBoxTipoIncontro" 
				                     runat="server" 
				                     Text='<%# Bind("tipo_incontro") %>' 
				                     Width="99%" 
				                     MaxLength='50' />
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxTipoIncontro" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="TextBoxTipoIncontro" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupEdit" />
			        </td>
			        
			        <td width="10%" align="center">
				        <asp:CheckBox ID="consultazioneCheckBox" 
				                      runat="server" 
				                      Checked='<%# Bind("consultazione") %>' />
			        </td>
			        
			        <td width="25%" align="center" valign="middle">
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
			    </tr>
		    </EditItemTemplate>
		    
		    <ItemTemplate>
			    <tr style="">
			        <td>
				        <asp:Label ID="tipo_incontroLabel" 
				                   runat="server" 
				                   Text='<%# Eval("tipo_incontro") %>' />
			        </td>
			        
			        <td width="10%" align="center">
				        <asp:CheckBox ID="consultazioneCheckBox" 
				                      runat="server" 
				                      Checked='<%# Eval("consultazione") %>' 
				                      Enabled="false" />
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
	                                CssClass="button" />
			        </td>
			    </tr>
		    </ItemTemplate>
		</asp:ListView>
		
        <asp:SqlDataSource ID="SqlDataSource1" 
                           runat="server" 
	                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
	                       
	                       DeleteCommand="DELETE FROM [tbl_incontri] 
	                                      WHERE [id_incontro] = @id_incontro" 
	                       
	                       InsertCommand="INSERT INTO [tbl_incontri] ([tipo_incontro], 
	                                                                  [consultazione]) 
	                                      VALUES (@tipo_incontro, 
	                                              @consultazione); 
	                                      SELECT @id_incontro = SCOPE_IDENTITY();" 
	                       
	                       SelectCommand="SELECT * 
	                                      FROM [tbl_incontri]" 
	                       
	                       UpdateCommand="UPDATE [tbl_incontri] 
	                                      SET [tipo_incontro] = @tipo_incontro, 
	                                          [consultazione] = @consultazione 
	                                      WHERE [id_incontro] = @id_incontro"
	                       
	                       OnInserted="SqlDataSource1_Inserted">
	    <DeleteParameters>
		    <asp:Parameter Name="id_incontro" Type="Int32" />
	    </DeleteParameters>
	    
	    <UpdateParameters>
		    <asp:Parameter Name="tipo_incontro" Type="String" />
		    <asp:Parameter Name="consultazione" Type="Boolean" />
		    <asp:Parameter Name="id_incontro" Type="Int32" />
	    </UpdateParameters>
	    
	    <InsertParameters>
		    <asp:Parameter Name="tipo_incontro" Type="String" />
		    <asp:Parameter Name="consultazione" Type="Boolean" />
		    <asp:Parameter Direction="Output" Name="id_incontro" Type="Int32" />
	    </InsertParameters>
	</asp:SqlDataSource>
	    </ContentTemplate>
	</asp:UpdatePanel>
    </div>
</asp:Content>