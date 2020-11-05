<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_consiglieri_dati_anagrafici.aspx.cs" 
         Inherits="report_consiglieri_dati_anagrafici" 
         Title="STAMPE > Consiglieri (Dati Anagrafici) " %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Consiglieri (Dati Anagrafici)"
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
        
        <table>
        <tr align="left">
            <td width="12%" align="left" >
                <asp:Label ID="lblLegislatura" 
                           runat="server"
                           Text="Legislatura: "
                           Width="70px">
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
    	    
            <td width="18%" align="left">
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
    	    
            <td width="19%" align="left">
                <asp:Label ID="lblProvinciaResidenza" 
                           runat="server"
                           Text="Provincia di residenza: ">
                </asp:Label> 
            
                <asp:DropDownList ID="ddlProvinciaResidenza" 
                                  runat="server"
                                  AppendDataBoundItems="true" 
                                  DataTextField="provincia"
                                  DataValueField="provincia"
                                  DataSourceID="SQLDataSource_ddlProvinciaResidenza">
        	    
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlProvinciaResidenza" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        	                       
                                   SelectCommand="SELECT DISTINCT provincia
                                                  FROM tbl_comuni	                                      
                                                  ORDER BY provincia">
                </asp:SqlDataSource>
            </td>    	        	                
            
            <td width="15%" align="left">
                <asp:Label ID="lblSesso" 
                           runat="server"
                           Text="Sesso: ">
                </asp:Label>
        	    
                <asp:DropDownList ID="ddlSesso" 
                                  runat="server" >
                                  	    
                    <asp:ListItem Text="Entrambi" Value="0"></asp:ListItem>
                    <asp:ListItem Text="Maschio" Value="1"></asp:ListItem>
                    <asp:ListItem Text="Femmina" Value="2"></asp:ListItem>
                </asp:DropDownList>
            </td>
            
            <td width="10%" align="right">
                <asp:Button ID="btnApplicaFiltro" 
                            runat="server" 
                            Text="Applica Filtri" 
                            Width="102"
                            OnClick="ApplyFilter" />
            </td>
        </tr>
        </table>
        
        <table>
        <tr align="left">
            <td align="left" width="15%">
                <asp:Label ID="lblGruppo" 
                           runat="server"
                           Text="Gruppo: "
                           Width="70px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlGruppo" 
                                  runat="server"	  
                                  Width="682px"                     
                                  AppendDataBoundItems="true" 
                                  DataTextField="nomegruppo"
                                  DataValueField="id_gruppo"	                         
                                  DataSourceID="SQLDataSource_ddlGruppo" >
                                   
                    <asp:ListItem Text="(tutti)" Value="0"></asp:ListItem>   	        
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlGruppo" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                   SelectCommand="SELECT id_gruppo, 
                                                         LTRIM(RTRIM(nome_gruppo)) AS nomegruppo
                                                  FROM gruppi_politici
                                                  WHERE deleted = 0
                                                  ORDER BY nomegruppo">
                </asp:SqlDataSource>
            </td>
        
            
        </tr> 
        </table>
        
        <br />
        
        <asp:Label ID="lblVisibilityTitle" 
                   runat="server"
                   Text="VISUALIZZA:"
                   Font-Bold="true" >
        </asp:Label>
        
        <table>
	    <tr align="left">
	        <td width="15%" align="right">
	            <asp:Label ID="lblChkGruppo" 
                           runat="server"
                           Text="Gruppo Consiliare">
                </asp:Label>
        
	            <asp:CheckBox ID="chkVis_Gruppo" 
	                          runat="server" 
	                          Checked="true" />
	        </td>

	        <td width="15%" align="right">
	            <asp:Label ID="lblChkGruppi" 
                           runat="server"
                           Text="Tutti i Gruppi">
                </asp:Label>
        
	            <asp:CheckBox ID="chkVis_Gruppi" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <td width="17%" align="right">
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
	        
	        <td width="20%" align="right">
	            <asp:Label ID="lblChkLuogoDataNascita" 
                           runat="server"
                           Text="Luogo e Data di Nascita">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_LuogoDataNascita" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <td>
	        </td>
	        
	        <td width="10%" align="right">
	            <asp:Button ID="btnVisualization" 
                            runat="server" 
                            Text="Applica Vis."
                            Width="102"
                            OnClick="ApplyVisualization" />
	        </td>	        
	    </tr>
	    </table>
	    
	    <br />
	    
	    <asp:Label runat="server"
	               Font-Bold="true"
	               Text="ORDINAMENTO:">
	    </asp:Label>
	    
	    <table width="100%">	    
        <tr align="left">	           
            <td width="15%" align="right">	            
                <asp:Label ID="lblOrderCognome"
                           runat="server"
                           Text="Cognome">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderCognome"/>	                
            </td>
            
            <td width="17%" align="right">	            
                <asp:Label ID="lblOrderGruppo"
                           runat="server"
                           Text="Gruppo">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderGruppo"/>	                
            </td>

            <td width="15%" align="right">	            
                <asp:Label ID="lblOrderDataNascita" 
                           runat="server"
                           Text="Data di nascita">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderDataNascita"/>	                
            </td>
            
            <td width="20%" align="right">	            
                <asp:Label ID="lblOrderComuneNascita" 
                           runat="server"
                           Text="Comune di nascita">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderComuneNascita"/>	                
            </td>
            
            <td width="18%" align="right">	            
                <asp:Label ID="lblOrderComuneResidenza" 
                           runat="server"
                           Text="Comune di residenza">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderComuneResidenza"/>	                
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
				                   Width="150px" 
				                   Text="">				            
				        </asp:Label>
			        </ItemTemplate>
			        <ItemStyle HorizontalAlign="Left" />
			    </asp:TemplateField>
			                                    			                                
		        <asp:BoundField DataField="nomegruppo" 
		                        HeaderText="GRUPPO CONSILIARE ATTUALE" 
			                    SortExpression="nomegruppo" 
			                    ItemStyle-HorizontalAlign="left"/>			                    		        		        		       			    			    

		        <asp:BoundField DataField="gruppi_tutti" 
		                        HeaderText="TUTTI I GRUPPI" 
			                    SortExpression="gruppi_tutti" 
			                    ItemStyle-HorizontalAlign="left"
                                HtmlEncode="false"/>			                    		        		        		       			    			    

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