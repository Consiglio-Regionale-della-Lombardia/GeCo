<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="certificati.aspx.cs" 
         Inherits="certificati_certificati" 
         Title="Persona > Certificati" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

<asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
</asp:ScriptManager>

<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	&nbsp;
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
			                   Text='<%# Eval("nome_completo") %>' >
			        </asp:Label>
			    </span>
			    
			    <br />
			    
			    <asp:Label ID="LabelHeadDataNascita" 
			               runat="server" 
			               Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' >
			    </asp:Label>
			    
			    <asp:Label ID="LabelHeadGruppo" 
			               runat="server" 
			               Font-Bold="true"
			               Text='<%# Eval("nome_gruppo") %>' >
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
			                          WHERE pp.id_persona = @id_persona" >
			                          
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
		<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		    <ContentTemplate>
			<table>
			    <tr>
				<td valign="top" width="230">
				    Seleziona legislatura:
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
					                   
					                   SelectCommand="SELECT [id_legislatura], 
					                                         [num_legislatura] 
					                                  FROM [legislature]" >
				    </asp:SqlDataSource>
				</td>

				<td align="left" valign="middle" >
				    <asp:Label ID="Label1"
				                runat="server"
				                Width="120px"
				                Text="Seleziona intervallo">
				    </asp:Label>
				            
				    <asp:Label ID="Label2"
				                runat="server" 
				                Text="dal: ">
				    </asp:Label>
				            			            				            				            
				    <asp:TextBox ID="txtStartDate_Search" 
				                    runat="server" 
				                    Width="70px">
				    </asp:TextBox>
				            
				    <img alt="calendar" 
				            src="../img/calendar_month.png" 
				            id="ImageStartDate_Search" 
				            runat="server" />
				            
				    <cc1:CalendarExtender ID="CalendarExtender1" 
				                            runat="server" 
				                            TargetControlID="txtStartDate_Search"
					                        PopupButtonID="ImageStartDate_Search" 
					                        Format="dd/MM/yyyy">
				    </cc1:CalendarExtender>				            				            
				            
				    <asp:RegularExpressionValidator ID="RegularExpressionValidator_StartDate" 
				                                    ControlToValidate="txtStartDate_Search"
					                                runat="server" 
					                                ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                                Display="Dynamic"
					                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                                ValidationGroup="FiltroData" >
					</asp:RegularExpressionValidator>
					        
					<asp:Label ID="Label5"
				                runat="server"
				                Width="30px"
				                Text="&nbsp;">
				    </asp:Label>
					        
					<asp:Label ID="Label3"
				                runat="server" 
				                Text="al: ">
				    </asp:Label>
				            
				    <asp:TextBox ID="txtEndDate_Search" 
				                    runat="server" 
				                    Width="70px">
				    </asp:TextBox>
				            
				    <img alt="calendar" 
				            src="../img/calendar_month.png" 
				            id="ImageEndDate_Search" 
				            runat="server" />
				            
				    <cc1:CalendarExtender ID="CalendarExtender3" 
				                            runat="server" 
				                            TargetControlID="txtEndDate_Search"
					                        PopupButtonID="ImageEndDate_Search" 
					                        Format="dd/MM/yyyy">
				    </cc1:CalendarExtender>				            				            
				            
				    <asp:RegularExpressionValidator ID="RegularExpressionValidator_EndDate" 
				                                    ControlToValidate="txtEndDate_Search"
					                                runat="server" 
					                                ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                                Display="Dynamic"
					                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                                ValidationGroup="FiltroData" >
					</asp:RegularExpressionValidator>
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
			              DataKeyNames="id_certificato" 
			              DataSourceID="SqlDataSource1"
			              GridLines="None">
			              
			    <EmptyDataTemplate>
				    <table width="100%" class="tab_gen">
				    <tr>
					    <th align="center">
					        Nessun record trovato.
					    </th>
					    <th width="100">
					        <% if (role <= 2 || role == 8 || true) { %>
					        <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
						    CausesValidation="false" />
					        <% } %>
					    </th>
				    </tr>
				    </table>
			    </EmptyDataTemplate>
			    <AlternatingRowStyle BackColor="#b2cca7" />	
			    <Columns>
				    <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
				        <ItemTemplate>
                            <asp:LinkButton ID="lnkbtn_leg" 
		                                    runat="server"
		                                    Text='<%# Eval("num_legislatura") %>'
		                                    Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>' >
		                    </asp:LinkButton>
				        </ItemTemplate>
				        <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
				    </asp:TemplateField>				
					
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

