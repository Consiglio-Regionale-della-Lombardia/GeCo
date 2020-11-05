<%@ Control Language="C#" AutoEventWireup="true" CodeFile="incarichi_scheda_edit.ascx.cs" Inherits="incarichi_scheda_edit" %>

<table style="width: 100%;" border="0" cellpadding="0" cellspacing="0">
    <%--organo + legislatura--%>
    <tr>
        <td>
            <table width="100%">
                <tr>
                    <td align="left">
                        <asp:Label ID="lbl_edit_organo"
                            runat="server"
                            Text="GIUNTA DELLE ELEZIONI"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_organo_val"
                            runat="server">
                        </asp:Label>
                    </td>

                    <td align="right">
                        <asp:Label ID="lbl_edit_legislatura"
                            runat="server"
                            Text="LEGISLATURA:"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_leg_gap"
                            runat="server"
                            Width="5px">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_legislatura_2"
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
                        <asp:Label ID="lbl_edit_consigliere"
                            runat="server"
                            Text="CONSIGLIERE:"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_cons_gap"
                            runat="server"
                            Width="5px">
                        </asp:Label>

                        <asp:Label ID="lbl_item_consigliere_2"
                            runat="server"
                            Text='<%# Eval("consigliere") %>'>
                        </asp:Label>
                    </td>

                    <td align="right">
                        <asp:Label ID="lbl_edit_gruppo_consiliare"
                            runat="server"
                            Text="GRUPPO CONSILIARE:"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_gruppo_gap"
                            runat="server"
                            Width="5px">
                        </asp:Label>

                        <asp:DropDownList ID="ddl_edit_gruppo_consiliare"
                            runat="server"
                            AppendDataBoundItems="true"
                            DataSourceID="SQLDataSource_GruppiConsiliari"
                            DataTextField="nome_gruppo"
                            DataValueField="id_gruppo"
                            SelectedValue='<%# Eval("id_gruppo") %>'
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
                        <asp:Label ID="lbl_edit_data_proclamazione"
                            runat="server"
                            Text="DATA PROCLAMAZIONE:"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_data_proc_gap"
                            runat="server"
                            Width="5px">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_data_proclamazione_2"
                            runat="server"
                            Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>'>
                        </asp:Label>
                    </td>

                    <td align="right">
                        <asp:Label ID="lbl_edit_dichiarazione_del"
                            runat="server"
                            Text="DICHIARAZIONE DEL:"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_dic_del_gap"
                            runat="server"
                            Width="5px">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_dichiarazione_del_2"
                            runat="server"
                            Text='<%# Eval("data", "{0:dd/MM/yyyy}") %>'>
                        </asp:Label>

                        <asp:Label ID="lbl_edit_gap"
                            runat="server"
                            Width="20px">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_info_seduta"
                            runat="server"
                            Text="SEDUTA:"
                            Font-Bold="True">
                        </asp:Label>

                        <asp:Label ID="lbl_edit_info_seduta_gap"
                            runat="server"
                            Width="5px">
                        </asp:Label>

