<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="consiglieri_dataproclamazione.aspx.cs" 
         Inherits="stampe_consiglieri_data_proclamazione" 
         Title="STAMPE > Consiglieri in carica + Data Proclamazione" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
	<b>Stampa di tutti i consiglieri con data di proclamazione.</b>
	<br />
	<br />
	
	<div align="center">
	    <asp:GridView ID="GridView1" 
	                  runat="server" 
	                  AllowSorting="True"
	                  AllowPaging="false" 
	                  PagerStyle-HorizontalAlign="Center" 
		              AutoGenerateColumns="False" 
		              CssClass="tab_gen" 
		              DataSourceID="SqlDataSource1">
		              
		    <Columns>
		        <asp:BoundField DataField="num_legislatura" 
		                        HeaderText="Legislatura" 
			                    SortExpression="num_legislatura" 
			                    ItemStyle-HorizontalAlign="center"/>
		    
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="Cognome" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"/>		        		       
		        
		        <asp:BoundField DataField="nome" 
		                        HeaderText="Nome" 
		                        SortExpression="nome" 
		                        ItemStyle-HorizontalAlign="left"/>		        

			    <asp:BoundField DataField="nome_organo" 
		                        HeaderText="Organo" 
			                    SortExpression="nome_organo" 
			                    ItemStyle-HorizontalAlign="left"/>
			                                    
		        <asp:BoundField DataField="nome_carica" 
		                        HeaderText="Carica" 
			                    SortExpression="nome_carica" 
			                    ItemStyle-HorizontalAlign="left"/>	        
		        
		        <asp:BoundField DataField="data_proclamazione" 
		                        HeaderText="Data Proclamazione" 
			                    SortExpression="data_proclamazione" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			                    	        
		        <asp:BoundField DataField="data_inizio" 
		                        HeaderText="Dal" 
			                    SortExpression="data_inizio" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			    
			    <asp:BoundField DataField="data_fine" 
			                    HeaderText="Al" 
			                    SortExpression="data_fine" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />			    			    
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT ll.num_legislatura,
                                                 pp.cognome, 
                                                 pp.nome,	   
                                                 oo.nome_organo,
	                                             cc.nome_carica,
	                                             jpoc.data_proclamazione,      
                                                 jpoc.data_inizio,
                                                  jpoc.data_fine       
                                          FROM persona AS pp
                                          INNER JOIN join_persona_organo_carica AS jpoc
                                            ON pp.id_persona = jpoc.id_persona 
                                          INNER JOIN organi AS oo
                                            ON jpoc.id_organo = oo.id_organo 
                                          INNER JOIN cariche AS cc
                                            ON jpoc.id_carica = cc.id_carica
                                          INNER JOIN legislature AS ll
                                            ON jpoc.id_legislatura = ll.id_legislatura
                                          WHERE pp.deleted = 0 AND pp.chiuso = 0
                                            AND jpoc.deleted = 0                                       
                                          ORDER BY ll.durata_legislatura_da DESC,
                                                   pp.cognome, pp.nome, nome_organo, cc.ordine ASC,
                                                   jpoc.data_proclamazione, jpoc.data_inizio DESC">		                   
	    </asp:SqlDataSource>
	
	</div>
	<br />
	
	<div align="right">
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