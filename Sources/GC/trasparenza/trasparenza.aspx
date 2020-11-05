<%@ Page Language="C#"
    MasterPageFile="~/MasterPage.master"
    AutoEventWireup="true"
    CodeFile="trasparenza.aspx.cs"
    Inherits="trasparenza"
    Title="Persona > Trasparenza" %>

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
                                        <asp:Label ID="LabelHeadNome"
                                            runat="server"
                                            Text='<%# Eval("nome_completo") %>'>
                                        </asp:Label>
                                    </span>

                                    <br />

                                    <asp:Label ID="LabelHeadDataNascita"
                                        runat="server"
                                        Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>'>
                                    </asp:Label>

                                    <asp:Label ID="LabelHeadGruppo"
                                        runat="server"
                                        Font-Bold="true"
                                        Text='<%# Eval("nome_gruppo") %>'>
                                    </asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                </asp:DataList>

                <asp:SqlDataSource ID="SqlDataSourceHead"
                    runat="server"
                    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                    SelectCommand="SELECT pp.nome + ' ' + pp.cognome AS nome_completo, 
                                             pp.data_nascita, 
                                             '(' + COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO') + ')' AS nome_gruppo 
			                          FROM persona AS pp 
			                          LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp 
			                             ON (pp.id_persona = jpgp.id_persona 
			                                 AND (jpgp.data_fine IS NULL OR jpgp.data_fine &gt;= GETDATE()) 
			                                 AND (jpgp.deleted = 0 OR jpgp.deleted IS NULL))
			                          LEFT OUTER JOIN gruppi_politici AS gg 
			                             ON jpgp.id_gruppo = gg.id_gruppo 
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
                        <asp:ScriptManager runat="server" ID="ScriptManager"></asp:ScriptManager>

                        <div style="font-weight: bold;">
                            Dichiarazione redditi e situazione patrimoniale 
                        </div>
                        <br />
                        <table>
                            <tr>
                                <td valign="top" width="230">
				                    Legislatura:
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
				                                                      ORDER BY durata_legislatura_da DESC" >
				                    </asp:SqlDataSource>




				                </td>

                                <td>
                                    Tipo Documento:

				                    <asp:DropDownList ID="DropDownTipo_Doc_Trasparenza" 
                                                      AutoPostBack="true"
				                                      runat="server" 
				                                      DataSourceID="SqlDataSourceTipo_Doc_Trasparenza"
					                                  DataTextField="descrizione" 
					                                  DataValueField="id_tipo_doc_trasparenza" 
					                                  Width="350px"
					                                  AppendDataBoundItems="True"
                                                      OnSelectedIndexChanged="DropDownTipo_Doc_Trasparenza_Change">
					                    <asp:ListItem Text="(tutte)" Value="" />
				                    </asp:DropDownList>
				    
				                    <asp:SqlDataSource ID="SqlDataSourceTipo_Doc_Trasparenza" 
				                                       runat="server" 
				                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                  
					                                   SelectCommand="SELECT * 
				                                                      FROM Tipo_Doc_Trasparenza
				                                                      ORDER BY id_tipo_doc_trasparenza" >
				                    </asp:SqlDataSource>



                                </td>
                                <td>
                                    <asp:Label ID="LabelConsenso" 
                                                       runat="server" 
                                                       Text="Mancato Consenso"
                                                       visible="false" />

                                    <asp:CheckBox ID="chkbox_consenso" 
                                            runat="server" 
                                            AutoPostBack="true"
                                            visible="false"
                                            OnCheckedChanged="chkbox_consenso_OnCheckedChanged" />
                                </td>
                            </tr>

                        </table>


                        <div>
                            <% if (canEdit)
                            { %>
                                <div style="padding:10px;">
                                    <asp:Label ID="LabelFile" 
                                                       runat="server" 
                                                       Text="File"
                                                       visible="true" />

                                    <asp:FileUpload ID="uploadFileAllegatoDichRedditi" 
                                            EnableViewState="true"
                                        runat="server" BackColor="#BBEEBB" Width="400"
                                        visible="true" />

                                    <span style="margin-left:10px; margin-right:10px;">
                                        Anno: <asp:TextBox ID="txAnno" runat="server"></asp:TextBox>
                                    </span>
                                    
                                    <asp:Button ID="cmdNewAllegatoDichRedditi"
                                        runat="server"
                                        Text="Aggiungi"
                                        OnClick="cmdNewAllegatoDichRedditi_Click"
                                        CssClass="button"
                                        EnableViewState="false"
                                        CausesValidation="true" />
                                </div>
                                <div style="padding:0px 10px 10px 40px;">
                                    <table>
                                        <tr>
                                            <td style="width:420px;">
                                                <asp:CustomValidator runat="server" ID="FileDichRedditiValidator"
                                                     Display="Dynamic" EnableViewState="true"
                                                     ValidateEmptyText="true"
                                                     ControlToValidate="uploadFileAllegatoDichRedditi"
                                                     ErrorMessage="File non valido, sono ammessi solo PDF."
                                                     OnServerValidate="FileDichRedditiValidator_ServerValidate" />
                                            </td>

                                            <td style="margin-left:10px; margin-right:10px;">
                                                <asp:RegularExpressionValidator ID="RegularExpressionValidatorAnno" 
                                                    ControlToValidate="txAnno"
							                        runat="server" Display="Dynamic" ErrorMessage="Anno non valido" 
                                                    ValidationExpression="^[0-9]{4}$" />

						                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorAnno"
                                                        ControlToValidate="txAnno"
							                            runat="server" Display="Dynamic" ErrorMessage="Indicare l'anno della dichiarazione." />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp</td>
                                            <td style="margin-left:10px; margin-right:10px;">
						                        <asp:RequiredFieldValidator ID="RequiredFieldLegislatura"
                                                        ControlToValidate="DropDownListLegislatura"
							                            runat="server" Display="Dynamic" ErrorMessage="Selezionare la legislatura." />      
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp</td>
                                            <td style="margin-left:10px; margin-right:10px;">
						                        <asp:RequiredFieldValidator ID="RequiredFieldTipo_Doc_Trasparenza"
                                                        ControlToValidate="DropDownTipo_Doc_Trasparenza"
							                            runat="server" Display="Dynamic" ErrorMessage="Selezionare il tipo documento." />
                                            </td>
                                        </tr>

                                    </table>
                                </div>
                            <% } %>  
                            
                            <asp:GridView ID="GridAllegati" runat="server"
                                        CssClass="tab_gen"
                                        DataSourceID="SqlDataSourceALL"
                                        DataKeyNames="id_rec"
                                        AutoGenerateColumns="false" 
                                        AllowPaging="false"
                                        AllowSorting="false"> 

                                 <AlternatingRowStyle BackColor="#b2cca7" />	
                                <Columns>

                                    <asp:BoundField DataField="id_legislatura" Visible="false" />
                                    <asp:BoundField DataField="num_legislatura" HeaderText="Legislatura" />
                                    <asp:BoundField DataField="id_tipo_doc_trasparenza" Visible="false" />
                                    <asp:BoundField DataField="tipo_documento" HeaderText="Tipo Documento" />
                                    <asp:BoundField DataField="Anno" HeaderText="Anno" />

                                    <asp:TemplateField HeaderText="Dichiarazione">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server"
                                                Text='<%# Eval("dich_redditi_filename") %>'
                                                Font-Bold="true"
                                                OnClientClick='<%# getDichRedditiURL(Eval("dich_redditi_filename"), Eval("anno"), Eval("id_legislatura"), Eval("id_tipo_doc_trasparenza") ) %>'>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="b_mancato_consenso" HeaderText="Mancato Consenso" />
                                    
                                    <asp:TemplateField HeaderText="">
                                        <ItemStyle HorizontalAlign="Center" />
                                        <ItemTemplate>
                                            <% if (canEdit)
                                                { %>
                                            &#160;&#160;
                                            <asp:LinkButton
                                                runat="server"
                                                Text="Elimina"
                                                CssClass="button"
                                                CausesValidation="false"
                                                ValidationGroup='<%# Eval("anno") + ";" + Eval("id_legislatura")  + ";" + Eval("id_tipo_doc_trasparenza")  %>'
                                                OnClientClick="return confirm('Confermare la cancellazione del file?');"
                                                OnClick="cmdDeleteAllegatoDichRedditi_Click" />
                                            <% } %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                                      
                            </asp:GridView>                       

                            <asp:SqlDataSource ID="SqlDataSourceALL"
                                runat="server"
                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                SelectCommand="select a.*, b.num_legislatura, c.descrizione tipo_documento, case when a.mancato_consenso = 1 then 'S' else null end b_mancato_consenso
                                                from [dbo].[join_persona_trasparenza] a
                                                LEFT OUTER JOIN [dbo].[legislature] b on a.id_legislatura = b.id_legislatura
                                                LEFT OUTER JOIN [dbo].[tipo_doc_trasparenza] c on a.id_tipo_doc_trasparenza = c.id_tipo_doc_trasparenza
                                                where id_persona = @id
                                                order by Anno desc">
                                <SelectParameters>
                                    <asp:SessionParameter Name="id" SessionField="id_persona" />
                                </SelectParameters>
                            </asp:SqlDataSource>
                        </div>

                        <br />
                        <br />

                        <div style="font-weight: bold;display:none" >
                            Altri cariche / incarichi 
                        </div>
                        <br />

                        <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional" Visible="false">
                            <ContentTemplate>
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
                                                    <% if (canEdit)
                                                       { %>
                                                    <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
                                                        CausesValidation="false" />
                                                    <% } %>
                                                </th>
                                            </tr>
                                        </table>
                                    </EmptyDataTemplate>
                                     <AlternatingRowStyle BackColor="#b2cca7" />	
                                    <Columns>
                                        <asp:BoundField DataField="incarico"
                                            HeaderText="Incarico"
                                            SortExpression="incarico"
                                            ItemStyle-HorizontalAlign="left"
                                            ItemStyle-Width="250px" />

                                        <asp:BoundField DataField="ente"
                                            HeaderText="Ente"
                                            SortExpression="ente"
                                            ItemStyle-HorizontalAlign="left"
                                            ItemStyle-Width="250px" />

                                        <asp:BoundField DataField="periodo"
                                            HeaderText="Periodo"
                                            SortExpression="periodo"
                                            ItemStyle-HorizontalAlign="left"
                                            ItemStyle-Width="150px" />

                                        <asp:BoundField DataField="compenso_desc"
                                            HeaderText="Compenso"
                                            SortExpression="compenso"
                                            ItemStyle-HorizontalAlign="Center"
                                            ItemStyle-Width="120px" />

                                        <asp:BoundField DataField="note"
                                            HeaderText="Note"
                                            SortExpression="note"
                                            ItemStyle-HorizontalAlign="left"
                                            ItemStyle-Width="250px" />

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
                                                <% if (role <= 2 || role == 8)
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
                                    SelectCommand="select *
                                                    ,case when [compenso] is null then ''
	                                                else '€ ' + convert(varchar, [compenso], 1)
	                                                end as compenso_desc

                                                    from [dbo].[join_persona_trasparenza_incarichi]
                                                    where [id_persona] = @id">
                                    <SelectParameters>
                                        <asp:SessionParameter Name="id" SessionField="id_persona" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <br />

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
                                <h3>ALTRI CARICHE/INCARICHI
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
                                            OnItemDeleted="DetailsView1_ItemDeleted"
                                            OnItemInserted="DetailsView1_ItemInserted"
                                            OnItemUpdated="DetailsView1_ItemUpdated">
                                            <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
                                            <RowStyle HorizontalAlign="left" />
                                            <HeaderStyle Font-Bold="False" />

                                            <Fields>
                                                <asp:TemplateField HeaderText="Incarico" SortExpression="incarico">
                                                    <EditItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxIncarico"
                                                            runat="server"
                                                            Text='<%# Bind("incarico") %>'>
                                                        </asp:TextBox>
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxIncarico"
                                                            runat="server"
                                                            Text='<%# Bind("incarico") %>'>
                                                        </asp:TextBox>
                                                    </InsertItemTemplate>

                                                    <ItemTemplate>
                                                        <asp:Label ID="LbIncarico"
                                                            runat="server"
                                                            Text='<%# Bind("incarico") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Ente" SortExpression="ente">
                                                    <EditItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxEnte"
                                                            runat="server"
                                                            Text='<%# Bind("ente") %>'>
                                                        </asp:TextBox>
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxEnte"
                                                            runat="server"
                                                            Text='<%# Bind("ente") %>'>
                                                        </asp:TextBox>
                                                    </InsertItemTemplate>

                                                    <ItemTemplate>
                                                        <asp:Label ID="LbEnte"
                                                            runat="server"
                                                            Text='<%# Bind("ente") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Periodo" SortExpression="periodo">
                                                    <EditItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxPeriodo"
                                                            runat="server"
                                                            Text='<%# Bind("periodo") %>'>
                                                        </asp:TextBox>
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxPeriodo"
                                                            runat="server"
                                                            Text='<%# Bind("periodo") %>'>
                                                        </asp:TextBox>
                                                    </InsertItemTemplate>

                                                    <ItemTemplate>
                                                        <asp:Label ID="LbPeriodo"
                                                            runat="server"
                                                            Text='<%# Bind("periodo") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>


                                                <asp:TemplateField HeaderText="Compenso" SortExpression="compenso">
                                                    <EditItemTemplate>
                                                        <asp:TextBox
                                                            ID="TxtCompensoEdit"
                                                            runat="server"
                                                            Text='<%# Bind("compenso") %>'>
                                                        </asp:TextBox>

                                                        <asp:RegularExpressionValidator ID="RegexValid_Compenso_Edit"
                                                            ControlToValidate="TxtCompensoEdit"
                                                            runat="server"
                                                            Display="Dynamic"
                                                            ErrorMessage="Immettere un importo valido"
                                                            ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$">
                                                        </asp:RegularExpressionValidator>
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox
                                                            ID="TxtCompensoInsert"
                                                            runat="server"
                                                            Text='<%# Bind("compenso") %>'>
                                                        </asp:TextBox>

                                                        <asp:RegularExpressionValidator ID="RegexValid_Compenso_Insert"
                                                            ControlToValidate="TxtCompensoInsert"
                                                            runat="server"
                                                            Display="Dynamic"
                                                            ErrorMessage="Immettere un importo valido"
                                                            ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$">
                                                        </asp:RegularExpressionValidator>
                                                    </InsertItemTemplate>

                                                    <ItemTemplate>
                                                        <asp:Label ID="LabelCompenso"
                                                            runat="server"
                                                            Text='<%# Bind("compenso_desc") %>'>
                                                        </asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Note" SortExpression="note">
                                                    <EditItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxNote"
                                                            runat="server"
                                                            Text='<%# Bind("note") %>'>
                                                        </asp:TextBox>
                                                    </EditItemTemplate>

                                                    <InsertItemTemplate>
                                                        <asp:TextBox TextMode="MultiLine"
                                                            Rows="3"
                                                            Columns="22"
                                                            ID="TxNote"
                                                            runat="server"
                                                            Text='<%# Bind("note") %>'>
                                                        </asp:TextBox>
                                                    </InsertItemTemplate>

                                                    <ItemTemplate>
                                                        <asp:Label ID="LbNote"
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
                                                            Text="Modifica" Visible="<%# canEdit ? true : false %>" />
                                                        <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
                                                            Text="Elimina" Visible="<%# canEdit ? true : false %>" />
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
                                            DeleteCommand="DELETE [join_persona_trasparenza_incarichi] 
				                                      WHERE [id_REC] = @id_REC"
                                            InsertCommand="INSERT INTO [join_persona_trasparenza_incarichi]
                                                                   ([id_persona]
                                                                   ,[incarico]
                                                                   ,[ente]
                                                                   ,[periodo]
                                                                   ,[compenso]
                                                                   ,[note])
                                                             VALUES
                                                                   (@id_persona
                                                                   ,@incarico
                                                                   ,@ente
                                                                   ,@periodo
                                                                   ,@compenso
                                                                   ,@note)
                                                SELECT @id_rec = SCOPE_IDENTITY();"
                                            SelectCommand="select * 
                                                    ,case when [compenso] is null then ''
	                                                else '€ ' + convert(varchar, [compenso], 1)
	                                                end as compenso_desc

                                                    from [dbo].[join_persona_trasparenza_incarichi]
                                                    where [id_rec] = @id_rec"
                                            UpdateCommand="UPDATE [dbo].[join_persona_trasparenza_incarichi]
                                                   SET [id_persona] = @id_persona
                                                      ,[incarico] = @incarico
                                                      ,[ente] = @ente
                                                      ,[periodo] = @periodo
                                                      ,[compenso] = @compenso
                                                      ,[note] = @note
                                                 WHERE [id_rec] = @id_rec">

                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="GridView1" Name="id_rec" PropertyName="SelectedValue"
                                                    Type="Int32" />
                                            </SelectParameters>

                                            <DeleteParameters>
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </DeleteParameters>

                                            <UpdateParameters>
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                                <asp:SessionParameter Name="id_persona" SessionField="id_persona" />
                                                <asp:Parameter Name="incarico" Type="String" />
                                                <asp:Parameter Name="ente" Type="String" />
                                                <asp:Parameter Name="periodo" Type="String" />
                                                <asp:Parameter Name="compenso" Type="Decimal" />
                                                <asp:Parameter Name="note" Type="String" />
                                            </UpdateParameters>

                                            <InsertParameters>
                                                <asp:SessionParameter Name="id_persona" SessionField="id_persona" />
                                                <asp:Parameter Name="incarico" Type="String" />
                                                <asp:Parameter Name="ente" Type="String" />
                                                <asp:Parameter Name="periodo" Type="String" />
                                                <asp:Parameter Name="compenso" Type="Decimal" />
                                                <asp:Parameter Name="note" Type="String" />
                                                <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                                            </InsertParameters>
                                        </asp:SqlDataSource>
                                    </ContentTemplate>
                                </asp:UpdatePanel>

                            </div>
                            <br />

                            <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails"
                                runat="server"
                                BehaviorID="ModalPopup1"
                                PopupControlID="PanelDetails"
                                BackgroundCssClass="modalBackground"
                                DropShadow="true"
                                TargetControlID="ButtonDetailsFake">
                            </cc1:ModalPopupExtender>

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
                        href="../persona/persona.aspx">« Indietro
                    </a>
                </b>
            </td>
        </tr>

        <tr>
            <td>&nbsp;
            </td>
        </tr>
    </table>
</asp:Content>
