﻿<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="pratiche_assessori.aspx.cs" 
         Inherits="pratiche_assessori" 
         Title="Assessori > Pratiche" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<%@ Register Src="~/TabsPersona.ascx" TagPrefix="tab" TagName="TabsPersona" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" 
       align="center" 
       cellpadding="0" 
       cellspacing="0" >
<tr>
    <td>
	&nbsp;
    </td>
</tr>

<tr>
    <td>
	<asp:DataList ID="DataList1" 
	              runat="server" 
	              DataSourceID="SqlDataSourceHead" 
	              Width="50%" >
	              
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
			        <span style="font-size: 1.5em; font-weight: bold; color: #50B306;" >
			            <asp:Label ID="LabelHeadNome" 
			                       runat="server" 
			                       Text='<%# Eval("nome") + " " + Eval("cognome") %>' />
			        </span>
			        <br />
			        <asp:Label ID="LabelHeadDataNascita" 
			                   runat="server" 
			                   Text='<%# Eval("data_nascita", "{0:dd/MM/yyyy}") %>' /> 			        
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
	                                         pp.data_nascita
			                          FROM persona AS pp 			                          
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
            <tab:TabsPersona runat="server" ID="tabsPersona" />
        </div>
	
	<div id="tab_content">
	    <div id="tab_content_content">
		<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		    <ContentTemplate>
			<table>
			<tr>
				<td valign="top" width="230">
				    Seleziona legislatura:
				    <asp:DropDownList ID="DropDownListLegislatura" 
				                      runat="server" 
				                      DataSourceID="SqlDataSourceLegislature"
					                  DataTextField="num_legislatura" 
					                  DataValueField="id_legislatura" 
					                  Width="70px"
					                  AppendDataBoundItems="True" >
					    <asp:ListItem Text="(tutte)" Value="" />
				    </asp:DropDownList>
				    
				    <asp:SqlDataSource ID="SqlDataSourceLegislature" 
				                       runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
					                 
					                   SelectCommand="SELECT id_legislatura, 
					                                         num_legislatura
					                                  FROM legislature" >
				    </asp:SqlDataSource>
				</td>
				
				<td valign="top" width="230">
				    Seleziona data:
				    <asp:TextBox ID="TextBoxFiltroData" 
				                 runat="server" 
				                 Width="70px" >
				    </asp:TextBox>
				    <img alt="calendar" 
				         src="../img/calendar_month.png" 
				         id="ImageFiltroData" 
				         runat="server" />
				    <cc1:CalendarExtender ID="CalendarExtender2" 
				                          runat="server" 
				                          TargetControlID="TextBoxFiltroData"
					                      PopupButtonID="ImageFiltroData" 
					                      Format="dd/MM/yyyy" >
				    </cc1:CalendarExtender>
				    
				    <asp:ScriptManager ID="ScriptManager2" 
				                       runat="server" 
				                       EnableScriptGlobalization="True" >
				    </asp:ScriptManager>
				    			    
				    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
				                                    ControlToValidate="TextBoxFiltroData"
					                                runat="server" 
					                                ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                                Display="Dynamic"
					                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                                ValidationGroup="FiltroData" />
				</td>
				
				<td valign="top">
				    <asp:Button ID="ButtonFiltri" 
				                runat="server" 
				                Text="Applica" 
				                OnClick="ButtonFiltri_Click"
					            ValidationGroup="FiltroData" />
				</td>
			</tr>
			</table>
			
			<br />
			<br />
			
			<asp:GridView ID="GridView1" 
			              runat="server" 
			              AllowPaging="True" 
			              PagerStyle-HorizontalAlign="Center" 
			              AllowSorting="True"
			              AutoGenerateColumns="False" 
			              CellPadding="5" 
			              CssClass="tab_gen" 
			              DataSourceID="SqlDataSource1"
			              GridLines="None" 
			              DataKeyNames="id_rec" >
			              
			    <EmptyDataTemplate>
				    <table width="100%" class="tab_gen">
			        <tr>
				        <th align="center">
				            Nessun record trovato.
				        </th>
				        <th width="100">
				            <% if (role <= 2) { %>
				            <asp:Button ID="Button1" 
				                        runat="server" 
				                        Text="Nuovo..." 
				                        OnClick="Button1_Click" 
				                        CssClass="button"
					                    CausesValidation="false" />
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
				    <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
				</asp:TemplateField>
				
				<asp:BoundField DataField="numero_pratica" 
				                HeaderText="Numero Pratica" 
				                SortExpression="numero_pratica"
				                ItemStyle-HorizontalAlign="center"  
				                ItemStyle-Width="100px" />
				
				<asp:BoundField DataField="data" 
				                HeaderText="Data Pratica" 
				                SortExpression="data"
				                DataFormatString="{0:dd/MM/yyyy}" 
				                ItemStyle-HorizontalAlign="center" 
				                ItemStyle-Width="80px" />
				
				<asp:BoundField DataField="oggetto" 
				                HeaderText="Oggetto" 
				                SortExpression="oggetto" />
				
				<asp:TemplateField>
				    <ItemTemplate>
					    <asp:LinkButton ID="LinkButtonDettagli" 
					                    runat="server" 
					                    CausesValidation="False" 
					                    Text="Dettagli"
					                    OnClick="LinkButtonDettagli_Click">
					    </asp:LinkButton>
				    </ItemTemplate>
				    
				    <HeaderTemplate>
					    <% if (role <= 2) { %>
					    <asp:Button ID="Button1" 
					                runat="server" 
					                Text="Nuovo..." 
					                OnClick="Button1_Click" 
					                CssClass="button"
					                CausesValidation="false" />
					    <% } %>
				    </HeaderTemplate>
				    
				    <ItemStyle HorizontalAlign="Center" 
				               VerticalAlign="Middle" 
				               Width="100px" />
				</asp:TemplateField>
			    </Columns>
			</asp:GridView>
			
			<asp:SqlDataSource ID="SqlDataSource1" 
			                   runat="server" 
			                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                   
			                   SelectCommand="SELECT ll.id_legislatura, 
			                                         ll.num_legislatura, 
			                                         jj.* 
					                          FROM join_persona_pratiche AS jj 
					                          INNER JOIN legislature AS ll 
					                            ON jj.id_legislatura = ll.id_legislatura
					                          WHERE jj.deleted = 0 
					                            AND jj.id_persona = @id" >
					                            
			    <SelectParameters>
				<asp:SessionParameter Name="id" SessionField="id_persona" />
			    </SelectParameters>
			</asp:SqlDataSource>
		    </ContentTemplate>
		</asp:UpdatePanel>
		
		<br />
		
		<div align="right">
		    <asp:LinkButton ID="LinkButtonExcel" 
		                    runat="server" 
		                    OnClick="LinkButtonExcel_Click">
		        <img src="../img/page_white_excel.png" 
		             alt="" 
		             align="top" /> 
		        Esporta
		    </asp:LinkButton>
		    -
		    <asp:LinkButton ID="LinkButtonPdf" 
		                    runat="server" 
		                    OnClick="LinkButtonPdf_Click">
		        <img src="../img/page_white_acrobat.png" 
		             alt="" 
		             align="top" /> 
		        Esporta
		    </asp:LinkButton>
		</div>
		
		<asp:Panel ID="PanelDetails" runat="server" BackColor="White" BorderColor="DarkSeaGreen"
		    BorderWidth="2px" Width="500" ScrollBars="Vertical" Style="padding: 10px; display: none; max-height: 500px;">
		    <div align="center">
			<br />
			<h3>
			    PRATICHE
			</h3>
			<br />
		    <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
			<ContentTemplate>
			    <asp:DetailsView ID="DetailsView1" 
			                     runat="server" 
			                     AutoGenerateRows="False" 
			                     CssClass="tab_det" 
			                     Width="420px"
				                 DataSourceID="SqlDataSource2" 
				                 OnModeChanged="DetailsView1_ModeChanged" 
				                 OnItemInserted="DetailsView1_ItemInserted" 
				                 OnItemInserting="DetailsView1_ItemInserting"
				                 OnItemUpdated="DetailsView1_ItemUpdated" 
				                 OnItemUpdating="DetailsView1_ItemUpdating"
				                 OnItemDeleted="DetailsView1_ItemDeleted" 
				                 DataKeyNames="id_rec">
				
				    <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
				    <RowStyle HorizontalAlign="left" />
				    <HeaderStyle Font-Bold="False" />
    				
				    <Fields>
				        <asp:TemplateField HeaderText="Legislatura">
					        <ItemTemplate>
					            <asp:Label ID="LabelLeg" 
					                       runat="server" 
					                       Text='<%# Bind("num_legislatura") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:DropDownList ID="DropDownListLeg" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceLeg"
						                          SelectedValue='<%# Eval("id_legislatura") %>' 
						                          DataTextField="num_legislatura"
						                          DataValueField="id_legislatura" 
						                          Width="200px" 
						                          AppendDataBoundItems="True">
						                          
						            <asp:ListItem Value="" Text="(seleziona)" />
					            </asp:DropDownList>
					            
					            <asp:SqlDataSource ID="SqlDataSourceLeg" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                           
						                           SelectCommand="SELECT id_legislatura, 
						                                                 num_legislatura 
						                                          FROM legislature" >
					            </asp:SqlDataSource>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" 
					                                        ControlToValidate="DropDownListLeg"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:DropDownList ID="DropDownListLeg" 
					                              runat="server" 
					                              DataSourceID="SqlDataSourceLeg"
						                          SelectedValue='<%# Eval("id_legislatura") %>' 
						                          DataTextField="num_legislatura"
						                          DataValueField="id_legislatura" 
						                          Width="200px" 
						                          AppendDataBoundItems="True" >
						            <asp:ListItem Value="" Text="(seleziona)" />
					            </asp:DropDownList>
					            
					            <asp:SqlDataSource ID="SqlDataSourceLeg" 
					                               runat="server" 
					                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
						                       
						                           SelectCommand="SELECT id_legislatura, 
						                                                 num_legislatura 
						                                          FROM legislature" >
					            </asp:SqlDataSource>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorLeg" 
					                                        ControlToValidate="DropDownListLeg"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />					            
					        </EditItemTemplate>
				        </asp:TemplateField>
    				    
    				    <asp:TemplateField HeaderText="Numero Pratica" 
    				                       SortExpression="oggetto">
					        <ItemTemplate>
					            <asp:Label ID="lblNum_Pratica" 
					                       runat="server" 
					                       Text='<%# Bind("numero_pratica") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:TextBox ID="txtNumPratica_Edit" 
					                         runat="server" 
					                         Text='<%# Bind("numero_pratica") %>' 
					                         MaxLength='50'>
					            </asp:TextBox>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorNumPratica_Edit" 
					                                        ControlToValidate="txtNumPratica_Edit"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox ID="txtNumPratica_Insert" 
					                         runat="server" 
					                         Text='<%# Bind("numero_pratica") %>' 
					                         MaxLength='50' >
					            </asp:TextBox>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorNumPratica_Insert" 
					                                        ControlToValidate="txtNumPratica_Insert"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
				        <asp:TemplateField HeaderText="Data Pratica" SortExpression="data">
					        <ItemTemplate>
					            <asp:Label ID="LabelDataPratica" 
					                       runat="server" 
					                       Text='<%# Eval("data", "{0:dd/MM/yyyy}") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:TextBox ID="dt_pratica_mod" runat="server" 
					            Text='<%# Eval("data", "{0:dd/MM/yyyy}") %>'></asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dt_pratica_mod"
						        PopupButtonID="Image1" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataPratica" ControlToValidate="dt_pratica_mod"
						        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_pratica_mod" ControlToValidate="dt_pratica_mod"
						        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="FiltroData" />
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox ID="dt_pratica_ins" runat="server" ></asp:TextBox>
					            <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
					            <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dt_pratica_ins"
						        PopupButtonID="Image1" Format="dd/MM/yyyy">
					            </cc1:CalendarExtender>
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataPratica" ControlToValidate="dt_pratica_ins"
						        runat="server" Display="Dynamic" ErrorMessage="Campo obbligatorio." ValidationGroup="ValidGroup" />
					            <asp:RegularExpressionValidator ID="RequiredFieldValidatordt_pratica_ins" ControlToValidate="dt_pratica_ins"
						        runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
						        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
						        ValidationGroup="FiltroData" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
				        <asp:TemplateField HeaderText="Oggetto" SortExpression="oggetto">
					        <ItemTemplate>
					            <asp:Label ID="LabelOggetto" 
					            runat="server" 
					            Text='<%# Bind("oggetto") %>'>
					            </asp:Label>
					        </ItemTemplate>
        					
					        <EditItemTemplate>
					            <asp:TextBox ID="TextBoxOggetto" 
					                         runat="server" 
					                         Text='<%# Bind("oggetto") %>' 
					                         MaxLength='50'>
					            </asp:TextBox>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorOggetto" 
					                                        ControlToValidate="TextBoxOggetto"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox ID="TextBoxOggetto" 
					                         runat="server" 
					                         Text='<%# Bind("oggetto") %>' 
					                         MaxLength='50'>
					            </asp:TextBox>
					            
					            <asp:RequiredFieldValidator ID="RequiredFieldValidatorOggetto" 
					                                        ControlToValidate="TextBoxOggetto"
						                                    runat="server" 
						                                    Display="Dynamic" 
						                                    ErrorMessage="Campo obbligatorio." 
						                                    ValidationGroup="ValidGroup" />
					        </InsertItemTemplate>
				        </asp:TemplateField>
    				    
				        <asp:TemplateField HeaderText="Note" SortExpression="note">
					        <EditItemTemplate>
					            <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
						        Text='<%# Bind("note") %>'></asp:TextBox>
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:TextBox TextMode="MultiLine" Rows="3" Columns="22" ID="TextBox1" runat="server"
						        Text='<%# Bind("note") %>'></asp:TextBox>
					        </InsertItemTemplate>
        					
					        <ItemTemplate>
					            <asp:Label ID="LabelVarie" runat="server" Text='<%# Bind("note") %>'></asp:Label>
					        </ItemTemplate>
				        </asp:TemplateField>
    				    
				        <asp:TemplateField ShowHeader="False">
					        <EditItemTemplate>
					            <asp:Button ID="Button1" runat="server" CausesValidation="True" CommandName="Update"
						        Text="Aggiorna" ValidationGroup="ValidGroup" />
					            <asp:Button ID="Button2" runat="server" CausesValidation="False" CommandName="Cancel"
						        Text="Annulla" />
					        </EditItemTemplate>
        					
					        <InsertItemTemplate>
					            <asp:Button ID="Button1" runat="server" CausesValidation="True" CommandName="Insert"
						        Text="Inserisci" ValidationGroup="ValidGroup" />
					            <asp:Button ID="Button4" runat="server" CausesValidation="False" Text="Chiudi" CssClass="button"
						        OnClick="ButtonAnnulla_Click" CommandName="Cancel" />
					        </InsertItemTemplate>
        					
					        <ItemTemplate>
					            <asp:Button ID="Button1" runat="server" CausesValidation="False" CommandName="Edit"
						        Text="Modifica" Visible="<%# (role <= 2) ? true : false %>" />
					            <asp:Button ID="Button3" runat="server" CausesValidation="False" CommandName="Delete"
						        Text="Elimina" Visible="<%# (role <= 2) ? true : false %>" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
					            <asp:Button ID="Button4" runat="server" CausesValidation="False" Text="Chiudi" CssClass="button"
						        OnClick="ButtonAnnulla_Click" CommandName="Cancel" />
					        </ItemTemplate>
					    <ControlStyle CssClass="button" />
				        </asp:TemplateField>
				    </Fields>
			    </asp:DetailsView>
			    
			    <asp:SqlDataSource ID="SqlDataSource2" 
			                       runat="server" 
			                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                   
				                   DeleteCommand="UPDATE join_persona_pratiche 
				                                  SET deleted = 1 
				                                  WHERE id_rec = @id_rec"
				                   
				                   InsertCommand="INSERT INTO join_persona_pratiche (id_legislatura, 
				                                                                     id_persona,
				                                                                     numero_pratica, 
				                                                                     data, 
				                                                                     oggetto, 
				                                                                     note) 
				                                  VALUES (@id_legislatura, 
				                                          @id_persona, 
				                                          @numero_pratica, 
				                                          @data, 
				                                          @oggetto, 
				                                          @note); 
				                                  SELECT @id_rec = SCOPE_IDENTITY();"
				                   
				                   SelectCommand="SELECT * 
				                                  FROM join_persona_pratiche AS jj 
				                                  INNER JOIN legislature AS ll 
				                                    ON jj.id_legislatura = ll.id_legislatura
				                                  WHERE id_rec = @id_rec" 
				                   
				                   UpdateCommand="UPDATE join_persona_pratiche 
				                                  SET id_legislatura = @id_legislatura, 
				                                      id_persona = @id_persona, 
				                                      numero_pratica = @numero_pratica, 
				                                      data = @data, 
				                                      oggetto = @oggetto, 
				                                      note = @note 
				                                  WHERE id_rec = @id_rec"
				                   
				                   OnInserted="SqlDataSource2_Inserted" >
				                   
				<SelectParameters>
				    <asp:ControlParameter ControlID="GridView1" 
				    Name="id_rec" 
				    PropertyName="SelectedValue"
					Type="Int32" />
				</SelectParameters>
				
				<DeleteParameters>
				    <asp:Parameter Name="id_rec" Type="Int32" />
				</DeleteParameters>
				
				<UpdateParameters>
				    <asp:Parameter Name="id_legislatura" Type="Int32" />
				    <asp:Parameter Name="id_persona" Type="Int32" />
				    <asp:Parameter Name="numero_pratica" Type="String" />
				    <asp:Parameter Name="data" Type="DateTime" />
				    <asp:Parameter Name="oggetto" Type="String" />
				    <asp:Parameter Name="note" Type="String" />
				    <asp:Parameter Name="id_rec" Type="Int32" />
				</UpdateParameters>
				
				<InsertParameters>
				    <asp:Parameter Name="id_legislatura" Type="Int32" />
				    <asp:Parameter Name="id_persona" Type="Int32" />
				    <asp:Parameter Name="numero_pratica" Type="String" />
				    <asp:Parameter Name="data" Type="DateTime" />
				    <asp:Parameter Name="oggetto" Type="String" />
				    <asp:Parameter Name="note" Type="String" />
				    <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
				</InsertParameters>
			    </asp:SqlDataSource>
			</ContentTemplate>
		    </asp:UpdatePanel>
		    </div>
		    
		    <br />
		    
		    <asp:UpdatePanel ID="UpdatePanelEsporta" 
		                     runat="server" 
		                     UpdateMode="Conditional" >
			<ContentTemplate>
			    <div align="right">
				<asp:LinkButton ID="LinkButtonExcelDetails" 
				                runat="server" 
				                OnClick="LinkButtonExcelDetails_Click">
				    Esporta 
				    <img src="../img/page_white_excel.png" 
				         alt="" 
				         align="top" />
				    <br />
				</asp:LinkButton>
				
				<asp:LinkButton ID="LinkButtonPdfDetails" 
				                runat="server" 
				                OnClick="LinkButtonPdfDetails_Click">
				    Esporta 
				    <img src="../img/page_white_acrobat.png" 
			             alt="" 
			             align="top" />
				</asp:LinkButton>
			    </div>
			</ContentTemplate>
			
			<Triggers>
			    <asp:PostBackTrigger ControlID="LinkButtonExcelDetails" />
			    <asp:PostBackTrigger ControlID="LinkButtonPdfDetails" />
			</Triggers>
			
		    </asp:UpdatePanel>
		    
		    <cc1:ModalPopupExtender ID="ModalPopupExtenderDetails" 
		                            BehaviorID="ModalPopup1" 
		                            runat="server" 
		                            PopupControlID="PanelDetails"
			                        BackgroundCssClass="modalBackground" 
			                        DropShadow="true" 
			                        TargetControlID="ButtonDetailsFake" />
			                        
		    <asp:Button ID="ButtonDetailsFake" 
		                runat="server" 
		                Text="" Style="display: none;" />
		</asp:Panel>
	    </div>
	</div>
	<%--Fix per lo stile dei calendarietti--%>
	<asp:TextBox ID="TextBoxCalendarFake" runat="server" style="display: none;"></asp:TextBox>
	<cc1:CalendarExtender ID="CalendarExtenderFake" runat="server" TargetControlID="TextBoxCalendarFake" Format="dd/MM/yyyy"></cc1:CalendarExtender>
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
	          href="../persona/persona_assessori.aspx">
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