<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="gestisciCariche.aspx.cs" 
         Inherits="cariche_gestisciCariche" 
         Title="Cariche > Gestione Cariche" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">

<b>Gestione cariche</b>

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
		                ImageUrl="~/img/magnifier_arrow.png" />
		                     
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
			    
		<table>
		<tr>
            <%-- 	
			<td valign="middle" width="230">
				Seleziona legislatura:
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
					                SelectCommand="SELECT [id_legislatura], 
					                                        [num_legislatura] 
					                                FROM [legislature]">
				</asp:SqlDataSource>
			</td>
    		
			<td valign="middle" width="230">
				Seleziona data:
				<asp:TextBox ID="TextBoxFiltroData" 
				                runat="server" 
				                Text='<%# Bind("data_fine") %>'
					            Width="70px">
				</asp:TextBox>
				<img alt="calendar" 
				        src="../img/calendar_month.png" 
				        id="ImageFiltroData" 
				        runat="server" />
				<cc1:CalendarExtender ID="CalendarExtenderFiltroData" 
				                        runat="server" 
				                        TargetControlID="TextBoxFiltroData"
					                    PopupButtonID="ImageFiltroData" Format="dd/MM/yyyy">
				</cc1:CalendarExtender>
				<asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
				                                ControlToValidate="TextBoxFiltroData"
					                            runat="server" 
					                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                            Display="Dynamic"
					                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                            ValidationGroup="FiltroData" />
			</td>
            --%>

		    <td align="left" valign="middle">
		        Carica:
		        <asp:TextBox ID="TextBoxRicNomeCarica" 
		                        runat="server" 
		                        Width="150px">
		        </asp:TextBox>
		    </td>
    				
			<td valign="middle">
				<asp:Button ID="ButtonFiltri" 
				            runat="server" 
				            Text="Applica" 
				            OnClick="ButtonFiltri_Click" 
				            ValidationGroup="FiltroData" />
			</td>
		</tr>
		</table>
	</asp:Panel>
</div>

