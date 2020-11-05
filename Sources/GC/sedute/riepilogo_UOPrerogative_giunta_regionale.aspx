<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="riepilogo_UOPrerogative_giunta_regionale.aspx.cs" 
         Inherits="riepilogo_UOPrerogative_giunta_regionale" 
         Title="Riepilogo Mensile Giunta Regionale" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:ScriptManager ID="ScriptManager" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>


<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	<b>RIEPILOGO GIUNTA REGIONALE</b>
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
		    <li >
		        <a href="riepilogoCR.aspx">
		            RIEPILOGO UFFICIO DI PRESIDENZA
		        </a>
		    </li>
		    
		    <li id="selected">
		        <a href="riepilogo_UOPrerogative_giunta_regionale.aspx">
		            RIEPILOGO GIUNTA REGIONALE
		        </a>
		    </li>
		    <li>
		        <a href="riepilogo_UOPrerogative.aspx">
                    <%--RIEPILOGO MENSILE DIARIA E RIMBORSO SPESE--%>
		            RIEPILOGO MENSILE
		        </a>
		    </li>
	    </ul>
	</div>
	
	<div id="tab_content">
	    <div id="tab_content_content">
		    <asp:Panel ID="Panel_Master" runat="server" UpdateMode="Conditional">
		        <table width="100%">
		        <tr>
		            <td align="left">
                        <asp:Label ID="lbl_legislatura" 
                                   runat="server"
                                   Text="Legislatura: "
                                   Width="80px">
                        </asp:Label> 
                        
                        <asp:DropDownList ID="ddl_legislatura" 
                                          runat="server"
                                          AppendDataBoundItems="true" 
                                          DataTextField="num_legislatura"
                                          DataValueField="id_legislatura"
                                          DataSourceID="SQLDataSource_ddlLegislatura">
                        </asp:DropDownList>
                        
                        <asp:SqlDataSource ID="SQLDataSource_ddlLegislatura" 
                                           runat="server"
                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                	                       
                                           SelectCommand="SELECT id_legislatura,
                                                                 num_legislatura
                                                          FROM legislature
                                                          ORDER BY durata_legislatura_da DESC">
                        </asp:SqlDataSource>
                    </td>
                    
                    <td align="left" valign="middle">
			            Seleziona Anno:
			            <asp:DropDownList ID="DropDownListAnnoRiepilogo" 
			                              runat="server" 
			                              DataSourceID="SqlDataSourceAnniRiepilogo"
				                          DataTextField="anno" 
				                          DataValueField="anno" 
				                          Width="100px">
			            </asp:DropDownList>
			            
			            <asp:SqlDataSource ID="SqlDataSourceAnniRiepilogo" 
			                               runat="server" 
			                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    				                       
				                           SelectCommand="SELECT anno 
				                                          FROM tbl_anni 
				                                          WHERE anno &gt; (YEAR(GETDATE()) - 25) 
				                                            AND anno &lt;= YEAR(GETDATE()) 
				                                          ORDER BY anno DESC">
			            </asp:SqlDataSource>
			        </td>
		        
			        <td align="left" valign="middle">
			            Seleziona Mese:
			            <asp:DropDownList ID="DropDownListMeseRiepilogo" runat="server" Width="100px">
				            <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
				            <asp:ListItem Text="Gennaio" Value="1"></asp:ListItem>
				            <asp:ListItem Text="Febbraio" Value="2"></asp:ListItem>
				            <asp:ListItem Text="Marzo" Value="3"></asp:ListItem>
				            <asp:ListItem Text="Aprile" Value="4"></asp:ListItem>
				            <asp:ListItem Text="Maggio" Value="5"></asp:ListItem>
				            <asp:ListItem Text="Giugno" Value="6"></asp:ListItem>
				            <asp:ListItem Text="Luglio" Value="7"></asp:ListItem>
				            <asp:ListItem Text="Agosto" Value="8"></asp:ListItem>
				            <asp:ListItem Text="Settembre" Value="9"></asp:ListItem>
				            <asp:ListItem Text="Ottobre" Value="10"></asp:ListItem>
				            <asp:ListItem Text="Novembre" Value="11"></asp:ListItem>
				            <asp:ListItem Text="Dicembre" Value="12"></asp:ListItem>
			            </asp:DropDownList>
    			        
			            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListMeseRiepilogo"
				                                    runat="server" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="DropDownListMeseRiepilogo"
				                                    Display="Dynamic" 
				                                    ValidationGroup="validgroup_filters" >
				        </asp:RequiredFieldValidator>
			        </td>
    			    
			        <td align="right" valign="middle">
			            <asp:Button ID="btn_filters" 
			                        runat="server" 
			                        Text="Visualizza" 
				                    ValidationGroup="validgroup_filters" 
    				                
				                    OnClick="ApplyFilter" />
			        </td>
		        </tr>
		        </table>

		        <br />
    			
    			<table width="100%">
    			    <tr>
    			        <td align="center">
    			            <asp:GridView ID="GridView1" 
		                                  runat="server" 
		                                  CssClass="tab_gen" 
		                                  AutoGenerateColumns="False"
		                                  DataSourceID="SqlDataSource1" >
                                
                                <EmptyDataTemplate>
		                            <table width="100%" class="tab_gen">
	                                <tr>
	                                    <th>
	                                        NESSUN DATO DISPONIBILE
	                                    </th>
	                                </tr>
		                            </table>
		                        </EmptyDataTemplate>
                                
		                        <Columns>
		                            <asp:BoundField DataField="componente" 
			                                        SortExpression="componente"
			                                        HeaderText="Componente"  
			                                        ItemStyle-HorizontalAlign="Left" />
                    			                  
		                            <asp:BoundField DataField="num_presenze" 
			                                        SortExpression="num_presenze"
			                                        HeaderText="Presente" 
			                                        ItemStyle-Width="90px"
			                                        ItemStyle-HorizontalAlign="Center" />
                    			                    
			                        <asp:BoundField DataField="num_assenze" 
			                                        SortExpression="num_assenze"
			                                        HeaderText="Assente" 
			                                        ItemStyle-Width="90px"
			                                        ItemStyle-HorizontalAlign="Center" />
			                                        
			                        <asp:BoundField DataField="num_missioni" 
			                                        SortExpression="num_missioni"
			                                        HeaderText="In missione"
			                                        ItemStyle-Width="90px"
			                                        ItemStyle-HorizontalAlign="Center"/>
		                        </Columns>
		                    </asp:GridView>
                			
		                    <asp:SqlDataSource ID="SqlDataSource1" 
		                                       runat="server" 
		                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
		                    </asp:SqlDataSource>
    			        </td>
    			    </tr>
    			    
    			    <tr>
    			        <td align="right">
    			            <asp:CheckBox ID="chkOptionLandscape" 
                                          runat="server"
                                          Text="Landscape"  
                                          Checked="false" />
                                          
                            <asp:Label ID="lblGap" 
                                       runat="server" 
                                       Text="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;">
                            </asp:Label>  
                                  
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
    			        </td>
    			    </tr>
    			</table>
    			
    			<div align="center">
		            <asp:Button ID="ButtonInvia" 
		                        runat="server" 
		                        Text="Invia i fogli presenze di questo mese" 
			                    onclick="ButtonInvia_Click" 
    			                
			                    OnClientClick="return confirm ('Confermare tutti i fogli presenza del mese selezionato?\nNon sarà più possibile effettuare ulteriori modifiche al foglio presenze.');" />
		        </div>
		    </asp:Panel>
	    </div>
	</div>
    </td>
</tr>

<tr>
    <td>
	&nbsp;
    </td>
</tr>
</table>
</asp:Content>