<%--				    <asp:BoundField DataField="note" 
				        HeaderText="Note" 
				        SortExpression="note"
				        ItemStyle-HorizontalAlign="left" 
				        ItemStyle-Width="200px" />--%>

				    <asp:TemplateField HeaderText="Note" SortExpression="note">
				        <ItemTemplate>
                            <asp:Label runat="server" 
                                Text='<%# Eval("note") %>' 
                                Visible='<%# IsEditable(Eval("id_ruolo_insert")) %>' />
				        </ItemTemplate>
				        <ItemStyle HorizontalAlign="left" Width="200px" />
				    </asp:TemplateField>	

				    <asp:TemplateField HeaderText="Valido" SortExpression="valido">
				        <ItemTemplate>
                            <asp:Label runat="server" 
                                Text='<%# Eval("valido") %>'
                                Visible='<%# IsEditable(Eval("id_ruolo_insert")) %>' />
				        </ItemTemplate>
				        <ItemStyle HorizontalAlign="center" Width="40px" />
				    </asp:TemplateField>	

				    <asp:TemplateField HeaderText="Inserito da" SortExpression="inserito_da">
				        <ItemTemplate>
                            <asp:Label runat="server" 
                                Text='<%# Eval("inserito_da") %>'
                                Visible='<%# IsEditable(Eval("id_ruolo_insert")) %>' />
				        </ItemTemplate>
				        <ItemStyle HorizontalAlign="center" Width="200px" />
				    </asp:TemplateField>

				    <asp:TemplateField>
				        <ItemTemplate>
					            <asp:LinkButton ID="LinkButtonDettagli" 
					                            runat="server" 
					                            CausesValidation="False" 
					                            Text="Dettagli"
					                            OnClick="LinkButtonDettagli_Click"
                                                Visible='<%# IsEditable(Eval("id_ruolo_insert")) %>'>
					            </asp:LinkButton>
				        </ItemTemplate>
				        <HeaderTemplate>
					        <%--DUP 106 - Ora li possono inserire tutti
                                <% if (role <= 2 || role == 8) { %>--%>
					        <asp:Button ID="Button1" 
					                    runat="server" 
					                    Text="Nuovo..." 
					                    OnClick="Button1_Click" 
					                    CssClass="button"
					                    CausesValidation="false" />
					        <%--<% } %>--%>
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
		                                            jj.id_certificato,
		                                            jj.data_inizio, 
		                                            jj.data_fine, 
		                                            jj.note,
		                                            case when isnull(jj.non_valido,0) = 0 then 'SI' 
		                                            else 'NO' 
		                                            end as valido,

                                                    (case when not jj.nome_utente_insert is null then jj.nome_utente_insert  + ' (' + rri.nome_ruolo + ')'
		                                            else uu.nome_utente + ' (' + rr.nome_ruolo + ')' end) as inserito_da,

		                                            isnull(jj.id_utente_insert,0) as id_utente_insert,

		                                            (case when not jj.id_ruolo_insert is null then jj.id_ruolo_insert
		                                            else rr.id_ruolo end) as id_ruolo_insert	

                                            FROM certificati AS jj 
                                            INNER JOIN legislature AS ll 
                                            ON jj.id_legislatura = ll.id_legislatura 
                                            left outer join utenti uu on uu.id_utente = jj.id_utente_insert
                                            left outer join tbl_ruoli rr on rr.id_ruolo = uu.id_ruolo
                                            left outer join tbl_ruoli rri on rri.id_ruolo = jj.id_ruolo_insert
                                            where jj.deleted = 0 and jj.id_persona = @id">			    
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
			<h3>
			    CERTIFICATI
			</h3>
			<br />
			
		    <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
			    <ContentTemplate>
			        <asp:DetailsView ID="DetailsView1" 
			                         runat="server" 
			                         AutoGenerateRows="False" 
			                         DataKeyNames="id_certificato" 
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
						             OnDataBinding="SqlDataSourceLeg_DataBinding"
                                        SelectCommand="SELECT [id_legislatura], 
						                                  [num_legislatura] 
						                           FROM [legislature]">
					                </asp:SqlDataSource>
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
						                           FROM [legislature]">
					                </asp:SqlDataSource>
					            </EditItemTemplate>
				            </asp:TemplateField>
				           
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
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDatIni" ControlToValidate="DataInizioEdit"
						                runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
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
					                             runat="server" >
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioInsert" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtenderDataInizioInsert" 
					                                      runat="server" 
					                                      TargetControlID="DataInizioInsert"
						                                  PopupButtonID="ImageDataInizioInsert" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDatIni" ControlToValidate="DataInizioInsert"
						                runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
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
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDatFin" ControlToValidate="DataFineEdit"
						                runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
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
					                             runat="server" >
					                </asp:TextBox>
					                <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineInsert" runat="server" />
					                <cc1:CalendarExtender ID="CalendarExtenderDataFineInsert" 
					                                      runat="server" 
					                                      TargetControlID="DataFineInsert"
						                                  PopupButtonID="ImageDataFineInsert" 
						                                  Format="dd/MM/yyyy">
					                </cc1:CalendarExtender>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDatFin" ControlToValidate="DataFineInsert"
						                runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					                <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFine" 
					                                                ControlToValidate="DataFineInsert"
						                                            runat="server" 
						                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                            Display="Dynamic"
						                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						                                            ValidationGroup="ValidGroup" />
					            </InsertItemTemplate>
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

				            <asp:TemplateField HeaderText="Non valido" SortExpression="non_valido">
					            <EditItemTemplate>					         
					                <asp:CheckBox ID="ChkNonValido" 
					                             runat="server" Checked='<%# Bind("non_valido") %>' />
					            </EditItemTemplate>
					        
					            <InsertItemTemplate>
					                <asp:CheckBox ID="ChkNonValido" 
					                             runat="server" Checked='<%# Bind("non_valido") %>' />
					            </InsertItemTemplate>
					        
					            <ItemTemplate>
					                <asp:CheckBox ID="ChkNonValido" Enabled="false" 
					                             runat="server" Checked='<%# Bind("non_valido") %>' />
					            </ItemTemplate>
				            </asp:TemplateField>

				            <asp:TemplateField HeaderText="Inserito da" SortExpression="inserito_da">
					            <EditItemTemplate>					         
					                <asp:Label ID="LabelInseritoDa" 
					                           runat="server" 
					                           Text='<%# Eval("inserito_da") %>'>
					                </asp:Label>
					            </EditItemTemplate>
					        
					            <InsertItemTemplate>
					                
					            </InsertItemTemplate>
					        
					            <ItemTemplate>
					                <asp:Label ID="LabelInseritoDa" 
					                           runat="server" 
					                           Text='<%# Eval("inserito_da") %>'>
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
						            Text="Modifica" Visible='<%# IsEditable(Eval("id_ruolo_insert")) %>' />
					                <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
						            Text="Elimina" Visible='<%# IsEditable(Eval("id_ruolo_insert")) %>' />
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
					                   
				                       DeleteCommand="UPDATE [certificati] 
				                                      SET [deleted] = 1 
				                                      WHERE [id_certificato] = @id_certificato"
				                                      
				                       InsertCommand="INSERT INTO [certificati]
                                                           ([id_legislatura]
                                                           ,[id_persona]
                                                           ,[data_inizio]
                                                           ,[data_fine]
                                                           ,[note]
                                                           ,[id_utente_insert]
                                                           ,[non_valido]
                                                           ,[nome_utente_insert]
                                                           ,[id_ruolo_insert])
                                                     VALUES
                                                           (@id_legislatura
                                                           ,@id_persona
                                                           ,@data_inizio
                                                           ,@data_fine
                                                           ,@note
                                                           ,@id_utente_insert
                                                           ,@non_valido
                                                           ,@nome_utente_insert
                                                           ,@id_ruolo_insert)
                                                SELECT @id_certificato = SCOPE_IDENTITY();"
					                   
				                       SelectCommand="SELECT jj.[id_certificato]
                                                              ,jj.[id_legislatura]
                                                              ,jj.[id_persona]
                                                              ,jj.[data_inizio]
                                                              ,jj.[data_fine]
                                                              ,jj.[note]
                                                              ,jj.[deleted]
                                                              ,jj.[id_utente_insert]
                                                              ,isnull(jj.[non_valido],0) as non_valido, 
				                                             ll.id_legislatura, 
				                                             ll.num_legislatura,

                                                            (case when not jj.nome_utente_insert is null then jj.nome_utente_insert  + ' (' + rri.nome_ruolo + ')'
		                                                    else uu.nome_utente + ' (' + rr.nome_ruolo + ')' end) as inserito_da,

		                                                    (case when not jj.id_ruolo_insert is null then jj.id_ruolo_insert
		                                                    else rr.id_ruolo end) as id_ruolo_insert	

				                                      FROM certificati AS jj 
				                                      INNER JOIN legislature AS ll 
				                                        ON jj.id_legislatura = ll.id_legislatura
                                                      LEFT OUTER JOIN utenti uu 
                                                        ON uu.id_utente = jj.id_utente_insert
                                                      LEFT OUTER JOIN tbl_ruoli rr
                                                        ON rr.id_ruolo = uu.id_ruolo
                                                      LEFT OUTER JOIN tbl_ruoli rri 
                                                        ON rri.id_ruolo = jj.id_ruolo_insert
				                                      WHERE
                                                             jj.[deleted] = 0 and 
                                                             jj.id_certificato = @id_certificato" 
					                   
				                       UpdateCommand="UPDATE [certificati]
                                                       SET [id_legislatura] = @id_legislatura
                                                          ,[id_persona] = @id_persona
                                                          ,[data_inizio] = @data_inizio
                                                          ,[data_fine] = @data_fine
                                                          ,[note] = @note
                                                          ,[non_valido] = @non_valido
                                                     WHERE [id_certificato] = @id_certificato"
					                   
				                       OnInserted="SqlDataSource2_Inserted">
				                       
				        <SelectParameters>
				            <asp:ControlParameter ControlID="GridView1" Name="id_certificato" PropertyName="SelectedValue"
					        Type="Int32" />
				        </SelectParameters>
				    
				        <DeleteParameters>
				            <asp:Parameter Name="id_certificato" Type="Int32" />
				        </DeleteParameters>
				    
				        <UpdateParameters>
				            <asp:Parameter Name="id_certificato" Type="Int32" />
				            <asp:Parameter Name="id_persona" Type="Int32" />
				            <asp:Parameter Name="note" Type="String" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
                            <asp:Parameter Name="non_valido" Type="Boolean" />
				        </UpdateParameters>
				    
				        <InsertParameters>
				            <asp:Parameter Name="id_persona" Type="Int32" />
				            <asp:Parameter Name="note" Type="String" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
                            <asp:Parameter Name="non_valido" Type="Boolean" />
                            <asp:SessionParameter Name="id_utente_insert" SessionField="user_id" />
                            <asp:SessionParameter Name="nome_utente_insert" SessionField="user_name" />
                            <asp:SessionParameter Name="id_ruolo_insert" SessionField="user_id_role" />
				            <asp:Parameter Direction="Output" Name="id_certificato" Type="Int32" />
				        </InsertParameters>
			        </asp:SqlDataSource>
			        
			        <asp:SqlDataSource ID="SqlDataSource5" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                       
				                       SelectCommand="SELECT [id_legislatura], 
				                                             [num_legislatura] 
				                                      FROM [legislature]">
			        </asp:SqlDataSource>
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
		    
		    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" 
		                            runat="server"
		                            BehaviorID="ModalPopup1" 
		                            PopupControlID="PanelDetails"
			                        BackgroundCssClass="modalBackground" 
			                        DropShadow="true" 
			                        TargetControlID="ButtonDetailsFake" >
			</cc1:ModalPopupExtender>
			
		    <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
		</asp:Panel>
	    </div>
	</div>
	<%--Fix per lo stile dei calendarietti--%>
	<asp:TextBox ID="TextBoxCalendarFake" runat="server" style="display: none;"></asp:TextBox>
	<cc1:CalendarExtender ID="CalendarExtenderFake" runat="server" TargetControlID="TextBoxCalendarFake" Format="dd/MM/yyyy"></cc1:CalendarExtender>
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
</asp:Content>