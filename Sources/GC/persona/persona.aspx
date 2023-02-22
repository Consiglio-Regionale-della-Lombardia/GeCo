<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master"
         AutoEventWireup="true" 
         EnableEventValidation="false"
         CodeFile="persona.aspx.cs" 
         Inherits="persona" 
         Title="Consiglieri > Ricerca" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
<asp:ScriptManager ID="ScriptManager1" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>

<b>CONSIGLIERI &gt; RICERCA</b>

<% if (role <= 2) { %>

<script>
    function TogglePanelAmmTrasp()
    {
        var elem = $('#panel_amm_trasparente');
        if (elem.css("display") == "none")
            elem.css("display", "block");
        else
            elem.css("display", "none");
    }
</script>


<div id="command_amm_trasparente" style="float:right;">
    <a href="#" class="linkButtonInv" style="padding:2px 8px;" onclick="TogglePanelAmmTrasp(); return false;">Esportazione per Amministrazione Trasparente</a>
</div>

<div id="panel_amm_trasparente" style="display:none; border:solid 1px #006600; padding:10px; margin:2px 0px;">

	<div id="PanelAmmTrasp_Container" align="center">
        <br />
        <div style="width:92%; text-align:left;">
            <h3>AMMINISTRAZIONE TRASPARENTE - ESPORTAZIONE FILES</h3>
        </div>
		<br />
                
        <div id="panel_periodo">
            <table style="width:90%;">
                <tr>
                    <td valign="middle" style="width:170px;">
                        <b>Periodo di riferimento:</b>
                    </td>
                    <td valign="middle" align="left" style="width:230px;">
				        Data inizio:
				        <asp:TextBox ID="TextBox_DataInizio" 
				            runat="server" 
				            Text=''
					        Width="70px">
					    </asp:TextBox>
				    
				        <img alt="calendar" 
				            src="../img/calendar_month.png" 
				            id="Image_DataInizio" 
				            runat="server" />
				    
				        <cc1:CalendarExtender ID="CalendarExtender_DataInizio" 
				            runat="server" 
				            TargetControlID="TextBox_DataInizio"
					        PopupButtonID="Image_DataInizio" 
					        Format="dd/MM/yyyy">
				        </cc1:CalendarExtender>

                        <br />

                        <asp:RequiredFieldValidator ID="RequiredFieldValidator_DataInizio" 
				            runat="server" 
				            ControlToValidate="TextBox_DataInizio"
				            Display="Dynamic" 
				            ErrorMessage="Campo obbligatorio." 
				            ValidationGroup="FiltroSearch">
				        </asp:RequiredFieldValidator>
				    
				        <asp:RegularExpressionValidator ID="RegexFieldValidator_DataInizio" 
				            ControlToValidate="TextBox_DataInizio"
					        runat="server" 
					        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					        Display="Dynamic"
					        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					        ValidationGroup="FiltroSearch">
					    </asp:RegularExpressionValidator>
				    </td>
                    <td valign="middle"  align="left">
				        Data fine:
				        <asp:TextBox ID="TextBox_DataFine" 
				            runat="server" 
				            Text=''
					        Width="70px">
					    </asp:TextBox>
				    
				        <img alt="calendar" 
				            src="../img/calendar_month.png" 
				            id="Image_DataFine" 
				            runat="server" />
				    
				        <cc1:CalendarExtender ID="CalendarExtender_DataFine" 
				            runat="server" 
				            TargetControlID="TextBox_DataFine"
					        PopupButtonID="Image_DataFine" 
					        Format="dd/MM/yyyy">
				        </cc1:CalendarExtender>

                        <br />

                        <asp:RequiredFieldValidator ID="RequiredFieldValidator_DataFine" 
				            runat="server" 
				            ControlToValidate="TextBox_DataFine"
				            Display="Dynamic" 
				            ErrorMessage="Campo obbligatorio." 
				            ValidationGroup="FiltroSearch">
				        </asp:RequiredFieldValidator>
				    
				        <asp:RegularExpressionValidator ID="RegularExpressionValidator_DataFine" 
				            ControlToValidate="TextBox_DataFine"
					        runat="server" 
					        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					        Display="Dynamic"
					        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					        ValidationGroup="FiltroSearch">
					    </asp:RegularExpressionValidator>
				    </td>
                </tr>
            </table>
        </div>
        <br />
		<div id="panel_buttons" style="height:40px;">
            <table style="width:90%;">
                <tr>
                    <td valign="middle"  align="left" style="width:230px;">
                        <asp:LinkButton ID="LinkButtonExport_Consiglieri" runat="server" 
                            ValidationGroup="FiltroSearch" OnClick="LinkButtonExport_Consiglieri_Click">
                            <img src="../img/page_white_excel.png" alt="" align="top" /> <b>Esporta file Consiglieri</b>
                        </asp:LinkButton>
                    </td>
                    <td valign="middle"  align="left">
                        <asp:LinkButton ID="LinkButtonExport_Assessori" runat="server"
                            ValidationGroup="FiltroSearch" OnClick="LinkButtonExport_Assessori_Click">
                            <img src="../img/page_white_excel.png" alt="" align="top" /> <b>Esporta file Giunta Regionale</b>
                        </asp:LinkButton>
                    </td>
                </tr>
            </table>        
		</div>
    </div>
</div>
<% } %>

