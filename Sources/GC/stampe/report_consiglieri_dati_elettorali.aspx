<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_consiglieri_dati_elettorali.aspx.cs" 
         Inherits="report_consiglieri_dati_elettorali" 
         Title="STAMPE > Consiglieri (Dati Elettorali) " %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Consiglieri (Dati Elettorali)"
               Font-Bold="true" >
    </asp:Label>   
     
	<br />
	<br />
	    
    <asp:Panel ID="panelFiltri" runat="server">
    <div id="content_filtri_vis" class="pannello_ricerca">
        <asp:Label ID="lblGroupTitle" 
                   runat="server"
                   Text="RAGGRUPAMENTO:"
                   Font-Bold="true" >
        </asp:Label> 
	    
	    <asp:DropDownList ID="ddlGroup" 
                          runat="server" >                             
            <asp:ListItem Text="nessuno" Value="0"></asp:ListItem>
            <asp:ListItem Text="Circoscrizione" Value="1"></asp:ListItem>
            <asp:ListItem Text="Maggioranza/Opposizione" Value="2"></asp:ListItem>
        </asp:DropDownList>	
                
        <br />
        <br />
        
        <asp:Label ID="lblFilterTitle" 
                   runat="server"
                   Text="FILTRI:"
                   Font-Bold="true" >
        </asp:Label> 
        
        <table width="100%">
        <tr align="left">
            <td align="left" >
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
    	    
    	    <td width="30"></td>
    	    
            <td align="left">
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
            
            <td width="30"></td>
            
            <td align="left">
                <asp:Label ID="lblCircoscrizione" 
                           runat="server"
                           Text="Circoscrizione: ">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlCircoscrizione" 
                                  runat="server" 
                                  AppendDataBoundItems="true"
                                  DataTextField="circoscrizione"
                                  DataValueField="circoscrizione"   
                                  DataSourceID="SQLDataSource_Circoscrizioni" >
                                     
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_Circoscrizioni" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                   SelectCommand="SELECT DISTINCT jpre.circoscrizione
                                                  FROM join_persona_risultati_elettorali AS jpre
                                                  WHERE jpre.circoscrizione IS NOT NULL">
                </asp:SqlDataSource>
            </td> 
            
           <%-- <td width="300"></td>--%>
            
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
	            <asp:Label ID="lblChkGruppo" 
                           runat="server"
                           Text="Gruppo Consiliare">
                </asp:Label>
        
	            <asp:CheckBox ID="chkVis_Gruppo" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	       <%-- <td width="30"></td>--%>
	        
	        <td align="right" width="17%">
	            
	            <asp:Label ID="lblChkDataProcl" 
                           runat="server"
                           Text="Data Proclamazione">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_DataProcl" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <%--<td width="30"></td>--%>
	        
	        <td align="right" width="15%">
	            <asp:Label ID="lblChkLista" 
                           runat="server"
                           Text="Lista">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Lista" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	       <%-- <td width="30"></td>--%>
	        
	        <td align="right" width="15%">
	            <asp:Label ID="lblChkVoti" 
                           runat="server"
                           Text="Voti">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Voti" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <%--<td width="30"></td>--%>
	        
	        <td align="right">
	            <asp:Label ID="lblChkMagg" 
                           runat="server"
                           Text="Maggioranza/Opposizione">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Magg" 
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
	    
	    <asp:Label ID="lblOrdinamento"
	               runat="server"
	               Text="ORDINAMENTO:"
	               Font-Bold="true">
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
	            
	                <asp:Label ID="lblOrderCircoscrizione" 
	                           runat="server"
	                           Text="Circoscrizione">
	                </asp:Label>
	                
	                <asp:CheckBox runat="server"
	                              ID="chbOrderCircoscrizione"/>
	                
	            </td>
	            
	            <td width="15%" align="right">
	            
	                <asp:Label ID="lblOrderPreferenze" 
	                           runat="server"
	                           Text="Preferenze">
	                </asp:Label>
	                
	                <asp:CheckBox runat="server"
	                              ID="chbOrderPreferenze"/>
	                
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
    
    <asp:Panel runat="server">
        <asp:GridView ID="GridView4" runat="server">
	        <EmptyDataTemplate>
	            vediamo un p&ograve
	        </EmptyDataTemplate>
	    </asp:GridView>
    </asp:Panel>
	
	<asp:Panel ID="Panel1" runat="server" align="center" Visible="true">	
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
		        
		        <asp:BoundField DataField="circoscrizione" 
		                        HeaderText="CIRCOSCRIZIONE" 
		                        SortExpression="circoscrizione" 
		                        ItemStyle-HorizontalAlign="left"/>
                
                <asp:BoundField DataField="lista" 
		                        HeaderText="LISTA" 
			                    SortExpression="lista" 
			                    ItemStyle-HorizontalAlign="left"/>
			    
			    <asp:BoundField DataField="voti" 
		                        HeaderText="VOTI" 
			                    SortExpression="voti" 
			                    ItemStyle-HorizontalAlign="right"/>
                		                        
<%--		        <asp:BoundField DataField="data_elezione" 
		                        HeaderText="DATA ELEZIONE" 
			                    SortExpression="data_elezione" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
