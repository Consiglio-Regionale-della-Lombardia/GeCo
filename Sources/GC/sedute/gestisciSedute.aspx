<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master"
         AutoEventWireup="true" 
         EnableEventValidation="false"               
         CodeFile="gestisciSedute.aspx.cs" 
         Inherits="sedute_gestisciSedute" 
         Title="Sedute > Ricerca" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content" />
    <asp:ScriptManager ID="ScriptManager2" 
	                   runat="server" 
	                   EnableScriptGlobalization="True">
	</asp:ScriptManager>
	<b>SEDUTE &gt; RICERCA</b>
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
			                                  Collapsed="False" 
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
				        <td valign="middle" align="left" width="250">
				            <asp:Label ID="LabelSearchLegislatura" 
				                       runat="server"
				                       Width="80px"
				                       Text="Legislatura:" >
				            </asp:Label>
				            
				            <asp:DropDownList ID="DropDownListLegislatura" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceLegislature"
					                          DataTextField="num_legislatura" 
					                          DataValueField="id_legislatura" 
					                          Width="130px"
					                          AppendDataBoundItems="true"
					                          AutoPostBack="true" >
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
        				
        				<% if (role <= 3) { %>
				        <td valign="middle" align="left" width="600px">
				            <asp:Label ID="LabelSearchOrganoAll" 
				                       runat="server"
				                       Width="60px"
				                       Text="Organo:">
				            </asp:Label>
				            
				            <asp:DropDownList ID="DropDownListOrgano" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceOrgani"
					                          DataTextField="nome_organo" 
					                          DataValueField="id_organo" 
					                          Width="500px"
					                          AutoPostBack="false" 
                                              OnDataBound="DropDownListOrgano_DataBound">
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSourceOrgani" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        					                   
					                           SelectCommand="SELECT 0 AS id_organo, 
                                                                     '(tutti)' AS nome_organo,
                                                                     '30001231' AS init_leg 
                                                              UNION
                                                              SELECT oo.id_organo AS id_organo, 
                                                                     oo.nome_organo AS nome_organo,
                                                                     CONVERT(varchar, ll.durata_legislatura_da, 112) AS init_leg 
                                                              FROM organi AS oo 
                                                              INNER JOIN legislature AS ll 
                                                              ON oo.id_legislatura = ll.id_legislatura
                                                              WHERE oo.deleted = 0 
                                                                AND ll.id_legislatura = @id_legislatura
                                                              ORDER BY init_leg DESC, nome_organo ASC" >
                                                              
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="PanelRicerca$DropDownListLegislatura" 
                                                          DefaultValue="0" 
                                                          Name="id_legislatura" 
                                                          PropertyName="SelectedValue" 
                                                          Type="Int32" />
                                </SelectParameters>
				            </asp:SqlDataSource>
				        </td>
				        <% } %>
        				
        				<% if (role == 4) { %>
				        <td valign="middle" align="left" width="600">
				            <asp:Label ID="LabelSearchOrganoServComm" 
				                       runat="server"
				                       Width="60px"
				                       Text="Organo:">
				            </asp:Label>
				            <asp:DropDownList ID="DropDownList_OrganoServComm" 
				                              runat="server" 
				                              DataSourceID="SqlDataSource_OrganiServComm"
					                          DataTextField="nome_organo" 
					                          DataValueField="id_organo" 
					                          Width="500px"
					                          AutoPostBack="false" 
                                              OnDataBound="DropDownListOrgano_DataBound">
					            <asp:ListItem Text="(tutti)" Value="0" />
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSource_OrganiServComm" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        					                   
					                           SelectCommand="SELECT 0 AS id_organo, 
                                                                     '(tutti)' AS nome_organo,
                                                                     '30001231' AS init_leg 
                                                              UNION
                                                              SELECT oo.id_organo AS id_organo, 
                                                                     oo.nome_organo AS nome_organo,
                                                                     CONVERT(varchar, ll.durata_legislatura_da, 112) AS init_leg 
                                                              FROM organi AS oo 
                                                              INNER JOIN legislature AS ll 
                                                              ON oo.id_legislatura = ll.id_legislatura
                                                              WHERE oo.deleted = 0 
                                                                AND oo.vis_serv_comm = 1
                                                                AND ll.id_legislatura = @id_legislatura
                                                              ORDER BY init_leg DESC, nome_organo ASC" >
                                                              
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="PanelRicerca$DropDownListLegislatura" 
                                                          DefaultValue="0" 
                                                          Name="id_legislatura" 
                                                          PropertyName="SelectedValue" 
                                                          Type="Int32" />
                                </SelectParameters>
				            </asp:SqlDataSource>
				        </td>
				        <% } %>   
				        
	        			<% if (role == 5) { %>
				        <td valign="middle" align="left" width="600">
				            <asp:Label ID="LabelSearchOrganoCommissioni" 
				                       runat="server"
				                       Width="60px" 
				                       Text="Organo:">
				            </asp:Label>
				            <asp:DropDownList ID="DropDownListOrganoComm" 
				                              runat="server" 
				                              DataSourceID="SqlDataSource_OrganiCommissione"
					                          DataTextField="nome_organo" 
					                          DataValueField="id_organo" 
					                          Width="500px"
					                          AutoPostBack="false" 
                                              OnDataBound="DropDownListOrgano_DataBound">
					            <asp:ListItem Text="(tutti)" Value="0" />
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSource_OrganiCommissione" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                           SelectCommand="select id_organo, nome_organo from (
                                                                SELECT 0 AS id_organo, 
                                                                     '(tutti)' AS nome_organo,
                                                                     '30001231' AS init_leg,
                                                                     0 as Sorting
                                                                UNION
                                                                SELECT oo.id_organo AS id_organo, 
                                                                     oo.nome_organo AS nome_organo,
                                                                     CONVERT(varchar, ll.durata_legislatura_da, 112) AS init_leg,
                                                                     case when oo.id_organo = @id_commissione then 1 else 2 end as Sorting
                                                                FROM organi AS oo 
                                                                INNER JOIN legislature AS ll 
                                                                ON oo.id_legislatura = ll.id_legislatura
                                                                WHERE oo.deleted = 0 
                                                                AND ll.id_legislatura = @id_legislatura
                                                                AND (oo.id_organo = @id_commissione OR (oo.comitato_ristretto = 1 AND oo.id_commissione = @id_commissione))
                                                              ) O
                                                              ORDER BY Sorting ASC, nome_organo ASC">
                                                              
                                <SelectParameters>               
                                    <asp:ControlParameter ControlID="PanelRicerca$DropDownListLegislatura" 
                                                          DefaultValue="0" 
                                                          Name="id_legislatura" 
                                                          PropertyName="SelectedValue" 
                                                          Type="Int32" />
                                    <asp:SessionParameter Name="id_commissione" 
                                                          Type="Int32" 
                                                          SessionField="logged_organo" />                     
                                </SelectParameters>
				            </asp:SqlDataSource>
				        </td>
				        <% } %>   			             				
			        </tr>
        			</table>
        			
        			<table>  
			        <tr>
				        <td valign="middle" align="left" width="250">
				            <asp:Label ID="LabelSearchTipoSeduta" 
				                       runat="server" 
				                       Width="80px" 
				                       Text="Tipo Seduta:" >
				            </asp:Label>
				            				            
				            <asp:DropDownList ID="DropDownListTipoSeduta" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceTipoSeduta"
					                          DataTextField="tipo_incontro" 
					                          DataValueField="id_incontro" 
					                          Width="130px"
					                          AutoPostBack="false"
					                          AppendDataBoundItems="True">
					            <asp:ListItem Text="(tutti)" Value="0" />
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSourceTipoSeduta" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        					                   
					                           SelectCommand="SELECT [id_incontro], 
					                                                 [tipo_incontro] 
					                                          FROM [tbl_incontri] 
					                                          ORDER BY [tipo_incontro]">
				            </asp:SqlDataSource>
				        </td>
        				
        	            <td valign="middle" align="left" width="200">
				            <asp:Label ID="LabelSearchMese" 
				                       runat="server"
				                       Width="60px"
				                       Text="Mese:">
				            </asp:Label>
				            
				            <asp:DropDownList ID="DropDownListMese" 
				                              runat="server"
				                              AutoPostBack="false"
				                              Width="100px">
					            <asp:ListItem Text='(tutti)' Value=''></asp:ListItem>
					            <asp:ListItem Text='1' Value='1'>Gennaio</asp:ListItem>
					            <asp:ListItem Text='2' Value='2'>Febbraio</asp:ListItem>
					            <asp:ListItem Text='3' Value='3'>Marzo</asp:ListItem>
					            <asp:ListItem Text='4' Value='4'>Aprile</asp:ListItem>
					            <asp:ListItem Text='5' Value='5'>Maggio</asp:ListItem>
					            <asp:ListItem Text='6' Value='6'>Giugno</asp:ListItem>
					            <asp:ListItem Text='7' Value='7'>Luglio</asp:ListItem>
					            <asp:ListItem Text='8' Value='8'>Agosto</asp:ListItem>
					            <asp:ListItem Text='9' Value='9'>Settembre</asp:ListItem>
					            <asp:ListItem Text='10' Value='10'>Ottobre</asp:ListItem>
					            <asp:ListItem Text='11' Value='11'>Novembre</asp:ListItem>
					            <asp:ListItem Text='12' Value='12'>Dicembre</asp:ListItem>
				            </asp:DropDownList>
				        </td>
        				
				        <td valign="middle" align="left" width="200">
				            <asp:Label ID="LabelSearchAnno" 
				                       runat="server"
				                       Width="60px"
				                       Text="Anno:" >
				            </asp:Label>
				            
				            <asp:DropDownList ID="DropDownListAnni" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceAnni"
				                              AutoPostBack="false"
					                          DataTextField="anno" 
					                          DataValueField="anno" 
					                          Width="100px">
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSourceAnni" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        					
					                           SelectCommand="SELECT anno 
					                                          FROM tbl_anni 
					                                          WHERE (anno &gt; YEAR(GETDATE()) - 10) 
					                                            AND (anno &lt;= YEAR(GETDATE())) 
					                                          ORDER BY anno DESC">
				            </asp:SqlDataSource>
				        </td>
        				
        				<td valign="middle" align="right" width="280">
				            <asp:Button ID="ButtonFiltri" 
				                        runat="server" 
				                        Text="Applica" 
				                        Visible="true" 
				                        Width="100px"
				                        OnClick="ButtonFiltri_Click" />
				        </td>        			        								        
			        </tr>
			        </table>
		        </asp:Panel>
		    </div>
    		
		    <asp:GridView ID="GridViewSedute" 
		                  runat="server" 
		                  AllowPaging="True"
		                  PagerStyle-HorizontalAlign="Center" 
		                  AllowSorting="false"
		                  AutoGenerateColumns="false" 
		                  DataSourceID="SqlDataSource_GridViewSedute" 
		                  CssClass="tab_gen" 
		                  GridLines="None" 
		                  DataKeyNames="id_seduta"
		                  CellPadding="5" 
		                  OnPageIndexChanging="ButtonFiltri_Click">
    		    
		        <EmptyDataTemplate>
			        <table width="100%" class="tab_gen">
			        <tr>
				        <th align="center">
				            Nessun record trovato.
				        </th>
				        <th width="100">
				            <% if (role <= 2 || role == 5 || role == 6) { %>
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
			        <asp:TemplateField HeaderText="Organo" SortExpression="nome_organo">
			            <ItemTemplate>
				            <asp:LinkButton ID="lnkbtn_organo" 
				                            runat="server"
				                            Text='<%# Eval("nome_organo") %>'
				                            Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../organi/dettaglio.aspx", Eval("id_organo")) %>'>
				            </asp:LinkButton>
				        
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
    			    
			        <asp:BoundField DataField="numero_seduta" 
			                        HeaderText="Numero" 
			                        SortExpression="numero_seduta" 
			                        ItemStyle-HorizontalAlign="center" 
			                        ItemStyle-Width="80px" />
    			    
			        <asp:BoundField DataField="tipo_incontro" 
			                        HeaderText="Tipo Seduta" 
			                        SortExpression="tipo_seduta" 
			                        ItemStyle-HorizontalAlign="center" 
			                        ItemStyle-Width="100px" />			   			   
    			                    
			        <asp:BoundField DataField="data_seduta" 
			                        HeaderText="Data" 
			                        SortExpression="data_seduta"
			                        DataFormatString="{0:dd/MM/yyyy}" 
			                        ItemStyle-HorizontalAlign="center" 
			                        ItemStyle-Width="80px" />
    			    
			        <asp:TemplateField>
			            <ItemTemplate>
				            <asp:HyperLink ID="HyperLinkDettagli" 
				                           runat="server" 
				                           NavigateUrl='<%# Eval("id_seduta", "dettaglio.aspx?mode=normal&id={0}") %>'
				                           Text="Foglio presenze">
				            </asp:HyperLink>
			            </ItemTemplate>
    			        
			            <HeaderTemplate>
				            <% if (role <= 2 || role == 5 || role == 6) { %>
				            <asp:Button ID="Button1" 
				                        runat="server" 
				                        OnClick="Button1_Click" 
				                        Text="Nuovo..." 
				                        Width="100px"
				                        CssClass="button" />
				            <% } %>
			            </HeaderTemplate>
    			        
			            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
			        </asp:TemplateField>
		        </Columns>
		    </asp:GridView>
    		
		    <asp:SqlDataSource ID="SqlDataSource_GridViewSedute" 
		                       runat="server" 
		                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >                           
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
	
	<br />
	
	<div align="right">
	    <asp:HyperLink ID="HyperLink_StampeSedute" 
	                   runat="server" 
	                   NavigateUrl="~/stampe/elenco_stampe_sedute.aspx">
	        <img src="../img/cards_arrow.png" 
	             alt="" 
	             align="top" /> 
	        <b>
	        Stampe Sedute &raquo;
	        </b>
	    </asp:HyperLink>
	</div>
	
	<br />
	
	<% 
    if (role == 1) 
    { 
    %>
    
    <asp:Panel ID="Panel_SbloccaSedute" runat="server">
        <div class="pannello_ricerca">
            <img src="../img/page_white_edit.png" alt=""/> 
            
            Sblocca i fogli presenza delle sedute
            
            <br />
            <br />
            
            <table width="100%">
            <tr>
	            <td align="left" valign="middle">
	                Seleziona organo:
	                
	                <br />
	                
	                <asp:DropDownList ID="DropDownListOrganoRiepilogo" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceOrganoRiepilogo"
		                              DataTextField="nome_organo" 
		                              DataValueField="id_organo" 
		                              Width="500px"
		                              AppendDataBoundItems="True">
		                <asp:ListItem Text="(nessuno)" Value="" />
	                </asp:DropDownList>
		            
		            <br />
		            
	                <asp:SqlDataSource ID="SqlDataSourceOrganoRiepilogo" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        			                   
		                               SelectCommand="SELECT oo.id_organo, 
		                                                     ll.num_legislatura + ' - ' + oo.nome_organo AS nome_organo
		                                              FROM organi AS oo
		                                              INNER JOIN legislature AS ll
		                                                ON oo.id_legislatura = ll.id_legislatura
		                                              WHERE oo.deleted = 0
		                                              ORDER BY ll.durata_legislatura_da DESC, nome_organo" >
	                </asp:SqlDataSource>
	                
	                <asp:RequiredFieldValidator ID="RequiredFieldValidatorOrganoRiepilogo" 
	                                            runat="server"
		                                        ErrorMessage="Campo obbligatorio." 
		                                        ControlToValidate="DropDownListOrganoRiepilogo" 
		                                        Display="Dynamic"
		                                        ValidationGroup="GroupRiepilogo" >
		            </asp:RequiredFieldValidator>
	            </td>
    		    
	            <td align="left" valign="middle">
	                Seleziona Mese:
	                
	                <br />
	                
	                <asp:DropDownList ID="DropDownListMeseRiepilogo" 
	                                  runat="server">
		                <asp:ListItem Text='(seleziona)' Value=''></asp:ListItem>
		                <asp:ListItem Text='1' Value='1'>Gennaio</asp:ListItem>
		                <asp:ListItem Text='2' Value='2'>Febbraio</asp:ListItem>
		                <asp:ListItem Text='3' Value='3'>Marzo</asp:ListItem>
		                <asp:ListItem Text='4' Value='4'>Aprile</asp:ListItem>
		                <asp:ListItem Text='5' Value='5'>Maggio</asp:ListItem>
		                <asp:ListItem Text='6' Value='6'>Giugno</asp:ListItem>
		                <asp:ListItem Text='7' Value='7'>Luglio</asp:ListItem>
		                <asp:ListItem Text='8' Value='8'>Agosto</asp:ListItem>
		                <asp:ListItem Text='9' Value='9'>Settembre</asp:ListItem>
		                <asp:ListItem Text='10' Value='10'>Ottobre</asp:ListItem>
		                <asp:ListItem Text='11' Value='11'>Novembre</asp:ListItem>
		                <asp:ListItem Text='12' Value='12'>Dicembre</asp:ListItem>
	                </asp:DropDownList>
	                
	                <br />
	                
	                <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListMeseRiepilogo" 
	                                            runat="server"
	                                            ErrorMessage="Campo obbligatorio." 
	                                            ControlToValidate="DropDownListMeseRiepilogo" 
	                                            Display="Dynamic"
	                                            ValidationGroup="GroupRiepilogo" >
	                </asp:RequiredFieldValidator>
	            </td>
    		    
	            <td align="left" valign="middle">
	                Seleziona Anno:
	                
	                <br />
	                
	                <asp:DropDownList ID="DropDownListAnnoRiepilogo" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceAnniRiepilogo"
		                              DataTextField="anno" 
		                              DataValueField="anno">
	                </asp:DropDownList>
	                
	                <asp:SqlDataSource ID="SqlDataSourceAnniRiepilogo" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        			                   
		                               SelectCommand="SELECT anno 
		                                              FROM tbl_anni 
		                                              WHERE (anno &gt; YEAR(GETDATE()) - 25) 
		                                                AND (anno &lt;= YEAR(GETDATE())) 
		                                              ORDER BY anno DESC">
	                </asp:SqlDataSource>
	            </td>
    		    
	            <td align="right" valign="middle">
	                <asp:Button ID="ButtonRiepilogo" 
	                            runat="server" 
	                            Text="Sblocca sedute" 
	                            Width="100px"
                                CausesValidation="true"
	                            ValidationGroup="GroupRiepilogo"
                                
	                            OnClick="ButtonSblocca_Click" 
		                        OnClientClick="return confirm ('Sbloccare tutti i fogli presenza del mese selezionato?');"  />
	            </td>
            </tr>
            </table>
            
            <asp:Label ID="Label_ErrorSbloccaSedute" 
                       runat="server" 
                       Visible="false" 
                       style="color:Red"
                       Text="ATTENZIONE: valorizzare i campi di organo e mese." >	    
            </asp:Label>
        </div>
    </asp:Panel>
    
    <% 
    } 
    %>
</asp:Content>