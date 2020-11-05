<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="legislature.aspx.cs" 
         Inherits="gruppi_politici_legislature" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:ScriptManager ID="ScriptManager1" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>

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
		&gt; LEGISLATURE
	    </ItemTemplate>
	</asp:DataList>
	
	<asp:SqlDataSource ID="SqlDataSource2" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	                   
	                   SelectCommand="SELECT gg.nome_gruppo 
	                                  FROM gruppi_politici AS gg
	                                  WHERE gg.id_gruppo = @id_gruppo">
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
		        <li><a id="a_componenti" runat="server">COMPONENTI</a></li>
		        <li id="selected"><a id="a_legislature" runat="server">LEGISLATURE</a></li>
		        <li><a id="a_storia" runat="server">STORIA</a></li>
	        </ul>
	    </div>
    	
	    <div id="tab_content">
	        <div id="tab_content_content">
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
        			          DataKeyNames="id_rec" 
        			          onrowdatabound="GridView1_RowDataBound">
            			      
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
    				
				    <asp:BoundField DataField="data_inizio" 
				                    HeaderText="Dal" 
				                    SortExpression="data_inizio"
				                    DataFormatString="{0:dd/MM/yyyy}" 
				                    ItemStyle-HorizontalAlign="center" />
    				
				    <asp:BoundField DataField="data_fine" 
				                    HeaderText="Al" 
				                    SortExpression="data_fine"
				                    DataFormatString="{0:dd/MM/yyyy}" 
				                    ItemStyle-HorizontalAlign="center" />
    				
                    
				    <asp:TemplateField>
				        <ItemTemplate>
					        <% 
                                //if (role <= 2) { 
                                if (1 == 0) {     
                                    %>
					        <asp:LinkButton ID="LinkButtonDettagli" 
					                        runat="server" 
					                        CausesValidation="False" 
					                        Text="Dettagli"
					                        
					                        OnClick="LinkButtonDettagli_Click">
					        </asp:LinkButton>
                            <% } %>
				        </ItemTemplate>
    				    
				        <HeaderTemplate>
					        <% 
                                //if (role <= 2) {
                                if (1 == 0) {
                                    %>
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
			                                             jgpl.id_rec, 
			                                             jgpl.data_inizio, 
			                                             jgpl.data_fine
				                                  FROM gruppi_politici AS gg
				                                  INNER JOIN join_gruppi_politici_legislature AS jgpl
				                                    ON gg.id_gruppo = jgpl.id_gruppo 
				                                  INNER JOIN legislature AS ll 
				                                    ON jgpl.id_legislatura = ll.id_legislatura
				                                  WHERE gg.deleted = 0
				                                    AND jgpl.deleted = 0 
				                                    AND gg.id_gruppo = @id
				                                  ORDER BY ll.durata_legislatura_da DESC" >
    			    
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
		               Style="padding: 10px; display: none; max-height: 500px;" >
    		    
		        <div align="center">
		        
			    <br />
			    
			    <h3>
			        LEGISLATURE
			    </h3>
			    
			    <br />
			    
		        <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
			    <ContentTemplate>
			        <asp:DetailsView ID="DetailsView1" 
			                         runat="server" 
			                         AutoGenerateRows="False" 
			                         CssClass="tab_det" 
			                         Width="420px"
				                     DataKeyNames="id_rec" 
				                     DataSourceID="SqlDataSource3" 
    				                 
				                     OnItemInserted="DetailsView1_ItemInserted"
				                     OnItemInserting="DetailsView1_ItemInserting" 
				                     OnItemUpdating="DetailsView1_ItemUpdating" 
				                     OnItemUpdated="DetailsView1_ItemUpdated"
				                     OnItemDeleted="DetailsView1_ItemDeleted" 
				                     OnModeChanged="DetailsView1_ModeChanged">
    				                 
				        <FieldHeaderStyle Font-Bold="True" 
				                          BackColor="LightGray" 
				                          Width="50%" 
				                          HorizontalAlign="right" />
				        <RowStyle HorizontalAlign="left" />
				        <HeaderStyle Font-Bold="False" />
    				    
				        <Fields>
				            <asp:TemplateField HeaderText="Legislatura">
					            <ItemTemplate>
					                <asp:Label ID="LabelLeg" 
					                           runat="server" 
					                           Text='<%# Eval("num_legislatura") %>'>
					                </asp:Label>
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
					                                                  ORDER BY durata_legislatura_da DESC" >
					                </asp:SqlDataSource>
					            </EditItemTemplate>
				            </asp:TemplateField>
    				        
				            <%--<asp:TemplateField HeaderText="Numero Delibera" SortExpression="numero_delibera_inizio">
					            <ItemTemplate>
					                <asp:Label ID="LabelDeliberaInizio" 
					                           runat="server" 
					                           Text='<%# Bind("numero_delibera_inizio") %>'>
					                </asp:Label>
					            </ItemTemplate>
    						    
					            <EditItemTemplate>
					                <asp:TextBox ID="TextBoxDeliberaInizio" 
					                             runat="server" 
					                             Text='<%# Bind("numero_delibera_inizio") %>'>
					                </asp:TextBox>
					                <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxDeliberaInizio"
						                                            ControlToValidate="TextBoxDeliberaInizio" 
						                                            runat="server" 
						                                            Display="Dynamic" 
						                                            ErrorMessage="Solo cifre ammesse."
						                                            ValidationExpression="^[0-9]+$">
					                </asp:RegularExpressionValidator>
					            </EditItemTemplate>
    						    
					            <InsertItemTemplate>
					                <asp:TextBox ID="TextBoxDeliberaInizio" 
					                             runat="server" 
					                             Text='<%# Bind("numero_delibera_inizio") %>'>
					                </asp:TextBox>
					                <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxDeliberaInizio"
						                                            ControlToValidate="TextBoxDeliberaInizio" 
						                                            runat="server" 
						                                            Display="Dynamic" 
						                                            ErrorMessage="Solo cifre ammesse."
						                                            ValidationExpression="^[0-9]+$">
					                </asp:RegularExpressionValidator>
					            </InsertItemTemplate>
				            </asp:TemplateField>
    				        
				            <asp:TemplateField HeaderText="Data Delibera" SortExpression="data_delibera_inizio">
					            <ItemTemplate>
					                <asp:Label ID="LabelDataDeliberaInizio" 
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
					                <cc1:CalendarExtender ID="CalendarExtender1" 
					                                      runat="server" 
					                                      TargetControlID="dtMod_delib_inizio"
						                                  PopupButtonID="Image1" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_delib_inizio" 
					                                                ControlToValidate="dtMod_delib_inizio"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
						                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                            ValidationGroup="FiltroData" />
					            </EditItemTemplate>
    						    
					            <InsertItemTemplate>
					                <asp:TextBox ID="dtIns_delib_inizio" 
					                             runat="server" >
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtender1" 
					                                      runat="server" 
					                                      TargetControlID="dtIns_delib_inizio"
						                                  PopupButtonID="Image1" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_delib_inizio" 
					                                                ControlToValidate="dtIns_delib_inizio"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
						                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                            ValidationGroup="FiltroData" />
					            </InsertItemTemplate>
				            </asp:TemplateField>
    				        
				            <asp:TemplateField HeaderText="Tipo delibera">
					            <ItemTemplate>
					                <asp:Label ID="label_tipo_delibera" runat="server" Text='<%# Eval("tipo_delibera") %>'>
					                </asp:Label>
					            </ItemTemplate>
    					        
					            <InsertItemTemplate>
					                <asp:DropDownList ID="DropDownListTipoDelibera" runat="server" DataSourceID="SqlDataSourceTipoDelibera"
						            DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_inizio") %>'
						            Width="200px" AppendDataBoundItems="true">
						            <asp:ListItem Text="(seleziona)" Value="" />
					                </asp:DropDownList>
					                <asp:SqlDataSource ID="SqlDataSourceTipoDelibera" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						            SelectCommand="SELECT * 
						                           FROM tbl_delibere"></asp:SqlDataSource>
					            </InsertItemTemplate>
    					        
					            <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListTipoDelibera" runat="server" DataSourceID="SqlDataSourceTipoDelibera"
						        DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_inizio") %>'
						        Width="200px" AppendDataBoundItems="true">
						        <asp:ListItem Text="(seleziona)" Value="" />
					            </asp:DropDownList>
					            <asp:SqlDataSource ID="SqlDataSourceTipoDelibera" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						        SelectCommand="SELECT * 
						                       FROM tbl_delibere"></asp:SqlDataSource>
					        </EditItemTemplate>
				            </asp:TemplateField>--%>
    				        
				            <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
					            <ItemTemplate>
					                <asp:Label ID="LabelDal" 
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
					                <cc1:CalendarExtender ID="CalendarExtender3" 
					                                      runat="server" 
					                                      TargetControlID="dtMod_inizio"
						                                  PopupButtonID="Image3" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RequiredFieldValidator ID="RequiredFieldValidatordMod_inizio" 
					                                            ControlToValidate="dtMod_inizio"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Campo obbligatorio." 
						                                        ValidationGroup="ValidGroup" />
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_inizio" 
					                                                ControlToValidate="dtMod_inizio"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
						                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                            ValidationGroup="ValidGroup" />
					            </EditItemTemplate>
    						    
					            <InsertItemTemplate>
					                <asp:TextBox ID="dtIns_inizio" 
					                             runat="server" >
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtender3" 
					                                      runat="server" 
					                                      TargetControlID="dtIns_inizio"
						                                  PopupButtonID="Image3" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RequiredFieldValidator ID="RequiredFieldValidatordIns_inizio" 
					                                            ControlToValidate="dtIns_inizio"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Campo obbligatorio." 
						                                        ValidationGroup="ValidGroup" />
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_inizio" 
					                                                ControlToValidate="dtIns_inizio"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
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
					                <cc1:CalendarExtender ID="CalendarExtender4" 
					                                      runat="server" 
					                                      TargetControlID="dtMod_fine"
						                                  PopupButtonID="Image4" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_fine" 
					                                                ControlToValidate="dtMod_fine"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
						                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                            ValidationGroup="ValidGroup" />
					            </EditItemTemplate>
    						    
					            <InsertItemTemplate>
					                <asp:TextBox ID="dtIns_fine" 
					                             runat="server" >
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="Image4" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtender4" 
					                                      runat="server" 
					                                      TargetControlID="dtIns_fine"
						                                  PopupButtonID="Image4" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_fine" 
					                                                ControlToValidate="dtIns_fine"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
						                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                            ValidationGroup="ValidGroup" />
					            </InsertItemTemplate>
				            </asp:TemplateField>
    				        
				            <%--<asp:TemplateField HeaderText="Protocollo" SortExpression="protocollo_gruppo">
					            <ItemTemplate>
					                <asp:Label ID="LabelProtocollo" runat="server" Text='<%# Bind("protocollo_gruppo") %>'></asp:Label>
					            </ItemTemplate>
					            
					            <EditItemTemplate>
					                <asp:TextBox ID="TextBoxProtocollo" runat="server" Text='<%# Bind("protocollo_gruppo") %>'
						            MaxLength="20"></asp:TextBox>
					            </EditItemTemplate>
					            
					            <InsertItemTemplate>
					                <asp:TextBox ID="TextBoxProtocollo" runat="server" Text='<%# Bind("protocollo_gruppo") %>'
						            MaxLength="20"></asp:TextBox>
					            </InsertItemTemplate>
				            </asp:TemplateField>--%>
    				        
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
					                <asp:Button ID="Button4" runat="server" CausesValidation="False" CommandName="Cancel"
						            Text="Chiudi" CssClass="button" OnClick="ButtonAnnulla_Click" />
					            </InsertItemTemplate>
					            
					            <ItemTemplate>
					                <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
						            Text="Modifica" Visible="<%# (role <= 2) ? true : false %>" />
					                <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
						            Text="Elimina" Visible="<%# (role <= 2) ? true : false %>" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
					                <asp:Button ID="Button4" runat="server" CausesValidation="False" CommandName="Cancel"
						            Text="Chiudi" CssClass="button" OnClick="ButtonAnnulla_Click" />
					            </ItemTemplate>
					        <ControlStyle CssClass="button" />
				            </asp:TemplateField>
				        </Fields>
			        </asp:DetailsView>
    			    
			        <asp:SqlDataSource ID="SqlDataSource3" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    				                   
				                       DeleteCommand="UPDATE join_gruppi_politici_legislature 
				                                      SET deleted = 1 
				                                      WHERE id_rec = @id_rec"
    				                   
				                       InsertCommand="INSERT INTO join_gruppi_politici_legislature (id_gruppo, 
				                                                                                    id_legislatura, 
				                                                                                    data_inizio, 
				                                                                                    data_fine, 
				                                                                                    deleted) 
				                                      VALUES (@id_gruppo, 
				                                              @id_legislatura,  
				                                              @data_inizio, 
				                                              @data_fine, 
				                                              0); 
				                                      SELECT @id_rec = SCOPE_IDENTITY();"
    				                   
				                       SelectCommand="SELECT ll.id_legislatura, 
				                                             ll.num_legislatura, 
				                                             jgpl.id_rec, 
				                                             gg.id_gruppo, 
				                                             jgpl.data_inizio, 
				                                             jgpl.data_fine
				                                      FROM join_gruppi_politici_legislature AS jgpl 
				                                      INNER JOIN gruppi_politici AS gg
				                                        ON jgpl.id_gruppo = gg.id_gruppo
					                                  INNER JOIN legislature AS ll 
					                                    ON jgpl.id_legislatura = ll.id_legislatura 
					                                  WHERE jgpl.id_rec = @id_rec"
    				                   
				                       UpdateCommand="UPDATE join_gruppi_politici_legislature
				                                      SET id_legislatura = @id_legislatura, 
				                                          data_inizio = @data_inizio, 
				                                          data_fine = @data_fine 
				                                      WHERE id_rec = @id_rec"
    				                   
				                       OnInserted="SqlDataSource3_Inserted">
    				                   
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
				            <asp:Parameter Name="numero_delibera_inizio" Type="String" />
				            <asp:Parameter Name="data_delibera_inizio" Type="DateTime" />
				            <asp:Parameter Name="tipo_delibera_inizio" Type="Int32" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
				            <asp:Parameter Name="protocollo_gruppo" Type="String" />
				            <asp:Parameter Name="id_rec" Type="Decimal" />
				        </UpdateParameters>
    					
				        <InsertParameters>
				            <asp:Parameter Name="id_gruppo" Type="Int32" />
				            <asp:Parameter Name="id_persona" Type="Int32" />
				            <asp:Parameter Name="numero_delibera_inizio" Type="String" />
				            <asp:Parameter Name="data_delibera_inizio" Type="DateTime" />
				            <asp:Parameter Name="tipo_delibera_inizio" Type="Int32" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
				            <asp:Parameter Name="protocollo_gruppo" Type="String" />
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
	                            <img src="../img/page_white_excel.png" alt="" align="top" /><br />
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
			                            TargetControlID="ButtonDetailsFake" >
			    </cc1:ModalPopupExtender>
		        
		        <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
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
</asp:Content>