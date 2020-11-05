<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_gruppi_consiliari.aspx.cs" 
         Inherits="report_gruppi_consiliari" 
         Title="STAMPE > Gruppi Consiliari" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Gruppi Consiliari"
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
            <td align="left" width="10%">
                <asp:Label ID="lblLegislatura" 
                           runat="server"
                           Text="Legislatura:"
                           Width="90px">
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
            
            <td align="left" width="10%">              
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
            
            <td align="left" width="15%">              
                <asp:Label ID="lblCarica" 
                           runat="server"
                           Text="Carica:">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlCarica" 
                                  runat="server" 
                                  DataTextField="nome_carica"
                                  DataValueField="id_carica"
                                  DataSourceID="SQLDataSource_ddlCarica"
                                  AppendDataBoundItems="true" >                                     
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlCarica"
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                   
                                   SelectCommand="SELECT cc.id_carica,
	                                                     cc.nome_carica
                                                  FROM cariche AS cc
                                                  WHERE tipologia = 'GRPPOL'
                                                  ORDER BY ordine">
                </asp:SqlDataSource>    
            </td>                               
        </tr>
        </table>        
        
        <table width="100%">
        <tr align="left">
            <td align="left">
                <asp:Label ID="lblGruppo" 
                           runat="server"
                           Text="Gruppo: "
                           Width="90px">
                </asp:Label>                                 
                
                <asp:DropDownList ID="ddlGruppo" 
                                  runat="server"	  
                                  Width="597px"                     
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
        
        <table width="100%">
        <tr align="left">
            <td align="left" width="20%">
                <asp:Label ID="lbl_StatoGruppo" 
                           runat="server"
                           Text="Stato Gruppo:"
                           Width="90px">
                </asp:Label>                                 
                
                <asp:DropDownList ID="ddl_StatoGruppo" 
                                  runat="server" >                                   
                    <asp:ListItem Text="(tutti)" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Attivi" Value="1"></asp:ListItem> 
                    <asp:ListItem Text="Non Attivi" Value="2"></asp:ListItem> 
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
	    
	    <br />
	    
	    <asp:Label ID="lblOrdinamento"
	               runat="server"
	               Font-Bold="true"
	               Text="ORDINAMENTO:">
	    </asp:Label>
	    
	    <br />
	    
	    <table width="100%">	    
	        <tr align="left">	    
	            <td align="center">
	                <asp:Label ID="lblOrdCognome"
	                           runat="server"
	                           Text="Cognome">
	                </asp:Label>
	                <asp:CheckBox ID="chbOrdCognome"
	                              runat="server"/>
	            </td>
	            
	            <td align="center">
	                <asp:Label ID="lblOrdGruppo"
	                           runat="server"
	                           Text="Gruppo">
	                </asp:Label>
	                <asp:CheckBox ID="chbOrdGruppo"
	                              runat="server"/>
	            </td>
	            
	            <td align="center">
                    <asp:Label ID="lblOrdCarica"
	                           runat="server"
	                           Text="Carica">
	                </asp:Label>
	                <asp:CheckBox ID="chbOrdCarica"
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
		              DataKeyNames="id_gruppo"
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
		        <asp:BoundField DataField="nome_gruppo" 
		                        HeaderText="GRUPPO CONSILIARE" 
			                    SortExpression="nome_gruppo" 
			                    ItemStyle-HorizontalAlign="left"
			                    ItemStyle-Width="60%"/>			                    
		        
		        <asp:BoundField DataField="nome_carica" 
		                        HeaderText="CARICA" 
			                    SortExpression="nome_carica" 
			                    ItemStyle-HorizontalAlign="Center"
			                    ItemStyle-Width="10%"/>	        
		    
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="COGNOME" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"
			                    ItemStyle-Width="15%"/>
		        
		        <asp:BoundField DataField="nome" 
		                        HeaderText="NOME" 
		                        SortExpression="nome" 
		                        ItemStyle-HorizontalAlign="left"
		                        ItemStyle-Width="15%"/>		        				                                    			                                		        		                    		        		        		       			    			    
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