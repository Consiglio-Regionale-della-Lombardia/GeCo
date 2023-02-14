<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master"
         CodeFile="componenti.aspx.cs" 
         Inherits="legislature_componenti" 
         Title="Legislatura > Persone" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	    <br />
    </td>
</tr>

<tr>
    <td>
	<b>LEGISLATURA &gt; PERSONE</b>
    </td>
</tr>

<tr>
    <td>
	    <br />
    </td>
</tr>

<tr>
    <td>
    <div id="tab">
        <ul>
	        <li><a id="leg_anagrafica" runat="server">ANAGRAFICA</a></li>
		    <li><a id="leg_gruppi_politici" runat="server">GRUPPI POLITICI</a></li>
		    <li id="selected"><a id="leg_componenti" runat="server">PERSONE</a></li>
        </ul>
    </div>
	
	<div id="tab_content">
	    <div id="tab_content_content">
		<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		    <ContentTemplate>
			<table width="100%">
		    <tr>			
				<td align="left" valign="middle">
				    <asp:Label ID="lbl_data_search" 
				               runat="server"
				               Text="Seleziona data: ">
				    </asp:Label>
				    
				    <asp:TextBox ID="TextBoxFiltroData" 
				                 runat="server" 
				                 Width="70px">
				    </asp:TextBox>
				    
				    <img id="ImageFiltroData" 
				         runat="server" 
				         alt="calendar" 
				         src="../img/calendar_month.png" />
				    
				    <cc1:CalendarExtender ID="CalendarExtenderFiltroData" 
				                          runat="server" 
				                          TargetControlID="TextBoxFiltroData"
					                      PopupButtonID="ImageFiltroData" 
					                      Format="dd/MM/yyyy">
				    </cc1:CalendarExtender>
				    
				    <asp:ScriptManager ID="ScriptManager2" 
				                       runat="server" 
				                       EnableScriptGlobalization="True">
				    </asp:ScriptManager>
				</td>
				
				<td align="right" valign="middle">
				    <asp:Button ID="ButtonFiltri" 
				                runat="server" 
				                Text="Applica" 
				                Width="100px"
				                OnClick="ButtonFiltri_Click" />
				</td>
			</tr>
			</table>
			
			<br />
			
			<asp:GridView ID="GridView1" 
			              runat="server" 
			              AllowSorting="True" 
			              AutoGenerateColumns="False"
			              CellPadding="5" 
			              CssClass="tab_gen" 
			              DataSourceID="SqlDataSource1" 
			              GridLines="None" 
			              
			              onrowdatabound="GridView1_RowDataBound" >
			              
			    <EmptyDataTemplate>
				    <table width="100%" class="tab_gen">
				    <tr>
					    <th align="center">
					        Nessun record trovato.
					    </th>
				    </tr>
				    </table>
			    </EmptyDataTemplate>
			    <AlternatingRowStyle BackColor="#b2cca7" />	
			    <Columns>
				    <asp:TemplateField HeaderText="Cognome" SortExpression="cognome">
				        <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_cognome" 
		                                runat="server"
		                                Text='<%# Eval("cognome") %>'
		                                Font-Bold="true"
		                                OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona"), Eval("tipo_carica")) %>' >
		                </asp:LinkButton>
				        </ItemTemplate>
				        
				        <ItemStyle Font-Bold="True" />
				    </asp:TemplateField>
    				
				    <asp:TemplateField HeaderText="Nome" SortExpression="nome">
				        <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_nome" 
		                                runat="server"
		                                Text='<%# Eval("nome") %>'
		                                Font-Bold="true"
		                                OnClientClick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona"), Eval("tipo_carica")) %>' >
		                </asp:LinkButton>
				        </ItemTemplate>
				        
				        <ItemStyle Font-Bold="True" />
				    </asp:TemplateField>
    				
				    <asp:TemplateField HeaderText="Gruppo Politico" SortExpression="nome_gruppo">
				        <ItemTemplate>
				        <asp:LinkButton ID="lnkbtn_gruppo" 
		                                runat="server"
		                                Text='<%# Eval("nome_gruppo") %>'
		                                Font-Bold="true"
		                                OnClientClick='<%# getPopupURL("../gruppi_politici/dettaglio.aspx", Eval("id_gruppo"), null) %>' >
		                </asp:LinkButton>
		                
		                </ItemTemplate>
				        <ItemStyle Font-Bold="True" />
				    </asp:TemplateField>
				    
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
			                   
			                   SelectCommand="SELECT pp.id_persona 
                                                    ,pp.cognome 
                                                    ,pp.nome 
                                                    ,COALESCE(gg.id_gruppo, 0) AS id_gruppo 
                                                    ,COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO ASSOCIATO') AS nome_gruppo
                                                    ,jpgp.data_inizio
                                                    ,jpgp.data_fine
                                                    ,CASE 
                                                        WHEN cc.id_tipo_carica = 4 --'consigliere regionale' 
															THEN 0
                                                        WHEN cc.id_tipo_carica = 5 --'consigliere regionale supplente' 
															THEN 0
                                                        ELSE 1
                                                     END AS tipo_carica
                                              FROM persona AS pp
                                              INNER JOIN join_persona_organo_carica AS jpoc
                                                 ON pp.id_persona = jpoc.id_persona
                                              INNER JOIN legislature AS ll
                                                 ON jpoc.id_legislatura = ll.id_legislatura
                                              INNER JOIN organi AS oo
                                                 ON jpoc.id_organo = oo.id_organo
                                              INNER JOIN cariche AS cc
                                                 ON jpoc.id_carica = cc.id_carica
                                              LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp
                                                 ON (jpgp.deleted = 0 
                                                     AND pp.id_persona = jpgp.id_persona 
                                                     AND ll.id_legislatura = jpgp.id_legislatura)
                                              LEFT OUTER JOIN gruppi_politici AS gg 
                                                 ON (gg.deleted = 0 
                                                     AND jpgp.id_gruppo = gg.id_gruppo)
                                              WHERE pp.deleted = 0 AND pp.chiuso = 0
                                                AND jpoc.deleted = 0
                                                AND oo.deleted = 0
                                                AND ll.id_legislatura = @id_legislatura 
                                                AND oo.id_categoria_organo IN (1, 4) --'consiglio regionale', 'giunta regionale'
                                                AND cc.id_tipo_carica IN (3, 4, 5) --'consigliere regionale', 'consigliere regionale supplente', 'assessore non consigliere'
                                              ORDER BY pp.cognome, pp.nome" >
			    <SelectParameters> 
			        <asp:QueryStringParameter Name="id_legislatura" QueryStringField="id" Type="Int32" />
			    </SelectParameters>
			</asp:SqlDataSource>
		    </ContentTemplate>
		</asp:UpdatePanel>
		
		<div align="right">
		    <br />
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
	</div>
    </td>
</tr>

<tr>
    <td>
	    <br />
    </td>
</tr>

<tr>
    <td align="right">
	    <b>
	        <a id="anchor_back" 
	           runat="server" 
	           href="../legislature/gestisciLegislature.aspx">
	            « Indietro
	        </a>
	    </b>
    </td>
</tr>

<tr>
    <td>
	    <br />
    </td>
</tr>
</table>
</asp:Content>