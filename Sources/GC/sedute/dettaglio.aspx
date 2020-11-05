<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" MasterPageFile="~/MasterPage.master"
    CodeFile="dettaglio.aspx.cs" Inherits="sedute_dettaglio" Title="Foglio Presenze" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Register Src="../allegati/allegatiList.ascx" TagName="AllegatiList" TagPrefix="all" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <table style="width: 98%;" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td style="padding: 20px;">
                <table border="0" style="width: 100%; background-color: #006600;" cellpadding="0"
                    cellspacing="1">
                    <tr>
                        <td style="background-color: White;">
                            <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
                            </asp:ScriptManager>

                            <asp:FormView ID="FormView_InfoSeduta" runat="server" DataKeyNames="id_seduta" DataSourceID="SqlDataSource_InfoSeduta"
                                Width="90%" Height="327px" OnPreRender="FormView_InfoSeduta_PreRender" OnItemDeleted="FormView_InfoSeduta_ItemDeleted"
                                OnItemInserting="FormView_InfoSeduta_ItemInserting" OnItemUpdating="FormView_InfoSeduta_ItemUpdating"
                                OnModeChanged="FormView_InfoSeduta_ModeChanged">
                                <%--ITEM--%>
                                <ItemTemplate>
                                    <div style="padding-left: 30px;">
                                        <table style="width: 100%;" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%; font-family: Verdana; font-size: 12px;">
                                                        <tr>
                                                            <td colspan="2">
                                                                <img alt="Consiglio Regionale della Lombardia" src="../img/BannerCRL.jpg" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width: 50px"></td>
                                                            <td>
                                                                <asp:Label ID="LabelLeg" runat="server" Font-Bold="false" Font-Names="Verdana" Font-Size="20px"
                                                                    Font-Italic="false" Text='<%# Bind("num_legislatura") %>'>
                                                                </asp:Label>
                                                                <asp:Label ID="lbl_leg_text" runat="server" Font-Bold="false" Font-Names="Verdana"
                                                                    Font-Size="20px" Font-Italic="false" Text=" Legislatura">
                                                                </asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <asp:Label ID="LabelOrgano" runat="server" Font-Bold="false" Font-Names="Verdana"
                                                                    Font-Size="16px" Text='<%# Bind("nome_organo") %>'>
                                                                </asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <br />
                                                                <br />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <table style="width: 100%;">
                                                                    <tr>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_tipo_item" runat="server" Text="Tipo: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="LabelTipoSeduta" runat="server" Text='<%# Bind("tipo_incontro") %>'>
                                                                            </asp:Label>

                                                                            <% 
                                                                               //if (tipo_sessione_visibile)
                                                                               { 
                                                                            %>
                                                                            <asp:Label ID="lbl_tipo_sessione" runat="server" Text="&#160;&#160;&#160;&#160;&#160;Sessione: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="labelTipoSessione" runat="server" Text='<%# Bind("tipo_sessione") %>'>
                                                                            </asp:Label>
                                                                            <% } %>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_numero_item" runat="server" Text="Numero: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="LabelNumSeduta" runat="server" Text='<%# Bind("numero_seduta") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_data_item" runat="server" Text="Data: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="LabelDataSeduta" runat="server" Text='<%# Eval("data_seduta", "{0:dd/MM/yyyy}") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                        <td></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_oraconv_item" runat="server" Text="Ora convocazione: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="LabelOraConvocazione" runat="server" Text='<%# Eval("ora_convocazione", "{0:HH.mm}") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_orainit_item" runat="server" Text="Ora inizio: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="LabelOraInizio" runat="server" Text='<%# Eval("ora_inizio", "{0:HH.mm}") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_orafine_item" runat="server" Text="Ora fine: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <asp:Label ID="LabelOraFine" runat="server" Text='<%# Eval("ora_fine", "{0:HH.mm}") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                        <td></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <asp:Label ID="lbl_oggetto_item" runat="server" Text="Oggetto: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <br />
                                                                            <asp:Label ID="LabelOggetto" runat="server" Text='<%# Bind("oggetto") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <asp:Label ID="lbl_note_item" runat="server" Text="Note: " Font-Bold="true">
                                                                            </asp:Label>
                                                                            <br />
                                                                            <asp:Label ID="LabelNote" runat="server" Text='<%# Bind("note") %>'>
                                                                            </asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4" style="text-align: center">
                                                                            <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
                                                                                CssClass="button" Text="Modifica" Visible="<%# ((user_role == 1  || (!seduta_locked & !seduta_locked1) || user_role > 4) && ((user_organo == 0) || (user_organo == seduta_organo_id) || (seduta_organo_com_ristr && (user_organo == seduta_organo_id_comm)))) ? true : false %>" />
                                                                            <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
                                                                                CssClass="button" OnClientClick="return confirm ('Procedere con l\'eliminazione?');"
                                                                                Text="Elimina" Visible="<%# (user_role == 1 || (!seduta_locked & !seduta_locked1)) ? true : false %>" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </ItemTemplate>
                                <%--EDIT--%>
                                <EditItemTemplate>
                                    <div style="padding-left: 30px;">
                                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
                                            <tr>
                                                <td>
                                                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%; font-family: Verdana; font-size: 12px;">
                                                        <tr>
                                                            <td colspan="2">
                                                                <img alt="Consiglio Regionale della Lombardia" src="../img/BannerCRL.jpg" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width: 50px"></td>
                                                            <td>
                                                                <span style="font-size: 16px; font-family: Verdana; font-style: normal;">
                                                                    <asp:DropDownList ID="DropDownListLeg" runat="server" AppendDataBoundItems="True"
                                                                        AutoPostBack="True" DataSourceID="SqlDataSourceLeg" DataTextField="num_legislatura"
                                                                        DataValueField="id_legislatura" OnDataBound="DropDownListLeg_DataBound" SelectedValue='<%# Eval("id_legislatura") %>'
                                                                        Width="200px" Visible="<%# (user_role <= 2) ? true : false %>">
                                                                        <asp:ListItem Text="(seleziona)" Value="" />
                                                                    </asp:DropDownList>
                                                                    <asp:Label ID="LabelLeg2" runat="server" Font-Bold="False" Font-Names="Verdana" Style="font-size: 20px"
                                                                        Font-Italic="False" Text='<%# Eval("num_legislatura") %>' Visible="<%# (user_role > 2) ? true : false %>">
                                                                    </asp:Label>
                                                                    <b>Legislatura</b> </span>
                                                                <asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                    SelectCommand="SELECT id_legislatura, 
                                                                                     num_legislatura 
                                                                              FROM legislature"></asp:SqlDataSource>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <asp:Label ID="LabelOrg2" runat="server" Font-Bold="False" Font-Names="Verdana" Font-Size="16px"
                                                                    Text='<%# Eval("nome_organo") %>' Visible="<%# (user_role > 2 && user_role != 5) ? true : false %>">
                                                                </asp:Label>
                                                                <asp:DropDownList ID="DropDownListOrgano" runat="server" AutoPostBack="true"
                                                                    DataSourceID="SqlDataSourceOrgano" OnSelectedIndexChanged="DropDownListOrgano_SelectedIndexChanged"
                                                                    DataTextField="nome_organo" DataValueField="id_organo" OnDataBound="DropDownListOrgano_DataBound"
                                                                    Width="480px" Visible="<%# (user_role <= 2) ? true : false %>">
                                                                </asp:DropDownList>
                                                                <asp:DropDownList ID="DropDownListOrganoComm" runat="server"
                                                                    DataSourceID="SqlDataSourceOrganoComm"
                                                                    DataTextField="nome_organo" DataValueField="id_organo" OnDataBound="DropDownListOrgano_DataBound"
                                                                    Width="480px" Visible="<%# (user_role == 5) ? true : false %>">
                                                                </asp:DropDownList>
                                                                <asp:SqlDataSource ID="SqlDataSourceOrgano" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                    SelectCommand="SELECT [id_organo], [nome_organo] 
                                                                            FROM [organi] 
                                                                            WHERE ([id_legislatura] = @id_legislatura) 
                                                                            AND deleted = 0              
                                                                            ORDER BY [nome_organo]">
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="FormView_Infoseduta$DropDownListLeg" DefaultValue="0"
                                                                            Name="id_legislatura" PropertyName="SelectedValue" Type="Int32" />
                                                                    </SelectParameters>
                                                                </asp:SqlDataSource>
                                                                <asp:SqlDataSource ID="SqlDataSourceOrganoComm" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                    SelectCommand="select id_organo, nome_organo from (
                                                                                                    SELECT oo.id_organo AS id_organo, 
                                                                                                         oo.nome_organo AS nome_organo,
                                                                                                         CONVERT(varchar, ll.durata_legislatura_da, 112) AS init_leg,
                                                                                                         case when oo.id_organo = @id_commissione then 1 else 2 end as Sorting
                                                                                                    FROM organi AS oo 
                                                                                                    INNER JOIN legislature AS ll 
                                                                                                    ON oo.id_legislatura = ll.id_legislatura
                                                                                                    WHERE oo.deleted = 0 
                                                                                                    AND ll.id_legislatura = @id_legislatura
                                                                                                    AND (oo.id_organo = @id_commissione OR (oo.comitato_ristretto = 1 AND oo.id_commissione = @id_commissione))
                                                                                                  ) O
                                                                                                  ORDER BY Sorting ASC, nome_organo ASC">
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="FormView_Infoseduta$DropDownListLeg" DefaultValue="0"
                                                                            Name="id_legislatura" PropertyName="SelectedValue" Type="Int32" />
                                                                        <asp:SessionParameter Name="id_commissione"
                                                                            Type="Int32"
                                                                            SessionField="logged_organo" />
                                                                    </SelectParameters>
                                                                </asp:SqlDataSource>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidatorOrgano" runat="server" ControlToValidate="DropDownListOrgano"
                                                                    Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                </asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <br />
                                                                <br />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <table style="width: 100%;">
                                                                    <tr valign="middle">
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_tipo_edit" runat="server" Font-Bold="true" Text="Tipo: " Width="35px">
                                                                            </asp:Label>
                                                                            <asp:DropDownList ID="DropDownListTipoSeduta" runat="server" DataSourceID="SqlDataSourceTipoSeduta"
                                                                                DataTextField="tipo_incontro" DataValueField="id_incontro" SelectedValue='<%# Bind("tipo_seduta") %>'
                                                                                Font-Names="Verdana" Font-Size="12px">
                                                                            </asp:DropDownList>
                                                                            <asp:SqlDataSource ID="SqlDataSourceTipoSeduta" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                                SelectCommand="SELECT * FROM tbl_incontri"></asp:SqlDataSource>
                                                                        </td>
                                                                        <td>
                                                                            <%--<asp:Panel runat="server" ID="boxTipoSessione" Visible="<%# tipo_sessione_visibile %>">--%>
                                                                            <asp:Panel runat="server" ID="Panel1" Visible=true>
                                                                                <asp:Label ID="lbl_tiposessione_edit" runat="server" Font-Bold="true" Text="Sessione: " Width="65px">
                                                                                </asp:Label>
                                                                                <asp:DropDownList ID="DropDownListTipoSessione" runat="server" DataSourceID="SqlDataSourceTipoSessione"
                                                                                    DataTextField="tipo_sessione" DataValueField="id_tipo_sessione" SelectedValue='<%# Bind("id_tipo_sessione") %>'
                                                                                    Font-Names="Verdana" Font-Size="12px">
                                                                                </asp:DropDownList>
                                                                                <%--<asp:RequiredFieldValidator ID="RequiredFieldValidatorTipoSessione" runat="server"
                                                                                    ControlToValidate="DropDownListTipoSessione" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                                </asp:RequiredFieldValidator>--%>
                                                                                <asp:SqlDataSource ID="SqlDataSourceTipoSessione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                                    SelectCommand="SELECT null as id_tipo_sessione, '' as tipo_sessione union SELECT id_tipo_sessione, tipo_sessione FROM tbl_tipi_sessione"></asp:SqlDataSource>
                                                                            </asp:Panel>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_numero_edit" runat="server" Font-Bold="true" Width="70px" Text="Numero: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxNumeroSeduta" runat="server" MaxLength="20" Text='<%# Bind("numero_seduta") %>'
                                                                                Font-Names="Verdana" Font-Size="12px" Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxNumeroSeduta" runat="server"
                                                                                ControlToValidate="TextBoxNumeroSeduta" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxNumeroSeduta"
                                                                                runat="server" ControlToValidate="TextBoxNumeroSeduta" Display="Dynamic" ErrorMessage="Solo cifre ammesse."
                                                                                ValidationExpression="^[0-9]+$" ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_data_edit" runat="server" Font-Bold="true" Width="60px" Text="Data: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxEditDataSeduta" runat="server" Text='<%# Eval("data_seduta", "{0:dd/MM/yyyy}") %>'
                                                                                Font-Names="Verdana" Font-Size="12px" Width="100px">
                                                                            </asp:TextBox>
                                                                            <img alt="ImageDataSeduta" src="../img/calendar_month.png" id="ImageDataSeduta" runat="server" />
                                                                            <cc1:CalendarExtender ID="CalendarExtenderDataSeduta" runat="server" TargetControlID="TextBoxEditDataSeduta"
                                                                                PopupButtonID="ImageDataSeduta" Format="dd/MM/yyyy">
                                                                            </cc1:CalendarExtender>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_DataSeduta" runat="server"
                                                                                ControlToValidate="TextBoxEditDataSeduta" Display="Dynamic" ErrorMessage="*"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionDataSeduta" runat="server" ControlToValidate="TextBoxEditDataSeduta"
                                                                                Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA." ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr valign="middle">
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_oraconv_edit" runat="server" Font-Bold="true" Text="Ora convocazione: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxEditOraConvocazione" runat="server" Text='<%# Eval("ora_convocazione", "{0:HH.mm}") %>'
                                                                                Font-Names="Verdana" Font-Size="12px" Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_OraConvocazione" runat="server"
                                                                                ControlToValidate="TextBoxEditOraConvocazione" Display="Dynamic" ErrorMessage="*"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionOraConvocazione" runat="server"
                                                                                ControlToValidate="TextBoxEditOraConvocazione" Display="Dynamic" ErrorMessage="Ammessi solo valori HH.MM."
                                                                                ValidationExpression="^(0[0-9]|1[0-9]|2[0-3])\.([0-5][0-9])$" ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_orainit_edit" runat="server" Font-Bold="true" Width="70px" Text="Ora inizio: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxEditOraInizio" runat="server" Text='<%# Eval("ora_inizio", "{0:HH.mm}") %>'
                                                                                Font-Names="Verdana" Font-Size="12px" Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxEditOraInizio" runat="server"
                                                                                ControlToValidate="TextBoxEditOraInizio" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionOraInizio" runat="server" ControlToValidate="TextBoxEditOraInizio"
                                                                                Display="Dynamic" ErrorMessage="Ammessi solo valori HH.MM." ValidationExpression="^(0[0-9]|1[0-9]|2[0-3])\.([0-5][0-9])$"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_orafine_edit" runat="server" Font-Bold="true" Width="60px" Text="Ora fine: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxEditOraFine" runat="server" Text='<%# Eval("ora_fine", "{0:HH.mm}") %>'
                                                                                Font-Names="Verdana" Font-Size="12px" Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxEditOraFine" runat="server"
                                                                                ControlToValidate="TextBoxEditOraFine" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionOraFine" runat="server" ControlToValidate="TextBoxEditOraFine"
                                                                                Display="Dynamic" ErrorMessage="Ammessi solo valori HH.MM." ValidationExpression="^(0[0-9]|1[0-9]|2[0-3])\.([0-5][0-9])$"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr valign="middle">
                                                                        <td colspan="4">
                                                                            <asp:Label ID="lbl_oggetto_edit" runat="server" Font-Bold="true" Text="Oggetto: ">
                                                                            </asp:Label>
                                                                            <br />
                                                                            <asp:TextBox ID="TextBoxOggetto" runat="server" Columns="5" MaxLength="50" Rows="5"
                                                                                Text='<%# Bind("oggetto") %>' TextMode="MultiLine" Width="99%">
                                                                            </asp:TextBox>
                                                                            </b>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr valign="middle">
                                                                        <td colspan="4">
                                                                            <asp:Label ID="lbl_note_edit" runat="server" Font-Bold="true" Text="Note: ">
                                                                            </asp:Label>
                                                                            <br />
                                                                            <asp:TextBox ID="TextBoxNote" runat="server" Columns="22" Rows="5" Text='<%# Bind("note") %>'
                                                                                TextMode="MultiLine" Width="99%">
                                                                            </asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4" style="text-align: center">
                                                                            <asp:Button ID="Button1" runat="server" CommandName="Update" CssClass="button" Text="Aggiorna"
                                                                                ValidationGroup="ValidGroup" />
                                                                            <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
                                                                                CssClass="button" Text="Annulla" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </EditItemTemplate>
                                <%--INSERT--%>
                                <InsertItemTemplate>
                                    <div style="padding-left: 30px;">
                                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
                                            <tr>
                                                <td>
                                                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%; font-family: Verdana; font-size: 12px;">
                                                        <tr>
                                                            <td colspan="2">
                                                                <img alt="Consiglio Regionale della Lombardia" src="../img/BannerCRL.jpg" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width: 50px"></td>
                                                            <td>
                                                                <span style="font-size: 16px; font-family: Verdana; font-style: normal;">
                                                                    <asp:DropDownList ID="DropDownListLeg" runat="server" AppendDataBoundItems="True"
                                                                        AutoPostBack="True" DataSourceID="SqlDataSourceLeg" DataTextField="num_legislatura"
                                                                        DataValueField="id_legislatura" Width="200px" SelectedValue='<%# Eval("id_legislatura") %>'
                                                                        OnDataBound="DropDownListLeg_DataBound">
                                                                        <asp:ListItem Text="(seleziona)" Value="" />
                                                                    </asp:DropDownList>
                                                                    <asp:Label ID="LabelLeg2" runat="server" Font-Bold="False" Font-Names="Verdana" Style="font-size: 20px"
                                                                        Font-Italic="False" Visible="false">
                                                                    </asp:Label>
                                                                    <b>Legislatura</b> </span>
                                                                <asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                    SelectCommand="SELECT id_legislatura, 
                                                                                     num_legislatura 
                                                                              FROM legislature
                                                                              ORDER BY durata_legislatura_da DESC"></asp:SqlDataSource>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <asp:DropDownList ID="DropDownListOrgano" runat="server" DataSourceID="SqlDataSourceOrgano"
                                                                    DataTextField="nome_organo" DataValueField="id_organo" OnDataBound="DropDownListOrgano_DataBound"
                                                                    OnSelectedIndexChanged="DropDownListOrgano_SelectedIndexChanged" AutoPostBack="true"
                                                                    Width="480px">
                                                                </asp:DropDownList>
                                                                <asp:Label ID="LabelOrg2" runat="server" Font-Bold="False" Font-Names="Verdana" Font-Size="16px"
                                                                    Visible="false">
                                                                </asp:Label>
                                                                <asp:SqlDataSource ID="SqlDataSourceOrgano" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                    SelectCommand="SELECT [id_organo], [nome_organo] 
                                                                        FROM [organi] 
                                                                        WHERE ([id_legislatura] = @id_legislatura) 
                                                                        AND deleted = 0              
                                                                        ORDER BY [nome_organo]">
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="FormView_Infoseduta$DropDownListLeg" DefaultValue="0"
                                                                            Name="id_legislatura" PropertyName="SelectedValue" Type="Int32" />
                                                                    </SelectParameters>
                                                                </asp:SqlDataSource>
                                                                <asp:SqlDataSource ID="SqlDataSourceOrganoComm" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                    SelectCommand="select id_organo, nome_organo from (
                                                                                    SELECT oo.id_organo AS id_organo, 
                                                                                         oo.nome_organo AS nome_organo,
                                                                                         CONVERT(varchar, ll.durata_legislatura_da, 112) AS init_leg,
                                                                                         case when oo.id_organo = @id_commissione then 1 else 2 end as Sorting
                                                                                    FROM organi AS oo 
                                                                                    INNER JOIN legislature AS ll 
                                                                                    ON oo.id_legislatura = ll.id_legislatura
                                                                                    WHERE oo.deleted = 0 
                                                                                    AND ll.id_legislatura = @id_legislatura
                                                                                    AND (oo.id_organo = @id_commissione OR (oo.comitato_ristretto = 1 AND oo.id_commissione = @id_commissione))
                                                                                  ) O
                                                                                  ORDER BY Sorting ASC, nome_organo ASC">
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="FormView_Infoseduta$DropDownListLeg" DefaultValue="0"
                                                                            Name="id_legislatura" PropertyName="SelectedValue" Type="Int32" />
                                                                        <asp:SessionParameter Name="id_commissione"
                                                                            Type="Int32"
                                                                            SessionField="logged_organo" />
                                                                    </SelectParameters>
                                                                </asp:SqlDataSource>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidatorOrgano" runat="server" ControlToValidate="DropDownListOrgano"
                                                                    Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                </asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <br />
                                                                <br />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <table style="width: 100%;">
                                                                    <tr valign="middle">
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_tipo_insert" runat="server" Font-Bold="true" Width="65px" Text="Tipo: ">
                                                                            </asp:Label>
                                                                            <asp:DropDownList ID="DropDownListTipoSeduta" runat="server" DataSourceID="SqlDataSourceTipoSeduta"
                                                                                DataTextField="tipo_incontro" DataValueField="id_incontro" Font-Names="Verdana"
                                                                                Font-Size="12px" SelectedValue='<%# Bind("tipo_seduta") %>'>
                                                                            </asp:DropDownList>
                                                                            <asp:SqlDataSource ID="SqlDataSourceTipoSeduta" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                                SelectCommand="SELECT * 
                                                                                      FROM tbl_incontri"></asp:SqlDataSource>
                                                                        </td>
                                                                        <td>
                                                                            <%--<asp:Panel runat="server" ID="boxTipoSessione" Visible="<%# tipo_sessione_visibile %>">--%>
                                                                            <asp:Panel runat="server" ID="boxTipoSessione" Visible=true>
                                                                                <asp:Label ID="lbl_tiposessione_insert" runat="server" Font-Bold="true" Text="Sessione: " Width="65px">
                                                                                </asp:Label>
                                                                                <asp:DropDownList ID="DropDownListTipoSessione" runat="server" DataSourceID="SqlDataSourceTipoSessione"
                                                                                    DataTextField="tipo_sessione" DataValueField="id_tipo_sessione" SelectedValue='<%# Bind("id_tipo_sessione") %>'
                                                                                    Font-Names="Verdana" Font-Size="12px">
                                                                                </asp:DropDownList>
                                                                                <%--<asp:RequiredFieldValidator ID="RequiredFieldValidatorTipoSessione" runat="server"
                                                                                    ControlToValidate="DropDownListTipoSessione" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                                </asp:RequiredFieldValidator>--%>
                                                                                <asp:SqlDataSource ID="SqlDataSourceTipoSessione" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                                    SelectCommand="SELECT null as id_tipo_sessione, '' as tipo_sessione union SELECT id_tipo_sessione, tipo_sessione FROM tbl_tipi_sessione"></asp:SqlDataSource>
                                                                            </asp:Panel>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_numero_insert" runat="server" Font-Bold="true" Width="70px" Text="Numero: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxNumeroSeduta" runat="server" Font-Names="Verdana" Font-Size="12px"
                                                                                MaxLength="20" Text='<%# Bind("numero_seduta") %>' Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxNumeroSeduta" runat="server"
                                                                                ControlToValidate="TextBoxNumeroSeduta" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxNumeroSeduta"
                                                                                runat="server" ControlToValidate="TextBoxNumeroSeduta" Display="Dynamic" ErrorMessage="Solo cifre ammesse."
                                                                                ValidationExpression="^[0-9]+$" ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_data_seduta_insert" runat="server" Font-Bold="true" Width="60px"
                                                                                Text="Data: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxInsertDataSeduta" runat="server" Font-Names="Verdana" Font-Size="12px"
                                                                                Width="100px">
                                                                            </asp:TextBox>
                                                                            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataSeduta" runat="server" />
                                                                            <cc1:CalendarExtender ID="CalendarExtenderDataSeduta" runat="server" TargetControlID="TextBoxInsertDataSeduta"
                                                                                PopupButtonID="ImageDataSeduta" Format="dd/MM/yyyy">
                                                                            </cc1:CalendarExtender>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxInsertDataSeduta" runat="server"
                                                                                ControlToValidate="TextBoxInsertDataSeduta" Display="Dynamic" ErrorMessage="*"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionDataSeduta" runat="server" ControlToValidate="TextBoxInsertDataSeduta"
                                                                                Display="Dynamic" ErrorMessage="Ammessi solo valori GG/MM/AAAA." ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr valign="middle">
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_convocazione_insert" runat="server" Font-Bold="true" Text="Ora convocazione: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxInsertOraConvocazione" runat="server" Font-Names="Verdana"
                                                                                Font-Size="12px" Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxInsertOraConvocazione"
                                                                                runat="server" ControlToValidate="TextBoxInsertOraConvocazione" Display="Dynamic"
                                                                                ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionOraConvocazione" runat="server"
                                                                                ControlToValidate="TextBoxInsertOraConvocazione" Display="Dynamic" ErrorMessage="Ammessi solo valori HH.MM."
                                                                                ValidationExpression="^(0[0-9]|1[0-9]|2[0-3])\.([0-5][0-9])$$" ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_inizio_insert" runat="server" Font-Bold="true" Width="70px" Text="Ora inizio: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxInsertOraInizio" runat="server" Font-Names="Verdana" Font-Size="12px"
                                                                                Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxInsertOraInizio" runat="server"
                                                                                ControlToValidate="TextBoxInsertOraInizio" Display="Dynamic" ErrorMessage="*"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionOraInizio" runat="server" ControlToValidate="TextBoxInsertOraInizio"
                                                                                Display="Dynamic" ErrorMessage="Ammessi solo valori HH.MM." ValidationExpression="^(0[0-9]|1[0-9]|2[0-3])\.([0-5][0-9])$"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td align="left">
                                                                            <asp:Label ID="lbl_fine_insert" runat="server" Font-Bold="true" Width="60px" Text="Ora fine: ">
                                                                            </asp:Label>
                                                                            <asp:TextBox ID="TextBoxInsertOraFine" runat="server" Font-Names="Verdana" Font-Size="12px"
                                                                                Width="50px">
                                                                            </asp:TextBox>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator_TextBoxInsertOraFine" runat="server"
                                                                                ControlToValidate="TextBoxInsertOraFine" Display="Dynamic" ErrorMessage="*" ValidationGroup="ValidGroup">
                                                                            </asp:RequiredFieldValidator>
                                                                            <br />
                                                                            <asp:RegularExpressionValidator ID="RegularExpressionOraFine" runat="server" ControlToValidate="TextBoxInsertOraFine"
                                                                                Display="Dynamic" ErrorMessage="Ammessi solo valori HH.MM." ValidationExpression="^(0[0-9]|1[0-9]|2[0-3])\.([0-5][0-9])$"
                                                                                ValidationGroup="ValidGroup">
                                                                            </asp:RegularExpressionValidator>
                                                                        </td>
                                                                        <td></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr valign="top">
                                                                        <td colspan="4" valign="top">
                                                                            <asp:Label ID="lbl_oggetto_insert" runat="server" Font-Bold="true" Text="Oggetto: ">
                                                                            </asp:Label>
                                                                            <br />
                                                                            <asp:TextBox ID="TextBoxOggetto" runat="server" Columns="5" MaxLength="50" Rows="5"
                                                                                Text='<%# Bind("oggetto") %>' TextMode="MultiLine" Width="99%">
                                                                            </asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr valign="top">
                                                                        <td colspan="4">
                                                                            <asp:Label ID="lbl_note_insert" runat="server" Font-Bold="true" Text="Note: ">
                                                                            </asp:Label>
                                                                            <br />
                                                                            <asp:TextBox ID="TextBoxNote" runat="server" Columns="22" Rows="5" Text='<%# Bind("note") %>'
                                                                                TextMode="MultiLine" Width="99%">
                                                                            </asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4" style="text-align: center">
                                                                            <asp:Button ID="Button1" runat="server" CommandName="Insert" CssClass="button" Text="Inserisci"
                                                                                ValidationGroup="ValidGroup" />
                                                                            <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
                                                                                CssClass="button" OnClick="ButtonAnnulla_Click" Text="Annulla" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="4">
                                                                            <br />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </InsertItemTemplate>
                            </asp:FormView>
                            <asp:SqlDataSource ID="SqlDataSource_InfoSeduta" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                DeleteCommand="UPDATE sedute 
		                                          SET deleted = 1 
		                                          WHERE id_seduta = @id_seduta"
                                InsertCommand="INSERT INTO [sedute] ([id_legislatura], 
		                                                                [id_organo], 		                                                                
		                                                                [numero_seduta], 
		                                                                [tipo_seduta], 
		                                                                [oggetto], 
		                                                                [data_seduta], 
		                                                                [ora_convocazione], 
		                                                                [ora_inizio], 
		                                                                [ora_fine], 
		                                                                [note],
                                                                        [id_tipo_sessione]) 
		                                          VALUES (@id_legislatura, 
		                                                  @id_organo, 
		                                                  @numero_seduta, 
		                                                  @tipo_seduta, 
		                                                  @oggetto, 
		                                                  @data_seduta, 
		                                                  @ora_convocazione, 
		                                                  @ora_inizio, 
		                                                  @ora_fine, 
		                                                  @note,
                                                          @id_tipo_sessione); 
		                                          SELECT @id_seduta = SCOPE_IDENTITY();"
                                SelectCommand="SELECT * 
		                                          FROM sedute AS ss 
		                                          INNER JOIN legislature as ll 
		                                            ON ss.id_legislatura = ll.id_legislatura 
		                                          INNER JOIN tbl_incontri AS ii 
		                                            ON ss.tipo_seduta = ii.id_incontro 
		                                          LEFT OUTER JOIN tbl_tipi_sessione AS zz 
		                                            ON ss.id_tipo_sessione = zz.id_tipo_sessione
		                                          INNER JOIN organi AS oo 
		                                            ON ss.id_organo = oo.id_organo
			                                      WHERE ss.deleted = 0
			                                        AND oo.deleted = 0
			                                        AND ss.id_seduta = @id_seduta"
                                UpdateCommand="UPDATE [sedute] 
			                                      SET [id_legislatura] = @id_legislatura, 
			                                          [id_organo] = @id_organo, 
			                                          [numero_seduta] = @numero_seduta, 
			                                          [tipo_seduta] = @tipo_seduta, 
			                                          [oggetto] = @oggetto, 
			                                          [data_seduta] = @data_seduta, 
			                                          [ora_convocazione] = @ora_convocazione, 
			                                          [ora_inizio] = @ora_inizio, 
			                                          [ora_fine] = @ora_fine, 
			                                          [note] = @note,
                                                      [id_tipo_sessione] = @id_tipo_sessione
			                                      WHERE [id_seduta] = @id_seduta"
                                OnInserted="SqlDataSource_InfoSeduta_Inserted">
                                <SelectParameters>
                                    <asp:SessionParameter Name="id_seduta" SessionField="id_seduta" Type="Int32" />
                                </SelectParameters>
                                <DeleteParameters>
                                    <asp:Parameter Name="id_seduta" Type="Int32" />
                                </DeleteParameters>
                                <UpdateParameters>
                                    <asp:Parameter Name="id_legislatura" Type="Int32" />
                                    <asp:Parameter Name="id_organo" Type="Int32" />
                                    <asp:Parameter Name="numero_seduta" Type="String" />
                                    <asp:Parameter Name="tipo_seduta" Type="Int32" />
                                    <asp:Parameter Name="oggetto" Type="String" />
                                    <asp:Parameter Name="data_seduta" Type="DateTime" />
                                    <asp:Parameter Name="ora_convocazione" Type="DateTime" />
                                    <asp:Parameter Name="ora_inizio" Type="DateTime" />
                                    <asp:Parameter Name="ora_fine" Type="DateTime" />
                                    <asp:Parameter Name="note" Type="String" />
                                    <asp:Parameter Name="id_seduta" Type="Int32" />
                                    <asp:Parameter Name="id_tipo_sessione" Type="Int32" />
                                </UpdateParameters>
                                <InsertParameters>
                                    <asp:Parameter Name="id_legislatura" Type="Int32" />
                                    <asp:Parameter Name="id_organo" Type="Int32" />
                                    <asp:Parameter Name="numero_seduta" Type="String" />
                                    <asp:Parameter Name="tipo_seduta" Type="Int32" />
                                    <asp:Parameter Name="oggetto" Type="String" />
                                    <asp:Parameter Name="data_seduta" Type="DateTime" />
                                    <asp:Parameter Name="ora_convocazione" Type="DateTime" />
                                    <asp:Parameter Name="ora_inizio" Type="DateTime" />
                                    <asp:Parameter Name="ora_fine" Type="DateTime" />
                                    <asp:Parameter Name="note" Type="String" />
                                    <asp:Parameter Name="id_tipo_sessione" Type="Int32" />
                                    <asp:Parameter Direction="Output" Name="id_seduta" Type="Int32" />
                                </InsertParameters>
                            </asp:SqlDataSource>
                        </td>
                    </tr>
                    <% if (view_details)
                       { %>
                    <tr>
                        <td style="background-color: White;">
                            <br />
                            <div id="" align="left">
                                <% if ((seduta_nodiaria) || (seduta_tipo))
                                   { %>
                                <asp:Panel ID="panel_full" runat="server">
                                    <asp:Panel ID="panel_top" runat="server">
                                        <asp:Label ID="lbl_title_full" runat="server" Font-Bold="true" Text="CONSIGLIERI">
                                        </asp:Label>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        Ordina per&nbsp;           
                                        <asp:DropDownList ID="DropDownSort" runat="server" Width="140px" AutoPostBack="true"
                                            OnSelectedIndexChanged="DropDownSort_SelectedIndexChanged" Style="margin-bottom: 2px;">
                                            <asp:ListItem Text="Carica" Value=" ORDER BY carica_ordine, carica_nome, persona_nome "></asp:ListItem>
                                            <asp:ListItem Text="Cognome" Value=" ORDER BY persona_nome "></asp:ListItem>
                                        </asp:DropDownList>
                                    </asp:Panel>
                                    <asp:GridView ID="GridView_Full" runat="server" CssClass="tab_gen" AutoGenerateColumns="False"
                                        DataSourceID="SqlDataSource_Full" DataKeyNames="persona_id">
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen">
                                                <tr>
                                                    <th align="center">Nessun elemento.
                                                    </th>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                        <AlternatingRowStyle BackColor="#b2cca7" />
                                        <Columns>
                                            <asp:BoundField DataField="carica_nome" HeaderText="Carica" SortExpression="carica_nome"
                                                ItemStyle-Width="150px">
                                                <ItemStyle Width="150px" />
                                            </asp:BoundField>
                                            <asp:TemplateField HeaderText="Nome" SortExpression="persona_nome">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkbtn_nome" runat="server" Text='<%# Eval("persona_nome") %>'
                                                        Font-Bold="true" OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("persona_id")) %>'>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle Font-Bold="True" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Entrata">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_presente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Oltre 15 min">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Ritardo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo_2" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Congedo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_congedo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Assente">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_assente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Missione">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_missione" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza Effettiva">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_eff" runat="server" Enabled="<%# seduta_enabled%>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Uscita">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_usc" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Sostituito da">
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="lbl_sostituto_id" runat="server" />
                                                    <asp:Label ID="lbl_sostituto" runat="server">
                                                    </asp:Label>
                                                    <asp:ImageButton ID="imgbtn_sostituto_full" runat="server" ImageUrl="~/img/page_white_edit.png"
                                                        Enabled="<%# seduta_enabled ? true : false %>" OnClick="imgbtn_sostituto_full_click" />
                                                </ItemTemplate>
                                                <ItemStyle Width="200px" HorizontalAlign="right" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource ID="SqlDataSource_Full" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>
                                </asp:Panel>
                                <% }
                                   else
                                   { %>
                                <asp:Panel ID="panel_diaria" runat="server">
                                    <asp:Label ID="lbl_title_diaria" runat="server" Font-Bold="true" Text="CONSIGLIERI CHE HANNO OPTATO PER LA DIARIA">
                                    </asp:Label>
                                    <asp:GridView ID="GridView_Diaria" runat="server" CssClass="tab_gen" AutoGenerateColumns="False"
                                        DataSourceID="SqlDataSource_Diaria" DataKeyNames="persona_id">
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen">
                                                <tr>
                                                    <th align="center">Nessun elemento.
                                                    </th>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                        <AlternatingRowStyle BackColor="#b2cca7" />
                                        <Columns>
                                            <asp:BoundField DataField="carica_nome" HeaderText="Carica" SortExpression="carica_nome"
                                                ItemStyle-Width="150px">
                                                <ItemStyle Width="150px" />
                                            </asp:BoundField>
                                            <asp:TemplateField HeaderText="Nome" SortExpression="persona_nome">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkbtn_nome" runat="server" Text='<%# Eval("persona_nome") %>'
                                                        Font-Bold="true" OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("persona_id")) %>'>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle Font-Bold="True" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Entrata">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_presente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Oltre 15 min">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Ritardo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo_2" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Congedo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_congedo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Assente">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_assente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Missione">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_missione" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza Effettiva">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_eff" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Uscita">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_usc" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Sostituito da">
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="lbl_sostituto_id" runat="server" />
                                                    <asp:Label ID="lbl_sostituto" runat="server">
                                                    </asp:Label>
                                                    <asp:ImageButton ID="imgbtn_sostituto_diaria" runat="server" ImageUrl="~/img/page_white_edit.png"
                                                        Enabled="<%# seduta_enabled %>" OnClick="imgbtn_sostituto_diaria_click" />
                                                </ItemTemplate>
                                                <ItemStyle Width="200px" HorizontalAlign="right" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource ID="SqlDataSource_Diaria" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>
                                    <br />
                                    <br />
                                    <asp:Label ID="lbl_title_nodiaria" runat="server" Font-Bold="true" Text="CONSIGLIERI CHE NON HANNO OPTATO PER LA DIARIA">
                                    </asp:Label>
                                    <br />
                                    <asp:Label ID="lbl_title_nodiaria_sub" runat="server" Text="Consiglieri non soggetti a rilevazione ai fini delle ritenute per il trasporto (art.4, comma 3bis, l.r.17/96)">
                                    </asp:Label>
                                    <asp:GridView ID="GridView_NoDiaria" runat="server" CssClass="tab_gen" AutoGenerateColumns="False"
                                        DataSourceID="SqlDataSource_NoDiaria" DataKeyNames="persona_id">
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen">
                                                <tr>
                                                    <th align="center">Nessun elemento.
                                                    </th>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                        <AlternatingRowStyle BackColor="#b2cca7" />
                                        <Columns>
                                            <asp:BoundField DataField="carica_nome" HeaderText="Carica" SortExpression="carica_nome"
                                                ItemStyle-Width="150px">
                                                <ItemStyle Width="150px" />
                                            </asp:BoundField>
                                            <asp:TemplateField HeaderText="Nome" SortExpression="persona_nome">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkbtn_nome" runat="server" Text='<%# Eval("persona_nome") %>'
                                                        Font-Bold="true" OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("persona_id")) %>'>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle Font-Bold="True" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Entrata">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_presente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Oltre 15 min">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Ritardo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo_2" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Congedo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_congedo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Assente">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_assente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Missione">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_missione" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza Effettiva">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_eff" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Uscita">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_usc" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Sostituito da">
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="lbl_sostituto_id" runat="server" />
                                                    <asp:Label ID="lbl_sostituto" runat="server">
                                                    </asp:Label>
                                                    <asp:ImageButton ID="imgbtn_sostituto_nodiaria" runat="server" ImageUrl="~/img/page_white_edit.png"
                                                        Enabled="<%# seduta_enabled %>" OnClick="imgbtn_sostituto_nodiaria_click" />
                                                </ItemTemplate>
                                                <ItemStyle Width="200px" HorizontalAlign="right" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource ID="SqlDataSource_NoDiaria" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>
                                    <br />
                                    <br />
                                    <asp:Label ID="lbl_Nessuna_Priorita" runat="server" Font-Bold="true" Text="Consiglieri che non hanno indicato la commissione come prioritaria." Visible="false">
                                    </asp:Label>
                                    <br />
                                    <asp:GridView ID="GridView_Nessuna_Priorita" runat="server" CssClass="tab_gen" AutoGenerateColumns="False"
                                        Visible="false"
                                        DataSourceID="SqlDataSource_Nessuna_Priorita" DataKeyNames="persona_id">
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen">
                                                <tr>
                                                    <th align="center">Nessun elemento.
                                                    </th>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                        <AlternatingRowStyle BackColor="#b2cca7" />
                                        <Columns>
                                            <asp:BoundField DataField="carica_nome" HeaderText="Carica" SortExpression="carica_nome"
                                                ItemStyle-Width="150px">
                                                <ItemStyle Width="150px" />
                                            </asp:BoundField>
                                            <asp:TemplateField HeaderText="Nome" SortExpression="persona_nome">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkbtn_nome" runat="server" Text='<%# Eval("persona_nome") %>'
                                                        Font-Bold="true" OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("persona_id")) %>'>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle Font-Bold="True" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Entrata">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_presente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Oltre 15 min">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Ritardo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo_2" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Congedo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_congedo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Assente">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_assente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Missione">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_missione" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza Effettiva">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_eff" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Uscita">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_usc" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Sostituito da">
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="lbl_sostituto_id" runat="server" />
                                                    <asp:Label ID="lbl_sostituto" runat="server">
                                                    </asp:Label>
                                                    <asp:ImageButton ID="imgbtn_sostituto_nopri" runat="server" ImageUrl="~/img/page_white_edit.png"
                                                        Enabled="<%# seduta_enabled %>" OnClick="imgbtn_sostituto_nopri_click" />
                                                </ItemTemplate>
                                                <ItemStyle Width="200px" HorizontalAlign="right" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource ID="SqlDataSource_Nessuna_Priorita" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>

                                </asp:Panel>
                                <% } %>

                                <br />

                                <% if ((idDup > Constants.Dup.Nessuno) && foglio_dinamico)
                                   { %>

                                <asp:Panel ID="panel_dynamic" runat="server">
                                    <asp:Panel ID="panel_dynamic_top" runat="server">
                                        <asp:Label ID="label_dynamic" runat="server" Font-Bold="true" Text="ALTRI CONVOCATI">
                                        </asp:Label>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        Ordina per&nbsp;           
                                        <asp:DropDownList ID="DropDownSort_dynamic" runat="server" Width="140px" AutoPostBack="true"
                                            OnSelectedIndexChanged="DropDownSort_dynamic_SelectedIndexChanged" Style="margin-bottom: 2px;">
                                            <asp:ListItem Text="Carica" Value=" ORDER BY carica_ordine, carica_nome, persona_nome "></asp:ListItem>
                                            <asp:ListItem Text="Cognome" Value=" ORDER BY persona_nome "></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp;&nbsp;&nbsp;&nbsp;

                                        <% if (seduta_enabled) { %>
                                        <asp:Label Text="Aggiungi persona" runat="server" />

                                        <asp:HiddenField ID="TextBoxPersona_dynamicId" runat="server" Value=''></asp:HiddenField>
                                        <asp:TextBox ID="TextBoxPersona_dynamic"
                                                    style="width:200px;"
                                                    runat="server"
                                                    Text=''>
                                        </asp:TextBox>

                                        <div id="DivPersona_dynamic" runat="server">
                                        </div>

                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderPersona_dynamic"
                                            runat="server"
                                            EnableCaching="True"
                                            TargetControlID="TextBoxPersona_dynamic"
                                            ServicePath="~/ricerca_persone.asmx"
                                            ServiceMethod="RicercaPersone_FoglioDinamico"
                                            UseContextKey="true"
                                            OnPreRender="AutoCompleteExtenderPersona_dynamic_PreRender"
                                            MinimumPrefixLength="1"
                                            CompletionInterval="0"
                                            CompletionListElementID="DivPersona_dynamic"
                                            CompletionSetCount="15"
                                            OnClientItemSelected="autoCompletePersonaDynamicSelected">

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
                                        &nbsp;&nbsp;&nbsp;&nbsp;
                                        <asp:Button ID="button_dynamic_add" runat="server" Text="Conferma"
                                            OnClick="button_dynamic_add_Click" CssClass="button" CausesValidation="false" />
                                        <% } %>
                                    </asp:Panel>
                                    <asp:GridView ID="GridView_dynamic" runat="server" CssClass="tab_gen" AutoGenerateColumns="False"
                                        DataSourceID="SqlDataSource_Dynamic" DataKeyNames="persona_id"
                                        OnRowDataBound="GridView_dynamic_RowDataBound" >
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen">
                                                <tr>
                                                    <th align="center">Nessun elemento.
                                                    </th>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>
                                        <AlternatingRowStyle BackColor="#b2cca7" />
                                        <Columns>
<%--                                            <asp:BoundField DataField="carica_nome" HeaderText="Carica" SortExpression="carica_nome"
                                                ItemStyle-Width="150px">
                                                <ItemStyle Width="150px" />
                                            </asp:BoundField>--%>
                                            <asp:TemplateField HeaderText="" SortExpression="">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID='lnkbtn_delete' runat="server" Text='Rimuovi'
                                                        Font-Bold="true" OnClick="lnkbtn_delete_Click">
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle Font-Bold="True" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Nome" SortExpression="persona_nome">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkbtn_nome" runat="server" Text='<%# Eval("persona_nome") %>'
                                                        Font-Bold="true" OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("persona_id")) %>'>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle Font-Bold="True" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Entrata">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_presente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Oltre 15 min">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Ritardo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_ritardo_2" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Congedo">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_congedo" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Assente">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_assente" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Missione">
                                                <ItemTemplate>
                                                    <asp:RadioButton ID="rbtn_missione" runat="server" GroupName="row" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza Effettiva">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_eff" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Presenza in Uscita">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkbox_pres_usc" runat="server" Enabled="<%# seduta_enabled %>" />
                                                </ItemTemplate>
                                                <ItemStyle Width="80px" HorizontalAlign="Center" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Sostituito da">
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="lbl_sostituto_id" runat="server" />
                                                    <asp:Label ID="lbl_sostituto" runat="server">
                                                    </asp:Label>
                                                    <asp:ImageButton ID="imgbtn_sostituto_full" runat="server" ImageUrl="~/img/page_white_edit.png"
                                                        Enabled="<%# seduta_enabled ? true : false %>" OnClick="imgbtn_sostituto_full_click" />
                                                </ItemTemplate>
                                                <ItemStyle Width="200px" HorizontalAlign="right" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource ID="SqlDataSource_Dynamic" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>
                                </asp:Panel>

                                <% } %>
                            </div>
                            <br />
                            <% if (seduta_enabled)
                               { %>
                            <%--                            <asp:Label ID="lblAvvisi" runat="server" CssClass="warning" Text="">
                            </asp:Label>  --%>

                            <div id="lblAvvisi" runat="server" class="warning">
                            </div>

                            <br />
                            <div align="center">
                                <asp:Button ID="ButtonSalva" runat="server" Text="Salva" CssClass="button" OnClientClick="return confirm('Salvare il foglio presenze?');"
                                    OnClick="ButtonSalva_Click" />
                            </div>
                            <br />
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </table>
                <br />
                <div align="right">
                    <asp:LinkButton ID="LinkButtonExcelDetails" runat="server" OnClick="LinkButtonExcel_Click">
	            <img src="../img/page_white_excel.png" alt="" align="top" /> 
                Esporta
                    </asp:LinkButton>
                    -
                    <asp:LinkButton ID="LinkButtonPdfDetails" runat="server" OnClick="LinkButtonPdf_Click">
	            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
                Esporta
                    </asp:LinkButton>
                </div>

                <div id="divAllegatiContainer" class="allegatiContainer">
                    <all:AllegatiList ID="listAllegati" runat="server" />
                </div>

                <asp:Panel ID="PanelDetails" runat="server" BackColor="White" BorderColor="DarkSeaGreen"
                    BorderWidth="2px" Width="500px" Height="250px" ScrollBars="Auto" Style="padding: 10px; display: none; max-height: 500px;">
                    <div align="center">
                        <br />
                        <h3>INSERIMENTO SOSTITUTO
                        </h3>
                        <br />
                        <asp:HiddenField ID="txt_sostitutoId" runat="server" Value='<%# Bind("id_persona") %>'></asp:HiddenField>
                        <asp:TextBox ID="txt_sostituto" runat="server" Text='<%# Bind("nome_completo") %>'>
                        </asp:TextBox>
                        <asp:Button ID="ButtonApplica" runat="server" Text="Applica" OnClick="ButtonApplica_Click" />
                        <asp:Button ID="btn_AnnullaSostituto" runat="server" Text="Annulla" OnClick="btn_AnnullaSostituto_Click" />
                        <div id="DivSostituto">
                        </div>
                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderSostituto" runat="server" EnableCaching="True"
                            TargetControlID="txt_sostituto" ServicePath="~/ricerca_persone.asmx" ServiceMethod="RicercaPersoneAll"
                            MinimumPrefixLength="1" CompletionInterval="0" CompletionListElementID="DivSostituto"
                            CompletionSetCount="15" OnClientItemSelected="autoCompleteSostitutoSelected">
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
                    </div>
                    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" runat="server" BehaviorID="ModalPopup1"
                        PopupControlID="PanelDetails" BackgroundCssClass="modalBackground" DropShadow="true"
                        TargetControlID="ButtonDetailsFake">
                    </cc1:ModalPopupExtender>
                    <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <br />
            </td>
        </tr>
        <tr>
            <td align="right">
                <a href="../sedute/gestisciSedute.aspx">
                    <asp:Label ID="lbl_anchor_back" runat="server" Font-Bold="true" Text="« Indietro">
                    </asp:Label>
                </a>
                <br />
            </td>
        </tr>
    </table>

      <script type="text/javascript">

        function autoCompletePersonaDynamicSelected(source, eventArgs) {
            var id = eventArgs.get_value();
            var text = eventArgs.get_text();

            //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

            $('input[id$=_TextBoxPersona_dynamicId').val(id);
          }

          function autoCompleteSostitutoSelected(source, eventArgs) {
              var id = eventArgs.get_value();
              var text = eventArgs.get_text();

              //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

              $('input[id$=_txt_sostitutoId').val(id);
          }

      </script>

</asp:Content>