<%--                       <asp:Label ID="Label2"
                            runat="server"
                            Width="5px" Text='<%# Eval("id_seduta") %>'>
                        </asp:Label>

                        <br />--%>

                       <asp:DropDownList ID="ddl_edit_info_seduta"
                            runat="server"
                            AppendDataBoundItems="true"
                            DataSourceID="SQLDataSource_InfoSeduta"
                            DataTextField="info_seduta"
                            DataValueField="id_seduta"
                            SelectedValue='<%# Eval("id_seduta") %>'>
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
                                                                                    AND (oo.id_categoria_organo = 9 -- giunta elezioni
                                                                                        )
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
        <td align="center">
            <asp:ListView ID="ListView_Edit_Incarichi"
                runat="server"
                AllowPaging="false"
                AllowSorting="false"
                InsertItemPosition="LastItem"
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
                                        <th id="Th10" runat="server" width="10%">DATA INIZIO	
                                        </th>
                                        <th id="Th3" runat="server" width="10%">DATA CESSAZIONE
                                        </th>
                                        <th id="Th14" runat="server" width="10%">COMPENSO
                                        </th>
                                        <th id="Th4" runat="server" width="15%">NOTE ISTRUTTORIE
                                        </th>
                                        <th id="Th15" runat="server" width="15%">NOTE TRASPARENZA
                                        </th>
                                        <th id="Th5" runat="server" width="10%"></th>
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
                        <td>
                            <asp:Label ID="lbl_item_data_inizio"
                                runat="server"
                                Text='<%# Eval("data_inizio") %>'>
                            </asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lbl_item_data_cessazione"
                                runat="server"
                                Text='<%# Eval("data_cessazione") %>'>
                            </asp:Label>
                        </td>
                        <td>
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


                        <% if ((role == 1) || (role == 2) || ((role == 5) && (nome_organo.Contains("giunta") && nome_organo.Contains("elezioni"))))
                            { %>
                        <td width="10%" valign="middle" align="center">
                            <asp:Button ID="EditButton"
                                runat="server"
                                CommandName="Edit"
                                Text="Modifica"
                                CssClass="button" />

                            <asp:Button ID="DeleteButton"
                                runat="server"
                                CommandName="Delete"
                                Text="Elimina"
                                CssClass="button"
                                OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                        </td>
                        <% } %>
                    </tr>
                </ItemTemplate>

                <EditItemTemplate>
                    <tr>
                        <td>
                            <asp:TextBox ID="txt_edit_nome_incarico"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("nome_incarico") %>'>
                            </asp:TextBox>

                            <%--			                                        <asp:RequiredFieldValidator ID="RFV_edit_nome_incarico" 
			                                                                    runat="server"
			                                                                    ControlToValidate="txt_edit_nome_incarico"
			                                                                    Display="Dynamic"
			                                                                    ErrorMessage="*"
			                                                                    ValidationGroup="ValidGroupEdit">
			                                        </asp:RequiredFieldValidator>--%>
                        </td>

                        <td class="hidden">
                            <asp:TextBox ID="txt_edit_riferimenti_normativi"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("riferimenti_normativi") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_edit_data_inizio"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("data_inizio") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_edit_data_cessazione"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("data_cessazione") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_edit_compenso"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("compenso") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_edit_note_istruttorie"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("note_istruttorie") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_edit_note_trasparenza"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("note_trasparenza") %>'>
                            </asp:TextBox>
                        </td>

                        <% if ((role == 1) || (role == 2) || ((role == 5) && (nome_organo.Contains("giunta") && nome_organo.Contains("elezioni"))))
                            { %>
                        <td width="10%" valign="middle" align="center">
                            <asp:Button ID="UpdateButton"
                                runat="server"
                                CommandName="Update"
                                Text="Aggiorna"
                                CssClass="button"
                                ValidationGroup="ValidGroupEdit" />

                            <asp:Button ID="CancelButton"
                                runat="server"
                                CommandName="Cancel"
                                Text="Annulla"
                                CssClass="button" />
                        </td>
                        <% } %>
                    </tr>
                </EditItemTemplate>

                <InsertItemTemplate>
                    <tr>
                        <td>
                            <asp:TextBox ID="txt_insert_nome_incarico"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("nome_incarico") %>'>
                            </asp:TextBox>

                            <%--		                                        <asp:RequiredFieldValidator ID="RFV_insert_nome_incarico" 
			                                                                    runat="server"
			                                                                    ControlToValidate="txt_insert_nome_incarico"
			                                                                    Display="Dynamic"
			                                                                    ErrorMessage="*"
			                                                                    ValidationGroup="ValidGroupInsert">
			                                        </asp:RequiredFieldValidator>--%>
                        </td>

                        <td class="hidden">
                            <asp:TextBox ID="txt_insert_riferimenti_normativi"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("riferimenti_normativi") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_insert_data_inizio"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("data_inizio") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_insert_data_cessazione"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("data_cessazione") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_insert_compenso"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("compenso") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_insert_note_istruttorie"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("note_istruttorie") %>'>
                            </asp:TextBox>
                        </td>
                        <td>
                            <asp:TextBox ID="txt_insert_note_trasparenza"
                                runat="server"
                                Width="95%"
                                TextMode="MultiLine"
                                Rows="3"
                                Text='<%# Bind("note_trasparenza") %>'>
                            </asp:TextBox>
                        </td>
                        <% if ((role == 1) || (role == 2) || ((role == 5) && (nome_organo.Contains("giunta") && nome_organo.Contains("elezioni"))))
                            { %>
                        <td width="10%" valign="middle" align="center">
                            <asp:Button ID="InsertButton"
                                runat="server"
                                CommandName="Insert"
                                Text="Inserisci"
                                CssClass="button"
                                ValidationGroup="ValidGroupInsert" />
                        </td>
                        <% } %>
                    </tr>
                </InsertItemTemplate>
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
            <asp:Label ID="lbl_edit_indicazioni_gde"
                runat="server"
                Text="INDICAZIONI GDE:"
                Font-Bold="true">
            </asp:Label>

            <br />

            <asp:TextBox ID="txt_edit_indicazioni_gde"
                runat="server"
                TextMode="MultiLine"
                Rows="4"
                Text='<%# Bind("indicazioni_gde") %>'
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
            <asp:Label ID="lbl_edit_indicazioni_segreteria"
                runat="server"
                Text="INDICAZIONI SEGRETERIA:"
                Font-Bold="true">
            </asp:Label>

            <br />

            <asp:TextBox ID="txt_edit_indicazioni_segreteria"
                runat="server"
                TextMode="MultiLine"
                Rows="4"
                Text='<%# Bind("indicazioni_seg") %>'
                Width="99%">
            </asp:TextBox>
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

            <div style="margin:6px 0px;">
              <asp:Label runat="server" ID="label_filename" Text='<%# Eval("filename") == DBNull.Value ? "Allegato non caricato per questa scheda" : Eval("filename") %>'>
              </asp:Label>       
                
                <asp:LinkButton ID="cmdDeleteAttachment"
                    runat="server"
                    Text="Elimina"
                    CssClass="button"
                    Visible='<%# (Eval("filename") != DBNull.Value && Eval("filename") != null) ? true : false %>'
                    CausesValidation="false" EnableViewState="false"
                    OnClientClick="return confirm('Confermare la cancellazione del file?');"
                    OnCommand="cmdDeleteAttachment_Command" />
            </div>

            <br />

            <div>
                <asp:FileUpload ID="uploadFile" runat="server" BackColor="#BBEEBB" Width="400" />

