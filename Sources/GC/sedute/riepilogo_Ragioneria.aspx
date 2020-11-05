<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         MasterPageFile="~/MasterPage.master"
         CodeFile="riepilogo_Ragioneria.aspx.cs" 
         Inherits="sedute_riepilogo_ragioneria" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:ScriptManager ID="ScriptManager1" 
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
	<b>RIEPILOGO MENSILE DIARIA</b>
    </td>
</tr>

<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	    <div id="tab_content">
	        <div id="tab_content_content">
		        <asp:Panel ID="Panel_Master" runat="server" UpdateMode="Conditional">
		            <table width="100%">
		            <tr>
		                <td align="left" valign="middle" width="25%">
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
			            
			            <td align="left" valign="middle" width="25%">
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
        				                
				                        OnClick="btn_filters_Click" />
			            </td>
		            </tr>
		            </table>

		            <br />
        			
    			    <table width="100%">
    			        <tr>
    			            <td align="center" width="50%">
    			                <asp:Label ID="lbl_title_cons"
    			                           runat="server"
    			                           Text="Consiglieri Regionali"
    			                           Font-Bold="true">
    			                </asp:Label>
    			            </td>
        			        
    			            <td align="center" width="50%">
    			                <asp:Label ID="lbl_title_ass"
    			                           runat="server"
    			                           Text="Assessori"
    			                           Font-Bold="true">
    			                </asp:Label>
    			            </td>
    			        </tr>
        			    
    			        <tr>
    			            <td align="center" valign="top" width="50%">
    			                <asp:GridView ID="GridView_Consiglieri" 
		                                      runat="server" 
		                                      CssClass="tab_gen" 
		                                      AutoGenerateColumns="False"
		                                      DataKeyNames="id_persona"
		                                      DataSourceID="SqlDataSource_GridView_Consiglieri" >
                                    
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
			                            <asp:TemplateField HeaderText="Nome e Cognome" SortExpression="nome_completo">
			                                <ItemTemplate>
			                                    <asp:Label ID="lbl_Nome" 
			                                               runat="server" 
			                                               Text='<%# Eval("nome_completo") %>' >
			                                    </asp:Label>
			                                </ItemTemplate>
                    			            
			                                <ItemStyle Font-Bold="True" HorizontalAlign="Left" />
			                            </asp:TemplateField>
                    					
			                            <asp:TemplateField HeaderText="Assenza Diaria">
			                                <ItemTemplate>
			                                    <asp:Label ID="lbl_assenza_diaria_val" 
			                                               runat="server"
			                                               Text='<%# Eval("assenze_diaria") %>'>
			                                    </asp:Label>
			                                </ItemTemplate>
                    			            
			                                <ItemStyle HorizontalAlign="Center" Width="100px" />
			                            </asp:TemplateField>
                    					
			                            <asp:TemplateField HeaderText="Assenza Rimborso Spese">
			                                <ItemTemplate>
			                                    <asp:Label ID="lbl_assenza_rimborso_spese_val" 
			                                               runat="server"
			                                               Text='<%# Eval("assenze_rimborso") %>'>
			                                    </asp:Label>
			                                </ItemTemplate>
                    			            
			                                <ItemStyle HorizontalAlign="Center" Width="150px" />
			                            </asp:TemplateField>
		                            </Columns>
		                        </asp:GridView>
                    			
		                        <asp:SqlDataSource ID="SqlDataSource_GridView_Consiglieri" 
		                                           runat="server" 
		                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
		                        </asp:SqlDataSource>
    			            </td>
        			        
    			            <td align="center" valign="top" width="50%">
    			                <asp:GridView ID="GridView_Assessori" 
		                                      runat="server" 
		                                      CssClass="tab_gen" 
		                                      AutoGenerateColumns="False"
		                                      DataKeyNames="id_persona"
		                                      DataSourceID="SqlDataSource_GridView_Assessori" >
                                    
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
			                            <asp:TemplateField HeaderText="Nome e Cognome" SortExpression="nome_completo">
			                                <ItemTemplate>
			                                    <asp:Label ID="lbl_Nome" 
			                                               runat="server" 
			                                               Text='<%# Eval("nome_completo") %>' >
			                                    </asp:Label>
			                                </ItemTemplate>
                    			            
			                                <ItemStyle Font-Bold="True" HorizontalAlign="Left" />
			                            </asp:TemplateField>
                    					
			                            <asp:TemplateField HeaderText="Assenza Diaria">
			                                <ItemTemplate>
			                                    <asp:Label ID="lbl_assenza_diaria_val" 
			                                               runat="server"
			                                               Text='<%# Eval("assenze_diaria") %>'>
			                                    </asp:Label>
			                                </ItemTemplate>
                    			            
			                                <ItemStyle HorizontalAlign="Center" Width="100px" />
			                            </asp:TemplateField>
                    					
			                            <asp:TemplateField HeaderText="Assenza Rimborso Spese">
			                                <ItemTemplate>
			                                    <asp:Label ID="lbl_assenza_rimborso_spese_val" 
			                                               runat="server"
			                                               Text='<%# Eval("assenze_rimborso") %>'>
			                                    </asp:Label>
			                                </ItemTemplate>
                    			            
			                                <ItemStyle HorizontalAlign="Center" Width="150px" />
			                            </asp:TemplateField>
		                            </Columns>
		                        </asp:GridView>
                    			
		                        <asp:SqlDataSource ID="SqlDataSource_GridView_Assessori" 
		                                           runat="server" 
		                                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
		                        </asp:SqlDataSource>
    			            </td>
    			        </tr>
        			    
    			        <tr>
    			            <td align="right" width="50%">
    			                <asp:CheckBox ID="chkOptionLandscape1" 
                                              runat="server"
                                              Text="Landscape"
                                              Checked="false" />
                                              
                                <asp:Label ID="lbl_gap_1" 
                                           runat="server" 
                                           Text="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" >
                                </asp:Label> 
                                
		                        <asp:LinkButton ID="lnkbtn_Export_Excel1" 
		                                        runat="server"
		                                        OnClick="LinkButtonExcel_Click" >
		                            <img src="../img/page_white_excel.png" alt="" align="top" /> 
		                            Esporta
		                        </asp:LinkButton>
		                        -
		                        <asp:LinkButton ID="lnkbtn_Export_PDF1" 
		                                        runat="server" 
		                                        OnClick="LinkButtonPdf_Click" >
		                            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		                            Esporta
		                        </asp:LinkButton>
    			            </td>
        			        
    			            <td align="right" width="50%">
    			                <asp:CheckBox ID="chkOptionLandscape2" 
                                              runat="server"
                                              Text="Landscape"
                                              Checked="false" />
                                              
                                <asp:Label ID="lbl_gap_2" 
                                           runat="server" 
                                           Text="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" >
                                </asp:Label> 
                                
		                        <asp:LinkButton ID="lnkbtn_Export_Excel2" 
		                                        runat="server"
		                                        OnClick="LinkButtonExcel_Click" >
		                            <img src="../img/page_white_excel.png" alt="" align="top" /> 
		                            Esporta
		                        </asp:LinkButton>
		                        -
		                        <asp:LinkButton ID="lnkbtn_Export_PDF2" 
		                                        runat="server" 
		                                        OnClick="LinkButtonPdf_Click" >
		                            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		                            Esporta
		                        </asp:LinkButton>
    			            </td>
    			        </tr>
    			    </table>
		        </asp:Panel>
        		
		        <br />
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