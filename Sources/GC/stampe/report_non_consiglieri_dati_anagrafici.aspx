<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_non_consiglieri_dati_anagrafici.aspx.cs" 
         Inherits="report_non_consiglieri_dati_anagrafici" 
         Title="STAMPE > Non Consiglieri (Dati Anagrafici) " %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Non Consiglieri (Dati Anagrafici)"
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
            <td width="15%" align="right" >
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

            <td width="18%" align="right">
                <asp:Label ID="lblStatoCariche" 
                           runat="server"
                           Text="Stato carica: ">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlStatoCariche" 
                                  runat="server" >
                                     
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                    <asp:ListItem Text="In carica" Value="1"></asp:ListItem>
                    <asp:ListItem Text="Non in carica" Value="2"></asp:ListItem>
                </asp:DropDownList>
            </td>
            
            <td>
            </td>
            
            <td align="right">
                <asp:Button ID="btnApplicaFiltro" 
                            runat="server" 
                            OnClick="ApplyFilter" 
                            Text="Applica Filtro"
                            Width="102" />
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
	        <td width="15%" align="right">
	            <asp:Label ID="lblChkResidenza" 
                           runat="server"
                           Text="Residenza attuale">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Residenza" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <td width="15%" align="right">
	            <asp:Label ID="lblChkRecapiti" 
                           runat="server"
                           Text="Recapiti">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Recapiti" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <td width="25%" align="right">
	            <asp:Label ID="lblChkLuogoDataNascita" 
                           runat="server"
                           Text="Luogo e Data di Nascita">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_LuogoDataNascita" 
	                          runat="server" 
	                          Checked="true" />
	        </td>	        
	        
	        <td align="right">
	            <asp:Button ID="btnVisualization" 
                            runat="server" 
                            Text="Applica Vis."
                            OnClick="ApplyVisualization"
                            Width="102"/>
	        </td>		        	                        
	    </tr>
	    </table>
	    
	    <br />
	    
	    <asp:Label ID="lblOrderRecord"
	               runat="server"
	               Text="ORDINAMENTO:"
	               Font-Bold="true">
	    </asp:Label>
	    
	    <table width="100%">	    
        <tr>	           
            <td width="15%" align="right">            
                <asp:Label ID="lblOrderCognome"
                           runat="server"
                           Text="Cognome">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderCognome"/>                
            </td>
            
            <td>
            </td>
            
            <td align="right">
                <asp:Button ID="btnApplicaOrdinamento" 
                            runat="server" 
                            Text="Applica Ord."
                            OnClick="applyOrder"
                            Width="102"/>                            
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
		              DataKeyNames="id_persona"  
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
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="COGNOME" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="nome" 
		                        HeaderText="NOME" 
		                        SortExpression="nome" 
		                        ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="data" 
		                        HeaderText="NATO IL" 
			                    SortExpression="data" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="70px" />
			    
			    <asp:BoundField DataField="comune" 
		                        HeaderText="NATO A" 
			                    SortExpression="comune" 
			                    ItemStyle-HorizontalAlign="left"/>
			    
			    <asp:BoundField DataField="ind1" 
		                        HeaderText="RESIDENZA ATTUALE" 
			                    SortExpression="ind1" 
			                    ItemStyle-HorizontalAlign="left"/>
			                    
                <asp:BoundField DataField="ind2" 		                         
			                    SortExpression="ind2" 
			                    ShowHeader="false"
			                    ItemStyle-HorizontalAlign="left"/>			                    
			                    
			    <asp:TemplateField HeaderText="RECAPITI">
			        <ItemTemplate>			            
				        <asp:Label ID="lblGridView1_Recapiti" 
				                   runat="server" 
				                   Width="170px" 
				                   Text="">				            
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" />
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