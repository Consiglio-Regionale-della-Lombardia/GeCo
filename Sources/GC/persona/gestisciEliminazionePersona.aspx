<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         EnableEventValidation="false"
         CodeFile="gestisciEliminazionePersona.aspx.cs" 
         Inherits="gestisciEliminazionePersona" 
         Title="Eliminazione Persone" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Eliminazione Persone"
               Font-Bold="true" >
    </asp:Label>   
     
	<br />
	<br />	    
	
	<div align="center">
	    <asp:GridView ID="GridView1" 
	                  runat="server" 
	                  AllowSorting="true" 
		              AllowPaging="false" 		              
		              PagerStyle-HorizontalAlign="Center" 
		              AutoGenerateColumns="False" 
		              CssClass="tab_gen"
		              DataKeyNames="id_persona"  
		              DataSourceID="SqlDataSource1" >
		    
		    <EmptyDataTemplate>
			    <table width="100%" class="tab_gen">
			    <tr>
				    <th align="center">
				        Nessun record.
				    </th>				    
			    </tr>
			    </table>
		    </EmptyDataTemplate>
		    <AlternatingRowStyle BackColor="#b2cca7" />			    
		    <Columns>
		        <asp:TemplateField>
			            <ItemTemplate>
				            <asp:CheckBox ID="CheckBoxAzione" 
				                          runat="server" />
			            </ItemTemplate>
			            
			            <ItemStyle HorizontalAlign="Center" 
			                       VerticalAlign="Middle" 
			                       Width="20px" />
			    </asp:TemplateField>
			        
		        <asp:BoundField DataField="cognome" 
		                        HeaderText="COGNOME" 
			                    SortExpression="cognome" 
			                    ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="nome" 
		                        HeaderText="NOME" 
		                        SortExpression="nome" 
		                        ItemStyle-HorizontalAlign="left"/>
		        
		        <asp:BoundField DataField="comune" 
		                        HeaderText="NATO A" 
			                    SortExpression="comune" 
			                    ItemStyle-HorizontalAlign="left" 
			                    ItemStyle-Width="200px" />	
			                    
		        <asp:BoundField DataField="data_nascita" 
		                        HeaderText="NATO IL" 
			                    SortExpression="data_nascita" 
			                    DataFormatString="{0:dd/MM/yyyy}" 
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="80px" />
			    			    		    			    			    
			    <asp:CheckBoxField DataField="deleted" 
		                           HeaderText="CANCELLATO?" 
			                       SortExpression="deleted" 
			                       ReadOnly="true" 
			                       ItemStyle-HorizontalAlign="center" 
			                       ItemStyle-Width="90px" />				    			    			                    		                    		        		        		       			    			    
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   
		                   SelectCommand="SELECT pp.id_persona,
	                                             pp.cognome,
	                                             pp.nome,
	                                             pp.data_nascita,
	                                             COALESCE(tc.comune, '') AS comune,
	                                             pp.deleted	   
                                          FROM persona AS pp
                                          LEFT OUTER JOIN tbl_comuni AS tc
                                            ON pp.id_comune_nascita = tc.id_comune
                                          ORDER BY cognome, nome" >		                   
	    </asp:SqlDataSource>
	    
	    <br />
	    
	    <div align="right">
	        <asp:LinkButton ID="LinkButton4" 
                            runat="server"                            
                            OnClick="btnDelete_Click" >
                <img src="../img/delete_icon.png" alt="" align="top" /> 
                Elimina Selezionati
		    </asp:LinkButton>
		</div>
	</div>		
</div>    
</asp:Content>