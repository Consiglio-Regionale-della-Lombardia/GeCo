<%@ Control Language="C#" AutoEventWireup="true" CodeFile="incarichi_scheda.ascx.cs" Inherits="incarichi_scheda" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<%@ Register Src="incarichi_scheda_edit.ascx" TagName="incarichi_scheda_edit" TagPrefix="inc" %>


<table width="100%">
    <tr>
        <td align="center" valign="top" width="100%">
            <asp:FormView ID="FormView_Scheda"
                runat="server"
                DataKeyNames="id_scheda"
                DataSourceID="SqlDataSource_Scheda"
                Width="99%"
                OnItemDeleted="FormView_Scheda_ItemDeleted"
                OnItemInserting="FormView_Scheda_ItemInserting"
                OnItemUpdating="FormView_Scheda_ItemUpdating"
                OnItemUpdated="FormView_Scheda_ItemUpdated">

                <EmptyDataTemplate>
                    <table width="100%">
                        <tr>
                            <td align="center">
                                <asp:Label ID="lbl_empty_form_message"
                                    runat="server"
                                    Font-Bold="true"
                                    Text="Nessuna scheda selezionata">
                                </asp:Label>
                            </td>
                        </tr>
                    </table>
                </EmptyDataTemplate>

                <%--ITEM--%>
                <ItemTemplate>
                    <div>
                        <table style="width: 100%;" border="0" cellpadding="0" cellspacing="0">
                            <%--organo + legislatura--%>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="lbl_item_organo"
                                                    runat="server"
                                                    Text="GIUNTA DELLE ELEZIONI"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_organo_val"
                                                    runat="server">
                                                </asp:Label>
                                            </td>

                                            <td align="right">
                                                <asp:Label ID="lbl_item_legislatura"
                                                    runat="server"
                                                    Text="LEGISLATURA:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_leg_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_legislatura_2"
                                                    runat="server"
                                                    Text='<%# Eval("legislatura") %>'>
                                                </asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--consigliere + gruppo--%>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="lbl_item_consigliere"
                                                    runat="server"
                                                    Text="CONSIGLIERE:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_cons_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_consigliere_2"
                                                    runat="server"
                                                    Text='<%# Eval("consigliere") %>'>
                                                </asp:Label>
                                            </td>

                                            <td align="right">
                                                <asp:Label ID="lbl_item_gruppo_consiliare"
                                                    runat="server"
                                                    Text="GRUPPO CONSILIARE:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_gruppo_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_gruppo_consiliare_2"
                                                    runat="server"
                                                    Text='<%# Eval("gruppo_consiliare") %>'>
                                                </asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--data_procl + dichiarazione del incarichi--%>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="lbl_item_data_proclamazione"
                                                    runat="server"
                                                    Text="DATA PROCLAMAZIONE:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_data_proc_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_data_proclamazione_2"
                                                    runat="server"
                                                    Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'>
                                                </asp:Label>
                                            </td>

                                            <td align="right">
                                                <asp:Label ID="lbl_item_dichiarazione_del"
                                                    runat="server"
                                                    Text="DICHIARAZIONE DEL:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_dic_del_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_dichiarazione_del_2"
                                                    runat="server"
                                                    Text='<%# Eval("data", "{0:dd/MM/yyyy}") %>'>
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_gap"
                                                    runat="server"
                                                    Width="20px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_info_seduta"
                                                    runat="server"
                                                    Text="SEDUTA:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_info_seduta_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_item_info_seduta_val"
                                                    runat="server"
                                                    Text='<%# Eval("info_seduta") %>'>
                                                </asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--lista incarichi--%>
                            <tr>
                                <td align="center">
                                    <asp:ListView ID="ListView_Item_Incarichi"
                                        runat="server"
                                        AllowPaging="false"
                                        AllowSorting="false"
                                        InsertItemPosition="None"
                                        AutoGenerateColumns="false"
                                        GridLines="None"
                                        DataKeyNames="id_incarico"
                                        DataSourceID="SQLDataSource_Incarichi">

                                        <LayoutTemplate>
                                            <table id="Table1" runat="server" width="100%">
                                                <tr id="Tr1" runat="server">
                                                    <td id="Td1" runat="server">
                                                        <table id="itemPlaceholderContainer" runat="server" width="100%" class="tab_gen">
                                                            <tr id="Tr2" runat="server">
                                                                <th id="Th1" runat="server" width="30%">CARICHE, INCARICHI, UFFICI, PROFESSIONI, ECC.
                                                                </th>
                                                                <th id="Th2" runat="server" width="0%" class="hidden">RIFERIMENTI NORMATIVI
                                                                </th>
                                                                <th id="Th6" runat="server" width="10%">DATA INIZIO	
                                                                </th>
                                                                <th id="Th3" runat="server" width="10%">DATA CESSAZIONE
                                                                </th>
                                                                <th id="Th7" runat="server" width="10%">COMPENSO
                                                                </th>
                                                                <th id="Th4" runat="server" width="20%">NOTE ISTRUTTORIE
                                                                </th>
                                                                <th id="Th8" runat="server" width="20%">NOTE TRASPARENZA
                                                                </th>
                                                            </tr>

                                                            <tr id="itemPlaceholder" runat="server">
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </LayoutTemplate>

                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen">
                                                <tr>
                                                    <th align="center">Nessun incarico associato alla scheda.
                                                    </th>
                                                </tr>
                                            </table>
                                        </EmptyDataTemplate>

                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lbl_item_nome_incarico"
                                                        runat="server"
                                                        Text='<%# Eval("nome_incarico") %>'>
                                                    </asp:Label>
                                                </td>

                                                <td class="hidden">
                                                    <asp:Label ID="lbl_item_riferimenti_normativi"
                                                        runat="server"
                                                        Text='<%# Eval("riferimenti_normativi") %>'>
                                                    </asp:Label>
                                                </td>

                                                <td style="text-align:right">
                                                    <asp:Label ID="lbl_item_data_inizio"
                                                        runat="server"
                                                        Text='<%# Eval("data_inizio") %>'>
                                                    </asp:Label>
                                                </td>

                                                <td style="text-align:right">
                                                    <asp:Label ID="lbl_item_data_cessazione"
                                                        runat="server"
                                                        Text='<%# Eval("data_cessazione") %>'>
                                                    </asp:Label>
                                                </td>

                                                <td style="text-align:right">
                                                    <asp:Label ID="lbl_item_compenso"
                                                        runat="server"
                                                        Text='<%# Eval("compenso") %>'>                                                        
                                                    </asp:Label>
                                                </td>

                                                <td>
                                                    <asp:Label ID="lbl_item_note_istruttorie"
                                                        runat="server"
                                                        Text='<%# Eval("note_istruttorie") %>'>
                                                    </asp:Label>
                                                </td>

                                                <td>
                                                    <asp:Label ID="lbl_item_note_trasparenza"
                                                        runat="server"
                                                        Text='<%# Eval("note_trasparenza") %>'>
                                                    </asp:Label>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:ListView>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--indicazioni gde--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_item_indicazioni_gde"
                                        runat="server"
                                        Text="INDICAZIONI GDE:"
                                        Font-Bold="true">
                                    </asp:Label>

                                    <br />

                                    <asp:Label ID="lbl_item_indicazioni_gde_2"
                                        runat="server"
                                        Text='<%# Eval("indicazioni_gde") %>'>
                                    </asp:Label>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--indicazioni segreteria--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_item_indicazioni_segreteria"
                                        runat="server"
                                        Text="INDICAZIONI SEGRETERIA:"
                                        Font-Bold="true">
                                    </asp:Label>

                                    <br />

                                    <asp:Label ID="lbl_item_indicazioni_segreteria_2"
                                        runat="server"
                                        Text='<%# Eval("indicazioni_seg") %>'>
                                    </asp:Label>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--allegato--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="Label1"
                                        runat="server"
                                        Text="ALLEGATO:"
                                        Font-Bold="true">
                                    </asp:Label>

                                    <br />

                                    <asp:LinkButton runat="server"
                                        Text='<%# Eval("filename") ?? "Allegato non caricato per questa scheda" %>'
                                        Font-Bold="true"
                                        OnClientClick='<%# getAttachmentURL(Eval("id_scheda"), Eval("filename")) %>'>
                                    </asp:LinkButton>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--crudel--%>
                            <% if ((role == 1) || (role == 2) || ((role == 5) && logged_categoria_organo == (int) Constants.CategoriaOrgano.GiuntaElezioni))
                                { %>
                            <tr>
                                <td align="center">
                                    <asp:Button ID="btn_item_edit"
                                        runat="server"
                                        CausesValidation="False"
                                        CommandName="Edit"
                                        CssClass="button"
                                        Text="Modifica" />

                                    <asp:Button ID="btn_item_delete"
                                        runat="server"
                                        CausesValidation="False"
                                        CommandName="Delete"
                                        CssClass="button"
                                        Text="Elimina"
                                        OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                                </td>
                            </tr>
                            <% } %>

                            <%--stampa scheda--%>
                            <tr>
                                <td align="right">
                                    <asp:LinkButton ID="LinkButtonPdfDetails"
                                        runat="server"
                                        OnClick="Print_Scheda">
		                                <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		                                Stampa Scheda
                                    </asp:LinkButton>
                                    -
                                    <asp:LinkButton ID="LinkButtonPdfTrasparenza"
                                        runat="server"
                                        OnClick="Print_SchedaTrasparenza">
		                                <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		                                Stampa Scheda Trasparenza
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </table>
                    </div>
                </ItemTemplate>

                <%--EDIT--%>
                <EditItemTemplate>
                    <div>
                        <inc:incarichi_scheda_edit runat="server" ID="SchedaEdit" />
                    </div>
                </EditItemTemplate>

                <%--INSERT--%>
                <InsertItemTemplate>
                    <div>
                        <table style="width: 100%;" border="0" cellpadding="0" cellspacing="0">
                            <%--organo + legislatura--%>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="lbl_insert_organo"
                                                    runat="server"
                                                    Text="GIUNTA DELLE ELEZIONI"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_organo_val"
                                                    runat="server">
                                                </asp:Label>
                                            </td>

                                            <td align="right">
                                                <asp:Label ID="lbl_insert_legislatura"
                                                    runat="server"
                                                    Text="LEGISLATURA:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_leg_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_legislatura_2"
                                                    runat="server"
                                                    Text='<%# selected_text_legislatura %>'>
                                                </asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--consigliere + gruppo--%>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="lbl_insert_consigliere"
                                                    runat="server"
                                                    Text="CONSIGLIERE:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_cons_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_consigliere_val"
                                                    runat="server"
                                                    Text='<%# selected_text_persona %>'>
                                                </asp:Label>
                                            </td>

                                            <td align="right">
                                                <asp:Label ID="lbl_insert_gruppo_consiliare"
                                                    runat="server"
                                                    Text="GRUPPO CONSILIARE:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_gruppo_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:DropDownList ID="ddl_insert_gruppo_consiliare"
                                                    runat="server"
                                                    AppendDataBoundItems="true"
                                                    DataSourceID="SQLDataSource_GruppiConsiliari"
                                                    DataTextField="nome_gruppo"
                                                    DataValueField="id_gruppo"
                                                    Width="250px">
                                                </asp:DropDownList>

                                                <asp:SqlDataSource ID="SqlDataSource_GruppiConsiliari"
                                                    runat="server"
                                                    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                    SelectCommand="select * from (
                                                            select P.id_persona, null as id_gruppo, '(nessuno)' as nome_gruppo, '99991231' as data_inizio
                                                            from persona P
                                                            left outer join
                                                            (select id_persona, COUNT(*) as num
                                                                from join_persona_gruppi_politici  
                                                                where (data_fine is null)
                                                                group by id_persona
                                                                ) Q
                                                            on P.id_persona = Q.id_persona
                                                            where num is null

                                                            union all

                                                            SELECT pp.id_persona, gg.id_gruppo, 
                                                            LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo,
                                                            convert(char(10),jpgp.data_inizio,112) as data_inizio
                                                            FROM gruppi_politici AS gg
                                                            INNER JOIN join_persona_gruppi_politici AS jpgp
                                                            ON gg.id_gruppo = jpgp.id_gruppo
                                                            INNER JOIN legislature AS ll
                                                            ON jpgp.id_legislatura = ll.id_legislatura
                                                            INNER JOIN persona AS pp
                                                            ON jpgp.id_persona = pp.id_persona
                                                            WHERE jpgp.deleted = 0 
                                                            AND pp.deleted = 0 
                                                            AND gg.deleted = 0 
                                                            ) PPP
                                                            where id_persona = @id_persona
                                                            ORDER BY PPP.data_inizio DESC">

                                                    <SelectParameters>
                                                        <asp:SessionParameter SessionField="selected_id_persona" Name="id_persona" Type="Int32" ConvertEmptyStringToNull="true" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--data_procl + dichiarazione del incarichi--%>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="lbl_insert_data_proclamazione"
                                                    runat="server"
                                                    Text="DATA PROCLAMAZIONE:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_data_proc_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_data_proclamazione_2"
                                                    runat="server"
                                                    Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'>
                                                </asp:Label>
                                            </td>

                                            <td align="right">
                                                <asp:Label ID="lbl_insert_dichiarazione_del"
                                                    runat="server"
                                                    Text="DICHIARAZIONE DEL:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_dic_del_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:TextBox ID="txt_insert_dichiarazione_del"
                                                    runat="server"
                                                    Width="80px">
                                                </asp:TextBox>

                                                <img alt="calendar"
                                                    src="../img/calendar_month.png"
                                                    id="img_insert_calendar"
                                                    runat="server" />

                                                <cc1:CalendarExtender ID="CalendarExtender_1"
                                                    runat="server"
                                                    TargetControlID="txt_insert_dichiarazione_del"
                                                    PopupButtonID="img_insert_calendar"
                                                    Format="dd/MM/yyyy">
                                                </cc1:CalendarExtender>

                                                <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData"
                                                    ControlToValidate="txt_insert_dichiarazione_del"
                                                    runat="server"
                                                    ErrorMessage="Formato gg/mm/aaaa."
                                                    Display="Dynamic"
                                                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                    ValidationGroup="ValidGroup_Insert">
                                                </asp:RegularExpressionValidator>

                                                <asp:RequiredFieldValidator ID="RFV_data"
                                                    runat="server"
                                                    ControlToValidate="txt_insert_dichiarazione_del"
                                                    ErrorMessage="*"
                                                    ValidationGroup="ValidGroup_Insert">
                                                </asp:RequiredFieldValidator>

                                                <asp:Label ID="lbl_insert_gap"
                                                    runat="server"
                                                    Width="20px">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_info_seduta"
                                                    runat="server"
                                                    Text="SEDUTA:"
                                                    Font-Bold="True">
                                                </asp:Label>

                                                <asp:Label ID="lbl_insert_info_seduta_gap"
                                                    runat="server"
                                                    Width="5px">
                                                </asp:Label>

                                                <asp:DropDownList ID="ddl_insert_info_seduta"
                                                    runat="server"
                                                    AppendDataBoundItems="true"
                                                    DataSourceID="SQLDataSource_InfoSeduta"
                                                    DataTextField="info_seduta"
                                                    DataValueField="id_seduta">
                                                    <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
                                                </asp:DropDownList>

                                                <asp:SqlDataSource ID="SQLDataSource_InfoSeduta"
                                                    runat="server"
                                                    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                    SelectCommand="SELECT ss.id_seduta,
                                                                                         'N° ' + ss.numero_seduta + ' del ' + CONVERT(varchar, ss.data_seduta, 103) AS info_seduta
                                                                                  FROM sedute AS ss
                                                                                  INNER JOIN legislature AS ll
                                                                                     ON ss.id_legislatura = ll.id_legislatura
                                                                                  INNER JOIN organi AS oo
                                                                                     ON ss.id_organo = oo.id_organo
                                                                                  WHERE ss.deleted = 0
                                                                                    AND oo.deleted = 0
                                                                                    AND oo.id_categoria_organo = 9 --'giunta elezioni'                                                                                    
                                                                                    AND ll.id_legislatura = @id_legislatura">
                                                    <SelectParameters>
                                                        <asp:SessionParameter Name="id_legislatura" Type="Int32" SessionField="selected_id_legislatura" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--lista incarichi--%>
                            <tr>
                                <td align="center"></td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--indicazioni gde--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_insert_indicazioni_gde"
                                        runat="server"
                                        Text="INDICAZIONI GDE:"
                                        Font-Bold="true">
                                    </asp:Label>

                                    <br />

                                    <asp:TextBox ID="txt_insert_indicazioni_gde"
                                        runat="server"
                                        TextMode="MultiLine"
                                        Rows="4"
                                        MaxLength="200"
                                        Width="99%">
                                    </asp:TextBox>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--indicazioni segreteria--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_insert_indicazioni_segreteria"
                                        runat="server"
                                        Text="INDICAZIONI SEGRETERIA:"
                                        Font-Bold="true">
                                    </asp:Label>

                                    <br />

                                    <asp:TextBox ID="txt_insert_indicazioni_segreteria"
                                        runat="server"
                                        TextMode="MultiLine"
                                        Rows="4"
                                        MaxLength="200"
                                        Width="99%">
                                    </asp:TextBox>
                                </td>
                            </tr>

                            <%--spazio--%>
                            <tr>
                                <td>&nbsp;
                                </td>
                            </tr>

                            <%--crudel--%>
                            <% if ((role == 1) || (role == 2) || ((role == 5) && 
                                    (logged_categoria_organo == (int) Constants.CategoriaOrgano.GiuntaElezioni)))
                                { %>
                            <tr>
                                <td align="center">
                                    <asp:Button ID="btn_insert_insert"
                                        runat="server"
                                        CausesValidation="True"
                                        ValidationGroup="ValidGroup_Insert"
                                        CommandName="Insert"
                                        CssClass="button"
                                        Text="Inserisci" />

                                    <asp:Button ID="btn_insert_cancel"
                                        runat="server"
                                        CausesValidation="False"
                                        CommandName="Cancel"
                                        CssClass="button"
                                        Text="Annulla"
                                        OnClick="btn_insert_cancel_click" />
                                </td>
                            </tr>
                            <% } %>
                        </table>
                    </div>
                </InsertItemTemplate>
            </asp:FormView>

            <asp:SqlDataSource ID="SqlDataSource_Scheda"
                runat="server"
                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                OnInserted="SqlDataSource_Scheda_Inserted"
                SelectCommand="SELECT ll.id_legislatura,
                                                         ll.num_legislatura AS legislatura,
                                                         sc.id_scheda,
                                                         pp.cognome + ' ' + pp.nome AS consigliere,
                                                         COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO') AS gruppo_consiliare,
                                                         COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_proclamazione,
                                                         CONVERT(varchar, sc.data, 103) AS data,
                                                         LTRIM(RTRIM(sc.indicazioni_gde)) AS indicazioni_gde,
                                                         LTRIM(RTRIM(sc.indicazioni_seg)) AS indicazioni_seg,
                                                         ss.id_seduta,
                                                         COALESCE('n° ' + ss.numero_seduta + ' del ' + CONVERT(varchar, ss.data_seduta, 103), 'N/A') AS info_seduta,
                                                         sc.id_gruppo AS id_gruppo,
                                                         sc.filename,
                                                         sc.filesize,
                                                         sc.filehash
                                                  FROM scheda AS sc
                                                  INNER JOIN persona AS pp
                                                     ON sc.id_persona = pp.id_persona
                                                  INNER JOIN legislature AS ll
                                                     ON sc.id_legislatura = ll.id_legislatura
                                                  INNER JOIN join_persona_organo_carica AS jpoc
                                                     ON (pp.id_persona = jpoc.id_persona AND ll.id_legislatura = jpoc.id_legislatura)
                                                  INNER JOIN organi AS oo
                                                     ON jpoc.id_organo = oo.id_organo
                                                  INNER JOIN cariche AS cc
                                                     ON jpoc.id_carica = cc.id_carica
                                                  LEFT OUTER JOIN gruppi_politici AS gg
                                                     ON (sc.id_gruppo = gg.id_gruppo AND gg.deleted = 0)
                                                  LEFT OUTER JOIN sedute AS ss
                                                     ON (sc.id_seduta = ss.id_seduta AND ss.deleted = 0)
                                                  WHERE sc.deleted = 0
                                                    AND pp.deleted = 0
                                                    AND jpoc.deleted = 0
                                                    AND oo.deleted = 0
                                                    AND ((cc.id_tipo_carica = 4 --'consigliere regionale'
                                                          AND 
                                                          oo.id_categoria_organo = 1 --'consiglio regionale'
                                                          )
                                                         OR
                                                         (cc.id_tipo_carica = 3 --'assessore non consigliere'
                                                          AND 
                                                          oo.id_categoria_organo = 4 -- 'giunta regionale'
                                                          ))
                                                    AND sc.id_scheda = @id_scheda"
                InsertCommand="INSERT INTO scheda (id_legislatura,
                                                                      id_persona,
                                                                      id_gruppo, 
                                                                      data,
                                                                      indicazioni_gde,
                                                                      indicazioni_seg,
                                                                      id_seduta,
                                                                      deleted) 
                                                  VALUES (@id_legislatura,
                                                          @id_persona,
                                                          @id_gruppo,
                                                          @data,
                                                          @indicazioni_gde,
                                                          @indicazioni_seg,
                                                          @id_seduta,
                                                          0); 
                                                  SELECT @id_scheda = SCOPE_IDENTITY();"
                UpdateCommand="UPDATE scheda 
                                                  SET id_gruppo = @id_gruppo, 
                                                      indicazioni_gde = @indicazioni_gde, 
                                                      indicazioni_seg = @indicazioni_seg, 
                                                      id_seduta = @id_seduta, 
                                                      filename = @filename,
                                                      filesize = @filesize,
                                                      filehash = @filehash 
                                                  WHERE id_scheda = @id_scheda"
                DeleteCommand="DELETE FROM incarico 
                                                  WHERE id_scheda = @id_scheda;
                                                  DELETE FROM scheda 
                                                  WHERE id_scheda = @id_scheda;">

                <SelectParameters>
                    <asp:SessionParameter SessionField="selected_id_scheda" Name="id_scheda" Type="Int32" ConvertEmptyStringToNull="true" />
                </SelectParameters>

                <InsertParameters>
                    <asp:Parameter Name="id_legislatura" Type="Int32" />
                    <asp:Parameter Name="id_persona" Type="Int32" />
                    <asp:Parameter Name="id_gruppo" Type="Int32" />
                    <asp:Parameter Name="data" Type="Datetime" />
                    <asp:Parameter Name="indicazioni_gde" Type="String" />
                    <asp:Parameter Name="indicazioni_seg" Type="String" />
                    <asp:Parameter Name="id_seduta" Type="Int32" />
                    <asp:Parameter Name="id_scheda" Type="Int32" Direction="Output" />
                </InsertParameters>

                <UpdateParameters>
                    <asp:Parameter Name="id_gruppo" Type="Int32" />
                    <asp:Parameter Name="indicazioni_gde" Type="String" />
                    <asp:Parameter Name="indicazioni_seg" Type="String" />
                    <asp:Parameter Name="id_seduta" Type="Int32" />
                    <asp:Parameter Name="id_scheda" Type="Int32" />
                    <asp:Parameter Name="filename" Type="String" />
                    <asp:Parameter Name="filesize" Type="Int32" />
                    <asp:Parameter Name="filehash" Type="String" />
                </UpdateParameters>

                <DeleteParameters>
                    <asp:Parameter Name="id_scheda" Type="Int32" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SQLDataSource_Incarichi"
                runat="server"
                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                SelectCommand="SELECT ii.id_incarico,
                                                         ii.nome_incarico,
                                                         ii.riferimenti_normativi,
                                                         ii.data_cessazione,
                                                         ii.note_istruttorie,
                                                         ii.data_inizio,
	                                                     ii.compenso,
	                                                     ii.note_trasparenza
                                                  FROM incarico AS ii
                                                  INNER JOIN scheda AS sc
                                                     ON ii.id_scheda = sc.id_scheda
                                                  WHERE sc.deleted = 0
                                                    AND ii.deleted = 0
                                                    AND sc.id_scheda = @id_scheda"
                InsertCommand="INSERT INTO incarico (id_scheda, 
                                                                        nome_incarico, 
                                                                        riferimenti_normativi, 
                                                                        data_cessazione, 
                                                                        note_istruttorie, 
                                                                        data_inizio,
	                                                                    compenso,
	                                                                    note_trasparenza,
                                                                        deleted)
                                                  VALUES (@id_scheda, 
                                                          @nome_incarico, 
                                                          @riferimenti_normativi, 
                                                          @data_cessazione, 
                                                          @note_istruttorie, 
                                                          @data_inizio,
	                                                      @compenso,
	                                                      @note_trasparenza,
                                                          0)"
                UpdateCommand="UPDATE incarico
                                                  SET nome_incarico = @nome_incarico,
                                                      riferimenti_normativi = @riferimenti_normativi,
                                                      data_cessazione = @data_cessazione,
                                                      note_istruttorie = @note_istruttorie,
                                                      data_inizio = @data_inizio,
	                                                  compenso = @compenso,
	                                                  note_trasparenza = @note_trasparenza
                                                  WHERE id_incarico = @id_incarico"
                DeleteCommand="DELETE FROM incarico
                                                  WHERE id_incarico = @id_incarico">
                <SelectParameters>
                    <asp:SessionParameter SessionField="selected_id_scheda" Name="id_scheda" Type="Int32" />
                </SelectParameters>

                <InsertParameters>
                    <asp:Parameter Name="nome_incarico" Type="String" />
                    <asp:Parameter Name="riferimenti_normativi" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="data_cessazione" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="note_istruttorie" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="data_inizio" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="compenso" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="note_trasparenza" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:SessionParameter SessionField="selected_id_scheda" Name="id_scheda" Type="Int32" />
                </InsertParameters>

                <UpdateParameters>
                    <asp:Parameter Name="nome_incarico" Type="String" />
                    <asp:Parameter Name="riferimenti_normativi" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="data_cessazione" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="note_istruttorie" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="data_inizio" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="compenso" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="note_trasparenza" Type="String" ConvertEmptyStringToNull="true" />
                    <asp:Parameter Name="id_incarico" Type="Int32" />
                </UpdateParameters>

                <DeleteParameters>
                    <asp:Parameter Name="id_incarico" Type="Int32" />
                </DeleteParameters>
            </asp:SqlDataSource>
        </td>
    </tr>
</table>

