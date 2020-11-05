<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="incarichi_extra_istituzionali_assessore.aspx.cs" 
         Inherits="incarichi_extra_istituzionali_assessore" 
         Title="Incarichi Extra Istituzionali" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<%@ Register src="incarichi_scheda.ascx" tagname="incarichi_scheda" tagprefix="inc" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:ScriptManager ID="ScriptManager_1" runat="server" EnableScriptGlobalization="True">
</asp:ScriptManager>

<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
        <br />
    </td>
</tr>

<tr>
    <td>
	    <asp:DataList ID="DataList1" runat="server" DataSourceID="SqlDataSourceHead" Width="50%">
	        <ItemTemplate>
		    <table>
		        <tr>
			        <td width="50">
			            <img alt="" 
			                 src="<%= photoName %>" 
			                 width="50" 
			                 height="50" 
			                 style="border: 1px solid #99cc99; margin-right: 10px;" 
			                 align="middle" />
			        </td>
    			    
			        <td>
			            <span style="font-size: 1.5em; font-weight: bold; color: #50B306;">
			                <asp:Label ID="LabelHeadNome" 
			                           runat="server" 
			                           Text='<%# Eval("nome_completo") %>' >
			                </asp:Label>
			            </span>
        			    
			            <br />
        			    
			            <asp:Label ID="LabelHeadDataNascita" 
			                       runat="server" 
			                       Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' >
			            </asp:Label>
        			    
			            <asp:Label ID="LabelHeadGruppo" 
			                       runat="server" 
			                       Font-Bold="true" 
			                       Text='<%# Eval("nome_gruppo") %>' >
			            </asp:Label>
			        </td>
		        </tr>
		    </table>
	        </ItemTemplate>
	    </asp:DataList>
    	
	    <asp:SqlDataSource ID="SqlDataSourceHead" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	                   
	                   SelectCommand="SELECT pp.nome + ' ' + pp.cognome AS nome_completo, 
                                             pp.data_nascita, 
                                             '(' + COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO') + ')' AS nome_gruppo 
			                          FROM persona AS pp 
			                          LEFT OUTER JOIN join_persona_gruppi_politici AS jpgp 
			                            ON (pp.id_persona = jpgp.id_persona 
			                                AND (jpgp.data_fine IS NULL OR jpgp.data_fine &gt;= GETDATE()) 
			                                AND (jpgp.deleted = 0 OR jpgp.deleted IS NULL))
			                          LEFT OUTER JOIN gruppi_politici AS gg 
			                            ON jpgp.id_gruppo = gg.id_gruppo 
			                          WHERE pp.id_persona = @id_persona">
	    
	    <SelectParameters>
		    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
	    </SelectParameters>
	</asp:SqlDataSource>
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
            <tab:TabsPersona runat="server" ID="tabsPersona" />
        </div>

        <div id="tab_content">
            <div id="tab_content_content">
                <table width="100%">
	            <tr>
		            <td align="left" valign="middle">
		                <asp:Label ID="lbl_search_legislatura" 
		                           runat="server" 
		                           Text="Legislatura: ">
		                </asp:Label>
    		            
		                <asp:DropDownList ID="ddl_search_legislatura" 
		                                  runat="server" 
		                                  AutoPostBack="true" 
			                              AppendDataBoundItems="false"
		                                  DataSourceID="SqlDataSource_Search_Legislature"
			                              DataTextField="num_legislatura" 
			                              DataValueField="id_legislatura" 
			                              OnSelectedIndexChanged="legislatura_selected">
		                </asp:DropDownList>
    				    
