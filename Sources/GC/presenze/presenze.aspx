<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master"
         CodeFile="presenze.aspx.cs" 
         Inherits="presenze_presenze" 
         Title="Consiglieri > Pres/Ass" %>

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
	    <asp:DataList ID="DataList1" 
	                  runat="server" 
	                  DataSourceID="SqlDataSourceHead" 
	                  Width="50%">
	        
	        <ItemTemplate>
		        <table>
		        <tr>
			        <td width="50" >
			            <img src="<%= photoName %>" 
			                 alt=""
			                 width="50" 
			                 height="50" 
			                 style="border: 1px solid #99cc99; margin-right: 10px;" 
			                 align="middle" />
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
		            <asp:ScriptManager ID="ScriptManager2" 
		                               runat="server" 
		                               EnableScriptGlobalization="True">
		            </asp:ScriptManager>
				            
			        <table width="100%">
			        <tr>
				        <td align="left" valign="middle" >
				            <asp:Label ID="Label_SearchLeg"
				                       runat="server" 
				                       width="130px"
				                       Text="Seleziona legislatura:">
				            </asp:Label>
				            
				            <asp:DropDownList ID="DropDownListLegislatura" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceLegislature"
					                          DataTextField="num_legislatura" 
					                          DataValueField="id_legislatura" 
					                          Width="70px"
					                          AppendDataBoundItems="True">
					            <asp:ListItem Text="(tutte)" Value="0" ></asp:ListItem>
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
				        
				        <td align="left" valign="middle" colspan="2" >
				            <% 
			                if ((role < 3) || (role == 4)) 
                            { 
                            %>
			                <asp:Label ID="Label_SearchOrg"
				                       runat="server" 
				                       width="120px"
				                       Text="Seleziona organo:">
				            </asp:Label>
				            
				            <% 
				            } 
				            %>
				            
				            <% 
                            if (role < 3)
                            { 
                            %>
				            <asp:DropDownList ID="DropDownListOrgano" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceOrgani"
					                          DataTextField="nome_organo" 
					                          DataValueField="id_organo" 
					                          Width="450px"
					                          AppendDataBoundItems="True" >
					            <asp:ListItem Text="(tutti)" Value="0" />
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSourceOrgani" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                           
					                           SelectCommand="SELECT oo.id_organo, 
					                                                 ll.num_legislatura + ' - ' + oo.nome_organo AS nome_organo
					                                          FROM organi AS oo
					                                          INNER JOIN legislature AS ll
					                                            ON oo.id_legislatura = ll.id_legislatura
					                                          WHERE oo.deleted = 0
					                                          ORDER BY ll.durata_legislatura_da DESC, nome_organo">
				            </asp:SqlDataSource>
				            
				            <% 
                            }
				            %>
				            
				            <% 
                            if (role == 4)
                            { 
                            %>
				            <asp:DropDownList ID="ddl_organi_servcomm" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceOrgani_ServComm"
					                          DataTextField="nome_organo" 
					                          DataValueField="id_organo" 
					                          Width="450px"
					                          AppendDataBoundItems="True" >
					            <asp:ListItem Text="(tutti)" Value="0" />
				            </asp:DropDownList>
				            
				            <asp:SqlDataSource ID="SqlDataSourceOrgani_ServComm" 
				                               runat="server" 
				                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                           
					                           SelectCommand="SELECT oo.id_organo, 
					                                                 ll.num_legislatura + ' - ' + oo.nome_organo AS nome_organo
					                                          FROM organi AS oo
					                                          INNER JOIN legislature AS ll
					                                            ON oo.id_legislatura = ll.id_legislatura
					                                          WHERE oo.deleted = 0
					                                            AND oo.vis_serv_comm = 1
					                                          ORDER BY ll.durata_legislatura_da DESC, nome_organo">
				            </asp:SqlDataSource>
				            
				            <% 
                            }
				            %>
				            
				        </td>
			        </tr>
			        
			        <tr>
			            <td align="left" valign="middle">
			                <asp:Label ID="Label_SearchData"
				                       runat="server"
				                       width="130px"
				                       Text="Seleziona data:">
				            </asp:Label>
				            				            
				            <asp:TextBox ID="TextBoxFiltroData" 
				                         runat="server" 
				                         Width="70px">
				            </asp:TextBox>
				            
				            <img alt="calendar" 
				                 src="../img/calendar_month.png" 
				                 id="ImageFiltroData" 
				                 runat="server" />
				            
				            <cc1:CalendarExtender ID="CalendarExtender2" 
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
				        
				        <td align="right" valign="middle">
				            <asp:Button ID="Button1" 
				                        runat="server" 
				                        Text="Applica" 
				                        CssClass="button"
				                        OnClick="ButtonFiltri_Click"
					                    ValidationGroup="FiltroData" />
				        </td>
			        </tr>
			        </table>
			        
			        <br />		
    			    		    
			        <asp:GridView ID="GridView1" 
			                      runat="server" 
			                      AutoGenerateColumns="False" 
			                      CellPadding="5"
	                              CssClass="tab_gen" 
	                              DataSourceID="SqlDataSource1" 
	                              GridLines="None" 
	                              onrowdatabound="GridView1_RowDataBound">
    				    
    				    <EmptyDataTemplate>
    				        <table width="100%" class="tab_gen">
			                <tr>
				                <th align="center">
				                    Nessun record trovato.
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
		                                            onclientclick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>' >
		                            </asp:LinkButton>
				                </ItemTemplate>
    					        
				                <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
				            </asp:TemplateField>
        					
				            <asp:TemplateField HeaderText="Organo" SortExpression="nome_organo" >
				                <ItemTemplate>
					                <asp:LinkButton ID="lnkbtn_organo" 
		                                            runat="server"
		                                            Text='<%# Eval("nome_organo") %>'
		                                            Font-Bold="true"
		                                            onclientclick='<%# getPopupURL("../organi/dettaglio.aspx", Eval("id_organo")) %>' >
		                            </asp:LinkButton>
				                </ItemTemplate>
    					        
				                <ItemStyle Font-Bold="True" />
				            </asp:TemplateField>
				            
					        <asp:BoundField DataField="tipo_incontro" 
				                            HeaderText="Tipo seduta" 
				                            SortExpression="tipo_incontro" 
				                            ItemStyle-HorizontalAlign="center" 
				                            ItemStyle-Width="90px" />			            
        					
				            <asp:TemplateField HeaderText="Seduta" SortExpression="nome_seduta">
				                <ItemTemplate>
					                <asp:LinkButton ID="lnkbtn_seduta" 
		                                            runat="server"
		                                            Text='<%# Eval("nome_seduta") %>'
		                                            Font-Bold="true"
		                                            onclientclick='<%# getPopupURL("../sedute/dettaglio.aspx", Eval("id_seduta")) %>' >
		                            </asp:LinkButton>
				                </ItemTemplate>
    					        
				                <ItemStyle Font-Bold="True" Width="120px" HorizontalAlign="Center" />
				            </asp:TemplateField>
        					
				            <asp:BoundField DataField="data_seduta" 
				                            HeaderText="Del" 
				                            SortExpression="data_seduta"
				                            DataFormatString="{0:dd/MM/yyyy}" 
				                            ItemStyle-HorizontalAlign="center" 
				                            ItemStyle-Width="80px" />
                 
                            <%--HeaderText="Presenza ai Fini della Diaria" --%>
				            <asp:BoundField DataField="nome_partecipazione" 
				                            HeaderText="Firma 1" 
				                            SortExpression="nome_partecipazione" 
				                            ItemStyle-HorizontalAlign="center" 
				                            ItemStyle-Width="120px" />

                            <asp:TemplateField HeaderText="Firma 2" SortExpression="firma2">
                                <ItemTemplate>
                                    <asp:Label ID="lbl_firma2" runat="server" Text='<%# Eval("firma2") %>'>
                                    </asp:Label>
                                </ItemTemplate>
                                <ItemStyle Width="120px" HorizontalAlign="Center" />
                            </asp:TemplateField>

				            <%-- 
				            <asp:TemplateField HeaderText="Presenza da Verbale" SortExpression="presenza_effettiva">
				                <ItemTemplate>
					                <asp:Label ID="lbl_pres_eff" 
				                               runat="server" 
				                               Text='<%# Eval("presenza_effettiva") %>' >
					                </asp:Label>
				                </ItemTemplate>
    					        
				                <ItemStyle Width="120px" HorizontalAlign="Center" />
				            </asp:TemplateField>
                            --%>

                            <asp:TemplateField HeaderText="Priorità" SortExpression="priorita">
                                <ItemTemplate>
                                    <asp:Label ID="lbl_priorita" runat="server" Text='<%# Eval("priorita") %>'>
                                    </asp:Label>
                                </ItemTemplate>
                                <ItemStyle Width="120px" HorizontalAlign="Center" />
                            </asp:TemplateField>

			            </Columns>
			        </asp:GridView>
    				
			        <asp:SqlDataSource ID="SqlDataSource1" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    				                   
			                           SelectCommand="SELECT ll.id_legislatura, 
			                                                 ll.num_legislatura, 
			                                                 oo.id_organo, 
			                                                 oo.nome_organo, 
			                                                 ss.id_seduta, 
			                                                 ti.tipo_incontro,
			                                                 ss.numero_seduta + ' del ' + CAST(YEAR(ss.data_seduta) AS char(4)) AS nome_seduta, 
			                                                 ss.data_seduta, 
                                                             tp.id_partecipazione,
                                                             tp.nome_partecipazione,
			                                                 CASE jj.presenza_effettiva
			                                                    WHEN 1 THEN 'SI'
			                                                    ELSE 'NO'
			                                                 END AS presenza_effettiva,
									                        case
										                        when oo.abilita_commissioni_priorita = 0 then null
										                        else dbo.get_tipo_commissione_priorita_desc(ss.id_seduta, jj.id_persona)
									                        end as priorita,
															case 
																when oo.utilizza_foglio_presenze_in_uscita = 1 then 
																	case
																		when jj.presente_in_uscita = 0 then 'No'
																		else 'Sì'
																	end 
															end  firma2
					                                  FROM join_persona_sedute AS jj 
					                                  INNER JOIN sedute AS ss     
                                                        on ss.id_seduta = jj.id_seduta     
                                                            inner join tbl_incontri ti
                                                        on ti.id_incontro = ss.tipo_seduta        
					                                  INNER JOIN organi AS oo 
					                                    ON ss.id_organo = oo.id_organo 
					                                  INNER JOIN tbl_partecipazioni AS tp 
					                                    ON jj.tipo_partecipazione = tp.id_partecipazione 
					                                  INNER JOIN legislature AS ll 
					                                    ON ss.id_legislatura = ll.id_legislatura
					                                  WHERE ss.deleted = 0 
					                                    AND jj.deleted = 0 
					                                    AND oo.deleted = 0
					                                    AND jj.id_persona = @id 
					                                    AND jj.copia_commissioni = 0"
                        
                                                        OnSelected="SqlDataSource1_Selected">
    			                           
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
		        Esporta</asp:LinkButton>
		        -
		        <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click">
		        <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		        Esporta</asp:LinkButton>
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