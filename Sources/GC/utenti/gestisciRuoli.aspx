<%@ Page Language="C#"
    MasterPageFile="~/MasterPage.master"
    AutoEventWireup="true"
    CodeFile="gestisciRuoli.aspx.cs"
    Inherits="utenti_gestisciRuoli"
    Title="Utenti > Gestione Utenti" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
        <div id="content">
    <asp:ScriptManager ID="ScriptManager"
        runat="server"
        EnableScriptGlobalization="True">
    </asp:ScriptManager>

    <b>GESTIONE PROFILI &gt; RICERCA</b>

    <br />
    <br />

    <div class="pannello_ricerca">
        <asp:ImageButton ID="ImageButtonRicerca"
            runat="server"
            ImageUrl="~/img/magnifier_arrow.png" />

        <asp:Label ID="LabelRicerca"
            runat="server"
            Text="">
        </asp:Label>

        <cc1:collapsiblepanelextender id="cpe"
            runat="Server"
            targetcontrolid="PanelRicerca"
            collapsedsize="0"
            collapsed="True"
            expandcontrolid="ImageButtonRicerca"
            collapsecontrolid="ImageButtonRicerca"
            autocollapse="False"
            autoexpand="False"
            scrollcontents="False"
            textlabelid="LabelRicerca"
            collapsedtext="Apri Ricerca"
            expandedtext="Nascondi Ricerca"
            expanddirection="Vertical">
		</cc1:collapsiblepanelextender>

        <asp:Panel ID="PanelRicerca" runat="server">
            <br />
            <table width="100%">
                <tr>
                    <td valign="middle" align="left">
                        Legislatura:
		                <asp:DropDownList ID="DropDownListRicLeg"
                            runat="server"
                            DataSourceID="SqlDataSourceLegislature"
                            DataTextField="num_legislatura"
                            DataValueField="id_legislatura"
                            AutoPostBack="true"
                            Width="130px">
                        </asp:DropDownList>

                        <asp:SqlDataSource ID="SqlDataSourceLegislature"
                            runat="server"
                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            SelectCommand="SELECT id_legislatura, 
			                                      num_legislatura 
			                                FROM legislature
			                                ORDER BY durata_legislatura_da DESC"></asp:SqlDataSource>
                    </td>
                    <td>
                        Organo:
                        <asp:DropDownList ID="DropDownListOrgano"
                            runat="server"
                            DataSourceID="SqlDataSourceOrgano"
                            DataTextField="nome_organo"
                            DataValueField="id_organo"
                            Width="75%">
                            <asp:ListItem Text="" Value=""></asp:ListItem>
                        </asp:DropDownList>

                        <asp:SqlDataSource ID="SqlDataSourceOrgano"
                            runat="server"
                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            SelectCommand="
                                    SELECT * FROM (
                                        SELECT '' AS id_organo, '' as nome_organo
                                    
                                        union

                                        SELECT oo.id_organo, 
                                                num_legislatura + ' - ' + oo.nome_organo AS nome_organo
                                        FROM organi AS oo
                                        INNER JOIN legislature AS ll
                                        ON oo.id_legislatura = ll.id_legislatura
                                        WHERE oo.deleted = 0 and ll.id_legislatura = @id_legislatura
                                    ) T
                                    ORDER BY T.nome_organo">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="DropDownListRicLeg" Name="id_legislatura" PropertyName="SelectedValue" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </td>
                </tr>
            </table>
            <table width="100%">
                <tr>
                    <td align="left" valign="middle">
                        Grado:
		                <asp:TextBox ID="TextBoxRicGrado"
                            runat="server"
                            Width="50px">
                        </asp:TextBox>
                    </td>

                    <td align="left" valign="middle">
                        Ruolo:
		                <asp:TextBox ID="TextBoxRicNome"
                            runat="server"
                            Width="250px">
                        </asp:TextBox>
                    </td>

                    <td align="left" valign="middle">
                        Gruppo rete:
		                <asp:TextBox ID="TextBoxRicGruppoRete"
                            runat="server"
                            Width="200px">
                        </asp:TextBox>
                    </td>

                    <td align="right" valign="middle">
                        <asp:Button ID="ButtonRic"
                            runat="server"
                            Text="Applica"
                            CssClass="button"
                            OnClick="ButtonRic_Click" />
                    </td>
                </tr>
            </table>
        </asp:Panel>

            <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:ListView ID="ListView2"
                        runat="server"
                        DataKeyNames="id_ruolo"
                        DataSourceID="SqlDataSource3"
                        InsertItemPosition="LastItem" 
                        OnItemCommand="ListView2_ItemCommand"
                        OnItemInserting="ListView2_ItemInserting"
                        OnItemInserted="ListView2_ItemInserted"
                        OnItemEditing="ListView2_ItemEditing">

                        <LayoutTemplate>
                            <table runat="server" width="100%">
                                <tr runat="server">
                                    <td runat="server">
                                        <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
                                            <tr runat="server">
                                                <th width="25%" runat="server">Nome Ruolo</th>
                                                <th width="40px" runat="server">Grado</th>
                                                <th width="30%" runat="server">Organo di riferimento</th>                                                
                                                <th width="30%" runat="server">Gruppo di rete</th>
                                                <th width="40px" runat="server">Sort</th>
                                                <th width="10%"  id="Th2" runat="server"></th>
                                            </tr>

                                            <tr id="itemPlaceholder" runat="server"></tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </LayoutTemplate>

                        <EmptyDataTemplate>
                            <table id="Table2" runat="server" style="">
                                <tr>
                                    <td>Non è stato restituito alcun dato.
                                    </td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>

                        <InsertItemTemplate>
                            <tr style="">
                                <td align="center" valign="middle">
                                    <asp:TextBox ID="TextBoxNomeRuoloInsert"
                                        runat="server"
                                        Text='<%# Bind("nome_ruolo") %>'
                                        Width="95%">
                                    </asp:TextBox>

                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorNomeRuoloInsert"
                                        ControlToValidate="TextBoxNomeRuoloInsert"
                                        runat="server"
                                        Display="Dynamic"
                                        ErrorMessage="Campo obbligatorio."
                                        ValidationGroup="ValidGroupRuoloInsert">
                                    </asp:RequiredFieldValidator>
                                </td>

                                <td align="center" valign="middle">
				                    <asp:TextBox ID="txt_Grado_Insert" 
				                                    runat="server" 
				                                    Text='<%# Bind("grado") %>'
				                                    Width="95%" >
				                    </asp:TextBox>
				        
				                    <asp:RequiredFieldValidator ID="RequiredFieldValidator_txt_Grado_Insert" 
				                                                runat="server" 
				                                                ControlToValidate="txt_Grado_Insert"
				                                                Display="Dynamic" 
				                                                ErrorMessage="Campo obbligatorio." 
				                                                ValidationGroup="ValidGroupRuoloInsert" >
				                    </asp:RequiredFieldValidator>
				        
				                    <asp:RegularExpressionValidator ID="REV_txt_Grado_Insert" 
				                                                    runat="server" 
				                                                    ControlToValidate="txt_Grado_Insert"
				                                                    Display="Dynamic" 
				                                                    ErrorMessage="Solo numeri." 
				                                                    ValidationExpression="^(0|[1-9]\d*)$"
				                                                    ValidationGroup="ValidGroupRuoloInsert" >
				                    </asp:RegularExpressionValidator>
			                    </td>

                                <td align="center" valign="middle">
                                    <asp:DropDownList ID="DropDownListOrganoInsert"
                                        runat="server"
                                        DataSourceID="SqlDataSourceOrganoInsert"
                                        DataTextField="nome_organo"
                                        DataValueField="id_organo"
                                        Width="99%"
                                        AppendDataBoundItems="true">
                                        <asp:ListItem Text="" Value=""></asp:ListItem>
                                    </asp:DropDownList>

                                    <asp:SqlDataSource ID="SqlDataSourceOrganoInsert"
                                        runat="server"
                                        ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                        SelectCommand="SELECT oo.id_organo, 
                                                                 num_legislatura + ' - ' + oo.nome_organo AS nome_organo
                                                          FROM organi AS oo
                                                          INNER JOIN legislature AS ll
                                                            ON oo.id_legislatura = ll.id_legislatura
                                                          WHERE oo.deleted = 0
                                                          ORDER BY ll.durata_legislatura_da DESC, oo.nome_organo"></asp:SqlDataSource>

