<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="schede_extra.aspx.cs" 
         Inherits="schede_extra" 
         Title="Incarichi Extra Istituzionali > Schede" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	    &nbsp;
    </td>
</tr>

<tr>
    <td>
	<asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSourceHead" Width="50%">
	    <ItemTemplate>
		<table>
		    <tr>
			<td width="50px">
			    <img alt="" src="<%= photoName %>" width="50px" height="50px" style="border: 1px solid #99cc99; margin-right: 10px;" align="middle" />
			</td>
			<td>
			    <span style="font-size: 1.5em; font-weight: bold; color: #50B306;"><asp:Label ID="LabelHeadNome" runat="server" Text='<%# Eval("nome") + " " + Eval("cognome") %>' /></span>
			    <br />
			    <asp:Label ID="LabelHeadDataNascita" runat="server" Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' /> (<asp:Label ID="LabelHeadGruppo" runat="server" Text='<%# Eval("nome_gruppo") %>' />)
			</td>
		    </tr>
		</table>
	    </ItemTemplate>
	</asp:DataList>
	
	<asp:SqlDataSource ID="SqlDataSourceHead" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	                   
	                   SelectCommand="SELECT pp.nome, 
	                                         pp.cognome, 
	                                         pp.data_nascita, 
	                                         gg.nome_gruppo 
			                          FROM persona AS pp 
			                          LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp 
			                            ON pp.id_persona = jpgp.id_persona 
			                           AND (jpgp.data_fine IS NULL OR jpgp.data_fine &gt;= GETDATE()) 
			                           AND (jpgp.deleted = 0 OR jpgp.deleted IS NULL) 
			                          LEFT OUTER JOIN gruppi_politici AS gg 
			                            ON jpgp.id_gruppo = gg.id_gruppo 
			                          WHERE (pp.id_persona = @id_persona)" >
	    
	    <SelectParameters>
		    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
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
            <li><a id="a_incarichi" runat="server" >INCARICHI</a></li>
            <li id="selected"><a id="a_schede" runat="server" >SCHEDE</a></li>
	    </ul>
	</div>
	
	<div id="tab_content">
	    <div id="tab_content_content">		    
		    <table width="100%">
		    <tr>
			    <td align="left" valign="middle">
			        Seleziona legislatura:
			        <asp:DropDownList ID="DropDownListLegislatura" 
			                          runat="server" 
			                          DataSourceID="SqlDataSourceLegislature"
				                      DataTextField="num_legislatura" 
				                      DataValueField="id_legislatura" 
				                      Width="70px"
				                      AppendDataBoundItems="True">
				        <asp:ListItem Text="(tutte)" Value="" />
			        </asp:DropDownList>
				    
			        <asp:SqlDataSource ID="SqlDataSourceLegislature" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                   
				                       SelectCommand="SELECT id_legislatura, 
				                                             num_legislatura 
				                                      FROM legislature
				                                      ORDER BY durata_legislatura_da DESC">
			        </asp:SqlDataSource>
			    </td>
				
			    <td align="left" valign="middle" >
			        Seleziona data:
			        <asp:TextBox ID="TextBoxFiltroData" 
			                     runat="server" 
			                     Width="70px">
			        </asp:TextBox>
				    
			        <img id="ImageFiltroData" 
			             runat="server" 
			             alt="calendar" 
			             src="../img/calendar_month.png"  />
				    
			        <cc1:CalendarExtender ID="CalendarExtenderFiltroData" 
			                              runat="server" 
			                              TargetControlID="TextBoxFiltroData"
				                          PopupButtonID="ImageFiltroData" 
				                          Format="dd/MM/yyyy">
			        </cc1:CalendarExtender>
				    
			        <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
			                                        ControlToValidate="TextBoxFiltroData"
				                                    runat="server" 
				                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
				                                    Display="Dynamic"
				                                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
				                                    ValidationGroup="FiltroData" >
				    </asp:RegularExpressionValidator>
					
			        <asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
			        </asp:ScriptManager>
			    </td>
				
			    <td align="right" valign="middle">
			        <asp:Button ID="bnt_filter" 
			                    runat="server" 
			                    Text="Applica" 
			                    Width="100px"
				                CausesValidation="true"
				                ValidationGroup="FiltroData" 
					            
				                OnClick="Filter_Click" />
			    </td>
		    </tr>
		    </table>
			
		    <br />
			
		    <asp:GridView ID="GridView1" 
		                  runat="server" 
		                  AutoGenerateColumns="False" 
		                  DataSourceID="SqlDataSource1"
		                  PagerStyle-HorizontalAlign="Center" 
		                  AllowSorting="True"			              
		                  CellPadding="5" 
		                  CssClass="tab_gen" 
		                  GridLines="None" 
		                  DataKeyNames="id_scheda" >
			              
		        <EmptyDataTemplate>
			        <table width="100%" class="tab_gen" >
			            <tr>
				            <th align="center">
				                Nessun record trovato.
				            </th>
    					    
				            <th width="100px">
				                <% if ((role == 1) || ((role == 5) && (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni))) { %>
				                <asp:Button ID="btn_insert_empty" 
				                            runat="server" 
				                            Text="Nuovo" 
				                            CssClass="button"
					                        CausesValidation="false" 
					                        OnClick="Insert_Click" />
				                <% } %>
				            </th>
			            </tr>
			        </table>
		        </EmptyDataTemplate>
			    
		        <Columns>
			        <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
			            <ItemTemplate>
				            <asp:LinkButton ID="lnkbtn_leg" 
	                                        runat="server"
	                                        Text='<%# Eval("num_legislatura") %>'
	                                        Font-Bold="true"
	                                        onclientclick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>' >
	                        </asp:LinkButton>
			            </ItemTemplate>
				        
			            <ItemStyle HorizontalAlign="center" Font-Bold="True" />
			        </asp:TemplateField>
    				
			        <asp:BoundField DataField="data" 
			                        HeaderText="Dichiarazione del" 
			                        SortExpression="data"
			                        DataFormatString="{0:dd/MM/yyyy}" 
			                        ItemStyle-HorizontalAlign="center" 
			                        ItemStyle-Width="120px" />
    				
			        <asp:TemplateField>
			            <ItemTemplate>
				            <asp:LinkButton ID="lnkbtn_item" 
				                            runat="server" 
				                            CausesValidation="False" 
				                            Text="Dettagli"
					                        
				                            OnClick="Item_Click">
				            </asp:LinkButton>
			            </ItemTemplate>
				        
			            <HeaderTemplate>
				            <% if ((role == 1) || ((role == 5) && (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni))) { %>
				            <asp:Button ID="btn_insert_header" 
				                        runat="server" 
				                        Text="Nuovo" 
				                        CssClass="button"
				                        CausesValidation="false" 
    					                
				                        OnClick="Insert_Click" />
				            <% } %>
			            </HeaderTemplate>
				        
			            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
			        </asp:TemplateField>
		        </Columns>
		    </asp:GridView>
			
		    <asp:SqlDataSource ID="SqlDataSource1" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT sc.id_scheda, 
		                                         sc.data, 
		                                         ll.id_legislatura, 
		                                         ll.num_legislatura 
			                              FROM scheda AS sc
			                              INNER JOIN persona AS pp
			                                ON sc.id_persona = pp.id_persona
			                              INNER JOIN legislature AS ll 
			                                ON sc.id_legislatura = ll.id_legislatura
			                              WHERE pp.deleted = 0
			                                AND sc.deleted = 0 
			                                AND pp.id_persona = @id_persona">
		    <SelectParameters>
			    <asp:SessionParameter Name="id_persona" SessionField="id_persona" />
		    </SelectParameters>
		</asp:SqlDataSource>
		
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
	</div>
	
	<%--Fix per lo stile dei calendarietti--%>
	<asp:TextBox ID="TextBoxCalendarFake" 
	             runat="server" 
	             style="display: none;" >
	</asp:TextBox>
	
	<cc1:CalendarExtender ID="CalendarExtenderFake" 
	                      runat="server" 
	                      TargetControlID="TextBoxCalendarFake" 
	                      Format="dd/MM/yyyy" >
	</cc1:CalendarExtender>
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
               href="../persona/dettaglio.aspx?mode=normal">
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