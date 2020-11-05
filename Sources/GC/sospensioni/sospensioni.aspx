<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="sospensioni.aspx.cs" 
         Inherits="sospensioni_sospensioni" 
         Title="Persona > Sospensioni" %>

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
		<asp:DataList ID="DataList1" 
		              runat="server" 
		              DataSourceID="SqlDataSourceHead" 
		              Width="50%">
		    <ItemTemplate>
			<table>
			    <tr>
				<td width="50">
				    <img alt="" 
				         src="<%= photoName %>" 
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
					    <asp:SqlDataSource ID="SqlDataSourceLegislature" 
					                       runat="server" 
					                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                   SelectCommand="SELECT [id_legislatura], 
						                                         [num_legislatura] 
						                                  FROM [legislature]">
					    </asp:SqlDataSource>
					</td>
					<td valign="top" width="230">
					    Seleziona data:
					    <asp:TextBox ID="TextBoxFiltroData" runat="server" Width="70px"></asp:TextBox>
					    <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
					    <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="TextBoxFiltroData"
						PopupButtonID="ImageFiltroData" Format="dd/MM/yyyy">
					    </cc1:CalendarExtender>
					    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" ControlToValidate="TextBoxFiltroData"
						runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						ValidationGroup="FiltroData" />
					    <asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
					    </asp:ScriptManager>
					</td>
					<td valign="top">
					    <asp:Button ID="ButtonFiltri" runat="server" Text="Applica" OnClick="ButtonFiltri_Click"
						ValidationGroup="FiltroData" />
					</td>
				    </tr>
				</table>
				<br />
				<br />
				
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
						    <% if (role <= 2) { %>
						    <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
							CausesValidation="false" />
						    <% } %>
						</th>
					    </tr>
					</table>
				    </EmptyDataTemplate>
				    
				    <Columns>
					    <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
					        <ItemTemplate>
						        <asp:LinkButton ID="lnkbtn_leg" 
		                                        runat="server"
		                                        Text='<%# Eval("num_legislatura") %>'
		                                        Font-Bold="true"
		                                        OnClientClick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura"), null) %>' >
		                        </asp:LinkButton>
					        </ItemTemplate>
					        <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
					    </asp:TemplateField>
					    
					    <asp:BoundField DataField="tipo" 
					                    HeaderText="Tipo" 
					                    SortExpression="tipo" 
					                    ItemStyle-HorizontalAlign="center" 
					                    ItemStyle-Width="100px" />
					    
					    <asp:BoundField DataField="data_inizio" HeaderText="Dal" SortExpression="data_inizio"
					        DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
					    
					    <asp:BoundField DataField="data_fine" HeaderText="Al" SortExpression="data_fine"
					        DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
					    
					    <asp:TemplateField HeaderText="Sostituito da" SortExpression="nome_completo">
					        <ItemTemplate>
						        <asp:LinkButton ID="lnkbtn_sostituto" 
		                                        runat="server"
		                                        Text='<%# Eval("nome_completo") %>'
		                                        Font-Bold="true"
		                                        OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_sostituto"), Eval("id_legislatura")) %>' >
		                        </asp:LinkButton>
					        </ItemTemplate>
					        <ItemStyle Font-Bold="True" />
					    </asp:TemplateField>
					    
					    <asp:BoundField DataField="descrizione_causa" HeaderText="Causa" SortExpression="descrizione_causa" />
					    
					    <asp:TemplateField>
					        <ItemTemplate>
						        <asp:LinkButton ID="LinkButtonDettagli" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        Text="Dettagli"
						                        OnClick="LinkButtonDettagli_Click">
						        </asp:LinkButton>
					        </ItemTemplate>
					        <HeaderTemplate>
						    <% if (role <= 2) { %>
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
				                   
				                   SelectCommand="SELECT ll.id_legislatura, 
				                                         ll.num_legislatura, 
				                                         jj.*, 
				                                         pp.id_persona AS id_sostituto, 
				                                         pp.cognome + ' ' +  pp.nome AS nome_completo, 
				                                         cc.descrizione_causa
					                              FROM join_persona_sospensioni AS jj
					                              LEFT OUTER JOIN persona AS pp 
					                                ON pp.id_persona = jj.sostituito_da 
					                              LEFT OUTER JOIN tbl_cause_fine AS cc 
					                                ON jj.id_causa_fine = cc.id_causa 
					                              INNER JOIN legislature AS ll 
					                                ON jj.id_legislatura = ll.id_legislatura
					                              WHERE jj.deleted = 0 
					                                AND jj.id_persona = @id">
				    
				    <SelectParameters>
					    <asp:SessionParameter Name="id" SessionField="id_persona" />
				    </SelectParameters>
				</asp:SqlDataSource>
				
			    </ContentTemplate>
			</asp:UpdatePanel>
			
			<br />
			
			<div align="right">
			    <asp:LinkButton ID="LinkButtonExcel" 
			                    runat="server" 
			                    OnClick="LinkButtonExcel_Click">
			        <img src="../img/page_white_excel.png" alt="" align="top" /> 
			        Esporta
			    </asp:LinkButton>
			    -
			    <asp:LinkButton ID="LinkButtonPdf" 
			                    runat="server" 
			                    OnClick="LinkButtonPdf_Click">
			        <img src="../img/page_white_acrobat.png" alt="" align="top" />
			        Esporta
			    </asp:LinkButton>
			</div>
			
			<asp:Panel ID="PanelDetails" 
			           runat="server" 
			           BackColor="White" 
			           BorderColor="DarkSeaGreen"
			           BorderWidth="2px" 
			           Width="500" 
			           ScrollBars="Vertical" 
			           Style="padding: 10px; display: none; max-height: 500px;">
			    <div align="center">
				<br />
				<h3>
				    SOSPENSIONI
				</h3>
				<br />
			    <asp:UpdatePanel ID="UpdatePanelDetails" 
			                     runat="server" 
			                     UpdateMode="Conditional">
				    <ContentTemplate>
				        <asp:DetailsView ID="DetailsView1" 
				                         runat="server" 
				                         AutoGenerateRows="False" 
				                         CssClass="tab_det" 
				                         Width="420px"
					                     DataKeyNames="id_rec" 
					                     DataSourceID="SqlDataSource2" 
					                     					                     
					                     OnModeChanged="DetailsView1_ModeChanged" 
					                     OnItemInserted="DetailsView1_ItemInserted"
					                     OnItemInserting="DetailsView1_ItemInserting" 
					                     OnItemUpdated="DetailsView1_ItemUpdated"
					                     OnItemUpdating="DetailsView1_ItemUpdating" 
					                     OnItemDeleted="DetailsView1_ItemDeleted">
    					
					        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
					        <RowStyle HorizontalAlign="left" />
					        <HeaderStyle Font-Bold="False" />
    					
					        <Fields>
					            <asp:TemplateField HeaderText="Legislatura">
						            <ItemTemplate>
						                <asp:Label ID="LabelLeg" 
						                           runat="server" 
						                           Text='<%# Bind("num_legislatura") %>'></asp:Label>
						            </ItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:DropDownList ID="DropDownListLeg" 
						                                  runat="server" 
						                                  DataSourceID="SqlDataSourceLeg"
							                              SelectedValue='<%# Eval("id_legislatura") %>' 
							                              DataTextField="num_legislatura"
							                              DataValueField="id_legislatura" 
							                              Width="200px" 
							                              AppendDataBoundItems="True">
							                <asp:ListItem Value="" Text="(seleziona)" />
						                </asp:DropDownList>
						                <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" 
						                                            ControlToValidate="DropDownListLeg"
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Campo obbligatorio." 
							                                        ValidationGroup="ValidGroup" />
						                    <asp:SqlDataSource ID="SqlDataSourceLeg" 
						                                       runat="server" 
						                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
							                                   SelectCommand="SELECT id_legislatura, 
							                                                         num_legislatura 
							                                                  FROM legislature
							                                                  ORDER BY durata_legislatura_da DESC">
						                </asp:SqlDataSource>
						            </InsertItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:DropDownList ID="DropDownListLeg" 
						                                  runat="server" 
						                                  DataSourceID="SqlDataSourceLeg"
							                              SelectedValue='<%# Eval("id_legislatura") %>' 
							                              DataTextField="num_legislatura"
							                              DataValueField="id_legislatura" 
							                              Width="200px" 
							                              AppendDataBoundItems="True">
							                <asp:ListItem Value="" Text="(seleziona)" />
						                </asp:DropDownList>
						                <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" 
						                                            ControlToValidate="DropDownListLeg"
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Campo obbligatorio." 
							                                        ValidationGroup="ValidGroup" />
						                <asp:SqlDataSource ID="SqlDataSourceLeg" 
						                                   runat="server" 
						                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
							                               SelectCommand="SELECT id_legislatura, 
							                                                     num_legislatura 
							                                              FROM legislature
							                                              ORDER BY durata_legislatura_da DESC">
						                </asp:SqlDataSource>
						            </EditItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Tipo" SortExpression="tipo">
						            <ItemTemplate>
						                <asp:Label ID="LabelTipo" 
						                           runat="server" 
						                           Text='<%# Eval("tipo") %>'>
						                </asp:Label>
						            </ItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:Label ID="LabelTipoEdit" 
						                           runat="server" 
						                           Text='<%# Eval("tipo") %>'>
						                </asp:Label>
						            </EditItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:RadioButtonList runat="Server" 
						                                     ID="RadioButtonListTipoInsert" 
						                                     AutoPostBack="true" 						                                     						                                     					                                      
						                                     OnSelectedIndexChanged="RadioButtonListTipoInsert_SelectedIndexChanged">
							                <asp:ListItem Value="Sospensione" Text="Sospensione" Selected="True" />
							                <asp:ListItem Value="Rientro" Text="Rientro" />
						                </asp:RadioButtonList>
						            </InsertItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Numero Pratica" SortExpression="numero_pratica">
						            <ItemTemplate>
						                <asp:Label ID="LabelNumeroPratica" 
						                           runat="server" 
						                           Text='<%# Bind("numero_pratica") %>'></asp:Label>
						            </ItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:TextBox ID="TextBoxNumeroPratica" 
						                             runat="server" 
						                             Text='<%# Bind("numero_pratica") %>'
							                         MaxLength='50'>
							            </asp:TextBox>
						                <asp:RequiredFieldValidator ID="RequiredFieldValidatorNumeroPratica" 
						                                            ControlToValidate="TextBoxNumeroPratica"
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Campo obbligatorio." 
							                                        ValidationGroup="ValidGroup" />
						                <asp:RegularExpressionValidator ID="RegularExpressionValidatorNumeroPratica" 
						                                                ControlToValidate="TextBoxNumeroPratica"
							                                            runat="server" 
							                                            Display="Dynamic" 
							                                            ErrorMessage="Solo cifre ammesse." 
							                                            ValidationExpression="^[0-9]+$"
							                                            ValidationGroup="ValidGroup" />
						            </EditItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:TextBox ID="TextBoxNumeroPratica" 
						                             runat="server" 
						                             Text='<%# Bind("numero_pratica") %>'
							                         MaxLength='50'>
							            </asp:TextBox>
							            
						                <asp:RequiredFieldValidator ID="RequiredFieldValidatorNumeroPratica" 
						                                            ControlToValidate="TextBoxNumeroPratica"
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Campo obbligatorio." 
							                                        ValidationGroup="ValidGroup" >
							            </asp:RequiredFieldValidator>
						                
						                <asp:RegularExpressionValidator ID="RegularExpressionValidatorNumeroPratica" 
						                                                ControlToValidate="TextBoxNumeroPratica"
							                                            runat="server" 
							                                            Display="Dynamic" 
							                                            ErrorMessage="Ammesse cifre, '.' e '/'." 
							                                            ValidationExpression="^[0-9./]+$"
							                                            ValidationGroup="ValidGroup" >
							            </asp:RegularExpressionValidator>
						            </InsertItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Numero Delibera" SortExpression="numero_delibera">
						            <ItemTemplate>
						                <asp:Label ID="LabelNumeroDelibera" runat="server" Text='<%# Bind("numero_delibera") %>'></asp:Label>
						            </ItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:TextBox ID="TextBoxLabelNumeroDelibera" runat="server" Text='<%# Bind("numero_delibera") %>'
							            MaxLength='50'></asp:TextBox>
						                <asp:RegularExpressionValidator ID="RegularExpressionValidatorNumeroDelibera" ControlToValidate="TextBoxLabelNumeroDelibera"
							            runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							            ValidationGroup="ValidGroup" />
						            </EditItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:TextBox ID="TextBoxLabelNumerodeLibera" runat="server" Text='<%# Bind("numero_delibera") %>'
							            MaxLength='50'></asp:TextBox>
						                <asp:RegularExpressionValidator ID="RegularExpressionValidatorNumeroDelibera" ControlToValidate="TextBoxLabelNumeroDelibera"
							            runat="server" Display="Dynamic" ErrorMessage="Ammesse cifre, '.' e '/'." ValidationExpression="^[0-9./]+$"
							            ValidationGroup="ValidGroup" />
						            </InsertItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Data Delibera" SortExpression="data_delibera">
						            <ItemTemplate>
						                <asp:Label ID="LabelDataDelibera" 
						                           runat="server" 
						                           Text='<%# Eval("data_delibera", "{0:dd/MM/yyyy}") %>'>
						                </asp:Label>
						            </ItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:TextBox ID="DataDeliberaEdit" 
						                             runat="server" 
						                             Text='<%# Eval("data_delibera", "{0:dd/MM/yyyy}") %>'>
						                </asp:TextBox>
						                <img alt="calendar" src="../img/calendar_month.png" id="ImageDataDeliberaEdit" runat="server" />
						                <cc1:CalendarExtender ID="CalendarExtenderDataDeliberaEdit" 
						                                      runat="server" 
						                                      TargetControlID="DataDeliberaEdit"
							                                  PopupButtonID="ImageDataDeliberaEdit" 
							                                  Format="dd/MM/yyyy">
						                </cc1:CalendarExtender>
						                <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataDelibera" 
						                                                ControlToValidate="DataDeliberaEdit"
							                                            runat="server" 
							                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                            Display="Dynamic"
							                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                            ValidationGroup="ValidGroup" />
						            </EditItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:TextBox ID="DataDeliberaInsert" 
						                             runat="server" >
						                </asp:TextBox>
						                <img alt="calendar" src="../img/calendar_month.png" id="ImageDataDeliberaInsert" runat="server" />
						                <cc1:CalendarExtender ID="CalendarExtenderDataDeliberaInsert" 
						                                      runat="server" 
						                                      TargetControlID="DataDeliberaInsert"
							                                  PopupButtonID="ImageDataDeliberaInsert" 
							                                  Format="dd/MM/yyyy">
						                </cc1:CalendarExtender>
						                <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataDelibera" 
						                                                ControlToValidate="DataDeliberaInsert"
							                                            runat="server" 
							                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                            Display="Dynamic"
							                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                            ValidationGroup="ValidGroup" />
						            </InsertItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Tipo Delibera">
						        <ItemTemplate>
						            <asp:Label ID="label_tipo_delibera" runat="server" Text='<%# Eval("nome_delibera") %>'>
						            </asp:Label>
						        </ItemTemplate>
        						
						        <InsertItemTemplate>
						            <asp:DropDownList ID="DropDownListTipoDelibera" runat="server" DataSourceID="SqlDataSourceTipoDelibera"
							        DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera") %>'
							        Width="200px" AppendDataBoundItems="true">
							        <asp:ListItem Text="(seleziona)" Value="" />
						            </asp:DropDownList>
						            <asp:SqlDataSource ID="SqlDataSourceTipoDelibera" 
						                               runat="server" 
						                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
							                           SelectCommand="SELECT * 
							                                          FROM [tbl_delibere]">
							        </asp:SqlDataSource>
						        </InsertItemTemplate>
        						
						        <EditItemTemplate>
						            <asp:DropDownList ID="DropDownListTipoDelibera" runat="server" DataSourceID="SqlDataSourceTipoDelibera"
							        DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera") %>'
							        Width="200px" AppendDataBoundItems="true">
							        <asp:ListItem Text="(seleziona)" Value="" />
						            </asp:DropDownList>
						            <asp:SqlDataSource ID="SqlDataSourceTipoDelibera" 
						                               runat="server" 
						                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        							                   
							                           SelectCommand="SELECT * 
							                                          FROM tbl_delibere">
							        </asp:SqlDataSource>
						        </EditItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Sostituito Dal" SortExpression="data_inizio">
						            <ItemTemplate>
						                <asp:Label ID="LabelDataInizio" 
						                           runat="server" 
						                           Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
						                </asp:Label>
						            </ItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:TextBox ID="DataInizioEdit" 
						                             runat="server" 
						                             Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
						                </asp:TextBox>
						                
						                <img alt="calendar" 
						                     src="../img/calendar_month.png" 
						                     id="ImageDataInizioEdit" 
						                     runat="server" />
						                     
						                <cc1:CalendarExtender ID="CalendarExtenderDataInizioEdit" 
						                                      runat="server" 
						                                      TargetControlID="DataInizioEdit"
							                                  PopupButtonID="ImageDataInizioEdit" 
							                                  Format="dd/MM/yyyy">
						                </cc1:CalendarExtender>
						                
						                <asp:RequiredFieldValidator ID="RequiredFieldValidator_DataInizio" 
						                                            ControlToValidate="DataInizioEdit"
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Campo obbligatorio." 
							                                        ValidationGroup="ValidGroup" >
							            </asp:RequiredFieldValidator>
						                
						                <asp:RegularExpressionValidator ID="RegularExpressionValidator_DataInizio_Edit" 
						                                                ControlToValidate="DataInizioEdit"
							                                            runat="server" 
							                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                            Display="Dynamic"
							                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                            ValidationGroup="ValidGroup" >
							            </asp:RegularExpressionValidator>
						            </EditItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:TextBox ID="DataInizioInsert" 
						                             runat="server" >
						                </asp:TextBox>
						                
						                <img alt="calendar" 
						                src="../img/calendar_month.png" 
						                id="ImageDataInizioInsert" 
						                runat="server" />
						                
						                <cc1:CalendarExtender ID="CalendarExtenderDataInizioInsert" 
						                                      runat="server" 
						                                      TargetControlID="DataInizioInsert"
							                                  PopupButtonID="ImageDataInizioInsert" 
							                                  Format="dd/MM/yyyy">
						                </cc1:CalendarExtender>			
						                
						                <asp:RequiredFieldValidator ID="RequiredFieldValidator_DataInizio_Insert" 
						                                            ControlToValidate="DataInizioInsert"
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Campo obbligatorio." 
							                                        ValidationGroup="ValidGroup" >
							            </asp:RequiredFieldValidator>
						                			                
						                <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizio" 
						                                                ControlToValidate="DataInizioInsert"
							                                            runat="server" 
							                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                            Display="Dynamic"
							                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                            ValidationGroup="ValidGroup" >
							            </asp:RegularExpressionValidator>
						            </InsertItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Sostituito Al" SortExpression="data_fine">
						            <ItemTemplate>
						                <asp:Label ID="LabelDataFine" 
						                           runat="server" 
						                           Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
						                </asp:Label>
						            </ItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:TextBox ID="DataFineEdit" 
						                             runat="server" 
						                             Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
						                </asp:TextBox>
						                <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineEdit" runat="server" />
						                <cc1:CalendarExtender ID="CalendarExtenderDataFineEdit" 
						                                      runat="server" 
						                                      TargetControlID="DataFineEdit"
							                                  PopupButtonID="ImageDataFineEdit" 
							                                  Format="dd/MM/yyyy">
						                </cc1:CalendarExtender>
						                <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFine" 
						                                                ControlToValidate="DataFineEdit"
							                                            runat="server" 
							                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                            Display="Dynamic"
							                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                            ValidationGroup="ValidGroup" />
						            </EditItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:TextBox ID="DataFineInsert" 
						                             runat="server" >
						                </asp:TextBox>
						                <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineInsert" runat="server" />
						                <cc1:CalendarExtender ID="CalendarExtenderDataFineInsert" 
						                                      runat="server" 
						                                      TargetControlID="DataFineInsert"
							                                  PopupButtonID="ImageDataFineInsert" 
							                                  Format="dd/MM/yyyy">
						                </cc1:CalendarExtender>
						                <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFine" 
						                                                ControlToValidate="DataFineInsert"
							                                            runat="server" 
							                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                            Display="Dynamic"
							                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                            ValidationGroup="ValidGroup" />
						            </InsertItemTemplate>
					            </asp:TemplateField>
        					    
					            <asp:TemplateField HeaderText="Sostituito Da">
						            <ItemTemplate>
						                <asp:Label ID="label_nome_completo" 
						                           runat="server" 
						                           Text='<%# Eval("nome_completo") %>'>
						                </asp:Label>
						            </ItemTemplate>
            						
						            <InsertItemTemplate>
										<asp:HiddenField ID="TextBoxSostitutoId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
						                <asp:TextBox ID="TextBoxSostituto" 
						                             runat="server" 
						                             Text='<%# Bind("nome_completo") %>'>
						                </asp:TextBox>
						                
						                <div id="DivSostitutoInsert">
						                </div>
						                
						                <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostitutoInsert" 
						                                          runat="server"
							                                      EnableCaching="True" 
							                                      TargetControlID="TextBoxSostituto" 
							                                      ServicePath="~/ricerca_persone.asmx"
							                                      ServiceMethod="RicercaPersone" 
							                                      MinimumPrefixLength="1" 
							                                      CompletionInterval="0"
							                                      CompletionListElementID="DivSostitutoInsert" 
							                                      CompletionSetCount="15" 
							                                      UseContextKey="true" 
							                                      OnPreRender="AutoCompleteExtenderSostituto_PreRender"
																  OnClientItemSelected="autoCompleteSostitutoSelected">
							            <Animations>
							                <OnShow>
								            <Sequence>
								                <OpacityAction Opacity='0' />
								                <HideAction Visible='true' />
								                <StyleAction Attribute='fontSize' Value='8pt' />
								                <Parallel Duration='.15'>
									            <FadeIn />
								                </Parallel>
								            </Sequence>
							                </OnShow>
							                <OnHide>
								            <Parallel Duration='.15'>
								                <FadeOut />
								            </Parallel>
							                </OnHide>
							            </Animations>
						                </cc1:AutoCompleteExtender>
						            </InsertItemTemplate>
            						
						            <EditItemTemplate>
										<asp:HiddenField ID="TextBoxSostitutoId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
						                <asp:TextBox ID="TextBoxSostituto" runat="server" Text='<%# Bind("nome_completo") %>'></asp:TextBox>
						                <div id="DivSostitutoEdit">
						                </div>
						                <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostitutoEdit" 
						                                          runat="server" 
						                                          EnableCaching="True"
							                                      TargetControlID="TextBoxSostituto" 
							                                      ServicePath="~/ricerca_persone.asmx" 
							                                      ServiceMethod="RicercaPersone"
							                                      MinimumPrefixLength="1" 
							                                      CompletionInterval="0" 
							                                      CompletionListElementID="DivSostitutoEdit"
							                                      CompletionSetCount="15" 
							                                      UseContextKey="true" 
							                                      OnPreRender="AutoCompleteExtenderSostituto_PreRender"
																  OnClientItemSelected="autoCompleteSostitutoSelected">
							            <Animations>
							                <OnShow>
								            <Sequence>
								                <OpacityAction Opacity='0' />
								                <HideAction Visible='true' />
								                <StyleAction Attribute='fontSize' Value='8pt' />
								                <Parallel Duration='.15'>
									            <FadeIn />
								                </Parallel>
								            </Sequence>
							                </OnShow>
							                <OnHide>
								            <Parallel Duration='.15'>
								                <FadeOut />
								            </Parallel>
							                </OnHide>
							            </Animations>
						                </cc1:AutoCompleteExtender>
						            </EditItemTemplate>
					            </asp:TemplateField>
        					    
					            <%--<asp:TemplateField HeaderText="Sostituito Il" SortExpression="data_sostituzione">
						        <ItemTemplate>
						            <asp:Label ID="LabelDataSostituzione" runat="server" Text='<%# Bind("data_sostituzione", "{0:dd/MM/yyyy}") %>'></asp:Label>
						        </ItemTemplate>
						        <EditItemTemplate>
						            <asp:TextBox ID="DataSostituzioneEdit" runat="server" Text='<%# Bind("data_sostituzione", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataSostituzioneEdit"
							        runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtenderDataSostituzioneEdit" runat="server" TargetControlID="DataSostituzioneEdit"
							        PopupButtonID="ImageDataSostituzioneEdit">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataSostituzione" ControlToValidate="DataSostituzioneEdit"
							        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" />
						        </EditItemTemplate>
						        <InsertItemTemplate>
						            <asp:TextBox ID="DataSostituzioneInsert" runat="server" Text='<%# Bind("data_sostituzione", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataSostituzioneInsert"
							        runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtenderDataSostituzioneInsert" runat="server"
							        TargetControlID="DataSostituzioneInsert" PopupButtonID="ImageDataSostituzioneInsert">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataSostituzione" ControlToValidate="DataSostituzioneInsert"
							        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" />
						        </InsertItemTemplate>
					            </asp:TemplateField>--%>
        					    
					            <asp:TemplateField HeaderText="Causa" >
						            
						            <ItemTemplate >
						                <asp:Label ID="label_descrizione_causa" 
						                           runat="server" 
						                           Text='<%# Eval("descrizione_causa") %>'>
						                </asp:Label>
						            </ItemTemplate>
            						
						            <InsertItemTemplate>
						                <asp:DropDownList ID="DropDownList1" 
						                                  runat="server" 
						                                  DataSourceID="SqlDataSource3"
							                              DataTextField="descrizione_causa" 
							                              DataValueField="id_causa" 
							                              SelectedValue='<%# Bind("id_causa_fine") %>'
							                              Width="200px" 
							                              AppendDataBoundItems="True"
							                              >
							                <asp:ListItem Value="">(nessuna)</asp:ListItem>
						                </asp:DropDownList>
						            </InsertItemTemplate>
            						
						            <EditItemTemplate>
						                <asp:DropDownList ID="DropDownList2" 
						                                  runat="server" 
						                                  DataSourceID="SqlDataSource3"
							                              DataTextField="descrizione_causa" 
							                              DataValueField="id_causa" 
							                              SelectedValue='<%# Bind("id_causa_fine") %>'
							                              Width="200px" 
							                              AppendDataBoundItems="True"
							                              >
							                <asp:ListItem Value="">(nessuna)</asp:ListItem>
						                </asp:DropDownList>
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
						                <asp:Button ID="Button1" 
						                            runat="server" 
						                            CausesValidation="True" 
						                            CommandName="Update"
							                        Text="Aggiorna" 
							                        ValidationGroup="ValidGroup" />
        							                
						                <asp:Button ID="Button2" 
						                            runat="server" 
						                            CausesValidation="False" 
						                            CommandName="Cancel"
							                        Text="Annulla" />
						            </EditItemTemplate>
        						    
						            <InsertItemTemplate>
						                <asp:Button ID="Button1" 
						                            runat="server" 
						                            CausesValidation="True" 
						                            CommandName="Insert"
							                        Text="Inserisci" 
							                        ValidationGroup="ValidGroup" />
        						        
						                <asp:Button ID="Button4" 
						                            runat="server" 
						                            CausesValidation="False" 
						                            Text="Chiudi" 
						                            CssClass="button"
							                        OnClick="ButtonAnnulla_Click" 
							                        CommandName="Cancel" />
						            </InsertItemTemplate>
        						    
						            <ItemTemplate>
						                <asp:Button ID="Button1" 
						                            runat="server" 
						                            CausesValidation="False" 
						                            CommandName="Edit"
							                        Text="Modifica" 							                        						                        
							                        Visible="<%# (role <= 2) ? true : false %>" />
        						        
						                <asp:Button ID="Button3" 
						                            runat="server" 
						                            CausesValidation="False" 
						                            CommandName="Delete"
							                        Text="Elimina" 
							                        Visible="<%# (role <= 2) ? true : false %>" 
							                        OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
        						        
						                <asp:Button ID="Button4" 
						                            runat="server" 
						                            CausesValidation="False" 
						                            Text="Chiudi" 
						                            CssClass="button"
							                        OnClick="ButtonAnnulla_Click" 
							                        CommandName="Cancel" />
						            </ItemTemplate>
        						    
						            <ControlStyle CssClass="button" />
					            </asp:TemplateField>
					        </Fields>
				        </asp:DetailsView>
				        <asp:SqlDataSource ID="SqlDataSource2" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    					                   
					                       DeleteCommand="UPDATE [join_persona_sospensioni] 
					                                      SET [deleted] = 1 
					                                      WHERE [id_rec] = @id_rec"
    					                   
					                       InsertCommand="INSERT INTO [join_persona_sospensioni] ([id_legislatura], 
					                                                                              [id_persona], 
					                                                                              [tipo], 
					                                                                              [numero_pratica], 
					                                                                              [data_inizio], 
					                                                                              [data_fine], 
					                                                                              [numero_delibera], 
					                                                                              [data_delibera], 
					                                                                              [tipo_delibera], 
					                                                                              [sostituito_da], 
					                                                                              [id_causa_fine], 
					                                                                              [note]) 
					                                      VALUES (@id_legislatura, 
					                                              @id_persona, 
					                                              @tipo, 
					                                              @numero_pratica, 
					                                              @data_inizio, 
					                                              @data_fine, 
					                                              @numero_delibera, 
					                                              @data_delibera, 
					                                              @tipo_delibera, 
					                                              @sostituito_da, 
					                                              @id_causa_fine, 
					                                              @note); 
					                                      SELECT @id_rec = SCOPE_IDENTITY();"
    					                   
					                       SelectCommand="SELECT jj.*, 
					                                             pp.cognome + ' ' +  pp.nome AS nome_completo, 
					                                             cc.descrizione_causa, 
					                                             ll.num_legislatura, 
					                                             dd.tipo_delibera AS nome_delibera
				                                          FROM join_persona_sospensioni AS jj 
				                                          LEFT OUTER JOIN persona AS pp 
				                                            ON pp.id_persona = jj.sostituito_da 
				                                          LEFT OUTER JOIN tbl_cause_fine AS cc 
				                                            ON jj.id_causa_fine = cc.id_causa 
				                                          INNER JOIN legislature AS ll 
				                                            ON jj.id_legislatura = ll.id_legislatura 
				                                          LEFT OUTER JOIN tbl_delibere AS dd 
				                                            ON jj.tipo_delibera = dd.id_delibera
				                                          WHERE jj.id_rec = @id_rec" 
    					                   
					                       UpdateCommand="UPDATE [join_persona_sospensioni] 
					                                      SET [id_legislatura] = @id_legislatura, 
					                                          [id_persona] = @id_persona, 
					                                          [tipo] = @tipo, 
					                                          [numero_pratica] = @numero_pratica, 
					                                          [data_inizio] = @data_inizio, 
					                                          [data_fine] = @data_fine, 
					                                          [numero_delibera] = @numero_delibera, 
					                                          [data_delibera] = @data_delibera, 
					                                          [tipo_delibera] = @tipo_delibera, 
					                                          [sostituito_da] = @sostituito_da, 
					                                          [id_causa_fine] = @id_causa_fine, 
					                                          [note] = @note 
					                                      WHERE [id_rec] = @id_rec"
    					                   
					                       OnInserted="SqlDataSource2_Inserted">
					        <SelectParameters>
					            <asp:ControlParameter ControlID="GridView1" 
					                                  Name="id_rec" 
					                                  PropertyName="SelectedValue"
						                              Type="Decimal" />
					        </SelectParameters>
        					
					        <DeleteParameters>
					            <asp:Parameter Name="id_rec" Type="Int32" />
					        </DeleteParameters>
        					
					        <UpdateParameters>
					            <asp:Parameter Name="id_legislatura" Type="Int32" />
					            <asp:Parameter Name="id_persona" Type="Int32" />
					            <asp:Parameter Name="tipo" Type="String" />
					            <asp:Parameter Name="numero_pratica" Type="String" />
					            <asp:Parameter Name="data_inizio" Type="DateTime" />
					            <asp:Parameter Name="data_fine" Type="DateTime" />
					            <asp:Parameter Name="numero_delibera" Type="String" />
					            <asp:Parameter Name="data_delibera" Type="DateTime" />
					            <asp:Parameter Name="tipo_delibera" Type="Int32" />
					            <asp:Parameter Name="sostituito_da" Type="Int32" />
					            <asp:Parameter Name="id_causa_fine" Type="Int32" />
					            <asp:Parameter Name="note" Type="String" />
					            <asp:Parameter Name="id_rec" Type="Int32" />
					        </UpdateParameters>
        					
					        <InsertParameters>
					            <asp:Parameter Name="id_legislatura" Type="Int32" />
					            <asp:Parameter Name="id_persona" Type="Int32" />
					            <asp:Parameter Name="tipo" Type="String" />
					            <asp:Parameter Name="numero_pratica" Type="String" />
					            <asp:Parameter Name="data_inizio" Type="DateTime" />
					            <asp:Parameter Name="data_fine" Type="DateTime" />
					            <asp:Parameter Name="numero_delibera" Type="String" />
					            <asp:Parameter Name="data_delibera" Type="DateTime" />
					            <asp:Parameter Name="tipo_delibera" Type="Int32" />
					            <asp:Parameter Name="sostituito_da" Type="Int32" />
					            <asp:Parameter Name="id_causa_fine" Type="Int32" />
					            <asp:Parameter Name="note" Type="String" />
					            <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
					        </InsertParameters>
				        </asp:SqlDataSource>
				        
				        <asp:SqlDataSource ID="SqlDataSource3" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                       SelectCommand="SELECT descrizione_causa, 
					                                             MAX(id_causa) as id_causa
                                                          FROM [tbl_cause_fine] 
                                                          WHERE [tipo_causa] = 'Persona-Sospensioni-Sostituzioni'
                                                          GROUP BY descrizione_causa
                                                          ORDER BY [descrizione_causa]" >
				        </asp:SqlDataSource>
				    </ContentTemplate>
			    </asp:UpdatePanel>
			    </div>
			    <br />
			    
			    <asp:UpdatePanel ID="UpdatePanelEsporta" runat="server" UpdateMode="Conditional">
				<ContentTemplate>
				    <div align="right">
					<asp:LinkButton ID="LinkButtonExcelDetails" 
					                runat="server" 
					                OnClick="LinkButtonExcelDetails_Click">
					    Esporta 
					    <img src="../img/page_white_excel.png" alt="" align="top" />
					    <br />
					</asp:LinkButton>
					<asp:LinkButton ID="LinkButtonPdfDetails" 
					                runat="server" 
					                OnClick="LinkButtonPdfDetails_Click">
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
			    
			    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails"
			                            BehaviorID="ModalPopup1" 
			                            runat="server" 
			                            PopupControlID="PanelDetails"
				                        BackgroundCssClass="modalBackground" 
				                        DropShadow="true" 
				                        TargetControlID="ButtonDetailsFake" />
			    
			    <asp:Button ID="ButtonDetailsFake" 
			                runat="server" 
			                Text="" Style="display: none;" />
			</asp:Panel>
		    </div>
		</div>
		
		<%--Fix per lo stile dei calendarietti--%>
		<asp:TextBox ID="TextBoxCalendarFake" 
		             runat="server" 
		             style="display: none;">
		</asp:TextBox>
		
		<cc1:CalendarExtender ID="CalendarExtenderFake" 
		                      runat="server" 
		                      TargetControlID="TextBoxCalendarFake" 
		                      Format="dd/MM/yyyy">
		</cc1:CalendarExtender>
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

	  <script type="text/javascript">

        function autoCompleteSostitutoSelected(source, eventArgs) {
            var id = eventArgs.get_value();
            var text = eventArgs.get_text();

            //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

            $('input[id$=_TextBoxSostitutoId').val(id);
        }

      </script>

</asp:Content>