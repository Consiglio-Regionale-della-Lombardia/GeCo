<%@ Page Language="C#"
    AutoEventWireup="true"
    MasterPageFile="~/MasterPage.master"
    CodeFile="report_incarichi_extra_incarichi.aspx.cs"
    Inherits="report_incarichi_extra_incarichi"
    Title="STAMPE > Incarichi Extra Istituzionali (incarichi)" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
        <asp:ScriptManager ID="ScriptManager2"
            runat="server"
            EnableScriptGlobalization="True">
        </asp:ScriptManager>

        <asp:Label ID="lblTitle"
            runat="server"
            Text="Report Incarichi Extra Istituzionali (incarichi)"
            Font-Bold="true">
        </asp:Label>

        <br />
        <br />

        <asp:Panel ID="panelFiltri" runat="server">
            <div id="content_filtri_vis" class="pannello_ricerca">
                <asp:Label ID="lblFilterTitle"
                    runat="server"
                    Text="FILTRI:"
                    Font-Bold="true">
                </asp:Label>

                <table width="100%">
                    <tr>
                        <td align="left">
                            <asp:Label ID="lblLegislatura"
                                runat="server"
                                Text="Legislatura: ">
                            </asp:Label>

                            <asp:DropDownList ID="ddlLegislatura"
                                runat="server"
                                AppendDataBoundItems="true"
                                DataTextField="num_legislatura"
                                DataValueField="id_legislatura"
                                DataSourceID="SQLDataSource_ddlLegislatura">
			                    <asp:ListItem Text="(tutte)" Value="" />
                            </asp:DropDownList>

                            <asp:SqlDataSource ID="SQLDataSource_ddlLegislatura"
                                runat="server"
                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                SelectCommand="SELECT id_legislatura,
                                                             num_legislatura
                                                      FROM legislature
                                                      ORDER BY durata_legislatura_da DESC"></asp:SqlDataSource>
                        </td>

                        <td align="left">
                            <asp:Label ID="lblNominativo"
                                runat="server"
                                Text="Nominativo: ">
                            </asp:Label>

                            <asp:DropDownList ID="ddlNominativo"
                                runat="server"
                                AppendDataBoundItems="true"
                                DataTextField="nominativo"
                                DataValueField="id_persona"
                                DataSourceID="SQLDataSource_ddlNominativo">

                                <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
                            </asp:DropDownList>

                            <asp:RequiredFieldValidator ID="RFV_Nominativo"
                                runat="server"
                                ControlToValidate="ddlNominativo"
                                ErrorMessage="*"
                                Display="Dynamic"
                                ValidationGroup="FilterGroup">
                            </asp:RequiredFieldValidator>

                            <asp:SqlDataSource ID="SQLDataSource_ddlNominativo"
                                runat="server"
                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                SelectCommand="SELECT DISTINCT pp.id_persona,
                                                                  pp.cognome + ' ' + pp.nome AS nominativo
                                                  FROM persona AS pp
                                                  --INNER JOIN scheda AS sc
                                                     --ON pp.id_persona = sc.id_persona
                                                  WHERE pp.deleted = 0  
                                                    --AND sc.deleted = 0
                                                  ORDER BY nominativo"></asp:SqlDataSource>
                        </td>

                        <td align="left">
                            <asp:Label ID="lbl_data_inizio"
                                runat="server"
                                Text="Dal:">
                            </asp:Label>

                            <asp:TextBox ID="txt_data_inizio"
                                runat="server"
                                Width="70px">
                            </asp:TextBox>

                            <img alt="calendar"
                                src="../img/calendar_month.png"
                                id="img_data_inizio"
                                runat="server" />

                            <cc1:CalendarExtender ID="CalendarExtender_DataInizio"
                                runat="server"
                                TargetControlID="txt_data_inizio"
                                PopupButtonID="img_data_inizio"
                                Format="dd/MM/yyyy">
                            </cc1:CalendarExtender>

                            <asp:RequiredFieldValidator ID="RFV_DataInizio"
                                runat="server"
                                ControlToValidate="txt_data_inizio"
                                ErrorMessage="*"
                                Display="Dynamic"
                                ValidationGroup="FilterGroup">
                            </asp:RequiredFieldValidator>

                            <asp:RegularExpressionValidator ID="REV_DataInizio"
                                ControlToValidate="txt_data_inizio"
                                runat="server"
                                ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                Display="Dynamic"
                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                ValidationGroup="FilterGroup">
                            </asp:RegularExpressionValidator>
                        </td>

                        <td align="left">
                            <asp:Label ID="lbl_data_fine"
                                runat="server"
                                Text="Al:">
                            </asp:Label>

                            <asp:TextBox ID="txt_data_fine"
                                runat="server"
                                Width="70px">
                            </asp:TextBox>

                            <img alt="calendar"
                                src="../img/calendar_month.png"
                                id="img_data_fine"
                                runat="server" />

                            <cc1:CalendarExtender ID="CalendarExtender_DataFine"
                                runat="server"
                                TargetControlID="txt_data_fine"
                                PopupButtonID="img_data_fine"
                                Format="dd/MM/yyyy">
                            </cc1:CalendarExtender>

                            <asp:RequiredFieldValidator ID="RFV_DataFine"
                                runat="server"
                                ControlToValidate="txt_data_fine"
                                ErrorMessage="*"
                                Display="Dynamic"
                                ValidationGroup="FilterGroup">
                            </asp:RequiredFieldValidator>

                            <asp:RegularExpressionValidator ID="REV_DataFine"
                                ControlToValidate="txt_data_fine"
                                runat="server"
                                ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                                Display="Dynamic"
                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                ValidationGroup="FilterGroup">
                            </asp:RegularExpressionValidator>
                        </td>

                        <td align="right">
                            <asp:Button ID="btnApplicaFiltro"
                                runat="server"
                                Text="Applica Filtri"
                                Width="102"
                                CausesValidation="true"
                                ValidationGroup="FilterGroup"
                                OnClick="ApplyFilter" />
                        </td>
                    </tr>
                </table>
            </div>
        </asp:Panel>

        <div align="center">
            <asp:GridView ID="GridView1"
                runat="server"
                AllowSorting="false"
                AllowPaging="false"
                PagerStyle-HorizontalAlign="Center"
                AutoGenerateColumns="false"
                CssClass="tab_gen"
                ShowHeader="false"
                OnRowDataBound="GridView1_OnRowDataBound">

                <EmptyDataTemplate>
                    <table width="100%" class="tab_gen">
                        <tr>
                            <th align="center">Nessun incarico trovato.
                            </th>
                        </tr>
                    </table>
                </EmptyDataTemplate>

                <Columns>
                    <asp:BoundField DataField="INCARICO"
                        HeaderText="INCARICO"
                        ShowHeader="false"
                        ItemStyle-HorizontalAlign="Left"
                        ItemStyle-Width="370px" />

                    <asp:BoundField DataField="RIFERIMENTI NORMATIVI"
                        HeaderText="RIFERIMENTI NORMATIVI"
                        ShowHeader="false"
                        ItemStyle-HorizontalAlign="Center"
                        ItemStyle-Width="100px" />

                    <asp:BoundField DataField="DATA CESSAZIONE"
                        HeaderText="DATA CESSAZIONE"
                        ShowHeader="false"
                        ItemStyle-HorizontalAlign="Center"
                        ItemStyle-Width="100px" />

                    <asp:BoundField DataField="NOTE ISTRUTTORIE"
                        HeaderText="NOTE ISTRUTTORIE"
                        ShowHeader="false"
                        ItemStyle-HorizontalAlign="Left"
                        ItemStyle-Width="370px" />
                </Columns>
            </asp:GridView>

            <asp:SqlDataSource ID="SqlDataSource1"
                runat="server"
                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>
        </div>

        <% if (printable)
            { %>
        <br />

        <div align="right">
            <asp:LinkButton ID="LinkButtonPdf"
                runat="server"
                OnClick="LinkButtonPdf_Click">
	        <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
	        Stampa
            </asp:LinkButton>
        </div>
        <% } %>
    </div>
</asp:Content>
