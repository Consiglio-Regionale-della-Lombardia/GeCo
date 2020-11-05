<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_consiglieri_cariche_ricoperte.aspx.cs" 
         Inherits="report_consiglieri_cariche_ricoperte" 
         Title="STAMPE > Consiglieri - Cariche Ricoperte" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Consiglieri (Cariche Ricoperte)"
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
            <td align="left" width="215">
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
    	    
            <td align="left" width="235">
                <asp:Label ID="lblStatoCariche" 
                           runat="server"
                           Text="Stato carica: "
                           Width="80px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlStatoCariche" 
                                  runat="server">                                     
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                    <asp:ListItem Text="In carica" Value="1"></asp:ListItem>
                    <asp:ListItem Text="Non in carica" Value="2"></asp:ListItem>
                </asp:DropDownList>
            </td>            
            
            <td align="right" width="215">
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
            
            <td align="right">
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
            <td align="left">
                <asp:Label ID="lblTipoCarica" 
                           runat="server"
                           Text="Carica: "
                           Width="70px">
                </asp:Label>
                
                <asp:DropDownList ID="ddlTipoCarica" 
                                  runat="server"                                   
                                  AppendDataBoundItems="true" 
                                  DataTextField="nome_carica"
                                  DataValueField="id_carica"	                         
                                  DataSourceID="SQLDataSource_ddlTipoCarica" >
                                  	    
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlTipoCarica" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                   SelectCommand="SELECT id_carica, 
                                                         nome_carica
                                                  FROM cariche
                                                  ORDER BY ordine, nome_carica">
                </asp:SqlDataSource>
            </td>
            
            <td width="50px">
            </td>            
            
            <td align="right">            
                <asp:Label ID="lblCaricheOld" 
                           runat="server"
                           Text="Anche cariche non più ricoperte? ">
                </asp:Label>
        	    
                <asp:CheckBox ID="chkCaricheOld" 
                              runat="server" 
                              Checked="false" />
            </td>
        </tr>
        </table>
        
        <table> 
        <tr>
           <td>
                <asp:Label ID="lblTipoOrgano"
                           runat="server"
                           Text="Organo:"
                           Width="70px">
                </asp:Label>
                
                <asp:DropDownList ID="ddlTipoOrgano"
                                  runat="server"
                                  DataSourceID="SQLDataSource_ddlTipoOrgano"
                                  DataTextField="leg"
                                  DataValueField="id_organo"
                                  AppendDataBoundItems="true"
                                  Width="600">
                    <asp:ListItem Text="(tutti)" Value="0" Selected="True"></asp:ListItem>
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlTipoOrgano"
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                   SelectCommand="SELECT oo.id_organo
	                                                    ,ll.num_legislatura + ' - ' + oo.nome_organo as leg
                                                  FROM organi AS oo,legislature AS ll
                                                  WHERE oo.deleted = 0
                                                    AND oo.id_legislatura = ll.id_legislatura
                                                  ORDER BY num_legislatura DESC">                                                       
                </asp:SqlDataSource>
            </td>
        </tr> 
        </table>
        
        <table>
        <tr align="left">
            <td align="left">
                <asp:Label ID="lblGruppo" 
                           runat="server"
                           Text="Gruppo: "
                           Width="70px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlGruppo" 
                                  runat="server"	  
                                  Width="600"
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
        
        <table width="100%">
	    <tr align="left">
	        <td align="right" width="15%">
	            <asp:Label ID="lblChkGruppo" 
                           runat="server"
                           Text="Gruppo Consiliare">
                </asp:Label>
        
	            <asp:CheckBox ID="chkVis_Gruppo" 
	                          runat="server" 
	                          Checked="true" />
	        </td>	        	        
	        
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
	    
	    <asp:Label ID="Label1" runat="server"
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
                              ID="chbOrderCognome" Checked="true" />
                
            </td>
            
            <%-- 
            <td>
            
                <asp:Label ID="lblOrderGruppo"
                           runat="server"
                           Text="Gruppo">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderGruppo"/>
                
            </td>
            --%>
            
            <td width="17%" align="right">            
                <asp:Label ID="lblOrderGruppo" 
                           runat="server"
                           Text="Gruppo">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderGruppo"/>                
            </td>
            
            <td width="15%" align="right">            
                <asp:Label ID="lblOrderOrgano" 
                           runat="server"
                           Text="Organo">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderOrgano"/>                
            </td>
            
            <td width="20%" align="right">            
                <asp:Label ID="lblOrderCarica" 
                           runat="server"
                           Text="Carica">
                </asp:Label>
                
                <asp:CheckBox runat="server"
                              ID="chbOrderCarica"/>                
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
		        
		        <asp:BoundField DataField="nome_organo" 
		                        HeaderText="ORGANO-CARICA" 
		                        SortExpression="nome_organo" 
		                        ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="nome_carica"  
		                        SortExpression="nome_carica"
		                        ShowHeader="false" 
		                        ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="data_inizio"  
		                        SortExpression="data_inizio"
		                        ShowHeader="false" 
		                        ItemStyle-HorizontalAlign="left"
		                        ItemStyle-Width="80px"/>
		        
		        <asp:BoundField DataField="data_fine"
			                    SortExpression="data_fine" 
			                    ShowHeader="false" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px"/>			    	                    
			                    		                                    			                                
		        <asp:BoundField DataField="nomegruppo" 
		                        HeaderText="GRUPPO CONSILIARE ATTUALE" 
			                    SortExpression="nomegruppo" 
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