<%--				        <asp:RegularExpressionValidator ID="REV_search_legislatura" 
				                                        runat="server"
				                                        ControlToValidate="ddl_search_legislatura"
				                                        Display="Dynamic"
				                                        ErrorMessage="*"
				                                        ValidationExpression="^([1-9]+)$"
				                                        ValidationGroup="ValGroup_New" >
				        </asp:RegularExpressionValidator>--%>
    				    
		                <asp:SqlDataSource ID="SqlDataSource_Search_Legislature" 
		                                   runat="server" 
		                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    					                   
			                               SelectCommand="SELECT 0 AS id_legislatura,
		                                                         '(seleziona)' AS num_legislatura,
		                                                         '30001231' AS durata_legislatura_da
		                                                  UNION
			                                              SELECT DISTINCT ll.id_legislatura, 
			                                                              ll.num_legislatura,
			                                                              ll.durata_legislatura_da 
			                                              FROM legislature AS ll
			                                              INNER JOIN join_persona_organo_carica AS jpoc
			                                                 ON ll.id_legislatura = jpoc.id_legislatura
			                                              INNER JOIN persona AS pp
			                                                 ON jpoc.id_persona = pp.id_persona
			                                              WHERE pp.id_persona = @id_persona
			                                              ORDER BY durata_legislatura_da DESC" >
			                <SelectParameters>
			                    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
			                </SelectParameters>
		                </asp:SqlDataSource>
		            </td>
    				
		            <td align="left" valign="middle" >
		                <asp:Label ID="lbl_search_data_dichiarazione" 
		                           runat="server" 
		                           Text="Dichiarazione del: ">
		                </asp:Label>
    		            
		                <%--OnSelectedIndexChanged="ddl_search_data_dichiarazione_selected"--%>
		                <asp:DropDownList ID="ddl_search_data_dichiarazione"
		                                  runat="server"
		                                  AutoPostBack="true" 
		                                  AppendDataBoundItems="false"
		                                  DataSourceID="SQLDataSource_Dichiarazioni"
		                                  DataValueField="id_scheda"
		                                  DataTextField="data_dichiarazione"
		                                  OnSelectedIndexChanged="scheda_selected" >
		                </asp:DropDownList>
    		            
		                <asp:SqlDataSource ID="SQLDataSource_Dichiarazioni" 
		                                   runat="server"
		                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    		                               
		                                   SelectCommand="SELECT 0 AS id_scheda,
		                                                         '(seleziona)' AS data_dichiarazione,
		                                                         '30001231' AS data
		                                                  UNION
		                                                  SELECT sc.id_scheda,
                                                                 CONVERT(varchar, sc.data, 103) AS data_dichiarazione,
                                                                 sc.data
                                                          FROM scheda AS sc
                                                          INNER JOIN persona AS pp
                                                             ON sc.id_persona = pp.id_persona
                                                          INNER JOIN legislature AS ll
                                                             ON sc.id_legislatura = ll.id_legislatura
                                                          WHERE sc.deleted = 0
                                                            AND pp.deleted = 0
                                                            AND pp.id_persona = @id_persona
                                                            AND ll.id_legislatura = @id_legislatura
                                                          ORDER BY data DESC" >
                            <SelectParameters>
                                <asp:ControlParameter ControlID="ddl_search_legislatura" Name="id_legislatura" Type="Int32" />
                                <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                            </SelectParameters>
		                </asp:SqlDataSource>
		            </td>
    		        
		            <td align="right" valign="middle">
		                <% if (Session.IsEditable_IncExtraCost()) { %>
		                <asp:Button ID="btn_new_scheda"
		                            runat="server"
		                            Text="Nuova Dichiarazione"
		                            CausesValidation="true"
		                            ValidationGroup="ValGroup_New"
		                            OnClick="New_Scheda" />
		                <% } %>
		            </td>
	            </tr>
	            </table>
                
                <inc:incarichi_scheda runat="server" ID="Scheda" OnSchedaAdded="Scheda_SchedaAdded" OnschedaDeleted="Scheda_SchedaDeleted" /> 

            </div>
        </div>
    </td>
</tr>


<tr>
    <td align="right">
        <b>
            <a id="a_back" 
               runat="server" 
               href="../persona/persona.aspx">
                « Indietro
            </a>
        </b>
    </td>
</tr>
</table>
</asp:Content>