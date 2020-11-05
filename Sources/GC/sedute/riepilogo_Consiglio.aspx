<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master"
         AutoEventWireup="true" 
         EnableEventValidation="false"        
         CodeFile="riepilogo_Consiglio.aspx.cs" 
         Inherits="riepilogo_Consiglio" 
         Title="Riepilogo Mensile - Consiglio Regionale" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<%@ Register src="../allegati/allegatiList.ascx" tagname="AllegatiList" tagprefix="all" %>

<asp:Content ID="Content1" 
             ContentPlaceHolderID="ContentPlaceHolder1" 
             runat="Server">
    <asp:ScriptManager ID="ScriptManager1" 
                       runat="server" 
                       EnableScriptGlobalization="True">
    </asp:ScriptManager>
    
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
	<tr>
	    <td>
		    <br />
	    </td>
	</tr>

	<tr>
	    <td>
		    <asp:Label ID="lbl_title"
		               runat="server"
		               Font-Bold="true"
		               Text="RIEPILOGO MENSILE PRESENZE">
		    </asp:Label>
	    </td>
	</tr>
	
	<tr>
	    <td>
		    <br />
	    </td>
	</tr>
	
	<tr>
	    <td>
		    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
		        <ContentTemplate>
			        <div style="background-color: #F0F0F0; padding: 10px;">
			            <table width="100%">
				        <tr>
				            <td>
				                <asp:Label ID="lbl_search_legislatura" 
				                           runat="server"
				                           Text="Legislatura: " >
				                </asp:Label>
				                
				                <asp:DropDownList ID="ddl_search_legislatura" 
				                                  runat="server" 
				                                  AppendDataBoundItems="true"
				                                  DataSourceID="SqlDataSource_Legislature"
				                                  DataValueField="id_legislatura"
				                                  DataTextField="num_legislatura" >
				                    <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
				                </asp:DropDownList>
				                
				                <asp:RequiredFieldValidator ID="ReqVal_Legislatura" 
				                                            runat="server" 
				                                            ControlToValidate="ddl_search_legislatura" 
				                                            Display="Dynamic" 
				                                            ErrorMessage="*" 
				                                            ValidationGroup="GroupRiepilogo" >
				                </asp:RequiredFieldValidator>
				                
				                <asp:SqlDataSource ID="SqlDataSource_Legislature" 
			                                       runat="server" 
			                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
            					                   
				                                   SelectCommand="SELECT id_legislatura, 
				                                                         num_legislatura 
				                                                  FROM legislature
				                                                  ORDER BY durata_legislatura_da DESC" >
				                </asp:SqlDataSource>
				            </td>
				            
				            <td align="left" valign="middle">
					            <asp:Label ID="lbl_year" 
				                           runat="server"
				                           Text="Seleziona Anno: " >
				                </asp:Label>
				                
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
					                                              WHERE (anno &gt; YEAR(GETDATE()) - 25) 
					                                                AND (anno &lt;= YEAR(GETDATE())) 
					                                              ORDER BY anno DESC">
					            </asp:SqlDataSource>
				            </td>
				            
				            <td align="left" valign="middle" >
					            <asp:Label ID="lbl_month" 
				                           runat="server"
				                           Text="Seleziona Mese: " >
				                </asp:Label>
				                
					            <asp:DropDownList ID="DropDownListMeseRiepilogo" 
					                              runat="server" 
					                              Width="100px" >
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
					                                        ErrorMessage="*" 
					                                        ControlToValidate="DropDownListMeseRiepilogo"
					                                        Display="Dynamic" 
					                                        ValidationGroup="GroupRiepilogo" >
					            </asp:RequiredFieldValidator>
				            </td>
				            
				            <td align="right" valign="middle">
					            <asp:Button ID="ButtonRiepilogo" 
					                        runat="server" 
					                        Text="Visualizza" 
					                        CausesValidation="true"
					                        ValidationGroup="GroupRiepilogo" 
					                        
					                        OnClick="ButtonRiepilogo_Click" />
				            </td>
				        </tr>
			            </table>
			        </div>
			        
				    <asp:GridView ID="GridView1" 
				                  runat="server" 
				                  CssClass="tab_gen"  
				                  AutoGenerateColumns="False"
				                  DataKeyNames="id_seduta" 
				                  DataSourceID="SqlDataSource1">
    				    
    				    <EmptyDataTemplate>
				            <table width="100%" class="tab_gen">
					        <tr>
					            <th align="center">
						            Nessun record trovato.
					            </th>
					        </tr>
				            </table>
				        </EmptyDataTemplate>
				        
				        <Columns>
					        <asp:TemplateField HeaderText="SEDUTA">
					            <ItemTemplate>
						            <asp:Label runat="server" 
						                       ID="lblInfoSeduta" 
						                       Font-Bold="true"
						                       Text='<%# Eval("info_seduta") %>' >
						            </asp:Label>
					            </ItemTemplate>
    					        
					            <ItemStyle Width="10%" HorizontalAlign="Center" />
					        </asp:TemplateField>
        					
					        <asp:TemplateField HeaderText="CONSIGLIERI E ASSESSORI ASSENTI O IN CONGEDO PER L’INTERA SEDUTA">
					            <ItemTemplate>
					                <asp:Label ID="lblCol1" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="45%" HorizontalAlign="Justify" VerticalAlign="Top" />
					        </asp:TemplateField>
        					
                            <%-- <asp:TemplateField HeaderText="CONSIGLIERI E ASSESSORI CHE NON HANNO SOTTOSCRITTO IL FOGLIO PRESENZE/DIARIA ENTRO 15 MINUTI DALL’INIZIO DELLA SEDUTA"> --%>
					        <asp:TemplateField HeaderText="CONSIGLIERI E ASSESSORI CHE NON HANNO SOTTOSCRITTO IL FOGLIO PRESENZE ENTRO 15 MINUTI DALL’INIZIO DELLA SEDUTA">
					            <ItemTemplate>
					                <asp:Label ID="lblCol2" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="45%" HorizontalAlign="Justify" VerticalAlign="Top" />
					        </asp:TemplateField>
        					
					        <%--<asp:TemplateField HeaderText="Consiglieri assenti">
					            <ItemTemplate>
					                <asp:Label ID="lblCol3" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
					        </asp:TemplateField>
        					
					        <asp:TemplateField HeaderText="Consiglieri presenti a incontri, consultazioni, ecc">
					            <ItemTemplate>
					                <asp:Label ID="lblCol4" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
					        </asp:TemplateField>--%>
				        </Columns>
				    </asp:GridView>

				    <asp:GridView ID="GridView2" 
                                  Visible="false"
				                  runat="server" 
				                  CssClass="tab_gen"  
				                  AutoGenerateColumns="False"
				                  DataKeyNames="id_seduta" 
				                  DataSourceID="SqlDataSource2">
    				    
    				    <EmptyDataTemplate>
				            <table width="100%" class="tab_gen">
					        <tr>
					            <th align="center">
						            Nessun record trovato.
					            </th>
					        </tr>
				            </table>
				        </EmptyDataTemplate>
				        
				        <Columns>
					        <asp:TemplateField HeaderText="SEDUTA">
					            <ItemTemplate>
						            <asp:Label runat="server" 
						                       ID="lblInfoSeduta" 
						                       Font-Bold="true"
						                       Text='<%# Eval("info_seduta") %>' >
						            </asp:Label>
					            </ItemTemplate>
    					        
					            <ItemStyle Width="10%" HorizontalAlign="Center" />
					        </asp:TemplateField>
        					
					        <asp:TemplateField HeaderText="CONSIGLIERI E ASSESSORI CHE NON HANNO SOTTOSCRITTO IL FOGLIO DI RILEVAZIONE IN INGRESSO">
					            <ItemTemplate>
					                <asp:Label ID="lblCol1" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="45%" HorizontalAlign="Justify" VerticalAlign="Top" />
					        </asp:TemplateField>
        					
					        <asp:TemplateField HeaderText="CONSIGLIERI E ASSESSORI CHE NON HANNO SOTTOSCRITTO IL FOGLIO DI RILEVAZIONE IN USCITA">
					            <ItemTemplate>
					                <asp:Label ID="lblCol2" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="45%" HorizontalAlign="Justify" VerticalAlign="Top" />
					        </asp:TemplateField>

					        <asp:TemplateField HeaderText="CONSIGLIERI E ASSESSORI IN CONGEDO">
					            <ItemTemplate>
					                <asp:Label ID="lblCol3" 
					                           runat="server" >
					                </asp:Label>
					            </ItemTemplate>
					            
					            <ItemStyle Width="45%" HorizontalAlign="Justify" VerticalAlign="Top" />
					        </asp:TemplateField>
        					
				        </Columns>
				    </asp:GridView>
				    
				    <asp:SqlDataSource ID="SqlDataSource1" 
				                       runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
				    </asp:SqlDataSource>

				    <asp:SqlDataSource ID="SqlDataSource2" 
				                       runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
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
    	
            <div id="divAllegatiContainer" class="allegatiContainer">
                <all:AllegatiList ID="listAllegati" runat="server" />
            </div>
            <br />

		    <div align="center">
		        <asp:Button ID="ButtonInvia" 
		                    runat="server" 
		                    Text="Invia i fogli presenze di questo mese" 
			                onclick="ButtonInvia_Click" 
			                
			                OnClientClick="return confirm ('Confermare tutti i fogli presenza del mese selezionato?\nNon sarà più possibile effettuare ulteriori modifiche al foglio presenze.');" />
		    </div>
	    </td>
	</tr>
	
	<tr>
	    <td>
		    <br />
	    </td>
	</tr>
    </table>
</asp:Content>