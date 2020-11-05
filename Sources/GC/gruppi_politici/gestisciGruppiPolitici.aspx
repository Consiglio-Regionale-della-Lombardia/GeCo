<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         EnableViewState="false"
         EnableEventValidation="false"
         CodeFile="gestisciGruppiPolitici.aspx.cs" 
         Inherits="gestisciGruppiPolitici" 
         Title="Gruppi Politici > Ricerca" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
<b>
    GRUPPI POLITICI &gt; RICERCA
</b>

<br />
<br />

<asp:ScriptManager ID="ScriptManager2" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>

<asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
<ContentTemplate>
    <div class="pannello_ricerca">
        <asp:ImageButton ID="ImageButtonRicerca" 
                         runat="server" 
                         ImageUrl="~/img/magnifier_arrow.png"
                         
                         OnClick="img_Search_Click" />
        
        <asp:Label ID="LabelRicerca" 
                   runat="server" 
                   Text="">
        </asp:Label>
        
        <cc1:CollapsiblePanelExtender ID="cpe" 
                                      runat="Server" 
                                      TargetControlID="PanelRicerca"
	                                  CollapsedSize="0" 
	                                  Collapsed="True" 
	                                  ExpandControlID="ImageButtonRicerca" 
	                                  CollapseControlID="ImageButtonRicerca"
	                                  AutoCollapse="False" 
	                                  AutoExpand="False" 
	                                  ScrollContents="False" 
	                                  TextLabelID="LabelRicerca"
	                                  CollapsedText="Apri Ricerca" 
	                                  ExpandedText="Nascondi Ricerca" 
	                                  ExpandDirection="Vertical" >
	    </cc1:CollapsiblePanelExtender>
		                              
        <asp:Panel ID="PanelRicerca" runat="server">
	        <br />
	        
	        <table width="100%">
            <tr>
                <td align="left" valign="middle">
	                    <asp:Label ID="lbl_leg_search" 
	                               runat="server"
	                               Text="Seleziona legislatura:" >
	                    </asp:Label>
    	                
	                    <asp:DropDownList ID="DropDownListLegislatura" 
	                                      runat="server" 
	                                      DataSourceID="SqlDataSourceLegislature"
		                                  DataTextField="num_legislatura" 
		                                  DataValueField="id_legislatura" 
		                                  Width="70px"
		                                  AppendDataBoundItems="True">
		                    <asp:ListItem Text="(tutte)" Value="" ></asp:ListItem>
	                    </asp:DropDownList>
    	                
	                    <asp:SqlDataSource ID="SqlDataSourceLegislature" 
	                                       runat="server" 
	                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    	                                   
		                                   SelectCommand="SELECT id_legislatura, 
		                                                         num_legislatura
		                                                  FROM legislature
		                                                  ORDER BY durata_legislatura_da DESC" >
	                    </asp:SqlDataSource>
	                </td>
	            
	            <td align="left" valign="middle">
	                <asp:Label ID="lbl_stato_search"
	                           runat="server"
	                           Text="Stato:">
	                </asp:Label>
	                
	                <asp:DropDownList ID="ddl_stato_search" 
	                                  runat="server"
	                                  AppendDataBoundItems="true">
	                    <asp:ListItem Text="(tutti)" Value=""></asp:ListItem>
	                    <asp:ListItem Text="Attivi" Value="1" Selected="True"></asp:ListItem>
	                    <asp:ListItem Text="Inattivi" Value="2"></asp:ListItem>
	                </asp:DropDownList>
	            </td>
			    
	            <td align="left" valign="middle">
	                Seleziona data:
	                <asp:TextBox ID="TextBoxFiltroData" 
	                             runat="server" 
	                             Text='<%# Bind("data_fine") %>'
		                         Width="70px">
		            </asp:TextBox>
		            
	                <img alt="calendar" src="../img/calendar_month.png" id="ImageFiltroData" runat="server" />
	                
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
	            </td>
			    
	            <td align="right" valign="middle">
	                <asp:Button ID="ButtonFiltri" 
	                            runat="server" 
	                            Text="Applica" 
	                            Width="100px"
	                            OnClick="ButtonFiltri_Click" 
	                            ValidationGroup="FiltroData" />
	            </td>
            </tr>
	        </table>
        </asp:Panel>
    </div>
	
    <asp:GridView ID="GridView1" 
                  runat="server" 
                  PagerStyle-HorizontalAlign="Center" 
                  AllowSorting="True"
                  AutoGenerateColumns="False" 
                  CellPadding="5" 
                  CssClass="tab_gen" 
                  DataSourceID="SqlDataSource1"
                  GridLines="None" 
                  DataKeyNames="id_gruppo" 
                  
                  OnSorting="GridView1_OnSorting"
                  OnRowDataBound="GridView1_RowDataBound" >
	              
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
		                        Text="Nuovo" 
		                        OnClick="Button1_Click" 
		                        CssClass="button"
		                        Width="100px"
			                    CausesValidation="false" />
		            <% } %>
		        </th>
	        </tr>
	        </table>
        </EmptyDataTemplate>
	    <AlternatingRowStyle BackColor="#b2cca7" />	
        <Columns>		    
	        <asp:TemplateField>
	            <ItemTemplate>
		            <asp:CheckBox ID="CheckBoxAzione" 
		                          runat="server" 
		                          AutoPostBack="true" 
		                          OnCheckedChanged="chkbox_Azione_OnCheckedChanged" />
	            </ItemTemplate>
	            
	            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="20px" />
	        </asp:TemplateField>
			
	        <asp:BoundField DataField="num_legislatura" 
	                        HeaderText="Legisl." 
	                        SortExpression="num_legislatura" 
	                        ItemStyle-HorizontalAlign="center" 
	                        ItemStyle-Width="40px" />
			
	        <asp:BoundField DataField="codice_gruppo" 
	                        HeaderText="Codice gruppo" 
	                        SortExpression="codice_gruppo" 
	                        ItemStyle-HorizontalAlign="center" 
	                        ItemStyle-Width="80px" />
			
	        <asp:BoundField DataField="nome_gruppo" 
	                        HeaderText="Nome gruppo" 
	                        SortExpression="nome_gruppo" />
			
	        <asp:BoundField DataField="data_inizio" 
	                        HeaderText="Data inizio" 
	                        SortExpression="data_inizio"
	                        DataFormatString="{0:dd/MM/yyyy}" 
	                        ItemStyle-HorizontalAlign="center" 
	                        ItemStyle-Width="80px" />
			
	        <asp:BoundField DataField="data_fine" 
	                        HeaderText="Data fine" 
	                        SortExpression="data_fine"
	                        DataFormatString="{0:dd/MM/yyyy}" 
	                        ItemStyle-HorizontalAlign="center" 
	                        ItemStyle-Width="80px" />
			                
	        <%--<asp:CheckBoxField DataField="attivo" 
	                           HeaderText="Attivo?" 
	                           SortExpression="attivo" 
	                           ItemStyle-HorizontalAlign="center" 
	                           ItemStyle-Width="50px" />--%>
			
	        <asp:BoundField DataField="descrizione_causa" 
	                        HeaderText="Causa fine" 
	                        SortExpression="descrizione_causa" 
	                        ItemStyle-HorizontalAlign="center" 
	                        ItemStyle-Width="100px"/>
			
	        <asp:TemplateField>
	            <ItemTemplate>
		            <asp:HyperLink ID="HyperLinkDettagli" 
		                           runat="server" 
		                           NavigateUrl='<%# Eval("id_gruppo", "dettaglio.aspx?id={0}") %>'
		                           Text="Dettagli">
		            </asp:HyperLink>
	            </ItemTemplate>
		        
	            <HeaderTemplate>
		        <% if (role <= 2) { %>
		        <asp:Button ID="Button1" 
		                    runat="server" 
		                    OnClick="Button1_Click" 
		                    Text="Nuovo" 
		                    Width="100px"
		                    CssClass="button" />
		        <% } %>
	            </HeaderTemplate>
		        
	            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
	        </asp:TemplateField>
        </Columns>
    </asp:GridView>
	
    <asp:SqlDataSource ID="SqlDataSource1" 
                       runat="server" 
                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
    </asp:SqlDataSource>
    
    <br />
    
    <% if (role <= 2)
       { %>
    <div align="right">
        Gruppi selezionati:
        <asp:LinkButton ID="LinkButton3" 
                        runat="server"
                        
                        OnClick="LinkButtonAggrega_Click">
            <img src="../img/arrow_in.png" alt="" align="top" /> 
            Aggregazione
        </asp:LinkButton>
        -
        <asp:LinkButton ID="LinkButton4" 
                        runat="server"
                        
                        OnClick="LinkButtonScindi_Click">
            <img src="../img/arrow_out.png" alt="" align="top" /> 
            Scissione
        </asp:LinkButton>
        -
        <asp:LinkButton ID="LinkButton5" 
                        runat="server"
                         
                        OnClick="LinkButtonRinomina_Click">
            <img src="../img/arrow_rotate_anticlockwise.png" alt="" align="top" /> 
            Ridenominazione
        </asp:LinkButton>
    </div>
    <% } %>
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

