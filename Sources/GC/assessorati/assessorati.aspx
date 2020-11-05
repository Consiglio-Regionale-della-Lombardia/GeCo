<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true"
    CodeFile="assessorati.aspx.cs" Inherits="assessorati_assessorati" Title="Pagina senza titolo" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
	<tr>
	    <td>
		&nbsp;
	    </td>
	</tr>
	<tr>
	    <td>
		<asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSource3" Width="50%">
		    <ItemStyle Font-Bold="True" />
		    <ItemTemplate>
			<asp:Label ID="nomeLabel" runat="server" Text='<%# Eval("nome") + " " + Eval("cognome") %>' />
			&gt; ASSESSORATI
		    </ItemTemplate>
		</asp:DataList>
		<asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		    SelectCommand="SELECT [nome], [cognome] FROM [persona] WHERE ([id_persona] = @id_persona)">
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
		    <ul>
			<li><a href="../persona/dettaglio.aspx">ANAGRAFICA</a></li>
			<li><a href="../gruppi_politici/gruppi_politici.aspx">GRUPPI POLITICI</a></li>
			<li><a href="../cariche/cariche.aspx">CARICHE</a></li>
			<li><a href="../sospensioni/sospensioni.aspx">SOSPENSIONI</a></li>
			<li><a href="../sostituzioni/sostituzioni.aspx">SOSTITUZIONI</a></li>
			<li><a href="../missioni/missioni.aspx">MISSIONI</a></li>
			<li><a href="../aspettative/aspettative.aspx">ASPETTATIVE</a></li>
			<li id="selected"><a href="../assessorati/assessorati.aspx">ASSESSORATI</a></li>
			<li><a href="../pratiche/pratiche.aspx">PRATICHE</a></li>
			<li><a href="../presenze/presenze.aspx">PRES./ASS.</a></li>
			<li><a href="../varie/varie.aspx">VARIE</a></li>
		    </ul>
		</div>
		<div id="tab_content">
		    <div id="tab_content_content">
			<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
			    <ContentTemplate>
				<table>
				    <tr>
					<td valign="top" width="230">
					    Seleziona legislatura:
					    <asp:DropDownList ID="DropDownListLegislatura" runat="server" DataSourceID="SqlDataSourceLegislature"
						DataTextField="num_legislatura" DataValueField="id_legislatura" Width="70px"
						AppendDataBoundItems="True">
						<asp:ListItem Text="(nessuna)" Value="" />
					    </asp:DropDownList>
					    <asp:SqlDataSource ID="SqlDataSourceLegislature" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						SelectCommand="SELECT [id_legislatura], [num_legislatura] FROM [legislature]">
					    </asp:SqlDataSource>
					</td>
					<td valign="top" width="230">
					    Seleziona data:
					    <asp:TextBox ID="TextBoxFiltroData" runat="server" Width="70px"></asp:TextBox>
					    <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
					    <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="TextBoxFiltroData"
						PopupButtonID="ImageFiltroData">
					    </cc1:CalendarExtender>
					    <asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
					    </asp:ScriptManager>
					    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" ControlToValidate="TextBoxFiltroData"
						runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						ValidationGroup="FiltroData" />
					</td>
					<td valign="top">
					    <asp:Button ID="ButtonFiltri" runat="server" Text="Applica" OnClick="ButtonFiltri_Click"
						ValidationGroup="FiltroData" />
					</td>
				    </tr>
				</table>
				<br />
				<br />
				<asp:GridView ID="GridView1" runat="server" AllowPaging="True" AllowSorting="True"
				    AutoGenerateColumns="False" CellPadding="5" CssClass="tab_gen" DataSourceID="SqlDataSource1"
				    GridLines="None" DataKeyNames="id_rec">
				    <EmptyDataTemplate>
					<table width="100%" class="tab_gen">
					    <tr>
						<th align="center">
						    Nessun record trovato.
						</th>
						<th width="100">
						    <% if (role <= 2) { %>
						    <asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
							CausesValidation="false" />
						    <% } %>
						</th>
					    </tr>
					</table>
				    </EmptyDataTemplate>
                    <AlternatingRowStyle BackColor="#b2cca7" />	
				    <Columns>
					<asp:BoundField DataField="nome_assessorato" HeaderText="Assessorato" SortExpression="nome_assessorato" />
					<asp:BoundField DataField="data_inizio" HeaderText="Dal" SortExpression="data_inizio"
					    DataFormatString="{0:dd/MM/yyyy}" />
					<asp:BoundField DataField="data_fine" HeaderText="Al" SortExpression="data_fine"
					    DataFormatString="{0:dd/MM/yyyy}" />
					<asp:TemplateField>
					    <ItemTemplate>
						<asp:LinkButton ID="LinkButtonDettagli" runat="server" CausesValidation="False" Text="Dettagli"
						    OnClick="LinkButtonDettagli_Click"></asp:LinkButton>
					    </ItemTemplate>
					    <HeaderTemplate>
						<% if (role <= 2) { %>
						<asp:Button ID="Button1" runat="server" Text="Nuovo..." OnClick="Button1_Click" CssClass="button"
						    CausesValidation="false" />
						<% } %>
					    </HeaderTemplate>
					    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
					</asp:TemplateField>
				    </Columns>
				</asp:GridView>
				<asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				    SelectCommand="SELECT * FROM join_persona_assessorati AS jj 
					    WHERE jj.deleted = 0 AND jj.id_persona = @id">
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
			<asp:Panel ID="PanelDetails" runat="server" BackColor="White" BorderColor="DarkSeaGreen"
			    BorderWidth="2px" Width="500" ScrollBars="Vertical" Style="padding: 10px; display: none; max-height: 500px;">
			    <div align="center">
				<br />
				<h3>
				    ASSESSORATI
				</h3>
				<br />
			    <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
				<ContentTemplate>
				    <asp:DetailsView ID="DetailsView1" runat="server" AutoGenerateRows="False" CssClass="tab_det" Width="420px"
					DataKeyNames="id_rec" DataSourceID="SqlDataSource2" OnModeChanged="DetailsView1_ModeChanged" OnItemInserted="DetailsView1_ItemInserted"
					OnItemInserting="DetailsView1_ItemInserting" OnItemUpdated="DetailsView1_ItemUpdated"
					OnItemUpdating="DetailsView1_ItemUpdating" OnItemDeleted="DetailsView1_ItemDeleted">
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
					    <asp:TemplateField HeaderText="Assessorato" SortExpression="nome_assessorato">
						<ItemTemplate>
						    <asp:Label ID="LabelAssessorato" runat="server" Text='<%# Bind("nome_assessorato") %>'></asp:Label>
						</ItemTemplate>
						<EditItemTemplate>
						    <asp:TextBox ID="TextBoxAssessorato" runat="server" Text='<%# Bind("nome_assessorato") %>'></asp:TextBox>
						    <asp:RequiredFieldValidator ID="RequiredFieldValidatorAssessorato" ControlToValidate="TextBoxAssessorato"
							runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						    <asp:RegularExpressionValidator ID="RegularExpressionValidatorAssessorato" ControlToValidate="TextBoxAssessorato"
							runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							ValidationGroup="ValidGroup" />
						</EditItemTemplate>
						<InsertItemTemplate>
						    <asp:TextBox ID="TextBoxAssessorato" runat="server" Text='<%# Bind("nome_assessorato") %>'></asp:TextBox>
						    <asp:RequiredFieldValidator ID="RequiredFieldValidatorAssessorato" ControlToValidate="TextBoxAssessorato"
							runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						    <asp:RegularExpressionValidator ID="RegularExpressionValidatorAssessorato" ControlToValidate="TextBoxAssessorato"
							runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							ValidationGroup="ValidGroup" />
						</InsertItemTemplate>
					    </asp:TemplateField>
					    <asp:TemplateField HeaderText="Dal" SortExpression="data_inizio">
						<ItemTemplate>
						    <asp:Label ID="LabelDataInizio" runat="server" Text='<%# Bind("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:Label>
						</ItemTemplate>
						<EditItemTemplate>
						    <asp:TextBox ID="DataInizioEdit" runat="server" Text='<%# Bind("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						    <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioEdit" runat="server" />
						    <cc1:CalendarExtender ID="CalendarExtenderDataInizioEdit" runat="server" TargetControlID="DataInizioEdit"
							PopupButtonID="ImageDataInizioEdit">
						    </cc1:CalendarExtender>
						    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="DataInizioEdit"
							runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						    <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizioEdit" ControlToValidate="DataInizioEdit"
							runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							ValidationGroup="ValidGroup" />
						</EditItemTemplate>
						<InsertItemTemplate>
						    <asp:TextBox ID="DataInizioInsert" runat="server" Text='<%# Bind("data_inizio", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						    <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioInsert" runat="server" />
						    <cc1:CalendarExtender ID="CalendarExtenderDataInizioInsert" runat="server" TargetControlID="DataInizioInsert"
							PopupButtonID="ImageDataInizioInsert">
						    </cc1:CalendarExtender>
						    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" ControlToValidate="DataInizioInsert"
							runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
						    <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizioInsert" ControlToValidate="DataInizioInsert"
							runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							ValidationGroup="ValidGroup" />
						</InsertItemTemplate>
					    </asp:TemplateField>
					    <asp:TemplateField HeaderText="Al" SortExpression="data_fine">
						<ItemTemplate>
						    <asp:Label ID="LabelDataFine" runat="server" Text='<%# Bind("data_fine", "{0:dd/MM/yyyy}") %>'></asp:Label>
						</ItemTemplate>
						<EditItemTemplate>
						    <asp:TextBox ID="DataFineEdit" runat="server" Text='<%# Bind("data_fine", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						    <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineEdit" runat="server" />
						    <cc1:CalendarExtender ID="CalendarExtenderDataFineEdit" runat="server" TargetControlID="DataFineEdit"
							PopupButtonID="ImageDataFineEdit">
						    </cc1:CalendarExtender>
						    <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFineEdit" ControlToValidate="DataFineEdit"
							runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							ValidationGroup="ValidGroup" />
						</EditItemTemplate>
						<InsertItemTemplate>
						    <asp:TextBox ID="DataFineInsert" runat="server" Text='<%# Bind("data_fine", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
						    <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineInsert" runat="server" />
						    <cc1:CalendarExtender ID="CalendarExtenderDataFineInsert" runat="server" TargetControlID="DataFineInsert"
							PopupButtonID="ImageDataFineInsert">
						    </cc1:CalendarExtender>
						    <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataFineInsert" ControlToValidate="DataFineInsert"
							runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
							ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							ValidationGroup="ValidGroup" />
						</InsertItemTemplate>
					    </asp:TemplateField>
					    <asp:TemplateField HeaderText="Indirizzo" SortExpression="indirizzo">
						<ItemTemplate>
						    <asp:Label ID="LabelIndirizzo" runat="server" Text='<%# Bind("indirizzo") %>'></asp:Label>
						</ItemTemplate>
						<EditItemTemplate>
						    <asp:TextBox ID="TextBoxIndirizzo" runat="server" Text='<%# Bind("indirizzo") %>'
							MaxLength='50'></asp:TextBox>
						</EditItemTemplate>
						<InsertItemTemplate>
						    <asp:TextBox ID="TextBoxIndirizzo" runat="server" Text='<%# Bind("indirizzo") %>'
							MaxLength='50'></asp:TextBox>
						</InsertItemTemplate>
					    </asp:TemplateField>
					    <asp:TemplateField HeaderText="Telefono" SortExpression="telefono">
						<ItemTemplate>
						    <asp:Label ID="LabelTelefono" runat="server" Text='<%# Bind("telefono") %>'></asp:Label>
						</ItemTemplate>
						<EditItemTemplate>
						    <asp:TextBox ID="TextBoxTelefono" runat="server" Text='<%# Bind("telefono") %>' MaxLength='50'></asp:TextBox>
						    <asp:RegularExpressionValidator ID="RegularExpressionValidatorTelefono" ControlToValidate="TextBoxTelefono"
							runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							ValidationGroup="ValidGroup" />
						</EditItemTemplate>
						<InsertItemTemplate>
						    <asp:TextBox ID="TextBoxTelefono" runat="server" Text='<%# Bind("telefono") %>' MaxLength='50'></asp:TextBox>
						    <asp:RegularExpressionValidator ID="RegularExpressionValidatorTelefono" ControlToValidate="TextBoxTelefono"
							runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							ValidationGroup="ValidGroup" />
						</InsertItemTemplate>
					    </asp:TemplateField>
					    <asp:TemplateField HeaderText="Fax" SortExpression="fax">
						<ItemTemplate>
						    <asp:Label ID="LabelFax" runat="server" Text='<%# Bind("fax") %>'></asp:Label>
						</ItemTemplate>
						<EditItemTemplate>
						    <asp:TextBox ID="TextBoxFax" runat="server" Text='<%# Bind("fax") %>' MaxLength='50'></asp:TextBox>
						    <asp:RegularExpressionValidator ID="RegularExpressionValidatorFax" ControlToValidate="TextBoxFax"
							runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							ValidationGroup="ValidGroup" />
						</EditItemTemplate>
						<InsertItemTemplate>
						    <asp:TextBox ID="TextBoxFax" runat="server" Text='<%# Bind("fax") %>' MaxLength='50'></asp:TextBox>
						    <asp:RegularExpressionValidator ID="RegularExpressionValidatorFax" ControlToValidate="TextBoxFax"
							runat="server" Display="Dynamic" ErrorMessage="Solo cifre ammesse." ValidationExpression="^[0-9]+$"
							ValidationGroup="ValidGroup" />
						</InsertItemTemplate>
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
						    <asp:Button ID="Button4" runat="server" CausesValidation="False" CommandName="Cancel"
							Text="Chiudi" CssClass="button" OnClick="ButtonAnnulla_Click" />
						</InsertItemTemplate>
						<ItemTemplate>
						    <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
							Text="Modifica" Visible="<%# (role <= 2) ? true : false %>" />
						    <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
							Text="Elimina" Visible="<%# (role <= 2) ? true : false %>" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
						    <asp:Button ID="Button4" runat="server" CausesValidation="False" CommandName="Cancel"
							Text="Chiudi" CssClass="button" OnClick="ButtonAnnulla_Click" />
						</ItemTemplate>
						<ControlStyle CssClass="button" />
					    </asp:TemplateField>
					</Fields>
				    </asp:DetailsView>
				    <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					SelectCommand="SELECT * FROM join_persona_assessorati AS jj INNER JOIN 
					    legislature AS ll ON jj.id_legislatura = ll.id_legislatura
					    WHERE id_rec = @id_rec" DeleteCommand="UPDATE [join_persona_assessorati] SET [deleted] = 1 WHERE [id_rec] = @id_rec"
					InsertCommand="INSERT INTO [join_persona_assessorati] ([id_legislatura], [id_persona], [nome_assessorato], [data_inizio], [data_fine], [indirizzo], [telefono], [fax]) VALUES (@id_legislatura, @id_persona, @nome_assessorato, @data_inizio, @data_fine, @indirizzo, @telefono, @fax); SELECT @id_rec = SCOPE_IDENTITY();"
					UpdateCommand="UPDATE [join_persona_assessorati] SET [id_legislatura] = @id_legislatura, [id_persona] = @id_persona, [nome_assessorato] = @nome_assessorato, [data_inizio] = @data_inizio, [data_fine] = @data_fine, [indirizzo] = @indirizzo, [telefono] = @telefono, [fax] = @fax WHERE [id_rec] = @id_rec"
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
					    <asp:Parameter Name="nome_assessorato" Type="String" />
					    <asp:Parameter Name="data_inizio" Type="DateTime" />
					    <asp:Parameter Name="data_fine" Type="DateTime" />
					    <asp:Parameter Name="indirizzo" Type="String" />
					    <asp:Parameter Name="telefono" Type="String" />
					    <asp:Parameter Name="fax" Type="String" />
					    <asp:Parameter Name="id_rec" Type="Int32" />
					</UpdateParameters>
					<InsertParameters>
					    <asp:Parameter Name="id_legislatura" Type="Int32" />
					    <asp:Parameter Name="id_persona" Type="Int32" />
					    <asp:Parameter Name="nome_assessorato" Type="String" />
					    <asp:Parameter Name="data_inizio" Type="DateTime" />
					    <asp:Parameter Name="data_fine" Type="DateTime" />
					    <asp:Parameter Name="indirizzo" Type="String" />
					    <asp:Parameter Name="telefono" Type="String" />
					    <asp:Parameter Name="fax" Type="String" />
					    <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
					</InsertParameters>
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
			    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" runat="server" PopupControlID="PanelDetails"
				BackgroundCssClass="modalBackground" DropShadow="true" TargetControlID="ButtonDetailsFake" />
			    <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
			</asp:Panel>
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
		<b><a href="../persona/dettaglio.aspx">« Indietro</a></b>
	    </td>
	</tr>
	<tr>
	    <td>
		&nbsp;
	    </td>
	</tr>
    </table>
</asp:Content>
