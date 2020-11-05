<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="storia.aspx.cs" 
         Inherits="gruppi_politici_storia" 
         Title="Gruppo Politico > Storia" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	<asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSource_Head" Width="50%">
	    <ItemStyle Font-Bold="True" />
	    <ItemTemplate>
		<asp:Label ID="nomeLabel" runat="server" Text='<%# Eval("nome_gruppo") %>' />
		&gt; STORIA
	    </ItemTemplate>
	</asp:DataList>
	
	<asp:SqlDataSource ID="SqlDataSource_Head" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	                   
	                   SelectCommand="SELECT nome_gruppo 
	                                  FROM gruppi_politici 
	                                  WHERE id_gruppo = @id_gruppo">
	    <SelectParameters>
		    <asp:SessionParameter Name="id_gruppo" SessionField="id_gruppo" Type="Int32" />
	    </SelectParameters>
	</asp:SqlDataSource>
    </td>
</tr>

<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	    <div id="tab">
	        <ul>
		        <li><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
		        <li><a id="a_componenti" runat="server">COMPONENTI</a></li>
		        <li><a id="a_legislature" runat="server">LEGISLATURE</a></li>
		        <li id="selected"><a id="a_storia" runat="server">STORIA</a></li>
	        </ul>
	    </div>
    	
        <div id="tab_content">
            <div id="tab_content_content">
	        <asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
	            </asp:ScriptManager>
	        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
	            <ContentTemplate>
    			
		        <asp:GridView ID="GridView1" runat="server" CssClass="tab_gen" 
		            DataSourceID="SqlDataSource1" AutoGenerateColumns="False">
                    <AlternatingRowStyle BackColor="#b2cca7" />	
		            <Columns>
			        <asp:TemplateField HeaderText="Il gruppo si è formato dall'aggregazione di:" SortExpression="nome_gruppo">
			            <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo_agg" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		                </asp:LinkButton>
				        
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
			        <asp:BoundField DataField="data_fine" HeaderText="Data" 
			            SortExpression="data_fine" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>
		        
		        <asp:SqlDataSource ID="SqlDataSource1" 
		                           runat="server" 
		                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                           
		                           SelectCommand="SELECT gg.id_gruppo, 
		                                                 LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
		                                                 gg.data_fine 
		                                          FROM gruppi_politici AS gg 
		                                          INNER JOIN gruppi_politici_storia AS ss 
		                                            ON ss.id_padre = gg.id_gruppo 
				                                  WHERE ss.id_figlio = @id 
				                                    AND gg.id_causa_fine = 5">
		            <SelectParameters>
			            <asp:SessionParameter Name="id" SessionField="id_gruppo" />
		            </SelectParameters>
		        </asp:SqlDataSource>
    			
		        <br />

		        <asp:GridView ID="GridView2" runat="server" CssClass="tab_gen" 
		            AutoGenerateColumns="False" DataKeyNames="id_gruppo" 
		            DataSourceID="SqlDataSource2">
		            <Columns>
			        <asp:TemplateField HeaderText="Il gruppo si è formato dalla scissione di:" SortExpression="nome_gruppo">
			            <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo_sci" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		                </asp:LinkButton>   
				        
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
			        <asp:BoundField DataField="data_fine" HeaderText="Data" 
			            SortExpression="data_fine" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>
		        
		        <asp:SqlDataSource ID="SqlDataSource2" 
		                           runat="server" 
		                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                           
		                           SelectCommand="SELECT gg.id_gruppo, 
		                                                 LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
		                                                 gg.data_fine 
		                                          FROM gruppi_politici AS gg 
		                                          INNER JOIN gruppi_politici_storia AS ss 
		                                            ON ss.id_padre = gg.id_gruppo 
		                                          WHERE ss.id_figlio = @id 
		                                            AND gg.id_causa_fine = 11" >
		            <SelectParameters>
			            <asp:SessionParameter Name="id" SessionField="id_gruppo" />
		            </SelectParameters>
		        </asp:SqlDataSource>

		        <br />
    			
		        <asp:GridView ID="GridView3" runat="server" CssClass="tab_gen" 
		            AutoGenerateColumns="False" DataKeyNames="id_gruppo" 
		            DataSourceID="SqlDataSource3">
		            <Columns>
			        <asp:TemplateField HeaderText="Il gruppo si è formato dalla ridenominazione di:" SortExpression="nome_gruppo">
			            <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo_rid" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		                </asp:LinkButton>
		                
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
			        <asp:BoundField DataField="data_fine" HeaderText="Data" 
			            SortExpression="data_fine" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>
    		
	                <asp:SqlDataSource ID="SqlDataSource3" 
	                                   runat="server" 
		                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                               
		                               SelectCommand="SELECT gg.id_gruppo, 
		                                                     LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
		                                                     gg.data_fine 
                                                      FROM gruppi_politici AS gg 
                                                      INNER JOIN gruppi_politici_storia AS ss 
                                                        ON ss.id_padre = gg.id_gruppo 
                                                      WHERE ss.id_figlio = @id 
                                                        AND gg.id_causa_fine = 10">
		            <SelectParameters>
			        <asp:SessionParameter Name="id" SessionField="id_gruppo" />
		            </SelectParameters>
		        </asp:SqlDataSource>
    			
		        <br />
    			
		        <asp:GridView ID="GridView4" runat="server" CssClass="tab_gen" 
		            DataSourceID="SqlDataSource4" AutoGenerateColumns="False">
		            <Columns>
			        <asp:TemplateField HeaderText="Il gruppo si è aggregato in:" SortExpression="nome_gruppo">
			            <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo_aggregazione" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		                </asp:LinkButton>
		                
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
			        <asp:BoundField DataField="data_fine" HeaderText="Data" 
			            SortExpression="data_fine" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>
		        
		        <asp:SqlDataSource ID="SqlDataSource4" 
		                           runat="server" 
		                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                           
		                           SelectCommand="SELECT gg.id_gruppo, 
		                                                 LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
		                                                 gg2.data_fine 
		                                          FROM gruppi_politici AS gg 
		                                          INNER JOIN gruppi_politici_storia AS ss 
		                                            ON ss.id_figlio = gg.id_gruppo 
		                                          INNER JOIN gruppi_politici AS gg2 
		                                            ON gg2.id_gruppo = ss.id_padre
				                                  WHERE ss.id_padre = @id 
				                                    AND gg2.id_causa_fine = 5">
		            <SelectParameters>
			        <asp:SessionParameter Name="id" SessionField="id_gruppo" />
		            </SelectParameters>
		        </asp:SqlDataSource>

		        <br />
    			
		        <asp:GridView ID="GridView5" runat="server" CssClass="tab_gen" 
		            AutoGenerateColumns="False" DataKeyNames="id_gruppo" 
		            DataSourceID="SqlDataSource5">
		            <Columns>
			        <asp:TemplateField HeaderText="Il gruppo si è scisso in:" SortExpression="nome_gruppo">
			            <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo_scissione" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		                </asp:LinkButton>
		                
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
			        <asp:BoundField DataField="data_fine" HeaderText="Data" 
			            SortExpression="data_fine" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>
		        
		        <asp:SqlDataSource ID="SqlDataSource5" runat="server" 
		            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		            SelectCommand="SELECT gg.id_gruppo, 
		                                  LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
		                                  gg2.data_fine 
                                   FROM gruppi_politici AS gg 
                                   INNER JOIN gruppi_politici_storia AS ss 
                                     ON ss.id_figlio = gg.id_gruppo 
                                   INNER JOIN gruppi_politici AS gg2 
                                     ON gg2.id_gruppo = ss.id_padre
				                   WHERE ss.id_padre = @id 
				                     AND gg2.id_causa_fine = 11">
		            <SelectParameters>
			        <asp:SessionParameter Name="id" SessionField="id_gruppo" />
		            </SelectParameters>
		        </asp:SqlDataSource>

		        <br />
    			
		        <asp:GridView ID="GridView6" runat="server" CssClass="tab_gen" 
		            AutoGenerateColumns="False" DataKeyNames="id_gruppo" 
		            DataSourceID="SqlDataSource6">
		            <Columns>
			        <asp:TemplateField HeaderText="Il gruppo si è ridenominato in:" SortExpression="nome_gruppo">
			            <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo_ridenominazione" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                onclientclick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo")) %>' >
		                </asp:LinkButton>
				        
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" />
			        </asp:TemplateField>
			        <asp:BoundField DataField="data_fine" HeaderText="Data" 
			            SortExpression="data_fine" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="center" ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>
    		
	                <asp:SqlDataSource ID="SqlDataSource6" runat="server" 
		            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		            SelectCommand="SELECT gg.id_gruppo, 
		                                  LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo, 
		                                  gg2.data_fine 
                                   FROM gruppi_politici AS gg 
                                   INNER JOIN gruppi_politici_storia AS ss 
                                     ON ss.id_figlio = gg.id_gruppo 
                                   INNER JOIN gruppi_politici AS gg2 
                                     ON gg2.id_gruppo = ss.id_padre
				                   WHERE ss.id_padre = @id 
				                     AND gg2.id_causa_fine = 10">
		            <SelectParameters>
			        <asp:SessionParameter Name="id" SessionField="id_gruppo" />
		            </SelectParameters>
		        </asp:SqlDataSource>
    		
	            </ContentTemplate>
	        </asp:UpdatePanel>
            </div>
        </div>
    </td>
</tr>
<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td align="right">
	    <b>
	        <a id="a_back" 
	           runat="server" 
	           href="../gruppi_politici/gestisciGruppiPolitici.aspx">
	            « Indietro
	        </a>
	    </b>
    </td>
</tr>

<tr>
    <td>
	&nbsp;
    </td>
</tr>
</table>
</asp:Content>