<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" MasterPageFile="~/MasterPage.master"
    CodeFile="componenti.aspx.cs" Inherits="organi_componenti" Title="Organo > Componenti" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Register Src="~/user_control/uc_Priorita.ascx" TagName="uc_Priorita" TagPrefix="pri" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True"></asp:ScriptManager>
 
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <pri:uc_Priorita runat="server" ID="uc_Priorita" />	    
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;
            </td>
        </tr>
        <tr>
            <td>
                <b>ORGANO &gt; COMPONENTI</b>
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
                        <li><a id="a_cariche" runat="server">CARICHE</a></li>
                    </ul>
                </div>
                <div id="tab_content">
                    <div id="tab_content_content">
                        <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <table>
                                    <tr>
                                        <td valign="middle">
                                            <%--<asp:Label ID="lblLeg_Search" 
			                                           runat="server"
			                                           Text="Seleziona legislatura: "
			                                           Width="130px" >
			                                </asp:Label>
                            			    
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
			                                </asp:SqlDataSource>--%>
                                            <asp:Label ID="lblLeg_Search" runat="server" Text="Legislatura: " Width="100px">
                                            </asp:Label>
                                            <asp:Label ID="lblLeg_Search_Val" runat="server" Width="100px">
                                            </asp:Label>
                                        </td>
                                        <td width="50px">
                                        </td>
                                        <td valign="middle">
                                            <asp:Label ID="lblData_Search" runat="server" Text="Seleziona data: " Width="100px">
                                            </asp:Label>
                                            <asp:TextBox ID="TextBoxFiltroData" runat="server" Text='<%# Bind("data_fine") %>'
                                                Width="70px">
                                            </asp:TextBox>
                                            <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
                                            <cc1:CalendarExtender ID="CalendarExtenderFiltroData" runat="server" TargetControlID="TextBoxFiltroData"
                                                PopupButtonID="ImageFiltroData" Format="dd/MM/yyyy">
                                            </cc1:CalendarExtender>
                                            <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" ControlToValidate="TextBoxFiltroData"
                                                runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                ValidationGroup="FiltroData">
                                            </asp:RegularExpressionValidator>
                                            <%-- 
                                            <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
                                            </asp:ScriptManager>
                                            --%>
                                        </td>
                                        <td width="50px">
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="middle" align="left">
                                            <asp:Label ID="lblCarica_Search" runat="server" Text="Seleziona Carica: " Width="100px">
                                            </asp:Label>
                                            <asp:DropDownList ID="DropDownListCarica" runat="server" DataSourceID="SqlDataSourceCariche"
                                                DataTextField="nome_carica" DataValueField="id_carica" Width="320px" AppendDataBoundItems="True">
                                                <asp:ListItem Text="(tutte)" Value="" />
                                            </asp:DropDownList>
                                            <asp:SqlDataSource ID="SqlDataSourceCariche" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                SelectCommand="SELECT DISTINCT cc.id_carica, 
				                                                  cc.nome_carica,
				                                                  cc.ordine 
				                                  FROM cariche cc, 
				                                       join_cariche_organi jco
				                                  WHERE jco.id_carica = cc.id_carica
				                                    AND jco.id_organo = @id_organo
				                                    AND deleted = 0	
				                                  ORDER BY cc.ordine ASC" OnSelecting="SqlDataSourceCariche_Selecting">
                                                <SelectParameters>
                                                    <asp:Parameter Name="id_organo" Type="Int32" />
                                                </SelectParameters>
                                            </asp:SqlDataSource>
                                        </td>
                                        <td width="50px">
                                        </td>
                                        <td align="left" valign="middle">
                                            <asp:Label ID="lblStatoCarica_Search" runat="server" Text="Seleziona Stato: " Width="100px">
                                            </asp:Label>
                                            <asp:DropDownList ID="ddlStatoCarica_Search" runat="server">
                                                <asp:ListItem Text="(tutte)" Value="" />
                                                <asp:ListItem Text="In carica" Value="1" Selected="True" />
                                                <asp:ListItem Text="Non in carica" Value="2" />
                                            </asp:DropDownList>
                                        </td>
                                        <td width="50px">
                                        </td>
                                        <td valign="middle" align="right">
                                            <asp:Button ID="ButtonFiltri" runat="server" Text="Applica" OnClick="ButtonFiltri_Click"
                                                ValidationGroup="FiltroData" />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <br />
                                <!-- INIZIO GRID VIEW -->
                                <asp:GridView ID="GridView1" runat="server" AllowSorting="True" AutoGenerateColumns="False"
                                    CellPadding="5" CssClass="tab_gen" DataSourceID="SqlDataSource1" GridLines="None"
                                    DataKeyNames="id_rec" OnSorting="ButtonFiltri_Click" OnRowDataBound="GridView1_RowDataBound">
                                    <EmptyDataTemplate>
                                        <table width="100%" class="tab_gen">
                                            <tr>
                                                <th align="center">
                                                    Nessun record trovato.
                                                </th>
                                                <th width="100">
                                                    <% if (role <= 2 || role == 4)
                                                       { %>
                                                    <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
                                                        CausesValidation="false" />
                                                    <% } %>
                                                </th>
                                            </tr>
                                        </table>
                                    </EmptyDataTemplate>
                                    <Columns>
                                        <asp:TemplateField HeaderText="Cognome" SortExpression="cognome">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkbtn_cognome" runat="server" Text='<%# Eval("cognome") %>'
                                                    Font-Bold="true" OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>'>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                            <ItemStyle Font-Bold="True" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Nome" SortExpression="nome">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkbtn_nome" runat="server" Text='<%# Eval("nome") %>' Font-Bold="true"
                                                    OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>'>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                            <ItemStyle Font-Bold="True" />
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="nome_carica" HeaderText="Carica" SortExpression="nome_carica" />
                                        <asp:TemplateField HeaderText="Priorità Attuale" SortExpression="priorita_attuale">
				                            <ItemTemplate>                            
                                                <asp:Label ID="priorita_attuale" 
					                                            runat="server" 
                                                                Text='<%# Eval("priorita_attuale") %>'
                                                                Visible='<%# Eval("abilita_commissioni_priorita")%>'>
                                                </asp:Label>
				                            </ItemTemplate>
				                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
				                        </asp:TemplateField>
                                        <asp:BoundField DataField="data_inizio" HeaderText="Dal" SortExpression="data_inizio"
                                            DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px">
                                            <ItemStyle HorizontalAlign="Center" Width="80px" />
                                        </asp:BoundField>
                                        <asp:BoundField DataField="data_fine" HeaderText="Al" SortExpression="data_fine"
                                            DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px">
                                            <ItemStyle HorizontalAlign="Center" Width="80px" />
                                        </asp:BoundField>
                                        <asp:TemplateField HeaderText="Gruppo Politico" SortExpression="nome_gruppo">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkbtn_gruppo" runat="server" Text='<%# Eval("nome_gruppo") %>'
                                                    Font-Bold="true" OnClientClick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>'>
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
                                                <% if (role <= 2 || role == 4)
                                                   { %>
                                                <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
                                                    CausesValidation="false" />
                                                <% } %>
                                            </HeaderTemplate>
                                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />                                        
                                        </asp:TemplateField>
                                        <asp:TemplateField>
				                            <ItemTemplate>                            
					                            <asp:LinkButton ID="LinkButtonPriorita" 
					                                            runat="server" 
					                                            CausesValidation="False" 
					                                            Text="Priorità"
					                                            Visible='<%# Eval("abilita_commissioni_priorita")%>'
                                            
					                                            OnClick="LinkButtonPriorita_Click">
					                            </asp:LinkButton>

				                            </ItemTemplate>
				                            <HeaderTemplate>
				                            </HeaderTemplate>
				                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
				                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <!-- FINE GRID VIEW -->
                                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>">
                                    <%--<SelectParameters>
				                        <asp:SessionParameter Name="id_organo" SessionField="id_organo" />
			                        </SelectParameters>--%>
                                </asp:SqlDataSource>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <br />
                        <div align="right">
                            <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click">
		        <img src="../img/page_white_excel.png" 
		             alt="" 
		             align="top" /> 
		        Esporta
                            </asp:LinkButton>
                            -
                            <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click">
		        <img src="../img/page_white_acrobat.png" 
		             alt="" 
		             align="top" /> 
		        Esporta
                            </asp:LinkButton>
                        </div>
                        <asp:Panel ID="PanelDetails" runat="server" BackColor="White" BorderColor="DarkSeaGreen"
                            BorderWidth="2px" Width="500" ScrollBars="Vertical" Style="padding: 10px; display: none;
                            max-height: 500px;">
                            <div align="center">
                                <br />
                                <h3>
                                    COMPONENTI
                                </h3>
                                <br />
                                <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <!-- INIZIO DETAILSVIEW -->
                                        <asp:DetailsView ID="DetailsView1" runat="server" AutoGenerateRows="False" DataKeyNames="id_rec"
                                            Width="420px" DataSourceID="SqlDataSourceDetails" CssClass="tab_det" OnModeChanged="DetailsView1_ModeChanged"
                                            OnItemInserted="DetailsView1_ItemInserted" OnItemInserting="DetailsView1_ItemInserting"
                                            OnItemUpdated="DetailsView1_ItemUpdated" OnItemUpdating="DetailsView1_ItemUpdating"
                                            OnItemDeleted="DetailsView1_ItemDeleted">
                                            <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
                                            <RowStyle HorizontalAlign="left" />
                                            <HeaderStyle Font-Bold="False" />
                                            <Fields>
                                                <asp:TemplateField HeaderText="Legislatura">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelLeg" runat="server" Text='<%# Bind("num_legislatura") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <InsertItemTemplate>
                                                        <%--<asp:DropDownList ID="DropDownListLeg" 
					                                          runat="server" 
					                                          DataSourceID="SqlDataSourceLeg"
						                                      DataTextField="num_legislatura"
						                                      DataValueField="id_legislatura" 
						                                      Width="200px" 
						                                      Enabled="false" 
						                                      AutoPostBack="True" 
						                                      AppendDataBoundItems="True">
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
                        						                           
						                                                   SelectCommand="SELECT id_legislatura, 
						                                                                         num_legislatura 
						                                                                  FROM legislature
						                                                                  WHERE id_legislatura = @id_legislatura" >
						                                    <SelectParameters>
						                                        <asp:SessionParameter Name="id_legislatura" Type="Int32" SessionField="id_legislatura_organo" />
						                                    </SelectParameters>
					                                    </asp:SqlDataSource>--%>
                                                        <asp:Label ID="LabelLeg" runat="server" Text='<%# legislatura_organo_name %>'>
                                                        </asp:Label>
                                                    </InsertItemTemplate>
                                                    <EditItemTemplate>
                                                        <%--<asp:DropDownList ID="DropDownListLeg" 
					                                          runat="server" 
					                                          DataSourceID="SqlDataSourceLeg"
						                                      SelectedValue='<%# Eval("id_legislatura") %>' 
						                                      DataTextField="num_legislatura"
						                                      DataValueField="id_legislatura" 
						                                      Width="200px" 
						                                      Enabled="false" 
						                                      AutoPostBack="True" 
						                                      AppendDataBoundItems="True" >
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
						                                                   SelectCommand="SELECT id_legislatura, 
						                                                                         num_legislatura 
						                                                                  FROM legislature
						                                                                  ORDER BY durata_legislatura_da DESC" >
					                                    </asp:SqlDataSource>--%>
                                                        <asp:Label ID="LabelLeg" runat="server" Text='<%# Bind("num_legislatura") %>'>
                                                        </asp:Label>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Consigliere">
                                                    <ItemTemplate>
                                                        <asp:Label ID="label_nome_completo" runat="server" Text='<%# Eval("nome_completo") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:HiddenField ID="TextBoxPersonaId" runat="server" Value='<%# Bind("id_persona") %>'>
                                                        </asp:HiddenField>
                                                        <asp:TextBox ID="TextBoxPersona" runat="server" Text='<%# Bind("nome_completo") %>'>
                                                        </asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorPersona" ControlToValidate="TextBoxPersona"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup">
                                                        </asp:RequiredFieldValidator>
                                                        <div id="DivPersona">
                                                        </div>
                                                        <% if (comitato_ristretto)
                                                           { %>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderCommIns" runat="server" EnableCaching="True"
                                                            TargetControlID="TextBoxPersona" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersoneCommissione"
                                                            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivPersona"
                                                            CompletionSetCount="15" UseContextKey="true" OnPreRender="AutoCompleteExtender_PreRender"
                                                             OnClientItemSelected="autoCompletePersonaSelected">
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
                                                        <%  
                                                            }
                                                           else
                                                           { %>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona" runat="server" EnableCaching="True"
                                                            TargetControlID="TextBoxPersona" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersoneAll"
                                                            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivPersona"
                                                            CompletionSetCount="15" OnClientItemSelected="autoCompletePersonaSelected">
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
                                                        <% } %>
                                                    </InsertItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:HiddenField ID="TextBoxPersonaId" runat="server" Value='<%# Bind("id_persona") %>'>
                                                        </asp:HiddenField>
                                                        <asp:TextBox ID="TextBoxPersona" runat="server" Text='<%# Bind("nome_completo") %>'>
                                                        </asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorPersona" ControlToValidate="TextBoxPersona"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup">
                                                        </asp:RequiredFieldValidator>
                                                        <div id="DivPersona">
                                                        </div>
                                                         <% if (comitato_ristretto)
                                                           { %>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderCommEdit" runat="server" EnableCaching="True"
                                                            TargetControlID="TextBoxPersona" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersoneCommissione"
                                                            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivPersona"
                                                            CompletionSetCount="15" UseContextKey="true" OnPreRender="AutoCompleteExtender_PreRender"
                                                             OnClientItemSelected="autoCompletePersonaSelected">
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
                                                        <%  
                                                            }
                                                           else
                                                           { %>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona" runat="server" EnableCaching="True"
                                                            TargetControlID="TextBoxPersona" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersoneAll"
                                                            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivPersona"
                                                            CompletionSetCount="15" OnClientItemSelected="autoCompletePersonaSelected">
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
                                                        <% } %>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Carica">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelCarica" runat="server" Text='<%# Eval("nome_carica") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:DropDownList ID="DropDownListCarica" runat="server" DataSourceID="SqlDataSourceCarica"
                                                            DataTextField="nome_carica" DataValueField="id_carica" Width="200px" AutoPostBack="True"
                                                            OnDataBound="DropDownListCarica_DataBound" OnSelectedIndexChanged="DropDownListCarica_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                        <asp:SqlDataSource ID="SqlDataSourceCarica" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT cc.id_carica, 
						                                                 cc.nome_carica, 
						                                                 jj.flag 
						                                          FROM join_cariche_organi AS jj 
						                                          INNER JOIN cariche AS cc 
						                                            ON jj.id_carica = cc.id_carica 
						                                          WHERE jj.deleted = 0 
						                                            AND jj.id_organo = @id_organo">
                                                            <SelectParameters>
                                                                <asp:SessionParameter SessionField="id_organo" Name="id_organo" Type="Int32" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorListCarica" runat="server"
                                                            ErrorMessage="Campo obbligatorio." ControlToValidate="DropDownListCarica" Display="Dynamic"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:DropDownList ID="DropDownListCarica" runat="server" DataSourceID="SqlDataSourceCarica"
                                                            DataTextField="nome_carica" DataValueField="id_carica" Width="200px" AutoPostBack="True"
                                                            OnDataBound="DropDownListCarica_DataBound" OnSelectedIndexChanged="DropDownListCarica_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                        <asp:SqlDataSource ID="SqlDataSourceCarica" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT cc.id_carica, 
						                                                          cc.nome_carica, 
						                                                          jj.flag 
						                                                   FROM join_cariche_organi AS jj 
						                                                   INNER JOIN cariche AS cc 
						                                                     ON jj.id_carica = cc.id_carica 
						                                                   WHERE jj.deleted = 0 
						                                                     AND jj.id_organo = @id_organo">
                                                            <SelectParameters>
                                                                <asp:SessionParameter SessionField="id_organo" Name="id_organo" Type="Int32" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorListCarica" runat="server"
                                                            ErrorMessage="Campo obbligatorio." ControlToValidate="DropDownListCarica" Display="Dynamic"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelDataInizio" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataInizio" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizio" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataInizio" runat="server" TargetControlID="TextBoxDataInizio"
                                                            PopupButtonID="ImageDataInizio" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="TextBoxDataInizio"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataInizio" ControlToValidate="TextBoxDataInizio"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataInizio" runat="server"></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizio" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataInizio" runat="server" TargetControlID="TextBoxDataInizio"
                                                            PopupButtonID="ImageDataInizio" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="TextBoxDataInizio"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataInizio" ControlToValidate="TextBoxDataInizio"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelDataFine" runat="server" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataFine" runat="server" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFine" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataFine" runat="server" TargetControlID="TextBoxDataFine"
                                                            PopupButtonID="ImageDataFine" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataFine" ControlToValidate="TextBoxDataFine"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataFine" runat="server"></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFine" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataFine" runat="server" TargetControlID="TextBoxDataFine"
                                                            PopupButtonID="ImageDataFine" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataFine" ControlToValidate="TextBoxDataFine"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
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
                                                <asp:TemplateField HeaderText="Data Proclamazione" SortExpression="data_proclamazione">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelDataProclamazione" runat="server" Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataProclamazione" runat="server" Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataProclamazione" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataProclamazione" runat="server" TargetControlID="TextBoxDataProclamazione"
                                                            PopupButtonID="ImageDataProclamazione" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataProclamazione" ControlToValidate="TextBoxDataProclamazione"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataProclamazione" runat="server"></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataProclamazione" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataProclamazione" runat="server" TargetControlID="TextBoxDataProclamazione"
                                                            PopupButtonID="ImageDataProclamazione" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataProclamazione" ControlToValidate="TextBoxDataProclamazione"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
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
                                                <asp:TemplateField HeaderText="Data Delibera Proclamazione" SortExpression="data_delibera_proclamazione">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelDataDeliberaProclamazione" runat="server" Text='<%# Eval("data_delibera_proclamazione", "{0:dd/MM/yyyy}") %>'></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataDeliberaProclamazione" runat="server" Text='<%# Eval("data_delibera_proclamazione", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataDeliberaProclamazione"
                                                            runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataDeliberaProclamazione" runat="server"
                                                            TargetControlID="TextBoxDataDeliberaProclamazione" PopupButtonID="ImageDataDeliberaProclamazione"
                                                            Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataDeliberaProclamazione" ControlToValidate="TextBoxDataDeliberaProclamazione"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataDeliberaProclamazione" runat="server"></asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataDeliberaProclamazione"
                                                            runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataDeliberaProclamazione" runat="server"
                                                            TargetControlID="TextBoxDataDeliberaProclamazione" PopupButtonID="ImageDataDeliberaProclamazione"
                                                            Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataDeliberaProclamazione" ControlToValidate="TextBoxDataDeliberaProclamazione"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
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
                                                            SelectCommand="SELECT * 
						                                          FROM [tbl_delibere]"></asp:SqlDataSource>
                                                    </InsertItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:DropDownList ID="DropDownListTipoDeliberaProclamazione" runat="server" DataSourceID="SqlDataSourceTipoDeliberaProclamazione"
                                                            DataTextField="tipo_delibera" DataValueField="id_delibera" SelectedValue='<%# Bind("tipo_delibera_proclamazione") %>'
                                                            Width="200px" AppendDataBoundItems="true">
                                                            <asp:ListItem Text="(seleziona)" Value="" />
                                                        </asp:DropDownList>
                                                        <asp:SqlDataSource ID="SqlDataSourceTipoDeliberaProclamazione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT * 
						                                          FROM [tbl_delibere]"></asp:SqlDataSource>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Protocollo Delibera Proclamazione" SortExpression="protocollo_delibera_proclamazione">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelProtocolloDeliberaProclamazione" runat="server" Text='<%# Bind("protocollo_delibera_proclamazione") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxProtocolloDeliberaProclamazione" runat="server" Text='<%# Bind("protocollo_delibera_proclamazione") %>'
                                                            MaxLength="50">
                                                        </asp:TextBox>
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxProtocolloDeliberaProclamazione" runat="server" Text='<%# Bind("protocollo_delibera_proclamazione") %>'
                                                            MaxLength="50">
                                                        </asp:TextBox>
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Data Convalida" SortExpression="data_convalida">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelDataConvalida" runat="server" Text='<%# Eval("data_convalida", "{0:dd/MM/yyyy}") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataConvalida" runat="server" Text='<%# Eval("data_convalida", "{0:dd/MM/yyyy}") %>'>
                                                        </asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataConvalida" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataConvalida" runat="server" TargetControlID="TextBoxDataConvalida"
                                                            PopupButtonID="ImageDataConvalida" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataConvalida" ControlToValidate="TextBoxDataConvalida"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxDataConvalida" runat="server">
                                                        </asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataConvalida" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataConvalida" runat="server" TargetControlID="TextBoxDataConvalida"
                                                            PopupButtonID="ImageDataConvalida" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDataConvalida" ControlToValidate="TextBoxDataConvalida"
                                                            runat="server" Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
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
                                                        <asp:TextBox ID="TextBoxTelefono" runat="server" Text='<%# Bind("telefono") %>' MaxLength="20">
                                                        </asp:TextBox>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionTelefono" ControlToValidate="TextBoxTelefono"
                                                            runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Fax" SortExpression="fax">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelFax" runat="server" Text='<%# Bind("fax") %>'></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="TextBoxFax" runat="server" Text='<%# Bind("fax") %>' MaxLength="20">
                                                        </asp:TextBox>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionFax" ControlToValidate="TextBoxFax"
                                                            runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="TextBoxFax" runat="server" Text='<%# Bind("fax") %>' MaxLength="20">
                                                        </asp:TextBox>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionFax" ControlToValidate="TextBoxFax"
                                                            runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Causa fine">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelCausa" runat="server" Text='<%# Eval("descrizione_causa") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:DropDownList ID="DropDownListCausa" runat="server" DataSourceID="SqlDataSource5"
                                                            DataTextField="descrizione_causa" DataValueField="id_causa" SelectedValue='<%# Bind("id_causa_fine") %>'
                                                            Width="200px" AppendDataBoundItems="True">
                                                            <asp:ListItem Value="">(nessuna)</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </InsertItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:DropDownList ID="DropDownListCausa" runat="server" DataSourceID="SqlDataSource5"
                                                            DataTextField="descrizione_causa" DataValueField="id_causa" SelectedValue='<%# Bind("id_causa_fine") %>'
                                                            Width="200px" AppendDataBoundItems="True">
                                                            <asp:ListItem Value="">(nessuna)</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <%--<asp:CheckBoxField DataField="diaria" HeaderText="Diaria" SortExpression="diaria" />--%>
                                                <asp:CheckBoxField DataField="diaria" HeaderText="Opzione" SortExpression="diaria" />
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
                                                            Text="Modifica" Visible="<%# (role <= 2 || role == 4) ? true : false %>" />
                                                        <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
                                                            Text="Elimina" Visible="<%# (role <= 2 || role == 4) ? true : false %>" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                                                        <asp:Button ID="Button4" runat="server" CausesValidation="False" Text="Chiudi" CssClass="button"
                                                            OnClick="ButtonAnnulla_Click" CommandName="Cancel" />
                                                    </ItemTemplate>
                                                    <ItemStyle HorizontalAlign="Center" />
                                                    <ControlStyle CssClass="button" />
                                                </asp:TemplateField>
                                            </Fields>
                                        </asp:DetailsView>
                                        <!-- FINE DETAILSVIEW -->
                                        <asp:SqlDataSource ID="SqlDataSourceDetails" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                            DeleteCommand="UPDATE join_persona_organo_carica 
				                                  SET deleted = 1 
				                                  WHERE id_rec = @id_rec" InsertCommand="INSERT INTO join_persona_organo_carica (id_organo, 
				                                                                          id_persona, 
				                                                                          id_legislatura, 
				                                                                          id_carica, 
				                                                                          data_inizio, 
				                                                                          data_fine, 
				                                                                          circoscrizione, 
				                                                                          data_elezione, 
				                                                                          lista, 
				                                                                          maggioranza, 
				                                                                          voti, 
				                                                                          neoeletto, 
				                                                                          numero_pratica, 
				                                                                          data_proclamazione, 
				                                                                          delibera_proclamazione, 
				                                                                          data_delibera_proclamazione, 
				                                                                          tipo_delibera_proclamazione, 
				                                                                          protocollo_delibera_proclamazione, 
				                                                                          data_convalida, 
				                                                                          telefono, 
				                                                                          fax, 
				                                                                          id_causa_fine, 
				                                                                          diaria, 
				                                                                          note) 
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
				                                          @note); 
				                                  SELECT @id_rec = SCOPE_IDENTITY();" SelectCommand="SELECT ll.num_legislatura, 
				                                         cc.nome_carica, 
				                                         jj.*, 
				                                         cf.descrizione_causa, 
				                                         dd.tipo_delibera, 
				                                         pp.cognome + ' ' +  pp.nome AS nome_completo,
				                                         oo.comitato_ristretto, oo.id_commissione,
                                                         pp.id_persona
				                                  FROM cariche AS cc 
				                                  INNER JOIN join_persona_organo_carica AS jj 
				                                    ON cc.id_carica = jj.id_carica 
				                                  LEFT OUTER JOIN tbl_cause_fine AS cf 
				                                    ON cf.id_causa = jj.id_causa_fine 
				                                  INNER JOIN legislature AS ll 
				                                    ON jj.id_legislatura = ll.id_legislatura 
				                                  LEFT OUTER JOIN tbl_delibere AS dd 
				                                    ON jj.tipo_delibera_proclamazione = dd.id_delibera 
				                                  INNER JOIN persona AS pp 
				                                    ON pp.id_persona = jj.id_persona
				                                  INNER JOIN organi AS oo 
				                                    ON jj.id_organo = oo.id_organo  
				                                  WHERE id_rec = @id_rec" UpdateCommand="UPDATE [join_persona_organo_carica] 
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
				                                      [note] = @note 
				                                  WHERE [id_rec] = @id_rec" 
                                            OnInserted="SqlDataSource2_Inserted"
                                            OnUpdated="SqlDataSourceDetails_Updated"
                                            OnDeleted="SqlDataSourceDetails_Deleted">
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
                                                <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                                            </InsertParameters>
                                        </asp:SqlDataSource>
                                        <asp:SqlDataSource ID="SqlDataSource5" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                            SelectCommand="SELECT descrizione_causa, 
				                                         MAX(id_causa) as id_causa
                                                  FROM tbl_cause_fine 
                                                  WHERE LOWER(tipo_causa) = 'persona-cariche-organi'
                                                  GROUP BY descrizione_causa
                                                  ORDER BY descrizione_causa"></asp:SqlDataSource>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <br />
                            <asp:UpdatePanel ID="UpdatePanelEsporta" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div align="right">
                                        <asp:LinkButton ID="LinkButtonExcelDetails" runat="server" OnClick="LinkButtonExcelDetails_Click">
				    Esporta 
				    <img src="../img/page_white_excel.png" 
				         alt="" 
				         align="top" />
				         <br />
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="LinkButtonPdfDetails" runat="server" OnClick="LinkButtonPdfDetails_Click">
				    Esporta 
				    <img src="../img/page_white_acrobat.png" 
				         alt="" 
				         align="top" />
                                        </asp:LinkButton>
                                    </div>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:PostBackTrigger ControlID="LinkButtonExcelDetails" />
                                    <asp:PostBackTrigger ControlID="LinkButtonPdfDetails" />
                                </Triggers>
                            </asp:UpdatePanel>
                            <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" BehaviorID="ModalPopup1" runat="server"
                                PopupControlID="PanelDetails" BackgroundCssClass="modalBackground" DropShadow="true"
                                TargetControlID="ButtonDetailsFake" />
                            <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
                        </asp:Panel>
                    </div>
                </div>
                <%--Fix per lo stile dei calendarietti--%>
                <asp:TextBox ID="TextBoxCalendarFake" runat="server" Style="display: none;">
                </asp:TextBox>
                <cc1:CalendarExtender ID="CalendarExtenderFake" runat="server" TargetControlID="TextBoxCalendarFake"
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
                <b><a id="a_back" runat="server" href="../organi/gestisciOrgani.aspx">« Indietro </a>
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