<%--                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListOrganoInsert"
                                        ControlToValidate="DropDownListOrganoInsert"
                                        runat="server"
                                        Display="Dynamic"
                                        ErrorMessage="Campo obbligatorio."
                                        ValidationGroup="ValidGroupRuoloInsert">
                                    </asp:RequiredFieldValidator>--%>
                                </td>

                                <td align="center" valign="middle">
                                    <asp:TextBox ID="TextBoxReteGruppoInsert"
                                        runat="server"
                                        Text='<%# Bind("rete_gruppo") %>'
                                        Width="95%">
                                    </asp:TextBox>

                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                        ControlToValidate="TextBoxReteGruppoInsert"
                                        runat="server"
                                        Display="Dynamic"
                                        ErrorMessage="Campo obbligatorio."
                                        ValidationGroup="ValidGroupRuoloInsert">
                                    </asp:RequiredFieldValidator>
                                </td>

                                <td align="center" valign="middle">
				                    <asp:TextBox ID="TextBoxReteSortInsert" 
				                                    runat="server" 
				                                    Text='<%# Bind("rete_sort") %>'
				                                    Width="95%">
				                    </asp:TextBox>
				        
				                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" 
				                                                    runat="server" 
				                                                    ControlToValidate="TextBoxReteSortInsert"
				                                                    Display="Dynamic" 
				                                                    ErrorMessage="Solo numeri." 
				                                                    ValidationExpression="^(0|[1-9]\d*)$"
				                                                    ValidationGroup="ValidGroupRuoloInsert" >
				                    </asp:RegularExpressionValidator>
			                    </td>

                                <td align="right" valign="middle">
                                    <asp:Button ID="InsertButton"
                                        runat="server"
                                        CommandName="Insert"
                                        Text="Inserisci"
                                        CssClass="button"
                                        ValidationGroup="ValidGroupRuoloInsert" />

                                    <asp:Button ID="CancelButton"
                                        runat="server"
                                        CommandName="Cancel"
                                        Text="Cancella"
                                        CssClass="button" />
                                </td>
                            </tr>
                        </InsertItemTemplate>

                        <EditItemTemplate>
                            <tr style="">
                                <td align="center" valign="middle">
                                    <asp:TextBox ID="TextBoxNomeRuoloEdit"
                                        runat="server"
                                        Text='<%# Bind("nome_ruolo") %>'
                                        Width="95%">
                                    </asp:TextBox>

                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorNomeRuoloEdit"
                                        runat="server"
                                        ControlToValidate="TextBoxNomeRuoloEdit"
                                        Display="Dynamic"
                                        ErrorMessage="Campo obbligatorio."
                                        ValidationGroup="ValidGroupRuoloEdit">
                                    </asp:RequiredFieldValidator>
                                </td>

                                <td align="center" valign="middle">
				                    <asp:TextBox ID="txt_Grado_Edit" 
				                                 runat="server" 
				                                 Text='<%# Bind("grado") %>'
				                                 Width="95%" >
				                    </asp:TextBox>
				        
				                    <asp:RequiredFieldValidator ID="RequiredFieldValidator_txt_Grado_Edit" 
				                                                runat="server" 
				                                                ControlToValidate="txt_Grado_Edit"
				                                                Display="Dynamic" 
				                                                ErrorMessage="Campo obbligatorio." 
				                                                ValidationGroup="ValidGroupRuoloEdit" >
				                    </asp:RequiredFieldValidator>
				        
				                    <asp:RegularExpressionValidator ID="REV_txt_Grado_Edit" 
				                                                    runat="server" 
				                                                    ControlToValidate="txt_Grado_Edit"
				                                                    Display="Dynamic" 
				                                                    ErrorMessage="Solo numeri." 
				                                                    ValidationExpression="^(0|[1-9]\d*)$"
				                                                    ValidationGroup="ValidGroupRuoloEdit" >
				                    </asp:RegularExpressionValidator>
			                    </td>

                                <td align="center" valign="middle">
                                    <asp:DropDownList ID="DropDownListOrganoEdit"
                                        runat="server"
                                        DataSourceID="SqlDataSourceOrganoEdit"
                                        DataTextField="nome_organo"
                                        DataValueField="id_organo"
                                        Width="99%" AppendDataBoundItems="true"
                                        SelectedValue='<%# Bind("id_organo") %>'>
                                        <asp:ListItem Text="" Value=""></asp:ListItem>
                                    </asp:DropDownList>

                                    <asp:SqlDataSource ID="SqlDataSourceOrganoEdit"
                                        runat="server"
                                        ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                        SelectCommand="SELECT oo.id_organo, 
                                                                 num_legislatura + ' - ' + oo.nome_organo AS nome_organo
                                                          FROM organi AS oo
                                                          INNER JOIN legislature AS ll
                                                            ON oo.id_legislatura = ll.id_legislatura
                                                          WHERE oo.deleted = 0
                                                          ORDER BY ll.durata_legislatura_da DESC, oo.nome_organo"></asp:SqlDataSource>