<asp:Panel ID="PanelDetails" 
           runat="server" 
           BackColor="White" 
           BorderColor="DarkSeaGreen"
           BorderWidth="2px" 
           Width="500px" 
           ScrollBars="Vertical" 
           Style="padding: 10px; display: none; max-height: 500px;">
    <div align="center">
	    <br />
	    <h3>SCISSIONE GRUPPO</h3>		        
	    <asp:UpdatePanel ID="UpdatePanelDetails" runat="server" UpdateMode="Conditional">
	        <ContentTemplate>	
	            <br />	            		            
	            Seleziona la data di scissione del gruppo: 
	            &nbsp
	            
	            <br />	
	            
	            <asp:TextBox ID="txtDataScissione" 
                             runat="server" >
                </asp:TextBox>
                
                <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
                
                <cc1:CalendarExtender ID="CalendarExtender3" 
                                      runat="server" 
                                      TargetControlID="txtDataScissione"
                                      PopupButtonID="Image3" 
                                      Format="dd/MM/yyyy">
                </cc1:CalendarExtender>
                
                <asp:RequiredFieldValidator ID="RequiredFieldValidator_DataScissione" 
                                            ControlToValidate="txtDataScissione"
                                            runat="server" 
                                            Display="Dynamic" 
                                            ErrorMessage="Campo obbligatorio." 
                                            ValidationGroup="ValidDataScissione" >
                </asp:RequiredFieldValidator>
                
                <asp:RegularExpressionValidator ID="RequiredExpressionValidator_DataScissione" 
                                                ControlToValidate="txtDataScissione"
                                                runat="server" 
                                                ErrorMessage="Ammessi solo valori GG/MM/AAAA."  
                                                Display="Dynamic"
                                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
                                                ValidationGroup="ValidDataScissione" >
                </asp:RegularExpressionValidator>
                                                
                <br />
                <br />
                
                Seleziona i gruppi in cui si è scisso quello selezionato.	
                	    
	            <br /> 
	                    
		        <asp:GridView ID="GridView2" 
		                      runat="server" 
		                      PagerStyle-HorizontalAlign="Center" 
		                      AutoGenerateColumns="False" 
		                      DataKeyNames="id_gruppo" 
		                      DataSourceID="SqlDataSource2" 
		                      CssClass="tab_gen">
			        
		            <Columns>
			            <asp:TemplateField>
			                <ItemTemplate>
				                <asp:CheckBox ID="CheckBoxScissione" 
				                              runat="server" 
				                              AutoPostBack="true" 
				                              OnCheckedChanged="chkbox_Scissione_OnCheckedChanged"/>
			                </ItemTemplate>
				            
			                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="20px" />
			            </asp:TemplateField>
    				    
			            <asp:BoundField DataField="nome_gruppo" 
			                            HeaderText="Gruppo" 
			                            SortExpression="nome_gruppo" />
    				    
			            <asp:BoundField DataField="data_inizio" 
			                            HeaderText="Data inizio" 
			                            SortExpression="data_inizio" 
			                            DataFormatString="{0:dd/MM/yyyy}" 
			                            ItemStyle-HorizontalAlign="center" 
			                            ItemStyle-Width="80px" />
    				    
			            <asp:BoundField DataField="data_fine" 
			                            HeaderText="Data Fine" 
			                            SortExpression="data_fine" 
			                            DataFormatString="{0:dd/MM/yyyy}" 
			                            ItemStyle-HorizontalAlign="center" 
			                            ItemStyle-Width="80px" />
		            </Columns>
		        </asp:GridView>        			        			
    			
		        <asp:SqlDataSource ID="SqlDataSource2" 
		                           runat="server" 
		                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                           SelectCommand="SELECT id_gruppo, 
		                                                 LTRIM(RTRIM(nome_gruppo)) AS nome_gruppo, 
		                                                 data_inizio, 
		                                                 data_fine 
		                                          FROM gruppi_politici 
		                                          WHERE id_gruppo != @id_gruppo 
		                                            AND deleted = 0 
		                                            AND attivo = 1 
		                                            AND data_fine IS NULL
		                                          ORDER BY nome_gruppo" >
		            <SelectParameters>
		                <asp:SessionParameter Name="id_gruppo" SessionField="gruppo_scissione" Type="String" />
		            </SelectParameters>
		        </asp:SqlDataSource>
		        
		        <br />
    			
		        <asp:Button ID="ButtonSalva" 
		                    runat="server" 
		                    Text="Conferma" 
		                    CausesValidation="True"
		                    ValidationGroup="ValidDataScissione"
		                    CssClass="button" 
		                    OnClick="ButtonSalva_Click" />
    			
		        <asp:Button ID="ButtonAnnulla" 
		                    runat="server" 
		                    Text="Annulla" 
		                    CssClass="button" 
		                    OnClick="ButtonAnnulla_Click"/>
	        </ContentTemplate>
	    </asp:UpdatePanel>		    
    </div>
    
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
</asp:Content>