<%@ Page Language="C#"
    MasterPageFile="~/MasterPage.master"
    AutoEventWireup="true"
    CodeFile="missioni_assessori.aspx.cs"
    Inherits="missioni_assessori"
    Title="Assessori > Missioni" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>&nbsp;
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
                                        <asp:Label ID="LabelHeadNome" runat="server" Text='<%# Eval("nome") + " " + Eval("cognome") %>' /></span>
                                    <br />
                                    <asp:Label ID="LabelHeadDataNascita" runat="server" Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>'>
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
			                          WHERE pp.id_persona = @id_persona">

                    <SelectParameters>
                        <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                    </SelectParameters>
                </asp:SqlDataSource>
            </td>
        </tr>
        <tr>
            <td>&nbsp;
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
                                        <td valign="top" width="230">Seleziona legislatura:
				    <asp:DropDownList ID="DropDownListLegislatura" runat="server" DataSourceID="SqlDataSourceLegislature"
                        DataTextField="num_legislatura" DataValueField="id_legislatura" Width="70px"
                        AppendDataBoundItems="True">
                        <asp:ListItem Text="(tutte)" Value="" />
                    </asp:DropDownList>
                                            <asp:SqlDataSource ID="SqlDataSourceLegislature" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                SelectCommand="SELECT [id_legislatura], 
					                      [num_legislatura] 
					               FROM [legislature]"></asp:SqlDataSource>
                                        </td>
                                        <td valign="top" width="230">Seleziona data:
				    <asp:TextBox ID="TextBoxFiltroData"
                        runat="server"
                        Width="70px">
                    </asp:TextBox>
                                            <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
                                            <cc1:CalendarExtender ID="CalendarExtender2"
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
                                    AllowSorting="True"
                                    AutoGenerateColumns="False"
                                    CellPadding="5"
                                    CssClass="tab_gen"
                                    DataKeyNames="id_rec"
                                    DataSourceID="SqlDataSource1"
                                    GridLines="None">

                                    <EmptyDataTemplate>
                                        <table width="100%" class="tab_gen">
                                            <tr>
                                                <th align="center">Nessun record trovato.
                                                </th>
                                                <th width="100">
                                                    <% if (role <= 2)
                                                    { %>
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
                                                    OnClientClick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>'>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Missione" SortExpression="oggetto">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkbtn_missione"
                                                    runat="server"
                                                    Text='<%# Eval("oggetto") %>'
                                                    Font-Bold="true"
                                                    OnClientClick='<%# getPopupURL("../missioni/dettaglio.aspx", Eval("id_missione")) %>'>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                            <ItemStyle Font-Bold="True" />
                                        </asp:TemplateField>

                                        <asp:CheckBoxField DataField="partecipato"
                                            HeaderText="Partecipato?"
                                            SortExpression="partecipato"
                                            ReadOnly="True"
                                            ItemStyle-HorizontalAlign="center"
                                            ItemStyle-Width="80px" />

                                        <asp:CheckBoxField DataField="incluso"
                                            HeaderText="Incluso?"
                                            SortExpression="incluso"
                                            ReadOnly="True"
                                            ItemStyle-HorizontalAlign="center"
                                            ItemStyle-Width="80px" />

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

                                        <asp:TemplateField HeaderText="Sostituito da" SortExpression="nome_completo">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkbtn_sostituto"
                                                    runat="server"
                                                    Text='<%# Eval("nome_completo") %>'
                                                    Font-Bold="true"
                                                    OnClientClick='<%# getPopupURL("../persona/dettaglio_assessori.aspx", Eval("id_sostituto")) %>'>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                            <ItemStyle Font-Bold="True" />
                                        </asp:TemplateField>

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
                                                <% if (role <= 2)
                                                { %>
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
		                                             mm.id_missione, 
		                                             mm.oggetto, 
		                                             jj.id_rec, 
		                                             jj.partecipato,
		                                             jj.incluso, 
		                                             jj.data_inizio, 
		                                             jj.data_fine, 
		                                             pp.id_persona AS id_sostituto, 
		                                             pp.cognome + ' ' +  pp.nome AS nome_completo
				                              FROM join_persona_missioni AS jj 
		                                      LEFT OUTER JOIN persona AS pp 
		                                        ON pp.id_persona = jj.sostituito_da 
		                                      INNER JOIN missioni AS mm 
		                                        ON jj.id_missione = mm.id_missione 
		                                      INNER JOIN legislature AS ll 
		                                        ON mm.id_legislatura = ll.id_legislatura
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
                            <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click">
		    <img src="../img/page_white_excel.png" alt="" align="top" /> 
		    Esporta
                            </asp:LinkButton>
                            -
		    <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click">
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
                                <h3>MISSIONI
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
                                                <asp:TemplateField HeaderText="Legislatura">
                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelLeg" runat="server" Text='<%# Bind("num_legislatura") %>'></asp:Label>
                                                    </ItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:DropDownList ID="DropDownListLeg" runat="server" DataSourceID="SqlDataSourceLeg"
                                                            SelectedValue='<%# Eval("id_legislatura") %>' DataTextField="num_legislatura"
                                                            DataValueField="id_legislatura" Width="200px" AutoPostBack="True" AppendDataBoundItems="True">
                                                            <asp:ListItem Value="" Text="(seleziona)" />
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" ControlToValidate="DropDownListLeg"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
                                                        <asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT [id_legislatura], 
						                                  [num_legislatura] 
						                           FROM [legislature]"></asp:SqlDataSource>
                                                    </InsertItemTemplate>

                                                    <EditItemTemplate>
                                                        <asp:DropDownList ID="DropDownListLeg" runat="server" DataSourceID="SqlDataSourceLeg"
                                                            SelectedValue='<%# Eval("id_legislatura") %>' DataTextField="num_legislatura"
                                                            DataValueField="id_legislatura" Width="200px" AutoPostBack="True" AppendDataBoundItems="True">
                                                            <asp:ListItem Value="" Text="(seleziona)" />
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" ControlToValidate="DropDownListLeg"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
                                                        <asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT [id_legislatura], 
						                                  [num_legislatura] 
						                           FROM [legislature]"></asp:SqlDataSource>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Missione">
                                                    <ItemTemplate>
                                                        <asp:Label ID="label_oggetto" runat="server" Text='<%# Eval("oggetto") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:DropDownList ID="DropDownListMissione" runat="server" DataSourceID="SqlDataSourceMissione"
                                                            DataTextField="descr_missione" DataValueField="id_missione" Width="200px" OnDataBound="DropDownListMissione_DataBound">
                                                        </asp:DropDownList>
                                                        <asp:SqlDataSource ID="SqlDataSourceMissione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT id_missione, 
						                                  citta + ', ' + SUBSTRING(oggetto, 0, 30) AS descr_missione 
						                           FROM missioni 
						                           WHERE (deleted = 0) 
						                             AND (id_legislatura = @id_legislatura) 
						                           ORDER BY oggetto">
                                                            <SelectParameters>
                                                                <asp:ControlParameter ControlID="DetailsView1$DropDownListLeg" Name="id_legislatura"
                                                                    PropertyName="SelectedValue" Type="Int32" DefaultValue="0" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorMissione" runat="server" ErrorMessage="Campo obbligatorio."
                                                            ControlToValidate="DropDownListMissione" Display="Dynamic" ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>

                                                    <EditItemTemplate>
                                                        <asp:DropDownList ID="DropDownListMissione" runat="server" DataSourceID="SqlDataSourceMissione"
                                                            DataTextField="descr_missione" DataValueField="id_missione" Width="200px" OnDataBound="DropDownListMissione_DataBound">
                                                        </asp:DropDownList>
                                                        <br />
                                                        <asp:Label ID="LabelMissione" runat="server" Text=""></asp:Label>
                                                        <asp:SqlDataSource ID="SqlDataSourceMissione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                            SelectCommand="SELECT id_missione, 
						                                  citta + ', ' + SUBSTRING(oggetto, 0, 30) AS descr_missione 
						                           FROM missioni 
						                           WHERE (deleted = 0) 
						                             AND (id_legislatura = @id_legislatura) 
						                           ORDER BY oggetto">
                                                            <SelectParameters>
                                                                <asp:ControlParameter ControlID="DetailsView1$DropDownListLeg" Name="id_legislatura"
                                                                    PropertyName="SelectedValue" Type="Int32" DefaultValue="0" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorMissione" runat="server" ErrorMessage="Campo obbligatorio."
                                                            ControlToValidate="DropDownListMissione" Display="Dynamic" ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>
                                                </asp:TemplateField>

                                                <asp:CheckBoxField DataField="partecipato"
                                                    HeaderText="Partecipato?"
                                                    SortExpression="partecipato" />

                                                <asp:CheckBoxField DataField="incluso"
                                                    HeaderText="Incluso?"
                                                    SortExpression="incluso" />

                                                <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
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
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioEdit" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataInizioEdit"
                                                            runat="server"
                                                            TargetControlID="DataInizioEdit"
                                                            PopupButtonID="ImageDataInizioEdit"
                                                            Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizio"
                                                            ControlToValidate="DataInizioEdit"
                                                            runat="server"
                                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            Display="Dynamic"
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox ID="DataInizioInsert"
                                                            runat="server">
                                                        </asp:TextBox>
                                                        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioInsert" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtenderDataInizioInsert"
                                                            runat="server"
                                                            TargetControlID="DataInizioInsert"
                                                            PopupButtonID="ImageDataInizioInsert"
                                                            Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizio"
                                                            ControlToValidate="DataInizioInsert"
                                                            runat="server"
                                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                                            Display="Dynamic"
                                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                            ValidationGroup="ValidGroup" />
                                                    </InsertItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
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
                                                            runat="server">
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

                                                <asp:TemplateField HeaderText="Sostituito da">
                                                    <ItemTemplate>
                                                        <asp:Label ID="label_nome_completo" runat="server" Text='<%# Eval("nome_completo") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                    <InsertItemTemplate>
                                                        <asp:HiddenField ID="TextBoxSostitutoId" runat="server" Value='<%# Bind("id_sostituto") %>'></asp:HiddenField>
                                                        <asp:TextBox ID="TextBoxSostituto" runat="server" Text='<%# Bind("nome_completo") %>'></asp:TextBox>
                                                        <div id="DivSostitutoInsert">
                                                        </div>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostitutoInsert" runat="server"
                                                            EnableCaching="True" TargetControlID="TextBoxSostituto" ServicePath="~/ricerca_persone.asmx"
                                                            ServiceMethod="RicercaPersone" MinimumPrefixLength="1" CompletionInterval="0"
                                                            CompletionListElementID="DivSostitutoInsert" CompletionSetCount="15" UseContextKey="true" OnPreRender="AutoCompleteExtenderSostituto_PreRender" OnClientItemSelected="autoCompleteSostitutoSelected">
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
                                                        <asp:HiddenField ID="TextBoxSostitutoId" runat="server" Value='<%# Bind("id_sostituto") %>'></asp:HiddenField>
                                                        <asp:TextBox ID="TextBoxSostituto" runat="server" Text='<%# Bind("nome_completo") %>'></asp:TextBox>
                                                        <div id="DivSostitutoEdit">
                                                        </div>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostitutoEdit" runat="server" EnableCaching="True"
                                                            TargetControlID="TextBoxSostituto" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersone"
                                                            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivSostitutoEdit"
                                                            CompletionSetCount="15" UseContextKey="true" OnPreRender="AutoCompleteExtenderSostituto_PreRender" OnClientItemSelected="autoCompleteSostitutoSelected">
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

                                                <asp:TemplateField HeaderText="Note" SortExpression="note">
                                                    <EditItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TextBox1"
                                                            runat="server"
                                                            Text='<%# Bind("note") %>'>
                                                        </asp:TextBox>
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TextBox1"
                                                            runat="server"
                                                            Text='<%# Bind("note") %>'>
                                                        </asp:TextBox>
                                                    </InsertItemTemplate>

                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelNote"
                                                            runat="server"
                                                            Text='<%# Bind("note") %>'>
                                                        </asp:Label>
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
                                                            Text="Modifica" Visible="<%# (role <= 2) ? true : false %>" />
                                                        <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
                                                            Text="Elimina" Visible="<%# (role <= 2) ? true : false %>" />
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
				                                             ll.id_legislatura, 
				                                             ll.num_legislatura, 
				                                             mm.oggetto, 
				                                             pp.cognome + ' ' +  pp.nome AS nome_completo,
                                                             pp.id_persona as id_sostituto
				                                      FROM join_persona_missioni AS jj 
				                                      LEFT OUTER JOIN persona AS pp 
				                                        ON pp.id_persona = jj.sostituito_da 
				                                      INNER JOIN missioni AS mm 
				                                        ON jj.id_missione = mm.id_missione 
				                                      INNER JOIN legislature AS ll 
				                                        ON mm.id_legislatura = ll.id_legislatura
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

                                        <asp:SqlDataSource ID="SqlDataSource5"
                                            runat="server"
                                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                            SelectCommand="SELECT [id_legislatura], 
				                                             [num_legislatura] 
				                                      FROM [legislature]"></asp:SqlDataSource>
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

                            <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" BehaviorID="ModalPopup1" runat="server" PopupControlID="PanelDetails"
                                BackgroundCssClass="modalBackground" DropShadow="true" TargetControlID="ButtonDetailsFake" />
                            <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
                        </asp:Panel>
                    </div>
                </div>
                <%--Fix per lo stile dei calendarietti--%>
                <asp:TextBox ID="TextBoxCalendarFake" runat="server" Style="display: none;"></asp:TextBox>
                <cc1:CalendarExtender ID="CalendarExtenderFake" runat="server" TargetControlID="TextBoxCalendarFake" Format="dd/MM/yyyy"></cc1:CalendarExtender>
            </td>
        </tr>

        <tr>
            <td>&nbsp;
            </td>
        </tr>

        <tr>
            <td align="right">
                <b>
                    <a id="a_back"
                        runat="server"
                        href="../persona/persona_assessori.aspx">« Indietro
                    </a>
                </b>
            </td>
        </tr>

        <tr>
            <td>&nbsp;
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
