<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         MasterPageFile="~/MasterPage.master"
         CodeFile="dettaglio.aspx.cs" 
         Inherits="legislature_dettaglio" 
         Title="Legislatura > Anagrafica" %>

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
	<b>LEGISLATURA &gt; ANAGRAFICA</b>
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
		        <li id="selected"><a id="leg_anagrafica" runat="server">ANAGRAFICA</a></li>
		        <li><a id="leg_gruppi_politici" runat="server">GRUPPI POLITICI</a></li>
		        <li><a id="leg_componenti" runat="server">PERSONE</a></li>
	        </ul>
	    </div>
    	
	    <div id="tab_content">
	        <div id="tab_content_content">

				<asp:Panel ID="PanelChiusura" 
                    runat="server" 
                    Width="1000px" 
                    BackColor="White" 
                    BorderColor="DarkSeaGreen"
                    BorderWidth="2px"
					Visible="true"
					Style="position: absolute; left: 0; right: 0; margin-left: auto; margin-right: auto;">

                    <div align="center">
                        <br />
                                    
                        <h3>CHIUSURA</h3>
                        <br />


                        <p>Seleziona la data della chiusura</p>
                            <asp:DropDownList runat="server" ID="chiusuraGiorni">

                        </asp:DropDownList>

                        <asp:DropDownList runat="server" ID="chiusuraMesi">
                            <asp:ListItem Text="Seleziona un mese" Value="0" />
                            <asp:ListItem Text="Gennaio" Value="01" />
                            <asp:ListItem Text="Febbraio" Value="02" />
                            <asp:ListItem Text="Marzo" Value="03" />
                            <asp:ListItem Text="Aprile" Value="04" />
                            <asp:ListItem Text="Maggio" Value="05" />
                            <asp:ListItem Text="Giugno" Value="06" />
                            <asp:ListItem Text="Luglio" Value="07" />
                            <asp:ListItem Text="Agosto" Value="08" />
                            <asp:ListItem Text="Settembre" Value="09" />
                            <asp:ListItem Text="Ottobre" Value="10" />
                            <asp:ListItem Text="Novembre" Value="11" />
                            <asp:ListItem Text="Dicembre" Value="12" />
                        </asp:DropDownList>

                        <asp:DropDownList runat="server" ID="chiusuraAnni">

                        </asp:DropDownList>

                            <br />
                        <br />
                        <asp:Label ID="labelChiusuraError" 
                                                       runat="server"  
                                                       ForeColor="Red"
                            Text="Prima di proseguire è necessario compilare tutti i campi"
                                                       Visible="false">
                                            </asp:Label>
                        <br />
                            <br />

                            <asp:Button ID="Button3" 
                                        runat="server" 
                                        CausesValidation="False" 
                                        Text="Conferma" 
                                        OnClientClick="return confirm ('Confermare la chiusura?');"
                                        OnClick="ButtonConfirmChiusura_Click"/>
                                    
                        <br />
                    </div>

                    <div align="center">
                        <br />
                        <asp:Button ID="ButtonChiudiChiusura" OnClick="ButtonCloseChiusura_Click" runat="server" Text="Chiudi" CssClass="button" />
                        <br />
                        <br />
                    </div>
                                
                </asp:Panel>

		    <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		        <ContentTemplate>
			    <table width="100%" cellspacing="5" cellpadding="10">
			        <tr>
				    <td class="singleborder" valign="top">
				        <asp:DetailsView ID="DetailsView1" 
			                             runat="server" 
			                             Height="50px" 
			                             Width="100%" 
			                             AutoGenerateRows="False"
				                         DataKeyNames="id_legislatura" 
				                         DataSourceID="SqlDataSource1" 
				                         CellPadding="5" 
				                         GridLines="None"
                						
            						     OnItemInserting="DetailsView1_ItemInserting" 
				                         OnItemUpdating="DetailsView1_ItemUpdating"
				                         OnItemDeleted="DetailsView1_ItemDeleted" >
    					
					    <Fields>
					        <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
						        <ItemTemplate>
						            <asp:Label ID="LabelLegislatura" 
						                       runat="server" 
						                       Text='<%# Bind("num_legislatura") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxLegislatura" 
						                         runat="server" 
						                         Text='<%# Bind("num_legislatura") %>'>
						            </asp:TextBox>
    						        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorLegislatura" 
						                                        ControlToValidate="TextBoxLegislatura"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </EditItemTemplate>
    							
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxLegislatura" 
						                         runat="server" 
						                         Text='<%# Bind("num_legislatura") %>'>
						            </asp:TextBox>
    						        
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorLegislatura" 
						                                        ControlToValidate="TextBoxLegislatura"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
    					    
					        <asp:TemplateField HeaderText="Data Inizio" SortExpression="durata_legislatura_da">
						        <ItemTemplate>
						            <asp:Label ID="LabelDataInizio" 
						                       runat="server" 
						                       Text='<%# Bind("durata_legislatura_da", "{0:dd/MM/yyyy}") %>'>
						            </asp:Label>
						        </ItemTemplate>
    							
						        <EditItemTemplate>
						            <asp:TextBox ID="TextBoxDataInizioEdit" 
						                         runat="server" 
						                         Text='<%# Bind("durata_legislatura_da", "{0:dd/MM/yyyy}") %>'>
						            </asp:TextBox>
    							    
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioEdit" runat="server" />
    							    
						            <cc1:CalendarExtender ID="CalendarExtenderDataInizioEdit" 
						                                  runat="server" 
						                                  TargetControlID="TextBoxDataInizioEdit"
							                              PopupButtonID="ImageDataInizioEdit" 
							                              Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
    							    
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" 
						                                        ControlToValidate="TextBoxDataInizioEdit"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
    							    
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizioEdit" 
						                                            ControlToValidate="TextBoxDataInizioEdit"
							                                        runat="server" 
							                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                        Display="Dynamic"
							                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                        ValidationGroup="FiltroData" >
							        </asp:RegularExpressionValidator>
						        </EditItemTemplate>
    							
						        <InsertItemTemplate>
						            <asp:TextBox ID="TextBoxDataInizioInsert" 
						                         runat="server" 
						                         Text='<%# Bind("durata_legislatura_da", "{0:dd/MM/yyyy}") %>'>
						            </asp:TextBox>
    						        
						            <img alt="calendar" src="../img/calendar_month.png" id="ImageDataInizioInsert" runat="server" />
    						        
						            <cc1:CalendarExtender ID="CalendarExtenderDataInizioInsert" 
						                                  runat="server" 
						                                  TargetControlID="TextBoxDataInizioInsert"
							                              PopupButtonID="ImageDataInizioInsert" 
							                              Format="dd/MM/yyyy">
						            </cc1:CalendarExtender>
    							    
						            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDataInizio" 
						                                        ControlToValidate="TextBoxDataInizioInsert"
							                                    runat="server" 
							                                    Display="Dynamic" 
							                                    ErrorMessage="Campo obbligatorio." 
							                                    ValidationGroup="ValidGroup" >
							        </asp:RequiredFieldValidator>
    							    
						            <asp:RegularExpressionValidator ID="RequiredFieldValidatorDataInizioInsert" 
						                                            ControlToValidate="TextBoxDataInizioInsert"
							                                        runat="server" 
							                                        ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                        Display="Dynamic"
							                                        ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                        ValidationGroup="FiltroData" >
							        </asp:RegularExpressionValidator>
						        </InsertItemTemplate>
					        </asp:TemplateField>
    					    
					        <asp:TemplateField HeaderText="Data Fine" SortExpression="durata_legislatura_a">
						    <ItemTemplate>
						        <asp:Label ID="LabelDataFine" 
						                   runat="server" 
						                   Text='<%# Bind("durata_legislatura_a", "{0:dd/MM/yyyy}") %>'>
						        </asp:Label>
						    </ItemTemplate>
    						
						    <EditItemTemplate>
						        <asp:TextBox ID="TextBoxDataFineEdit" 
						                     runat="server" 
						                     Text='<%# Bind("durata_legislatura_a", "{0:dd/MM/yyyy}") %>'>
						        </asp:TextBox>
						        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineEdit" runat="server" />
						        <cc1:CalendarExtender ID="CalendarExtenderDataFineEdit" 
						                              runat="server" 
						                              TargetControlID="TextBoxDataFineEdit"
							                          PopupButtonID="ImageDataFineEdit" 
							                          Format="dd/MM/yyyy">
						        </cc1:CalendarExtender>
    						    
						        <asp:RegularExpressionValidator ID="RequiredFieldValidatorTextBoxDataFineEdit" 
						                                        ControlToValidate="TextBoxDataFineEdit"
							                                    runat="server" 
							                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
							                                    Display="Dynamic"
							                                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                    ValidationGroup="FiltroData" >
							    </asp:RegularExpressionValidator>
						    </EditItemTemplate>
    						
						    <InsertItemTemplate>
						        <asp:TextBox ID="TextBoxDataFineInsert" 
						                     runat="server" 
						                     Text='<%# Bind("durata_legislatura_a", "{0:dd/MM/yyyy}") %>' >
						        </asp:TextBox>
    						    
						        <img alt="calendar" src="../img/calendar_month.png" id="ImageDataFineInsert" runat="server" />
    						    
						        <cc1:CalendarExtender ID="CalendarExtenderDataFineInsert" 
						                              runat="server" 
						                              TargetControlID="TextBoxDataFineInsert"
							                          PopupButtonID="ImageDataFineInsert" 
							                          Format="dd/MM/yyyy">
						        </cc1:CalendarExtender>
    						    
						        <asp:RegularExpressionValidator ID="RequiredFieldValidatorTextBoxDataFineInsert"
							                                    ControlToValidate="TextBoxDataFineInsert" 
							                                    runat="server" 
							                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA."
							                                    Display="Dynamic" 
							                                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
							                                    ValidationGroup="FiltroData" >
							    </asp:RegularExpressionValidator>
						    </InsertItemTemplate>
					        </asp:TemplateField>
    					    
					        <%--<asp:TemplateField HeaderText="Attiva?">
					            <ItemTemplate>
					                <asp:CheckBox />
					            </ItemTemplate>
    					        
					            <InsertItemTemplate>
					            </InsertItemTemplate>
    					        
					            <EditItemTemplate>
					            </EditItemTemplate>
					        </asp:TemplateField>--%>
    					    
					        <%--<asp:CheckBoxField DataField="attiva" 
					                           HeaderText="Attiva?" 
					                           SortExpression="attiva"
						                       ReadOnly="true" />--%>
    					    
					        <asp:TemplateField HeaderText="Causa fine">
						        <ItemTemplate>
						            <asp:Label ID="label_descrizione_causa" 
						                       runat="server" 
						                       Text='<%# Bind("descrizione_causa") %>'>
						            </asp:Label>
						        </ItemTemplate>
    						    
						        <InsertItemTemplate>
						            <asp:DropDownList ID="DropDownList1" 
						                              runat="server" 
						                              DataSourceID="SqlDataSource2"
							                          DataTextField="descrizione_causa" 
							                          DataValueField="id_causa" 
							                          SelectedValue='<%# Bind("id_causa_fine") %>'
							                          Width="200px" 
							                          AppendDataBoundItems="True">
							            <asp:ListItem Value="">(nessuna)</asp:ListItem>
						            </asp:DropDownList>
						        </InsertItemTemplate>
    						    
						        <EditItemTemplate>
						            <asp:DropDownList ID="DropDownList2" 
						                              runat="server" 
						                              DataSourceID="SqlDataSource2"
							                          DataTextField="descrizione_causa" 
							                          DataValueField="id_causa" 
							                          SelectedValue='<%# Bind("id_causa_fine") %>'
							                          Width="200px" 
							                          AppendDataBoundItems="True">
							            <asp:ListItem Value="">(nessuna)</asp:ListItem>
						            </asp:DropDownList>
						        </EditItemTemplate>
					        </asp:TemplateField>
    					    
					        <asp:TemplateField ShowHeader="False">
						        <EditItemTemplate>
						            <asp:Button ID="Button1" 
						                        runat="server" 
						                        ValidationGroup="ValidGroup" 
						                        CommandName="Update"
							                    Text="Aggiorna" />
    							                
						            <asp:Button ID="Button2" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Cancel"
							                    Text="Annulla" />
						        </EditItemTemplate>
    							
						        <InsertItemTemplate>
						            <asp:Button ID="Button1" 
						                        runat="server" 
						                        ValidationGroup="ValidGroup" 
						                        CommandName="Insert"
							                    Text="Inserisci" />
    							                
						            <asp:Button ID="Button2" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Cancel"
							                    Text="Annulla" 
    							                
							                    OnClick="ButtonAnnulla_Click" />
						        </InsertItemTemplate>
    							
						        <ItemTemplate>
						            <asp:Button ID="Button1" 
						                        runat="server" 
						                        CausesValidation="False" 
						                        CommandName="Edit"
							                    Text="Modifica" 
							                    Visible="<%# (role <= 2) ? true : false %>" />
									<asp:Button ID="ButtonChiusura" 
                                                        runat="server" 
                                                        CausesValidation="False" 
                                                        CommandName="Close"
                                                        Text="Chiusura" 
                                                        Visible="<%# (role <= 2) ? true : false %>"
                                                        OnClick="ButtonChiusura_Click" />
    							                
						            <%--<asp:Button ID="Button3" 
						                            runat="server" 
						                            CausesValidation="False" 
						                            CommandName="Delete"
							                        Text="Elimina" 
							                        Visible="<%# (role <= 2) ? true : false %>" />--%>
						        </ItemTemplate>
						    <ControlStyle CssClass="button" />
					        </asp:TemplateField>
					    </Fields>
					    <FieldHeaderStyle Font-Bold="True" Width="150px" />
				        </asp:DetailsView>
				    </td>
			        </tr>
			    </table>
    			
			    <asp:SqlDataSource ID="SqlDataSource1" 
			                       runat="server" 
			                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    			                   
			                       SelectCommand="SELECT * 
			                                      FROM legislature AS ll 
			                                      LEFT OUTER JOIN tbl_cause_fine AS cc 
			                                        ON ll.id_causa_fine = cc.id_causa 
				                                  WHERE id_legislatura = @id_legislatura" 
    				               
				                   DeleteCommand="DELETE FROM legislature 
				                                  WHERE id_legislatura = @id_legislatura"
    			                   
			                       InsertCommand="INSERT INTO legislature (num_legislatura, 
			                                                               durata_legislatura_da, 
			                                                               durata_legislatura_a, 
			                                                               attiva, 
			                                                               id_causa_fine) 
			                                      VALUES (@num_legislatura, 
			                                              @durata_legislatura_da, 
			                                              @durata_legislatura_a, 
			                                              @attiva, 
			                                              @id_causa_fine); 
			                                      SELECT @id_legislatura = SCOPE_IDENTITY();"
    			                   
			                       UpdateCommand="UPDATE legislature 
			                                      SET num_legislatura = @num_legislatura, 
			                                          durata_legislatura_da = @durata_legislatura_da, 
			                                          durata_legislatura_a = @durata_legislatura_a, 
			                                          attiva = @attiva, 
			                                          id_causa_fine = @id_causa_fine 
			                                      WHERE id_legislatura = @id_legislatura"
    			                   
			                       OnInserted="SqlDataSource1_Inserted"
                                   OnUpdated="SqlDataSource1_Updated"
                                   OnDeleted="SqlDataSource1_Deleted"
                                   >
    			        
    			    <%--<asp:SessionParameter Name="id_legislatura" SessionField="id_leg" Type="Int32" /> --%>
			        <SelectParameters>
			            <asp:QueryStringParameter Name="id_legislatura" QueryStringField="id" Type="Int32" />
			        </SelectParameters>
    			    
			        <DeleteParameters>
				        <asp:Parameter Name="id_legislatura" Type="Int32" />
			        </DeleteParameters>
    			    
			        <UpdateParameters>
				        <asp:Parameter Name="num_legislatura" Type="String" />
				        <asp:Parameter Name="durata_legislatura_da" Type="DateTime" />
				        <asp:Parameter Name="durata_legislatura_a" Type="DateTime" />
				        <asp:Parameter Name="attiva" Type="Boolean" />
				        <asp:Parameter Name="id_causa_fine" Type="Int32" />
				        <asp:Parameter Name="id_legislatura" Type="Int32" />
			        </UpdateParameters>
    			    
			        <InsertParameters>
				        <asp:Parameter Name="num_legislatura" Type="String" />
				        <asp:Parameter Name="durata_legislatura_da" Type="DateTime" />
				        <asp:Parameter Name="durata_legislatura_a" Type="DateTime" />
				        <asp:Parameter Name="attiva" Type="Boolean" />
				        <asp:Parameter Name="id_causa_fine" Type="Int32" />
				        <asp:Parameter Direction="Output" Name="id_legislatura" Type="Int32" />
			        </InsertParameters>
			    </asp:SqlDataSource>
    			
			    <asp:SqlDataSource ID="SqlDataSource2" 
			                       runat="server" 
			                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    			                   
			                       SelectCommand="SELECT id_causa,
			                                             descrizione_causa
                                                  FROM tbl_cause_fine 
                                                  WHERE LOWER(tipo_causa) = 'legislature' 
                                                  ORDER BY descrizione_causa" >
			    </asp:SqlDataSource>
			    
			    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="True">
			    </asp:ScriptManager>
		        </ContentTemplate>
		    </asp:UpdatePanel>
		    
		    <br />
		    
		    <div align="right">
		        <asp:LinkButton ID="LinkButtonExcelDetails" 
		                        runat="server" 
		                        OnClick="LinkButtonExcelDetails_Click">
		            <img src="../img/page_white_excel.png" alt="" align="top" /> 
		            Esporta
		        </asp:LinkButton>
		        -
		        <asp:LinkButton ID="LinkButtonPdfDetails" 
		                        runat="server" 
		                        OnClick="LinkButtonPdfDetails_Click">
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
	&nbsp;
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
	&nbsp;
    </td>
</tr>
</table>
</asp:Content>
