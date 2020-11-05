<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="consiglieri_sospesi.aspx.cs" 
         Inherits="stampe_consiglieri_sospesi" 
         Title="STAMPE > Consiglieri Sospesi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">	
    <b>Stampa di tutti i consiglieri sospesi.</b>
	<br />
	<br />
	
	<div align="left">
	    <asp:CheckBox ID="chkOpzioneCarica" 
	                  runat="server" 
	                  AutoPostBack="true" 
	                  Text="Solo consiglieri in carica" 
	                  Checked="false" />    
	</div>
	
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
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="70px"/>
			                    
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="Cognome" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="nome" 
		                        HeaderText="Nome" 
		                        SortExpression="nome" 
		                        ItemStyle-HorizontalAlign="left"/>
                
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
                
                <asp:BoundField DataField="sostituto" 
		                        HeaderText="Sostituito da" 
			                    SortExpression="sostituto" 
			                    ItemStyle-HorizontalAlign="left"/>
			                    			                    			                    		        		        			    			    
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   
		                   SelectCommand="SELECT ll.num_legislatura,
                                                 pp.cognome, 
                                                 pp.nome,	     
                                                 jps.data_inizio,	
                                                 jps.data_fine,
	                                             (SELECT cognome + ' ' + nome 
		                                          FROM persona pp1
		                                          WHERE jps.sostituito_da = pp1.id_persona
                                                    AND pp1.deleted = 0) as sostituto
                                          FROM persona AS pp
                                          INNER JOIN join_persona_sospensioni AS jps
                                            ON pp.id_persona = jps.id_persona 
                                          INNER JOIN legislature AS ll
                                            ON jps.id_legislatura = ll.id_legislatura
                                          WHERE pp.deleted = 0
                                            AND jps.deleted = 0
                                          ORDER BY ll.durata_legislatura_da DESC,
		                                           pp.cognome, pp.nome ASC,
                                                   jps.data_inizio DESC" >		                   
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