<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true" 
         EnableEventValidation="false" 
         CodeFile="persona_commissione.aspx.cs" 
         Inherits="persona_persona_commissione" 
         Title="Consiglieri > Ricerca"%>

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
				    <td valign="middle" width="200px">
				        <asp:Label ID="Label3"
				                   runat="server"
				                   Text="Legislatura:" 
				                   Width="70px">
				        </asp:Label>
				        
				        <asp:DropDownList ID="DropDownListRicLeg" 
				                          runat="server" 
				                          DataSourceID="SqlDataSourceLegislature"
					                      DataTextField="num_legislatura" 
					                      DataValueField="id_legislatura" 
					                      Width="70px"
					                      AppendDataBoundItems="true">
					        <asp:ListItem Text="(seleziona)" Value="" />
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
				    
				    <td valign="middle" width="200px">
				        <asp:Label ID="Label1"
				                   runat="server"
				                   Text="Nome:">
				        </asp:Label>
				        
				        <asp:TextBox ID="TextBoxRicNome" 
				                     runat="server" 
				                     Width="120px">
				        </asp:TextBox>
				    </td>
				    
				    <td valign="middle" width="200px">
				        <asp:Label ID="Label2"
				                   runat="server"
				                   Text="Cognome:">
				        </asp:Label>
				        
				        <asp:TextBox ID="TextBoxRicCognome" 
				                     runat="server" 
				                     Width="120px">
				        </asp:TextBox>
				    </td>

				    <td valign="middle" align="right">
				        <asp:Button ID="btn_Search" 
				                    runat="server" 
				                    Text="Applica" 
				                    
				                    OnClick="btn_Search_Click" />
				    </td>
			    </tr>
			    
			    <% if (role == 4) { %>
			    <tr>
				    <td valign="middle" width="600px" colspan="4">
				        <asp:Label ID="lbl_Organo"
				                   runat="server"
				                   Text="Organo:" 
				                   Width="70px">
				        </asp:Label>
				        
				        <asp:DropDownList ID="DropDownListOrgano" 
				                          runat="server" 
				                          DataSourceID="SqlDataSourceOrgani"
					                      DataTextField="nome_organo" 
					                      DataValueField="id_organo" 
					                      Width="520px"
					                      AppendDataBoundItems="True">
					        <asp:ListItem Text="(tutti)" Value="0" />
				        </asp:DropDownList>
				        
				        <asp:SqlDataSource ID="SqlDataSourceOrgani" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                       
					                       SelectCommand="SELECT oo.id_organo, 
					                                             ll.num_legislatura + ' - ' + LTRIM(RTRIM(oo.nome_organo)) AS nome_organo 
					                                      FROM organi AS oo
					                                      INNER JOIN legislature AS ll
					                                        ON oo.id_legislatura = ll.id_legislatura 
					                                      WHERE oo.deleted = 0
					                                        AND oo.vis_serv_comm = 1
					                                      ORDER BY ll.durata_legislatura_da DESC, nome_organo" >
				        </asp:SqlDataSource>
				    </td>
				</tr>
				<% } %>
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
                      
                      OnSorting="btn_Search_Click" >
                      
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
		    
		    <Columns>
		        <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
	                <ItemTemplate>
		                <asp:LinkButton ID="lnkbtn_leg" 
                                        runat="server"
                                        Text='<%# Eval("num_legislatura") %>'
                                        Font-Bold="true"
                                        onclientclick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura"), null) %>' >
                        </asp:LinkButton>
	                </ItemTemplate>
			        
	                <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
	            </asp:TemplateField>
			    
			    <asp:TemplateField HeaderText="Commissione" SortExpression="commissione" >
	                <ItemTemplate>
		                <asp:LinkButton ID="lnkbtn_organo" 
                                        runat="server"
                                        Text='<%# Eval("commissione") %>'
                                        Font-Bold="true"
                                        OnClientClick='<%# getPopupURL("../organi/dettaglio.aspx", Eval("id_organo"), null) %>' >
                        </asp:LinkButton>
	                </ItemTemplate>
			        
	                <ItemStyle Font-Bold="True" Width="80px" />
	            </asp:TemplateField>
			    
			    <asp:BoundField DataField="nome_carica" 
			                    HeaderText="Carica" 
			                    SortExpression="ordine" />
			    
			    <asp:TemplateField HeaderText="Cognome" SortExpression="cognome" >
	                <ItemTemplate>
		                <asp:LinkButton ID="lnkbtn_cognome" 
                                        runat="server"
                                        Text='<%# Eval("cognome") %>'
                                        Font-Bold="true" 
                                        OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona"), Eval("id_legislatura")) %>' >
                        </asp:LinkButton>
	                </ItemTemplate>
			        
	                <ItemStyle Font-Bold="True" Width="120px" />
	            </asp:TemplateField>
			    
			    <asp:TemplateField HeaderText="Nome" SortExpression="nome" >
	                <ItemTemplate>     
		                <asp:LinkButton ID="lnkbtn_nome" 
                                        runat="server"
                                        Text='<%# Eval("nome") %>'
                                        Font-Bold="true"
                                        OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona"), Eval("id_legislatura")) %>' >
                        </asp:LinkButton>
	                </ItemTemplate>
			        
	                <ItemStyle Font-Bold="True" Width="120px" />
	            </asp:TemplateField>
			    
			    <asp:TemplateField HeaderText="Gruppo Politico" SortExpression="nome_gruppo" >
	                <ItemTemplate>
		                <asp:LinkButton ID="lnkbtn_gruppo" 
                                        runat="server"
                                        Text='<%# Eval("nome_gruppo") %>'
                                        Font-Bold="true"
                                        onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo"), null) %>' >
                        </asp:LinkButton>
	                </ItemTemplate>
			        
	                <ItemStyle Font-Bold="True" />
	            </asp:TemplateField>
			    
                <%-- HeaderText="Diaria" --%> 
			    <asp:CheckBoxField DataField="diaria" 
			                       HeaderText="Opzione" 
			                       SortExpression="diaria" 
			                       ItemStyle-Width="80px" 
			                       ItemStyle-HorizontalAlign="Center" />
		    </Columns>
		</asp:GridView>
		
		<asp:SqlDataSource ID="SqlDataSource1" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                    
		                   SelectCommand="">
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
	</div>
</div>
</asp:Content>
