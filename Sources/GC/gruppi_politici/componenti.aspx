<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="componenti.aspx.cs" 
         Inherits="gruppi_politici_componenti" 
         Title="Gruppo Politico > Componenti" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server" >
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	&nbsp;
    </td>
</tr>
<tr>
    <td>
	<asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSource2" Width="50%">
	    <ItemStyle Font-Bold="True" />
	    <ItemTemplate>
		<asp:Label ID="nomeLabel" runat="server" Text='<%# Eval("nome_gruppo") %>' />
		&gt; COMPONENTI
	    </ItemTemplate>
	</asp:DataList>
	<asp:SqlDataSource ID="SqlDataSource2" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	    
	                   SelectCommand="SELECT nome_gruppo 
	                                  FROM gruppi_politici 
	                                  WHERE id_gruppo = @id_gruppo">
	    <SelectParameters>
		<asp:SessionParameter Name="id_gruppo" SessionField="id_gruppo" Type="Int32" />
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
	        <ul>
	            <li><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
	            <li id="selected"><a id="a_componenti" runat="server">COMPONENTI</a></li>
	            <li><a id="a_legislature" runat="server">LEGISLATURE</a></li>
	            <li><a id="a_storia" runat="server">STORIA</a></li>
	        </ul>
	    </div>
    	
	    <div id="tab_content">
	        <div id="tab_content_content">
		    <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		        <ContentTemplate>
			    <table>
			        <tr>
				    <td valign="middle" width="230">
				        Seleziona legislatura:
				        <asp:DropDownList ID="DropDownListLegislatura" 
				                          runat="server" 
				                          DataSourceID="SqlDataSourceLegislature"
					                      DataTextField="num_legislatura" 
					                      DataValueField="id_legislatura" 
					                      Width="70px"
					                      AppendDataBoundItems="True">
					    <asp:ListItem Text="(tutte)" Value="" />
				        </asp:DropDownList>
    				    
				        <asp:SqlDataSource ID="SqlDataSourceLegislature" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                       SelectCommand="SELECT id_legislatura, 
					                                             num_legislatura 
					                                      FROM legislature
					                                      ORDER BY durata_legislatura_da DESC">
				        </asp:SqlDataSource>
				    </td>
    				
				    <td valign="middle" width="230">
				        Seleziona data:
				        <asp:TextBox ID="TextBoxFiltroData" 
				        runat="server" 
				        Text='<%# Bind("data_fine") %>'
					    Width="70px">
					    </asp:TextBox>
    					
				        <img alt="calendar" 
				        src="../img/calendar_month.png" 
				        id="ImageFiltroData" 
				        runat="server" />
    				    
				        <cc1:CalendarExtender ID="CalendarExtenderFiltroData" 
				                              runat="server" 
				                              TargetControlID="TextBoxFiltroData"
					                          PopupButtonID="ImageFiltroData" 
					                          Format="dd/MM/yyyy">
				        </cc1:CalendarExtender>
    				    
				        <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
				                                        ControlToValidate="TextBoxFiltroData"
					                                    runat="server" 
					                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                                    Display="Dynamic"
					                                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                                    ValidationGroup="FiltroData" >
					    </asp:RegularExpressionValidator>
				        <asp:ScriptManager ID="ScriptManager1" 
				                           runat="server" 
				                           EnableScriptGlobalization="True">
				        </asp:ScriptManager>
				    </td>
				    <td valign="middle">
				        <asp:Button ID="ButtonFiltri" 
				                    runat="server" 
				                    Text="Applica" 
				                    OnClick="ButtonFiltri_Click" 
				                    ValidationGroup="FiltroData" />
				    </td>
			        </tr>
			    </table>
			    
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
			                  DataKeyNames="id_rec" 
			                 
			                  OnSorting="ButtonFiltri_Click"
			                  OnPageIndexChanged="ButtonFiltri_Click" 
			                  OnRowDataBound="GridView1_RowDataBound" >
    			              
			        <EmptyDataTemplate>
				    <table width="100%" class="tab_gen">
				        <tr>
					    <th align="center">
					        Nessun record trovato.
					    </th>
					    <th width="100">
					        <% if (role <= 2) { %>
					        <asp:Button ID="Button1" 
					                    runat="server" 
					                    Text="Nuovo..." 
					                    OnClick="Button1_Click" 
					                    CssClass="button"
						                CausesValidation="false" />
					        <% } %>
					    </th>
				        </tr>
				    </table>
			        </EmptyDataTemplate>
    			    <AlternatingRowStyle BackColor="#b2cca7" />	
			        <Columns>
				        <asp:BoundField DataField="num_legislatura" 
				                        HeaderText="Legislatura" 
				                        SortExpression="num_legislatura" 
				                        ItemStyle-HorizontalAlign="center" 
				                        ItemStyle-Width="80px" />
        				
				        <asp:TemplateField HeaderText="Nome" SortExpression="nome">
				            <ItemTemplate>
					            <asp:LinkButton ID="lnkbtn_nome" 
		                                        runat="server"
		                                        Text='<%# Eval("nome") %>'
		                                        Font-Bold="true"
		                                        OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona"), Eval("id_legislatura")) %>' >
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
		                                        OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona"), Eval("id_legislatura")) %>' >
		                        </asp:LinkButton>
				            </ItemTemplate>
				            <ItemStyle Font-Bold="True" />
				        </asp:TemplateField>
        				
				        <asp:BoundField DataField="data_inizio" 
				                        HeaderText="Membro dal" 
				                        SortExpression="data_inizio"
			                            DataFormatString="{0:dd/MM/yyyy}" 
			                            ItemStyle-HorizontalAlign="center" 
			                            ItemStyle-Width="80px" />
        				
				        <asp:BoundField DataField="data_fine" 
				                        HeaderText="Membro al" 
				                        SortExpression="data_fine"
			                            DataFormatString="{0:dd/MM/yyyy}" 
			                            ItemStyle-HorizontalAlign="center" 
			                            ItemStyle-Width="80px" />
        				
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
					    <asp:Button ID="Button1" 
					                runat="server" 
					                Text="Nuovo..." 
					                OnClick="Button1_Click" 
					                CssClass="button"
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
    		                      
		                           SelectCommand="SELECT ll.num_legislatura, 
		                                                 jpgp.id_rec, 
		                                                 pp.id_persona, 
		                                                 jpgp.data_inizio, 
		                                                 jpgp.data_fine, 
		                                                 pp.nome, 
		                                                 pp.cognome,
		                                                 ll.id_legislatura
			                                      FROM gruppi_politici AS gg
			                                      INNER JOIN join_gruppi_politici_legislature AS jgpl
			                                        ON gg.id_gruppo = jgpl.id_gruppo
			                                      INNER JOIN join_persona_gruppi_politici AS jpgp 
			                                        ON gg.id_gruppo = jpgp.id_gruppo
			                                      INNER JOIN legislature AS ll 
			                                        ON (jgpl.id_legislatura = ll.id_legislatura 
			                                            AND jpgp.id_legislatura = ll.id_legislatura)
			                                      INNER JOIN persona AS pp 
			                                        ON jpgp.id_persona = pp.id_persona 
			                                      WHERE gg.deleted = 0 and gg.chiuso = 0 
			                                        AND jgpl.deleted = 0 and jgpl.chiuso = 0 
			                                        AND jpgp.deleted = 0 
			                                        AND jpgp.id_gruppo = @id" >
			        <SelectParameters>
				        <asp:SessionParameter Name="id" SessionField="id_gruppo" />
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
		        Esporta</asp:LinkButton>
		        -
		        <asp:LinkButton ID="LinkButtonPdf" 
		        runat="server" 
		        OnClick="LinkButtonPdf_Click">
		        <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		        Esporta</asp:LinkButton>
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
			        GRUPPI POLITICI</h3>
			    <br />
		        <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
			    <ContentTemplate>
			        <asp:DetailsView ID="DetailsView1" 
			                         runat="server" 
			                         AutoGenerateRows="False" 
			                         CssClass="tab_det" 
			                         Width="420px"
				                     DataKeyNames="id_rec" 
				                     DataSourceID="SqlDataSourceDetails" 
    				                 
				                     OnModeChanged="DetailsView1_ModeChanged" 
				                     OnItemInserted="DetailsView1_ItemInserted"
				                     OnItemInserting="DetailsView1_ItemInserting" 
				                     OnItemUpdated="DetailsView1_ItemUpdated"
				                     OnItemUpdating="DetailsView1_ItemUpdating" 
				                     OnItemDeleted="DetailsView1_ItemDeleted">
    				                 
				        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
				        <RowStyle HorizontalAlign="left" />
				        <HeaderStyle Font-Bold="False" />
        				
        				<EmptyDataTemplate>
        				    <table >
        				    <tr>
        				        <td>
        				            <asp:Label ID="lbl_close"
        				                       runat="server"
        				                       Text="Nessun dato da visualizzare." >
        				            </asp:Label>
        				        </td>
        				    </tr>
        				    
        				    <tr>
        				        <td>
    				                <asp:Button ID="btn_close" 
					                            runat="server" 
					                            CausesValidation="False" 
					                            CommandName="Cancel"
						                        Text="Chiudi" 
						                        CssClass="button" 
						                        
						                        OnClick="ButtonAnnulla_Click" />
    				            </td>
        				    </tr>
        				    </table>
        				</EmptyDataTemplate>
				        
				        <Fields>
				            <asp:TemplateField HeaderText="Legislatura">
					            <ItemTemplate>
					                <asp:Label ID="LabelLeg" runat="server" Text='<%# Bind("num_legislatura") %>'></asp:Label>
					            </ItemTemplate>
        					    
					            <InsertItemTemplate>
					                <asp:DropDownList ID="DropDownListLeg" runat="server" DataSourceID="SqlDataSourceLeg"
						            SelectedValue='<%# Eval("id_legislatura") %>' DataTextField="num_legislatura"
						            DataValueField="id_legislatura" Width="200px" AppendDataBoundItems="True">
						            <asp:ListItem Value="" Text="(seleziona)" />
					                </asp:DropDownList>
        					        
					                <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" ControlToValidate="DropDownListLeg"
						            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
        					        
					                <asp:SqlDataSource ID="SqlDataSourceLeg" 
					                                   runat="server"
					                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						                           
						                               SelectCommand="SELECT ll.id_legislatura, 
						                                                     ll.num_legislatura 
						                                              FROM legislature AS ll
						                                              INNER JOIN join_gruppi_politici_legislature AS jgpl
						                                                ON ll.id_legislatura = jgpl.id_legislatura
						                                              WHERE jgpl.id_gruppo = @id_gruppo
						                                              ORDER BY ll.durata_legislatura_da DESC" >
						                <SelectParameters>
						                    <asp:SessionParameter Name="id_gruppo" SessionField="id_gruppo" Type="Int32" />
						                </SelectParameters>
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
    						                           
						                               SelectCommand="SELECT ll.id_legislatura, 
						                                                     ll.num_legislatura 
	                                                                  FROM legislature AS ll
	                                                                  INNER JOIN join_gruppi_politici_legislature AS jgpl
	                                                                    ON ll.id_legislatura = jgpl.id_legislatura
	                                                                  WHERE jgpl.id_gruppo = @id_gruppo
	                                                                  ORDER BY ll.durata_legislatura_da DESC">
	                                    <SelectParameters>
						                    <asp:SessionParameter Name="id_gruppo" SessionField="id_gruppo" Type="Int32" />
						                </SelectParameters>
					                </asp:SqlDataSource>
					            </EditItemTemplate>
				            </asp:TemplateField>
        				    					    
				            <asp:TemplateField HeaderText="Consigliere">
					            <ItemTemplate>
					                <asp:Label ID="label_nome_completo" runat="server" Text='<%# Eval("nome_completo") %>'>
					                </asp:Label>
					            </ItemTemplate>
        					    
					            <InsertItemTemplate>
									<asp:HiddenField ID="TextBoxPersonaId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
					                <asp:TextBox ID="TextBoxPersona" runat="server" Text='<%# Bind("nome_completo") %>'></asp:TextBox>
					                <asp:RequiredFieldValidator ID="RequiredFieldValidatorPersona" ControlToValidate="TextBoxPersona"
						            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					                <div id="DivPersona">
					                </div>
					                <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona" runat="server"
						            EnableCaching="True" TargetControlID="TextBoxPersona" ServicePath="~/ricerca_persone.asmx"
						            ServiceMethod="RicercaPersoneAll" MinimumPrefixLength="1" CompletionInterval="0"
						            CompletionListElementID="DivPersona" CompletionSetCount="15"  OnClientItemSelected="autoCompletePersonaSelected">
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
									<asp:HiddenField ID="TextBoxPersonaId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
					                <asp:TextBox ID="TextBoxPersona" runat="server" Text='<%# Bind("nome_completo") %>'></asp:TextBox>
					                <asp:RequiredFieldValidator ID="RequiredFieldValidatorPersona" ControlToValidate="TextBoxPersona"
						            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					                <div id="DivPersona">
					                </div>
					                <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona" runat="server" EnableCaching="True"
						            TargetControlID="TextBoxPersona" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersoneAll"
						            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivPersona"
						            CompletionSetCount="15"  OnClientItemSelected="autoCompletePersonaSelected">
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
        		            
    		                <asp:TemplateField HeaderText="Tipo Carica">
					            <ItemTemplate>
					                <asp:Label ID="lblTipoCarica_Item" 
					                           runat="server" 
					                           Text='<%# Eval("nome_carica") %>'>
					                </asp:Label>
					            </ItemTemplate>
        						
					            <InsertItemTemplate>
					                <asp:DropDownList ID="ddlTipoCarica_Insert" 
					                                  runat="server" 
					                                  DataSourceID="SqlDataSource_ddlTipoCarica_Insert"
						                              DataTextField="nome_carica" 
						                              DataValueField="id_carica" 
						                              SelectedValue='<%# Bind("id_carica") %>'
						                              Width="100px" 
						                              AppendDataBoundItems="true">
						                <asp:ListItem Text="(seleziona)" Value="" />
					                </asp:DropDownList>
    					            
					                <asp:SqlDataSource ID="SqlDataSource_ddlTipoCarica_Insert" 
					                                   runat="server" 
					                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						                           
						                               SelectCommand="SELECT * 
						                                              FROM cariche
						                                              WHERE tipologia = 'GRPPOL'
						                                              ORDER BY ordine" >
						            </asp:SqlDataSource>
    						        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TipoCarica_Insert" 
					                                            runat="server" 
					                                            ErrorMessage="Campo obbligatorio."
						                                        ControlToValidate="ddlTipoCarica_Insert" 
						                                        Display="Dynamic" 
						                                        ValidationGroup="ValidGroup" >
						            </asp:RequiredFieldValidator>
					            </InsertItemTemplate>
        						
					            <EditItemTemplate>
					                <asp:DropDownList ID="ddlTipoCarica_Edit" 
					                                  runat="server" 
					                                  DataSourceID="SqlDataSource_ddlTipoCarica_Edit"
						                              DataTextField="nome_carica" 
						                              DataValueField="id_carica" 
						                              SelectedValue='<%# Bind("id_carica") %>'
						                              Width="100px" 
						                              AppendDataBoundItems="true">
						                <asp:ListItem Text="(seleziona)" Value="" />
					                </asp:DropDownList>
    					            
					                <asp:SqlDataSource ID="SqlDataSource_ddlTipoCarica_Edit" 
					                                   runat="server" 
					                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						                           
						                               SelectCommand="SELECT * 
						                                              FROM cariche
						                                              WHERE tipologia = 'GRPPOL'
						                                              ORDER BY ordine">
						            </asp:SqlDataSource>
    						        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TipoCarica_Edit" 
					                                            runat="server" 
					                                            ErrorMessage="Campo obbligatorio."
						                                        ControlToValidate="ddlTipoCarica_Edit" 
						                                        Display="Dynamic" 
						                                        ValidationGroup="ValidGroup" />
					            </EditItemTemplate>
				            </asp:TemplateField>
        		            
				            <asp:TemplateField HeaderText="Numero Pratica" SortExpression="numero_pratica">
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxPratica" 
					                         runat="server" 
					                         Text='<%# Bind("numero_pratica") %>'
						                     MaxLength="20" >
						        </asp:TextBox>
					        </EditItemTemplate>
    					    
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxPratica" 
					                         runat="server" 
					                         Text='<%# Bind("numero_pratica") %>'
						                     MaxLength="20" >
						        </asp:TextBox>
					        </InsertItemTemplate>
					        <ItemTemplate>
					            <asp:Label ID="Label1" runat="server" Text='<%# Bind("numero_pratica") %>'>
					            </asp:Label>
					        </ItemTemplate>
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Numero Delibera Inizio" SortExpression="numero_delibera_inizio">
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxNrDeliberaInizio" runat="server" Text='<%# Bind("numero_delibera_inizio") %>'
						        MaxLength="20">
						        </asp:TextBox>
    					        
					            <asp:RegularExpressionValidator ID="RegularExpressionNrDeliberaInizio" ControlToValidate="TextBoxNrDeliberaInizio"
						        runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						        ValidationGroup="ValidGroup" >
						        </asp:RegularExpressionValidator>
					        </EditItemTemplate>
    					    
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxNrDeliberaInizio" runat="server" Text='<%# Bind("numero_delibera_inizio") %>'
						        MaxLength="20">
						        </asp:TextBox>
    					        
					            <asp:RegularExpressionValidator ID="RegularExpressionNrDeliberaInizio" ControlToValidate="TextBoxNrDeliberaInizio"
						        runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						        ValidationGroup="ValidGroup" >
						        </asp:RegularExpressionValidator>
					        </InsertItemTemplate>
					        <ItemTemplate>
					            <asp:Label ID="Label5" runat="server" Text='<%# Bind("numero_delibera_inizio") %>'></asp:Label>
					        </ItemTemplate>
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Data Delibera Inizio" SortExpression="data_delibera_inizio">
					        <ItemTemplate>
					            <asp:Label ID="Label_delib_inizio" 
					                       runat="server" 
					                       Text='<%# Eval("data_delibera_inizio", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:TextBox ID="dtMod_delib_inizio" 
					                         runat="server" 
					                         Text='<%# Eval("data_delibera_inizio", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dtMod_delib_inizio"
						        PopupButtonID="Image1" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
    						    
					            <asp:RegularExpressionValidator ID="RegularExpressionDtDelibInizio" ControlToValidate="dtMod_delib_inizio"
						        runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="ValidGroup" >
						        </asp:RegularExpressionValidator>
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox ID="dtIns_delib_inizio" 
					                         runat="server" 
					                         >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dtIns_delib_inizio"
						        PopupButtonID="Image1" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
    					        
					            <asp:RegularExpressionValidator ID="RegularExpressionDtDelibInizio" ControlToValidate="dtIns_delib_inizio"
						        runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="ValidGroup" >
						        </asp:RegularExpressionValidator>
					        </InsertItemTemplate>
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Tipo delibera Inizio">
					        <ItemTemplate>
					            <asp:Label ID="label_tipo_delibera" runat="server" Text='<%# Eval("nome_delibera_inizio") %>'>
					            </asp:Label>
					        </ItemTemplate>
					        <InsertItemTemplate>
					            <asp:DropDownList ID="DropDownListTipoDeliberaInizio" 
					            runat="server" 
					            DataSourceID="SqlDataSourceTipoDeliberaInizio"
						        DataTextField="tipo_delibera" 
						        DataValueField="id_delibera" 
						        SelectedValue='<%# Bind("tipo_delibera_inizio") %>'
						        Width="200px" AppendDataBoundItems="true">
						        <asp:ListItem Text="(seleziona)" Value="" />
					            </asp:DropDownList>
					            <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaInizio" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						    
						                           SelectCommand="SELECT * 
						                                          FROM tbl_delibere">
						        </asp:SqlDataSource>
					        </InsertItemTemplate>
					        <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListTipoDeliberaInizio" runat="server" DataSourceID="SqlDataSourceTipoDeliberaInizio"
						        DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_inizio") %>'
						        Width="200px" AppendDataBoundItems="true">
						        <asp:ListItem Text="(seleziona)" Value="" />
					            </asp:DropDownList>
					            <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaInizio" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT * 
						                                          FROM tbl_delibere">
						        </asp:SqlDataSource>
					        </EditItemTemplate>
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Numero Delibera Fine" SortExpression="numero_delibera_fine">
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxNrDelibFine" runat="server" Text='<%# Bind("numero_delibera_fine") %>'></asp:TextBox>
					            <asp:RegularExpressionValidator ID="RegularExpressionNrDelibFine" ControlToValidate="TextBoxNrDelibFine"
						        runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxNrDelibFine" runat="server" Text='<%# Bind("numero_delibera_fine") %>'></asp:TextBox>
					            <asp:RegularExpressionValidator ID="RegularExpressionNrDelibFine" ControlToValidate="TextBoxNrDelibFine"
						        runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
					        <ItemTemplate>
					            <asp:Label ID="Label6" runat="server" Text='<%# Bind("numero_delibera_fine") %>'></asp:Label>
					        </ItemTemplate>
					        <ItemStyle BackColor="InactiveCaptionText" />
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Data Delibera Fine" SortExpression="data_delibera_fine">
					        <ItemTemplate>
					            <asp:Label ID="Label2" 
					                       runat="server" 
					                       Text='<%# Eval("data_delibera_fine", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:TextBox ID="dtMod_delib_fine" 
					                         runat="server" 
					                         Text='<%# Eval("data_delibera_fine", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dtMod_delib_fine"
						        PopupButtonID="Image2" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDtDelibFine" ControlToValidate="dtMod_delib_fine"
						        runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox ID="dtIns_delib_fine" 
					                         runat="server" 
					                         >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dtIns_delib_fine"
						        PopupButtonID="Image2" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDtDelibFine" ControlToValidate="dtIns_delib_fine"
						        runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
					        <ItemStyle BackColor="InactiveCaptionText" />
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Tipo delibera Fine">
					        <ItemTemplate>
					            <asp:Label ID="label_tipo_deliberaFine" runat="server" Text='<%# Eval("nome_delibera_fine") %>'>
					            </asp:Label>
					        </ItemTemplate>
					        <InsertItemTemplate>
					            <asp:DropDownList ID="DropDownListTipoDeliberaFine" runat="server" DataSourceID="SqlDataSourceTipoDeliberaFine"
						        DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_fine") %>'
						        Width="200px" AppendDataBoundItems="true">
						        <asp:ListItem Text="(seleziona)" Value="" />
					            </asp:DropDownList>
					            <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaFine" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						                       
						                           SelectCommand="SELECT * 
						                                          FROM tbl_delibere">
						        </asp:SqlDataSource>
					        </InsertItemTemplate>
					        <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListTipoDeliberaFine" runat="server" DataSourceID="SqlDataSourceTipoDeliberaFine"
						        DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_fine") %>'
						        Width="200px" AppendDataBoundItems="true">
						        <asp:ListItem Text="(seleziona)" Value="" />
					            </asp:DropDownList>
					            <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaFine" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						               
						                           SelectCommand="SELECT * 
						                                          FROM tbl_delibere">
						        </asp:SqlDataSource>
					        </EditItemTemplate>
					        <ItemStyle BackColor="InactiveCaptionText" />
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
					        <ItemTemplate>
					            <asp:Label ID="Label3" 
					                       runat="server" 
					                       Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:TextBox ID="dtMod_inizio" 
					                         runat="server" 
					                         Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="dtMod_inizio"
						        PopupButtonID="Image3" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDtInizio" ControlToValidate="dtMod_inizio"
						        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					            <asp:RegularExpressionValidator ID="RegularExpressionDtInizio" ControlToValidate="dtMod_inizio"
						        runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox ID="dtIns_inizio" 
					                         runat="server" 
					                         >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="dtIns_inizio"
						        PopupButtonID="Image3" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDtInizio" ControlToValidate="dtIns_inizio"
						        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					            <asp:RegularExpressionValidator ID="RegularExpressionDtInizio" ControlToValidate="dtIns_inizio"
						        runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
					            <ItemTemplate>
					                <asp:Label ID="Label4" 
					                           runat="server" 
					                           Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
					                </asp:Label>
					            </ItemTemplate>
        						
					            <EditItemTemplate>
					                <asp:TextBox ID="dtMod_fine" 
					                             runat="server" 
					                             Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="Image4" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtender4" runat="server" TargetControlID="dtMod_fine"
						            PopupButtonID="Image4" Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RegularExpressionValidator ID="RegularExpressionDtFine" ControlToValidate="dtMod_fine"
						            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						            ValidationGroup="ValidGroup" />
					            </EditItemTemplate>
        						
					            <InsertItemTemplate>
					                <asp:TextBox ID="dtIns_fine" 
					                             runat="server" 
					                             >
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="Image4" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtender4" runat="server" TargetControlID="dtIns_fine"
						            PopupButtonID="Image4" 
						            Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RegularExpressionValidator ID="RegularExpressionDtFine" ControlToValidate="dtIns_fine"
						            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						            ValidationGroup="ValidGroup" />
					            </InsertItemTemplate>
        						
					            <ItemStyle BackColor="InactiveCaptionText" />
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Protocollo" SortExpression="protocollo_gruppo">
					            <EditItemTemplate>
					                <asp:TextBox ID="TextBoxProtocollo" 
					                runat="server" 
					                Text='<%# Bind("protocollo_gruppo") %>'></asp:TextBox>
					                <asp:RegularExpressionValidator ID="RegularExpressionProtocollo" 
					                ControlToValidate="TextBoxProtocollo"
						            runat="server" 
						            Display="Dynamic" 
						            ErrorMessage="Solo cifre ammesse." 
						            ValidationExpression="^[0-9]+$"
						            ValidationGroup="ValidGroup" />
					            </EditItemTemplate>
        						
					            <InsertItemTemplate>
					                <asp:TextBox ID="TextBoxProtocollo" 
					                runat="server" 
					                Text='<%# Bind("protocollo_gruppo") %>'>
					                </asp:TextBox>
					                <asp:RegularExpressionValidator ID="RegularExpressionProtocollo" 
					                ControlToValidate="TextBoxProtocollo"
						            runat="server" 
						            Display="Dynamic" 
						            ErrorMessage="Solo cifre ammesse." 
						            ValidationExpression="^[0-9]+$"
						            ValidationGroup="ValidGroup" />
					            </InsertItemTemplate>
        						
					            <ItemTemplate>
					                <asp:Label ID="Label7" 
					                runat="server" 
					                Text='<%# Bind("protocollo_gruppo") %>'>
					                </asp:Label>
					            </ItemTemplate>
				            </asp:TemplateField>
        				    
				            <asp:TemplateField HeaderText="Note" SortExpression="varie">
					            <EditItemTemplate>
					                <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
						            Text='<%# Bind("varie") %>'></asp:TextBox>
					            </EditItemTemplate>
        						
					            <InsertItemTemplate>
					                <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
						            Text='<%# Bind("varie") %>'></asp:TextBox>
					            </InsertItemTemplate>
        						
					            <ItemTemplate>
					                <asp:Label ID="LabelVarie" runat="server" Text='<%# Bind("varie") %>'></asp:Label>
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
					                <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
						            Text="Annulla" OnClick="ButtonAnnulla_Click" />
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
					                            CommandName="Cancel"
						                        Text="Chiudi" 
						                        CssClass="button" 
						                        
						                        OnClick="ButtonAnnulla_Click" />
					            </ItemTemplate>
					            <ControlStyle CssClass="button" />
				            </asp:TemplateField>
				        </Fields>
			        </asp:DetailsView>
    			    
			        <asp:SqlDataSource ID="SqlDataSourceDetails" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    				                   
				                       DeleteCommand="UPDATE join_persona_gruppi_politici 
				                                      SET deleted = 1 
				                                      WHERE id_rec = @id_rec"
    				                   
				                       InsertCommand="INSERT INTO [join_persona_gruppi_politici] ([id_gruppo], 
				                                                                                  [id_persona], 
				                                                                                  [id_carica],  
				                                                                                  [id_legislatura],
				                                                                                  [numero_pratica], 
				                                                                                  [numero_delibera_inizio], 
				                                                                                  [data_delibera_inizio], 
				                                                                                  [tipo_delibera_inizio], 
				                                                                                  [numero_delibera_fine], 
				                                                                                  [data_delibera_fine], 
				                                                                                  [tipo_delibera_fine], 
				                                                                                  [data_inizio], 
				                                                                                  [data_fine], 
				                                                                                  [protocollo_gruppo], 
				                                                                                  [varie]) 
				                                      VALUES (@id_gruppo, 
				                                              @id_persona, 
				                                              @id_carica, 
				                                              @id_legislatura, 
				                                              @numero_pratica, 
				                                              @numero_delibera_inizio, 
				                                              @data_delibera_inizio, 
				                                              @tipo_delibera_inizio, 
				                                              @numero_delibera_fine, 
				                                              @data_delibera_fine, 
				                                              @tipo_delibera_fine, 
				                                              @data_inizio, 
				                                              @data_fine, 
				                                              @protocollo_gruppo, 
				                                              @varie); 
				                                      SELECT @id_rec = SCOPE_IDENTITY();"
    				                   
				                       SelectCommand="SELECT jpgp.* 
				                                            ,pp.cognome + ' ' +  pp.nome AS nome_completo 
				                                            ,ll.num_legislatura 
				                                            ,dd1.tipo_delibera AS nome_delibera_inizio 
				                                            ,dd2.tipo_delibera AS nome_delibera_fine
				                                            ,cc.nome_carica
				                                      FROM join_persona_gruppi_politici AS jpgp 
				                                      INNER JOIN persona AS pp 
				                                        ON jpgp.id_persona = pp.id_persona 
				                                      INNER JOIN gruppi_politici AS gg
				                                        ON jpgp.id_gruppo = gg.id_gruppo
				                                      INNER JOIN join_gruppi_politici_legislature AS jgpl
				                                        ON (gg.id_gruppo = jgpl.id_gruppo 
                                                            AND jpgp.id_legislatura = jgpl.id_legislatura)
				                                      INNER JOIN legislature AS ll 
				                                        ON jgpl.id_legislatura = ll.id_legislatura
			                                          INNER JOIN cariche AS cc 
				                                        ON jpgp.id_carica = cc.id_carica 
				                                      LEFT OUTER JOIN tbl_delibere AS dd1 
				                                        ON jpgp.tipo_delibera_inizio = dd1.id_delibera 
				                                      LEFT OUTER JOIN tbl_delibere AS dd2 
				                                        ON jpgp.tipo_delibera_fine = dd2.id_delibera
				                                      WHERE jpgp.id_rec = @id_rec" 
    				                   
				                       UpdateCommand="UPDATE [join_persona_gruppi_politici] 
				                                      SET [id_gruppo] = @id_gruppo, 
				                                          [id_persona] = @id_persona, 
				                                          [id_carica] = @id_carica, 
				                                          [id_legislatura] = @id_legislatura,
				                                          [numero_pratica] = @numero_pratica, 
				                                          [numero_delibera_inizio] = @numero_delibera_inizio, 
				                                          [data_delibera_inizio] = @data_delibera_inizio, 
				                                          [tipo_delibera_inizio] = @tipo_delibera_inizio, 
				                                          [numero_delibera_fine] = @numero_delibera_fine, 
				                                          [data_delibera_fine] = @data_delibera_fine, 
				                                          [tipo_delibera_fine] = @tipo_delibera_fine, 
				                                          [data_inizio] = @data_inizio, 
                                                          [data_fine] = @data_fine, 
				                                          [protocollo_gruppo] = @protocollo_gruppo, 
				                                          [varie] = @varie 
				                                      WHERE [id_rec] = @id_rec"
    				                   
				                       OnInserted="SqlDataSourceDetails_Inserted"
                                       OnUpdated="SqlDataSourceDetails_Updated"
                                       OnDeleted="SqlDataSourceDetails_Deleted">
				        <SelectParameters>
				            <asp:ControlParameter ControlID="GridView1" 
				                                  Name="id_rec" 
				                                  PropertyName="SelectedValue"
					                              Type="Decimal" />
				        </SelectParameters>
        				
				        <DeleteParameters>
				            <asp:Parameter Name="id_rec" Type="Decimal" />
				        </DeleteParameters>
        				
				        <UpdateParameters>
				            <asp:Parameter Name="id_gruppo" Type="Int32" />
				            <asp:Parameter Name="id_persona" Type="Int32" />
				            <asp:Parameter Name="id_legislatura" Type="Int32" />
				            <asp:Parameter Name="numero_pratica" Type="String" />
				            <asp:Parameter Name="numero_delibera_inizio" Type="String" />
				            <asp:Parameter Name="data_delibera_inizio" Type="DateTime" />
				            <asp:Parameter Name="tipo_delibera_inizio" Type="Int32" />
				            <asp:Parameter Name="numero_delibera_fine" Type="String" />
				            <asp:Parameter Name="data_delibera_fine" Type="DateTime" />
				            <asp:Parameter Name="tipo_delibera_fine" Type="Int32" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
				            <asp:Parameter Name="protocollo_gruppo" Type="String" />
				            <asp:Parameter Name="varie" Type="String" />
				            <asp:Parameter Name="id_rec" Type="Decimal" />
				        </UpdateParameters>
        				
				        <InsertParameters>
				            <asp:Parameter Name="id_gruppo" Type="Int32" />
				            <asp:Parameter Name="id_persona" Type="Int32" /> 
				            <asp:Parameter Name="id_legislatura" Type="Int32" />
				            <asp:Parameter Name="numero_pratica" Type="String" />
				            <asp:Parameter Name="numero_delibera_inizio" Type="String" />
				            <asp:Parameter Name="data_delibera_inizio" Type="DateTime" />
				            <asp:Parameter Name="tipo_delibera_inizio" Type="Int32" />
				            <asp:Parameter Name="numero_delibera_fine" Type="String" />
				            <asp:Parameter Name="data_delibera_fine" Type="DateTime" />
				            <asp:Parameter Name="tipo_delibera_fine" Type="Int32" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
				            <asp:Parameter Name="protocollo_gruppo" Type="String" />
				            <asp:Parameter Name="varie" Type="String" />
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
    			
		        <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
		    </asp:Panel>
	        </div>
	    </div>
	
	<%--Fix per lo stile dei calendarietti--%>
	<asp:TextBox ID="TextBoxCalendarFake" runat="server" style="display: none;">
	</asp:TextBox>
	
	<cc1:CalendarExtender ID="CalendarExtenderFake" 
	runat="server" 
	TargetControlID="TextBoxCalendarFake">
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
	           href="../gruppi_politici/gestisciGruppiPolitici.aspx">
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

      </script>

</asp:Content>