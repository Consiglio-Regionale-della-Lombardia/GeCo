<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true" 
         CodeFile="dettaglio.aspx.cs" 
         Inherits="gruppi_politici_dettaglio" 
         Title="Gruppo Politico > Anagrafica"%>

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
	<asp:DataList ID="DataList1" 
	              runat="server" 
	              DataSourceID="SqlDataSource5" 
	              Width="50%">
	    <ItemStyle Font-Bold="True" />
	    
	    <ItemTemplate>
		    <asp:Label ID="nomeLabel" 
		               runat="server" 
		               Text='<%# Eval("nome_gruppo") %>' />
		    &gt; ANAGRAFICA
	    </ItemTemplate>
	</asp:DataList>
	
	<asp:SqlDataSource ID="SqlDataSource5" 
	                   runat="server" 
	                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
	                   
	                   SelectCommand="SELECT LTRIM(RTRIM(nome_gruppo)) AS nome_gruppo 
	                                  FROM gruppi_politici 
	                                  WHERE deleted = 0
	                                    AND id_gruppo = @id_gruppo">
	    <SelectParameters>
		    <asp:SessionParameter Name="id_gruppo" SessionField="id_gruppo" Type="Int32" />
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
		        <li id="selected"><a id="a_dettaglio" runat="server">ANAGRAFICA</a></li>
		        <li><a id="a_componenti" runat="server">COMPONENTI</a></li>
		        <li><a id="a_legislature" runat="server">LEGISLATURE</a></li>
		        <li><a id="a_storia" runat="server">STORIA</a></li>
	        </ul>
	    </div>
	
	    <div id="tab_content">
	        <div id="tab_content_content">
		        <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		            <ContentTemplate>
			        <asp:Label ID="LabelGruppiAggregati" 
			                   runat="server" 
			                   Text="" 
			                   Font-Bold="true" 
			                   ForeColor="Red">
			        </asp:Label>
    			    
			        <table width="100%" cellspacing="5" cellpadding="10">
		            <tr>
			            <td class="singleborder" valign="top">
			                <asp:DetailsView ID="DetailsView1" 
			                                 runat="server" 
			                                 Height="50px" 
			                                 Width="100%" 
			                                 AutoGenerateRows="False"
				                             CellPadding="5" 
				                             DataKeyNames="id_gruppo" 
				                             DataSourceID="SqlDataSource4" 
				                             GridLines="None"
        					                 
				                             OnItemDeleted="DetailsView1_ItemDeleted" 
				                             OnItemInserting="DetailsView1_ItemInserting"
				                             OnItemUpdating="DetailsView1_ItemUpdating" 
				                             OnItemUpdated="DetailsView1_ItemUpdated" >
        					                 
				                <FieldHeaderStyle Font-Bold="True" Width="150px" />
            					
				                <Fields>

				                    <asp:TemplateField HeaderText="Legislatura" SortExpression="id_legislatura">
					                    <ItemTemplate>
					                        <asp:Label ID="LabelNumLegislatura" 
					                                   runat="server" 
					                                   Text='<%# Bind("num_legislatura") %>' >
					                        </asp:Label>
					                    </ItemTemplate>

					                    <EditItemTemplate>
					                        <asp:Label ID="LabelNumLegislatura" 
					                                   runat="server" 
					                                   Text='<%# Bind("num_legislatura") %>' >
					                        </asp:Label>
					                    </EditItemTemplate>
                						
					                    <InsertItemTemplate>
					                        <asp:Label ID="LabelNumLegislatura" 
					                                   runat="server" 
					                                   Text='<%# legislatura_corrente_num%>' >
					                        </asp:Label>
					                    </InsertItemTemplate>
				                    </asp:TemplateField>


				                    <asp:TemplateField HeaderText="Codice gruppo" SortExpression="codice_gruppo">
					                    <ItemTemplate>
					                        <asp:Label ID="LabelCodiceGruppo" 
					                                   runat="server" 
					                                   Text='<%# Bind("codice_gruppo") %>' >
					                        </asp:Label>
					                    </ItemTemplate>

                						
					                    <EditItemTemplate>
					                        <asp:TextBox ID="TextBoxCodiceGruppo" 
					                                     runat="server" 
					                                     Width="200px"
					                                     MaxLength='50'
					                                     Text='<%# Bind("codice_gruppo") %>' >
						                    </asp:TextBox>
    					                    
					                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorCodiceGruppo" 
					                                                    ControlToValidate="TextBoxCodiceGruppo"
						                                                runat="server" 
						                                                Display="Dynamic" 
						                                                ErrorMessage="Campo obbligatorio." 
						                                                ValidationGroup="ValidGroup" >
						                    </asp:RequiredFieldValidator>
					                    </EditItemTemplate>
                						
					                    <InsertItemTemplate>
					                        <asp:TextBox ID="TextBoxCodiceGruppo" 
					                                     runat="server" 
					                                     Width="200px"
					                                     MaxLength='50'
					                                     Text='<%# Bind("codice_gruppo") %>' >
						                    </asp:TextBox>
    						                
					                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorCodiceGruppo" 
					                                                    ControlToValidate="TextBoxCodiceGruppo"
						                                                runat="server" 
						                                                Display="Dynamic" 
						                                                ErrorMessage="Campo obbligatorio." 
						                                                ValidationGroup="ValidGroup" >
						                    </asp:RequiredFieldValidator>
					                    </InsertItemTemplate>
				                    </asp:TemplateField>
            					    
				                    <asp:TemplateField HeaderText="Nome gruppo" SortExpression="nome_gruppo">
					                    <ItemTemplate>
					                        <asp:Label ID="LabelNomeGruppo" 
					                                   runat="server" 
					                                   Text='<%# Bind("nome_gruppo") %>'>
					                        </asp:Label>
					                    </ItemTemplate>
            						    
					                    <EditItemTemplate>
					                        <asp:TextBox ID="TextBoxNomeGruppo" 
					                                     runat="server" 
					                                     Width="300px"
					                                     MaxLength='255'
					                                     Text='<%# Bind("nome_gruppo") %>' >
						                    </asp:TextBox>
    					                    
					                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorNomeGruppo" 
					                                                    ControlToValidate="TextBoxNomeGruppo"
						                                                runat="server" 
						                                                Display="Dynamic" 
						                                                ErrorMessage="Campo obbligatorio." 
						                                                ValidationGroup="ValidGroup" >
						                    </asp:RequiredFieldValidator>
					                    </EditItemTemplate>
            						    
					                    <InsertItemTemplate>
					                        <asp:TextBox ID="TextBoxNomeGruppo" 
					                                     runat="server" 
					                                     Width="300px"
					                                     MaxLength='255'
					                                     Text='<%# Bind("nome_gruppo") %>' >
						                    </asp:TextBox>
    					                    
					                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorNomeGruppo" 
					                                                    ControlToValidate="TextBoxNomeGruppo"
						                                                runat="server" 
						                                                Display="Dynamic" 
						                                                ErrorMessage="Campo obbligatorio." 
						                                                ValidationGroup="ValidGroup" >
						                    </asp:RequiredFieldValidator>
					                    </InsertItemTemplate>
				                    </asp:TemplateField>
            					    
				                    <asp:TemplateField HeaderText="Data inizio" SortExpression="data_inizio">
					                    <ItemTemplate>
					                        <asp:Label ID="LabelDataInizio" 
					                                   runat="server" 
					                                   Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
					                        </asp:Label>
					                    </ItemTemplate>
            						    
					                    <EditItemTemplate>
					                        <asp:TextBox ID="dtMod_inizio_group" 
					                                     runat="server" 
					                                     Width="80px"
					                                     Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'>
					                        </asp:TextBox>
    					                    
					                        <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
    					                    
					                        <cc1:CalendarExtender ID="CalendarExtender1" 
					                                              runat="server" 
					                                              TargetControlID="dtMod_inizio_group"
						                                          PopupButtonID="Image1"
						                                          Format="dd/MM/yyyy">
					                        </cc1:CalendarExtender>
    					                    
					                        <asp:RequiredFieldValidator ID="RequiredFieldValidatordMod_inizio_group" 
					                                                    ControlToValidate="dtMod_inizio_group"
						                                                runat="server" 
						                                                Display="Dynamic" 
						                                                ErrorMessage="Campo obbligatorio." 
						                                                ValidationGroup="ValidGroup" >
						                    </asp:RequiredFieldValidator>
    					                    
					                        <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_inizio_group" 
					                                                        ControlToValidate="dtMod_inizio_group"
						                                                    runat="server" 
						                                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                                    Display="Dynamic"
						                                                    ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
						                                                    ValidationGroup="ValidGroup" >
						                    </asp:RegularExpressionValidator>
					                    </EditItemTemplate>
            						    
					                    <InsertItemTemplate>
					                        <asp:TextBox ID="dtIns_inizio_group" 
					                                     runat="server" 
					                                     Width="80px" >
					                        </asp:TextBox>
    					                    
					                        <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
    					                    
					                        <cc1:CalendarExtender ID="CalendarExtender1" 
					                                              runat="server" 
					                                              TargetControlID="dtIns_inizio_group"
						                                          PopupButtonID="Image1"
						                                          Format="dd/MM/yyyy">
					                        </cc1:CalendarExtender>
    					                    
					                        <asp:RequiredFieldValidator ID="RequiredFieldValidatordIns_inizio_group" 
					                                                    ControlToValidate="dtIns_inizio_group"
						                                                runat="server" 
						                                                Display="Dynamic" 
						                                                ErrorMessage="Campo obbligatorio." 
						                                                ValidationGroup="ValidGroup" >
						                    </asp:RequiredFieldValidator>
    					                    
					                        <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_inizio_group" 
					                                                        ControlToValidate="dtIns_inizio_group"
						                                                    runat="server" 
						                                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                                    Display="Dynamic"
						                                                    ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
						                                                    ValidationGroup="ValidGroup" >
						                    </asp:RegularExpressionValidator>
					                    </InsertItemTemplate>
				                    </asp:TemplateField>
            					    
				                    <asp:TemplateField HeaderText="Data fine" SortExpression="data_fine">
					                    <ItemTemplate>
					                        <asp:Label ID="LabelDataFine" 
					                                   runat="server" 
					                                   Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
					                        </asp:Label>
					                    </ItemTemplate>
            						    
					                    <EditItemTemplate>
					                        <asp:TextBox ID="dtMod_fine_group" 
					                                     runat="server" 
					                                     Width="80px"
					                                     Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'>
					                        </asp:TextBox>
    					                    
					                        <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
    					                    
					                        <cc1:CalendarExtender ID="CalendarExtender2" 
					                                              runat="server" 
					                                              TargetControlID="dtMod_fine_group"
						                                          PopupButtonID="Image2"
						                                          Format="dd/MM/yyyy">
					                        </cc1:CalendarExtender>
    					                    
					                        <asp:RegularExpressionValidator ID="RequiredFieldValidatordtMod_fine_group" 
					                                                        ControlToValidate="dtMod_fine_group"
						                                                    runat="server" 
						                                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                                    Display="Dynamic"
						                                                    ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
						                                                    ValidationGroup="ValidGroup" >
						                    </asp:RegularExpressionValidator>
					                    </EditItemTemplate>
            						    
					                    <InsertItemTemplate>
					                        <asp:TextBox ID="dtIns_fine_group" 
					                                     runat="server" 
					                                     Width="80px" >						                                 
					                        </asp:TextBox>
    					                    
					                        <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
    					                    
					                        <cc1:CalendarExtender ID="CalendarExtender2" 
					                                              runat="server" 
					                                              TargetControlID="dtIns_fine_group"
						                                          PopupButtonID="Image2"
						                                          Format="dd/MM/yyyy">
					                        </cc1:CalendarExtender>
    					                    
					                        <asp:RegularExpressionValidator ID="RequiredFieldValidatordtIns_fine_group" 
					                                                        ControlToValidate="dtIns_fine_group"
						                                                    runat="server" 
						                                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
						                                                    Display="Dynamic"
						                                                    ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
						                                                    ValidationGroup="ValidGroup" >
						                    </asp:RegularExpressionValidator>
					                    </InsertItemTemplate>
				                    </asp:TemplateField>
            					
				                    <asp:TemplateField HeaderText="Causa fine">
					                    <ItemTemplate>
					                        <asp:Label ID="label_descrizione_causa" 
					                                   runat="server" 
					                                   Text='<%# Eval("descrizione_causa") %>'>
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
    						                            
					                        <asp:Button ID="Button3" 
					                                    runat="server" 
					                                    CausesValidation="False" 
					                                    CommandName="Delete"
						                                Text="Elimina" 
						                                Visible="<%# (role <= 2) ? true : false %>" 
    						                            
						                                OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
					                    </ItemTemplate>
        						        
					                    <ControlStyle CssClass="button" />
				                    </asp:TemplateField>
				                </Fields>
			                </asp:DetailsView>
			            </td> 
		            </tr> 
			        </table>
    			    
			        <asp:SqlDataSource ID="SqlDataSource4" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        			                   
        			                   SelectCommand="SELECT gg.*, jgp.id_legislatura, l.num_legislatura, cc.* 
			                                          FROM gruppi_politici AS gg 
			                                          LEFT OUTER JOIN tbl_cause_fine AS cc 
			                                            ON cc.id_causa = gg.id_causa_fine
			                                          INNER JOIN join_gruppi_politici_legislature AS jgp
                                                        ON gg.id_gruppo = jgp.id_gruppo
			                                          INNER JOIN legislature AS l
                                                        ON jgp.id_legislatura = l.id_legislatura
			                                          WHERE gg.deleted = 0
			                                            AND gg.id_gruppo = @id_gruppo"
        			                   
			                           DeleteCommand="UPDATE gruppi_politici 
			                                          SET deleted = 1 
			                                          WHERE id_gruppo = @id_gruppo"
    			                                      
			                           InsertCommand="INSERT INTO gruppi_politici (codice_gruppo, 
			                                                                       nome_gruppo, 
			                                                                       data_inizio, 
			                                                                       data_fine, 
			                                                                       attivo, 
			                                                                       id_causa_fine, 
			                                                                       protocollo, 
			                                                                       numero_delibera, 
			                                                                       data_delibera, 
			                                                                       id_delibera) 
			                                          VALUES (@codice_gruppo, 
			                                                  @nome_gruppo, 
			                                                  @data_inizio, 
			                                                  @data_fine, 
			                                                  @attivo, 
			                                                  @id_causa_fine, 
			                                                  @protocollo, 
			                                                  @numero_delibera, 
			                                                  @data_delibera, 
			                                                  @id_delibera); 
			                                          SELECT @id_gruppo = SCOPE_IDENTITY();"
        			                   
			                           UpdateCommand="UPDATE gruppi_politici 
			                                          SET codice_gruppo = @codice_gruppo, 
			                                              nome_gruppo = @nome_gruppo, 
			                                              data_inizio = @data_inizio, 
			                                              data_fine = @data_fine, 
			                                              attivo = @attivo, 
			                                              id_causa_fine = @id_causa_fine, 
			                                              protocollo = @protocollo, 
			                                              numero_delibera = @numero_delibera, 
			                                              data_delibera = @data_delibera, 
			                                              id_delibera = @id_delibera 
			                                          WHERE id_gruppo = @id_gruppo"
        			                   
			                           OnInserted="SqlDataSource4_Inserted"
                                       OnUpdated="SqlDataSource4_Updated"
                                       OnDeleted="SqlDataSource4_Deleted">
        			                   
			            <SelectParameters>
				            <asp:SessionParameter Name="id_gruppo" SessionField="id_gruppo" Type="Int32" />
			            </SelectParameters>
        			    
			            <DeleteParameters>
				            <asp:Parameter Name="id_gruppo" Type="Int32" />
			            </DeleteParameters>
        			    
			            <UpdateParameters>
				            <asp:Parameter Name="codice_gruppo" Type="String" />
				            <asp:Parameter Name="nome_gruppo" Type="String" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
				            <asp:Parameter Name="attivo" Type="Boolean" />
				            <asp:Parameter Name="id_causa_fine" Type="Int32" />
				            <asp:Parameter Name="protocollo" Type="String" />
				            <asp:Parameter Name="numero_delibera" Type="String" />
				            <asp:Parameter Name="data_delibera" Type="DateTime" />
				            <asp:Parameter Name="id_delibera" Type="Int32" />
				            <asp:Parameter Name="id_gruppo" Type="Int32" />
			            </UpdateParameters>
        			    
			            <InsertParameters>			            
				            <asp:Parameter Name="codice_gruppo" Type="String" />
				            <asp:Parameter Name="nome_gruppo" Type="String" />
				            <asp:Parameter Name="data_inizio" Type="DateTime" />
				            <asp:Parameter Name="data_fine" Type="DateTime" />
				            <asp:Parameter Name="attivo" Type="Boolean" />
				            <asp:Parameter Name="id_causa_fine" Type="Int32" />
				            <asp:Parameter Name="protocollo" Type="String" />
				            <asp:Parameter Name="numero_delibera" Type="String" />
				            <asp:Parameter Name="data_delibera" Type="DateTime" />
				            <asp:Parameter Name="id_delibera" Type="Int32" />
				            <asp:Parameter Direction="Output" Name="id_gruppo" Type="Int32" />
			            </InsertParameters>
			        </asp:SqlDataSource>
    			    
			        <asp:SqlDataSource ID="SqlDataSource1" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                           
			                           SelectCommand="SELECT id_gruppo, 
			                                                 LTRIM(RTRIM(nome_gruppo)) AS nome_gruppo 
			                                          FROM gruppi_politici 
			                                          WHERE deleted = 0 
			                                          ORDER BY nome_gruppo">
			        </asp:SqlDataSource>
    			    
			        <asp:SqlDataSource ID="SqlDataSource2" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                           
			                           SelectCommand="SELECT descrizione_causa, 
			                                                 MAX(id_causa) as id_causa
                                                      FROM tbl_cause_fine 
                                                      WHERE LOWER(tipo_causa) = 'gruppi-politici' 
                                                      GROUP BY descrizione_causa
                                                      ORDER BY descrizione_causa" >
			        </asp:SqlDataSource>
    			    
			        <asp:SqlDataSource ID="SqlDataSource3" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
			                           
			                           SelectCommand="SELECT * 
			                                          FROM tbl_delibere">
			        </asp:SqlDataSource>
    			    			    
			        <asp:ScriptManager ID="ScriptManager1" 
			                           runat="server" 
			                           EnableScriptGlobalization="True" >
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
	        <a id="a_back" 
	           runat="server" 
	           href="../gruppi_politici/gestisciGruppiPolitici.aspx">
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