<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="consiglieri_elezione.aspx.cs" 
         Inherits="stampe_consiglieri_elezione" 
         Title="STAMPE > Consiglieri + Dati di Elezione" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">	
    <b>Stampa di tutti i consiglieri con dati elezione</b>
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
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="Cognome" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"/>
    		    
		        <asp:BoundField DataField="nome" 
		                        HeaderText="Nome" 
			                    SortExpression="nome" 
			                    ItemStyle-HorizontalAlign="left" />
    		    
		        <asp:BoundField DataField="circoscrizione" 
		                        HeaderText="Circoscrizione" 
			                    SortExpression="circoscrizione" 
			                    ItemStyle-HorizontalAlign="left"/>
    		    
		        <asp:BoundField DataField="data_elezione" 
		                        HeaderText="Data" 
			                    SortExpression="data_elezione" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
    		    
		        <asp:BoundField DataField="lista" 
		                        HeaderText="Lista" 
			                    SortExpression="lista" 
			                    ItemStyle-HorizontalAlign="left"/>
    		    
		        <asp:BoundField DataField="maggioranza" 
		                        HeaderText="Maggioranza" 
			                    SortExpression="maggioranza" 
			                    ItemStyle-HorizontalAlign="left"/>
    		    
		        <asp:BoundField DataField="voti" 
		                        HeaderText="Voti" 
			                    SortExpression="voti" 
			                    ItemStyle-HorizontalAlign="right"/>
    		    
		        <asp:CheckBoxField DataField="neoeletto" 
		                           HeaderText="Neoeletto" 
			                       SortExpression="neoeletto" 
			                       ItemStyle-HorizontalAlign="center" 
			                       ItemStyle-Width="50px" />
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   
		                   SelectCommand="SELECT pp.cognome, 
		                                         pp.nome, 
		                                         jpre.circoscrizione, 
		                                         jpre.data_elezione, 
		                                         jpre.lista, 
		                                         jpre.maggioranza, 
		                                         jpre.voti, 
		                                         jpre.neoeletto 
		                                  FROM persona AS pp
		                                  INNER JOIN join_persona_risultati_elettorali AS jpre
		                                    ON pp.id_persona = jpre.id_persona 
		                                  WHERE pp.deleted = 0 AND pp.chiuso = 0
		                                  ORDER BY pp.cognome, pp.nome, jpre.circoscrizione ASC,
		                                           jpre.data_elezione DESC">
		                   
		                   <%--SelectCommand="SELECT persona.cognome, 
		                                         persona.nome, 
		                                         join_persona_risultati_elettorali.circoscrizione, 
		                                         join_persona_risultati_elettorali.data_elezione, 
		                                         join_persona_risultati_elettorali.lista, 
		                                         join_persona_risultati_elettorali.maggioranza, 
		                                         join_persona_risultati_elettorali.voti, 
		                                         join_persona_risultati_elettorali.neoeletto 
		                                  FROM persona 
		                                  INNER JOIN join_persona_risultati_elettorali 
		                                    ON persona.id_persona = join_persona_risultati_elettorali.id_persona 
		                                  WHERE (join_persona_risultati_elettorali.id_legislatura = @leg)"--%>
		    <%--<SelectParameters>
		        <asp:SessionParameter Name="leg" SessionField="id_legislatura" />
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
