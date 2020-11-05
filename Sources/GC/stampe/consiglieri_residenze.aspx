<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="consiglieri_residenze.aspx.cs" 
         Inherits="stampe_consiglieri_residenze" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	
    <b>Stampa di tutti i consiglieri con indirizzi di residenza</b>
	<br />
	<br />
	<div align="center">
	    <asp:GridView ID="GridView1" 
	                  runat="server"
	                  AllowSorting="True" 
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
		                        
		        <asp:BoundField DataField="indirizzo_residenza" 
		                        HeaderText="Indirizzo" 
			                    SortExpression="indirizzo_residenza" 
			                    ItemStyle-HorizontalAlign="left" />
			                    
		        <asp:BoundField DataField="comune" 
		                        HeaderText="Comune" 
			                    SortExpression="comune" 
			                    ItemStyle-HorizontalAlign="left"/>
			                    
		        <asp:BoundField DataField="provincia" 
		                        HeaderText="Provincia" 
			                    SortExpression="provincia" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			                    
		        <asp:BoundField DataField="cap" 
		                        HeaderText="CAP" 
		                        SortExpression="cap" 
		                        ItemStyle-HorizontalAlign="center" 
		                        ItemStyle-Width="80px" />
		    </Columns>
	    </asp:GridView>
	    
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   SelectCommand="SELECT persona.cognome, 
		                                         persona.nome, 
		                                         join_persona_residenza.indirizzo_residenza, 
		                                         tbl_comuni.comune, 
		                                         tbl_comuni.provincia, 
		                                         join_persona_residenza.cap 
		                                  FROM persona 
		                                  INNER JOIN join_persona_residenza 
		                                    ON persona.id_persona = join_persona_residenza.id_persona 
		                                  INNER JOIN tbl_comuni 
		                                    ON join_persona_residenza.id_comune_residenza = tbl_comuni.id_comune 
		                                  WHERE (join_persona_residenza.residenza_attuale = 1)" >
	    </asp:SqlDataSource>
	    
	</div>
	<br />
	<div align="right">
	    <asp:LinkButton ID="LinkButtonExcel" runat="server" OnClick="LinkButtonExcel_Click">
	        <img src="../img/page_white_excel.png" alt="" align="top" /> 
	        Esporta
	    </asp:LinkButton>
	    -
	    <asp:LinkButton ID="LinkButtonPdf" runat="server" OnClick="LinkButtonPdf_Click">
	        <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
	        Esporta
	    </asp:LinkButton>
	</div>
	
    </div>
</asp:Content>