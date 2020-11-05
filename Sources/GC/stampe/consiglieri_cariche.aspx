<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="consiglieri_cariche.aspx.cs" 
         Inherits="stampe_consiglieri_cariche" 
         Title="STAMPE > Consiglieri + Cariche" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
	<b>Stampa di tutti i consiglieri con cariche che ricoprono</b>
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
		              DataKeyNames="id_persona" 
		              DataSourceID="SqlDataSource1"
		              
		              OnRowDataBound="GridView1_OnRowDataBound" >
		              
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
		        
		        <asp:BoundField DataField="nome_gruppo" 
			                    HeaderText="Gruppo" 
			                    SortExpression="nome_gruppo" 
			                    ItemStyle-HorizontalAlign="left"/>
			                    
		        <asp:BoundField DataField="nome_carica" 
		                        HeaderText="Carica" 
			                    SortExpression="nome_carica" 
			                    ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="nome_organo" 
		                        HeaderText="Organo" 
			                    SortExpression="nome_organo" 
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
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT ll.num_legislatura,
                                                 pp.id_persona,
                                                 pp.cognome, 
                                                 pp.nome,
                                                 cc.nome_carica,
                                                 oo.nome_organo,
                                                 jpoc.data_inizio,
                                                 jpoc.data_fine,               
                                                 COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo 
                                          FROM persona AS pp
                                          INNER JOIN join_persona_organo_carica AS jpoc
                                            ON pp.id_persona = jpoc.id_persona 
                                          INNER JOIN organi AS oo
                                            ON jpoc.id_organo = oo.id_organo 
                                          INNER JOIN cariche AS cc
                                            ON jpoc.id_carica = cc.id_carica
                                          INNER JOIN legislature AS ll
                                            ON jpoc.id_legislatura = ll.id_legislatura
                                          LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp
                                            ON (pp.id_persona = jpgp.id_persona AND jpgp.deleted = 0 AND jpgp.data_fine IS NULL)
                                          LEFT OUTER JOIN gruppi_politici AS gg
                                            ON (jpgp.id_gruppo = gg.id_gruppo AND gg.deleted = 0)
                                          WHERE pp.deleted = 0
                                            AND oo.deleted = 0
                                            AND jpoc.deleted = 0 
                                          ORDER BY pp.cognome ASC, pp.nome ASC,
                                                   ll.durata_legislatura_da DESC" >
		                   
		                   <%--SelectCommand="SELECT persona.cognome, 
		                                         persona.nome, 
		                                         join_persona_organo_carica.data_inizio, 
		                                         organi.nome_organo, 
		                                         cariche.nome_carica 
		                                  FROM persona 
		                                  INNER JOIN join_persona_organo_carica 
		                                    ON persona.id_persona = join_persona_organo_carica.id_persona 
		                                  INNER JOIN organi 
		                                    ON join_persona_organo_carica.id_organo = organi.id_organo 
		                                  INNER JOIN cariche 
		                                    ON join_persona_organo_carica.id_carica = cariche.id_carica 
		                                  WHERE (join_persona_organo_carica.data_fine IS NULL) 
		                                    AND (join_persona_organo_carica.id_legislatura = @id_leg)"--%>
		    <%--<SelectParameters>
		        <asp:SessionParameter Name="id_leg" SessionField="id_legislatura" />
		    </SelectParameters>--%>
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