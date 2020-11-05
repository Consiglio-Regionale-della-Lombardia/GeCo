<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="gestisciMissioni.aspx.cs" 
         Inherits="missioni_gestisciMissioni" 
         Title="Missioni > Ricerca" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	<b>MISSIONE &gt; RICERCA</b>
	
	<br />
	<br />
	
	<asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
	</asp:ScriptManager>
	
	<asp:UpdatePanel ID="UpdatePanel1" runat="server">
	    <ContentTemplate>
		<div class="pannello_ricerca">
		    <asp:ImageButton ID="ImageButtonRicerca" 
		    runat="server" 
		    ImageUrl="~/img/magnifier_arrow.png" />
		    <asp:Label ID="LabelRicerca" runat="server" Text="">
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
					    <asp:ListItem Text="(tutte)" Value="0" />
				    </asp:DropDownList>
				    
				    <asp:SqlDataSource ID="SqlDataSourceLegislature" 
				                       runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                   
					                   SelectCommand="SELECT id_legislatura, 
					                                         num_legislatura 
					                                  FROM legislature
					                                  ORDER BY durata_legislatura_da DESC">
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
					PopupButtonID="ImageFiltroData" 
					Format="dd/MM/yyyy">
				    </cc1:CalendarExtender>
				    
				    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
				    ControlToValidate="TextBoxFiltroData"
					runat="server" 
					ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					Display="Dynamic"
					ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					ValidationGroup="FiltroData" >
					</asp:RegularExpressionValidator>
				</td>
				
				<td valign="middle" width="230">
				    Seleziona città:
				    <asp:TextBox ID="TextBoxFiltroCitta" 
				    runat="server" 
				    Width="70px">
				    </asp:TextBox>
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
		              AllowSorting="True" 
		              AutoGenerateColumns="False"
	                  CellPadding="5" 
	                  DataKeyNames="id_missione" 
	                  DataSourceID="SqlDataSource1" 
	                  GridLines="None"
	                  CssClass="tab_gen">
	                  
		    <EmptyDataTemplate>
			    <table width="100%" class="tab_gen">
			        <tr>
				    <th align="center">
				        Nessun record trovato.
				    </th>
				    <th width="100">
				        <% if (role <= 2 || role == 8) { %>
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
		        <asp:BoundField DataField="num_legislatura" 
			                    HeaderText="Legislatura" 
			                    SortExpression="durata_legislatura_da" />
			                    
		        <asp:BoundField DataField="codice" 
			                    HeaderText="Codice" 
			                    SortExpression="codice" />			                    
		        
			    <asp:BoundField DataField="oggetto" 
			                    HeaderText="Missione" 
			                    SortExpression="oggetto" />
    			
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
    			
			    <asp:BoundField DataField="luogo" 
			                    HeaderText="Luogo" 
			                    SortExpression="luogo" />
    			
			    <asp:BoundField DataField="citta" 
			                    HeaderText="Città" 
			                    SortExpression="citta" />
    			
			    <asp:BoundField DataField="nazione" 
			                    HeaderText="Nazione" 
			                    SortExpression="nazione" />
    			
    			<asp:BoundField DataField="info_delibera" 
			                    HeaderText="Delibera" 
			                    SortExpression="info_delibera" />			   
    			
    			<%--NavigateUrl='<%# Eval("id_missione", "dettaglio.aspx?id={0}") %>'--%>
			    <asp:TemplateField>
			        <ItemTemplate>
				        <asp:HyperLink ID="HyperLinkDettagli" 
				                       runat="server" 
				                       Text="Dettagli"
				                       NavigateUrl='<%# "dettaglio.aspx?mode=normal&id=" +  Eval("id_missione") + "&sel_leg_id=" + Eval("id_legislatura") %>' >
				        </asp:HyperLink>
			        </ItemTemplate>
    			    
			        <HeaderTemplate>
				    <% if (role <= 2 || role == 8) { %>
				    <asp:Button ID="Button1" 
				                runat="server" 
				                Text="Nuovo..." 
				                CssClass="button" 
				                OnClick="Button1_Click" />
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
                                                 ll.durata_legislatura_da,
		                                         mm.id_missione,
                                                 mm.oggetto,
                                                 mm.data_inizio,
                                                 mm.data_fine,
                                                 mm.luogo,
                                                 mm.citta,
                                                 mm.nazione,
                                                 mm.codice,
                                                 CONVERT(VARCHAR, tbld.tipo_delibera) + ' (' + mm.numero_delibera + ') del ' + CONVERT(VARCHAR, mm.data_delibera, 103) AS info_delibera
                                          FROM missioni AS mm
                                          INNER JOIN legislature AS ll
                                             ON mm.id_legislatura = ll.id_legislatura
                                          LEFT OUTER JOIN tbl_delibere AS tbld
                                             ON mm.id_delibera = tbld.id_delibera
                                          WHERE mm.deleted = 0" >
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