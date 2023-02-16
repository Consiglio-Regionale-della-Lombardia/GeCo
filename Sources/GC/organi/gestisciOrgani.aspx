<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         MasterPageFile="~/MasterPage.master"
         CodeFile="gestisciOrgani.aspx.cs" 
         Inherits="organi_gestisciOrgani" 
         Title="Organi > Ricerca" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
	<b>ORGANI &gt; RICERCA</b>
	
	<br />
	<br />
	
	<asp:ScriptManager ID="ScriptManager2" 
	                   runat="server" 
	                   EnableScriptGlobalization="True">
	</asp:ScriptManager>
	
	<asp:UpdatePanel ID="UpdatePanel1" runat="server">
	    <ContentTemplate>
		<div class="pannello_ricerca">
		    <asp:ImageButton ID="ImageButtonRicerca" 
		                     runat="server" 
		                     ImageUrl="~/img/magnifier_arrow.png" />
		                     
		    <asp:Label ID="LabelRicerca" 
		               runat="server" 
		               Text="">
		    </asp:Label>
		    
		    <cc1:CollapsiblePanelExtender ID="cpe" 
		                                  runat="Server" 
		                                  TargetControlID="PanelRicerca"
			                              CollapsedSize="0" 
			                              Collapsed="True" 
			                              ExpandControlID="ImageButtonRicerca" 
			                              CollapseControlID="ImageButtonRicerca"
			                              AutoCollapse="False" 
			                              AutoExpand="False" 
			                              ScrollContents="False" 
			                              TextLabelID="LabelRicerca"
			                              CollapsedText="Apri Ricerca" 
			                              ExpandedText="Nascondi Ricerca" 
			                              ExpandDirection="Vertical" >
			</cc1:CollapsiblePanelExtender>
			                              
		    <asp:Panel ID="PanelRicerca" runat="server">
			    <br />
			    
			    <table>
			    <tr>
				    <td valign="middle" width="230">
				        Seleziona legislatura:
				        <asp:DropDownList ID="DropDownListLegislatura" 
				                          runat="server" 
				                          DataSourceID="SqlDataSourceLegislature"
					                      DataTextField="num_legislatura" 
					                      DataValueField="id_legislatura" 
					                      Width="70px"
					                      AppendDataBoundItems="True">
					        <asp:ListItem Text="(tutte)" Value="" ></asp:ListItem>
				        </asp:DropDownList>
				        
				        <asp:SqlDataSource ID="SqlDataSourceLegislature" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                       SelectCommand="SELECT [id_legislatura], 
					                                             [num_legislatura] 
					                                      FROM [legislature]">
				        </asp:SqlDataSource>
				    </td>
    				
				    <td valign="middle" width="230">
				        Seleziona data:
				        <asp:TextBox ID="TextBoxFiltroData" 
				                     runat="server" 
				                     Text='<%# Bind("data_fine") %>'
					                 Width="70px">
				        </asp:TextBox>
				        <img alt="calendar" 
				             src="../img/calendar_month.png" 
				             id="ImageFiltroData" 
				             runat="server" />
				        <cc1:CalendarExtender ID="CalendarExtenderFiltroData" 
				                              runat="server" 
				                              TargetControlID="TextBoxFiltroData"
					                          PopupButtonID="ImageFiltroData" Format="dd/MM/yyyy">
				        </cc1:CalendarExtender>
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
		    </asp:Panel>
		</div>
		
		<asp:GridView ID="GridView1" 
		              runat="server" 
		              AllowPaging="True" 
		              PagerStyle-HorizontalAlign="Center" 
		              AllowSorting="True"
		              AutoGenerateColumns="False" 
		              DataKeyNames="id_organo" 
		              DataSourceID="SqlDataSource1"
		              CellPadding="5" 
		              CssClass="tab_gen" 
		              GridLines="None" 
		              
		              OnPageIndexChanging="ButtonFiltri_Click"
		              OnSorting="ButtonFiltri_Click"
		              OnRowDataBound="GridView1_RowDataBound" >
		              
		    <EmptyDataTemplate>
			<table width="100%" class="tab_gen">
			<tr>
				<th align="center">
				    Nessun record trovato.
				</th>
				<th width="100">
				    <% if (role <= 2 || role == 4) { %>
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
			    <asp:BoundField DataField="ordinamento" 
			                    HeaderText="Ord." 
			                    SortExpression="ordinamento"
                                ItemStyle-Width="24px" 
                                ItemStyle-HorizontalAlign="Center" />

			    <asp:BoundField DataField="nome_organo" 
			                    HeaderText="Organo" 
			                    SortExpression="nome_organo" />

			    <asp:BoundField DataField="nome_organo_breve" 
			                    HeaderText="Nome abbreviato" 
			                    SortExpression="nome_organo_breve" />
			    
			    <asp:BoundField DataField="data_inizio" 
			                    HeaderText="Data inizio" 
			                    SortExpression="data_inizio"
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			    
			    <asp:BoundField DataField="data_fine" 
			                    HeaderText="Data fine" 
			                    SortExpression="data_fine"
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			    
			    <asp:TemplateField>
			        <ItemTemplate>
				        <asp:HyperLink ID="HyperLinkDettagli" 
				                       runat="server" 
				                       NavigateUrl='<%# Eval("id_organo", "dettaglio.aspx?id={0}") + Eval("id_legislatura", "&idleg={0}") %>'
				                       Text="Dettagli">
				        </asp:HyperLink>
			        </ItemTemplate>
			        
			        <HeaderTemplate>
				    <% if (role <= 2 || role == 4) { %>
				    <asp:Button ID="Button1" 
				                runat="server" 
				                OnClick="Button1_Click" 
				                Text="Nuovo..." 
				                CssClass="button" />
				    <% } %>
			        </HeaderTemplate>
			        
			        <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
			    </asp:TemplateField>
		    </Columns>
		</asp:GridView>
		
		<asp:SqlDataSource ID="SqlDataSource1" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT * 
		                                  FROM organi AS oo 
		                                  WHERE oo.deleted = 0 and oo.chiuso = 0">
		</asp:SqlDataSource>
	    </ContentTemplate>
	</asp:UpdatePanel>
	
	<br />
	
	<div align="right">
	    <asp:LinkButton ID="LinkButtonExcel" 
	                    runat="server" 
	                    OnClick="LinkButtonExcel_Click">
	        <img src="../img/page_white_excel.png" alt="" align="top" /> 
	        Esporta
	    </asp:LinkButton>
	    -
	    <asp:LinkButton ID="LinkButtonPdf" 
	                    runat="server" 
	                    OnClick="LinkButtonPdf_Click">
	        <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
	        Esporta
	    </asp:LinkButton>
	</div>
    </div>
</asp:Content>