<asp:ListView ID="ListView1" 
              runat="server" 
              DataKeyNames="id_carica" 
              DataSourceID="SqlDataSource1"
              InsertItemPosition="LastItem" 
         
              OnItemDeleting="ListView1_ItemDeleting" 
              OnItemUpdated="ListView1_ItemUpdated"
              OnItemInserting="ListView1_ItemInserting"
              OnItemUpdating="ListView1_ItemUpdating" >
              
    <LayoutTemplate>
	    <table runat="server" width="100%">
        <tr runat="server">
	        <td runat="server">
	            <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
		        <tr runat="server">
		            <th width="150px" id="Th_Carica" runat="server">
                        <asp:LinkButton runat="server" ID="Sort_Carica" 
                            CommandArgument="nome_carica"
                            OnClick="Sort_Column_Click">Carica</asp:LinkButton>
		            </th>
			        
		            <th id="Th_Tipologia" runat="server">	            
                        <asp:LinkButton runat="server" ID="Sort_Tipologia" 
                            CommandArgument="tipologia"
                            OnClick="Sort_Column_Click">Tipologia</asp:LinkButton>
		            </th>
			        
		            <th width="7%" id="Th_Ordine" runat="server">
                        <asp:LinkButton runat="server" ID="Sort_Ordine" 
                            CommandArgument="ordine"
                            OnClick="Sort_Column_Click">Ordine</asp:LinkButton>
		            </th>

			        <th width="7%" id="Th_PresidenteGruppo" runat="server">			            
                        <asp:LinkButton runat="server" ID="Sort_PresidenteGruppo" 
                            CommandArgument="presidente_gruppo"
                            OnClick="Sort_Column_Click">Presidente Gruppo</asp:LinkButton>
		            </th>

			        <th id="Th_IndennitaCarica" runat="server">
                        <asp:LinkButton runat="server" ID="Sort_IndennitaDiCarica" 
                            CommandArgument="indennita_carica"
                            OnClick="Sort_Column_Click">Indennità di carica</asp:LinkButton>
		            </th>

			        <th id="Th_IndennitaFunzione" runat="server">           
                        <asp:LinkButton runat="server" ID="Sort_IndennitaFunzione" 
                            CommandArgument="indennita_funzione"
                            OnClick="Sort_Column_Click">Indennità di funzione</asp:LinkButton>
		            </th>

			        <th id="Th_RimborsoMandato" runat="server">		            
                        <asp:LinkButton runat="server" ID="Sort_RimborsoMandato" 
                            CommandArgument="rimborso_forfettario_mandato"
                            OnClick="Sort_Column_Click">Rimborso forfettario per l'esercizio del mandato</asp:LinkButton>
		            </th>

			        <th id="Th_IndennitaFineMandato" runat="server">
                        <asp:LinkButton runat="server" ID="Sort_IndennitaDiFineMandato" 
                            CommandArgument="indennita_fine_mandato"
                            OnClick="Sort_Column_Click">Indennità di fine mandato</asp:LinkButton>
		            </th>
                    		        
		            <th width="23%" id="Th_CrUdEl" runat="server">
		            </th>
		        </tr>
		        
		        <tr id="itemPlaceholder" runat="server">
		        </tr>
	            </table>
	        </td>
        </tr>
        
        <tr runat="server">
	        <td runat="server" style="" align="center">
	            <asp:DataPager ID="DataPager1" runat="server">
		            <Fields>
		                <asp:NextPreviousPagerField ButtonType="Button" 
		                                            ShowFirstPageButton="False" 
		                                            ShowNextPageButton="False"
			                                        ShowPreviousPageButton="False" />
    			        
		                <asp:NumericPagerField />
    			        
		                <asp:NextPreviousPagerField ButtonType="Button" 
		                                            ShowLastPageButton="False" 
		                                            ShowNextPageButton="False"
			                                        ShowPreviousPageButton="False" />
		            </Fields>
	            </asp:DataPager>
	        </td>
        </tr>
	    </table>
    </LayoutTemplate>
    
    <EmptyDataTemplate>
	    <table id="Table1" runat="server" style="">
	    <tr>
		    <td>
		        Nessun dato disponibile.
		    </td>
	    </tr>
	    </table>
    </EmptyDataTemplate>
    
    <InsertItemTemplate>
	    <tr style="">
	        <td>
		        <asp:TextBox ID="txtCarica_Insert" 
		                     runat="server" 
		                     Text='<%# Bind("nome_carica") %>'
		                     MaxLength='250'
		                     Width="99%" Height="60" TextMode="MultiLine" Font-Names="Verdana" Font-Size="10px"
                             onKeyDown="return CheckMaxLength(this,250);" onChange="CheckMaxLength(this,250)">
		        </asp:TextBox>
		        
		        <asp:RequiredFieldValidator ID="RequiredFieldValidator_txtCarica_Insert" 
		                                    runat="server"
		                                    ErrorMessage="Campo obbligatorio." 
		                                    ControlToValidate="txtCarica_Insert" 
		                                    Display="Dynamic"
		                                    ValidationGroup="ValidGroupInsert" >
		        </asp:RequiredFieldValidator>
	        </td>
	        
	        <td align="center">
	            <asp:DropDownList ID="ddlTipologia_Insert" 
	                              runat="server" 
	                              SelectedValue='<%# Bind("tipologia") %>' >
	                <asp:ListItem Text="ORGANI" Value="ORGANI"></asp:ListItem>
	                <asp:ListItem Text="GRPPOL" Value="GRPPOL"></asp:ListItem>
	            </asp:DropDownList>
	        </td>
	        
	        <td align="center">
		        <asp:TextBox ID="txtOrdine_Insert" 
		                     runat="server"
		                     Text='<%# Bind("ordine") %>' 
		                     Width="95%" >
		        </asp:TextBox>
		        
		        <asp:RequiredFieldValidator ID="RequiredFieldValidator_txtOrdine_Insert" 
		                                    runat="server"
		                                    ErrorMessage="Campo obbligatorio." 
		                                    ControlToValidate="txtOrdine_Insert" 
		                                    Display="Dynamic"
		                                    ValidationGroup="ValidGroupInsert" >
		        </asp:RequiredFieldValidator>
		        
		        <asp:RegularExpressionValidator ID="RegularExpressionValidator_txtOrdine_Insert" 
		                                        ControlToValidate="txtOrdine_Insert"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Solo cifre ammesse." 
		                                        ValidationExpression="^[0-9]+$" >
		        </asp:RegularExpressionValidator>
	        </td>	
            
            <td align="center">
                <asp:CheckBox ID="ChkPresidenteGruppo" 
                            runat="server" 
                            Checked='<%# Bind("presidente_gruppo") %>'  />
            </td>  
            
      	    <td align="center">
		        <asp:TextBox ID="txtIndennitaCarica_Insert" 
		                     runat="server"
		                     Text='<%# Bind("indennita_carica") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_IndennitaCarica_Insert" 
		                                        ControlToValidate="txtIndennitaCarica_Insert"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td>     
            
      	    <td align="center">
		        <asp:TextBox ID="txtIndennitaFunzione_Insert" 
		                     runat="server"
		                     Text='<%# Bind("indennita_funzione") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_IndennitaFunzione_Insert" 
		                                        ControlToValidate="txtIndennitaFunzione_Insert"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td>  
            
         	<td align="center">
		        <asp:TextBox ID="txtRimborsoMandato_Insert" 
		                     runat="server"
		                     Text='<%# Bind("rimborso_forfettario_mandato") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_RimborsoMandato_Insert" 
		                                        ControlToValidate="txtRimborsoMandato_Insert"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td>                  
                   	        
      	    <td align="center">
		        <asp:TextBox ID="txtIndennitaFineMandato_Insert" 
		                     runat="server"
		                     Text='<%# Bind("indennita_fine_mandato") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_IndennitaFineMandato_Insert" 
		                                        ControlToValidate="txtIndennitaFineMandato_Insert"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td> 
            	        
	        <td align="center" valign="top">
		        <asp:Button ID="InsertButton" 
		                    runat="server" 
		                    CommandName="Insert" 
		                    Text="Inserisci"
		                    ValidationGroup="ValidGroupInsert" 
		                    CssClass="button" />
				
		        <asp:Button ID="CancelButton" 
		                    runat="server" 
		                    CommandName="Cancel" 
		                    Text="Cancella"
		                    CssClass="button" />
	        </td>
	    </tr>
    </InsertItemTemplate>
    		    
    <EditItemTemplate>
	    <tr style="">
	        <td>
		        <asp:TextBox ID="txtCarica_Edit" 
		                     runat="server" 
		                     Text='<%# Bind("nome_carica") %>'
		                     MaxLength='250' 
		                     Width="99%" Height="60" TextMode="MultiLine" Font-Names="Verdana" Font-Size="10px"
                             onKeyDown="return CheckMaxLength(this,250);" onChange="CheckMaxLength(this,250)">>
		        </asp:TextBox>
		        
		        <asp:RequiredFieldValidator ID="RequiredFieldValidator_txtCarica_Edit" 
		                                    runat="server"
		                                    ErrorMessage="Campo obbligatorio." 
		                                    ControlToValidate="txtCarica_Edit" 
		                                    Display="Dynamic"
		                                    ValidationGroup="ValidGroupEdit" >
		        </asp:RequiredFieldValidator>
	        </td>
	        
	        <td align="center">
	            <asp:DropDownList ID="ddlTipologia_Edit" 
	                              runat="server"
	                              SelectedValue='<%# Bind("tipologia") %>' >	                
	                <asp:ListItem Text="ORGANI" Value="ORGANI"></asp:ListItem>
	                <asp:ListItem Text="GRPPOL" Value="GRPPOL"></asp:ListItem>
	            </asp:DropDownList>
	        </td>
	        
	        <td align="center">
		        <asp:TextBox ID="txtOrdine_Edit" 
		                     runat="server" 
		                     Text='<%# Bind("ordine") %>' 
		                     Width="95%" >
		        </asp:TextBox>
		        
		        <asp:RequiredFieldValidator ID="RequiredFieldValidator_txtOrdine_Edit" 
		                                    runat="server"
		                                    ErrorMessage="Campo obbligatorio." 
		                                    ControlToValidate="txtOrdine_Edit" 
		                                    Display="Dynamic"
		                                    ValidationGroup="ValidGroupEdit" >
		        </asp:RequiredFieldValidator>
		        
		        <asp:RegularExpressionValidator ID="RegularExpressionValidator_txtOrdine_Edit" 
		                                        ControlToValidate="txtOrdine_Edit"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Solo cifre ammesse." 
		                                        ValidationExpression="^[0-9]+$" >
		        </asp:RegularExpressionValidator>
	        </td>

            <td align="center">
                <asp:CheckBox ID="ChkPresidenteGruppo" 
                            runat="server" 
                            Checked='<%# Bind("presidente_gruppo") %>'  />
            </td> 

      	    <td align="center">
		        <asp:TextBox ID="txtIndennitaCarica_Edit" 
		                     runat="server"
		                     Text='<%# Bind("indennita_carica") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_IndennitaCarica_Edit" 
		                                        ControlToValidate="txtIndennitaCarica_Edit"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td>     
            
      	    <td align="center">
		        <asp:TextBox ID="txtIndennitaFunzione_Edit" 
		                     runat="server"
		                     Text='<%# Bind("indennita_funzione") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_IndennitaFunzione_Edit" 
		                                        ControlToValidate="txtIndennitaFunzione_Edit"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td>  
            
         	<td align="center">
		        <asp:TextBox ID="txtRimborsoMandato_Edit" 
		                     runat="server"
		                     Text='<%# Bind("rimborso_forfettario_mandato") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_RimborsoMandato_Edit" 
		                                        ControlToValidate="txtRimborsoMandato_Edit"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td>                  
                   	        
      	    <td align="center">
		        <asp:TextBox ID="txtIndennitaFineMandato_Edit" 
		                     runat="server"
		                     Text='<%# Bind("indennita_fine_mandato") %>' 
		                     Width="95%">
		        </asp:TextBox>
		        
		        <asp:RegularExpressionValidator ID="RegexValid_IndennitaFineMandato_Edit" 
		                                        ControlToValidate="txtIndennitaFineMandato_Edit"
		                                        runat="server" 
		                                        Display="Dynamic" 
		                                        ErrorMessage="Immettere un importo valido" 
		                                        ValidationExpression="^(0|((\d{1,3})\.?(\d{3})*))\,?(\d{1,2})?$" >
		        </asp:RegularExpressionValidator>
	        </td> 
	        
	        <td align="center" valign="top">
		        <asp:Button ID="UpdateButton" 
		                    runat="server" 
		                    CommandName="Update" 
		                    Text="Aggiorna"
		                    ValidationGroup="ValidGroupEdit" 
		                    CssClass="button" />
		        
		        <asp:Button ID="CancelButton" 
		                    runat="server" 
		                    CommandName="Cancel" 
		                    Text="Annulla"
		                    CssClass="button" />
	        </td>
	    </tr>
    </EditItemTemplate>
    <AlternatingItemTemplate>
        <tr style="background-color: #b2cca7;">
	        <td>
		        <asp:Label ID="nome_caricaLabel" 
		                   runat="server" 
		                   Text='<%# Eval("nome_carica") %>' 
		                   Width="95%" >
		        </asp:Label>
	        </td>
	        
	        <td align="center">
		        <asp:Label ID="lblTipologia_Item" 
		                   runat="server" 
		                   Text='<%# Eval("tipologia") %>' >
		        </asp:Label>
	        </td>
	        
            <td align="center">
	            <asp:Label ID="ordineLabel" 
	                       runat="server" 
	                       Text='<%# Eval("ordine") %>' >
	            </asp:Label>
            </td>

            <td align="center">
                <asp:CheckBox ID="ChkPresidenteGruppo" 
                            runat="server"
                            Enabled="false" 
                            Checked='<%# Bind("presidente_gruppo") %>'  />
            </td> 

            <td align="center">
	            <asp:Label ID="IndennitaCaricaLabel" 
	                       runat="server" 
	                       Text='<%# Eval("indennita_carica_desc") %>' >
	            </asp:Label>
            </td>

            <td align="center">
	            <asp:Label ID="IndennitaFunzioneLabel" 
	                       runat="server" 
	                       Text='<%# Eval("indennita_funzione_desc") %>' >
	            </asp:Label>
            </td>

            <td align="center">
	            <asp:Label ID="RimborsoMandatoLabel" 
	                       runat="server" 
	                       Text='<%# Eval("rimborso_forfettario_mandato_desc") %>' >
	            </asp:Label>
            </td>

            <td align="center">
	            <asp:Label ID="IndennitaFineMandatoLabel" 
	                       runat="server" 
	                       Text='<%# Eval("indennita_fine_mandato_desc") %>' >
	            </asp:Label>
            </td>
            
            <td align="center" valign="top">
	            <asp:Button ID="EditButton" 
	                        runat="server" 
	                        CommandName="Edit" 
	                        Text="Modifica" 
	                        CssClass="button" />
	            
	            <asp:Button ID="DeleteButton" 
	                        runat="server" 
	                        CommandName="Delete" 
	                        Text="Elimina"
	                        CssClass="button"                         
	                        OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
	        </td>
	    </tr>
    </AlternatingItemTemplate>
    <ItemTemplate>
	    <tr style="">
	        <td>
		        <asp:Label ID="nome_caricaLabel" 
		                   runat="server" 
		                   Text='<%# Eval("nome_carica") %>' 
		                   Width="95%" >
		        </asp:Label>
	        </td>
	        
	        <td align="center">
		        <asp:Label ID="lblTipologia_Item" 
		                   runat="server" 
		                   Text='<%# Eval("tipologia") %>' >
		        </asp:Label>
	        </td>
	        
            <td align="center">
	            <asp:Label ID="ordineLabel" 
	                       runat="server" 
	                       Text='<%# Eval("ordine") %>' >
	            </asp:Label>
            </td>

            <td align="center">
                <asp:CheckBox ID="ChkPresidenteGruppo" 
                            runat="server"
                            Enabled="false" 
                            Checked='<%# Bind("presidente_gruppo") %>'  />
            </td> 

            <td align="center">
	            <asp:Label ID="IndennitaCaricaLabel" 
	                       runat="server" 
	                       Text='<%# Eval("indennita_carica_desc") %>' >
	            </asp:Label>
            </td>

            <td align="center">
	            <asp:Label ID="IndennitaFunzioneLabel" 
	                       runat="server" 
	                       Text='<%# Eval("indennita_funzione_desc") %>' >
	            </asp:Label>
            </td>

            <td align="center">
	            <asp:Label ID="RimborsoMandatoLabel" 
	                       runat="server" 
	                       Text='<%# Eval("rimborso_forfettario_mandato_desc") %>' >
	            </asp:Label>
            </td>

            <td align="center">
	            <asp:Label ID="IndennitaFineMandatoLabel" 
	                       runat="server" 
	                       Text='<%# Eval("indennita_fine_mandato_desc") %>' >
	            </asp:Label>
            </td>
            
            <td align="center" valign="top">
	            <asp:Button ID="EditButton" 
	                        runat="server" 
	                        CommandName="Edit" 
	                        Text="Modifica" 
	                        CssClass="button" />
	            
	            <asp:Button ID="DeleteButton" 
	                        runat="server" 
	                        CommandName="Delete" 
	                        Text="Elimina"
	                        CssClass="button"                         
	                        OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
	        </td>
	    </tr>
    </ItemTemplate>		    
