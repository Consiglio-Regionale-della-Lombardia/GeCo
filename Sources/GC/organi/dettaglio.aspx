<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MasterPage.master"
    CodeFile="dettaglio.aspx.cs" Inherits="organi_dettaglio" Title="Organo > Anagrafica" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <script type="text/javascript" language="javascript">

        function CheckCR(oSrc, args) {
            args.IsValid = true;

            var chk = document.getElementById('ctl00_ContentPlaceHolder1_DetailsView1_check_comitato_ristretto');
            var hid = document.getElementById('ctl00_ContentPlaceHolder1_DetailsView1_dd_idcommissione');

            //alert('chk: ' + chk.toString());
            //alert('dd: ' + dd.toString());

            if (chk && hid) {
                //alert('chk.value: ' + chk.checked);
                //alert('dd.value: ' + dd.value);

                if (chk.checked = true) {
                    args.IsValid = (hid.value != "");
                }
            }
        }
    </script>
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>&nbsp;
            </td>
        </tr>
        <tr>
            <td>
                <b>ORGANO &gt; ANAGRAFICA</b>
            </td>
        </tr>
        <tr>
            <td>&nbsp;
            </td>
        </tr>
        <tr>
            <td>
                <div id="tab">
                    <ul>
                        <li id="selected"><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
                        <li><a id="a_componenti" runat="server">COMPONENTI</a></li>
                        <li><a id="a_cariche" runat="server">CARICHE</a></li>
                    </ul>
                </div>
                <div id="tab_content">
                    <div id="tab_content_content">
                        <table width="100%" cellspacing="5" cellpadding="10">
                            <tr>
                                <td class="singleborder" valign="top" width="75%">
                                    <asp:DetailsView ID="DetailsView1" runat="server" Height="50px" Width="100%" AutoGenerateRows="False"
                                        DataSourceID="SqlDataSource1" OnItemDeleted="DetailsView1_ItemDeleted" CellPadding="5"
                                        GridLines="None" DataKeyNames="id_organo" OnItemUpdated="DetailsView1_ItemUpdated"
                                        OnItemInserting="DetailsView1_ItemInserting" OnItemUpdating="DetailsView1_ItemUpdating"
                                        OnModeChanged="DetailsView1_ModeChanged" OnPreRender="DetailsView1_PreRender">
                                        <FieldHeaderStyle Font-Bold="True" Width="150px" />
                                        <Fields>
                                            <asp:TemplateField HeaderText="Legislatura">
                                                <ItemTemplate>
                                                    <asp:Label ID="label_num_legislatura" runat="server" Text='<%# Eval("num_legislatura") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:DropDownList ID="dd_legislatura" runat="server" Width="80px" DataSourceID="SqlDataSource2"
                                                        DataTextField="num_legislatura" DataValueField="id_legislatura" AutoPostBack="true"
                                                        OnSelectedIndexChanged="ddLeg_SelectedIndexChanged" SelectedValue='<%# Bind("id_legislatura") %>'>
                                                    </asp:DropDownList>
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:DropDownList ID="dd_legislatura" runat="server" Width="80px" DataSourceID="SqlDataSource2"
                                                        DataTextField="num_legislatura" DataValueField="id_legislatura" AutoPostBack="true"
                                                        OnSelectedIndexChanged="ddLeg_SelectedIndexChanged" SelectedValue='<%# Bind("id_legislatura") %>'>
                                                    </asp:DropDownList>
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Organo" SortExpression="nome_organo">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelOrgano" runat="server" Text='<%# Bind("nome_organo") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="TextBoxOrgano" runat="server" Text='<%# Bind("nome_organo") %>'
                                                        MaxLength='255' Width="400px">
                                                    </asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxOrgano" ControlToValidate="TextBoxOrgano"
                                                        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup">
                                                    </asp:RequiredFieldValidator>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:TextBox ID="TextBoxOrgano" runat="server" Text='<%# Bind("nome_organo") %>'
                                                        MaxLength='255' Width="400px">
                                                    </asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxOrgano" ControlToValidate="TextBoxOrgano"
                                                        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup">
                                                    </asp:RequiredFieldValidator>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Nome abbreviato" SortExpression="nome_organo_breve">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelOrganoBreve" runat="server" Text='<%# Bind("nome_organo_breve") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="TextBoxOrganoBreve" runat="server" Text='<%# Bind("nome_organo_breve") %>'
                                                        MaxLength='30' Width="200px">
                                                    </asp:TextBox>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:TextBox ID="TextBoxOrganooBreve" runat="server" Text='<%# Bind("nome_organo_breve") %>'
                                                        MaxLength='30' Width="200px">
                                                    </asp:TextBox>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Data inizio" SortExpression="data_inizio">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelDataInizio" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="dtMod_inizio_group" runat="server" Width="80px" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
                                                    </asp:TextBox>
                                                    <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
                                                    <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dtMod_inizio_group"
                                                        PopupButtonID="Image1" Format="dd/MM/yyyy">
                                                    </cc1:CalendarExtender>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatordMod_inizio_group" ControlToValidate="dtMod_inizio_group"
                                                        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup">
                                                    </asp:RequiredFieldValidator>
                                                    <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_inizio_group" ControlToValidate="dtMod_inizio_group"
                                                        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                        ValidationGroup="ValidGroup">
                                                    </asp:RegularExpressionValidator>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:TextBox ID="dtIns_inizio_group" runat="server" Width="80px">
                                                    </asp:TextBox>
                                                    <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
                                                    <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dtIns_inizio_group"
                                                        PopupButtonID="Image1" Format="dd/MM/yyyy">
                                                    </cc1:CalendarExtender>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatordIns_inizio_group" ControlToValidate="dtIns_inizio_group"
                                                        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup">
                                                    </asp:RequiredFieldValidator>
                                                    <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_inizio_group" ControlToValidate="dtIns_inizio_group"
                                                        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                        ValidationGroup="ValidGroup">
                                                    </asp:RegularExpressionValidator>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Data fine" SortExpression="data_fine">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelDataFine" runat="server" Width="80px" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="dtMod_fine_group" runat="server" Width="80px" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
                                                    </asp:TextBox>
                                                    <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
                                                    <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dtMod_fine_group"
                                                        PopupButtonID="Image2" Format="dd/MM/yyyy">
                                                    </cc1:CalendarExtender>
                                                    <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_fine_group" ControlToValidate="dtMod_fine_group"
                                                        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                        ValidationGroup="ValidGroup">
                                                    </asp:RegularExpressionValidator>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:TextBox ID="dtIns_fine_group" runat="server" Width="80px">
                                                    </asp:TextBox>
                                                    <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
                                                    <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dtIns_fine_group"
                                                        PopupButtonID="Image2" Format="dd/MM/yyyy">
                                                    </cc1:CalendarExtender>
                                                    <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_fine_group" ControlToValidate="dtIns_fine_group"
                                                        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                        ValidationGroup="ValidGroup">
                                                    </asp:RegularExpressionValidator>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Ordinamento" SortExpression="ordinamento">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelOrdinamento" runat="server" Text='<%# Bind("ordinamento") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="TextBoxOrdinamento" runat="server" Text='<%# Bind("ordinamento") %>'
                                                        MaxLength='50' Width="50px">
                                                    </asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="RequiredFieldValidatorTextBoxOrdinamento" ControlToValidate="TextBoxOrdinamento"
                                                        runat="server" ErrorMessage="Ammessi solo valori numerici." Display="Dynamic"
                                                        ValidationExpression="^\d*$" ValidationGroup="ValidGroup">
                                                    </asp:RegularExpressionValidator>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:TextBox ID="TextBoxOrdinamento" runat="server" Text='<%# Bind("ordinamento") %>'
                                                        MaxLength='50' Width="50px">
                                                    </asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="RequiredFieldValidatorTextBoxOrdinamento" ControlToValidate="TextBoxOrdinamento"
                                                        runat="server" ErrorMessage="Ammessi solo valori numerici." Display="Dynamic"
                                                        ValidationExpression="^\d*$" ValidationGroup="ValidGroup">
                                                    </asp:RegularExpressionValidator>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>

                                            <%--                                            <asp:CheckBoxField DataField="vis_serv_comm" HeaderText="Visibile al Servizio Commissione?"
                                                SortExpression="vis_serv_comm" />
                                            --%>
                                            <asp:TemplateField HeaderText="Visibile al Servizio Commissione?">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="check_vis_serv_comm" Enabled="false" runat="server" Checked='<%# Eval("vis_serv_comm") %>' />
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:CheckBox ID="check_vis_serv_comm" runat="server" Checked='<%# Bind("vis_serv_comm") %>' />
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:CheckBox ID="check_vis_serv_comm" runat="server" Checked='<%# Bind("vis_serv_comm") %>' />
                                                </EditItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Comitato ristretto">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="check_comitato_ristretto" Enabled="false" runat="server" Checked='<%# Eval("comitato_ristretto") %>' />
                                                    <asp:Label ID="label_id_commissione" runat="server" Font-Bold="true" Style="margin: 0px 2px 0px 30px;"
                                                        Text="Commissione" Visible='<%# (Eval("comitato_ristretto") != null) && (Eval("comitato_ristretto").ToString() == "True") %>'>
                                                    </asp:Label>
                                                    <asp:Label ID="label1" Visible='<%# (Eval("comitato_ristretto") != null) && (Eval("comitato_ristretto").ToString() == "True") %>'
                                                        runat="server" Text='<%# Eval("nome_commissione") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:CheckBox ID="check_comitato_ristretto" runat="server" Checked='<%# Bind("comitato_ristretto") %>' />
                                                    <asp:Label ID="label_id_commissione" runat="server" Text='Commissione' Font-Bold="true"
                                                        Style="margin: 0px 2px 0px 30px;">
                                                    </asp:Label>
                                                    <asp:DropDownList ID="dd_idcommissione" runat="server" Width="300px" Style="margin: 0px;"
                                                        DataSourceID="SqlDataSource3" DataTextField="nome_organo" DataValueField="id_organo">
                                                    </asp:DropDownList>
                                                    <%--						                <asp:TextBox ID="tx_nome_commissione"
						                           runat="server" 
						                           Width="300px"
						                           Enabled="false" style="margin-right:0px;"
						                           Text='<%# Eval("nome_commissione") %>'>
						                </asp:TextBox>--%>
                                                    <asp:HiddenField ID="hid_id_commissione" runat="server" Value='<%# Bind("id_commissione") %>' />
                                                    <br />
                                                    <asp:CustomValidator ID="validateComRistr_Ins" runat="server" OnServerValidate="idComm_ServerValidate"
                                                        Display="Dynamic" ValidationGroup="ValidGroup" ErrorMessage="Selezionare la commissione di appartenenza" />
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:CheckBox ID="check_comitato_ristretto" runat="server" Checked='<%# Bind("comitato_ristretto") %>' />
                                                    <asp:Label ID="label_id_commissione" runat="server" Text='Commissione' Font-Bold="true"
                                                        Style="margin: 0px 2px 0px 30px;">
                                                    </asp:Label>
                                                    <asp:DropDownList ID="dd_idcommissione" runat="server" Width="300px" Style="margin: 0px;"
                                                        DataSourceID="SqlDataSource3" DataTextField="nome_organo" DataValueField="id_organo">
                                                    </asp:DropDownList>
                                                    <%--						                <asp:TextBox ID="tx_nome_commissione"
						                           runat="server" 
						                           Width="300px"
						                           Enabled="false" style="margin-right:0px;"
						                           Text='<%# Eval("nome_commissione") %>'>
						                </asp:TextBox> --%>
                                                    <asp:HiddenField ID="hid_id_commissione" runat="server" Value='<%# Bind("id_commissione") %>' />
                                                    <br />
                                                    <asp:CustomValidator ID="validateComRistr_Ins" runat="server" OnServerValidate="idComm_ServerValidate"
                                                        Display="Dynamic" ValidationGroup="ValidGroup" ErrorMessage="Selezionare la commissione di appartenenza" />
                                                </EditItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Tipo Organo" SortExpression="tipo_organo_descrizione">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelTipoOrgano" runat="server" Text='<%# Bind("tipo_organo_descrizione") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:DropDownList ID="dd_idtipoorgano" runat="server" Width="300px" Style="margin: 0px;" AppendDataBoundItems="true"
                                                        DataSourceID="SqlDataSource4" DataTextField="descrizione" DataValueField="id" SelectedValue='<%# Bind("id_tipo_organo") %>'>
                                                        <asp:ListItem Value="" Text="[Seleziona]"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:DropDownList ID="dd_idtipoorgano" runat="server" Width="300px" Style="margin: 0px;"
                                                        DataSourceID="SqlDataSource4" DataTextField="descrizione" DataValueField="id">
                                                    </asp:DropDownList>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Categoria Organo" SortExpression="categoria_organo_descrizione">
                                                <ItemTemplate>
                                                    <asp:Label ID="LabelCategoriaOrgano" runat="server" Text='<%# Bind("categoria_organo") %>'>
                                                    </asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:DropDownList ID="dd_idcategoriaorgano" runat="server" Width="300px" Style="margin: 0px;" AppendDataBoundItems="true"
                                                        DataSourceID="SqlDataSource5" DataTextField="categoria_organo" DataValueField="id_categoria_organo" SelectedValue='<%# Bind("id_categoria_organo") %>'>
                                                        <asp:ListItem Value="" Text="[Seleziona]"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:DropDownList ID="dd_idcategoriaorgano" runat="server" Width="300px" Style="margin: 0px;"
                                                        DataSourceID="SqlDataSource5" DataTextField="categoria_organo" DataValueField="id_categoria_organo">
                                                    </asp:DropDownList>
                                                </InsertItemTemplate>
                                            </asp:TemplateField>

                                            <%--<asp:TemplateField HeaderText="[id_parent]" SortExpression="id_parent">
					        <ItemTemplate>
					            <asp:Label ID="LabelParent" runat="server" Text='<%# Bind("id_parent") %>'></asp:Label>
					        </ItemTemplate>
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxparent" runat="server" Text='<%# Bind("id_parent") %>'></asp:TextBox>
					            <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxparent" ControlToValidate="TextBoxparent"
						        runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						        ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxparent" runat="server" Text='<%# Bind("id_parent") %>'></asp:TextBox>
					            <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxparent" ControlToValidate="TextBoxparent"
						        runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
						        ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				            </asp:TemplateField>--%>

                                            <asp:TemplateField HeaderText="Foglio presenze dinamico">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chk_foglio_pres_dinamico" Enabled="false" runat="server" Checked='<%# Eval("foglio_pres_dinamico") %>' />
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:CheckBox ID="chk_foglio_pres_dinamico" runat="server" Checked='<%# Bind("foglio_pres_dinamico") %>' />
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:CheckBox ID="chk_foglio_pres_dinamico" runat="server" Checked='<%# Bind("foglio_pres_dinamico") %>' />
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Considera assenze Presidenti Gruppi">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chk_assenze_presidenti" Enabled="false" runat="server" Checked='<%# Eval("assenze_presidenti") %>' />
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:CheckBox ID="chk_assenze_presidenti" runat="server" Checked='<%# Bind("assenze_presidenti") %>' />
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:CheckBox ID="chk_assenze_presidenti" runat="server" Checked='<%# Bind("assenze_presidenti") %>' />
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            
                                            <asp:TemplateField HeaderText="Abilita Commissione Prioritaria">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chk_commissione_prioritaria" Enabled="false" runat="server" Checked='<%# Eval("abilita_commissioni_priorita") %>' />
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:CheckBox ID="chk_commissione_prioritaria" runat="server" Checked='<%# Bind("abilita_commissioni_priorita") %>' />
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:CheckBox ID="chk_commissione_prioritaria" runat="server" Checked='<%# Bind("abilita_commissioni_priorita") %>' />
                                                </EditItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Utilizza Foglio Presenze in Uscita">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chk_utilizza_foglio_presenze_in_uscita" Enabled="false" runat="server" Checked='<%# Eval("utilizza_foglio_presenze_in_uscita") %>' />
                                                </ItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:CheckBox ID="chk_utilizza_foglio_presenze_in_uscita" runat="server" Checked='<%# Bind("utilizza_foglio_presenze_in_uscita") %>' />
                                                </InsertItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:CheckBox ID="chk_utilizza_foglio_presenze_in_uscita" runat="server" Checked='<%# Bind("utilizza_foglio_presenze_in_uscita") %>' />
                                                </EditItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField ShowHeader="False">
                                                <EditItemTemplate>
                                                    <asp:Button ID="Button1" runat="server" ValidationGroup="ValidGroup" CommandName="Update"
                                                        Text="Aggiorna" />
                                                    <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
                                                        Text="Annulla" />
                                                </EditItemTemplate>
                                                <InsertItemTemplate>
                                                    <asp:Button ID="Button1" runat="server" ValidationGroup="ValidGroup" CommandName="Insert"
                                                        Text="Inserisci" />
                                                    <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
                                                        Text="Annulla" OnClick="ButtonAnnulla_Click" />
                                                </InsertItemTemplate>
                                                <ItemTemplate>
                                                    <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
                                                        Text="Modifica" Visible='<%# (role <= 2 || (role == 4 && Eval("comitato_ristretto").ToString() == "True")) ? true : false %>' />
                                                    <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
                                                        Text="Elimina" Visible='<%# (role <= 2 || (role == 4 && Eval("comitato_ristretto").ToString() == "True")) ? true : false %>' OnClientClick="return confirm ('Procedere con l\'eliminazione?\n\nEliminare un organo comporterà l\'eliminazione automatica di tutti i dati ad esso relativi, comprese le sedute.');" />
                                                </ItemTemplate>
                                                <ControlStyle CssClass="button" />
                                            </asp:TemplateField>
                                        </Fields>
                                    </asp:DetailsView>
                                </td>
                                <td>
                                    <div align="center">
                                        <img src="<%= logoName %>" alt="Logo" align="middle" height="150" width="150" />
                                    </div>
                                    <br />
                                    <br />
                                    <asp:Panel ID="PanelFoto" runat="server" align="center">
                                        <asp:FileUpload ID="FileUpload1" runat="server" Width="200px" Height="22px" />
                                        <br />
                                        <div align="center">
                                            <span style="font-size: smaller;">Estensioni consentite: JPG. Dimensione massima: 100k
                                            </span>
                                            <br />
                                            <asp:Button CssClass="button" ID="Button_Carica" runat="server" OnClick="Carica_Click"
                                                Text="Carica" CausesValidation="false" />
                                        </div>
                                    </asp:Panel>
                                </td>
                            </tr>
                        </table>
                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            DeleteCommand="UPDATE organi 
			                               SET deleted = 1 
			                               WHERE id_organo = @id_organo"

                            InsertCommand="INSERT INTO organi (id_legislatura, 
			                                                      nome_organo, 
			                                                      data_inizio, 
			                                                      data_fine, 
			                                                      id_parent,				                                                        
			                                                      vis_serv_comm,
			                                                      ordinamento,
			                                                      comitato_ristretto,
			                                                      id_commissione,
																  id_tipo_organo,
                                                                  foglio_pres_dinamico,
                                                                  assenze_presidenti,
                                                                  nome_organo_breve,
                                                                  abilita_commissioni_priorita,
                                                                  utilizza_foglio_presenze_in_uscita,
                                                                  id_categoria_organo) 
			                                  VALUES (@id_legislatura, 
			                                          @nome_organo, 
			                                          @data_inizio, 
			                                          @data_fine, 
			                                          @id_parent,
			                                          @vis_serv_comm,
			                                          @ordinamento,
			                                          @comitato_ristretto,
			                                          @id_commissione,
													  @id_tipo_organo,
                                                      @foglio_pres_dinamico,
                                                      @assenze_presidenti,
                                                      @nome_organo_breve,
                                                      @abilita_commissioni_priorita,
                                                      @utilizza_foglio_presenze_in_uscita,
                                                      @id_categoria_organo); 
			                                  SELECT @id_organo = SCOPE_IDENTITY();"

                            SelectCommand="SELECT 
	                                            ll.num_legislatura
                                               ,oo.id_organo
                                               ,oo.id_legislatura
                                               ,oo.nome_organo
                                               ,oo.data_inizio
                                               ,oo.data_fine
                                               ,oo.id_parent
                                               ,oo.deleted
                                               ,oo.logo
                                               ,oo.Logo2
                                               ,oo.vis_serv_comm
                                               ,oo.senza_opz_diaria
                                               ,oo.ordinamento
                                               ,ISNULL(oo.comitato_ristretto, 0) AS comitato_ristretto
                                               ,oo.id_commissione
                                               ,cc.nome_organo AS nome_commissione
                                               ,oo.id_tipo_organo
                                               ,dbo.tipo_organo.descrizione AS tipo_organo_descrizione
                                               ,oo.id_categoria_organo 
                                               ,dbo.tbl_categoria_organo.categoria_organo     
                                               ,ISNULL(oo.foglio_pres_dinamico, 0) AS foglio_pres_dinamico
                                               ,ISNULL(oo.assenze_presidenti, 0) AS assenze_presidenti
                                               ,oo.nome_organo_breve
                                               ,oo.abilita_commissioni_priorita
                                               ,oo.utilizza_foglio_presenze_in_uscita
                                            FROM dbo.organi AS oo 
                                            INNER JOIN dbo.legislature AS ll 
	                                            ON oo.id_legislatura = ll.id_legislatura 
                                            LEFT OUTER JOIN dbo.tipo_organo 
	                                            ON oo.id_tipo_organo = dbo.tipo_organo.id 
                                            LEFT OUTER JOIN dbo.organi AS cc 
	                                            ON dbo.tipo_organo.id = cc.id_tipo_organo AND cc.id_organo = oo.id_commissione
                                            LEFT OUTER JOIN dbo.tbl_categoria_organo 
	                                            ON oo.id_categoria_organo = dbo.tbl_categoria_organo.id_categoria_organo
                                            WHERE oo.id_organo = @id_organo"

                            UpdateCommand="UPDATE organi 
			                                  SET id_legislatura = @id_legislatura, 
			                                      nome_organo = @nome_organo, 
			                                      data_inizio = @data_inizio, 
			                                      data_fine = @data_fine, 
			                                      id_parent = @id_parent,
			                                      vis_serv_comm = @vis_serv_comm,
			                                      ordinamento = @ordinamento,
			                                      comitato_ristretto = @comitato_ristretto,
			                                      id_commissione = @id_commissione,
												  id_tipo_organo = @id_tipo_organo,
                                                  id_categoria_organo = @id_categoria_organo,
                                                  foglio_pres_dinamico = @foglio_pres_dinamico,
                                                  assenze_presidenti = @assenze_presidenti,
                                                  nome_organo_breve = @nome_organo_breve,
                                                  abilita_commissioni_priorita = @abilita_commissioni_priorita,
                                                  utilizza_foglio_presenze_in_uscita = @utilizza_foglio_presenze_in_uscita
			                                  WHERE id_organo = @id_organo"

                            OnInserted="SqlDataSource1_Inserted"
                            OnUpdated="SqlDataSource1_Updated"
                            OnDeleted="SqlDataSource1_Deleted">
                            <SelectParameters>
                                <asp:SessionParameter Name="id_organo" SessionField="id_organo" Type="Int32" />
                            </SelectParameters>
                            <DeleteParameters>
                                <asp:Parameter Name="id_organo" Type="Int32" />
                            </DeleteParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="id_legislatura" Type="Int32" />
                                <asp:Parameter Name="nome_organo" Type="String" />
                                <asp:Parameter Name="data_inizio" Type="DateTime" />
                                <asp:Parameter Name="data_fine" Type="DateTime" />
                                <asp:Parameter Name="id_parent" Type="Int32" />
                                <asp:Parameter Name="vis_serv_comm" Type="Boolean" />
                                <asp:Parameter Name="ordinamento" Type="Int32" />
                                <asp:Parameter Name="comitato_ristretto" Type="Boolean" />
                                <asp:Parameter Name="id_commissione" Type="Int32" />
                                <asp:Parameter Name="id_tipo_organo" Type="Int32" />
                                <asp:Parameter Name="id_organo" Type="Int32" />
                                <asp:Parameter Name="nome_organo_breve" Type="String" />
                                <asp:Parameter Name="abilita_commissioni_priorita" Type="Boolean" />
                                <asp:Parameter Name="utilizza_foglio_presenze_in_uscita" Type="Boolean" />
                                
                            </UpdateParameters>
                            <InsertParameters>
                                <asp:Parameter Name="id_legislatura" Type="Int32" />
                                <asp:Parameter Name="nome_organo" Type="String" />
                                <asp:Parameter Name="data_inizio" Type="DateTime" />
                                <asp:Parameter Name="data_fine" Type="DateTime" />
                                <asp:Parameter Name="id_parent" Type="Int32" />
                                <asp:Parameter Name="vis_serv_comm" Type="Boolean" />
                                <asp:Parameter Name="ordinamento" Type="Int32" />
                                <asp:Parameter Name="comitato_ristretto" Type="Boolean" />
                                <asp:Parameter Name="id_commissione" Type="Int32" />
                                <asp:Parameter Name="id_tipo_organo" Type="Int32" />
                                <asp:Parameter Name="nome_organo_breve" Type="String" />
                                <asp:Parameter Name="abilita_commissioni_priorita" Type="Boolean" />
                                <asp:Parameter Name="utilizza_foglio_presenze_in_uscita" Type="Boolean" />
                                <asp:Parameter Direction="Output" Name="id_organo" Type="Int32" />
                            </InsertParameters>
                        </asp:SqlDataSource>
                        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            SelectCommand="SELECT num_legislatura, 
			                                         id_legislatura 
			                                  FROM legislature
			                                  ORDER BY durata_legislatura_da DESC"></asp:SqlDataSource>
                        <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            SelectCommand="select null as id_organo, '' as nome_organo
			                                   union
			                                  select id_organo, nome_organo from organi 
                                              where nome_organo like '%commissione%'
                                              and id_legislatura = @id_legislatura
                                              order by nome_organo">
                            <SelectParameters>
                                <asp:SessionParameter Name="id_legislatura" Type="Int32" SessionField="id_organo_leg" />
                            </SelectParameters>
                        </asp:SqlDataSource>

                        <asp:SqlDataSource ID="SqlDataSource4" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            SelectCommand="SELECT id, 
			                                      descrizione
			                                  FROM tipo_organo
			                                  ORDER BY descrizione"></asp:SqlDataSource>

                        <asp:SqlDataSource ID="SqlDataSource5" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                            SelectCommand="SELECT id_categoria_organo, 
			                                      categoria_organo
			                                  FROM tbl_categoria_organo
			                                  ORDER BY categoria_organo"></asp:SqlDataSource>

                        <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
                        </asp:ScriptManager>
                        <br />
                        <div align="right">
                            <asp:LinkButton ID="LinkButtonExcelDetails" runat="server" OnClick="LinkButtonExcelDetails_Click">
		            <img src="../img/page_white_excel.png" alt="" align="top" /> 
		            Esporta
                            </asp:LinkButton>
                            -
                            <asp:LinkButton ID="LinkButtonPdfDetails" runat="server" OnClick="LinkButtonPdfDetails_Click">
		            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		            Esporta
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td>&nbsp;
            </td>
        </tr>
        <tr>
            <td align="right">
                <b><a id="a_back" runat="server" href="../organi/gestisciOrgani.aspx">« Indietro </a>
                </b>
            </td>
        </tr>
        <tr>
            <td>&nbsp;
            </td>
        </tr>
    </table>
</asp:Content>
