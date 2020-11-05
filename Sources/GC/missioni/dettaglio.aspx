<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         EnableViewState="false"
         MasterPageFile="~/MasterPage.master"
         CodeFile="dettaglio.aspx.cs" 
         Inherits="missioni_dettaglio" 
         Title="Missione > Anagrafica" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	<b>MISSIONE &gt; ANAGRAFICA</b>
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
		    <li id="selected"><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
			<li><a id="a_componenti" runat="server">PARTECIPANTI</a></li>
	    </ul>
	</div>
	
	<div id="tab_content">
	    <div id="tab_content_content">
		<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		    <ContentTemplate>
			<table width="100%" cellspacing="5" cellpadding="10">
			    <tr>
				<td class="singleborder" valign="top">
				    <asp:DetailsView ID="DetailsView1" 
				                     runat="server" 
				                     Height="50px"
				                     Width="100%" 					                      
					                 AutoGenerateRows="False" 
					                 CellPadding="5"
					                 GridLines="None" 
					                 DataKeyNames="id_missione" 
					                 DataSourceID="SqlDataSource4"
					                 
					                 OnItemDeleted="DetailsView1_ItemDeleted"
					                 OnItemInserting="DetailsView1_ItemInserting"
					                 OnItemUpdating="DetailsView1_ItemUpdating" >
					                 
					    <Fields>
					        <asp:TemplateField HeaderText="Legislatura">
						        <ItemTemplate>
						            <asp:Label ID="label_num_legislatura" 
						            runat="server" 
						            Text='<%# Eval("num_legislatura") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <InsertItemTemplate>
						        <%--OnSelectedIndexChanged="SelectedIndexChanged_ddlLegislatura_Insert"
						            OnDataBound="DataBound_ddlLegislatura_Insert"--%>
						            <asp:DropDownList ID="DropDownList3" 
						                              runat="server" 
						                              DataSourceID="SqlDataSource2"
							                          DataTextField="num_legislatura" 
							                          DataValueField="id_legislatura" 
							                          SelectedValue='<%# Bind("id_legislatura") %>'
							                          Width="160px" 
							                          AutoPostBack="true"
							                          AppendDataBoundItems="true"
							                          
                    							      OnSelectedIndexChanged="SelectedIndexChanged_ddlLegislatura_Insert" >
							        
							            <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
						            </asp:DropDownList>
						            
						            <asp:RequiredFieldValidator ID="RequiredFieldValidator_ddlLeg_Insert"
						                                        runat="server"
						                                        ControlToValidate="DropDownList3"
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
						            </asp:RequiredFieldValidator>
						        </InsertItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:DropDownList ID="DropDownList4" 
						                              runat="server" 
						                              DataSourceID="SqlDataSource2"
							                          DataTextField="num_legislatura" 
							                          DataValueField="id_legislatura" 
							                          SelectedValue='<%# Bind("id_legislatura") %>'
							                          Width="160px">
						            </asp:DropDownList>
						        </EditItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Codice" SortExpression="codice">
						        <ItemTemplate>
						            <asp:Label ID="LabelCodice" 
						                       runat="server" 
						                       Text='<%# Bind("codice") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxCodice_Edit" 
						                         runat="server" 
						                         Text='<%# Bind("codice") %>' 
						                         MaxLength='20'>
						            </asp:TextBox>
						            
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxCodice_Edit" 
						                                        runat="server"
						                                        ControlToValidate="TextBoxCodice_Edit"
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
							        <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxCodice_Edit"
							                                        ControlToValidate="TextBoxCodice_Edit" 
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Solo cifre ammesse."
							                                        ValidationExpression="^[0-9]+$" 
							                                        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxCodice_Insert" 
						                         runat="server" 
						                         Text='<%# Bind("codice") %>' 
						                         MaxLength='20'>
						            </asp:TextBox>
						            
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxCodice_Insert" 
						                                        ControlToValidate="TextBoxCodice_Insert"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
							        <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxCodice_Insert"
							                                        ControlToValidate="TextBoxCodice_Insert" 
							                                        runat="server" 
							                                        Display="Dynamic" 
							                                        ErrorMessage="Solo cifre ammesse."
							                                        ValidationExpression="^[0-9]+$" 
							                                        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Protocollo" SortExpression="protocollo">
						        <ItemTemplate>
						            <asp:Label ID="LabelProtocollo" runat="server" Text='<%# Bind("protocollo") %>'></asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxProtocollo" runat="server" Text='<%# Bind("protocollo") %>'
							        MaxLength='20'></asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxProtocollo" ControlToValidate="TextBoxProtocollo"
							        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxProtocollo" runat="server" Text='<%# Bind("protocollo") %>'
							        MaxLength='20'></asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxProtocollo" ControlToValidate="TextBoxProtocollo"
							        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Oggetto" SortExpression="oggetto">
						        <ItemTemplate>
						            <asp:Label ID="LabelOggetto" 
						                       runat="server" 
						                       Text='<%# Bind("oggetto") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxOggetto" 
						                         runat="server"
						                         Rows="5"
					                             TextMode="MultiLine" 
						                         Text='<%# Bind("oggetto") %>'
							                     MaxLength='500' 
							                     Width="300px">
							        </asp:TextBox>
							        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxOggetto" 
						                                        ControlToValidate="TextBoxOggetto"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							                                    
							        <asp:RegularExpressionValidator ID="RegularExpressionValidator_TextBoxOggetto_Edit"
							                                        runat="server"
							                                        ControlToValidate="TextBoxOggetto"
							                                        Display="Dynamic"
							                                        ValidationExpression="^.{1,500}$" 
							                                        ErrorMessage="MAX 500 caratteri." 
							                                        ValidationGroup="ValidGroup" >							        
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxOggetto" 
					                             runat="server"
					                             Rows="5"
					                             TextMode="MultiLine"
					                             Text='<%# Bind("oggetto") %>'
						                         MaxLength='500' 
						                         Width="300px">
							        </asp:TextBox>
							        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxOggetto" 
						                                        ControlToValidate="TextBoxOggetto"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
							        <asp:RegularExpressionValidator ID="RegularExpressionValidator_TextBoxOggetto_Insert"
							                                        runat="server"
							                                        ControlToValidate="TextBoxOggetto"
							                                        Display="Dynamic"
							                                        ValidationExpression="^.{1,500}$" 
							                                        ErrorMessage="MAX 500 caratteri." 
							                                        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
						    
					        <asp:TemplateField HeaderText="Tipo Delibera">
						        <ItemTemplate>
						            <asp:Label ID="label_tipo_delibera" 
						            runat="server" 
						            Text='<%# Eval("tipo_delibera") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:DropDownList ID="DropDownList1" 
						            runat="server" 
						            DataSourceID="SqlDataSource3"
							        DataTextField="tipo_delibera" 
							        DataValueField="id_delibera" 
							        SelectedValue='<%# Bind("id_delibera") %>'
							        Width="160px">
						            </asp:DropDownList>
						        </InsertItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:DropDownList ID="DropDownList2" 
						            runat="server" 
						            DataSourceID="SqlDataSource3"
							        DataTextField="tipo_delibera" 
							        DataValueField="id_delibera" 
							        SelectedValue='<%# Bind("id_delibera") %>'
							        Width="160px">
						            </asp:DropDownList>
						        </EditItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Numero Delibera" SortExpression="numero_delibera">
						        <ItemTemplate>
						            <asp:Label ID="LabelNumeroDelibera" 
						            runat="server" 
						            Text='<%# Bind("numero_delibera") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxNumeroDelibera_Edit" 
						            runat="server" 
						            Text='<%# Bind("numero_delibera") %>'
							        MaxLength='20'>
							        </asp:TextBox>
							        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxNumeroDelibera_Edit" 
						            ControlToValidate="TextBoxNumeroDelibera_Edit"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
						            <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxNumeroDelibera_Edit"
							        ControlToValidate="TextBoxNumeroDelibera_Edit" 
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Solo cifre ammesse."
							        ValidationExpression="^[0-9]+$" 
							        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxNumeroDelibera_Insert" 
						            runat="server" 
						            Text='<%# Bind("numero_delibera") %>'
							        MaxLength='20'>
							        </asp:TextBox>
							        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxNumeroDelibera_Insert" 
						            ControlToValidate="TextBoxNumeroDelibera_Insert"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
						            <asp:RegularExpressionValidator ID="RegularExpressionValidatorTextBoxNumeroDelibera_Insert"
							        ControlToValidate="TextBoxNumeroDelibera_Insert" 
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Solo cifre ammesse."
							        ValidationExpression="^[0-9]+$" 
							        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Data Delibera" SortExpression="data_delibera">
						        <ItemTemplate>
						            <asp:Label ID="LabelDataDelibera" 
						            runat="server" 
						            Text='<%# Eval("data_delibera", "{0:dd/MM/yyyy}") %>'>
						            </asp:Label>
						        </ItemTemplate>
							    
						        <EditItemTemplate>
						            <asp:TextBox ID="dt_delibera_Mod" 
						            runat="server" 
						            Text='<%# Eval("data_delibera", "{0:dd/MM/yyyy}") %>'>
						            </asp:TextBox>
						            
						            <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
						            
						            <cc1:CalendarExtender ID="CalendarExtender1" 
						            runat="server" 
						            TargetControlID="dt_delibera_Mod"
							        PopupButtonID="Image1" 
							        Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatord_delibera_Mod" 
						            ControlToValidate="dt_delibera_Mod"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_delibera_Mod" 
						            ControlToValidate="dt_delibera_Mod"
							        runat="server"
							        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							        Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="FiltroData">
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
							    
						        <InsertItemTemplate>
						            <asp:TextBox ID="dt_delibera_Ins" 
						            runat="server" >
						            </asp:TextBox>
						            <img alt="calendar" 
						            src="../img/calendar_month.png" 
						            id="Image_DTDelibera_Insert" 
						            runat="server" />
						            
						            <cc1:CalendarExtender ID="CalendarExtender_DTDelibera_Insert" 
						            runat="server" 
						            TargetControlID="dt_delibera_Ins"
							        PopupButtonID="Image_DTDelibera_Insert" 
							        Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatord_delibera_Ins" 
						            ControlToValidate="dt_delibera_Ins"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_delibera_Ins" 
						            ControlToValidate="dt_delibera_Ins"
							        runat="server" 
							        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							        Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="FiltroData" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
						        <ItemTemplate>
						            <asp:Label ID="Label2" 
						            runat="server" 
						            Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
						            </asp:Label>
						        </ItemTemplate>
							    
						        <EditItemTemplate>
						            <asp:TextBox ID="dt_missioneDa_mod" 
						            runat="server" 
						            Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
						            </asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtender2" 
						            runat="server" 
						            TargetControlID="dt_missioneDa_mod"
							        PopupButtonID="Image2" 
							        Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatord_missioneDa_mod" 
						            ControlToValidate="dt_missioneDa_mod"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_missioneDa_mod" 
						            ControlToValidate="dt_missioneDa_mod"
							        runat="server" 
							        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							        Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
							    
						        <InsertItemTemplate>
						            <asp:TextBox ID="dt_missioneDa_ins" 
						            runat="server" >
						            </asp:TextBox>
						            
						            <img alt="calendar" src="../img/calendar_month.png" id="Image_DTDal_Insert" runat="server" />
						            
						            <cc1:CalendarExtender ID="CalendarExtender_DTDal_Insert" 
						            runat="server" 
						            TargetControlID="dt_missioneDa_ins"
							        PopupButtonID="Image_DTDal_Insert" 
							        Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatord_missioneDa_ins" 
						            ControlToValidate="dt_missioneDa_ins"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
							        
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_missioneDa_ins" 
						            ControlToValidate="dt_missioneDa_ins"
							        runat="server" 
							        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							        Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
						        <ItemTemplate>
						            <asp:Label ID="Label3" 
						            runat="server" 
						            Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
						            </asp:Label>
						        </ItemTemplate>
							    
						        <EditItemTemplate>
						            <asp:TextBox ID="dt_missioneA_mod" 
						            runat="server" 
						            Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
						            </asp:TextBox>
						            <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
						            <cc1:CalendarExtender ID="CalendarExtender3" 
						            runat="server" 
						            TargetControlID="dt_missioneA_mod"
							        PopupButtonID="Image3" 
							        Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_missioneA_mod" 
						            ControlToValidate="dt_missioneA_mod"
							        runat="server" 
							        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							        Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
							    
						        <InsertItemTemplate>
						            <asp:TextBox ID="dt_missioneA_ins" 
						            runat="server" >
						            </asp:TextBox>
						            
						            <img alt="calendar" src="../img/calendar_month.png" id="Image_DTAl_Insert" runat="server" />
						            
						            <cc1:CalendarExtender ID="CalendarExtender_DTAl_Insert" 
						            runat="server" 
						            TargetControlID="dt_missioneA_ins"
							        PopupButtonID="Image_DTAl_Insert" 
							        Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
						            
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_missioneA_ins" 
						            ControlToValidate="dt_missioneA_ins"
							        runat="server" 
							        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							        Display="Dynamic"
							        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							        ValidationGroup="ValidGroup" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Luogo" SortExpression="luogo">
						        <ItemTemplate>
						            <asp:Label ID="LabelLuogo" runat="server" Text='<%# Bind("luogo") %>'></asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxLuogo_Edit" 
						            runat="server" 
						            Text='<%# Bind("luogo") %>'>
						            </asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxLuogo_Edit" 
						            ControlToValidate="TextBoxLuogo_Edit"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" />
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxLuogo_Insert" 
						            runat="server" 
						            Text='<%# Bind("luogo") %>'>
						            </asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxLuogo_Insert" 
						            ControlToValidate="TextBoxLuogo_Insert"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Città" SortExpression="citta">
						        <ItemTemplate>
						            <asp:Label ID="LabelCitta" runat="server" Text='<%# Bind("citta") %>'></asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxCitta_Edit" 
						            runat="server" 
						            Text='<%# Bind("citta") %>'>
						            </asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxCitta_Edit" 
						            ControlToValidate="TextBoxCitta_Edit"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxCitta_Insert" 
						            runat="server" 
						            Text='<%# Bind("citta") %>'>
						            </asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxCitta_Insert" 
						            ControlToValidate="TextBoxCitta_Insert"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Nazione" SortExpression="nazione">
						        <ItemTemplate>
						            <asp:Label ID="LabelNazione" runat="server" Text='<%# Bind("nazione") %>'></asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxNazione_Edit" 
						            runat="server" 
						            Text='<%# Bind("nazione") %>'>
						            </asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxNazione_Edit" 
						            ControlToValidate="TextBoxNazione_Edit"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxNazione_Insert" 
						            runat="server" 
						            Text='<%# Bind("nazione") %>'>
						            </asp:TextBox>
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorTextBoxNazione_Insert" 
						            ControlToValidate="TextBoxNazione_Insert"
							        runat="server" 
							        Display="Dynamic" 
							        ErrorMessage="Campo obbligatorio." 
							        ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField ShowHeader="False">
					            <ItemTemplate>
						            <asp:Button ID="Button1" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Edit"
							                    Text="Modifica" 
							                    Visible="<%# (role <= 2 || role == 8) ? true : false %>" />
							                    
						            <asp:Button ID="Button3" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Delete"
							                    Text="Elimina" 
							                    Visible="<%# (role <= 2 || role == 8) ? true : false %>"							                     
							                    OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:Button ID="btn_Update" 
						                        runat="server" 
						                        CommandName="Update" 
						                        ValidationGroup="ValidGroup"
							                    Text="Aggiorna" />
							                    
						            <asp:Button ID="btn_Cancel_Update" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Cancel"
							                    Text="Annulla" />
						        </EditItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:Button ID="btn_Insert" 
						                        runat="server" 
						                        CommandName="Insert" 
						                        ValidationGroup="ValidGroup"
							                    Text="Inserisci" />
							                    
						            <asp:Button ID="btn_Cancel_Insert" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Cancel"
							                    Text="Annulla" 
							                    OnClick="ButtonAnnulla_Click" />
						        </InsertItemTemplate>
    						    
						        <ControlStyle CssClass="button" />
					        </asp:TemplateField>
					    </Fields>
					    <FieldHeaderStyle Font-Bold="True" Width="150px" />
				    </asp:DetailsView>
				</td>
			    </tr>
			</table>
			
			<asp:SqlDataSource ID="SqlDataSource2" 
			                   runat="server" 
			                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                   SelectCommand="SELECT num_legislatura, 
			                                         id_legislatura 
			                                  FROM legislature
			                                  ORDER BY durata_legislatura_da DESC">
			</asp:SqlDataSource>
			
			<asp:SqlDataSource ID="SqlDataSource3" 
			                   runat="server" 
			                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                  
			                   SelectCommand="SELECT id_delibera, 
			                                         tipo_delibera 
			                                  FROM tbl_delibere">
			    </asp:SqlDataSource>
			
			<asp:SqlDataSource ID="SqlDataSource4" 
			                   runat="server" 
			                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                   
			                   DeleteCommand="UPDATE missioni 
			                                  SET deleted = 1 
			                                  WHERE id_missione = @id_missione"
			                   
			                   InsertCommand="INSERT INTO [missioni] ([id_legislatura], 
			                                                          [codice], 
			                                                          [protocollo], 
			                                                          [oggetto], 
			                                                          [id_delibera], 
			                                                          [numero_delibera], 
			                                                          [data_delibera], 
			                                                          [data_inizio], 
			                                                          [data_fine], 
			                                                          [luogo], 
			                                                          [nazione], 
			                                                          [citta]) 
			                                  VALUES (@id_legislatura, 
			                                          @codice, 
			                                          @protocollo, 
			                                          @oggetto, 
			                                          @id_delibera, 
			                                          @numero_delibera, 
			                                          @data_delibera, 
			                                          @data_inizio, 
			                                          @data_fine, 
			                                          @luogo, 
			                                          @nazione, 
			                                          @citta); 
			                                  SELECT @id_missione = SCOPE_IDENTITY();"
			                   
			                   SelectCommand="SELECT * 
			                                  FROM missioni m 
				                              INNER JOIN legislature l 
				                                ON m.id_legislatura = l.id_legislatura
				                              INNER JOIN tbl_delibere d 
				                                ON m.id_delibera = d.id_delibera
				                              WHERE ([id_missione] = @id_missione)" 
				               
				               UpdateCommand="UPDATE [missioni] 
				                              SET [id_legislatura] = @id_legislatura, 
				                                  [codice] = @codice, 
				                                  [protocollo] = @protocollo, 
				                                  [oggetto] = @oggetto, 
				                                  [id_delibera] = @id_delibera, 
				                                  [numero_delibera] = @numero_delibera, 
				                                  [data_delibera] = @data_delibera, 
				                                  [data_inizio] = @data_inizio, 
				                                  [data_fine] = @data_fine, 
				                                  [luogo] = @luogo,
				                                  [nazione] = @nazione, 
				                                  [citta] = @citta 
				                              WHERE [id_missione] = @id_missione"
			                   
			                   OnInserted="SqlDataSource4_Inserted">
			                   
			    <SelectParameters>
				    <asp:SessionParameter Name="id_missione" SessionField="id_missione" Type="Int32" />
			    </SelectParameters>
			    
			    <DeleteParameters>
				    <asp:Parameter Name="id_missione" Type="Int32" />
			    </DeleteParameters>
			    
			    <UpdateParameters>
				    <asp:Parameter Name="id_legislatura" Type="Int32" />
				    <asp:Parameter Name="codice" Type="String" />
				    <asp:Parameter Name="protocollo" Type="String" />
				    <asp:Parameter Name="oggetto" Type="String" />
				    <asp:Parameter Name="id_delibera" Type="Int32" />
				    <asp:Parameter Name="numero_delibera" Type="String" />
				    <asp:Parameter Name="data_delibera" Type="DateTime" />
				    <asp:Parameter Name="data_inizio" Type="DateTime" />
				    <asp:Parameter Name="data_fine" Type="DateTime" />
				    <asp:Parameter Name="luogo" Type="String" />
				    <asp:Parameter Name="nazione" Type="String" />
				    <asp:Parameter Name="citta" Type="String" />
				    <asp:Parameter Name="id_missione" Type="Int32" />
			    </UpdateParameters>
			    
			    <InsertParameters>
				    <asp:Parameter Name="id_legislatura" Type="Int32" />
				    <asp:Parameter Name="codice" Type="String" />
				    <asp:Parameter Name="protocollo" Type="String" />
				    <asp:Parameter Name="oggetto" Type="String" />
				    <asp:Parameter Name="id_delibera" Type="Int32" />
				    <asp:Parameter Name="numero_delibera" Type="String" />
				    <asp:Parameter Name="data_delibera" Type="DateTime" />
				    <asp:Parameter Name="data_inizio" Type="DateTime" />
				    <asp:Parameter Name="data_fine" Type="DateTime" />
				    <asp:Parameter Name="luogo" Type="String" />
				    <asp:Parameter Name="nazione" Type="String" />
				    <asp:Parameter Name="citta" Type="String" />
				    <asp:Parameter Direction="Output" Name="id_missione" Type="Int32" />
			    </InsertParameters>
			</asp:SqlDataSource>
			
			<asp:ScriptManager ID="ScriptManager1" 
			                   runat="server" 
			                   EnableScriptGlobalization="True" >
			</asp:ScriptManager>
		    </ContentTemplate>
		</asp:UpdatePanel>
		
		<br />
		
		<div align="right">
		    <asp:LinkButton ID="LinkButtonExcelDetails" 
		    runat="server" 
		    OnClick="LinkButtonExcelDetails_Click">
		    <img src="../img/page_white_excel.png" 
		    alt="" 
		    align="top" /> 
		    Esporta
		    </asp:LinkButton>
		    -
		    <asp:LinkButton ID="LinkButtonPdfDetails" 
		    runat="server" 
		    OnClick="LinkButtonPdfDetails_Click">
		    <img src="../img/page_white_acrobat.png" 
		    alt="" 
		    align="top" /> 
		    Esporta
		    </asp:LinkButton>
		</div>
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
	    <a id="a_back" runat="server" href="../missioni/gestisciMissioni.aspx">
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
</asp:Content>