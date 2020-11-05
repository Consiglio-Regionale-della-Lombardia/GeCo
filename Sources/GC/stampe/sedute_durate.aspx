<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         CodeFile="sedute_durate.aspx.cs" 
         Inherits="stampe_sedute_durate" 
         Title="Stampe > Durata Sedute" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:ScriptManager ID="ScriptManager1" 
                       runat="server" 
                       EnableScriptGlobalization="True">
    </asp:ScriptManager>
	
	<asp:Label ID="lbl_title"
	           runat="server"
	           Font-Bold="true">
	</asp:Label>
	
	<br />
	<br />
	
	<div class="pannello_ricerca">
        <asp:Panel ID="panel_search" runat="server">
            <table width="100%">
            <tr>			            
	            <td align="left" valign="middle">
                    <asp:Label ID="lbl_data_dal"
	                           runat="server"
	                           Text="Dal:"
	                           Width="50px">
	                </asp:Label>
    	            				            
	                <asp:TextBox ID="txt_data_dal" 
	                             runat="server" 
	                             Width="70px">
	                </asp:TextBox>
    	            
	                <img alt="calendar" 
	                     src="../img/calendar_month.png" 
	                     id="img_data_dal" 
	                     runat="server" />
    	            
	                <cc1:CalendarExtender ID="CalendarExtender_data_dal" 
	                                      runat="server" 
	                                      TargetControlID="txt_data_dal"
		                                  PopupButtonID="img_data_dal" 
		                                  Format="dd/MM/yyyy" >
	                </cc1:CalendarExtender>
    	            
	                <asp:RegularExpressionValidator ID="RFV_data_dal" 
	                                                ControlToValidate="txt_data_dal"
		                                            runat="server" 
		                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
		                                            Display="Dynamic"
		                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
		                                            ValidationGroup="GroupFilters" >
		            </asp:RegularExpressionValidator>
	            </td>

	            <td align="left" valign="middle">
                    <asp:Label ID="lbl_data_al"
	                           runat="server"
	                           Text="Al:">
	                </asp:Label>
    	            				            
	                <asp:TextBox ID="txt_data_al" 
	                             runat="server" 
	                             Width="70px">
	                </asp:TextBox>
    	            
	                <img alt="calendar" 
	                     src="../img/calendar_month.png" 
	                     id="img_data_al" 
	                     runat="server" />
    	            
	                <cc1:CalendarExtender ID="CalendarExtender_data_al" 
	                                      runat="server" 
	                                      TargetControlID="txt_data_al"
		                                  PopupButtonID="img_data_al" 
		                                  Format="dd/MM/yyyy" >
	                </cc1:CalendarExtender>
    	            
	                <asp:RegularExpressionValidator ID="RFV_data_al" 
	                                                ControlToValidate="txt_data_al"
		                                            runat="server" 
		                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
		                                            Display="Dynamic"
		                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
		                                            ValidationGroup="GroupFilters" >
		            </asp:RegularExpressionValidator>
	            </td>
    			
    			<td align="left" valign="middle">
                    <asp:Label ID="lbl_tipo_seduta" 
	                           runat="server"
	                           Text="Tipo seduta:" >
	                </asp:Label>
    	            
	                <asp:DropDownList ID="ddl_tipo_seduta" 
	                                  runat="server" 
		                              AutoPostBack="false" >
		                <asp:ListItem Text="(tutte)" Value="" ></asp:ListItem>
		                <asp:ListItem Text="Seduta" Value="1" ></asp:ListItem>
		                <asp:ListItem Text="Altro" Value="2" ></asp:ListItem>
	                </asp:DropDownList>
	            </td>
    			
			    <td valign="middle" align="right">
	                <asp:Button ID="ButtonFiltri" 
	                            runat="server" 
	                            Text="Applica" 
	                            Visible="true" 
	                            Width="100px"
	                            CausesValidation="true"
	                            ValidationGroup="GroupFilters"
	                            
	                            OnClick="ApplyFiltersClick" />
	            </td>        			        								        
            </tr>
            
            <% if ((logged_role_id == 4) || (logged_role_id == 1)) { %>
            <tr>
                <td align="left" valign="middle" colspan="3">
                    <asp:Label ID="lbl_organo"
		                       runat="server"
		                       Text="Organo:"
		                       Width="50px" >
		            </asp:Label>
				            
	                <asp:DropDownList ID="ddl_organi_servcomm" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceOrgani_ServComm"
		                              DataTextField="nome_organo" 
		                              DataValueField="id_organo" 
		                              Width="625px"
		                              AppendDataBoundItems="true" >
		                <asp:ListItem Text="(tutti)" Value=""></asp:ListItem>
	                </asp:DropDownList>
    	            
	                <asp:SqlDataSource ID="SqlDataSourceOrgani_ServComm" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
	                                   
	                                   SelectCommand="SELECT oo.id_organo AS id_organo, 
                                                             'Legislatura ' + ll.num_legislatura + ' - ' + oo.nome_organo AS nome_organo,
                                                             ll.durata_legislatura_da AS init_leg
                                                      FROM organi AS oo
                                                      INNER JOIN legislature AS ll
                                                         ON oo.id_legislatura = ll.id_legislatura
                                                      WHERE oo.deleted = 0
                                                        AND oo.vis_serv_comm = 1
                                                      ORDER BY init_leg DESC, nome_organo">
	                </asp:SqlDataSource>
                </td>
            </tr>
            <% } else if (logged_role_id == 5) { %>
            <tr>
                <td align="left" valign="middle" colspan="3">
                    <asp:Label ID="Label1"
		                       runat="server"
		                       Text="Organo:"
		                       Width="50px" >
		            </asp:Label>
				            
	                <asp:DropDownList ID="ddl_organi_comm" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceOrgani_Comm"
		                              DataTextField="nome_organo" 
		                              DataValueField="id_organo" 
		                              Width="625px"
		                              AppendDataBoundItems="true" >
		                <asp:ListItem Text="(tutti)" Value=""></asp:ListItem>
	                </asp:DropDownList>
    	            
	                <asp:SqlDataSource ID="SqlDataSourceOrgani_Comm" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
	                                   
	                                   SelectCommand="select id_organo, nome_organo from (
                                                        SELECT oo.id_organo AS id_organo, oo.nome_organo,   
                                                             case when oo.id_organo = @id_commissione then 1 else 2 end as Sorting
                                                        FROM organi AS oo 
                                                        WHERE oo.deleted = 0 
                                                        AND (oo.id_organo = @id_commissione OR (oo.comitato_ristretto = 1 AND oo.id_commissione = @id_commissione))
                                                      ) O
                                                      ORDER BY Sorting ASC, nome_organo ASC">
                         <SelectParameters>
                               <asp:SessionParameter Name="id_commissione" 
                                                     Type="Int32" 
                                                     SessionField="logged_organo" />   
                         </SelectParameters>                             
	                </asp:SqlDataSource>
                </td>
            </tr>            
            <% } %>
            </table>
	    </asp:Panel>
    </div>
	
    <asp:GridView ID="GridView1" 
                  runat="server" 
                  AllowSorting="True" 
	              AutoGenerateColumns="False" 
	              CssClass="tab_gen" 
	              DataSourceID="SqlDataSource1"
	              ShowFooter="true"
	              
	              OnSorting="ApplyFiltersClick" 
	              OnRowDataBound="GridView1_RowDataBound" >
	              
	    <EmptyDataTemplate>
	        <table width="100%" class="tab_gen">
            <tr>
                <th align="center">
                    Nessun elemento trovato
                </th>
            </tr>
            </table>
	    </EmptyDataTemplate>         
	     
	    <Columns>
	        <asp:BoundField DataField="data_seduta_str" 
	                        HeaderText="Data Seduta" 
	                        SortExpression="data_seduta" 
	                        ItemStyle-HorizontalAlign="Center" />
	        
	        <asp:BoundField DataField="ora_convocazione" 
	                        HeaderText="Ora Convocazione" 
	                        SortExpression="ora_convocazione" 
	                        ItemStyle-HorizontalAlign="Center" />
	        
	        <asp:BoundField DataField="ora_inizio" 
	                        HeaderText="Ora Inizio" 
	                        SortExpression="ora_inizio" 
	                        ItemStyle-HorizontalAlign="Center" />
	        
	        <asp:BoundField DataField="ora_fine" 
	                        HeaderText="Ora Fine" 
	                        SortExpression="ora_fine" 
	                        ItemStyle-HorizontalAlign="Center" />
	        
	        <asp:BoundField DataField="tipo_incontro" 
	                        HeaderText="Tipo Incontro" 
	                        SortExpression="tipo_incontro" 
	                        ItemStyle-HorizontalAlign="Center" />
	                        
	        <asp:BoundField DataField="durata_conv" 
	                        HeaderText="Durata da Ora Convocazione" 
	                        SortExpression="durata_conv" 
	                        ItemStyle-HorizontalAlign="Right" 
	                        FooterText="TOTALE"
	                        FooterStyle-HorizontalAlign="Right" />
	                        
            <asp:BoundField DataField="durata_effet" 
	                        HeaderText="Durata Effettiva" 
	                        SortExpression="durata_effet" 
	                        ItemStyle-HorizontalAlign="Right" 
	                        FooterStyle-HorizontalAlign="Right"/>
	                        
	    </Columns>
	    
	    <FooterStyle BackColor="#99cc99"
                     BorderStyle="Solid" 
                     BorderWidth="1"
                     Font-Bold="true"
                     ForeColor="#006600"  />
    </asp:GridView>
    
    <asp:SqlDataSource ID="SqlDataSource1" 
                       runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
    </asp:SqlDataSource>
	
	<br />
	
	<asp:Label ID="lbl_tot_sedute" 
	           runat="server"
	           Text="n. sedute"
	           Font-Bold="true">
	</asp:Label>
	
	<asp:Label ID="lbl_tot_sedute_val" 
	           runat="server"
	           Font-Bold="true" >
	</asp:Label>
	
	<br />
	
	<div align="right">
	    <asp:LinkButton ID="LinkButtonExcel" 
	                    runat="server" 
	                    OnClick="LinkButtonExcel_Click" >
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