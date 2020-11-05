<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master"
         CodeFile="componenti.aspx.cs" 
         Inherits="missioni_componenti" 
         Title="Missione > Partecipanti" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit"
             TagPrefix="cc1" %>
 
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
	<tr>
	    <td>
		&nbsp;
	    </td>
	</tr>
	<tr>
	    <td>
		<b>MISSIONE &gt; PARTECIPANTI</b>
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
		    <ul>
			    <li><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
			    <li id="selected"><a id="a_componenti" runat="server">PARTECIPANTI</a></li>
		    </ul>
		</div>
		<div id="tab_content">
		    <div id="tab_content_content">
			<br />
			<asp:ScriptManager ID="ScriptManager2" 
			                   runat="server" 
			                   EnableScriptGlobalization="True">
			</asp:ScriptManager>
			    
			<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
			    <ContentTemplate>
				<asp:GridView ID="GridView1" 
				              runat="server" 
				              AllowPaging="True" 
				              PagerStyle-HorizontalAlign="Center" 
				              AllowSorting="True"
				              AutoGenerateColumns="False" 
				              CellPadding="5" 
				              CssClass="tab_gen" 
				              DataSourceID="SqlDataSource1"
				              GridLines="None" 
				              DataKeyNames="id_rec">
				              
				    <EmptyDataTemplate>
					    <table width="100%" class="tab_gen">
					        <tr>
						    <th align="center">
						        Nessun record trovato.
						    </th>
						    <th width="100">
						        <% if (role <= 2 || role == 8) { %>
						        <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
							    CausesValidation="false" />
						        <% } %>
						    </th>
					        </tr>
					    </table>
				    </EmptyDataTemplate>
				    
				    <Columns>
					    <asp:TemplateField HeaderText="Nome" SortExpression="nome">
					        <ItemTemplate>
						        <asp:LinkButton ID="lnkbtn_nome" 
		                                        runat="server"
		                                        Text='<%# Eval("nome") %>'
		                                        Font-Bold="true"
		                                        onclientclick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>' >
		                        </asp:LinkButton>
					        </ItemTemplate>
					        <ItemStyle Font-Bold="True" />
					    </asp:TemplateField>
    					
					    <asp:TemplateField HeaderText="Cognome" SortExpression="cognome">
					        <ItemTemplate>
					            <asp:LinkButton ID="lnkbtn_cognome" 
		                                        runat="server"
		                                        Text='<%# Eval("cognome") %>'
		                                        Font-Bold="true"
		                                        onclientclick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>' >
		                        </asp:LinkButton>
					        </ItemTemplate>
					        <ItemStyle Font-Bold="True" />
					    </asp:TemplateField>
    										
					    <asp:CheckBoxField DataField="partecipato" HeaderText="Partecipato?" SortExpression="partecipato"
					        ReadOnly="True" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
    					
					    <asp:CheckBoxField DataField="incluso" HeaderText="Incluso?" SortExpression="incluso"
					        ReadOnly="True" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
    					    
					    <asp:BoundField DataField="data_inizio" HeaderText="Dal" SortExpression="data_inizio"
					        DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
    					
					    <asp:BoundField DataField="data_fine" HeaderText="Al" SortExpression="data_fine"
					        DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
    					
					    <asp:TemplateField HeaderText="Sostituito Da" SortExpression="nome_completo">
					        <ItemTemplate>
					            <asp:LinkButton ID="lnkbtn_sostituto" 
		                                        runat="server"
		                                        Text='<%# Eval("nome_completo") %>'
		                                        Font-Bold="true"
		                                        onclientclick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_sostituto")) %>' >
		                        </asp:LinkButton>
					        
					        </ItemTemplate>
					        <ItemStyle Font-Bold="True" />
					    </asp:TemplateField>
    					
					    <asp:TemplateField>
					        <ItemTemplate>
						    <asp:LinkButton ID="LinkButtonDettagli" runat="server" CausesValidation="False" Text="Dettagli"
						        OnClick="LinkButtonDettagli_Click">
						    </asp:LinkButton>
					        </ItemTemplate>
					        
					        <HeaderTemplate>
						    <% if (role <= 2  || role == 8) { %>
						    <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
						        CausesValidation="false" />
						    <% } %>
					        </HeaderTemplate>
					        
					        <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
					    </asp:TemplateField>
				    </Columns>
				</asp:GridView>
				<asp:SqlDataSource ID="SqlDataSource1" 
				                   runat="server" 
				                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                   
				                   SelectCommand="SELECT pp1.id_persona, 
				                                         pp1.nome, 
				                                         pp1.cognome, 
				                                         jj.id_rec, 
				                                         jj.partecipato, 
				                                         jj.incluso, 
				                                         jj.data_inizio, 
				                                         jj.data_fine, 
				                                         pp2.id_persona AS id_sostituto, 
				                                         pp2.nome + ' ' + pp2.cognome AS nome_completo
					                              FROM join_persona_missioni AS jj 
					                              INNER JOIN persona AS pp1 
					                                ON jj.id_persona = pp1.id_persona
					                              LEFT OUTER JOIN persona AS pp2 
					                                ON jj.sostituito_da = pp2.id_persona
					                              WHERE jj.deleted = 0 
					                                AND pp1.deleted = 0					                                
					                                AND jj.id_missione = @id" >
				    <SelectParameters>
					    <asp:SessionParameter Name="id" SessionField="id_missione" />
				    </SelectParameters>
				</asp:SqlDataSource>
			    </ContentTemplate>
			</asp:UpdatePanel>
			
			<br />
			
			<div align="right">
			    <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click">
			    <img src="../img/page_white_excel.png" alt="" align="top" /> Esporta</asp:LinkButton>
			    -
			    <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click">
			    <img src="../img/page_white_acrobat.png" alt="" align="top" /> Esporta</asp:LinkButton>
			</div>
			
			<asp:Panel ID="PanelDetails" 
		               runat="server" 
		               BackColor="White" 
		               BorderColor="DarkSeaGreen"
		               BorderWidth="2px" 
		               Width="500px" 
		               ScrollBars="Vertical" 
		               Style="padding: 10px; display: none; max-height: 500px;">
			    <div align="center">
				<br />
				<h3>
				    MISSIONI
				</h3>
				<br />
			    <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
				<ContentTemplate>
				    <asp:DetailsView ID="DetailsView1" 
				                     runat="server" 
				                     AutoGenerateRows="False" 
				                     DataKeyNames="id_rec" 
				                     Width="420px"
					                 DataSourceID="SqlDataSource2" 
					                 CssClass="tab_det" 
                					
					                 OnModeChanged="DetailsView1_ModeChanged" 
					                 OnItemDeleted="DetailsView1_ItemDeleted"
					                 OnItemInserted="DetailsView1_ItemInserted" 
					                 OnItemInserting="DetailsView1_ItemInserting"
					                 OnItemUpdated="DetailsView1_ItemUpdated" 
					                 OnItemUpdating="DetailsView1_ItemUpdating">
					                 
					    <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
					    <RowStyle HorizontalAlign="left" />
					    <HeaderStyle Font-Bold="False" />
					    
					    <Fields>
					        <asp:TemplateField HeaderText="Consigliere">
						        <ItemTemplate>
						            <asp:Label ID="label_nome_completo" 
						                       runat="server" 
						                       Text='<%# Eval("nome_completo") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <InsertItemTemplate>
									<asp:HiddenField ID="TextBoxPersonaId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
						            <asp:TextBox ID="TextBoxPersona" 
						                         runat="server" 
						                         Text='<%# Bind("nome_completo") %>'>
						            </asp:TextBox>
    						        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorPersona" 
						                                        ControlToValidate="TextBoxPersona"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
    							                                
						            <div id="DivPersona">
						            </div>
    						        
						            <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona" 
						                                      runat="server"
							                                  EnableCaching="True" 
							                                  TargetControlID="TextBoxPersona" 
							                                  ServicePath="~/ricerca_persone.asmx"
							                                  ServiceMethod="RicercaPersoneAll" 
							                                  MinimumPrefixLength="1" 
							                                  CompletionInterval="0"
							                                  CompletionListElementID="DivPersona" 
							                                  CompletionSetCount="15"
															  OnClientItemSelected="autoCompletePersonaSelected">
    							                              
							            <Animations>
							                <OnShow>
								                <Sequence>
								                    <OpacityAction Opacity='0' ></OpacityAction>
								                    <HideAction Visible='true' ></HideAction>
								                    <StyleAction Attribute='fontSize' Value='8pt' ></StyleAction>
								                    <Parallel Duration='.15'>
									                    <FadeIn ></FadeIn>
								                    </Parallel>
								                </Sequence>
							                </OnShow>
    							            
							                <OnHide>
								                <Parallel Duration='.15'>
								                    <FadeOut></FadeOut>
								                </Parallel>
							                </OnHide>
							            </Animations>
						            </cc1:AutoCompleteExtender>
						        </InsertItemTemplate>
    						    
						        <EditItemTemplate>
									<asp:HiddenField ID="TextBoxPersonaId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
						            <asp:TextBox ID="TextBoxPersona" 
						                         runat="server" 
						                         Text='<%# Bind("nome_completo") %>'>
						            </asp:TextBox>
    						        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorPersona" 
						                                        ControlToValidate="TextBoxPersona"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
    						        
						            <div id="DivPersona">
						            </div>
    						        
						            <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona" 
						                                      runat="server" 
						                                      EnableCaching="True"
							                                  TargetControlID="TextBoxPersona" 
							                                  ServicePath="~/ricerca_persone.asmx"
							                                  ServiceMethod="RicercaPersoneAll" 
							                                  MinimumPrefixLength="1" 
							                                  CompletionInterval="0" 
							                                  CompletionListElementID="DivPersona"
							                                  CompletionSetCount="15"
															  OnClientItemSelected="autoCompletePersonaSelected">
							            <Animations>
							                <OnShow>
								                <Sequence>
								                    <OpacityAction Opacity='0' ></OpacityAction>
								                    <HideAction Visible='true' ></HideAction>
								                    <StyleAction Attribute='fontSize' Value='8pt' ></StyleAction>
								                    <Parallel Duration='.15'>
									                    <FadeIn ></FadeIn>
								                    </Parallel>
								                </Sequence>
							                </OnShow>
    							            
							                <OnHide>
								                <Parallel Duration='.15'>
								                    <FadeOut ></FadeOut>
								                </Parallel>
							                </OnHide>
							            </Animations>
						            </cc1:AutoCompleteExtender>
						        </EditItemTemplate>
					        </asp:TemplateField>    					    					        
					        
					        <asp:CheckBoxField DataField="partecipato" HeaderText="Partecipato?" SortExpression="partecipato" />
					        
					        <asp:CheckBoxField DataField="incluso" HeaderText="Incluso?" SortExpression="incluso" />
					        
					        <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
						        <ItemTemplate>
						            <asp:Label ID="LabelDataInizio" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="DataInizioEdit" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioEdit" runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtenderDataInizioEdit" runat="server" TargetControlID="DataInizioEdit"
							        PopupButtonID="ImageDataInizioEdit" Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="DataInizioEdit"
							        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" />
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="DataInizioInsert" runat="server" ></asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioInsert" runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtenderDataInizioInsert" runat="server" TargetControlID="DataInizioInsert"
							        PopupButtonID="ImageDataInizioInsert" Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="DataInizioInsert"
							        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" />
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
						        <ItemTemplate>
						            <asp:Label ID="LabelDataFine" runat="server" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'></asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="DataFineEdit" runat="server" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineEdit" runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtenderDataFineEdit" runat="server" TargetControlID="DataFineEdit"
							        PopupButtonID="ImageDataFineEdit" Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFine" ControlToValidate="DataFineEdit"
							        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" />
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="DataFineInsert" runat="server" ></asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineInsert" runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtenderDataFineInsert" runat="server" TargetControlID="DataFineInsert"
							        PopupButtonID="ImageDataFineInsert" Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFine" ControlToValidate="DataFineInsert"
							        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" />
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Sostituito da">
						    <ItemTemplate>
						        <asp:Label ID="label_nome_sostituto" runat="server" Text='<%# Eval("nome_sostituto") %>'>
						        </asp:Label>
						    </ItemTemplate>
						    
						    <InsertItemTemplate>
								<asp:HiddenField ID="TextBoxSostitutoId" runat="server" Value='<%# Bind("id_sostituto") %>'></asp:HiddenField>
						        <asp:TextBox ID="TextBoxSostitutoInsert" runat="server" Text='<%# Bind("nome_sostituto") %>'></asp:TextBox>
						        <div id="DivSostitutoInsert">
						        </div>
						        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostituto" 
						                                  runat="server"
							                              EnableCaching="True" 
							                              TargetControlID="TextBoxSostitutoInsert" 
							                              ServicePath="~/ricerca_persone.asmx"
							                              ServiceMethod="RicercaPersoneAll" 
							                              MinimumPrefixLength="1" 
							                              CompletionInterval="0"
							                              CompletionListElementID="DivSostitutoInsert" 
							                              CompletionSetCount="15"
														  OnClientItemSelected="autoCompleteSostitutoSelected">
							    <Animations>
						            <OnShow>
						                <Sequence>
							            <OpacityAction Opacity='0' ></OpacityAction>
							            <HideAction Visible='true' ></HideAction>
							            <StyleAction Attribute='fontSize' Value='8pt' ></StyleAction>
							            <Parallel Duration='.15'>
							                <FadeIn ></FadeIn>
							            </Parallel>
						                </Sequence>
						            </OnShow>
						            <OnHide>
						                <Parallel Duration='.15'>
							            <FadeOut ></FadeOut>
						                </Parallel>
						            </OnHide>
							    </Animations>
						        </cc1:AutoCompleteExtender>
						    </InsertItemTemplate>
						    
						    <EditItemTemplate>
								<asp:HiddenField ID="TextBoxSostitutoId" runat="server" Value='<%# Bind("id_sostituto") %>'></asp:HiddenField>
						        <asp:TextBox ID="TextBoxSostitutoEdit" 
						                     runat="server" 
						                     Text='<%# Bind("nome_sostituto") %>'>
						        </asp:TextBox>
						        <div id="DivSostitutoEdit">
						        </div>
						        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostituto" 
						                                  runat="server" 
						                                  EnableCaching="True"
							                              TargetControlID="TextBoxSostitutoEdit" 
							                              ServicePath="~/ricerca_persone.asmx"
							                              ServiceMethod="RicercaPersoneAll" 
							                              MinimumPrefixLength="1" 
							                              CompletionInterval="0" 
							                              CompletionListElementID="DivSostitutoEdit"
							                              CompletionSetCount="15"
														  OnClientItemSelected="autoCompleteSostitutoSelected">
							    <Animations>
						            <OnShow>
						                <Sequence>
							            <OpacityAction Opacity='0' ></OpacityAction>
							            <HideAction Visible='true' ></HideAction> 
							            <StyleAction Attribute='fontSize' Value='8pt' ></StyleAction>
							            <Parallel Duration='.15'>
							                <FadeIn ></FadeIn>
							            </Parallel>
						                </Sequence>
						            </OnShow>
						            <OnHide>
						                <Parallel Duration='.15'>
							                <FadeOut ></FadeOut>
						                </Parallel>
						            </OnHide>
							    </Animations>
						        </cc1:AutoCompleteExtender>
						    </EditItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Note" SortExpression="note">
						    <EditItemTemplate>
						        <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
							    Text='<%# Bind("note") %>'></asp:TextBox>
						    </EditItemTemplate>
						    <InsertItemTemplate>
						        <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
							    Text='<%# Bind("note") %>'></asp:TextBox>
						    </InsertItemTemplate>
						    <ItemTemplate>
						        <asp:Label ID="LabelNote" runat="server" Text='<%# Bind("note") %>'></asp:Label>
						    </ItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField ShowHeader="False">
						    <EditItemTemplate>
						        <asp:Button ID="Button1" runat="server" CausesValidation="True" CommandName="Update"
							    Text="Aggiorna" ValidationGroup="ValidGroup" />
						        <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
							    Text="Annulla" />
						    </EditItemTemplate>
						    <InsertItemTemplate>
						        <asp:Button ID="Button1" runat="server" CausesValidation="True" CommandName="Insert"
							    Text="Inserisci" ValidationGroup="ValidGroup" />
						        <asp:Button ID="Button4" runat="server" CausesValidation="False" Text="Chiudi" CssClass="button"
							    OnClick="ButtonAnnulla_Click" CommandName="Cancel" />
						    </InsertItemTemplate>
						    <ItemTemplate>
						        <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
							    Text="Modifica" Visible="<%# (role <= 2  || role == 8) ? true : false %>" />
						        <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
							    Text="Elimina" Visible="<%# (role <= 2  || role == 8) ? true : false %>" />
						        <asp:Button ID="Button4" runat="server" CausesValidation="False" Text="Chiudi" CssClass="button"
							    OnClick="ButtonAnnulla_Click" CommandName="Cancel" />
						    </ItemTemplate>
						    <ControlStyle CssClass="button" />
					        </asp:TemplateField>
					    </Fields>
				    </asp:DetailsView>
				    
				    <asp:SqlDataSource ID="SqlDataSource2" 
				                       runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                  
					                   DeleteCommand="UPDATE [join_persona_missioni] 
					                                  SET [deleted] = 1 
					                                  WHERE [id_rec] = @id_rec"
					                  
					                   InsertCommand="INSERT INTO [join_persona_missioni] ([id_missione], 
					                                                                       [id_persona], 
					                                                                       [note], 
					                                                                       [incluso], 
					                                                                       [partecipato], 
					                                                                       [data_inizio], 
					                                                                       [data_fine], 
					                                                                       [sostituito_da]) 
					                                  VALUES (@id_missione, 
					                                          @id_persona, 
					                                          @note, 
					                                          @incluso, 
					                                          @partecipato, 
					                                          @data_inizio, 
					                                          @data_fine, 
					                                          @sostituito_da);
					                                  SELECT @id_rec = SCOPE_IDENTITY();"
					                  
					                   SelectCommand="SELECT jj.*, 
					                                         pp.cognome + ' ' +  pp.nome AS nome_completo, 
					                                         pp2.cognome + ' ' +  pp2.nome AS nome_sostituto,
						                                     pp2.id_persona as id_sostituto
						                              FROM join_persona_missioni AS jj 
						                              INNER JOIN persona AS pp 
						                                ON pp.id_persona = jj.id_persona 
						                              INNER JOIN missioni AS mm 
						                                ON jj.id_missione = mm.id_missione
						                              LEFT OUTER JOIN persona AS pp2 
						                                ON jj.sostituito_da = pp2.id_persona
						                              WHERE id_rec = @id_rec" 
					                  
					                   UpdateCommand="UPDATE [join_persona_missioni] 
					                                  SET [id_missione] = @id_missione, 
					                                      [id_persona] = @id_persona, 
					                                      [note] = @note, 
					                                      [incluso] = @incluso, 
					                                      [partecipato] = @partecipato, 
					                                      [data_inizio] = @data_inizio, 
					                                      [data_fine] = @data_fine, 
					                                      [sostituito_da] = @sostituito_da 
					                                  WHERE [id_rec] = @id_rec"
					                  
					                   OnInserted="SqlDataSource2_Inserted">
					<SelectParameters>
					    <asp:ControlParameter ControlID="GridView1" Name="id_rec" PropertyName="SelectedValue"
						Type="Int32" />
					</SelectParameters>
					
					<DeleteParameters>
					    <asp:Parameter Name="id_rec" Type="Int32" />
					</DeleteParameters>
					
					<UpdateParameters>
					    <asp:Parameter Name="id_missione" Type="Int32" />
					    <asp:Parameter Name="id_persona" Type="Int32" />
					    <asp:Parameter Name="note" Type="String" />
					    <asp:Parameter Name="incluso" Type="Boolean" />
					    <asp:Parameter Name="partecipato" Type="Boolean" />
					    <asp:Parameter Name="sostituito_da" Type="Int32" />
					    <asp:Parameter Name="data_inizio" Type="DateTime" />
					    <asp:Parameter Name="data_fine" Type="DateTime" />
					    <asp:Parameter Name="id_rec" Type="Int32" />
					</UpdateParameters>
					
					<InsertParameters>
					    <asp:Parameter Name="id_missione" Type="Int32" />
					    <asp:Parameter Name="id_persona" Type="Int32" />
					    <asp:Parameter Name="note" Type="String" />
					    <asp:Parameter Name="incluso" Type="Boolean" />
					    <asp:Parameter Name="partecipato" Type="Boolean" />
					    <asp:Parameter Name="sostituito_da" Type="Int32" />
					    <asp:Parameter Name="data_inizio" Type="DateTime" />
					    <asp:Parameter Name="data_fine" Type="DateTime" />
					    <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
					</InsertParameters>
				    </asp:SqlDataSource>
				</ContentTemplate>
			    </asp:UpdatePanel>
			    </div>
			    <br />
			    <asp:UpdatePanel ID="UpdatePanelEsporta" runat="server" UpdateMode="Conditional">
				<ContentTemplate>
				    <div align="right">
					<asp:LinkButton ID="LinkButtonExcelDetails" runat="server" OnClick="LinkButtonExcelDetails_Click">
					Esporta 
					<img src="../img/page_white_excel.png" alt="" align="top" /><br />
					</asp:LinkButton>
					<asp:LinkButton ID="LinkButtonPdfDetails" runat="server" OnClick="LinkButtonPdfDetails_Click">
					Esporta 
					<img src="../img/page_white_acrobat.png" alt="" align="top" />
					</asp:LinkButton>
				    </div>
				</ContentTemplate>
				<Triggers>
				    <asp:PostBackTrigger ControlID="LinkButtonExcelDetails" />
				    <asp:PostBackTrigger ControlID="LinkButtonPdfDetails" />
				</Triggers>
			    </asp:UpdatePanel>
			    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" BehaviorID="ModalPopup1" runat="server" PopupControlID="PanelDetails"
				BackgroundCssClass="modalBackground" DropShadow="true" TargetControlID="ButtonDetailsFake" />
			    <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
			</asp:Panel>
		    </div>
		</div>
		<%--Fix per lo stile dei calendarietti--%>
		<asp:TextBox ID="TextBoxCalendarFake" runat="server" style="display: none;"></asp:TextBox>
		<cc1:CalendarExtender ID="CalendarExtenderFake" runat="server" TargetControlID="TextBoxCalendarFake" Format="dd/MM/yyyy"></cc1:CalendarExtender>
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
	           href="../missioni/gestisciMissioni.aspx">
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

	  <script type="text/javascript">

        function autoCompletePersonaSelected(source, eventArgs) {
            var id = eventArgs.get_value();
            var text = eventArgs.get_text();

            //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

            $('input[id$=_TextBoxPersonaId').val(id);
		}

          function autoCompleteSostitutoSelected(source, eventArgs) {
              var id = eventArgs.get_value();
              var text = eventArgs.get_text();

              //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

              $('input[id$=_TextBoxSostitutoId').val(id);
          }

      </script>

</asp:Content>
