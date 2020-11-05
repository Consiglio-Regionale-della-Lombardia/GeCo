<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_elenco_gruppi_consiliari.aspx.cs" 
         Inherits="report_elenco_gruppi_consiliari" 
         Title="STAMPE > Elenco Gruppi Consiliari " %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Elenco Gruppi Consiliari."
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
                    
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>    	        
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
    	    
    	    <td align="left" width="20%">
                <asp:Label ID="lblStatoGruppo" 
                           runat="server"
                           Text="Stato Gruppo: ">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlStatoGruppo" 
                                  runat="server">
                                  
                    <asp:ListItem Text="(tutti)" Value="0"></asp:ListItem>    	        
                    <asp:ListItem Text="Attivo" Value="1"></asp:ListItem>    	        
                    <asp:ListItem Text="Non Attivo" Value="2"></asp:ListItem>    	        
                </asp:DropDownList>                
            </td>
                       
            <td align="right">
                <asp:Button ID="btnApplicaFiltro" 
                            runat="server" 
                            Text="Applica Filtri" 
                            
                            OnClick="ApplyFilter" />
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
		        <asp:BoundField DataField="num_legislatura" 
		                        HeaderText="LEGISLATURA" 
			                    SortExpression="num_legislatura" 
			                    ItemStyle-HorizontalAlign="center"
			                    ItemStyle-Width="80px"/>
			                    
		        <asp:BoundField DataField="nomegruppo" 
		                        HeaderText="GRUPPO CONSILIARE" 
			                    SortExpression="nomegruppo" 
			                    ItemStyle-HorizontalAlign="left"/>		        		        
		        
		        <asp:BoundField DataField="data_inizio" 
		                        HeaderText="DAL" 
			                    SortExpression="data_inizio" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="70px" />
			    
			    <asp:BoundField DataField="data_fine" 
		                        HeaderText="AL" 
			                    SortExpression="data_fine" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="70px" />
		        
		        <asp:BoundField DataField="descrizione_causa" 
		                        HeaderText="CAUSA FINE" 
		                        SortExpression="descrizione_causa" 
		                        ItemStyle-HorizontalAlign="left"
		                        ItemStyle-Width="170px"/>		                                    		        		        		       			    			    
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