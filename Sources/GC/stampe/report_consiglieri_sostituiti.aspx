<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_consiglieri_sostituiti.aspx.cs" 
         Inherits="report_consiglieri_sostituiti" 
         Title="STAMPE > Consiglieri Dimessi o Sospesi" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">

    <asp:ScriptManager ID="ScriptManager2"
        runat="server"
        EnableScriptGlobalization="True">
    </asp:ScriptManager>

    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Consiglieri Dimessi o Sospesi"
               Font-Bold="true" >
    </asp:Label>   
     
	<br />
	<br />
	    
    <asp:Panel ID="panelFiltri" runat="server">
    <div id="content_filtri_vis" class="pannello_ricerca">
        <asp:Label ID="lblFilterTitle" 
                   runat="server"
                   Text="FILTRI:"
                   Font-Bold="true" >
        </asp:Label> 
        
        <table width="100%">
        <tr align="left">
            <td align="left" width="20%">
                <asp:Label ID="lblLegislatura" 
                           runat="server"
                           Text="Legislatura: ">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlLegislatura" 
                                  runat="server"	                      
                                  AppendDataBoundItems="true" 
                                  DataTextField="num_legislatura"
                                  DataValueField="id_legislatura"	                         
                                  DataSourceID="SQLDataSource_ddlLegislatura">	  	        
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlLegislatura" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                   SelectCommand="SELECT id_legislatura,
                                                         num_legislatura
                                                  FROM legislature
                                                  ORDER BY durata_legislatura_da DESC">
                </asp:SqlDataSource>
            </td>    
            

            <td align="left">
                <asp:Label ID="lbl_data_inizio"
                    runat="server"
                    Text="Dal:">
                </asp:Label>

                <asp:TextBox ID="txt_data_inizio"
                    runat="server"
                    Width="70px">
                </asp:TextBox>

                <img alt="calendar"
                    src="../img/calendar_month.png"
                    id="img_data_inizio"
                    runat="server" />

                <cc1:CalendarExtender ID="CalendarExtender_DataInizio"
                    runat="server"
                    TargetControlID="txt_data_inizio"
                    PopupButtonID="img_data_inizio"
                    Format="dd/MM/yyyy">
                </cc1:CalendarExtender>

                <asp:RequiredFieldValidator ID="RFV_DataInizio"
                    runat="server"
                    ControlToValidate="txt_data_inizio"
                    ErrorMessage="*"
                    Display="Dynamic"
                    ValidationGroup="FilterGroup">
                </asp:RequiredFieldValidator>

                <asp:RegularExpressionValidator ID="REV_DataInizio"
                    ControlToValidate="txt_data_inizio"
                    runat="server"
                    ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                    Display="Dynamic"
                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                    ValidationGroup="FilterGroup">
                </asp:RegularExpressionValidator>
            </td>

            <td align="left">
                <asp:Label ID="lbl_data_fine"
                    runat="server"
                    Text="Al:">
                </asp:Label>

                <asp:TextBox ID="txt_data_fine"
                    runat="server"
                    Width="70px">
                </asp:TextBox>

                <img alt="calendar"
                    src="../img/calendar_month.png"
                    id="img_data_fine"
                    runat="server" />

                <cc1:CalendarExtender ID="CalendarExtender_DataFine"
                    runat="server"
                    TargetControlID="txt_data_fine"
                    PopupButtonID="img_data_fine"
                    Format="dd/MM/yyyy">
                </cc1:CalendarExtender>

                <asp:RequiredFieldValidator ID="RFV_DataFine"
                    runat="server"
                    ControlToValidate="txt_data_fine"
                    ErrorMessage="*"
                    Display="Dynamic"
                    ValidationGroup="FilterGroup">
                </asp:RequiredFieldValidator>

                <asp:RegularExpressionValidator ID="REV_DataFine"
                    ControlToValidate="txt_data_fine"
                    runat="server"
                    ErrorMessage="Ammessi solo valori GG/MM/AAAA."
                    Display="Dynamic"
                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                    ValidationGroup="FilterGroup">
                </asp:RegularExpressionValidator>
            </td>

    	                          
            <td align="right">
                <asp:Button ID="btnApplicaFiltro" 
                            runat="server" 
                            Text="Applica Filtri" 
                            Width="102"
                            OnClick="ApplyFilter" />
            </td>
        </tr>
        </table>
        
        <br />

        <asp:Label ID="lblVisibilityTitle" 
                   runat="server"
                   Text="VISUALIZZA:"
                   Font-Bold="true" >
        </asp:Label>

        <table width="100%">
        <tr align="left">
   
            <td align="right" width="15%">
                <asp:Label ID="lblChkDelibera" 
                           runat="server"
                           Text="Delibera">
                </asp:Label>

                <asp:CheckBox ID="chkVis_Delibera" 
                              runat="server" 
                              Checked="true" />
            </td>
    
           <%-- <td width="30"></td>--%>
    
            <td align="right" width="17%">
        
                <asp:Label ID="lblChkCausa" 
                           runat="server"
                           Text="Causa">
                </asp:Label>
        
                <asp:CheckBox ID="chkVis_Causa" 
                              runat="server" 
                              Checked="true" />
            </td>
    
            <%--<td width="30"></td>--%>
    
            <td align="right" width="15%">
                <asp:Label ID="lblChkNote" 
                           runat="server"
                           Text="Note">
                </asp:Label>
        
                <asp:CheckBox ID="chkVis_Note" 
                              runat="server" 
                              Checked="true" />
            </td>
    
            <%--<td width="150"></td>--%>
    
            <td align="right">
                <asp:Button ID="btnVisualization" 
                            runat="server" 
                            Text="Applica Vis."
                            Width="102"
                            OnClick="ApplyVisualization" />
            </td>	        
        </tr>
        </table>
        
        <br />
        
        <asp:Label ID="lblOrdSospesi"
                   runat="server"
                   Font-Bold="true"
                   Text="ORDINAMENTO:">
        </asp:Label>
        
        <table width="100%">
            <tr align="left">
                <td align="right" width="13%">
                    <asp:Label ID="lblOrdinamentoCognome"
                               runat="server"
                               Text="Cognome">
                    </asp:Label>
                    <asp:CheckBox ID="chbOrdCognome"
                                  runat="server"/>
                </td>
                
                <td align="right" width="13%">
                    <asp:Label ID="lblOrdinamentoNome"
                               runat="server"
                               Text="Nome">
                    </asp:Label>
                    <asp:CheckBox ID="chbOrdNome"
                                  runat="server"/>
                </td>
                
                <td align="right">
                    <asp:Button ID="btnApplicaOrdinamento"
                                runat="server"
                                Text="Applica Ord."
                                Width="102"
                                OnClick="ApplyOrder"/>
                </td>
            </tr>
        </table>              
    </div>
    </asp:Panel>
	
	<div align="center">
	    <asp:GridView ID="GridView1" 
	                  runat="server" 
	                  AllowSorting="false" 
		              AllowPaging="false" 
		              PagerStyle-HorizontalAlign="Center" 
		              AutoGenerateColumns="False" 
		              CssClass="tab_gen"
		              DataKeyNames="id_rec"  
		              DataSourceID="SqlDataSource1"
		              
		              OnRowDataBound="GridView1_OnRowDataBound" >
		    
		    <EmptyDataTemplate>
			    <table width="100%" class="tab_gen">
			    <tr>
				    <th align="center">
				        Nessun record.
				    </th>				    
			    </tr>
			    </table>
		    </EmptyDataTemplate>
		    		    
		    <Columns>
		        <asp:BoundField DataField="nome_completo_sost" 
		                        HeaderText="CONSIGLIERE SOSTITUTO" 
			                    SortExpression="nome_completo_sost" 
			                    ItemStyle-HorizontalAlign="left"/>	

		        <asp:BoundField DataField="nome_completo" 
		                        HeaderText="CONSIGLIERE SOSTITUITO" 
			                    SortExpression="nome_completo" 
			                    ItemStyle-HorizontalAlign="left"/>	
			    
			    <asp:TemplateField HeaderText="DATA INIZIO SOSTITUZIONE" >
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna2" 
				                   runat="server" 
				                   Text='<%# Eval("data_inizio") %>' >
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>
			    
			    <asp:TemplateField HeaderText="DATA FINE SOSTITUZIONE">
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna3" 
				                   runat="server" 
				                   Text='<%# Eval("data_fine") %>' >
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>
			    
			    <asp:TemplateField HeaderText="Delibera">
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna3" 
				                   runat="server" 
				                   Text='<%# Eval("data_sosp") + "<br />- Delibera: " + Eval("tipo_delib_sosp") + " " + Eval("numero_delib_sosp") + "/" + Eval("anno_delib_sosp")%>'>				            
				        </asp:Label>
			        </ItemTemplate>
			        
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>

		        <asp:BoundField DataField="descrizione_causa" 
		                        HeaderText="Causa" 
			                    SortExpression="descrizione_causa" 
			                    ItemStyle-HorizontalAlign="left"/>	

		        <asp:BoundField DataField="note" 
		                        HeaderText="Note" 
			                    SortExpression="note" 
			                    ItemStyle-HorizontalAlign="left"/>	
			                               		        		        		       			    			    
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   
		                   SelectCommand="" >		                   
	    </asp:SqlDataSource>
	
	</div>
	
	<br />
	
	<div align="right">
	    <asp:CheckBox ID="chkOptionLandscape" 
                      runat="server"
                      Text="Landscape"  
                      Checked="false" />
                      
        <asp:Label ID="lblGap" 
                   runat="server" 
                   Text="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;">
        </asp:Label>  
              
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