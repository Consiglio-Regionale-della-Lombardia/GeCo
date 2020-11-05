<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_aspettative.aspx.cs" 
         Inherits="report_aspettative" 
         Title="STAMPE > Aspettative" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Aspettative"
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
    	    
    	    <td width="30%">
    	        <asp:Label ID="lblCognome" 
                           runat="server"
                           Text="Cognome: ">
                </asp:Label> 
                
    	        <asp:TextBox ID="txtCognome" 
    	                     runat="server">
    	        </asp:TextBox>
    	    </td>
            
            <td width="30%">
                <asp:Label ID="lblNome" 
                           runat="server"
                           Text="Nome: ">
                </asp:Label> 
                
    	        <asp:TextBox ID="txtNome" 
    	                     runat="server">
    	        </asp:TextBox>
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
                   Text="ORDINAMENTO:"
                   Font-Bold="true" >
        </asp:Label>
        
        <table width="100%">
	        <tr align="left">                
                <td align="right" width="20%">
                    <asp:Label ID="lblOrdCognome"
                               runat="server"
                               Text="Cognome">
                    </asp:Label>
                    <asp:CheckBox ID="chbOrdCognome"
                                  runat="server"/>
                </td>
                
                <td align="right" width="20%">
                    <asp:Label ID="lblOrdTempo"
                               runat="server"
                               Text="Data Inizio">
                    </asp:Label>
                    <asp:CheckBox ID="chbOrdDataInizio"
                                  runat="server"/>
                </td>
                
                <td align="right">
                    <asp:Button ID="btnApplyOrder"
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
			                    ItemStyle-Width="70px"/>
			                    
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="COGNOME" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"/>		        		        
		        
		        <asp:BoundField DataField="nome" 
		                        HeaderText="NOME" 
			                    SortExpression="nome" 
			                    ItemStyle-HorizontalAlign="left"/>	
			    
			    <asp:BoundField DataField="numero_pratica" 
		                        HeaderText="N.PRATICA" 
			                    SortExpression="numero_pratica" 
			                    ItemStyle-HorizontalAlign="center"
			                    ItemStyle-Width="100px"/>	
			                                 
		        <asp:BoundField DataField="data_inizio" 
		                        HeaderText="DAL" 
			                    SortExpression="data_inizio" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			    
			    <asp:BoundField DataField="data_fine" 
		                        HeaderText="AL" 
			                    SortExpression="data_fine" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />		        		        	                                    		        		        		       			    			    
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