--%>
		        <asp:BoundField DataField="data_proclamazione" 
		                        HeaderText="DATA PROCLAMAZIONE" 
			                    SortExpression="data_elezione" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
                                  			                                
		        <asp:BoundField DataField="nomegruppo" 
		                        HeaderText="GRUPPO CONSILIARE ATTUALE" 
			                    SortExpression="nomegruppo" 
			                    ItemStyle-HorizontalAlign="left"/>	
			    
			    <asp:BoundField DataField="magg_min" 			                    
			                    HeaderText="MAGGIORANZA/OPPOSIZIONE"
			                    SortExpression="magg_min" 
			                    ItemStyle-HorizontalAlign="left"/>			                    		        		        		       			    			    
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   
		                   SelectCommand="" >		                   
	    </asp:SqlDataSource>	
	</asp:Panel>
	
	<asp:Panel ID="Panel2" runat="server" align="center" Visible="false">
	    <asp:GridView ID="GridView2" 
	                  runat="server" 
	                  AllowSorting="false" 
		              AllowPaging="false" 
		              PagerStyle-HorizontalAlign="Center" 
		              AutoGenerateColumns="False" 
		              CssClass="tab_gen" 
		              ShowHeader="false"
		              
		              OnRowDataBound="GridView2_OnRowDataBound" >
		    
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
		        <asp:BoundField DataField="COGNOME" 
		                        ShowHeader="false"
			                    SortExpression="COGNOME" 
			                    ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="NOME" 
		                        ShowHeader="false"
		                        SortExpression="NOME" 
		                        ItemStyle-HorizontalAlign="left"/>
                
                <asp:BoundField DataField="LISTA" 
		                        ShowHeader="false" 
			                    SortExpression="LISTA" 
			                    ItemStyle-HorizontalAlign="left"/>
			    
			    <asp:BoundField DataField="VOTI" 
		                        ShowHeader="false" 
			                    SortExpression="VOTI" 
			                    ItemStyle-HorizontalAlign="right"/>
                		                        
<%--		        <asp:BoundField DataField="DATA ELEZIONE" 
		                        ShowHeader="false" 
			                    SortExpression="DATA ELEZIONE"
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />--%>

		        <asp:BoundField DataField="DATA PROCLAMAZIONE" 
		                        ShowHeader="false" 
			                    SortExpression="DATA PROCLAMAZIONE"
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
                                                                  			                                
		        <asp:BoundField DataField="GRUPPO CONSILIARE" 
		                        ShowHeader="false" 
			                    SortExpression="GRUPPO CONSILIARE" 
			                    ItemStyle-HorizontalAlign="left"/>	
			    
			    <asp:BoundField DataField="MAGGIORANZA/OPPOSIZIONE" 			                    
			                    ShowHeader="false"
			                    SortExpression="MAGGIORANZA/OPPOSIZIONE" 
			                    ItemStyle-HorizontalAlign="left"/>			                    		        		        		       			    			    
		    </Columns>
	    </asp:GridView>	
	</asp:Panel>
	
	<asp:Panel ID="Panel3" runat="server" align="center" Visible="false">
	    <asp:GridView ID="GridView3" 
	                  runat="server" 
	                  AllowSorting="false" 
		              AllowPaging="false" 
		              PagerStyle-HorizontalAlign="Center" 
		              AutoGenerateColumns="False" 
		              CssClass="tab_gen"  
		              ShowHeader="false"
		              
		              OnRowDataBound="GridView3_OnRowDataBound" >
		    
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
		        <asp:BoundField DataField="COGNOME" 
		                        ShowHeader="false"
			                    SortExpression="COGNOME" 
			                    ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="NOME" 
		                        ShowHeader="false"
		                        SortExpression="NOME" 
		                        ItemStyle-HorizontalAlign="left"/>
		                        
		        <asp:BoundField DataField="CIRCOSCRIZIONE" 
		                        ShowHeader="false" 
		                        SortExpression="CIRCOSCRIZIONE" 
		                        ItemStyle-HorizontalAlign="left"/>
                
                <asp:BoundField DataField="LISTA" 
		                        ShowHeader="false" 
			                    SortExpression="LISTA" 
			                    ItemStyle-HorizontalAlign="left"/>
			    
			    <asp:BoundField DataField="VOTI" 
		                        ShowHeader="false" 
			                    SortExpression="VOTI" 
			                    ItemStyle-HorizontalAlign="right"/>
                		                        
<%--		        <asp:BoundField DataField="DATA ELEZIONE" 
		                        ShowHeader="false" 
			                    SortExpression="DATA ELEZIONE" 			                     
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />--%>

 		        <asp:BoundField DataField="DATA PROCLAMAZIONE" 
		                        ShowHeader="false" 
			                    SortExpression="DATA PROCLAMAZIONE" 			                     
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
                                                                 			                                
		        <asp:BoundField DataField="GRUPPO CONSILIARE" 
		                        ShowHeader="false" 
			                    SortExpression="GRUPPO CONSILIARE" 
			                    ItemStyle-HorizontalAlign="left"/>			    			                    		        		        		       			    			    
		    </Columns>
	    </asp:GridView>		
	</asp:Panel>
	
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