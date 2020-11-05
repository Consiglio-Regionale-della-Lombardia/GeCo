<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         MasterPageFile="~/MasterPage.master" 
         CodeFile="riepilogo2.aspx.cs" 
         Inherits="sedute_riepilogo2" 
         Title="Riepilogo Numero Sedute" %>

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
		<b>RIEPILOGO NUMERO DELLE SEDUTE DELLE COMMISSIONI</b>
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
			        <li>
			            <a href="riepilogo.aspx">
			                RIEPILOGO PRES/ASS
			            </a>
			        </li>
    			    
			        <li id="selected">
			            <a href="riepilogo2.aspx">
			                RIEPILOGO SEDUTE
			            </a>
			        </li>
		        </ul>
		    </div>
    		
		    <div id="tab_content">
		        <div id="tab_content_content">
			        <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
			            <ContentTemplate>
				        <table width="100%">
				        <tr>
				            <td valign="middle" align="left">
					            Tipo Seduta:
					            <asp:DropDownList ID="DropDownListTipoSedute" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceTipoSedute"
						                          DataTextField="tipo_incontro" 
						                          DataValueField="id_incontro" 
						                          AppendDataBoundItems="true">
						            <asp:ListItem Value="all" Text="Tutte"/>
					            </asp:DropDownList>
					            
					            <asp:SqlDataSource ID="SqlDataSourceTipoSedute" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           
						                           SelectCommand=" SELECT id_incontro, 
						                                                  tipo_incontro 
                                                                   FROM tbl_incontri">
					            </asp:SqlDataSource>					
					        </td>
					        
					        <td valign="middle" align="left">
					            Seleziona Anno:
					            <asp:DropDownList ID="DropDownListAnnoRiepilogo" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceAnniRiepilogo"
						                          DataTextField="anno" 
						                          DataValueField="anno" >
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
					        
					        <td valign="middle" align="left">
					            Seleziona Mese:
					            <asp:DropDownList ID="DropDownListMeseRiepilogo" 
					                              runat="server">
						            <asp:ListItem Text='(seleziona)' Value=''></asp:ListItem>
						            <asp:ListItem Text='1' Value='1'>Gennaio</asp:ListItem>
						            <asp:ListItem Text='2' Value='2'>Febbraio</asp:ListItem>
						            <asp:ListItem Text='3' Value='3'>Marzo</asp:ListItem>
						            <asp:ListItem Text='4' Value='4'>Aprile</asp:ListItem>
						            <asp:ListItem Text='5' Value='5'>Maggio</asp:ListItem>
						            <asp:ListItem Text='6' Value='6'>Giugno</asp:ListItem>
						            <asp:ListItem Text='7' Value='7'>Luglio</asp:ListItem>
						            <asp:ListItem Text='8' Value='8'>Agosto</asp:ListItem>
						            <asp:ListItem Text='9' Value='9'>Settembre</asp:ListItem>
						            <asp:ListItem Text='10' Value='10'>Ottobre</asp:ListItem>
						            <asp:ListItem Text='11' Value='11'>Novembre</asp:ListItem>
						            <asp:ListItem Text='12' Value='12'>Dicembre</asp:ListItem>
					            </asp:DropDownList>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListMeseRiepilogo"
						                                    runat="server" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ControlToValidate="DropDownListMeseRiepilogo"
						                                    Display="Dynamic" 
						                                    ValidationGroup="GroupRiepilogo" >
						        </asp:RequiredFieldValidator>
					        </td>
					        
					        <td valign="middle" align="right">
					            <asp:Button ID="ButtonRiepilogo" 
					                        runat="server" 
					                        Text="Visualizza" 
					                        ValidationGroup="GroupRiepilogo"
					                        
					                        OnClick="ButtonRiepilogo_Click" />
					        </td>
				            </tr>
				        </table>
				        
				        <br />
				        
				        <asp:GridView ID="GridView1" 
				                      runat="server" 
				                      CssClass="tab_gen_s" 
				                      AutoGenerateColumns="False" 
				                      DataKeyNames="id_organo" 
				                      DataSourceID="SqlDataSource1"
                                      OnPreRender="GridView1_PreRender"
                                      OnRowDataBound="GridView1_RowDataBound">
				                      
				            <Columns>
					            <asp:TemplateField HeaderText="Commissione" SortExpression="nome_organo">
					                <ItemTemplate>
						                <asp:LinkButton ID="lnkbtn_organo" 
		                                                runat="server"
		                                                Text='<%# Eval("nome_organo") %>'
		                                                Font-Bold="true"
		                                                onclientclick='<%# getPopupURL("../organi/dettaglio.aspx", Eval("id_organo")) %>' >
		                                </asp:LinkButton>
					                </ItemTemplate>
					                <ItemStyle Font-Bold="True" HorizontalAlign="Center" />
					            </asp:TemplateField>
				        
    					        <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
					        
					            <asp:TemplateField>
					                <ItemTemplate></ItemTemplate>
					                <ItemStyle Width="16px" HorizontalAlign="Center" />
					            </asp:TemplateField>
				            </Columns>
				        </asp:GridView>
                			
				        <asp:SqlDataSource ID="SqlDataSource1" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
				                           
				                           SelectCommand="SELECT id_organo, 
	                                                               nome_organo 
                                                            FROM
                                                            (
	                                                            select 0 as id_organo
	                                                                  ,'' as nome_organo
		                                                              ,0 as ordinamento
                                                            
	                                                            union
	
	                                                            SELECT id_organo
		                                                              ,case when isnull(nome_organo_breve,'') &lt;&gt; '' then nome_organo_breve
		                                                               else nome_organo end as nome_organo
		                                                              ,ordinamento
	                                                            FROM organi 
	                                                            WHERE deleted = 0
	                                                            AND id_legislatura = @id_legislatura
	                                                            AND vis_serv_comm = 1 
                                                            ) Q
                            
                                                            order by ordinamento">
				            <SelectParameters>
					            <asp:SessionParameter Name="id_legislatura" SessionField="id_legislatura" Type="Int32" />
				            </SelectParameters>
				        </asp:SqlDataSource>
			            </ContentTemplate>
			        </asp:UpdatePanel>
    			    
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
	    </td>
	</tr>
	
	<tr>
	    <td align="right">
		    <b>
		    <a href="../sedute/gestisciSedute.aspx">
		        « Indietro
		    </a>
		    </b>
		    
		    <br />
		    <br />
	    </td>
	</tr>
    </table>
</asp:Content>