<%--                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListOrganoEdit"
                                        ControlToValidate="DropDownListOrganoEdit"
                                        runat="server"
                                        Display="Dynamic"
                                        ErrorMessage="Campo obbligatorio."
                                        ValidationGroup="ValidGroupRuoloEdit">
                                    </asp:RequiredFieldValidator>--%>
                                </td>

                                <td align="center" valign="middle">
                                    <asp:TextBox ID="TextBoxReteGruppoEdit"
                                        runat="server"
                                        Text='<%# Bind("rete_gruppo") %>'
                                        Width="95%">
                                    </asp:TextBox>

                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                        ControlToValidate="TextBoxReteGruppoEdit"
                                        runat="server"
                                        Display="Dynamic"
                                        ErrorMessage="Campo obbligatorio."
                                        ValidationGroup="ValidGroupRuoloEdit">
                                    </asp:RequiredFieldValidator>
                                </td>

                                <td align="center" valign="middle">
				                    <asp:TextBox ID="TextBoxReteSortEdit" 
				                                    runat="server" 
				                                    Text='<%# Bind("rete_sort") %>'
				                                    Width="95%">
				                    </asp:TextBox>
				        
				                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" 
				                                                    runat="server" 
				                                                    ControlToValidate="TextBoxReteSortEdit"
				                                                    Display="Dynamic" 
				                                                    ErrorMessage="Solo numeri." 
				                                                    ValidationExpression="^(0|[1-9]\d*)$"
				                                                    ValidationGroup="ValidGroupRuoloEdit" >
				                    </asp:RegularExpressionValidator>
			                    </td>

                                <td align="right" valign="middle">
                                    <asp:Button ID="UpdateButton"
                                        runat="server"
                                        CommandName="Update"
                                        Text="Aggiorna"
                                        CssClass="button"
                                        ValidationGroup="ValidGroupRuoloEdit" />

                                    <asp:Button ID="CancelButton"
                                        runat="server"
                                        CommandName="Cancel"
                                        Text="Annulla"
                                        CssClass="button" />
                                </td>
                            </tr>
                        </EditItemTemplate>

                        <ItemTemplate>
                            <tr style="">
                                <td valign="middle">
                                    <asp:Label ID="nome_ruoloLabel"
                                        runat="server"
                                        Text='<%# Eval("nome_ruolo") %>'>
                                    </asp:Label>
                                </td>

                                <td valign="middle">
                                    <asp:Label ID="grado_label"
                                        runat="server"
                                        Text='<%# Eval("grado") %>'>
                                    </asp:Label>
                                </td>

                                <td valign="middle">
                                    <asp:Label ID="id_organoLabel"
                                        runat="server"
                                        Text='<%# Eval("nome_organo") %>'>
                                    </asp:Label>
                                </td>

                                <td valign="middle">
                                    <asp:Label ID="rete_gruppoLabel"
                                        runat="server"
                                        Text='<%# Eval("rete_gruppo") %>'>
                                    </asp:Label>
                                </td>

                                <td valign="middle">
                                    <asp:Label ID="rete_sortLabel"
                                        runat="server"
                                        Text='<%# Eval("rete_sort") %>'>
                                    </asp:Label>
                                </td>

                                <td align="right" valign="middle">
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
                            </tr>
                        </ItemTemplate>
                    </asp:ListView>

                    <asp:SqlDataSource ID="SqlDataSource3"
                        runat="server"
                        ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                        SelectCommand=""
                        InsertCommand="INSERT INTO tbl_ruoli (nome_ruolo, 
		                                                         grado, 
		                                                         id_organo,
                                                                 rete_sort,
                                                                 rete_gruppo)
		                                              VALUES (@nome_ruolo, 
		                                                      @grado, 
		                                                      @id_organo,
                                                              @rete_sort,
                                                              @rete_gruppo)"
                        UpdateCommand="UPDATE tbl_ruoli 
		                                  SET nome_ruolo = @nome_ruolo, 
		                                      id_organo = @id_organo,
		                                      grado = @grado,
                        		              rete_sort = @rete_sort,
                        		              rete_gruppo = @rete_gruppo
		                                  WHERE id_ruolo = @id_ruolo"
                        DeleteCommand="DELETE FROM tbl_ruoli 
		                                  WHERE id_ruolo = @id_ruolo">
<%--                    <SelectParameters>
                            <asp:Parameter DefaultValue="5" Name="grado" Type="Int32" />
                        </SelectParameters>--%>

                        <DeleteParameters>
                            <asp:Parameter Name="id_ruolo" Type="Int32" />
                        </DeleteParameters>

                        <UpdateParameters>
                            <asp:Parameter Name="nome_ruolo" Type="String" />
                            <asp:Parameter Name="id_organo" Type="Int32" />
                            <asp:Parameter Name="id_ruolo" Type="Int32" />
                            <asp:Parameter Name="grado" Type="Int32" />
                            <asp:Parameter Name="rete_sort" Type="Int32" />
                            <asp:Parameter Name="rete_gruppo" Type="String" />
                        </UpdateParameters>

                        <InsertParameters>
                            <asp:Parameter Name="nome_ruolo" Type="String" />
                            <asp:Parameter Name="id_organo" Type="Int32" />
                            <asp:Parameter Name="grado" Type="Int32" />
                            <asp:Parameter Name="rete_sort" Type="Int32" />
                            <asp:Parameter Name="rete_gruppo" Type="String" />
                        </InsertParameters>
                    </asp:SqlDataSource>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
</asp:Content>
