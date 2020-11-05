<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="aspettative.aspx.cs" 
         Inherits="aspettative_aspettative" 
         Title="Persona > Aspettative" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
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
		                                  WHERE pp.id_persona = @id_persona">
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
					<td valign="middle" width="230">
					    Seleziona legislatura:
					    <asp:DropDownList ID="DropDownListLegislatura" runat="server" DataSourceID="SqlDataSourceLegislature"
						DataTextField="num_legislatura" DataValueField="id_legislatura" Width="70px"
						AppendDataBoundItems="True">
						<asp:ListItem Text="(tutte)" Value="" />
					    </asp:DropDownList>
					    <asp:SqlDataSource ID="SqlDataSourceLegislature" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
					    </asp:SqlDataSource>
					</td>
					<td valign="middle" width="230">
					    Seleziona data:
					    <asp:TextBox ID="TextBoxFiltroData" 
					                 runat="server" 
					                 Width="70px">
					    </asp:TextBox>
					    <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
					    <cc1:CalendarExtender ID="CalendarExtender3" 
					                          runat="server" 
					                          TargetControlID="TextBoxFiltroData"
						                      PopupButtonID="ImageFiltroData" 
						                      Format="dd/MM/yyyy">
					    </cc1:CalendarExtender>
					    <asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
					    </asp:ScriptManager>
					    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
					    ControlToValidate="TextBoxFiltroData"
						runat="server" 
						ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						Display="Dynamic"
						ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						ValidationGroup="FiltroData" />
					</td>
					<td valign="middle">
					    <asp:Button ID="ButtonFiltri" 
					    runat="server" 
					    Text="Applica" 
					    OnClick="ButtonFiltri_Click"
						ValidationGroup="FiltroData" />
					</td>
				    </tr>
				</table>
				<br />
				<br />
				
				<asp:GridView ID="GridView1" 
				              runat="server" 
				              AllowPaging="True"
				              PagerStyle-HorizontalAlign="Center" 
				              AllowSorting="True"
				              AutoGenerateColumns="False" 
				              CellPadding="5" 
				              CssClass="tab_gen" 
				              DataSourceID="SqlDataSource1"
				              GridLines="None" 
				              DataKeyNames="id_rec">
				    
				    <EmptyDataTemplate>
					    <table width="100%" class="tab_gen">
					        <tr>
						    <th align="center">
						        Nessun record trovato.
						    </th>
						    <th width="100">
						        <% if (role <= 2) { %>
						        <asp:Button ID="Button1" 
						                    runat="server" 
						                    Text="Nuovo..." 
						                    OnClick="Button1_Click" 
						                    CssClass="button"
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
					
					<asp:BoundField DataField="numero_pratica" 
					HeaderText="Numero Pratica" 
					SortExpression="numero_pratica" />
					
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
						<% if (role <= 2) { %>
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
				                   
				                   SelectCommand="SELECT ll.id_legislatura, 
				                                         ll.num_legislatura, 
				                                         jj.* 
						                          FROM join_persona_aspettative AS jj 
						                          INNER JOIN legislature AS ll 
						                            ON jj.id_legislatura = ll.id_legislatura
						                          WHERE jj.deleted = 0 
						                            AND jj.id_persona = @id">
				    <SelectParameters>
					<asp:SessionParameter Name="id" SessionField="id_persona" />
				    </SelectParameters>
				</asp:SqlDataSource>
			    </ContentTemplate>
			</asp:UpdatePanel>
			<br />
			<div align="right">
			    <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click"><img src="../img/page_white_excel.png" alt="" align="top" /> Esporta</asp:LinkButton>
			    -
			    <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click"><img src="../img/page_white_acrobat.png" alt="" align="top" /> Esporta</asp:LinkButton>
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
				    ASPETTATIVE
				</h3>
				<br />
			    <asp:UpdatePanel ID="UpdatePanelDetails" 
			                     runat="server" 
			                     UpdateMode="Conditional">
				<ContentTemplate>
				    <asp:DetailsView ID="DetailsView1" 
				                     runat="server" 
				                     AutoGenerateRows="False" 
				                     CssClass="tab_det" 
				                     Width="420px"
					                 DataSourceID="SqlDataSource2" 					                 
					                 DataKeyNames="id_rec"
					                 
					                 OnModeChanged="DetailsView1_ModeChanged" 
					                 OnItemInserted="DetailsView1_ItemInserted" 
					                 OnItemInserting="DetailsView1_ItemInserting"
					                 OnItemUpdated="DetailsView1_ItemUpdated" 
					                 OnItemUpdating="DetailsView1_ItemUpdating"
					                 OnItemDeleted="DetailsView1_ItemDeleted" >
					                 
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
							    DataValueField="id_legislatura" Width="200px" AppendDataBoundItems="True">
							    <asp:ListItem Value="" Text="(seleziona)" />
						        </asp:DropDownList>
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" ControlToValidate="DropDownListLeg"
							    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        <asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
							    SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
						        </asp:SqlDataSource>
						    </InsertItemTemplate>
						    <EditItemTemplate>
						        <asp:DropDownList ID="DropDownListLeg" runat="server" DataSourceID="SqlDataSourceLeg"
							    SelectedValue='<%# Eval("id_legislatura") %>' DataTextField="num_legislatura"
							    DataValueField="id_legislatura" Width="200px" AppendDataBoundItems="True">
							    <asp:ListItem Value="" Text="(seleziona)" />
						        </asp:DropDownList>
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" ControlToValidate="DropDownListLeg"
							    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        <asp:SqlDataSource ID="SqlDataSourceLeg" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
							    SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
						        </asp:SqlDataSource>
						    </EditItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Numero Pratica" SortExpression="numero_pratica">
						    <ItemTemplate>
						        <asp:Label ID="LabelNumeroPratica" runat="server" Text='<%# Bind("numero_pratica") %>'></asp:Label>
						    </ItemTemplate>
						    <EditItemTemplate>
						        <asp:TextBox ID="TextBoxNumeroPratica" runat="server" Text='<%# Bind("numero_pratica") %>'
							    MaxLength='50'></asp:TextBox>
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorNumeroPratica" ControlToValidate="TextBoxNumeroPratica"
							    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        <asp:RegularExpressionValidator ID="RegularExpressionValidatorNumeroPratica" ControlToValidate="TextBoxNumeroPratica"
							    runat="server" Display="Dynamic" ErrorMessage="Ammesse cifre, '.' e '/'." ValidationExpression="^[0-9./]+$"
							    ValidationGroup="ValidGroup" />
						    </EditItemTemplate>
						    <InsertItemTemplate>
						        <asp:TextBox ID="TextBoxNumeroPratica" runat="server" Text='<%# Bind("numero_pratica") %>'
							    MaxLength='50'></asp:TextBox>
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorNumeroPratica" ControlToValidate="TextBoxNumeroPratica"
							    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        <asp:RegularExpressionValidator ID="RegularExpressionValidatorNumeroPratica" ControlToValidate="TextBoxNumeroPratica"
							    runat="server" Display="Dynamic" ErrorMessage="Ammesse cifre, '.' e '/'." ValidationExpression="^[0-9./]+$"
							    ValidationGroup="ValidGroup" />
						    </InsertItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
						    <ItemTemplate>
						        <asp:Label ID="Label1" 
						                   runat="server" 
						                   Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
						        </asp:Label>
						    </ItemTemplate>
						    
						    <InsertItemTemplate>
						        <asp:TextBox ID="aspettative_ins_dataSince" 
						                     runat="server" >
						        </asp:TextBox>
						        <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
						        <cc1:CalendarExtender ID="CalendarExtender1" 
						        runat="server" 
						        TargetControlID="aspettative_ins_dataSince"
							    PopupButtonID="Image1" 
							    Format="dd/MM/yyyy" >
						        </cc1:CalendarExtender>
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="aspettative_ins_dataSince"
							    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        <asp:RegularExpressionValidator ID="RegularExpressionValidatorDataInizio" ControlToValidate="aspettative_ins_dataSince"
							    runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							    ValidationGroup="ValidGroup" />
						    </InsertItemTemplate>
						    
						    <EditItemTemplate>
						        <asp:TextBox ID="aspettative_mod_dataSince" 
						        runat="server" 
						        Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
						        </asp:TextBox>
						        <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
						        <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="aspettative_mod_dataSince"
							    PopupButtonID="Image1" 
							    Format="dd/MM/yyyy">
						        </cc1:CalendarExtender>
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="aspettative_mod_dataSince"
							    runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						        <asp:RegularExpressionValidator ID="RequiredFieldValidatoraspettative_mod_dataSince"
							    ControlToValidate="aspettative_mod_dataSince" runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
							    Display="Dynamic" ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							    ValidationGroup="ValidGroup" />
						    </EditItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
						    <ItemTemplate>
						        <asp:Label ID="Label2" 
						        runat="server" 
						        Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
						        </asp:Label>
						    </ItemTemplate>
						    
						    <InsertItemTemplate>
						        <asp:TextBox ID="aspettative_ins_dataTo" 
						        runat="server" >
						        </asp:TextBox>
						        <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
						        <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="aspettative_ins_dataTo"
							    PopupButtonID="Image2" Format="dd/MM/yyyy" >
						        </cc1:CalendarExtender>
						        <asp:RegularExpressionValidator ID="RequiredFieldValidatoraspettative_ins_dataTo"
							    ControlToValidate="aspettative_ins_dataTo" runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
							    Display="Dynamic" ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							    ValidationGroup="ValidGroup" />
						    </InsertItemTemplate>
						    
						    <EditItemTemplate>
						        <asp:TextBox ID="aspettative_mod_dataTo" 
						        runat="server" 
						        Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
						        </asp:TextBox>
						        <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
						        <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="aspettative_mod_dataTo"
							    PopupButtonID="Image2" Format="dd/MM/yyyy">
						        </cc1:CalendarExtender>
						        <asp:RegularExpressionValidator ID="RequiredFieldValidatoraspettative_mod_dataTo"
							    ControlToValidate="aspettative_mod_dataTo" runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA."
							    Display="Dynamic" ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							    ValidationGroup="ValidGroup" />
						    </EditItemTemplate>
					        </asp:TemplateField>
					        
					        <asp:TemplateField HeaderText="Note" SortExpression="note">
						    <EditItemTemplate>
						        <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
							    Text='<%# Bind("note") %>'></asp:TextBox>
						    </EditItemTemplate>
						    <InsertItemTemplate>
						        <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
							    Text='<%# Bind("note") %>'></asp:TextBox>
						    </InsertItemTemplate>
						    <ItemTemplate>
						        <asp:Label ID="LabelNote" runat="server" Text='<%# Bind("note") %>'></asp:Label>
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
							    CommandName="Cancel" OnClick="ButtonAnnulla_Click" />
						    </InsertItemTemplate>
						    <ItemTemplate>
						        <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
							    Text="Modifica" Visible="<%# (role <= 2) ? true : false %>" />
						        <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
							    Text="Elimina" Visible="<%# (role <= 2) ? true : false %>" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
						        <asp:Button ID="Button4" runat="server" CausesValidation="False" Text="Chiudi" CssClass="button"
							    CommandName="Cancel" OnClick="ButtonAnnulla_Click" />
						    </ItemTemplate>
						    <ControlStyle CssClass="button" />
					        </asp:TemplateField>
					    </Fields>
				    </asp:DetailsView>
				    
				    <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					DeleteCommand="UPDATE [join_persona_aspettative] SET [deleted] = 1 WHERE [id_rec] = @id_rec"
					InsertCommand="INSERT INTO [join_persona_aspettative] ([id_legislatura], [id_persona], [numero_pratica], [data_inizio], [data_fine], [note]) VALUES (@id_legislatura, @id_persona, @numero_pratica, @data_inizio, @data_fine, @note); SELECT @id_rec = SCOPE_IDENTITY();"
					SelectCommand="SELECT * FROM join_persona_aspettative AS jj INNER JOIN
						legislature AS ll ON jj.id_legislatura = ll.id_legislatura
						WHERE id_rec = @id_rec" UpdateCommand="UPDATE [join_persona_aspettative] SET [id_legislatura] = @id_legislatura, [id_persona] = @id_persona, [numero_pratica] = @numero_pratica, [data_inizio] = @data_inizio, [data_fine] = @data_fine, [note] = @note WHERE [id_rec] = @id_rec"
					OnInserted="SqlDataSource2_Inserted">
					<SelectParameters>
					    <asp:ControlParameter ControlID="GridView1" Name="id_rec" PropertyName="SelectedValue"
						Type="Int32" />
					</SelectParameters>
					<DeleteParameters>
					    <asp:Parameter Name="id_rec" Type="Int32" />
					</DeleteParameters>
					<UpdateParameters>
					    <asp:Parameter Name="id_legislatura" Type="Int32" />
					    <asp:Parameter Name="id_persona" Type="Int32" />
					    <asp:Parameter Name="numero_pratica" Type="String" />
					    <asp:Parameter Name="data_inizio" Type="DateTime" />
					    <asp:Parameter Name="data_fine" Type="DateTime" />
					    <asp:Parameter Name="note" Type="String" />
					    <asp:Parameter Name="id_rec" Type="Int32" />
					</UpdateParameters>
					<InsertParameters>
					    <asp:Parameter Name="id_legislatura" Type="Int32" />
					    <asp:Parameter Name="id_persona" Type="Int32" />
					    <asp:Parameter Name="numero_pratica" Type="String" />
					    <asp:Parameter Name="data_inizio" Type="DateTime" />
					    <asp:Parameter Name="data_fine" Type="DateTime" />
					    <asp:Parameter Name="note" Type="String" />
					    <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
					</InsertParameters>
				    </asp:SqlDataSource>
				    
				    <asp:SqlDataSource ID="SqlDataSource5" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
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
			    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" BehaviorID="ModalPopup1" runat="server" PopupControlID="PanelDetails"
				BackgroundCssClass="modalBackground" DropShadow="true" TargetControlID="ButtonDetailsFake" />
			    <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
			</asp:Panel>
		    </div>
		</div>
		<%--Fix per lo stile dei calendarietti--%>
		<asp:TextBox ID="TextBoxCalendarFake" runat="server" style="display: none;"></asp:TextBox>
		<cc1:CalendarExtender ID="CalendarExtenderFake" runat="server" TargetControlID="TextBoxCalendarFake" Format="dd/MM/yyyy" ></cc1:CalendarExtender>
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