<br />
<br />

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
		    <table width="100%">
		    <tr>
		        <td align="left" valign="middle">
		            Legislatura:
		            <asp:DropDownList ID="DropDownListRicLeg" 
		                              runat="server" 
		                              DataSourceID="SqlDataSourceLegislature"
			                          DataTextField="num_legislatura" 
			                          DataValueField="id_legislatura" 
			                          Width="70px"
			                          AppendDataBoundItems="true">
			            <asp:ListItem Text="(tutte)" Value="" />
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
		        
		        <td align="left" valign="middle">
		            Nome:
		            <asp:TextBox ID="TextBoxRicNome" 
		                         runat="server" 
		                         Width="150px">
		            </asp:TextBox>
		        </td>
			    
		        <td align="left" valign="middle">
		            Cognome:
		            <asp:TextBox ID="TextBoxRicCognome" 
		                         runat="server" 
		                         Width="150px">
		            </asp:TextBox>
		        </td>

				<td align="left" valign="middle">
					Chiuso:
					<asp:DropDownList ID="DropDownChiuso" 
		                              runat="server" 
			                          Width="70px">
			            <asp:ListItem Text="No" Value="0" />
						<asp:ListItem Text="Si" Value="1" />
		            </asp:DropDownList>

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
	</div>
	
	<asp:GridView ID="GridView1" 
	              runat="server" 
	              AllowPaging="True" 
	              AllowSorting="True" 
	              PagerStyle-HorizontalAlign="Center"
	              AutoGenerateColumns="False"		             
	              CssClass="tab_gen" 
	              GridLines="None" 
	              DataSourceID="SqlDataSource1"         		                
	              OnRowDataBound="GridView1_RowDataBound" >
	              
	    <EmptyDataTemplate>
		    <table width="100%" class="tab_gen">
		    <tr>
			    <th align="center">
			        Nessun record trovato.
			    </th>
			    <th width="100px">
			        <% if (role <= 2) { %>
			        <asp:Button ID="Button1" 
			                    runat="server" 
			                    Text="Nuovo" 
			                    OnClick="Button1_Click" 
			                    CssClass="button"
			                    Width="100px"
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
		                            OnClientClick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>' >
		            </asp:LinkButton>
		        </ItemTemplate>
		        
		        <ItemStyle HorizontalAlign="center" 
		                   VerticalAlign="Middle"
		                   Width="80px" />
		    </asp:TemplateField>
		    
		    <asp:BoundField DataField="cognome" 
		                    HeaderText="Cognome" 
		                    SortExpression="cognome" 
		                    ItemStyle-Width="120px" 
		                    ItemStyle-VerticalAlign="Middle" />
		    
		    <asp:BoundField DataField="nome" 
		                    HeaderText="Nome" 
		                    SortExpression="nome" 
		                    ItemStyle-Width="120px" 
		                    ItemStyle-VerticalAlign="Middle" />
		    
		    <asp:BoundField DataField="data_nascita" 
		                    HeaderText="Data Nascita" 
		                    SortExpression="data_nascita"
		                    DataFormatString="{0:dd/MM/yyyy}" 
		                    ItemStyle-HorizontalAlign="center" 
		                    ItemStyle-VerticalAlign="Middle" 
		                    ItemStyle-Width="90px" />
		    
		    <asp:BoundField HeaderText="Comune nascita" 
		                    DataField="nome_comune" 
		                    SortExpression="nome_comune" 
		                    ItemStyle-VerticalAlign="Middle" />
		    
		    <asp:TemplateField HeaderText="Gruppo Politico" SortExpression="nome_gruppo">
		        <ItemTemplate>
		            <asp:LinkButton ID="lnkbtn_gruppo" 
		                            runat="server"
		                            Text='<%# Eval("nome_gruppo") %>'
		                            Font-Bold="true" 
		                            OnClientClick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		            </asp:LinkButton>
		        </ItemTemplate>
		        
		        <ItemStyle VerticalAlign="Middle" />
		    </asp:TemplateField>
		    
		    <%--NavigateUrl='<%# Eval("id_persona", "dettaglio.aspx?mode=normal&id={0}") %>'--%>
		    <asp:TemplateField>
		        <ItemTemplate>
			        <asp:HyperLink ID="HyperLinkDettagli" 
			                       runat="server" 
			                       NavigateUrl='<%# "dettaglio.aspx?mode=normal&id=" +  Eval("id_persona") + "&sel_leg_id=" + Eval("id_legislatura") %>'
			                       Text="Dettagli">
			        </asp:HyperLink>				        
		        </ItemTemplate>
		        
		        <HeaderTemplate>
			        <% if (role <= 2) { %>
			        <asp:Button ID="Button1" 
			                    runat="server" 
			                    OnClick="Button1_Click" 
			                    Text="Nuovo" 
			                    Width="100px"
			                    CssClass="button" />
			        <% } %>
		        </HeaderTemplate>
		        
		        <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
		    </asp:TemplateField>
	    </Columns>
	</asp:GridView>
	
	<asp:SqlDataSource ID="SqlDataSource1" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>">
	</asp:SqlDataSource>
    </ContentTemplate>
</asp:UpdatePanel>

<br />

<div align="right">
    <asp:LinkButton ID="LinkButtonExcel" 
                    runat="server" 
                    OnClick="LinkButtonExcel_Click">
        <img src="../img/page_white_excel.png" 
             alt="" 
             align="top" /> 
        Esporta
    </asp:LinkButton>
    -
    <asp:LinkButton ID="LinkButtonPdf" 
                    runat="server" 
                    OnClick="LinkButtonPdf_Click">
        <img src="../img/page_white_acrobat.png" 
             alt="" 
             align="top" /> 
        Esporta
    </asp:LinkButton>
    
    <br />
    <br />
    
    <asp:HyperLink ID="HyperLinkStampe" 
                   runat="server" 
                   NavigateUrl="~/stampe/elenco_stampe_altre.aspx">
        <img src="../img/cards_arrow.png" 
             alt="" 
             align="top" /> 
        <b>
            Altre stampe &raquo;
        </b>
    </asp:HyperLink>
</div>
</div>
</asp:Content>
