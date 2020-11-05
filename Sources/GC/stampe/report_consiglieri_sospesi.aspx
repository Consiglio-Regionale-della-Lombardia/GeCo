<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_consiglieri_sospesi.aspx.cs" 
         Inherits="report_consiglieri_sospesi" 
         Title="STAMPE > Consiglieri Dimessi o Sospesi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
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
		        <asp:BoundField DataField="nome_completo" 
		                        HeaderText="CONSIGLIERI DIMESSI O SOSPESI" 
			                    SortExpression="nome_completo" 
			                    ItemStyle-HorizontalAlign="left"/>	
			    
			    <asp:TemplateField ShowHeader="false">
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna2" 
				                   runat="server" 
				                   Text='<%# GetColumnString2(Eval("data_procl"), Eval("tipo_delib_procl"), Eval("numero_pratica_procl"), Eval("anno_delib_procl"), Eval("circoscrizione")) %>' >
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>
			    
			    <asp:TemplateField ShowHeader="false">
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna3" 
				                   runat="server" 
				                   Text='<%# Eval("data_sosp") + "<br />- Delibera: " + Eval("tipo_delib_sosp") + " " + Eval("numero_delib_sosp") + "/" + Eval("anno_delib_sosp")%>'>				            
				        </asp:Label>
			        </ItemTemplate>
			        
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>
			                  
		        <asp:BoundField DataField="nome_gruppo" 
		                        ShowHeader="false"
		                        SortExpression="nome_gruppo" 
		                        ItemStyle-HorizontalAlign="left"/>	
		                        
		        <asp:BoundField DataField="nome_completo_sost" 
		                        HeaderText="CONSIGLIERI SUBENTRATI" 
			                    SortExpression="nome_completo_sost" 
			                    ItemStyle-HorizontalAlign="left" />
			                    
			    <asp:TemplateField ShowHeader="false">
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna2" 
				                   runat="server" 
				                   Text='<%# GetColumnString2(Eval("data_procl_sost"), Eval("tipo_delib_procl_sost"), Eval("numero_pratica_procl_sost"), Eval("anno_delib_procl_sost"), Eval("circoscrizione_sost")) %>' >
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>
			    
			    <asp:TemplateField ShowHeader="false">
			        <ItemTemplate>			            
				        <asp:Label ID="lblColonna2" 
				                   runat="server" 
				                   Text='<%# GetColumnStringGruppoSost(Eval("nome_completo_sost"), Eval("nome_gruppo_sost")) %>' >
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" Width="200px"/>
			    </asp:TemplateField>                                  		        		        		       			    			    
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