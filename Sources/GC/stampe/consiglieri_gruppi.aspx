<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="consiglieri_gruppi.aspx.cs" 
         Inherits="stampe_consiglieri_gruppi" 
         Title="STAMPE > Consiglieri + Gruppi Politici" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">	
    <b>Stampa di tutti i consiglieri con gruppi politici di appartenenza</b>
    <br />
    <br />
    
    <div align="center">
        <asp:GridView ID="GridView1" 
                      runat="server" 
                      AllowSorting="True" 
                      AllowPaging="False" 
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
	                            ItemStyle-HorizontalAlign="left" />

                <asp:BoundField DataField="nomegruppo" 
	                            HeaderText="Gruppo Politico" 
		                        SortExpression="nomegruppo" 
		                        ItemStyle-HorizontalAlign="left"/>
		                        		        	            		        
	            <asp:BoundField DataField="data_inizio" 
	                            HeaderText="Dal" 
		                        SortExpression="data_inizio" 
		                        DataFormatString="{0:dd/MM/yyyy}" 
		                        ItemStyle-HorizontalAlign="center" 
		                        ItemStyle-Width="75px" />
		                        
		        <asp:BoundField DataField="data_fine" 
	                            HeaderText="Al" 
		                        SortExpression="data_fine" 
		                        DataFormatString="{0:dd/MM/yyyy}" 
		                        ItemStyle-HorizontalAlign="center" 
		                        ItemStyle-Width="75px" />
	        </Columns>
        </asp:GridView>
	
        <asp:SqlDataSource ID="SqlDataSource1" 
                           runat="server" 
	                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
	                       
	                       SelectCommand="SELECT DISTINCT pp.cognome, 
	                                                      pp.nome, 
	                                                      LTRIM(RTRIM(gg.nome_gruppo)) as nomegruppo, 
	                                                      jpgp.data_inizio,
	                                                      jpgp.data_fine,
	                                                      ll.num_legislatura,
	                                                      ll.durata_legislatura_da 
	                                      FROM gruppi_politici AS gg
	                                      INNER JOIN join_persona_gruppi_politici AS jpgp
	                                        ON gg.id_gruppo = jpgp.id_gruppo 
	                                      INNER JOIN persona AS pp
	                                        ON jpgp.id_persona = pp.id_persona
	                                      INNER JOIN join_gruppi_politici_legislature AS jgpl
	                                        ON gg.id_gruppo = jgpl.id_gruppo
	                                      INNER JOIN legislature ll
	                                        ON jgpl.id_legislatura = ll.id_legislatura
	                                      WHERE pp.deleted = 0
                                            AND gg.deleted = 0
                                            AND jpgp.deleted = 0
                                            AND jgpl.deleted = 0
	                                      ORDER BY ll.durata_legislatura_da DESC, 	                                                
	                                               pp.cognome, pp.nome, nomegruppo ASC,
	                                               jpgp.data_inizio DESC" >
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
