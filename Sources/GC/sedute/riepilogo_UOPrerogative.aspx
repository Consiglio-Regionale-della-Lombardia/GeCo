<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         MasterPageFile="~/MasterPage.master"
         CodeFile="riepilogo_UoPrerogative.aspx.cs" 
         Inherits="sedute_riepilogo_UoPrerogative" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc2" %>

<%@ Register src="DettaglioAssenze.ascx" tagname="DettaglioAssenze" tagprefix="da" %>

<%@ Register src="../allegati/allegatiList.ascx" tagname="AllegatiList" tagprefix="all" %>

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
	<b>RIEPILOGO MENSILE</b>
    </td>
</tr>

        <tr>
    <td>
	&nbsp;
    </td>
</tr>

        <tr>
    <td>
    <% if (role != 7)
       { %>
	<div id="tab">
	    <ul>		    
		    <li>
		        <%--<a href="riepilogo_UOPrerogative_ufficio_presidenza.aspx">--%>
                <a href="riepilogoCR.aspx">
		            RIEPILOGO UFFICIO DI PRESIDENZA
		        </a>
		    </li>
		    
		    <li>
		        <a href="riepilogo_UOPrerogative_giunta_regionale.aspx">
		            RIEPILOGO GIUNTA REGIONALE
		        </a>
		    </li>
		    <li id="selected">
		        <a href="riepilogo_UOPrerogative.aspx">
                    <%--RIEPILOGO MENSILE DIARIA E RIMBORSO SPESE--%>
		            RIEPILOGO MENSILE
		        </a>
		    </li>
	    </ul>
	</div>
    <% } %>
	
	<div id="tab_content">
	    <div id="tab_content_content">

		    <asp:Panel ID="Panel_Master" runat="server" UpdateMode="Conditional">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:UpdateProgress ID="UpdateProgressGenerale" runat="server">
                            <ProgressTemplate>
                                <div align="center" style="position: fixed; text-align:center; z-index:100; top: 50%; left: 50%;">
                                    <asp:Image ID="ImageUpdate" runat="server" ImageUrl="../img/wait.gif"  />
                                </div>
                            </ProgressTemplate>
                        </asp:UpdateProgress>


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
				                    <asp:ListItem Value="" Text="(seleziona)" ></asp:ListItem>
				                    <asp:ListItem Value="1" Text="Gennaio" ></asp:ListItem>
				                    <asp:ListItem Value="2" Text="Febbraio" ></asp:ListItem>
				                    <asp:ListItem Value="3" Text="Marzo" ></asp:ListItem>
				                    <asp:ListItem Value="4" Text="Aprile" ></asp:ListItem>
				                    <asp:ListItem Value="5" Text="Maggio" ></asp:ListItem>
				                    <asp:ListItem Value="6" Text="Giugno" ></asp:ListItem>
				                    <asp:ListItem Value="7" Text="Luglio" ></asp:ListItem>
				                    <asp:ListItem Value="8" Text="Agosto" ></asp:ListItem>
				                    <asp:ListItem Value="9" Text="Settembre" ></asp:ListItem>
				                    <asp:ListItem Value="10" Text="Ottobre" ></asp:ListItem>
				                    <asp:ListItem Value="11" Text="Novembre" ></asp:ListItem>
				                    <asp:ListItem Value="12" Text="Dicembre" ></asp:ListItem>
			                    </asp:DropDownList>
    			        
			                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListMeseRiepilogo"
				                                            runat="server" 
				                                            ErrorMessage="*" 
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

                        <asp:Label ID="lblAvvisi" 
                                   runat="server" 
                                   Text="" 
                                   ForeColor="red">
                        </asp:Label>
    		    
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
		                                          DataSourceID="SqlDataSource_GridView_Consiglieri"
		                                          OnRowDataBound="GridView_Consiglieri_RowDataBound" >
                                
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
		                                    <asp:TemplateField ShowHeader="false">
		                                        <ItemTemplate>
		                                                <asp:LinkButton ID="btn_modify_diaria_cons"
		                                                                runat="server" 
		                                                                Text="Modifica"
                		                                
		                                                                OnClick="btn_modify_diaria_Click" >
		                                                </asp:LinkButton>
		                                        </ItemTemplate>
                		                
		                                        <ItemStyle Width="60px" HorizontalAlign="Center" />
		                                    </asp:TemplateField>
			                                <asp:TemplateField HeaderText="Nome e Cognome" SortExpression="nome_completo">
			                                    <ItemTemplate>
                                                    <% if (role == 7){ %>	           
                                                        <asp:Label ID="lbl_nome" 
			                                                       runat="server" 
			                                                       Text='<%# Eval("nome_completo") %>' ToolTip='<%# Eval("nome_tooltip") %>'>
			                                            </asp:Label>	
                                                    <% } else { %>
			                                            <asp:LinkButton ID="btn_dettAssenze_cons" 
		                                                    runat="server" 
		                                                    Text='<%# Eval("nome_completo") %>' ToolTip='<%# Eval("nome_tooltip") %>'
		                                                    OnClick="dettAssenze_apri_Click">
		                                                </asp:LinkButton>
                                                    <% } %>
			                                    </ItemTemplate>
                			            
			                                    <ItemStyle HorizontalAlign="Left" />
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
                					
			                                <asp:TemplateField HeaderText="Assenza Rimborso Spese Frazione">
			                                    <ItemTemplate>
			                                        <asp:Label ID="lbl_assenza_rimborso_spese_val" 
			                                                   runat="server"
			                                                   Text='<%# Eval("assenze_rimborso") %>'>
			                                        </asp:Label>
			                                    </ItemTemplate>
                			            
			                                    <ItemStyle HorizontalAlign="Center" Width="150px" />
			                                </asp:TemplateField>
			                                <asp:TemplateField HeaderText="Assenza Rimborso Spese Decimale">
			                                    <ItemTemplate>
			                                        <asp:Label ID="lbl_assenza_rimborso_spese_val_dec" 
			                                                   runat="server"
			                                                   Text='<%# Eval("assenze_rimborso") %>'>
			                                        </asp:Label>
			                                    </ItemTemplate>
                			            
			                                    <ItemStyle HorizontalAlign="Center" Width="150px" />
			                                </asp:TemplateField>

			                                <asp:TemplateField Visible="false">
			                                    <ItemTemplate>
			                                        <asp:Label ID="lbl_riepilogo_xml" 
			                                                   runat="server"
			                                                   Text="">
			                                        </asp:Label>
			                                    </ItemTemplate>
                			            
			                                    <ItemStyle HorizontalAlign="Center" Width="150px" />
			                                </asp:TemplateField>

		                                </Columns>
		                            </asp:GridView>
                			
		                            <asp:SqlDataSource ID="SqlDataSource_GridView_Consiglieri" 
		                                               runat="server" 
		                                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
													   SelectCommand="spGetPersoneForRiepilogo"
													   SelectCommandType="StoredProcedure"
											           OnSelecting="SqlDataSource_GridView_ConsiglieriAssessori_Selecting">
										<SelectParameters>
											<asp:SessionParameter Name="idLegislatura" DbType="Int32" SessionField="id_legislatura" />
											<asp:Parameter Name="idTipoCarica" DbType="Int16" DefaultValue="4" />
											<asp:Parameter Name="dataInizio" DbType="Date" />
											<asp:Parameter Name="dataFine" DbType="Date" />
										</SelectParameters>
		                            </asp:SqlDataSource>
    			                </td>
    			        
    			                <td align="center" valign="top" width="50%">
    			                    <asp:GridView ID="GridView_Assessori" 
		                                          runat="server" 
		                                          CssClass="tab_gen" 
		                                          AutoGenerateColumns="False"
		                                          DataKeyNames="id_persona" 
		                                          DataSourceID="SqlDataSource_GridView_Assessori"
		                                           OnRowDataBound="GridView_Assessori_RowDataBound">
                                
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
		                                    <asp:TemplateField ShowHeader="false">
		                                        <ItemTemplate>
		                                            <asp:LinkButton ID="btn_modify_diaria_ass"
		                                                            runat="server" 
		                                                            Text="Modifica"
                		                                
		                                                            OnClick="btn_modify_diaria_Click" >
		                                            </asp:LinkButton>
		                                        </ItemTemplate>
                		                
		                                        <ItemStyle Width="60px" HorizontalAlign="Center" />
		                                    </asp:TemplateField>
                			        
			                                <asp:TemplateField HeaderText="Nome e Cognome" SortExpression="nome_completo">
			                                    <ItemTemplate>
                                                    <% if (role == 7){ %>	           
                                                        <asp:Label ID="lbl_nome" 
			                                                       runat="server" 
			                                                       Text='<%# Eval("nome_completo") %>' ToolTip='<%# Eval("nome_tooltip") %>'>
			                                            </asp:Label>	
                                                    <% } else { %>
			                                            <asp:LinkButton ID="btn_dettAssenze_asse" 
		                                                    runat="server" 
		                                                    Text='<%# Eval("nome_completo") %>' ToolTip='<%# Eval("nome_tooltip") %>'
		                                                    OnClick="dettAssenze_apri_Click">
		                                                </asp:LinkButton>
                                                    <% } %>
			                                    </ItemTemplate>
                			            
			                                    <ItemStyle HorizontalAlign="Left" />
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

			                                <asp:TemplateField HeaderText="Assenza Rimborso Spese Decimale">
			                                    <ItemTemplate>
			                                        <asp:Label ID="lbl_assenza_rimborso_spese_val_dec" 
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
													CancelSelectOnNullParameter="true"
		                                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
													SelectCommand="spGetPersoneForRiepilogo"
													SelectCommandType="StoredProcedure"
											        OnSelecting="SqlDataSource_GridView_ConsiglieriAssessori_Selecting">
										<SelectParameters>
											<asp:SessionParameter Name="idLegislatura" DbType="Int32" SessionField="id_legislatura" />
											<asp:SessionParameter Name="idTipoCarica" DbType="Int16" DefaultValue="3" /> 
											<asp:SessionParameter Name="dataInizio" DbType="Date" />
											<asp:SessionParameter Name="dataFine" DbType="Date" />
										</SelectParameters>
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
                            <tr>
                                <td colspan="2">
                                    <div id="divAllegatiContainer" class="allegatiContainer">
                                        <all:AllegatiList ID="listAllegati" runat="server" />
                                    </div>
                                    <br />
                                </td>
                            </tr>
    			        </table>

                		<asp:Panel ID="PanelDetails" 
		                           runat="server" 
		                           BackColor="White" 
		                           BorderColor="DarkSeaGreen"
		                           BorderWidth="2px" 
		                           Width="500px" 
		                           ScrollBars="Auto" 
		                           Style="padding: 10px; display: none; max-height: 500px;">
		                    <div align="center">
			                <br />
			                <h3>
			                    CORREZIONE ASSENZE <%--DIARIA--%>
			                </h3>
			                <br />
			    

			                <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
			                    <ContentTemplate>
			                        <asp:DetailsView ID="DetailsView_CorrezioneDiaria" 
				                                        runat="server" 
				                                        AutoGenerateRows="False" 
				                                        CssClass="tab_det"
				                                        Width="420px"  
				                                        DataKeyNames="id_persona" 
				                                        DataSourceID="SQLDataSource_DetailsView_CorrezioneDiaria"
				                                        OnItemInserting="DetailsView_CorrezioneDiaria_Inserting"
				                                        OnItemUpdating="DetailsView_CorrezioneDiaria_Updating" >
                            
				                        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="60%" HorizontalAlign="right" />
				                        <RowStyle HorizontalAlign="left" />
				                        <HeaderStyle Font-Bold="False" />
				            
				                        <EmptyDataTemplate>
				                            <table>
				                                <tr>
				                                    <td style="border-color: White;">
				                                        NESSUN DATO DISPONIBILE 
				                                    </td>
				                        
				                                    <td style="border-color: White;">
				                                        <asp:Button ID="btn_New_CorrDiaria" 
	                                                                runat="server"
	                                                                Text="Nuovo" 
	                                                                Width="80px"
	                                                                CommandName="New" />
				                                    </td>
				                                </tr>
				                            </table>
				                        </EmptyDataTemplate>
				            
				                        <Fields>
				                            <asp:TemplateField HeaderText="Correzione Assenza Diaria" >
				                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				                    
				                                <ItemTemplate>
				                                    <asp:Label ID="lbl_corr_ass_diaria" 
				                                                runat="server"
				                                                Text='<%# Eval("corr_ass_diaria") %>' >
				                                    </asp:Label>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_diaria_edit"
				                                                    runat="server"
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_diaria") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_diaria_edit" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_diaria_edit"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Update">
				                                    </asp:RequiredFieldValidator>
				                         
				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_diaria_edit"
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_diaria_edit"
				                                                                    ErrorMessage="Solo numeri interi o mezze giornate"
				                                                                    ValidationExpression="([-]?\d+(\,5)?)"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Update">
				                                    </asp:RegularExpressionValidator>
				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_diaria_insert"
				                                                    runat="server" 
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_diaria") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_diaria_insert" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_diaria_insert"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Insert">
				                                    </asp:RequiredFieldValidator>
				                        
				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_diaria_insert"      
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_diaria_insert"
				                                                                    ErrorMessage="Solo numeri interi o mezze giornate"
				                                                                    ValidationExpression="([-]?\d+(\,5)?)"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Insert">
				                                    </asp:RegularExpressionValidator>
				                                </InsertItemTemplate>
				                            </asp:TemplateField>
	
				                            <asp:TemplateField HeaderText="Correzione Assenza Rimborso Spese">
				                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				                    
				                                <ItemTemplate>
				                                    <asp:Label ID="lbl_corr_ass_rimborso" 
				                                                runat="server"
				                                                Text='<%# Eval("corr_ass_rimb_spese") %>'>
				                                    </asp:Label>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_rimborso_edit"
				                                                    runat="server"
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_rimb_spese") %>'>
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_rimborso_edit" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_rimborso_edit"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Update">
				                                    </asp:RequiredFieldValidator>
				                        
				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_rimborso_edit"
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_rimborso_edit"
				                                                                    ErrorMessage="Solo numeri interi o mezze giornate"
				                                                                    ValidationExpression="([-]?\d+(\,5)?)"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Update">
				                                    </asp:RegularExpressionValidator>
				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_rimborso_insert"
				                                                    runat="server"
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_rimb_spese") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_rimborso_insert" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_rimborso_insert"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Insert">
				                                    </asp:RequiredFieldValidator>
				                        
				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_rimborso_insert"
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_rimborso_insert"
				                                                                    ErrorMessage="Solo numeri interi o mezze giornate"
				                                                                    ValidationExpression="([-]?\d+(\,5)?)"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Insert">
				                                    </asp:RegularExpressionValidator>
				                                </InsertItemTemplate>
				                            </asp:TemplateField>
				                
				                            <asp:TemplateField ShowHeader="false">
				                                <ItemTemplate>
				                                    <asp:Button ID="btn_Edit" 
				                                                runat="server" 
				                                                Text="Modifica"
				                                                Width="80px"
				                                                CommandName="Edit" />
				                                    
				                                    <%--<asp:Button ID="btn_Cancel_Item" 
				                                                runat="server"
				                                                Text="Annulla"
				                                                Width="80px" 
				                                                CommandName="Cancel" 
				                                    
				                                                OnClick="btn_close_details_Click" />--%>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:Button ID="btn_Update_CorrDiaria" 
				                                                runat="server" 
				                                                Width="80px"
				                                                Text="Salva" 
				                                                CausesValidation="true"
				                                                ValidationGroup="ValGroup_Update"
				                                                CommandName="Update" />
				                                    
				                                    <asp:Button ID="btn_Cancel_Edit" 
				                                                runat="server" 
				                                                Text="Annulla"
				                                                Width="80px"
				                                                CommandName="Cancel" />
				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:Button ID="btn_Insert_CorrDiaria" 
				                                                runat="server"
				                                                Text="Salva" 
				                                                Width="80px"
				                                                CausesValidation="true"
				                                                ValidationGroup="ValGroup_Insert"
				                                                CommandName="Insert" />
				                                    
				                                    <asp:Button ID="btn_Cancel_Insert" 
				                                                runat="server" 
				                                                Text="Annulla"
				                                                Width="80px"
				                                                CommandName="Cancel" />
				                                </InsertItemTemplate>
				                    
				                                <ItemStyle HorizontalAlign="Center" />
				                            </asp:TemplateField>
				                        </Fields>
				                    </asp:DetailsView>
			        
				                    <asp:SqlDataSource ID="SQLDataSource_DetailsView_CorrezioneDiaria" 
		                                                runat="server" 
		                                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                                   
		                                                SelectCommand="SELECT id_persona,
                                                                                corr_ass_diaria,
                                                                                corr_ass_rimb_spese
                                                                        FROM correzione_diaria
                                                                        WHERE id_persona = @id_persona
                                                                        AND mese = @mese 
                                                                        AND anno = @anno"
		                                   
		                                                UpdateCommand="UPDATE correzione_diaria
                                                                        SET corr_ass_diaria = @corr_ass_diaria, 
                                                                            corr_ass_rimb_spese = @corr_ass_rimb_spese
                                                                        WHERE id_persona = @id_persona
                                                                        AND mese = @mese
                                                                        AND anno = @anno" 
                                          
                                                        InsertCommand="INSERT INTO correzione_diaria(id_persona, 
                                                                                                    mese, 
                                                                                                    anno, 
                                                                                                    corr_ass_diaria, 
                                                                                                    corr_ass_rimb_spese) 
                                                                        VALUES(@id_persona, 
                                                                                @mese, 
                                                                                @anno, 
                                                                                @corr_ass_diaria, 
                                                                                @corr_ass_rimb_spese)" >
		                    
		                                <SelectParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />		                        
		                                </SelectParameters>
		                    
		                                <UpdateParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />	
		                                    <asp:Parameter Name="corr_ass_diaria" Type="Decimal" />	
		                                    <asp:Parameter Name="corr_ass_rimb_spese" Type="Decimal" />	
		                                </UpdateParameters>
		                    
		                                <InsertParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />	
		                                    <asp:Parameter Name="corr_ass_diaria" Type="Decimal" />	
		                                    <asp:Parameter Name="corr_ass_rimb_spese" Type="Decimal" />
		                                </InsertParameters>
				                    </asp:SqlDataSource>
			                    </ContentTemplate>
			                </asp:UpdatePanel>
	
                        
			                <asp:UpdatePanel ID="UpdatePanelDetailsNoDiaria" runat="server" UpdateMode="Conditional">
			                    <ContentTemplate>
			                        <asp:DetailsView ID="DetailsView_Correzione" 
				                                        runat="server" 
				                                        AutoGenerateRows="False" 
				                                        CssClass="tab_det"
				                                        Width="420px"  
				                                        DataKeyNames="id_persona" 
				                                        DataSourceID="SQLDataSource_DetailsView_Correzione"
				                                        OnItemInserting="DetailsView_Correzione_Inserting"
				                                        OnItemUpdating="DetailsView_Correzione_Updating" >
                            
				                        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="60%" HorizontalAlign="right" />
				                        <RowStyle HorizontalAlign="left" />
				                        <HeaderStyle Font-Bold="False" />
				            
				                        <EmptyDataTemplate>
				                            <table>
				                                <tr>
				                                    <td style="border-color: White;">
				                                        NESSUN DATO DISPONIBILE 
				                                    </td>
				                        
				                                    <td style="border-color: White;">
				                                        <asp:Button ID="btn_New_CorrDiaria" 
	                                                                runat="server"
	                                                                Text="Nuovo" 
	                                                                Width="80px"
	                                                                CommandName="New" />
				                                    </td>
				                                </tr>
				                            </table>
				                        </EmptyDataTemplate>
				            
				                        <Fields>
				                            <asp:TemplateField HeaderText="Correzione Assenza Rimborso Spese" >
				                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				                    
				                                <ItemTemplate>
				                                    <asp:Label ID="lbl_corr_ass_diaria" 
				                                                runat="server"
				                                                Text='<%# Eval("corr_ass_diaria") %>' >
				                                    </asp:Label>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_diaria_edit"
				                                                    runat="server"
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_diaria") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_diaria_edit" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_diaria_edit"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Update">
				                                    </asp:RequiredFieldValidator>
				                         
				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_diaria_edit"
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_diaria_edit"
				                                                                    ErrorMessage="Solo numeri interi o mezze giornate"
				                                                                    ValidationExpression="([-]?\d+(\,5)?)"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Update">
				                                    </asp:RegularExpressionValidator>
				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_diaria_insert"
				                                                    runat="server" 
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_diaria") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_diaria_insert" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_diaria_insert"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Insert">
				                                    </asp:RequiredFieldValidator>
				                        
				                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1"      
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_diaria_insert"
				                                                                    ErrorMessage="Solo numeri interi o mezze giornate"
				                                                                    ValidationExpression="([-]?\d+(\,5)?)"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Insert">
				                                    </asp:RegularExpressionValidator>

 
				                                </InsertItemTemplate>
				                            </asp:TemplateField>
                                			                
				                            <asp:TemplateField ShowHeader="false">
				                                <ItemTemplate>
				                                    <asp:Button ID="btn_Edit" 
				                                                runat="server" 
				                                                Text="Modifica"
				                                                Width="80px"
				                                                CommandName="Edit" />
				                                    
				                                    <%--<asp:Button ID="btn_Cancel_Item" 
				                                                runat="server"
				                                                Text="Annulla"
				                                                Width="80px" 
				                                                CommandName="Cancel" 
				                                    
				                                                OnClick="btn_close_details_Click" />--%>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:Button ID="btn_Update_CorrDiaria" 
				                                                runat="server" 
				                                                Width="80px"
				                                                Text="Salva" 
				                                                CausesValidation="true"
				                                                ValidationGroup="ValGroup_Update"
				                                                CommandName="Update" />
				                                    
				                                    <asp:Button ID="btn_Cancel_Edit" 
				                                                runat="server" 
				                                                Text="Annulla"
				                                                Width="80px"
				                                                CommandName="Cancel" />
				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:Button ID="btn_Insert_CorrDiaria" 
				                                                runat="server"
				                                                Text="Salva" 
				                                                Width="80px"
				                                                CausesValidation="true"
				                                                ValidationGroup="ValGroup_Insert"
				                                                CommandName="Insert" />
				                                    
				                                    <asp:Button ID="btn_Cancel_Insert" 
				                                                runat="server" 
				                                                Text="Annulla"
				                                                Width="80px"
				                                                CommandName="Cancel" />
				                                </InsertItemTemplate>
				                    
				                                <ItemStyle HorizontalAlign="Center" />
				                            </asp:TemplateField>
				                        </Fields>
				                    </asp:DetailsView>
			        
				                    <asp:SqlDataSource ID="SQLDataSource_DetailsView_Correzione" 
		                                                runat="server" 
		                                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                                   
		                                                SelectCommand="SELECT id_persona,
                                                                                corr_ass_diaria
                                                                        FROM correzione_diaria
                                                                        WHERE id_persona = @id_persona
                                                                        AND mese = @mese 
                                                                        AND anno = @anno"
		                                   
		                                                UpdateCommand="UPDATE correzione_diaria
                                                                        SET corr_ass_diaria = @corr_ass_diaria
                                                                        WHERE id_persona = @id_persona
                                                                        AND mese = @mese
                                                                        AND anno = @anno" 
                                          
                                                        InsertCommand="INSERT INTO correzione_diaria(id_persona, 
                                                                                                    mese, 
                                                                                                    anno, 
                                                                                                    corr_ass_diaria) 
                                                                        VALUES(@id_persona, 
                                                                                @mese, 
                                                                                @anno, 
                                                                                @corr_ass_diaria)" >
		                    
		                                <SelectParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />		                        
		                                </SelectParameters>
		                    
		                                <UpdateParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />	
		                                    <asp:Parameter Name="corr_ass_diaria" Type="Decimal" />	
		                                </UpdateParameters>
		                    
		                                <InsertParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />	
		                                    <asp:Parameter Name="corr_ass_diaria" Type="Decimal" />	
		                                </InsertParameters>
				                    </asp:SqlDataSource>
			                    </ContentTemplate>
			                </asp:UpdatePanel>

			                <asp:UpdatePanel ID="UpdatePaneDUP53" runat="server" UpdateMode="Conditional">
			                    <ContentTemplate>

			                        <asp:DetailsView ID="DetailsView_DUP53" 
				                                        runat="server" 
				                                        AutoGenerateRows="False" 
				                                        CssClass="tab_det"
				                                        Width="420px"  
				                                        DataKeyNames="id_persona" 
				                                        DataSourceID="SQLDataSource_DetailsView_DUP53"
				                                        OnItemInserting="DetailsView_DUP53_Inserting"
				                                        OnItemUpdating="DetailsView_DUP53_Updating" >
                            
				                        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="60%" HorizontalAlign="right" />
				                        <RowStyle HorizontalAlign="left" />
				                        <HeaderStyle Font-Bold="False" />
				            
				                        <EmptyDataTemplate>
				                            <table>
				                                <tr>
				                                    <td style="border-color: White;">
				                                        NESSUN DATO DISPONIBILE 
				                                    </td>
				                        
				                                    <td style="border-color: White;">
				                                        <asp:Button ID="btn_New_CorrDiaria" 
	                                                                runat="server"
	                                                                Text="Nuovo" 
	                                                                Width="80px"
	                                                                CommandName="New" />
				                                    </td>
				                                </tr>
				                            </table>
				                        </EmptyDataTemplate>
				            
				                        <Fields>
				                            <asp:TemplateField HeaderText="Correzione Assenza Rimborso Spese" >
				                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
				                    
				                                <ItemTemplate>
				                                    <asp:Label ID="lbl_corr_ass_diaria" 
				                                                runat="server"
				                                                Text='<%# Eval("corr_frazione") != DBNull.Value ? String.Concat(Eval("corr_segno"), Eval("corr_ass_diaria"), " <sup>", Eval("corr_frazione"), "</sup") : Eval("corr_ass_diaria") %> ' >
				                                    </asp:Label>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_diaria_edit"
				                                                    runat="server"
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_diaria") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_diaria_edit" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_diaria_edit"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Update">
				                                    </asp:RequiredFieldValidator>
				                         

				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_diaria_edit"
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_diaria_edit"
				                                                                    ErrorMessage="Solo numeri interi."
				                                                                    ValidationExpression="^\d+$"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Update">
				                                    </asp:RegularExpressionValidator>

                                                    <asp:DropDownList ID="Frazione" runat="server" Width="200px" SelectedValue='<%# Bind("corr_frazione") %>'>
                                                        <asp:ListItem Text="Selezione Frazione" Value=""></asp:ListItem>
                                                        <asp:ListItem Text="1/2" Value="1/2"></asp:ListItem>
                                                        <asp:ListItem Text="1/3" Value="1/3"></asp:ListItem>
                                                        <asp:ListItem Text="1/4" Value="1/4"></asp:ListItem>
                                                        <asp:ListItem Text="1/6" Value="1/6"></asp:ListItem>
                                                        <asp:ListItem Text="2/3" Value="2/3"></asp:ListItem>
                                                        <asp:ListItem Text="3/4" Value="3/4"></asp:ListItem>
                                                        <asp:ListItem Text="5/6" Value="5/6"></asp:ListItem>
                                                    </asp:DropDownList>

                                                    <asp:DropDownList ID="Segno" runat="server" Width="200px" SelectedValue='<%# Bind("corr_segno") %>'>
                                                        <asp:ListItem Text="+" Value="+"></asp:ListItem>
                                                        <asp:ListItem Text="-" Value="-"></asp:ListItem>
                                                    </asp:DropDownList>

				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:TextBox ID="txt_corr_ass_diaria_insert"
				                                                    runat="server" 
				                                                    Width="30px"
				                                                    Text='<%# Bind("corr_ass_diaria") %>' >
				                                    </asp:TextBox>
				                        
				                                    <asp:RequiredFieldValidator ID="RFV_corr_ass_diaria_insert" 
				                                                                runat="server"
				                                                                ControlToValidate="txt_corr_ass_diaria_insert"
				                                                                ErrorMessage="*"
				                                                                Display="Dynamic"
				                                                                ValidationGroup="ValGroup_Insert">
				                                    </asp:RequiredFieldValidator>
				                        
				                                    <asp:RegularExpressionValidator ID="REV_corr_ass_diaria_insert"      
				                                                                    runat="server"
				                                                                    ControlToValidate="txt_corr_ass_diaria_insert"
				                                                                    ErrorMessage="Solo numeri interi."
                                                                                    ValidationExpression="^\d+$"
				                                                                    Display="Dynamic"
				                                                                    ValidationGroup="ValGroup_Insert">
				                                    </asp:RegularExpressionValidator>

                                                    <asp:DropDownList ID="Frazione" runat="server" Width="200px" SelectedValue='<%# Bind("corr_frazione") %>'>
                                                        <asp:ListItem Text="Selezione Frazione" Value=""></asp:ListItem>
                                                        <asp:ListItem Text="1/2" Value="1/2"></asp:ListItem>
                                                        <asp:ListItem Text="1/3" Value="1/3"></asp:ListItem>
                                                        <asp:ListItem Text="1/4" Value="1/4"></asp:ListItem>
                                                        <asp:ListItem Text="1/6" Value="1/6"></asp:ListItem>
                                                        <asp:ListItem Text="2/3" Value="2/3"></asp:ListItem>
                                                        <asp:ListItem Text="3/4" Value="3/4"></asp:ListItem>
                                                        <asp:ListItem Text="5/6" Value="5/6"></asp:ListItem>
                                                    </asp:DropDownList>

                                                    <asp:DropDownList ID="Segno" runat="server" Width="200px" SelectedValue='<%# Bind("corr_segno") %>'>
                                                        <asp:ListItem Text="+" Value="+"></asp:ListItem>
                                                        <asp:ListItem Text="-" Value="-"></asp:ListItem>
                                                    </asp:DropDownList>

				                                </InsertItemTemplate>
				                            </asp:TemplateField>
                                			                
				                            <asp:TemplateField ShowHeader="false">
				                                <ItemTemplate>
				                                    <asp:Button ID="btn_Edit" 
				                                                runat="server" 
				                                                Text="Modifica"
				                                                Width="80px"
				                                                CommandName="Edit" />
				                                    
				                                    <%--<asp:Button ID="btn_Cancel_Item" 
				                                                runat="server"
				                                                Text="Annulla"
				                                                Width="80px" 
				                                                CommandName="Cancel" 
				                                    
				                                                OnClick="btn_close_details_Click" />--%>
				                                </ItemTemplate>
				                    
				                                <EditItemTemplate>
				                                    <asp:Button ID="btn_Update_CorrDiaria" 
				                                                runat="server" 
				                                                Width="80px"
				                                                Text="Salva" 
				                                                CausesValidation="true"
				                                                ValidationGroup="ValGroup_Update"
				                                                CommandName="Update" />
				                                    
				                                    <asp:Button ID="btn_Cancel_Edit" 
				                                                runat="server" 
				                                                Text="Annulla"
				                                                Width="80px"
				                                                CommandName="Cancel" />
				                                </EditItemTemplate>
				                    
				                                <InsertItemTemplate>
				                                    <asp:Button ID="btn_Insert_CorrDiaria" 
				                                                runat="server"
				                                                Text="Salva" 
				                                                Width="80px"
				                                                CausesValidation="true"
				                                                ValidationGroup="ValGroup_Insert"
				                                                CommandName="Insert" />
				                                    
				                                    <asp:Button ID="btn_Cancel_Insert" 
				                                                runat="server" 
				                                                Text="Annulla"
				                                                Width="80px"
				                                                CommandName="Cancel" />
				                                </InsertItemTemplate>
				                    
				                                <ItemStyle HorizontalAlign="Center" />
				                            </asp:TemplateField>
				                        </Fields>
				                    </asp:DetailsView>
			        
				                    <asp:SqlDataSource ID="SQLDataSource_DetailsView_DUP53" 
		                                                runat="server" 
		                                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                                   
		                                                SelectCommand="SELECT id_persona,
                                                                                corr_ass_diaria,
                                                                                corr_frazione,
                                                                                corr_segno 
                                                                        FROM correzione_diaria
                                                                        WHERE id_persona = @id_persona
                                                                        AND mese = @mese 
                                                                        AND anno = @anno"
		                                   
		                                                UpdateCommand="UPDATE correzione_diaria
                                                                        SET corr_ass_diaria = @corr_ass_diaria,
                                                                            corr_frazione = @corr_frazione,
                                                                            corr_segno = @corr_segno
                                                                        WHERE id_persona = @id_persona
                                                                        AND mese = @mese
                                                                        AND anno = @anno" 
                                          
                                                        InsertCommand="INSERT INTO correzione_diaria(id_persona, 
                                                                                                    mese, 
                                                                                                    anno, 
                                                                                                    corr_ass_diaria,
                                                                                                    corr_frazione,
                                                                                                    corr_segno) 
                                                                        VALUES(@id_persona, 
                                                                                @mese, 
                                                                                @anno, 
                                                                                @corr_ass_diaria,
                                                                                @corr_frazione,
                                                                                @corr_segno)" >
		                    
		                                <SelectParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />		                        
		                                </SelectParameters>
		                    
		                                <UpdateParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />	
		                                    <asp:Parameter Name="corr_ass_diaria" Type="Decimal" />	
		                                </UpdateParameters>
		                    
		                                <InsertParameters>
		                                    <asp:Parameter Name="id_persona" Type="Int32" />
		                                    <asp:Parameter Name="mese" Type="Int32" />
		                                    <asp:Parameter Name="anno" Type="Int32" />	
		                                    <asp:Parameter Name="corr_ass_diaria" Type="Decimal" />	
		                                </InsertParameters>
				                    </asp:SqlDataSource>
			                    </ContentTemplate>
			                </asp:UpdatePanel>
               		                <%--  --%>
			                <table width="100%">
		                        <tr>
		                            <td align="center">
		                                <asp:LinkButton ID="btn_close_details" 
		                                                runat="server"
		                                                Text="Chiudi" 
		                                    
		                                                OnClick="btn_close_details_Click">
		                                </asp:LinkButton>
		                            </td>
		                        </tr>
		                    </table>
			        
    		                </div>
		        
		                    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" 
		                                            BehaviorID="ModalPopup1" 
		                                            runat="server"
			                                        PopupControlID="PanelDetails" 
			                                        BackgroundCssClass="modalBackground" 
			                                        DropShadow="true"
			                                        TargetControlID="ButtonDetailsFake" >
			                </cc1:ModalPopupExtender>
			    
			    
			    
		                    <asp:Button ID="ButtonDetailsFake" runat="server" Text="" Style="display: none;" />
		       
		                </asp:Panel>
		    

                        <asp:Panel ID="PanelDettaglioAssenze"
		    		               runat="server" 
		                           BackColor="White" 
		                           BorderColor="DarkSeaGreen"
		                           BorderWidth="2px" 
		                           Width="1210px" 
		                           ScrollBars="Auto" 
		                           Style="padding: 10px; display: none; max-height: 500px;">
		                    <div align="center"> 
                                <div style="text-align:right;">
                                    <asp:LinkButton ID="LinkButton2" 
		                                            runat="server"
		                                            Text="Chiudi"                                
		                                            OnClick="dettAssenze_chiudi_Click">
		                            </asp:LinkButton>
                                </div>                
                    
		                        <da:DettaglioAssenze ID="dettaglioAssenze" runat="server" />

                                <div style="text-align:center;">
                                    <asp:LinkButton ID="LinkButton1" 
		                                            runat="server"
		                                            Text="Chiudi"                                
		                                            OnClick="dettAssenze_chiudi_Click">
		                            </asp:LinkButton>
                                </div>  
			        
    		                </div>
		        
		                    <cc1:ModalPopupExtender ID="ModalPopupExtenderAssenze" 
		                                            BehaviorID="ModalPopup2" 
		                                            runat="server"
			                                        PopupControlID="PanelDettaglioAssenze" 
			                                        BackgroundCssClass="modalBackground" 
			                                        DropShadow="true"
			                                        TargetControlID="ButtonAssenzeFake" >
			                </cc1:ModalPopupExtender>	    
			    
		                    <asp:Button ID="ButtonAssenzeFake" runat="server" Text="" Style="display: none;" />
		                </asp:Panel>

                    </ContentTemplate>
                    <Triggers>
		                <asp:PostBackTrigger ControlID="lnkbtn_Export_Excel1" />
		                <asp:PostBackTrigger ControlID="lnkbtn_Export_PDF1" />
		                <asp:PostBackTrigger ControlID="lnkbtn_Export_Excel2" />
		                <asp:PostBackTrigger ControlID="lnkbtn_Export_PDF2" />
                    </Triggers>
                </asp:UpdatePanel>
    			
                <% if (role != 7) { %>
    			<div align="center">
		            <asp:Button ID="ButtonInvia" 
		                        runat="server" 
		                        Text="Invia i fogli presenze di questo mese" 
			                    onclick="ButtonInvia_Click" 
    			                
			                    OnClientClick="return confirm ('Confermare tutti i fogli presenza del mese selezionato?\nNon sarà più possibile effettuare ulteriori modifiche al foglio presenze.');" />
		        </div>
                <% } %>
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