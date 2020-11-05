<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="risultati_elettorali.aspx.cs" 
         Inherits="risultati_elettorali_risultati_elettorali" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

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
		<asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSourceHead" Width="50%">
		    <ItemTemplate>
			<table>
			    <tr>
				<td width="50">
				    <img src="<%= photoName %>" 
				         width="50" 
				         height="50" 
				         style="border: 1px solid #99cc99; margin-right: 10px;" 
				         align="absmiddle" />
				</td>
				
				<td>
				    <span style="font-size: 1.5em; font-weight: bold; color: #50B306;">
				        <asp:Label ID="LabelHeadNome" 
				                   runat="server" 
				                   Text='<%# Eval("nome_completo") %>' >
				        </asp:Label>
				    </span>
				    
				    <br />
				    
				    <asp:Label ID="LabelHeadDataNascita" 
				               runat="server" 
				               Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' >
				    </asp:Label>
				    
				    <asp:Label ID="LabelHeadGruppo" 
				               runat="server" 
				               Font-Bold="true"
				               Text='<%# Eval("nome_gruppo") %>' >
				    </asp:Label>
				</td>
			    </tr>
			</table>
		    </ItemTemplate>
		</asp:DataList>
		
		<asp:SqlDataSource ID="SqlDataSourceHead" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT pp.nome + ' ' + pp.cognome AS nome_completo, 
                                                 pp.data_nascita, 
                                                 '(' + COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO') + ')' AS nome_gruppo 
				                          FROM persona AS pp 
				                          LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp 
				                             ON (pp.id_persona = jpgp.id_persona 
				                                 AND (jpgp.data_fine IS NULL OR jpgp.data_fine &gt;= GETDATE()) 
				                                 AND (jpgp.deleted = 0 OR jpgp.deleted IS NULL))
				                          LEFT OUTER JOIN gruppi_politici AS gg 
				                             ON jpgp.id_gruppo = gg.id_gruppo 
				                          WHERE pp.id_persona = @id_persona">
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
			<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
			    <ContentTemplate>
				<table>
				    <tr>
					<td valign="top" width="230">
					    Seleziona legislatura:
					    <asp:DropDownList ID="DropDownListLegislatura" runat="server" DataSourceID="SqlDataSourceLegislature"
						DataTextField="num_legislatura" DataValueField="id_legislatura" Width="70px"
						AppendDataBoundItems="True">
						<asp:ListItem Text="(tutte)" Value="" />
					    </asp:DropDownList>
					    <asp:SqlDataSource ID="SqlDataSourceLegislature" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
					    </asp:SqlDataSource>
					</td>
					<td valign="top" width="230">
					    Seleziona data:
					    <asp:TextBox ID="TextBoxFiltroData" runat="server" Width="70px"></asp:TextBox>
					    <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
					    <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="TextBoxFiltroData"
						PopupButtonID="ImageFiltroData" Format="dd/MM/yyyy">
					    </cc1:CalendarExtender>
					    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
					    </asp:ScriptManager>
					    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" ControlToValidate="TextBoxFiltroData"
						runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						ValidationGroup="FiltroData" />
					</td>
					<td valign="top">
					    <asp:Button ID="ButtonFiltri" runat="server" Text="Applica" OnClick="ButtonFiltri_Click"
						ValidationGroup="FiltroData" />
					</td>
				    </tr>
				</table>
				
				<br />
				<br />
				
				<asp:ListView ID="ListView1" 
				              runat="server" 
				              DataKeyNames="id_rec" 
				              DataSourceID="SqlDataSource1" 
				              InsertItemPosition="LastItem"
				              
				              OnItemInserting="ListView1_ItemInserting" 
				              OnItemUpdating="ListView1_ItemUpdating"
				              OnItemDeleted="ListView1_ItemDeleted" 
				              OnItemUpdated="ListView1_ItemUpdated">
				    
				    <LayoutTemplate>
					<table runat="server" width="100%">
					    <tr runat="server">
						<td runat="server">
						    <table ID="itemPlaceholderContainer" runat="server" width="100%" class="tab_gen">
							<tr runat="server" style="">
							    <th runat="server">
								Legislatura</th>
							    <th runat="server">
								Circoscrizione</th>
							    <th runat="server">
								Data Elezione</th>
							    <th runat="server">
								Lista</th>
							    <th runat="server">
								Maggioranza</th>
							    <th runat="server">
								Voti</th>
							    <th runat="server">
								Neoeletto</th>
							    <th runat="server">
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
					<% if (role <= 2) { %>
					<tr style="">
					    <td valign="top" width="70">
						<asp:DropDownList ID="DropDownListLeg" runat="server" DataSourceID="SqlDataSourceLeg"
						    DataTextField="num_legislatura" DataValueField="id_legislatura" Width="90" AppendDataBoundItems="true">
						    <asp:ListItem Text="(seleziona)" Value="" />
						</asp:DropDownList>
						<asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						    SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
						</asp:SqlDataSource>
						<asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListLeg" 
						                            ControlToValidate="DropDownListLeg"
						                            runat="server" 
						                            Display="Dynamic" 
						                            ErrorMessage="Campo obbligatorio." 
						                            ValidationGroup="ValidGroupInsert" />
					    </td>
					    
					    <td valign="top">
						<asp:TextBox ID="circoscrizioneTextBox" runat="server" Width="99%" MaxLength="50"
						    Text='<%# Bind("circoscrizione") %>' />
					    </td>
					    
					    <td width="100" valign="top">
						<asp:TextBox ID="TextBoxDataElezioneIns" 
						             runat="server" 
						             Width="70px" />
						<img alt="calendar" src="../img/calendar_month.png" id="ImageDataElezione" runat="server" />
						<cc1:CalendarExtender ID="CalendarExtenderDataElezione" runat="server" TargetControlID="TextBoxDataElezioneIns"
						    PopupButtonID="ImageDataElezione" Format="dd/MM/yyyy">
						</cc1:CalendarExtender>
						<asp:RequiredFieldValidator ID="RequiredFieldValidatorDataElezione"
						                            runat="server"
						                            ControlToValidate="TextBoxDataElezioneIns"
						                            ValidationGroup="ValidGroupInsert"
						                            Display="Dynamic"
						                            ErrorMessage="Campo Obbligatorio" >
						</asp:RequiredFieldValidator>
						<asp:RegularExpressionValidator ID="RegularExpressionValidatorDataElezione" ControlToValidate="TextBoxDataElezioneIns"
						    runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						    ValidationGroup="ValidGroupInsert" />
					    </td>
					    
					    <td valign="top" width="80">
						<asp:TextBox ID="listaTextBox" runat="server" Width="99%" MaxLength="50"
						    Text='<%# Bind("lista") %>' />
					    </td>
					    
					    <td valign="top" width="80">
						<%-- Definizione Textbox precedente alla modifica
						    <asp:TextBox ID="maggioranzaTextBox" runat="server" Width="99%" MaxLength="50"
						    Text='<%# Bind("maggioranza") %>' />
						    
						    Fine definizione --%>
						    <asp:DropDownList ID="ddlMagMin_Insert"
						                      runat="server" >
						        <asp:ListItem Selected="True"
						                      Text="Non definito"
						                      Value="">
						        </asp:ListItem>                
						          
						        <asp:ListItem Text="Maggioranza"
						                      Value="Maggioranza">
						        </asp:ListItem>
						        
						        <asp:ListItem Text="Opposizione"
						                      Value="Opposizione">
						        </asp:ListItem>
						        
						    </asp:DropDownList>
					    </td>
					    
					    <td valign="top" width="80">
						<asp:TextBox ID="votiTextBox" runat="server" Width="99%" 
						    Text='<%# Bind("voti") %>' />
						<asp:RegularExpressionValidator ID="RegularExpressionVoti" ControlToValidate="votiTextBox"
						    runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						    ValidationGroup="ValidGroupInsert" />
					    </td>
					    
					    <td valign="top" align="center" width="30">
						<asp:CheckBox ID="neoelettoCheckBox" runat="server" 
						    Checked='<%# Bind("neoeletto") %>' />
					    </td>
					    
					    <td width="23%" valign="top" align="center">
						<asp:Button ID="InsertButton" 
					                runat="server" CommandName="Insert" 
					                Text="Inserisci" CssClass="button" 
					                CausesValidation="true"
					                ValidationGroup="ValidGroupInsert" />
						<asp:Button ID="CancelButton" runat="server" CommandName="Cancel" 
						    Text="Cancella" CssClass="button" />
					    </td>
					</tr>
					<% } %>
				    </InsertItemTemplate>
				    
				    <EmptyDataTemplate>
					<table runat="server" style="">
					    <tr>
						<td>
						    Non è stato restituito alcun dato.</td>
					    </tr>
					</table>
				    </EmptyDataTemplate>
				    
				    <EditItemTemplate>
					<tr style="">
					    <td valign="top" width="70">
						<asp:DropDownList ID="DropDownListLeg" runat="server" DataSourceID="SqlDataSourceLeg"  SelectedValue='<%# Bind("id_legislatura") %>'
						    DataTextField="num_legislatura" DataValueField="id_legislatura" Width="99%" AppendDataBoundItems="true">
						    <asp:ListItem Text="(seleziona)" Value="" />
						</asp:DropDownList>
						<asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						    SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
						</asp:SqlDataSource>
						<asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListLeg" ControlToValidate="DropDownListLeg"
						    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroupEdit" />
					    </td>
					    
					    <td valign="top">
						<asp:TextBox ID="circoscrizioneTextBox" runat="server" Width="99%" MaxLength="50"
						    Text='<%# Bind("circoscrizione") %>' />
					    </td>
					    
					    <td width="100" valign="top">
						<asp:TextBox ID="TextBoxDataElezioneMod" 
						             runat="server" 
						             Text='<%# Eval("data_elezione", "{0:dd/MM/yyyy}") %>'
						             Width="70px" />
						<img alt="calendar" src="../img/calendar_month.png" id="ImageDataElezione" runat="server" />
						<cc1:CalendarExtender ID="CalendarExtenderDataElezione" runat="server" TargetControlID="TextBoxDataElezioneMod"
						    PopupButtonID="ImageDataElezione" Format="dd/MM/yyyy">
						</cc1:CalendarExtender>
						<asp:RequiredFieldValidator ID="RequireFieldValidatorDataElezione"
						                            runat="server"
						                            ControlToValidate="TextBoxDataElezioneMod"
						                            ErrorMessage="Campo obbligatorio"
						                            ValidationGroup="ValidGroupEdit"
						                            Display="Dynamic" >
						</asp:RequiredFieldValidator>
						
						<asp:RegularExpressionValidator ID="RegularExpressionValidatorDataElezione" ControlToValidate="TextBoxDataElezioneMod"
						    runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						    ValidationGroup="ValidGroupEdit" >
						</asp:RegularExpressionValidator>
					    </td>
					    
					    <td valign="top" width="80">
						<asp:TextBox ID="listaTextBox" runat="server" Width="99%" MaxLength="50"
						    Text='<%# Bind("lista") %>' />
					    </td>
					    
					    <td valign="top" width="80">
						<%--<asp:TextBox ID="maggioranzaTextBox" runat="server" Width="99%" MaxLength="50"
						    Text='<%# Bind("maggioranza") %>' />--%>
						    
						    <asp:DropDownList ID="ddlMagMin_Edit"
						                      runat="server"
						                      SelectedValue='<%# Bind("maggioranza") %>' >
						        <asp:ListItem Selected="True"
						                      Text="Non definito"
						                      Value="">
						        </asp:ListItem>                
						          
						        <asp:ListItem Text="Maggioranza"
						                      Value="Maggioranza">
						        </asp:ListItem>
						        
						        <asp:ListItem Text="Opposizione"
						                      Value="Opposizione">
						        </asp:ListItem>
						        
						    </asp:DropDownList>
					    </td>
					    
					    <td valign="top" width="80">
						<asp:TextBox ID="votiTextBox" runat="server" Width="99%"
						    Text='<%# Bind("voti") %>' />
						<asp:RegularExpressionValidator ID="RegularExpressionVoti" ControlToValidate="votiTextBox"
						    runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						    ValidationGroup="ValidGroupEdit" />
					    </td>
					    
					    <td valign="top" align="center" width="30">
						<asp:CheckBox ID="neoelettoCheckBox" runat="server" 
						    Checked='<%# Bind("neoeletto") %>' />
					    </td>
					    
					    <% if (role <= 2) { %>
					    <td width="23%" valign="top" align="center">
						<asp:Button ID="UpdateButton" 
						runat="server" 
						CommandName="Update" 
						    Text="Aggiorna" 
						    CssClass="button" 
						    CausesValidation="true"
						    ValidationGroup="ValidGroupEdit" />
						<asp:Button ID="CancelButton" runat="server" CommandName="Cancel" 
						    Text="Annulla" CssClass="button" />
					    </td>
					    <% } %>
					</tr>
				    </EditItemTemplate>
				    
				    <ItemTemplate>
					<tr style="">
					    <td align="center">
						<asp:Label ID="id_legislaturaLabel" runat="server" 
						    Text='<%# Eval("num_legislatura") %>' />
					    </td>
					    
					    <td>
						<asp:Label ID="circoscrizioneLabel" runat="server" 
						    Text='<%# Eval("circoscrizione") %>' />
					    </td>
					    
					    <td align="center">
						<asp:Label ID="data_elezioneLabel" runat="server" 
						    Text='<%# Eval("data_elezione", "{0:dd/MM/yyyy}") %>' />
					    </td>
					    
					    <td>
						<asp:Label ID="listaLabel" runat="server" Text='<%# Eval("lista") %>' />
					    </td>
					    
					    <td>
						<asp:Label ID="maggioranzaLabel" runat="server" 
						    Text='<%# Eval("maggioranza") %>' />
					    </td>
					    
					    <td>
						<asp:Label ID="votiLabel" runat="server" Text='<%# Eval("voti") %>' />
					    </td>
					    
					    <td align="center">
						<asp:CheckBox ID="neoelettoCheckBox" runat="server" 
						    Checked='<%# Eval("neoeletto") %>' Enabled="false" />
					    </td>
					    
					    <% if (role <= 2) { %>
					    <td width="23%" valign="top" align="center">
						<asp:Button ID="DeleteButton" runat="server" CommandName="Delete" 
						    Text="Elimina" CssClass="button" />
						<asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica"
						    CssClass="button" />
					    </td>
					    <% } %>
					</tr>
				    </ItemTemplate>
				    
				</asp:ListView>
			        <asp:SqlDataSource ID="SqlDataSource1" 
			                           runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
				    
				                       DeleteCommand="DELETE FROM [join_persona_risultati_elettorali] 
				                                      WHERE [id_rec] = @id_rec"
                    				    
				                       InsertCommand="INSERT INTO [join_persona_risultati_elettorali] ([id_persona], 
				                                                                                       [id_legislatura], 
				                                                                                       [circoscrizione], 
				                                                                                       [data_elezione], 
				                                                                                       [lista], 
				                                                                                       [maggioranza], 
				                                                                                       [voti], 
				                                                                                       [neoeletto]) 
				                                      VALUES (@id_persona, 
				                                              @id_legislatura, 
				                                              @circoscrizione, 
				                                              @data_elezione, 
				                                              @lista,
				                                              @maggioranza, 
				                                              @voti, 
				                                              @neoeletto); 
				                                      SELECT @id_rec = SCOPE_IDENTITY();" 
                    				   
				                       SelectCommand="SELECT ll.num_legislatura, 
				                                             jj.* 
				                                      FROM join_persona_risultati_elettorali AS jj 
				                                      INNER JOIN legislature AS ll 
				                                        ON jj.id_legislatura = ll.id_legislatura 
				                                      WHERE id_persona = @id_persona
				                                        AND jj.id_legislatura = @id_leg
				                                      ORDER BY jj.data_elezione DESC" 
                    				   
				                       UpdateCommand="UPDATE [join_persona_risultati_elettorali] 
				                                      SET [id_legislatura] = @id_legislatura, 
				                                          [circoscrizione] = @circoscrizione, 
				                                          [data_elezione] = @data_elezione, 
				                                          [lista] = @lista, 
				                                          [maggioranza] = @maggioranza, 
				                                          [voti] = @voti, 
				                                          [neoeletto] = @neoeletto 
				                                      WHERE [id_rec] = @id_rec"
                    				                  
				                       OnInserted="SqlDataSource1_Inserted" >
				    
				    <SelectParameters>				    
					    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
				    </SelectParameters>
				    
				    <DeleteParameters>
					    <asp:Parameter Name="id_rec" Type="Int32" />
				    </DeleteParameters>
				    
				    <UpdateParameters>
					    <asp:Parameter Name="id_legislatura" Type="Int32" />
					    <asp:Parameter Name="circoscrizione" Type="String" />
					    <asp:Parameter Name="data_elezione" Type="DateTime" />
					    <asp:Parameter Name="lista" Type="String" />
					    <asp:Parameter Name="maggioranza" Type="String" />
					    <asp:Parameter Name="voti" Type="Int32" />
					    <asp:Parameter Name="neoeletto" Type="Boolean" />
					    <asp:Parameter Name="id_rec" Type="Int32" />
				    </UpdateParameters>
				    
				    <InsertParameters>
					    <asp:Parameter Name="id_persona" Type="Int32" />
					    <asp:Parameter Name="id_legislatura" Type="Int32" />
					    <asp:Parameter Name="circoscrizione" Type="String" />
					    <asp:Parameter Name="data_elezione" Type="DateTime" />
					    <asp:Parameter Name="lista" Type="String" />
					    <asp:Parameter Name="maggioranza" Type="String" />
					    <asp:Parameter Name="voti" Type="Int32" />
					    <asp:Parameter Name="neoeletto" Type="Boolean" />
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
	           href="../persona/persona.aspx">
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