<%--                <asp:Button ID="cmdNewAttachment"
                    runat="server"
                    Text="Aggiungi"
                    OnClick="cmdNewAttachment_Click"
                    CssClass="button"
                    CausesValidation="false" EnableViewState="false" />--%>
            </div>
      
             <asp:HiddenField runat="server" ID="hidden_filename" Value='<%# Eval("filename") %>' />
             <asp:HiddenField runat="server" ID="hidden_filesize" Value='<%# Eval("filesize") %>' />     
             <asp:HiddenField runat="server" ID="hidden_filehash" Value='<%# Eval("filehash") %>' />   

             <asp:HiddenField runat="server" ID="hidden_id_scheda" Value='<%# Eval("id_scheda") %>' />      
        </td>
    </tr>

    <%--spazio--%>
    <tr>
        <td>&nbsp;
        </td>
    </tr>

    <%--crudel--%>
    <% if ((role == 1) || (role == 2) || ((role == 5) && (nome_organo.Contains("giunta") && nome_organo.Contains("elezioni"))))
        { %>
    <tr>
        <td align="center">
            <asp:Button ID="btn_edit_update"
                runat="server"
                CausesValidation="False"
                CommandName="Update"
                CssClass="button"
                Text="Aggiorna" />

            <asp:Button ID="btn_edit_cancel"
                runat="server"
                CausesValidation="False"
                CommandName="Cancel"
                CssClass="button"
                Text="Annulla" />
        </td>
    </tr>
    <% } %>
</table>




