<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="cariche_assessori.aspx.cs" 
         Inherits="cariche_assessori" 
         Title="Assessori > Cariche" %>

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
			    <img alt="" src="<%= photoName %>" width="50" height="50" style="border: 1px solid #99cc99; margin-right: 10px;" align="middle" />
			</td>
			<td>
			    <span style="font-size: 1.5em; font-weight: bold; color: #50B306;">
			    <asp:Label ID="LabelHeadNome" runat="server" Text='<%# Eval("nome") + " " + Eval("cognome") %>' >
			    </asp:Label>
			    </span>
			    <br />
			    <asp:Label ID="LabelHeadDataNascita" runat="server" Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' >
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
			                           WHERE pp.id_persona = @id_persona" >
	    
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
					<asp:ListItem Text="(tutte)" Value="0" />
				    </asp:DropDownList>
				    <asp:SqlDataSource ID="SqlDataSourceLegislature" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					SelectCommand="SELECT [id_legislatura], 
					                      [num_legislatura] 
					               FROM [legislature]">
				    </asp:SqlDataSource>
				</td>
				
				<td valign="top" width="230">
				    Seleziona data:
				    <asp:TextBox ID="TextBoxFiltroData" runat="server" Width="70px"></asp:TextBox>
				    <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
				    <cc1:CalendarExtender ID="CalendarExtenderFiltroData" runat="server" TargetControlID="TextBoxFiltroData"
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
			
			<br /><br />
			
			<asp:GridView ID="GridView1" 
			              runat="server" 
			              AutoGenerateColumns="False" 
			              DataSourceID="SqlDataSource1"
			              PagerStyle-HorizontalAlign="Center" 
			              AllowSorting="True"			              
			              CellPadding="5" 
			              CssClass="tab_gen" 
			              GridLines="None" 
			              DataKeyNames="id_rec" >
			              
			    <EmptyDataTemplate>
				<table width="100%" class="tab_gen" >
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
			    <AlternatingRowStyle BackColor="#b2cca7" />	
			    <Columns>
				    <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
				        <ItemTemplate>
					        <asp:LinkButton ID="lnkbtn_leg" 
		                                    runat="server"
		                                    Text='<%# Eval("num_legislatura") %>'
		                                    Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>' >
		                    </asp:LinkButton>
				        </ItemTemplate>
				        <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
				    </asp:TemplateField>
    				
				    <asp:BoundField DataField="nome_carica" 
				    HeaderText="Carica" 
				    SortExpression="nome_carica" />
    				
				    <asp:TemplateField HeaderText="Organo" SortExpression="nome_organo">
				        <ItemTemplate>
					        <asp:LinkButton ID="lnkbtn_organo" 
		                                    runat="server"
		                                    Text='<%# Eval("nome_organo") %>'
		                                    Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../organi/dettaglio.aspx", Eval("id_organo")) %>' >
		                    </asp:LinkButton>
				        </ItemTemplate>
				        <ItemStyle Font-Bold="True" />
				    </asp:TemplateField>
    				
				    <asp:BoundField DataField="data_inizio" 
				    HeaderText="Dal" 
				    SortExpression="data_inizio"
				        DataFormatString="{0:dd/MM/yyyy}" 
				        ItemStyle-HorizontalAlign="center" 
				        ItemStyle-Width="80px" />
    				    
				    <asp:BoundField DataField="data_fine" 
				    HeaderText="Al" 
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
			                   
			                   SelectCommand="SELECT ll.id_legislatura, 
			                                         ll.num_legislatura, 
			                                         jj.id_rec, jj.id_organo, 
			                                         jj.data_inizio, 
			                                         jj.data_fine, 
			                                         oo.nome_organo, 
			                                         cc.nome_carica
				                              FROM cariche AS cc 
				                              INNER JOIN join_persona_organo_carica AS jj 
				                                ON cc.id_carica = jj.id_carica 
				                              INNER JOIN organi AS oo 
				                                ON jj.id_organo = oo.id_organo 
				                              INNER JOIN legislature AS ll 
				                                ON jj.id_legislatura = ll.id_legislatura
				                              WHERE jj.deleted = 0 
				                                AND id_persona = @id">
			    <SelectParameters>
				    <asp:SessionParameter Name="id" SessionField="id_persona" />
			    </SelectParameters>
			</asp:SqlDataSource>
		    </ContentTemplate>
		</asp:UpdatePanel>
		
		<br />
		
		<div align="right">
		    <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click"><img src="../img/page_white_excel.png" alt="" align="top" /> Esporta</asp:LinkButton>
		    -
		    <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click"><img src="../img/page_white_acrobat.png" alt="" align="top" /> Esporta</asp:LinkButton>
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
			    CARICHE
			</h3>
			<br />
		    <asp:UpdatePanel ID="UpdatePanelDetails" 
		                     runat="server" 
		                     UpdateMode="Conditional">
			<ContentTemplate>
			    <asp:DetailsView ID="DetailsView1" 
			                     runat="server" 
			                     AutoGenerateRows="False" 
			                     DataKeyNames="id_rec" 
			                     Width="420px"
				                 DataSourceID="SqlDataSource2" 
				                 CssClass="tab_det" 
				                 
				                 OnDataBound="DetailsView1_DataBound" 
				                 OnModeChanged="DetailsView1_ModeChanged" 
				                 OnItemInserted="DetailsView1_ItemInserted"
				                 OnItemInserting="DetailsView1_ItemInserting" 
				                 OnItemUpdated="DetailsView1_ItemUpdated"
				                 OnItemUpdating="DetailsView1_ItemUpdating" 
				                 OnItemDeleted="DetailsView1_ItemDeleted" >
				
				    <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
				    <RowStyle HorizontalAlign="left" />
				    <HeaderStyle Font-Bold="False" />
    				
				    <Fields>
				        <%-- cella 1 --%>
				        <asp:TemplateField HeaderText="Legislatura" >
					        <ItemTemplate>
					            <asp:Label ID="LabelLeg" 
					                       runat="server" 
					                       Text='<%# Bind("num_legislatura") %>'>
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
						                          AutoPostBack="True" 
						                          AppendDataBoundItems="True">
						            <asp:ListItem Value="" Text="(seleziona)" />
					            </asp:DropDownList>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" 
					                                        ControlToValidate="DropDownListLeg"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
					            
					            <asp:SqlDataSource ID="SqlDataSourceLeg" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT [id_legislatura], 
						                                                 [num_legislatura] 
						                                          FROM [legislature]">
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
						                          AutoPostBack="True" 
						                          AppendDataBoundItems="True"
						                          Enabled='<%# IsEnabled(DataBinder.Eval(DetailsView1.DataItem, "id_tipo_carica")) %>' >
						            <asp:ListItem Value="" Text="(seleziona)" />
					            </asp:DropDownList>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" 
					                                        ControlToValidate="DropDownListLeg"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
						        
					            <asp:SqlDataSource ID="SqlDataSourceLeg" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT [id_legislatura], 
						                                                 [num_legislatura] 
						                                          FROM [legislature]">
					            </asp:SqlDataSource>
					        </EditItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 2 --%>
				        <asp:TemplateField HeaderText="Organo">
					        <ItemTemplate>
					            <asp:Label ID="LabelOrgano" 
					                       runat="server" 
					                       Text='<%# Eval("nome_organo") %>'>
					            </asp:Label>
					        </ItemTemplate>
    					    
					        <InsertItemTemplate>
					            <asp:DropDownList ID="DropDownListOrgano" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceOrgano"
						                          DataTextField="nome_organo" 
						                          DataValueField="id_organo" 
						                          Width="200px" 
						                          AutoPostBack="True"
						                          OnDataBound="DropDownListOrgano_DataBound">
					            </asp:DropDownList>
					            
					            <asp:SqlDataSource ID="SqlDataSourceOrgano" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT [id_organo], 
						                                                 [nome_organo] 
						                                          FROM [organi] 
						                                          WHERE (deleted = 0) 
						                                            AND ([id_legislatura] = @id_legislatura) 
						                                          ORDER BY [nome_organo]">
						            <SelectParameters>
						                <asp:ControlParameter ControlID="DetailsView1$DropDownListLeg" 
						                                      Name="id_legislatura"
							                                  PropertyName="SelectedValue" 
							                                  Type="Int32" 
							                                  DefaultValue="0" />
						            </SelectParameters>
					            </asp:SqlDataSource>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorListOrgano" 
					                                        runat="server"
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ControlToValidate="DropDownListOrgano" 
						                                    Display="Dynamic"
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
					        </InsertItemTemplate>
    					    
					        <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListOrgano" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceOrgano"
						                          DataTextField="nome_organo" 
						                          DataValueField="id_organo" 
						                          Width="200px" 
						                          AutoPostBack="True"
						                          Enabled='<%# IsEnabled(DataBinder.Eval(DetailsView1.DataItem, "id_tipo_carica")) %>'
						                          OnDataBound="DropDownListOrgano_DataBound">
					            </asp:DropDownList>
					            
					            <asp:SqlDataSource ID="SqlDataSourceOrgano" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT [id_organo], 
						                                                 [nome_organo] 
						                                          FROM [organi] 
						                                          WHERE (deleted = 0) 
						                                            AND ([id_legislatura] = @id_legislatura) 
						                                          ORDER BY [nome_organo]">
						            <SelectParameters>
						                <asp:ControlParameter ControlID="DetailsView1$DropDownListLeg" 
						                                      Name="id_legislatura"
							                                  PropertyName="SelectedValue" 
							                                  Type="Int32" 
							                                  DefaultValue="0" />
						            </SelectParameters>
					            </asp:SqlDataSource>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorListOrgano" 
					                                        runat="server"
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ControlToValidate="DropDownListOrgano" 
						                                    Display="Dynamic"
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
					        </EditItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 3 --%>
				        <asp:TemplateField HeaderText="Carica">
					        <ItemTemplate>
					            <asp:Label ID="LabelCarica" 
					                       runat="server" 
					                       Text='<%# Eval("nome_carica") %>'>
					            </asp:Label>
					        </ItemTemplate>
    					    
					        <InsertItemTemplate>
					            <asp:DropDownList ID="DropDownListCarica" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceCarica"
						                          DataTextField="nome_carica" 
						                          DataValueField="id_carica" 
						                          Width="200px"
						                          AutoPostBack="True"
						                          OnDataBound="DropDownListCarica_DataBound"
						                          OnSelectedIndexChanged="DropDownListCarica_SelectedIndexChanged">
					            </asp:DropDownList>
					            <asp:SqlDataSource ID="SqlDataSourceCarica" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT cc.id_carica, 
						                                                 cc.nome_carica, 
						                                                 jj.flag 
						                                          FROM join_cariche_organi AS jj 
						                                          INNER JOIN cariche AS cc 
						                                            ON jj.id_carica = cc.id_carica 
						                                          WHERE (jj.deleted = 0) 
						                                            AND (jj.id_organo = @id_organo)">
						            <SelectParameters>
						                <asp:ControlParameter ControlID="DetailsView1$DropDownListOrgano" 
						                                      Name="id_organo"
							                                  PropertyName="SelectedValue" 
							                                  Type="Int32" 
							                                  DefaultValue="0" />
						            </SelectParameters>
					            </asp:SqlDataSource>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorListCarica" 
					                                        runat="server"
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ControlToValidate="DropDownListCarica" 
						                                    Display="Dynamic"
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
					        </InsertItemTemplate>
    					    
					        <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListCarica" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceCarica"
						                          DataTextField="nome_carica" 
						                          DataValueField="id_carica" 
						                          Width="200px" 
						                          AutoPostBack="True"
						                          Enabled='<%# IsEnabled(DataBinder.Eval(DetailsView1.DataItem, "id_tipo_carica")) %>'
						                          OnDataBound="DropDownListCarica_DataBound" 
						                          OnSelectedIndexChanged="DropDownListCarica_SelectedIndexChanged">
					            </asp:DropDownList>
					            
					            <asp:SqlDataSource ID="SqlDataSourceCarica" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           SelectCommand="SELECT cc.id_carica, 
						                                                 cc.nome_carica, 
						                                                 jj.flag 
						                                          FROM join_cariche_organi AS jj 
						                                          INNER JOIN cariche AS cc 
				                                                    ON jj.id_carica = cc.id_carica 
				                                                  WHERE (jj.deleted = 0) 
				                                                    AND (jj.id_organo = @id_organo)">
						            <SelectParameters>
						                <asp:ControlParameter ControlID="DetailsView1$DropDownListOrgano" 
						                                      Name="id_organo"
							                                  PropertyName="SelectedValue" 
							                                  Type="Int32" 
							                                  DefaultValue="0" />
						            </SelectParameters>
					            </asp:SqlDataSource>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorListCarica" 
					                                        runat="server"
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ControlToValidate="DropDownListCarica" 
						                                    Display="Dynamic"
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
					        </EditItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 4 --%>
				        <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
					        <ItemTemplate>
					            <asp:Label ID="LabelDataInizio" 
					                       runat="server" 
					                       Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
    						
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxDataInizio" 
					                         runat="server" 
					                         Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizio" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataInizio" 
					                                  runat="server" 
					                                  TargetControlID="TextBoxDataInizio"
						                              PopupButtonID="ImageDataInizio" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" 
					                                        ControlToValidate="TextBoxDataInizio"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					            <asp:RegularExpressionValidator ID="RegularExpressionDataInizio" 
					                                            ControlToValidate="TextBoxDataInizio"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
    						
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxDataInizio" 
					                         runat="server" >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizio" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataInizio" 
					                                  runat="server" 
					                                  TargetControlID="TextBoxDataInizio"
						                              PopupButtonID="ImageDataInizio" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" 
					                                        ControlToValidate="TextBoxDataInizio"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					            <asp:RegularExpressionValidator ID="RegularExpressionDataInizio" 
					                                            ControlToValidate="TextBoxDataInizio"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 5 --%>
				        <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
					        <ItemTemplate>
					            <asp:Label ID="LabelDataFine" 
					                       runat="server" 
					                       Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
    						
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxDataFine" 
					                         runat="server" 
					                         Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFine" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataFine" 
					                                  runat="server" 
					                                  TargetControlID="TextBoxDataFine"
						                              PopupButtonID="ImageDataFine" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataFine" 
					                                            ControlToValidate="TextBoxDataFine"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
    						
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxDataFine" 
					                         runat="server" >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFine" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataFine" 
					                                  runat="server" 
					                                  TargetControlID="TextBoxDataFine"
						                              PopupButtonID="ImageDataFine" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataFine" 
					                                            ControlToValidate="TextBoxDataFine"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>    				    				        
    				    
    				    <%-- cella 6 --%>
				        <asp:TemplateField HeaderText="Numero Pratica" SortExpression="numero_pratica">
					    <ItemTemplate>
					        <asp:Label ID="LabelNumeroPratica" runat="server" Text='<%# Bind("numero_pratica") %>'></asp:Label>
					    </ItemTemplate>
					    <EditItemTemplate>
					        <asp:TextBox ID="TextBoxNumeroPratica" runat="server" Text='<%# Bind("numero_pratica") %>'
						    MaxLength="50"></asp:TextBox>
					    </EditItemTemplate>
					    <InsertItemTemplate>
					        <asp:TextBox ID="TextBoxNumeroPratica" runat="server" Text='<%# Bind("numero_pratica") %>'
						    MaxLength="50"></asp:TextBox>
					    </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 7 --%>
				        <asp:TemplateField HeaderText="Data Proclamazione" SortExpression="data_proclamazione">
					        <ItemTemplate>
					            <asp:Label ID="LabelDataProclamazione" 
					                       runat="server" 
					                       Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
    						
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxDataProclamazione" 
					                         runat="server" 
					                         Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataProclamazione" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataProclamazione" 
					                                  runat="server" 
					                                  TargetControlID="TextBoxDataProclamazione"
						                              PopupButtonID="ImageDataProclamazione" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataProclamazione" 
					                                            ControlToValidate="TextBoxDataProclamazione"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
    						
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxDataProclamazione" 
					                         runat="server" >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataProclamazione" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataProclamazione" 
					                                  runat="server" 
					                                  TargetControlID="TextBoxDataProclamazione"
						                              PopupButtonID="ImageDataProclamazione" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataProclamazione" 
					                                            ControlToValidate="TextBoxDataProclamazione"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 8 --%>
				        <asp:TemplateField HeaderText="Delibera Proclamazione" SortExpression="delibera_proclamazione">
					    <ItemTemplate>
					        <asp:Label ID="LabelDeliberaProclamazione" runat="server" Text='<%# Bind("delibera_proclamazione") %>'></asp:Label>
					    </ItemTemplate>
					    <EditItemTemplate>
					        <asp:TextBox ID="TextBoxDeliberaProclamazione" runat="server" Text='<%# Bind("delibera_proclamazione") %>'
						    MaxLength="50"></asp:TextBox>
					    </EditItemTemplate>
					    <InsertItemTemplate>
					        <asp:TextBox ID="TextBoxDeliberaProclamazione" runat="server" Text='<%# Bind("delibera_proclamazione") %>'
						    MaxLength="50"></asp:TextBox>
					    </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 9 --%>
				        <asp:TemplateField HeaderText="Data Delibera Proclamazione" SortExpression="data_delibera_proclamazione">
					        <ItemTemplate>
					            <asp:Label ID="LabelDataDeliberaProclamazione" 
					                       runat="server" 
					                       Text='<%# Eval("data_delibera_proclamazione", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
    						
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxDataDeliberaProclamazione" 
					                         runat="server" 
					                         Text='<%# Eval("data_delibera_proclamazione", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataDeliberaProclamazione" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataDeliberaProclamazione" 
					                                  runat="server"
						                              TargetControlID="TextBoxDataDeliberaProclamazione" 
						                              PopupButtonID="ImageDataDeliberaProclamazione" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataDeliberaProclamazione" 
					                                            ControlToValidate="TextBoxDataDeliberaProclamazione"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
    						
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxDataDeliberaProclamazione" 
					                         runat="server" >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataDeliberaProclamazione" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataDeliberaProclamazione" 
					                                  runat="server"
						                              TargetControlID="TextBoxDataDeliberaProclamazione" 
						                              PopupButtonID="ImageDataDeliberaProclamazione" 
						                              Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataDeliberaProclamazione" 
					                                            ControlToValidate="TextBoxDataDeliberaProclamazione"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 10 --%>
				        <asp:TemplateField HeaderText="Tipo Delibera Proclamazione">
					    <ItemTemplate>
					        <asp:Label ID="label_tipo_deliberaProclamazione" runat="server" Text='<%# Eval("tipo_delibera") %>'>
					        </asp:Label>
					    </ItemTemplate>
					    <InsertItemTemplate>
					        <asp:DropDownList ID="DropDownListTipoDeliberaProclamazione" runat="server" DataSourceID="SqlDataSourceTipoDeliberaProclamazione"
						    DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_proclamazione") %>'
						    Width="200px" AppendDataBoundItems="true">
						    <asp:ListItem Text="(seleziona)" Value="" />
					        </asp:DropDownList>
					        <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaProclamazione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						    SelectCommand="SELECT * FROM [tbl_delibere]"></asp:SqlDataSource>
					    </InsertItemTemplate>
					    <EditItemTemplate>
					        <asp:DropDownList ID="DropDownListTipoDeliberaProclamazione" runat="server" DataSourceID="SqlDataSourceTipoDeliberaProclamazione"
						    DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_proclamazione") %>'
						    Width="200px" AppendDataBoundItems="true">
						    <asp:ListItem Text="(seleziona)" Value="" />
					        </asp:DropDownList>
					        <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaProclamazione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						    SelectCommand="SELECT * FROM [tbl_delibere]"></asp:SqlDataSource>
					    </EditItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 11 --%>
				        <asp:TemplateField HeaderText="Protocollo Delibera Proclamazione" SortExpression="protocollo_delibera_proclamazione">
					    <ItemTemplate>
					        <asp:Label ID="LabelProtocolloDeliberaProclamazione" runat="server" Text='<%# Bind("protocollo_delibera_proclamazione") %>'></asp:Label>
					    </ItemTemplate>
					    <EditItemTemplate>
					        <asp:TextBox ID="TextBoxProtocolloDeliberaProclamazione" runat="server" Text='<%# Bind("protocollo_delibera_proclamazione") %>'
						    MaxLength="50"></asp:TextBox>
					    </EditItemTemplate>
					    <InsertItemTemplate>
					        <asp:TextBox ID="TextBoxProtocolloDeliberaProclamazione" runat="server" Text='<%# Bind("protocollo_delibera_proclamazione") %>'
						    MaxLength="50"></asp:TextBox>
					    </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 12 --%>
				        <asp:TemplateField HeaderText="Data Convalida" SortExpression="data_convalida">
					        <ItemTemplate>
					            <asp:Label ID="LabelDataConvalida" 
					            runat="server" 
					            Text='<%# Eval("data_convalida", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
    						
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxDataConvalida" 
					                            runat="server" 
					                            Text='<%# Eval("data_convalida", "{0:dd/MM/yyyy}") %>'>
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataConvalida" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataConvalida" 
					                                    runat="server" 
					                                    TargetControlID="TextBoxDataConvalida"
						                                PopupButtonID="ImageDataConvalida" 
						                                Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataConvalida" 
					                                            ControlToValidate="TextBoxDataConvalida"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
    						
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxDataConvalida" 
					                            runat="server" >
					            </asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataConvalida" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtenderDataConvalida" 
					                                    runat="server" 
					                                    TargetControlID="TextBoxDataConvalida"
						                                PopupButtonID="ImageDataConvalida" 
						                                Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RegularExpressionValidator ID="RegularExpressionDataConvalida" 
					                                            ControlToValidate="TextBoxDataConvalida"
						                                        runat="server" 
						                                        Display="Dynamic" 
						                                        rrorMessage="Ammessi solo valori GG/MM/AAAA."
						                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 13 --%>
				        <asp:TemplateField HeaderText="Telefono" SortExpression="telefono">
					    <ItemTemplate>
					        <asp:Label ID="LabelTelefono" runat="server" Text='<%# Bind("telefono") %>'></asp:Label>
					    </ItemTemplate>
					    <EditItemTemplate>
					        <asp:TextBox ID="TextBoxTelefono" runat="server" Text='<%# Bind("telefono") %>' MaxLength="20"></asp:TextBox>
					        <asp:RegularExpressionValidator ID="RegularExpressionTelefono" ControlToValidate="TextBoxTelefono"
						    runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						    ValidationGroup="ValidGroup" />
					    </EditItemTemplate>
					    <InsertItemTemplate>
					        <asp:TextBox ID="TextBoxTelefono" runat="server" Text='<%# Bind("telefono") %>' MaxLength="20"></asp:TextBox>
					        <asp:RegularExpressionValidator ID="RegularExpressionTelefono" ControlToValidate="TextBoxTelefono"
						    runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						    ValidationGroup="ValidGroup" />
					    </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 14 --%>
				        <asp:TemplateField HeaderText="Fax" SortExpression="fax">
					    <ItemTemplate>
					        <asp:Label ID="LabelFax" runat="server" Text='<%# Bind("fax") %>'></asp:Label>
					    </ItemTemplate>
					    <EditItemTemplate>
					        <asp:TextBox ID="TextBoxFax" runat="server" Text='<%# Bind("fax") %>' MaxLength="20"></asp:TextBox>
					        <asp:RegularExpressionValidator ID="RegularExpressionFax" ControlToValidate="TextBoxFax"
						    runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						    ValidationGroup="ValidGroup" />
					    </EditItemTemplate>
					    <InsertItemTemplate>
					        <asp:TextBox ID="TextBoxFax" runat="server" Text='<%# Bind("fax") %>' MaxLength="20"></asp:TextBox>
					        <asp:RegularExpressionValidator ID="RegularExpressionFax" ControlToValidate="TextBoxFax"
						    runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						    ValidationGroup="ValidGroup" />
					    </InsertItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 15 --%>
				        <asp:TemplateField HeaderText="Causa fine">
					        <ItemTemplate>
					            <asp:Label ID="LabelCausa" 
					                       runat="server" 
					                       Text='<%# Eval("descrizione_causa") %>'>
					            </asp:Label>
					        </ItemTemplate>
    						
					        <InsertItemTemplate>
					            <asp:DropDownList ID="DropDownListCausa" 
					                              runat="server" 
					                              DataSourceID="SqlDataSource5"
						                          DataTextField="descrizione_causa" 
						                          DataValueField="id_causa" 
						                          SelectedValue='<%# Bind("id_causa_fine") %>'
						                          Width="200px" 
						                          AppendDataBoundItems="True">
						            <asp:ListItem Value="">(nessuna)</asp:ListItem>
					            </asp:DropDownList>
					        </InsertItemTemplate>
    						
					        <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListCausa" 
					                              runat="server" 
					                              DataSourceID="SqlDataSource5"
						                          DataTextField="descrizione_causa" 
						                          DataValueField="id_causa" 
						                          SelectedValue='<%# Bind("id_causa_fine") %>'
						                          Width="200px" 
						                          AppendDataBoundItems="True">
						            <asp:ListItem Value="">(nessuna)</asp:ListItem>
					            </asp:DropDownList>
					        </EditItemTemplate>
				        </asp:TemplateField>
    				    
    				    <%-- cella 16 --%>
				        <%--<asp:CheckBoxField DataField="diaria" HeaderText="Diaria" SortExpression="diaria" />--%>
                        <asp:CheckBoxField DataField="diaria" HeaderText="Opzione" SortExpression="diaria" />
    				    
    				    <%-- cella 17 --%>
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

    				    <%-- cella 17b --%>
				        <asp:TemplateField HeaderText="Note Trasparenza" SortExpression="note_trasparenza">
					    <EditItemTemplate>
					        <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="Note_Trasparenza" runat="server"
						    Text='<%# Bind("note_trasparenza") %>'></asp:TextBox>
					    </EditItemTemplate>
					    <InsertItemTemplate>
					        <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="Note_Trasparenza" runat="server"
						    Text='<%# Bind("note_trasparenza") %>'></asp:TextBox>
					    </InsertItemTemplate>
					    <ItemTemplate>
					        <asp:Label ID="LabelNoteTrasparenza" runat="server" Text='<%# Bind("note_trasparenza") %>'></asp:Label>
					    </ItemTemplate>
				        </asp:TemplateField>

    				    <%-- cella 18 --%>
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
						                    Enabled='<%# IsEnabled(DataBinder.Eval(DetailsView1.DataItem, "id_tipo_carica")) %>'
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
					        <ItemStyle HorizontalAlign="Center" />
				        </asp:TemplateField>
				    </Fields>
			    </asp:DetailsView>
			    
			    <asp:SqlDataSource ID="SqlDataSource2" 
			                       runat="server" 
			                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                   
				                   DeleteCommand="UPDATE [join_persona_organo_carica] 
				                                  SET [deleted] = 1 
				                                  WHERE [id_rec] = @id_rec"
				                   
				                   InsertCommand="INSERT INTO [join_persona_organo_carica] ([id_organo], 
				                                                                            [id_persona], 
				                                                                            [id_legislatura], 
				                                                                            [id_carica], 
				                                                                            [data_inizio], 
				                                                                            [data_fine], 
				                                                                            [circoscrizione], 
				                                                                            [data_elezione], 
				                                                                            [lista], 
				                                                                            [maggioranza], 
				                                                                            [voti], 
				                                                                            [neoeletto], 
				                                                                            [numero_pratica],
				                                                                            [data_proclamazione], 
				                                                                            [delibera_proclamazione], 
				                                                                            [data_delibera_proclamazione], 
				                                                                            [tipo_delibera_proclamazione], 
				                                                                            [protocollo_delibera_proclamazione], 
				                                                                            [data_convalida], 
				                                                                            [telefono], 
				                                                                            [fax], 
				                                                                            [id_causa_fine], 
				                                                                            [diaria], 
				                                                                            [note],
                                                                                            [note_trasparenza]) 
				                                  VALUES (@id_organo, 
				                                          @id_persona, 
				                                          @id_legislatura, 
				                                          @id_carica, 
				                                          @data_inizio, 
				                                          @data_fine, 
				                                          @circoscrizione, 
				                                          @data_elezione, 
				                                          @lista, 
				                                          @maggioranza, 
				                                          @voti, 
				                                          @neoeletto, 
				                                          @numero_pratica, 
				                                          @data_proclamazione, 
				                                          @delibera_proclamazione, 
				                                          @data_delibera_proclamazione, 
				                                          @tipo_delibera_proclamazione, 
				                                          @protocollo_delibera_proclamazione, 
				                                          @data_convalida, 
				                                          @telefono, 
				                                          @fax, 
				                                          @id_causa_fine, 
				                                          @diaria, 
				                                          @note,
                                                          @note_trasparenza); 
				                                  SELECT @id_rec = SCOPE_IDENTITY();"
				                   
				                   SelectCommand="SELECT 
														ll.num_legislatura, 
														cc.nome_carica,
														oo.nome_organo, 
														jj.*, 
														cf.descrizione_causa, 
														dd.tipo_delibera,
														cc.id_tipo_carica
				                                  FROM cariche AS cc 
				                                  INNER JOIN join_persona_organo_carica AS jj 
				                                  ON cc.id_carica = jj.id_carica 
				                                  INNER JOIN organi AS oo 
				                                    ON jj.id_organo = oo.id_organo 
				                                  LEFT OUTER JOIN tbl_cause_fine AS cf 
				                                    ON cf.id_causa = jj.id_causa_fine 
				                                  INNER JOIN legislature AS ll 
				                                    ON jj.id_legislatura = ll.id_legislatura 
				                                  LEFT OUTER JOIN tbl_delibere AS dd 
				                                    ON jj.tipo_delibera_proclamazione = dd.id_delibera
				                                  WHERE ([id_rec] = @id_rec)" 
				                   
				                   UpdateCommand="UPDATE [join_persona_organo_carica] 
				                                  SET [id_organo] = @id_organo, 
				                                      [id_persona] = @id_persona, 
				                                      [id_legislatura] = @id_legislatura, 
				                                      [id_carica] = @id_carica, 
				                                      [data_inizio] = @data_inizio, 
				                                      [data_fine] = @data_fine, 
				                                      [circoscrizione] = @circoscrizione, 
				                                      [data_elezione] = @data_elezione, 
				                                      [lista] = @lista, 
				                                      [maggioranza] = @maggioranza, 
				                                      [voti] = @voti, 
				                                      [neoeletto] = @neoeletto, 
				                                      [numero_pratica] = @numero_pratica, 
				                                      [data_proclamazione] = @data_proclamazione, 
				                                      [delibera_proclamazione] = @delibera_proclamazione, 
				                                      [data_delibera_proclamazione] = @data_delibera_proclamazione, 
				                                      [tipo_delibera_proclamazione] = @tipo_delibera_proclamazione, 
				                                      [protocollo_delibera_proclamazione] = @protocollo_delibera_proclamazione, 
				                                      [data_convalida] = @data_convalida, 
				                                      [telefono] = @telefono, 
				                                      [fax] = @fax, 
				                                      [id_causa_fine] = @id_causa_fine, 
				                                      [diaria] = @diaria, 
				                                      [note] = @note,
                                                      [note_trasparenza] = @note_trasparenza 
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
				        <asp:Parameter Name="id_organo" Type="Int32" />
				        <asp:Parameter Name="id_persona" Type="Int32" />
				        <asp:Parameter Name="id_legislatura" Type="Int32" />
				        <asp:Parameter Name="id_carica" Type="Int32" />
				        <asp:Parameter Name="data_inizio" Type="DateTime" />
				        <asp:Parameter Name="data_fine" Type="DateTime" />
				        <asp:Parameter Name="circoscrizione" Type="String" />
				        <asp:Parameter Name="data_elezione" Type="DateTime" />
				        <asp:Parameter Name="lista" Type="String" />
				        <asp:Parameter Name="maggioranza" Type="String" />
				        <asp:Parameter Name="voti" Type="Int32" />
				        <asp:Parameter Name="neoeletto" Type="Boolean" />
				        <asp:Parameter Name="numero_pratica" Type="String" />
				        <asp:Parameter Name="data_proclamazione" Type="DateTime" />
				        <asp:Parameter Name="delibera_proclamazione" Type="String" />
				        <asp:Parameter Name="data_delibera_proclamazione" Type="DateTime" />
				        <asp:Parameter Name="tipo_delibera_proclamazione" Type="Int32" />
				        <asp:Parameter Name="protocollo_delibera_proclamazione" Type="String" />
				        <asp:Parameter Name="data_convalida" Type="DateTime" />
				        <asp:Parameter Name="telefono" Type="String" />
				        <asp:Parameter Name="fax" Type="String" />
				        <asp:Parameter Name="id_causa_fine" Type="Int32" />
				        <asp:Parameter Name="diaria" Type="Boolean" />
				        <asp:Parameter Name="note" Type="String" />
                        <asp:Parameter Name="note_trasparenza" Type="String" />
				        <asp:Parameter Name="id_rec" Type="Int32" />
				    </UpdateParameters>
					
				    <InsertParameters>
				        <asp:Parameter Name="id_organo" Type="Int32" />
				        <asp:Parameter Name="id_persona" Type="Int32" />
				        <asp:Parameter Name="id_legislatura" Type="Int32" />
				        <asp:Parameter Name="id_carica" Type="Int32" />
				        <asp:Parameter Name="data_inizio" Type="DateTime" />
				        <asp:Parameter Name="data_fine" Type="DateTime" />
				        <asp:Parameter Name="circoscrizione" Type="String" />
				        <asp:Parameter Name="data_elezione" Type="DateTime" />
				        <asp:Parameter Name="lista" Type="String" />
				        <asp:Parameter Name="maggioranza" Type="String" />
				        <asp:Parameter Name="voti" Type="Int32" />
				        <asp:Parameter Name="neoeletto" Type="Boolean" />
				        <asp:Parameter Name="numero_pratica" Type="String" />
				        <asp:Parameter Name="data_proclamazione" Type="DateTime" />
				        <asp:Parameter Name="delibera_proclamazione" Type="String" />
				        <asp:Parameter Name="data_delibera_proclamazione" Type="DateTime" />
				        <asp:Parameter Name="tipo_delibera_proclamazione" Type="Int32" />
				        <asp:Parameter Name="protocollo_delibera_proclamazione" Type="String" />
				        <asp:Parameter Name="data_convalida" Type="DateTime" />
				        <asp:Parameter Name="telefono" Type="String" />
				        <asp:Parameter Name="fax" Type="String" />
				        <asp:Parameter Name="id_causa_fine" Type="Int32" />
				        <asp:Parameter Name="diaria" Type="Boolean" />
				        <asp:Parameter Name="note" Type="String" />
                        <asp:Parameter Name="note_trasparenza" Type="String" />
				        <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
				    </InsertParameters>
			    </asp:SqlDataSource>
			    
			    <asp:SqlDataSource ID="SqlDataSource5" 
			                       runat="server" 
			                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                   
				                   SelectCommand="SELECT descrizione_causa, 
				                                         MAX(id_causa) as id_causa
                                                  FROM [tbl_cause_fine] 
                                                  WHERE [tipo_causa] = 'Persona-Cariche-Organi' 
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
				<asp:LinkButton ID="LinkButtonExcelDetails" runat="server" OnClick="LinkButtonExcelDetails_Click">Esporta <img src="../img/page_white_excel.png" alt="" align="top" /><br /></asp:LinkButton>
				<asp:LinkButton ID="LinkButtonPdfDetails" runat="server" OnClick="LinkButtonPdfDetails_Click">Esporta <img src="../img/page_white_acrobat.png" alt="" align="top" /></asp:LinkButton>
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
	<asp:TextBox ID="TextBoxCalendarFake" 
	             runat="server" 
	             style="display: none;" >
	</asp:TextBox>
	
	<cc1:CalendarExtender ID="CalendarExtenderFake" 
	                      runat="server" 
	                      TargetControlID="TextBoxCalendarFake" 
	                      Format="dd/MM/yyyy" >
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