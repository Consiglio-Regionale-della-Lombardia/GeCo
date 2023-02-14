<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         CodeFile="dettaglio.aspx.cs" 
         Inherits="dettaglio" 
         Title="Persona > Anagrafica" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
    <Services>
        <asp:ServiceReference Path="~/ricerca_comuni.asmx" />
    </Services>
</asp:ScriptManager>
    
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
        &nbsp;
    </td>
</tr>

<tr>
    <td>
        <asp:DataList ID="DataList1" 
                      runat="server" 
                      DataSourceID="SqlDataSource5" 
                      Width="50%">
            <ItemTemplate>
                <span style="font-size: 1.5em; font-weight: bold; color: #50B306;">
                    <asp:Label ID="LabelHeadNome" 
                               runat="server" 
                               Text='<%# Eval("nome_completo") %>' >
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
                
            </ItemTemplate>
        </asp:DataList>
        
        <asp:SqlDataSource ID="SqlDataSource5" 
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
                                          WHERE pp.deleted = 0 and pp.chiuso = 0
                                            AND pp.id_persona = @id_persona">
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

                <asp:Panel ID="PanelChiusura" 
                    runat="server" 
                    Width="1000px" 
                    BackColor="White" 
                    BorderColor="DarkSeaGreen"
                    BorderWidth="2px"
                    Visible="false"
                    Style="position: absolute; left: 0; right: 0; margin-left: auto; margin-right: auto;">

                    <div align="center">
                        <br />
                                    
                        <h3>CHIUSURA</h3>
                        <br />

                            <p>Seleziona la motivazione della chiusura</p>
                        <asp:DropDownList runat="server" ID="chiusuraCausaFine">

                        </asp:DropDownList>

                            <br />

                        <p>Seleziona la data della chiusura</p>
                            <asp:DropDownList runat="server" ID="chiusuraGiorni">

                        </asp:DropDownList>

                        <asp:DropDownList runat="server" ID="chiusuraMesi">
                            <asp:ListItem Text="Seleziona un mese" Value="0" />
                            <asp:ListItem Text="Gennaio" Value="01" />
                            <asp:ListItem Text="Febbraio" Value="02" />
                            <asp:ListItem Text="Marzo" Value="03" />
                            <asp:ListItem Text="Aprile" Value="04" />
                            <asp:ListItem Text="Maggio" Value="05" />
                            <asp:ListItem Text="Giugno" Value="06" />
                            <asp:ListItem Text="Luglio" Value="07" />
                            <asp:ListItem Text="Agosto" Value="08" />
                            <asp:ListItem Text="Settembre" Value="09" />
                            <asp:ListItem Text="Ottobre" Value="10" />
                            <asp:ListItem Text="Novembre" Value="11" />
                            <asp:ListItem Text="Dicembre" Value="12" />
                        </asp:DropDownList>

                        <asp:DropDownList runat="server" ID="chiusuraAnni">

                        </asp:DropDownList>

                            <br />
                        <br />
                        <asp:Label ID="labelChiusuraError" 
                                                       runat="server"  
                                                       ForeColor="Red"
                            Text="Prima di proseguire è necessario compilare tutti i campi"
                                                       Visible="false">
                                            </asp:Label>
                        <br />
                            <br />

                            <asp:Button ID="Button3" 
                                        runat="server" 
                                        CausesValidation="False" 
                                        Text="Conferma" 
                                        OnClientClick="return confirm ('Confermare la chiusura?');"
                                        OnClick="ButtonConfirmChiusura_Click"/>
                                    
                        <br />
                    </div>

                    <div align="center">
                        <br />
                        <asp:Button ID="ButtonChiudiChiusura" OnClick="ButtonCloseChiusura_Click" runat="server" Text="Chiudi" CssClass="button" />
                        <br />
                        <br />
                    </div>
                                
                </asp:Panel>

                <table width="100%" cellspacing="5" cellpadding="10">
                    <tr>
                        <td class="singleborder" valign="top" width="75%">
                            <asp:DetailsView Width="100%" 
                                             ID="DetailsView1" 
                                             runat="server" 
                                             AutoGenerateRows="False"
                                             DataKeyNames="id_persona" 
                                             DataSourceID="SqlDataSource1" 
                                             Font-Bold="False" 
                                             CellPadding="5"
                                             GridLines="None" 
                                             
                                             OnModeChanging="DetailsView1_ModeChanging" 
                                             OnItemDeleted="DetailsView1_ItemDeleted"
                                             OnItemUpdating="DetailsView1_ItemUpdating" 
                                             OnItemInserting="DetailsView1_ItemInserting"
                                             OnItemUpdated="DetailsView1_ItemUpdated" >
                                
                                <Fields>
                                    <asp:TemplateField HeaderText="Nome" SortExpression="nome">
                                        <EditItemTemplate>
                                            <asp:TextBox ID="TextBoxNome" 
                                                         MaxLength="50" 
                                                         runat="server" 
                                                         Text='<%# Bind("nome") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorName" 
                                                                        ControlToValidate="TextBoxNome"
                                                                        Display="Dynamic" 
                                                                        runat="server" 
                                                                        ErrorMessage="Campo obbligatorio.">
                                            </asp:RequiredFieldValidator>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:TextBox ID="TextBoxNome" 
                                                         MaxLength="50" 
                                                         runat="server" 
                                                         Text='<%# Bind("nome") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorName" 
                                                                        ControlToValidate="TextBoxNome"
                                                                        Display="Dynamic" 
                                                                        runat="server" 
                                                                        ErrorMessage="Campo obbligatorio.">
                                            </asp:RequiredFieldValidator>
                                            
                                            <asp:Label ID="lbl_insert_error" 
                                                       runat="server"  
                                                       ForeColor="Red"
                                                       Visible="false" >
                                            </asp:Label>
                                        </InsertItemTemplate>
                                        
                                        <ItemTemplate>
                                            <asp:Label ID="LabelNome" 
                                                       runat="server" 
                                                       Text='<%# Bind("nome") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Cognome" SortExpression="cognome">
                                        <EditItemTemplate>
                                            <asp:TextBox ID="TextBoxCognome" 
                                                         runat="server" 
                                                         MaxLength="50" 
                                                         Text='<%# Bind("cognome") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorCognome" 
                                                                        ControlToValidate="TextBoxCognome"
                                                                        Display="Dynamic" 
                                                                        runat="server" 
                                                                        ErrorMessage="Campo obbligatorio.">
                                            </asp:RequiredFieldValidator>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExprValidatorCognome" 
                                                                            ControlToValidate="TextBoxCognome"
                                                                            runat="server" 
                                                                            ErrorMessage="Formato non valido." 
                                                                            Display="Dynamic" 
                                                                            ValidationExpression="^[a-zA-Z\u00E0\u00E8\u00EC\u00F2\u00F9\u0027\s]+$">
                                            </asp:RegularExpressionValidator>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:TextBox ID="TextBoxCognome" 
                                                         runat="server" 
                                                         MaxLength="50" 
                                                         Text='<%# Bind("cognome") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorCognome" 
                                                                        ControlToValidate="TextBoxCognome"
                                                                        Display="Dynamic" 
                                                                        runat="server" 
                                                                        ErrorMessage="Campo obbligatorio.">
                                            </asp:RequiredFieldValidator>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExprValidatorCognome" 
                                                                            ControlToValidate="TextBoxCognome"
                                                                            runat="server" 
                                                                            ErrorMessage="Formato non valido." 
                                                                            Display="Dynamic" 
                                                                            ValidationExpression="^[a-zA-Z\u00E0\u00E8\u00EC\u00F2\u00F9\u0027\s]+$">
                                            </asp:RegularExpressionValidator>
                                        </InsertItemTemplate>
                                        
                                        <ItemTemplate>
                                            <asp:Label ID="LabelCognome" 
                                                       runat="server" 
                                                       Text='<%# Bind("cognome") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Sesso" SortExpression="sesso">
                                        <ItemTemplate>
                                            <asp:Label ID="LabelSesso" 
                                                       runat="server" 
                                                       Text='<%# Bind("sesso") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                        
                                        <EditItemTemplate>
                                            <asp:RadioButtonList ID="RadioButtonList1" 
                                                                 runat="Server" 
                                                                 SelectedValue='<%# Bind("sesso") %>'>
                                                <asp:ListItem Value="M" Text="M" Selected="True" />
                                                <asp:ListItem Value="F" Text="F" />
                                            </asp:RadioButtonList>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:RadioButtonList ID="RadioButtonList2" 
                                                                 runat="Server" 
                                                                 SelectedValue='<%# Bind("sesso") %>'>
                                                <asp:ListItem Value="M" Text="M" Selected="True" />
                                                <asp:ListItem Value="F" Text="F" />
                                            </asp:RadioButtonList>
                                        </InsertItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Nato/a il" SortExpression="data_nascita">
                                        <ItemTemplate>
                                            <asp:Label ID="LabelDataNascita" 
                                                       runat="server" 
                                                       Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                        
                                        <EditItemTemplate>
                                            <asp:TextBox ID="TextBoxDataNascitaEdit" 
                                                         runat="server" 
                                                         MaxLength="10" 
                                                         Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>'>
                                            </asp:TextBox>
                                            
                                            <img id="ImageDataNascitaEdit" 
                                                 runat="server"
                                                 alt="calendar" 
                                                 src="../img/calendar_month.png" />
                                            
                                            <cc1:CalendarExtender ID="CalendarExtenderDataNascitaEdit" 
                                                                  runat="server" 
                                                                  TargetControlID="TextBoxDataNascitaEdit"
                                                                  PopupButtonID="ImageDataNascitaEdit" 
                                                                  Format="dd/MM/yyyy">
                                            </cc1:CalendarExtender>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorNascita" 
                                                                            ControlToValidate="TextBoxDataNascitaEdit"
                                                                            runat="server" 
                                                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
                                                                            Display="Dynamic"
                                                                            ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))">
                                            </asp:RegularExpressionValidator>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:TextBox ID="TextBoxDataNascitaInsert" 
                                                         MaxLength="10" 
                                                         runat="server">
                                            </asp:TextBox>
                                            
                                            <img id="ImageDataNascitaInsert" 
                                                 runat="server"
                                                 alt="calendar" 
                                                 src="../img/calendar_month.png" />
                                            
                                            <cc1:CalendarExtender ID="CalendarExtender1" 
                                                                  runat="server" 
                                                                  TargetControlID="TextBoxDataNascitaInsert"
                                                                  PopupButtonID="ImageDataNascitaInsert" 
                                                                  Format="dd/MM/yyyy">
                                            </cc1:CalendarExtender>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorNascita" 
                                                                            ControlToValidate="TextBoxDataNascitaInsert"
                                                                            runat="server" 
                                                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
                                                                            Display="Dynamic"
                                                                            ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))">
                                            </asp:RegularExpressionValidator>
                                        </InsertItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Nato/a a">
                                        <ItemTemplate>
                                            <asp:Label ID="label_comune" 
                                                       runat="server" 
                                                       Text='<%# Eval("nome_comune") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:HiddenField ID="TextBoxComuneNascitaId" runat="server" Value='<%# Bind("id_comune") %>'></asp:HiddenField>
                                            <asp:TextBox ID="TextBoxComuneNascita" 
                                                         runat="server" 
                                                         Text='<%# Eval("nome_comune") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorComune" 
                                                                            runat="server"
                                                                            ControlToValidate="TextBoxComuneNascita" 
                                                                            ErrorMessage="Formato non valido."
                                                                            Display="Dynamic" 
                                                                            ValidationExpression="^[A-Za-z'\*\s\-]+\([A-Za-z]{2}\)$">
                                            </asp:RegularExpressionValidator>
                                            
                                            <div id="DivComuneNascitaInsert">
                                            </div>
                                            
                                            <cc1:AutoCompleteExtender ID="AutoCompleteExtenderComuneNascitaInsert" 
                                                                      runat="server"
                                                                      EnableCaching="True" 
                                                                      TargetControlID="TextBoxComuneNascita" 
                                                                      ServicePath="~/ricerca_comuni.asmx"
                                                                      ServiceMethod="RicercaComuni" 
                                                                      MinimumPrefixLength="1" 
                                                                      CompletionInterval="0"
                                                                      CompletionListElementID="DivComuneNascitaInsert" 
                                                                      CompletionSetCount="15"  
                                                                      OnClientItemSelected="autoCompleteComuneNascitaSelected">
                                                <Animations>
				                                    <OnShow>
					                                    <Sequence>
					                                        <OpacityAction Opacity='0'></OpacityAction>
					                                        <HideAction Visible='true'></HideAction>
					                                        <StyleAction Attribute='fontSize' Value='8pt'></StyleAction>
					                                        <Parallel Duration='.15'>
						                                        <FadeIn></FadeIn>
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
                                        </InsertItemTemplate>
                                        
                                        <EditItemTemplate>
                                           <asp:HiddenField ID="TextBoxComuneNascitaId" runat="server" Value='<%# Bind("id_comune") %>'></asp:HiddenField>
                                            <asp:TextBox ID="TextBoxComuneNascita" 
                                                         runat="server" 
                                                         Text='<%# Eval("nome_comune") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorComune" 
                                                                            runat="server"
                                                                            ControlToValidate="TextBoxComuneNascita" 
                                                                            ErrorMessage="Formato non valido."
                                                                            Display="Dynamic" 
                                                                            ValidationExpression="^[A-Za-z'\*\s\-]+\([A-Za-z]{2}\)$">
                                            </asp:RegularExpressionValidator>
                                            
                                            <div id="DivComuneNascitaEdit">
                                            </div>
                                            
                                            <cc1:AutoCompleteExtender ID="AutoCompleteExtenderComuneNascitaEdit" 
                                                                      runat="server"
                                                                      EnableCaching="True" 
                                                                      TargetControlID="TextBoxComuneNascita" 
                                                                      ServicePath="~/ricerca_comuni.asmx"
                                                                      ServiceMethod="RicercaComuni" 
                                                                      MinimumPrefixLength="1" 
                                                                      CompletionInterval="0"
                                                                      CompletionListElementID="DivComuneNascitaEdit" 
                                                                      CompletionSetCount="15"  
                                                                      OnClientItemSelected="autoCompleteComuneNascitaSelected">
                                                <Animations>
				                                    <OnShow>
					                                    <Sequence>
					                                        <OpacityAction Opacity='0'></OpacityAction>
					                                        <HideAction Visible='true'></HideAction>
					                                        <StyleAction Attribute='fontSize' Value='8pt'></StyleAction>
					                                        <Parallel Duration='.15'>
						                                        <FadeIn></FadeIn>
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
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Codice Fiscale" SortExpression="codice_fiscale">
                                        <ItemTemplate>
                                            <asp:Label ID="LabelCF" 
                                                       runat="server"
                                                       Text='<%# Bind("codice_fiscale") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                        
                                        <EditItemTemplate>
                                            <asp:TextBox ID="TextBoxCF"
                                                         runat="server" 
                                                         MaxLength="16" 
                                                         Text='<%# Bind("codice_fiscale") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorCF" 
                                                                            ControlToValidate="TextBoxCF"
                                                                            ErrorMessage="Formato non valido." 
                                                                            runat="server" 
                                                                            Display="Dynamic" 
                                                                            ValidationExpression="^[A-Za-z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$">
                                            </asp:RegularExpressionValidator>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:TextBox ID="TextBoxCF" 
                                                         runat="server" 
                                                         MaxLength="16" 
                                                         Text='<%# Bind("codice_fiscale") %>'>
                                            </asp:TextBox>
                                            
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidatorCF" 
                                                                            ControlToValidate="TextBoxCF"
                                                                            ErrorMessage="Formato non valido." 
                                                                            runat="server" 
                                                                            Display="Dynamic" 
                                                                            ValidationExpression="^[A-Za-z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$">
                                            </asp:RegularExpressionValidator>
                                        </InsertItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Numero Tessera" SortExpression="numero_tessera">
                                        <EditItemTemplate>
                                            <asp:TextBox ID="TextBoxNT" 
                                                         MaxLength="20" 
                                                         runat="server" 
                                                         Text='<%# Bind("numero_tessera") %>'>
                                            </asp:TextBox>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:TextBox ID="TextBoxNT" 
                                                         MaxLength="20" 
                                                         runat="server"
                                                         Text='<%# Bind("numero_tessera") %>'
                                                Value='<%#newCardNumber%>'>
                                            </asp:TextBox>
                                        </InsertItemTemplate>
                                        
                                        <ItemTemplate>
                                            <asp:Label ID="LabelNT" 
                                                       runat="server" 
                                                       Text='<%# Bind("numero_tessera") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Professione" SortExpression="professione">
                                        <EditItemTemplate>
                                            <asp:TextBox ID="TextBoxProf" 
                                                         runat="server" 
                                                         MaxLength="50" 
                                                         Text='<%# Bind("professione") %>'>
                                            </asp:TextBox>
                                        </EditItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:TextBox ID="TextBoxProf" 
                                                         runat="server" 
                                                         MaxLength="50" 
                                                         Text='<%# Bind("professione") %>'>
                                            </asp:TextBox>
                                        </InsertItemTemplate>
                                        
                                        <ItemTemplate>
                                            <asp:Label ID="LabelProf" 
                                                       runat="server" 
                                                       Text='<%# Bind("professione") %>'>
                                            </asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Supplente?">
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkbox_supplente_item" 
                                                          runat="server" 
                                                          Checked='<%# Convert.ToBoolean(Eval("supplente")) %>' 
                                                          Enabled="false" />
                                        </ItemTemplate>
                                        
                                        <InsertItemTemplate>
                                            <asp:CheckBox ID="chkbox_supplente_insert" 
                                                          runat="server" />
                                        </InsertItemTemplate>
                                        
                                        <EditItemTemplate>
                                            <asp:CheckBox ID="chkbox_supplente_edit" 
                                                          runat="server"
                                                          Checked='<%# Convert.ToBoolean(Eval("supplente")) %>'
                                                          Enabled="false" />
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField ShowHeader="False">
                                        <EditItemTemplate>
                                            <asp:Button ID="Button1" 
                                                        runat="server" 
                                                        CausesValidation="True" 
                                                        CommandName="Update"
                                                        Text="Aggiorna" />
                                                        
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
                                                        Text="Inserisci" />
                                                
                                            <asp:Button ID="Button2" 
                                                        runat="server" 
                                                        CausesValidation="False" 
                                                        CommandName="Cancel"
                                                        Text="Annulla" 
                                                        OnClick="ButtonAnnulla_Click" />
                                        </InsertItemTemplate>
                                        
                                        <ItemTemplate>
                                            <asp:Button ID="Button1" 
                                                        runat="server" 
                                                        CausesValidation="False" 
                                                        CommandName="Edit"
                                                        Text="Modifica" 
                                                        Visible="<%# (role <= 2) ? true : false %>" />

                                            <asp:Button ID="ButtonChiusura" 
                                                        runat="server" 
                                                        CausesValidation="False" 
                                                        CommandName="Close"
                                                        Text="Chiusura" 
                                                        Visible="<%# (role <= 2) ? true : false %>"
                                                        OnClick="ButtonChiusura_Click" />
                                                
                                            <asp:Button ID="Button3" 
                                                        runat="server" 
                                                        CausesValidation="False" 
                                                        CommandName="Delete"
                                                        Text="Elimina" 
                                                        Visible="<%# (role <= 2) ? true : false %>" 
                                                        OnClientClick="return confirm ('Eliminare il consigliere? Questo eliminerà anche tutti i record a lui associati.');" />
                                        </ItemTemplate>
                                        <ControlStyle CssClass="button" />
                                    </asp:TemplateField>
                                </Fields>
                                
                                <FieldHeaderStyle Width="150px" Font-Bold="true" />
                                <HeaderStyle Font-Bold="False" />

                            </asp:DetailsView>

                            <br />
                            
                            <div align="right">
                                <asp:LinkButton ID="LinkButtonExcelDetails" 
                                                runat="server" 
                                                OnClick="LinkButtonExcelDetails_Click">
		                            <img src="../img/page_white_excel.png" alt="" align="top" /> 
		                            Esporta
                                </asp:LinkButton>
                                -
                                <asp:LinkButton ID="LinkButtonPdfDetails" 
                                                runat="server" 
                                                OnClick="LinkButtonPdfDetails_Click">
		                            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		                            Stampa Tessera
                                </asp:LinkButton>
                            </div>
                            
                            <asp:SqlDataSource ID="SqlDataSource1" 
                                               runat="server" 
                                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                               
                                               DeleteCommand="UPDATE persona 
		                                                      SET deleted = 1 
		                                                      WHERE id_persona = @id_persona" 
		                                      
		                                       InsertCommand="INSERT INTO persona (codice_fiscale, 
		                                                                           numero_tessera, 
		                                                                           cognome, 
		                                                                           nome, 
		                                                                           data_nascita, 
		                                                                           id_comune_nascita, 
		                                                                           sesso, 
		                                                                           professione) 
		                                                      VALUES (@codice_fiscale, 
		                                                              @numero_tessera, 
		                                                              @cognome, 
		                                                              @nome, 
		                                                              @data_nascita, 
		                                                              @id_comune_nascita, 
		                                                              @sesso, 
		                                                              @professione); 
		                                                      SELECT @id_persona = SCOPE_IDENTITY();" 
		                                      
		                                      SelectCommand="SELECT pp.*, 
		                                                            cmn.comune + ' (' + cmn.provincia + ')' AS nome_comune,
                                                                    cmn.id_comune as id_comune,
		                                                            CASE cc.id_tipo_carica
		                                                              WHEN 5 --'consigliere regionale supplente'
                                                                            THEN 'true'
		                                                              ELSE 'false'
		                                                            END AS supplente 
		                                                     FROM persona AS pp 
		                                                     INNER JOIN join_persona_organo_carica AS jpoc
		                                                        ON pp.id_persona = jpoc.id_persona
		                                                     INNER JOIN cariche AS cc
		                                                        ON jpoc.id_carica = cc.id_carica
		                                                     INNER JOIN organi AS oo
		                                                        ON jpoc.id_organo = oo.id_organo 
		                                                     INNER JOIN legislature AS ll
                                                                ON jpoc.id_legislatura = ll.id_legislatura
		                                                     LEFT OUTER JOIN tbl_comuni AS cmn 
		                                                        ON pp.id_comune_nascita = cmn.id_comune 
		                                                     WHERE pp.deleted = 0 and pp.chiuso = 0
		                                                       AND jpoc.deleted = 0
		                                                       AND oo.deleted = 0
                                                               AND oo.id_categoria_organo = 1 -- Consiglio Regionale 
		                                                       AND (cc.id_tipo_carica = 4 --'consigliere regionale' 
                                                                    OR cc.id_tipo_carica = 5 --'consigliere regionale supplente'
                                                                    )
		                                                       AND pp.id_persona = @id_persona
		                                                       AND ll.id_legislatura = @id_legislatura" 
		                                      
		                                      UpdateCommand="UPDATE persona 
		                                                     SET codice_fiscale = @codice_fiscale, 
		                                                         numero_tessera = @numero_tessera, 
		                                                         cognome = @cognome, 
		                                                         nome = @nome, 
		                                                         data_nascita = @data_nascita, 
		                                                         id_comune_nascita = @id_comune_nascita, 
		                                                         sesso = @sesso, 
		                                                         professione = @professione
		                                                     WHERE id_persona = @id_persona" 
		                                      
		                                      OnInserted="SqlDataSource1_Inserted"
                                              OnUpdated="SqlDataSource1_Updated"
                                              OnDeleted="SqlDataSource1_Deleted"
                                              >
                                <SelectParameters>
                                    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                    <%--<asp:SessionParameter Name="id_legislatura" SessionField="id_legislatura" Type="Int32" />--%>
                                    <asp:SessionParameter Name="id_legislatura" SessionField="sel_leg_id" Type="Int32" />
                                </SelectParameters>
                                
                                <DeleteParameters>
                                    <asp:Parameter Name="id_persona" Type="Int32" />
                                </DeleteParameters>
                                
                                <UpdateParameters>
                                    <asp:Parameter Name="codice_fiscale" Type="String" />
                                    <asp:Parameter Name="numero_tessera" Type="String" />
                                    <asp:Parameter Name="cognome" Type="String" />
                                    <asp:Parameter Name="nome" Type="String" />
                                    <asp:Parameter Name="data_nascita" Type="DateTime" />
                                    <asp:Parameter Name="id_comune_nascita" Type="String" />
                                    <asp:Parameter Name="sesso" Type="String" />
                                    <asp:Parameter Name="professione" Type="String" />
                                    <asp:Parameter Name="foto" Type="String" />
                                    <asp:Parameter Name="id_persona" Type="Int32" />
                                </UpdateParameters>
                                
                                <InsertParameters>
                                    <asp:Parameter Name="codice_fiscale" Type="String" />
                                    <asp:Parameter Name="numero_tessera" Type="String" />
                                    <asp:Parameter Name="cognome" Type="String" />
                                    <asp:Parameter Name="nome" Type="String" />
                                    <asp:Parameter Name="data_nascita" Type="DateTime" />
                                    <asp:Parameter Name="id_comune_nascita" Type="String" />
                                    <asp:Parameter Name="sesso" Type="String" />
                                    <asp:Parameter Name="professione" Type="String" />
                                    <asp:Parameter Name="foto" Type="String" />
                                    <asp:Parameter Direction="Output" Name="id_persona" Type="Int32" />
                                </InsertParameters>
                            </asp:SqlDataSource>
                            
                            <br />
                            
                            <asp:Panel ID="PanelGestione" runat="server">
                                <table width="100%" cellpadding="10" class="singleborder">
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel ID="UpdatePanelDataListResidenze" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DataList ID="DataListResidenze" runat="server" DataSourceID="SqlDataSourceResidenzaAttuale">
                                                        <HeaderTemplate>
                                                            <b>Residenza attuale:</b>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:Label ID="Label11" runat="server" Text='<%# Eval("indirizzo") %>' />
                                                        </ItemTemplate>
                                                    </asp:DataList>
                                                    <asp:SqlDataSource ID="SqlDataSourceResidenzaAttuale" 
                                                                       runat="server" 
                                                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                      
                                                                       SelectCommand="SELECT top 1 (jj.indirizzo_residenza + ', ' +  cc.comune + ' (' + cc.provincia + ')') AS indirizzo
							                                                          FROM join_persona_residenza jj 
							                                                          INNER JOIN tbl_comuni cc 
							                                                            ON jj.id_comune_residenza = cc.id_comune
							                                                          WHERE jj.id_persona = @id_persona
							                                                            AND jj.residenza_attuale = 1 and jj.data_a is null ">
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                                        </SelectParameters>
                                                    </asp:SqlDataSource>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                        <% if (role <= 2)
                                           { %>
                                        <td width="250">
                                            <asp:Button ID="ButtonResidenze" runat="server" Text="Gestisci residenze..." Width="250px" />
                                        </td>
                                        <% } %>
                                    </tr>
                                </table>
                                <br />
                                <table width="100%" cellpadding="10" class="singleborder">
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel ID="UpdatePanelDataListRecapiti" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DataList ID="DataListEmail" runat="server" DataSourceID="SqlDataSourceListaEmail">
                                                        <HeaderTemplate>
                                                            <b>Email:</b>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <b>
                                                                <asp:HyperLink ID="HyperLinkEmail" 
                                                                               runat="server" 
                                                                               NavigateUrl='<%# Eval("recapito", "mailto:{0}") %>'
                                                                               Text='<%# Eval("recapito") %>' >
                                                                </asp:HyperLink>
                                                            </b>
                                                        </ItemTemplate>
                                                    </asp:DataList>
                                                    <asp:SqlDataSource ID="SqlDataSourceListaEmail" 
                                                                       runat="server" 
                                                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                       
                                                                       SelectCommand="SELECT jj.recapito, 
					                                                                         rr.nome_recapito
					                                                                  FROM join_persona_recapiti AS jj 
					                                                                  INNER JOIN tbl_recapiti AS rr 
					                                                                    ON jj.tipo_recapito = rr.id_recapito
							                                                          WHERE jj.id_persona = @id_persona 
							                                                            AND rr.id_recapito = 'E1'">
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                                        </SelectParameters>
                                                    </asp:SqlDataSource>
                                                    <br />
                                                    <asp:DataList ID="DataListRecapiti" runat="server" DataSourceID="SqlDataSourceListaRecapiti">
                                                        <HeaderTemplate>
                                                            <b>Recapiti:</b>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <b>
                                                                <asp:Hyperlink style='<%# Eval("tipo_recapito").ToString() == "U1" ? "" : "display:none" %>'
                                                                    runat="server" Target="_blank" NavigateUrl='<%# Eval("recapito") %>'><%# Eval("recapito") %></asp:Hyperlink>
                                                                <asp:Label style='<%# Eval("tipo_recapito").ToString() == "U1" ? "display:none" : "" %>'
                                                                    ID="LabelRecapito" runat="server" Text='<%# Eval("recapito") %>'>
                                                                </asp:Label>
                                                            </b>
                                                            <asp:Label ID="LabelNomeRecapito" runat="server" Text='<%# Eval("nome_recapito") %>'>
                                                            </asp:Label>
                                                        </ItemTemplate>
                                                    </asp:DataList>
                                                    <asp:SqlDataSource ID="SqlDataSourceListaRecapiti" 
                                                                       runat="server" 
                                                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                       
                                                                       SelectCommand="SELECT jj.recapito, 
					                                                                         rr.id_recapito, 
					                                                                         '(' + LTRIM(RTRIM(rr.nome_recapito)) + ')' AS nome_recapito
                                                                                        ,jj.tipo_recapito
					                                                                  FROM join_persona_recapiti AS jj 
					                                                                  INNER JOIN tbl_recapiti AS rr 
					                                                                    ON jj.tipo_recapito = rr.id_recapito
							                                                          WHERE jj.id_persona = @id_persona 
							                                                            AND rr.id_recapito != 'E1'">
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                                        </SelectParameters>
                                                    </asp:SqlDataSource>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                        <% if (role <= 2)
                                           { %>
                                        <td width="250">
                                            <asp:Button ID="ButtonRecapiti" runat="server" Text="Gestisci recapiti..." Width="250px" />
                                        </td>
                                        <% } %>
                                    </tr>
                                </table>
                                <br />
                                <table width="100%" cellpadding="10" class="singleborder">
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel ID="UpdatePanelDataListTitoliStudio" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DataList ID="DataListTitoliStudio" runat="server" DataSourceID="SqlDataSourceTitoloStudioAttuale">
                                                        <HeaderTemplate>
                                                            <b>Titolo di studio:</b>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:Label ID="Label33" runat="server" Text='<%# Eval("titolo") %>'>
                                                            </asp:Label>
                                                        </ItemTemplate>
                                                    </asp:DataList>
                                                    <asp:SqlDataSource ID="SqlDataSourceTitoloStudioAttuale" 
                                                                       runat="server" 
                                                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                                       
                                                                       SelectCommand="SELECT TOP 1 tt.descrizione_titolo_studio + ' (' + jj.note + ')' AS titolo
					                                                                  FROM tbl_titoli_studio tt 
					                                                                  INNER JOIN join_persona_titoli_studio jj 
					                                                                    ON tt.id_titolo_studio = jj.id_titolo_studio
					                                                                  WHERE id_persona = @id_persona 
					                                                                  ORDER BY jj.anno_conseguimento DESC">
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                                        </SelectParameters>
                                                    </asp:SqlDataSource>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                        <% if (role <= 2)
                                           { %>
                                        <td width="250">
                                            <asp:Button ID="ButtonTitoliStudio" runat="server" Text="Gestisci titoli di studio..."
                                                Width="250px" />
                                        </td>
                                        <% } %>
                                    </tr>
                                </table>
                                
                                <br />
                                
                                <div class="singleborder" style="padding: 10px;">
                                    <asp:DataList ID="DataListLegislature" runat="server" DataSourceID="SqlDataSourceLegislature">
                                        <HeaderTemplate>
                                            <b>Legislature di cui ha fatto parte:</b>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <b>
                                                <asp:HyperLink ID="HyperLink1" 
                                                               runat="server" 
                                                               NavigateUrl='<%# Eval("id_legislatura", "~/legislature/dettaglio.aspx?id={0}") %>'
                                                               Text='<%# Eval("legislatura") %>'>
                                                </asp:HyperLink>
                                            </b>
                                        </ItemTemplate>
                                    </asp:DataList>
                                    
                                    <asp:SqlDataSource ID="SqlDataSourceLegislature" 
                                                       runat="server" 
                                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                       
                                                       SelectCommand="SELECT DISTINCT ll.id_legislatura, 
			                                                                          ll.num_legislatura AS legislatura
					                                                  FROM join_persona_organo_carica AS jpoc 
					                                                  INNER JOIN legislature AS ll 
					                                                    ON jpoc.id_legislatura = ll.id_legislatura
					                                                  WHERE jpoc.deleted = 0
					                                                    AND id_persona = @id_persona" >
                                        <SelectParameters>
                                            <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                        </SelectParameters>
                                    </asp:SqlDataSource>
                                </div>
                            </asp:Panel>
                        </td>
                        
                        <td align="center" valign="top">
                            <div align="center">
                                <img src="<%= photoName %>?idFoto=<%= DateTime.Now %>" align="middle" width="150"
                                    style="border:solid 1px #99cc99;"
                                    height="150" alt="Foto" />
                            </div>
                            
                            <br />
                            <br />
                            
                            <asp:Panel ID="PanelFoto" runat="server" align="center">
                                <asp:FileUpload ID="FileUpload1" runat="server" Width="200px" Height="22px" />
                                <br />
                                <div align="center">
                                    <span style="font-size: smaller;">
                                        Estensioni consentite: JPG. Dimensione massima: 100k
                                    </span>
                                    
                                    <br />
                                    
                                    <asp:Button ID="Button_Carica" 
                                                runat="server" 
                                                CssClass="button" 
                                                Text="Carica" 
                                                CausesValidation="false"
                                                OnClick="Carica_Click" />
                                        
                                    <br />
                                    
                                    <asp:Button ID="btn_delete_photo" 
                                                runat="server" 
                                                CssClass="button" 
                                                Text="Elimina"
                                                CausesValidation="false" 
                                                OnClientClick="return confirm ('Procedere con l\'eliminazione?');"
                                                OnClick="btn_delete_photo_Click" />
                                </div>
                            </asp:Panel>
                            
                            <asp:Image ID="ImageSospeso" 
                                       runat="server" 
                                       ImageUrl="~/img/information.png" 
                                       ImageAlign="top"
                                       Visible="false" />
                            
                            <asp:Label ID="LabelSospeso" 
                                       runat="server" 
                                       Text=" Il consigliere è attualmente sospeso."
                                       Font-Bold="true" 
                                       ForeColor="Red" 
                                       Visible="false">
                            </asp:Label>
                            
                            <br />
                            
                            <asp:Image ID="ImageSostituito" 
                                       runat="server" 
                                       ImageUrl="~/img/information.png" 
                                       ImageAlign="top"
                                       Visible="false" />
                            
                            <asp:Label ID="LabelSostituito" 
                                       runat="server"
                                       Font-Bold="true" 
                                       ForeColor="Red" 
                                       Visible="false">
                            </asp:Label>
                            
                            <br />
                            
                            <asp:Image ID="ImageSostituente" 
                                       runat="server" 
                                       ImageUrl="~/img/information.png"
                                       ImageAlign="top" 
                                       Visible="false" />
                                
                            <asp:Label ID="LabelSostituente" 
                                       runat="server"
                                       Font-Bold="true" 
                                       ForeColor="Red" 
                                       Visible="false">
                            </asp:Label>
                            
                            <br />
                            <br />
                            
                            <% if (role <= 2) { %>

                            <asp:Panel ID="PanelResidenze" 
                                       runat="server" 
                                       Width="1000px" 
                                       BackColor="White" 
                                       BorderColor="DarkSeaGreen"
                                       BorderWidth="2px" 
                                       Style="display: none;">
                                <div align="center">
                                    <br />
                                    
                                    <h3>GESTIONE RESIDENZE</h3>
                                    
                                    <br />
                                </div>
                                
                                <asp:UpdatePanel ID="UpdatePanelResidenze" runat="server">
                                    <ContentTemplate>
                                        <asp:ListView ID="ListViewResidenze" runat="server" DataKeyNames="id_rec" DataSourceID="SqlDataSourceResidenze"
                                            InsertItemPosition="LastItem" OnItemInserting="ListViewResidenze_ItemInserting"
                                            OnItemInserted="ListViewResidenze_ItemInserted" OnItemUpdating="ListViewResidenze_ItemUpdating"
                                            OnItemUpdated="ListViewResidenze_ItemUpdated" OnItemDeleted="ListViewResidenze_ItemDeleted">
                                            <LayoutTemplate>
                                                <table id="Table1" runat="server" width="95%">
                                                    <tr id="Tr1" runat="server">
                                                        <td id="Td1" runat="server">
                                                            <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
                                                                <tr id="Tr2" runat="server">
                                                                    <th id="Th1" runat="server">
                                                                        Indirizzo
                                                                    </th>
                                                                    <th id="Th2" runat="server">
                                                                        Comune
                                                                    </th>
                                                                    <th id="Th3" runat="server">
                                                                        Dal
                                                                    </th>
                                                                    <th id="Th4" runat="server">
                                                                        Al
                                                                    </th>
                                                                    <th id="Th5" runat="server">
                                                                        CAP
                                                                    </th>
                                                                    <th id="Th6" runat="server">
                                                                    </th>
                                                                </tr>
                                                                <tr id="itemPlaceholder" runat="server">
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr id="Tr3" runat="server">
                                                        <td id="Td2" runat="server" style="">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </LayoutTemplate>
                                            
                                            <InsertItemTemplate>
                                                <tr style="">
                                                    <td valign="top">
                                                        <asp:TextBox ID="indirizzo_residenzaTextBox" runat="server" Text='<%# Bind("indirizzo_residenza") %>'
                                                            Width="99%" MaxLength="100" />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorAddress" runat="server" ControlToValidate="indirizzo_residenzaTextBox"
                                                            ErrorMessage="Campo obbligatorio." Display="Dynamic" ValidationGroup="ResidenzeInsertGroup" />
                                                    </td>
                                                    <td width="150" valign="top">                                                        
                                                        <asp:HiddenField ID="TextBoxComuneResidenzaId" runat="server" Value='<%# Bind("id_comune") %>'></asp:HiddenField>
                                                        <asp:TextBox ID="TextBoxComuneResidenza" runat="server" Text='<%# Eval("nome_comune") %>' />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorComune" runat="server" ControlToValidate="TextBoxComuneResidenza"
                                                            ErrorMessage="Campo obbligatorio." Display="Dynamic" ValidationGroup="ResidenzeInsertGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionValidatorComune" runat="server"
                                                            ControlToValidate="TextBoxComuneResidenza" ErrorMessage="Formato non valido."
                                                            Display="Dynamic" ValidationExpression="^[A-Za-z'\*\s\-]+\([A-Za-z]{2}\)$" ValidationGroup="ResidenzeInsertGroup" />
                                                        <div id="DivComuneResidenzaInsert">
                                                        </div>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderComuneResidenzaInsert" runat="server"
                                                            EnableCaching="True" TargetControlID="TextBoxComuneResidenza" ServicePath="~/ricerca_comuni.asmx"
                                                            ServiceMethod="RicercaComuni" MinimumPrefixLength="1" CompletionInterval="0"
                                                            CompletionSetCount="15" CompletionListElementID="DivComuneResidenzaInsert" OnClientItemSelected="autoCompleteComuneResidenzaSelected">
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
                                                    </td>
                                                    
                                                    <td width="100" valign="top">
                                                        <asp:TextBox ID="dt_residenza_Dal" runat="server" Width="70px" />
                                                        <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dt_residenza_Dal"
                                                            PopupButtonID="Image1" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorResidenzaSince" runat="server"
                                                            ControlToValidate="dt_residenza_Dal" ErrorMessage="Campo obbligatorio." Display="Dynamic"
                                                            ValidationGroup="ResidenzeInsertGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionValidator_dt_residenza" ControlToValidate="dt_residenza_Dal"
                                                            runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                            ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                                            ValidationGroup="ResidenzeInsertGroup" />
                                                    </td>
                                                    
                                                    <td width="100" valign="top">
                                                        <asp:TextBox ID="dt_residenza_Al" runat="server" Width="70px" />
                                                        <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dt_residenza_Al"
                                                            PopupButtonID="Image2" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RequiredFieldValidatorResidenzaTo" ControlToValidate="dt_residenza_Al"
                                                            runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                            ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                                            ValidationGroup="ResidenzeInsertGroup" />
                                                    </td>
                                                    <td width="50" valign="top">
                                                        <asp:TextBox ID="capTextBox" runat="server" Text='<%# Bind("cap") %>' Width="50px"
                                                            MaxLength="5" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionValidatorCAP" ControlToValidate="capTextBox"
                                                            runat="server" Display="Dynamic" ErrorMessage="Formato non valido." ValidationExpression="^[0-9]{5}$"
                                                            ValidationGroup="ResidenzeInsertGroup" />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Inserisci"
                                                            CssClass="button" ValidationGroup="ResidenzeInsertGroup" />
                                                        <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancella"
                                                            CssClass="button" CausesValidation="false" />
                                                    </td>
                                                </tr>
                                            </InsertItemTemplate>
                                            <EditItemTemplate>
                                                <tr style="">
                                                    <td valign="top">
                                                        <asp:TextBox ID="indirizzo_residenzaTextBox" runat="server" Text='<%# Bind("indirizzo_residenza") %>'
                                                            Width="99%" MaxLength="100" />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorAddress" runat="server" ControlToValidate="indirizzo_residenzaTextBox"
                                                            ErrorMessage="Campo obbligatorio." Display="Dynamic" ValidationGroup="ResidenzeEditGroup" />
                                                    </td>
                                                    <td valign="top">
                                                        <asp:HiddenField ID="TextBoxComuneResidenzaId" runat="server" Value='<%# Bind("id_comune") %>'></asp:HiddenField>
                                                        <asp:TextBox ID="TextBoxComuneResidenza" runat="server" Text='<%# Eval("nome_comune") %>'>
                                                        </asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorComune" runat="server" ControlToValidate="TextBoxComuneResidenza"
                                                            ErrorMessage="Campo obbligatorio." Display="Dynamic" ValidationGroup="ResidenzeEditGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionValidatorComune" runat="server"
                                                            ControlToValidate="TextBoxComuneResidenza" ErrorMessage="Formato non valido."
                                                            Display="Dynamic" ValidationExpression="^[A-Za-z'\*\s\-]+\([A-Za-z]{2}\)$" ValidationGroup="ResidenzeEditGroup" />
                                                        <div id="DivComuneResidenzaEdit">
                                                        </div>
                                                        <cc1:AutoCompleteExtender ID="AutoCompleteExtenderComuneResidenzaEdit" runat="server"
                                                            EnableCaching="True" TargetControlID="TextBoxComuneResidenza" ServicePath="~/ricerca_comuni.asmx"
                                                            ServiceMethod="RicercaComuni" MinimumPrefixLength="1" CompletionInterval="0"
                                                            CompletionSetCount="15" CompletionListElementID="DivComuneResidenzaEdit" OnClientItemSelected="autoCompleteComuneResidenzaSelected">
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
                                                    </td>
                                                    <td valign="top">
                                                        <asp:TextBox ID="dt_residenzaMod_Dal" runat="server" Text='<%# Eval("data_da", "{0:dd/MM/yyyy}") %>'
                                                            Width="70px" MaxLength="10" />
                                                        <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dt_residenzaMod_Dal"
                                                            PopupButtonID="Image3" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDtResidenzaSince" runat="server"
                                                            ControlToValidate="dt_residenzaMod_Dal" ErrorMessage="Campo obbligatorio." Display="Dynamic"
                                                            ValidationGroup="ResidenzeEditGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDtResidenzaSince" ControlToValidate="dt_residenzaMod_Dal"
                                                            runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                            ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                                            ValidationGroup="ResidenzeEditGroup" />
                                                    </td>
                                                    <td valign="top">
                                                        <asp:TextBox ID="data_aTextBox" runat="server" Text='<%# Eval("data_a", "{0:dd/MM/yyyy}") %>'
                                                            Width="70px" MaxLength="10" />
                                                        <img alt="calendar" src="../img/calendar_month.png" id="Image4" runat="server" />
                                                        <cc1:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="data_aTextBox"
                                                            PopupButtonID="Image4" Format="dd/MM/yyyy">
                                                        </cc1:CalendarExtender>
                                                        <asp:RegularExpressionValidator ID="RegularExpressionDtResidenzaTo" ControlToValidate="data_aTextBox"
                                                            runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                                            ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                                            ValidationGroup="ResidenzeEditGroup" />
                                                    </td>
                                                    <td valign="top">
                                                        <asp:TextBox ID="capTextBox" runat="server" Text='<%# Bind("cap") %>' Width="50px"
                                                            MaxLength="5" />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorCAP" runat="server" ControlToValidate="capTextBox"
                                                            ErrorMessage="Campo obbligatorio." Display="Dynamic" ValidationGroup="ResidenzeEditGroup" />
                                                        <asp:RegularExpressionValidator ID="RegularExpressionValidatorCAP" ControlToValidate="capTextBox"
                                                            runat="server" Display="Dynamic" ErrorMessage="Formato non valido." ValidationExpression="^[0-9]{5}$"
                                                            ValidationGroup="ResidenzeEditGroup" />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="UpdateButton" runat="server" CommandName="Update" Text="Aggiorna"
                                                            CssClass="button" ValidationGroup="ResidenzeEditGroup" />
                                                        <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Annulla"
                                                            CssClass="button" CausesValidation="false" />
                                                    </td>
                                                </tr>
                                            </EditItemTemplate>
                                            <ItemTemplate>
                                                <tr style="">
                                                    <td>
                                                        <asp:Label ID="indirizzo_residenzaLabel" runat="server" Text='<%# Eval("indirizzo_residenza") %>' />
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="id_comune_residenzaLabel" runat="server" Text='<%# Eval("nome_comune") %>' />
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="data_daLabel" runat="server" Text='<%# Eval("data_da", "{0:dd/MM/yyyy}") %>' />
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="data_aLabel" runat="server" Text='<%# Eval("data_a", "{0:dd/MM/yyyy}") %>' />
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="capLabel" runat="server" Text='<%# Eval("cap") %>' />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica" CssClass="button"
                                                            CausesValidation="false" />
                                                        <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" Text="Elimina"
                                                            CssClass="button" CausesValidation="false" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                            <EmptyDataTemplate>
                                                <table id="Table2" runat="server" style="">
                                                    <tr>
                                                        <td>
                                                            Non è stato restituito alcun dato.
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                        </asp:ListView>
                                        <asp:SqlDataSource ID="SqlDataSourceResidenze" 
                                                           runat="server" 
                                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                           
                                                           DeleteCommand="DELETE FROM join_persona_residenza 
			                                                              WHERE id_rec = @id_rec" 
			                                          
			                                               InsertCommand="INSERT INTO join_persona_residenza (id_persona, 
			                                                                                                  indirizzo_residenza, 
			                                                                                                  id_comune_residenza, 
			                                                                                                  data_da, 
			                                                                                                  data_a, 
			                                                                                                  residenza_attuale, 
			                                                                                                  cap) 
			                                                              VALUES (@id_persona, 
			                                                                      @indirizzo_residenza, 
			                                                                      @id_comune, 
			                                                                      @data_da, 
			                                                                      @data_a, 
			                                                                      @residenza_attuale, 
			                                                                      @cap); 
			                                                              SELECT @id_rec = SCOPE_IDENTITY();" 
			                                          
			                                               SelectCommand="SELECT j.*, 
		                                                                         c.comune + ' (' + c.provincia + ')' AS nome_comune,
                                                                                 c.id_comune as id_comune
		                                                                  FROM join_persona_residenza AS j 
		                                                                  INNER JOIN tbl_comuni AS c 
		                                                                     ON j.id_comune_residenza = c.id_comune 
		                                                                  WHERE id_persona = @id_persona" 
			                                          
			                                               UpdateCommand="UPDATE join_persona_residenza 
			                                                              SET id_persona = @id_persona, 
			                                                                  indirizzo_residenza = @indirizzo_residenza, 
			                                                                  id_comune_residenza = @id_comune, 
			                                                                  data_da = @data_da, 
			                                                                  data_a = @data_a, 
			                                                                  residenza_attuale = @residenza_attuale, 
			                                                                  cap = @cap 
			                                                              WHERE id_rec = @id_rec" 
        			                                          
			                                               OnInserting="SqlDataSourceResidenze_Inserting"
                                                           OnInserted="SqlDataSourceResidenze_Inserted" >
                                            <SelectParameters>
                                                <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                            </SelectParameters>
                                            
                                            <DeleteParameters>
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </DeleteParameters>
                                            
                                            <UpdateParameters>
                                                <%--<asp:Parameter Name="id_residenza" Type="Int32" />--%>
                                                <asp:Parameter Name="id_persona" Type="Int32" />
                                                <asp:Parameter Name="indirizzo_residenza" Type="String" />
                                                <asp:Parameter Name="id_comune" Type="String" />
                                                <asp:Parameter Name="data_da" Type="DateTime" />
                                                <asp:Parameter Name="data_a" Type="DateTime" />
                                                <asp:Parameter Name="residenza_attuale" Type="String" />
                                                <asp:Parameter Name="cap" Type="String" />
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </UpdateParameters>
                                            
                                            <InsertParameters>
                                                <%--<asp:Parameter Name="id_residenza" Type="Int32" />--%>
                                                <asp:Parameter Name="id_persona" Type="Int32" />
                                                <asp:Parameter Name="indirizzo_residenza" Type="String" />
                                                <asp:Parameter Name="id_comune" Type="String" />
                                                <asp:Parameter Name="data_da" Type="DateTime" />
                                                <asp:Parameter Name="data_a" Type="DateTime" />
                                                <asp:Parameter Name="residenza_attuale" Type="String" />
                                                <asp:Parameter Name="cap" Type="String" />
                                                <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                                            </InsertParameters>
                                        </asp:SqlDataSource>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <div align="center">
                                    <br />
                                    <asp:Button ID="ButtonChiudiResidenze" runat="server" Text="Chiudi" CssClass="button" />
                                    <br />
                                    <br />
                                </div>
                                <cc1:ModalPopupExtender ID="ModalPopupExtenderResidenze" BehaviorID="ModalPopup1"
                                    runat="server" PopupControlID="PanelResidenze" BackgroundCssClass="modalBackground"
                                    DropShadow="true" TargetControlID="ButtonResidenze" CancelControlID="ButtonChiudiResidenze">
                                </cc1:ModalPopupExtender>
                            </asp:Panel>
                            
                            <asp:Panel ID="PanelRecapiti" runat="server" Width="1000px" BackColor="White" BorderColor="DarkSeaGreen"
                                BorderWidth="2px" Style="display: none;">
                                <div align="center">
                                    <br />
                                    <h3>
                                        GESTIONE RECAPITI</h3>
                                    <br />
                                </div>
                                <asp:UpdatePanel ID="UpdatePanelRecapiti" runat="server">
                                    <ContentTemplate>
                                        <asp:ListView ID="ListViewRecapiti" runat="server" DataKeyNames="id_rec" DataSourceID="SqlDataSourceRecapiti"
                                            InsertItemPosition="LastItem" OnItemInserting="ListViewRecapiti_ItemInserting"
                                            OnItemInserted="ListViewRecapiti_ItemInserted" OnItemUpdating="ListViewRecapiti_ItemUpdating"
                                            OnItemDeleted="ListViewRecapiti_ItemDeleted" OnItemUpdated="ListViewRecapiti_ItemUpdated">
                                            <LayoutTemplate>
                                                <table id="Table3" runat="server" width="95%">
                                                    <tr id="Tr4" runat="server">
                                                        <td id="Td3" runat="server">
                                                            <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
                                                                <tr id="Tr5" runat="server">
                                                                    <th id="Th8" runat="server">
                                                                        Tipo
                                                                    </th>
                                                                    <th id="Th7" runat="server">
                                                                        Recapito
                                                                    </th>
                                                                    <th id="Th1" runat="server">
                                                                    </th>
                                                                </tr>
                                                                <tr id="itemPlaceholder" runat="server">
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr id="Tr6" runat="server">
                                                        <td id="Td4" runat="server" style="">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </LayoutTemplate>
                                            
                                            <InsertItemTemplate>
                                                <tr style="">
                                                    <td width="160" valign="top" align="center">
                                                        <asp:DropDownList ID="DropDownListTipoRecapitoInsert" runat="server" DataSourceID="SqlDataSource3"
                                                            DataTextField="nome_recapito" DataValueField="id_recapito" Width="150px">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td valign="top">
                                                        <asp:TextBox ID="recapitoTextBox" runat="server" Text='<%# Bind("recapito") %>' Width="99%" />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorRecapito" ControlToValidate="recapitoTextBox"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="RecapitiInsertGroup" />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Inserisci"
                                                            CssClass="button" ValidationGroup="RecapitiInsertGroup" />
                                                        <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancella"
                                                            CssClass="button" CausesValidation="false" />
                                                    </td>
                                                </tr>
                                            </InsertItemTemplate>
                                            
                                            <EmptyDataTemplate>
                                                <table id="Table4" runat="server" style="">
                                                    <tr>
                                                        <td>
                                                            Non è stato restituito alcun dato.
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                            
                                            <EditItemTemplate>
                                                <tr style="">
                                                    <td width="160" valign="top" align="center">
                                                        <asp:DropDownList ID="DropDownListTipoRecapitoEdit" runat="server" SelectedValue='<%# Bind("tipo_recapito") %>'
                                                            DataSourceID="SqlDataSource3" DataTextField="nome_recapito" DataValueField="id_recapito"
                                                            Width="150px">
                                                        </asp:DropDownList>
                                                    </td>
                                                    
                                                    <td valign="top">
                                                        <asp:TextBox ID="recapitoTextBox" runat="server" Text='<%# Bind("recapito") %>' Width="99%" />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorRecapito" ControlToValidate="recapitoTextBox"
                                                            runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="RecapitiEditGroup" />
                                                    </td>
                                                    
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="UpdateButton" runat="server" CommandName="Update" Text="Aggiorna"
                                                            CssClass="button" ValidationGroup="RecapitiEditGroup" />
                                                        <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Annulla"
                                                            CssClass="button" CausesValidation="false" />
                                                    </td>
                                                </tr>
                                            </EditItemTemplate>
                                            
                                            <ItemTemplate>
                                                <tr style="">
                                                    <td>
                                                        <asp:Label ID="tipo_recapitoLabel" runat="server" Text='<%# Eval("nome_recapito") %>' />
                                                    </td>
                                                    
                                                    <td>
                                                        <asp:Label ID="recapitoLabel" runat="server" Text='<%# Eval("recapito") %>' />
                                                    </td>
                                                    
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica" CssClass="button"
                                                            CausesValidation="false" />
                                                        <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" Text="Elimina"
                                                            CssClass="button" CausesValidation="false" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:ListView>
                                        <asp:SqlDataSource ID="SqlDataSourceRecapiti" 
                                                           runat="server" 
                                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                       
                                                           DeleteCommand="DELETE FROM [join_persona_recapiti] 
                                                                          WHERE [id_rec] = @id_rec"
                                                           
                                                           InsertCommand="INSERT INTO [join_persona_recapiti] ([id_persona], 
                                                                                                               [recapito], 
                                                                                                               [tipo_recapito]) 
                                                                          VALUES (@id_persona, 
                                                                                  @recapito, 
                                                                                  @tipo_recapito); 
                                                                          SELECT @id_rec = SCOPE_IDENTITY();"
                                                           
                                                           SelectCommand="SELECT * 
                                                                          FROM join_persona_recapiti AS jj 
                                                                          INNER JOIN tbl_recapiti AS rr 
                                                                            ON jj.tipo_recapito = rr.id_recapito 
                                                                          WHERE id_persona = @id_persona"
                                                           
                                                           UpdateCommand="UPDATE [join_persona_recapiti] 
                                                                          SET [id_persona] = @id_persona, 
                                                                              [recapito] = @recapito, 
                                                                              [tipo_recapito] = @tipo_recapito 
                                                                          WHERE [id_rec] = @id_rec"
                                                           
                                                           OnInserted="SqlDataSourceRecapiti_Inserted" >
                                            <SelectParameters>
                                                <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                            </SelectParameters>
                                            <DeleteParameters>
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </DeleteParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="id_persona" Type="Int32" />
                                                <asp:Parameter Name="recapito" Type="String" />
                                                <asp:Parameter Name="tipo_recapito" Type="String" />
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </UpdateParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="id_persona" Type="Int32" />
                                                <asp:Parameter Name="recapito" Type="String" />
                                                <asp:Parameter Name="tipo_recapito" Type="String" />
                                                <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                                            </InsertParameters>
                                        </asp:SqlDataSource>
                                        <asp:SqlDataSource ID="SqlDataSource3" 
                                                           runat="server" 
                                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                           
                                                           SelectCommand="SELECT * 
                                                                          FROM [tbl_recapiti] 
                                                                          ORDER BY [nome_recapito]">
                                        </asp:SqlDataSource>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <div align="center">
                                    <br />
                                    <asp:Button ID="ButtonChiudiRecapiti" runat="server" Text="Chiudi" CssClass="button" />
                                    <br />
                                    <br />
                                </div>
                                <cc1:ModalPopupExtender ID="ModalPopupExtenderRecapiti" BehaviorID="ModalPopup2"
                                    runat="server" PopupControlID="PanelRecapiti" BackgroundCssClass="modalBackground"
                                    DropShadow="true" TargetControlID="ButtonRecapiti" CancelControlID="ButtonChiudiRecapiti">
                                </cc1:ModalPopupExtender>
                            </asp:Panel>
                            
                            <asp:Panel ID="PanelTitoliStudio" runat="server" Width="1000px" BackColor="White"
                                BorderColor="DarkSeaGreen" BorderWidth="2px" Style="display: none;">
                                <div align="center">
                                    <br />
                                    <h3>
                                        GESTIONE TITOLI DI STUDIO</h3>
                                    <br />
                                </div>
                                <asp:UpdatePanel ID="UpdatePanelTitoliStudio" runat="server">
                                    <ContentTemplate>
                                        <asp:ListView ID="ListViewTitoliStudio" runat="server" DataKeyNames="id_rec" DataSourceID="SqlDataSourceTitoliStudio"
                                            InsertItemPosition="LastItem" OnItemInserting="ListViewTitoliStudio_ItemInserting"
                                            OnItemInserted="ListViewTitoliStudio_ItemInserted" OnItemUpdating="ListViewTitoliStudio_ItemUpdating"
                                            OnItemDeleted="ListViewTitoliStudio_ItemDeleted" OnItemUpdated="ListViewTitoliStudio_ItemUpdated">
                                            <LayoutTemplate>
                                                <table id="Table5" runat="server" width="95%">
                                                    <tr id="Tr7" runat="server">
                                                        <td id="Td5" runat="server">
                                                            <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
                                                                <tr id="Tr8" runat="server">
                                                                    <th id="Th9" runat="server">
                                                                        Titolo di studio
                                                                    </th>
                                                                    <th id="Th1" runat="server">
                                                                        Conseguito nel
                                                                    </th>
                                                                    <th id="Th3" runat="server">
                                                                        Note
                                                                    </th>
                                                                    <th id="Th2" runat="server">
                                                                    </th>
                                                                </tr>
                                                                <tr id="itemPlaceholder" runat="server">
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr id="Tr9" runat="server">
                                                        <td id="Td6" runat="server" style="">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </LayoutTemplate>
                                            <InsertItemTemplate>
                                                <tr style="">
                                                    <td width="260px" align="center">
                                                        <asp:DropDownList ID="DropDownListTitoloStudioInsert" runat="server" DataSourceID="SqlDataSourceTitoli"
                                                            DataTextField="descrizione_titolo_studio" DataValueField="id_titolo_studio" Width="250px">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td width="160" align="center">
                                                        <asp:DropDownList ID="DropDownListAnniInsert" runat="server" DataSourceID="SqlDataSourceAnni"
                                                            DataTextField="anno" DataValueField="anno" Width="150px" AppendDataBoundItems="true">
                                                            <asp:ListItem Text="(non specificato)" Value="" />
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox ID="noteTextBox" runat="server" Text='<%# Bind("note") %>' Width="99%"
                                                            MaxLength="30" />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Inserisci"
                                                            CssClass="button" CausesValidation="false" />
                                                        <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancella"
                                                            CssClass="button" CausesValidation="false" />
                                                    </td>
                                                </tr>
                                            </InsertItemTemplate>
                                            <EmptyDataTemplate>
                                                <table id="Table6" runat="server" style="">
                                                    <tr>
                                                        <td>
                                                            Non è stato restituito alcun dato.
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                            <EditItemTemplate>
                                                <tr style="">
                                                    <td width="260" align="center">
                                                        <asp:DropDownList ID="DropDownListTitoloStudioEdit" runat="server" SelectedValue='<%# Bind("id_titolo_studio") %>'
                                                            DataSourceID="SqlDataSourceTitoli" DataTextField="descrizione_titolo_studio"
                                                            DataValueField="id_titolo_studio" Width="250px">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td width="160" align="center">
                                                        <asp:DropDownList ID="DropDownListAnniEdit" runat="server" SelectedValue='<%# Bind("anno_conseguimento") %>'
                                                            DataSourceID="SqlDataSourceAnni" DataTextField="anno" DataValueField="anno" Width="150px"
                                                            AppendDataBoundItems="true">
                                                            <asp:ListItem Text="(non specificato)" Value="" />
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox ID="noteTextBox" runat="server" Text='<%# Bind("note") %>' Width="99%"
                                                            MaxLength="30" />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="UpdateButton" runat="server" CommandName="Update" Text="Aggiorna"
                                                            CssClass="button" CausesValidation="false" />
                                                        <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Annulla"
                                                            CssClass="button" CausesValidation="false" />
                                                    </td>
                                                </tr>
                                            </EditItemTemplate>
                                            <ItemTemplate>
                                                <tr style="">
                                                    <td width="260">
                                                        <asp:Label ID="descrizione_titolo_studioLabel" runat="server" Text='<%# Eval("descrizione_titolo_studio") %>'
                                                            Width="250px" />
                                                    </td>
                                                    <td width="160">
                                                        <asp:Label ID="anno_conseguimentoLabel" runat="server" Text='<%# Eval("anno_conseguimento") %>'
                                                            Width="100px" />
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="noteLabel" runat="server" Text='<%# Eval("note") %>' />
                                                    </td>
                                                    <td width="23%" valign="top" align="center">
                                                        <asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica" CssClass="button"
                                                            CausesValidation="false" />
                                                        <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" Text="Elimina"
                                                            CssClass="button" CausesValidation="false" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:ListView>
                                        
                                        <asp:SqlDataSource ID="SqlDataSourceTitoliStudio" 
                                                           runat="server" 
                                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                           
                                                           DeleteCommand="DELETE FROM [join_persona_titoli_studio] 
                                                                          WHERE [id_rec] = @id_rec"
                                                           
                                                           InsertCommand="INSERT INTO [join_persona_titoli_studio] ([id_titolo_studio], 
                                                                                                                    [id_persona], 
                                                                                                                    [anno_conseguimento], 
                                                                                                                    [note]) 
                                                                          VALUES (@id_titolo_studio, 
                                                                                  @id_persona, 
                                                                                  @anno_conseguimento, 
                                                                                  @note); 
                                                                          SELECT @id_rec = SCOPE_IDENTITY();"
                                                           
                                                           SelectCommand="SELECT * 
                                                                          FROM join_persona_titoli_studio AS jj 
                                                                          INNER JOIN tbl_titoli_studio AS tt 
                                                                             ON jj.id_titolo_studio = tt.id_titolo_studio 
					                                                      WHERE ([id_persona] = @id_persona) 
					                                                      ORDER BY [anno_conseguimento] DESC" 
					                                       
					                                       UpdateCommand="UPDATE [join_persona_titoli_studio] 
					                                                      SET [id_titolo_studio] = @id_titolo_studio, 
					                                                          [id_persona] = @id_persona, 
					                                                          [anno_conseguimento] = @anno_conseguimento, 
					                                                          [note] = @note 
					                                                      WHERE [id_rec] = @id_rec"
					                                                      
                                                           OnInserted="SqlDataSourceTitoliStudio_Inserted">
                                            <SelectParameters>
                                                <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                                            </SelectParameters>
                                            
                                            <DeleteParameters>
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </DeleteParameters>
                                            
                                            <UpdateParameters>
                                                <asp:Parameter Name="id_titolo_studio" Type="Int32" />
                                                <asp:Parameter Name="id_persona" Type="Int32" />
                                                <asp:Parameter Name="anno_conseguimento" Type="Int32" />
                                                <asp:Parameter Name="note" Type="String" />
                                                <asp:Parameter Name="id_rec" Type="Int32" />
                                            </UpdateParameters>
                                            
                                            <InsertParameters>
                                                <asp:Parameter Name="id_titolo_studio" Type="Int32" />
                                                <asp:Parameter Name="id_persona" Type="Int32" />
                                                <asp:Parameter Name="anno_conseguimento" Type="Int32" />
                                                <asp:Parameter Name="note" Type="String" />
                                                <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                                            </InsertParameters>
                                        </asp:SqlDataSource>
                                        <asp:SqlDataSource ID="SqlDataSourceAnni" 
                                                           runat="server" 
                                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                          
                                                           SelectCommand="SELECT anno 
                                                                          FROM tbl_anni 
                                                                          WHERE (anno &gt; YEAR(GETDATE()) - 50) AND (anno &lt;= YEAR(GETDATE())) 
                                                                          ORDER BY anno DESC">
                                        </asp:SqlDataSource>
                                        <asp:SqlDataSource ID="SqlDataSourceTitoli" 
                                                           runat="server" 
                                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                           
                                                           SelectCommand="SELECT * 
                                                                          FROM [tbl_titoli_studio] 
                                                                          ORDER BY [descrizione_titolo_studio]">
                                        </asp:SqlDataSource>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <div align="center">
                                    <br />
                                    <asp:Button ID="ButtonChiudiTitoliStudio" runat="server" Text="Chiudi" CssClass="button" />
                                    <br />
                                    <br />
                                </div>
                                <cc1:ModalPopupExtender ID="ModalPopupExtenderTitoliStudio" BehaviorID="ModalPopup3"
                                    runat="server" PopupControlID="PanelTitoliStudio" BackgroundCssClass="modalBackground"
                                    DropShadow="true" TargetControlID="ButtonTitoliStudio" CancelControlID="ButtonChiudiTitoliStudio">
                                </cc1:ModalPopupExtender>
                            </asp:Panel>
                            <% } %>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
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
               href="../persona/persona.aspx">
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


  <script type="text/javascript">

        function autoCompleteComuneNascitaSelected(source, eventArgs) {
            var id = eventArgs.get_value();
            var text = eventArgs.get_text();

            //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

            $('input[id$=_TextBoxComuneNascitaId').val(id);
        }

        function autoCompleteComuneResidenzaSelected(source, eventArgs) {
            var id = eventArgs.get_value();
            var text = eventArgs.get_text();

            //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

            $('input[id$=_TextBoxComuneResidenzaId').val(id);
        }

  </script>

</asp:Content>