</asp:ListView>

<asp:SqlDataSource ID="SqlDataSource1" 
                   runat="server" 
                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                   
                   SelectCommand="SELECT [id_carica]
                                      ,[nome_carica]
                                      ,[ordine]
                                      ,[tipologia]
                                      ,isnull([presidente_gruppo],0) as presidente_gruppo
                                      ,indennita_carica
                                      ,indennita_funzione
                                      ,rimborso_forfettario_mandato
                                      ,indennita_fine_mandato
                                          ,case when [indennita_carica] is null then ''
	                                       else '€ ' + convert(varchar, [indennita_carica], 1)
	                                       end as indennita_carica_desc

                                          ,case when [indennita_funzione] is null then ''
	                                       else '€ ' + convert(varchar, [indennita_funzione], 1)
	                                       end as indennita_funzione_desc

                                          ,case when [rimborso_forfettario_mandato] is null then ''
	                                       else '€ ' + convert(varchar, [rimborso_forfettario_mandato], 1)
	                                       end as rimborso_forfettario_mandato_desc

                                          ,case when [indennita_fine_mandato] is null then ''
	                                       else '€ ' + convert(varchar, [indennita_fine_mandato], 1)
	                                       end as indennita_fine_mandato_desc
                                  FROM cariche"
                                  
                   DeleteCommand="DELETE FROM cariche 
                                  WHERE id_carica = @id_carica" 
                   
                   InsertCommand="INSERT INTO cariche (nome_carica 
                                                      ,tipologia
                                                      ,ordine
                                                      ,presidente_gruppo
                                                      ,indennita_carica
                                                      ,indennita_funzione
                                                      ,rimborso_forfettario_mandato
                                                      ,indennita_fine_mandato) 
                                  VALUES (@nome_carica 
                                         ,@tipologia
                                         ,@ordine
                                         ,@presidente_gruppo
                                         ,@indennita_carica
                                         ,@indennita_funzione
                                         ,@rimborso_forfettario_mandato
                                         ,@indennita_fine_mandato); 
                                  SELECT @id_carica = SCOPE_IDENTITY();"

                   UpdateCommand="UPDATE cariche 
                                  SET nome_carica = @nome_carica 
                                     ,tipologia = @tipologia
                                     ,ordine = @ordine 
                                     ,presidente_gruppo = @presidente_gruppo
                                     ,indennita_carica = @indennita_carica
                                     ,indennita_funzione = @indennita_funzione
                                     ,rimborso_forfettario_mandato = @rimborso_forfettario_mandato
                                     ,indennita_fine_mandato = @indennita_fine_mandato
                                  WHERE id_carica = @id_carica"
                   
                   OnInserted="SqlDataSource1_Inserted" OnSelecting="SqlDataSource1_Selecting">
                   
    <DeleteParameters>
	    <asp:Parameter Name="id_carica" Type="Int32" />
    </DeleteParameters>
    
    <UpdateParameters>
		<asp:Parameter Name="nome_carica" Type="String" />
		<asp:Parameter Name="tipologia" Type="String" />
		<asp:Parameter Name="ordine" Type="Int32" />
    	<asp:Parameter Name="id_carica" Type="Int32" />
        <asp:Parameter Name="indennita_carica" Type="Decimal" />
        <asp:Parameter Name="indennita_funzione" Type="Decimal" />
        <asp:Parameter Name="rimborso_forfettario_mandato" Type="Decimal" />
        <asp:Parameter Name="indennita_fine_mandato" Type="Decimal" />
    </UpdateParameters>
    
    <InsertParameters>
		<asp:Parameter Name="nome_carica" Type="String" />
		<asp:Parameter Name="tipologia" Type="String" />
		<asp:Parameter Name="ordine" Type="Int32" />
        <asp:Parameter Name="indennita_carica" Type="Decimal" />
        <asp:Parameter Name="indennita_funzione" Type="Decimal" />
        <asp:Parameter Name="rimborso_forfettario_mandato" Type="Decimal" />
        <asp:Parameter Name="indennita_fine_mandato" Type="Decimal" />
    	<asp:Parameter Direction="Output" Name="id_carica" Type="Int32" />
    </InsertParameters>
</asp:SqlDataSource>
</ContentTemplate>
</asp:UpdatePanel>
</div>
</asp:Content>