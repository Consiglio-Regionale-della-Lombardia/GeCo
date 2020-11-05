<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="gestisciUtenti.aspx.cs" 
         Inherits="utenti_gestisciUtenti" 
         Title="Utenti > Gestione Utenti" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content">
	<b>Gestione utenti</b>
	
	<br />
	<br />
	
	<asp:ScriptManager ID="ScriptManager" 
	                   runat="server" 
	                   EnableScriptGlobalization="True">
	</asp:ScriptManager>
	
	<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
	    <ContentTemplate>
		<asp:ListView ID="ListView1" 
		              runat="server" 
		              DataKeyNames="id_utente" 
		              DataSourceID="SqlDataSource1"
		              InsertItemPosition="LastItem" 
		              
		              OnItemInserting="ListView1_ItemInserting" 
		              OnItemUpdating="ListView1_ItemUpdating">
		    
		    <LayoutTemplate>
			    <table runat="server" width="100%">
			    <tr runat="server">
				    <td runat="server">
				        <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
					        <tr runat="server" class="tab_ris_header">
					            <th runat="server">Username</th>
					            <th runat="server">Password</th>
					            <th runat="server">Attivo?</th>
					            <th runat="server">Ruolo</th>
					            <th id="Th3" runat="server">Nome</th>
					            <th id="Th4" runat="server">Cognome</th>
					            <th runat="server">Rete</th>
					            <th id="Th1" runat="server"></th>
					        </tr>
    					    
					        <tr id="itemPlaceholder" runat="server"></tr>
				        </table>
				    </td>
			    </tr>
			    </table>
		    </LayoutTemplate>
		    
		    <EmptyDataTemplate>
			    <table id="Table1" runat="server" style="">
			    <tr>
				    <td>
				        Non è stato restituito alcun dato.
				    </td>
			    </tr>
			    </table>
		    </EmptyDataTemplate>
		    
		    <InsertItemTemplate>
			    <tr style="">
			        <td valign="middle" align="center" width="10%">
				        <asp:TextBox ID="nome_utenteTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("nome_utente") %>'
				                     Width="95%" 
				                     MaxLength='50' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatornome_utenteTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="nome_utenteTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" width="10%" align="center">
				        <asp:TextBox ID="pwdTextBox" 
				                     TextMode="password" 
				                     runat="server" 
				                     Text='<%# Bind("pwd") %>'
				                     Width="95%" 
				                     MaxLength='32' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorpwdTextBox"
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="pwdTextBox"
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" align="center" width="5%">
				        <asp:CheckBox ID="attivoCheckBox" 
				                      runat="server" 
				                      Checked='<%# Bind("attivo") %>'
				                      Width="95%" />
			        </td>
			        
			        <td valign="middle" width="25%" align="center">
				        <asp:DropDownList ID="DropDownList1" 
				                          runat="server" 
				                          DataSourceID="SqlDataSource2"
				                          DataTextField="nome_ruolo" 
				                          DataValueField="id_ruolo" 
				                          Font-Size="7pt"
				                          Width="99%">
				        </asp:DropDownList>
			        </td>
			        
			        <td valign="middle" width="10%" align="center">
				        <asp:TextBox ID="nomeTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("nome") %>' 
				                     Width="95%"
				                     MaxLength='20' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatornomeTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="nomeTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" width="10%" align="center">
				        <asp:TextBox ID="cognomeTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("cognome") %>' 
				                     Width="95%"
				                     MaxLength='50' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorcognomeTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="cognomeTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" width="20%" align="center">
				        <asp:TextBox ID="login_reteTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("login_rete") %>'
				                     Width="95%" 
				                     MaxLength='50' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorlogin_reteTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="login_reteTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td width="10%" align="right" valign="middle">
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
			        <td align="center" valign="middle" width="10%">
				        <asp:TextBox ID="nome_utenteTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("nome_utente") %>'
				                     Width="95%" 
				                     MaxLength='50' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatornome_utenteTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="nome_utenteTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupEdit" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td align="center" valign="middle" width="5%">
				        <asp:TextBox ID="pwdTextBox" 
				                     TextMode="password" 
				                     runat="server" 
				                     Text='<%# Bind("pwd") %>'
				                     Width="95%" 
				                     MaxLength='32' >
				        </asp:TextBox>
			        </td>
			        
			        <td valign="middle" align="center" width="5%">
				        <asp:CheckBox ID="attivoCheckBox" 
				                      runat="server" 
				                      Checked='<%# Bind("attivo") %>'
				                      Width="95%" />
			        </td>
			        
			        <td valign="middle" align="center" width="20%">
				        <asp:DropDownList ID="DropDownList2" 
				                          runat="server" 
				                          DataSourceID="SqlDataSource2" 
				                          DataTextField="nome_ruolo" 
				                          DataValueField="id_ruolo" 
				                          SelectedValue='<%# Bind("id_ruolo") %>' 
				                          Font-Size="7pt"
				                          Width="99%" >
				        </asp:DropDownList>
			        </td>
			        
			        <td valign="middle" align="center" width="10%">
				        <asp:TextBox ID="nomeTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("nome") %>' 
				                     Width="95%"
				                     MaxLength='20' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatornomeTextBox" 
				                                    runat="server"
			                                        ErrorMessage="Campo obbligatorio." 
			                                        ControlToValidate="nomeTextBox" 
			                                        Display="Dynamic"
			                                        ValidationGroup="ValidGroupEdit" >
			            </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" align="center" width="10%">
				        <asp:TextBox ID="cognomeTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("cognome") %>' 
				                     Width="95%"
				                     MaxLength='50' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorcognomeTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="cognomeTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupEdit" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" align="center" width="20%">
				        <asp:TextBox ID="login_reteTextBox" 
				                     runat="server" 
				                     Text='<%# Bind("login_rete") %>'
				                     Width="95%" 
				                     MaxLength='50' >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorlogin_reteTextBox" 
				                                    runat="server"
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ControlToValidate="login_reteTextBox" 
				                                    Display="Dynamic"
				                                    ValidationGroup="ValidGroupEdit" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td valign="middle" align="right" width="10%">
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
		    
		    <ItemTemplate>
			    <tr style="">
			        <td valign="middle" width="10%">
				        <asp:Label ID="nome_utenteLabel" 
				                   runat="server" 
				                   Text='<%# Eval("nome_utente") %>' >
				        </asp:Label>
			        </td>
			        
			        <td valign="middle" width="10%">
				        <asp:Label ID="pwdLabel" 
				                   runat="server" 
				                   Text='(nascosta)' >
				        </asp:Label>
			        </td>
			        
			        <td valign="middle" width="5%" align="center">
				        <asp:CheckBox ID="attivoCheckBox" 
				                      runat="server" 
				                      Checked='<%# Eval("attivo") %>'
				                      Enabled="false" />
			        </td>
			        
			        <td valign="middle" width="20%">
				        <asp:Label ID="id_ruoloLabel" 
				                   runat="server" 
				                   Text='<%# Eval("nome_ruolo_leg") %>' >
				        </asp:Label>
			        </td>
			        
			        <td valign="middle" width="10%">
				        <asp:Label ID="nomeLabel" 
				                   runat="server" 
				                   Text='<%# Eval("nome") %>' >
				        </asp:Label>
			        </td>
			        
			        <td valign="middle" width="10%">
				        <asp:Label ID="cognomeLabel" 
				                   runat="server" 
				                   Text='<%# Eval("cognome") %>' >
				        </asp:Label>
			        </td>
			        
			        <td valign="middle" width="20%">
				        <asp:Label ID="login_reteLabel" 
				                   runat="server" 
				                   Text='<%# Eval("login_rete") %>' >
				        </asp:Label>
			        </td>
			        
			        <td width="10%" align="right">
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
		                   
		                   DeleteCommand="DELETE FROM utenti 
		                                  WHERE id_utente = @id_utente" 
		                   
		                   InsertCommand="INSERT INTO utenti (nome_utente, 
		                                                      nome, 
		                                                      cognome, 
		                                                      pwd, 
		                                                      attivo, 
		                                                      id_ruolo, 
		                                                      login_rete) 
		                                  VALUES (@nome_utente, 
		                                          @nome, 
		                                          @cognome, 
		                                          @pwd, 
		                                          @attivo, 
		                                          @id_ruolo, 
		                                          @login_rete)"
		                   
		                   SelectCommand="  SELECT r.nome_ruolo + COALESCE(' - Leg. ' + ll.num_legislatura , '') AS nome_ruolo_leg, * 
                                          FROM utenti AS u 
                                          INNER JOIN tbl_ruoli AS r 
                                            ON u.id_ruolo = r.id_ruolo 
                                              LEFT OUTER JOIN organi AS oo
                                            ON (r.id_organo = oo.id_organo)
                                          LEFT OUTER JOIN legislature AS ll
                                            ON oo.id_legislatura = ll.id_legislatura
                                          ORDER BY r.grado"
		                                  
		                   UpdateCommand="UPDATE utenti 
		                                  SET nome_utente = @nome_utente, 
		                                      nome = @nome, 
		                                      cognome = @cognome, 
		                                      pwd = @pwd, 
		                                      attivo = @attivo, 
		                                      id_ruolo = @id_ruolo, 
		                                      login_rete = @login_rete 
		                                  WHERE id_utente = @id_utente" >
		    
		    <DeleteParameters>
			    <asp:Parameter Name="id_utente" Type="Int32" />
		    </DeleteParameters>
		    
		    <UpdateParameters>
			    <asp:Parameter Name="nome_utente" Type="String" />
			    <asp:Parameter Name="nome" Type="String" />
			    <asp:Parameter Name="cognome" Type="String" />
			    <asp:Parameter Name="pwd" Type="String" />
			    <asp:Parameter Name="attivo" Type="Boolean" />
			    <asp:Parameter Name="id_ruolo" Type="Int32" />
			    <asp:Parameter Name="login_rete" Type="String" />
			    <asp:Parameter Name="id_utente" Type="Int32" />
		    </UpdateParameters>
		    
		    <InsertParameters>
			    <asp:Parameter Name="nome_utente" Type="String" />
			    <asp:Parameter Name="nome" Type="String" />
			    <asp:Parameter Name="cognome" Type="String" />
			    <asp:Parameter Name="pwd" Type="String" />
			    <asp:Parameter Name="attivo" Type="Boolean" />
			    <asp:Parameter Name="id_ruolo" Type="Int32" />
			    <asp:Parameter Name="login_rete" Type="String" />
		    </InsertParameters>
		</asp:SqlDataSource>
		
		<asp:SqlDataSource ID="SqlDataSource2" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT tr.id_ruolo, 
	                                             tr.nome_ruolo + COALESCE(' - Leg. ' + ll.num_legislatura , '') AS nome_ruolo
                                          FROM tbl_ruoli AS tr 
                                          LEFT OUTER JOIN organi AS oo
                                            ON (tr.id_organo = oo.id_organo AND oo.deleted = 0)
                                          LEFT OUTER JOIN legislature AS ll
                                            ON oo.id_legislatura = ll.id_legislatura
                                          ORDER BY tr.grado ASC, ll.durata_legislatura_da DESC" >
		</asp:SqlDataSource>
	    </ContentTemplate>
	</asp:UpdatePanel>
	
	<br />
	<br />
	<hr />
	<b>Gestione ruoli relativi a commissioni specifiche</b>
	<br />
	<br />
	
	<asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
	    <ContentTemplate>
		<asp:ListView ID="ListView2" 
		              runat="server" 
		              DataKeyNames="id_ruolo" 
		              DataSourceID="SqlDataSource3"
		              InsertItemPosition="LastItem" 
		              
		              OnItemInserting="ListView2_ItemInserting" 
		              oniteminserted="ListView2_ItemInserted">
		              
		    <LayoutTemplate>
			    <table runat="server" width="100%">
			    <tr runat="server">
				    <td runat="server">
				        <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
					    <tr runat="server">
					        <th runat="server">Nome Ruolo</th>
					        <%--<th runat="server">Grado</th>--%>
					        <th runat="server">Organo di riferimento</th>
					        <th id="Th2" runat="server"></th>
					    </tr>
					    
					    <tr id="itemPlaceholder" runat="server"></tr>
				        </table>
				    </td>
			    </tr>
			    </table>
		    </LayoutTemplate>
		    
		    <EmptyDataTemplate>
			    <table id="Table2" runat="server" style="">
			        <tr>
				        <td>
				            Non è stato restituito alcun dato.
				        </td>
			        </tr>
			    </table>
		    </EmptyDataTemplate>
		    
		    <InsertItemTemplate>
			    <tr style="">
			        <td width="30%" align="center" valign="middle">
				        <asp:TextBox ID="TextBoxNomeRuoloInsert" 
				                     runat="server" 
				                     Text='<%# Bind("nome_ruolo") %>'
				                     Width="95%" >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorNomeRuoloInsert" 
				                                    ControlToValidate="TextBoxNomeRuoloInsert"
				                                    runat="server" 
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupRuoloInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <%--<td width="10%" align="center" valign="middle">
				        <asp:TextBox ID="txt_Grado_Insert" 
				                     runat="server" 
				                     Text='<%# Bind("grado") %>'
				                     Width="95%" >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidator_txt_Grado_Insert" 
				                                    runat="server" 
				                                    ControlToValidate="txt_Grado_Insert"
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupRuoloInsert" >
				        </asp:RequiredFieldValidator>
				        
				        <asp:RegularExpressionValidator ID="REV_txt_Grado_Insert" 
				                                        runat="server" 
				                                        ControlToValidate="txt_Grado_Insert"
				                                        Display="Dynamic" 
				                                        ErrorMessage="Solo numeri." 
				                                        ValidationExpression="(\d)"
				                                        ValidationGroup="ValidGroupRuoloInsert" >
				        </asp:RegularExpressionValidator>
			        </td>--%>
			        
			        <td width="60%" align="center" valign="middle">
				        <asp:DropDownList ID="DropDownListOrganoInsert" 
			                              runat="server" 
			                              DataSourceID="SqlDataSourceOrganoInsert"
			                              DataTextField="nome_organo" 
			                              DataValueField="id_organo" 
			                              Width="99%" 
			                              AppendDataBoundItems="true">
				            <asp:ListItem Text="(seleziona)" Value="" ></asp:ListItem>
				        </asp:DropDownList>
				        
				        <asp:SqlDataSource ID="SqlDataSourceOrganoInsert" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                           
				                           SelectCommand="SELECT oo.id_organo, 
                                                                 num_legislatura + ' - ' + oo.nome_organo AS nome_organo
                                                          FROM organi AS oo
                                                          INNER JOIN legislature AS ll
                                                            ON oo.id_legislatura = ll.id_legislatura
                                                          WHERE oo.deleted = 0
                                                          ORDER BY ll.durata_legislatura_da DESC, oo.nome_organo" >
				        </asp:SqlDataSource>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListOrganoInsert" 
				                                    ControlToValidate="DropDownListOrganoInsert"
				                                    runat="server" 
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupRuoloInsert" >
				        </asp:RequiredFieldValidator>
			        </td>
			        
			        <td width="10%" align="right" valign="middle">
				        <asp:Button ID="InsertButton" 
				                    runat="server" 
				                    CommandName="Insert" 
				                    Text="Inserisci"
				                    CssClass="button" 
				                    ValidationGroup="ValidGroupRuoloInsert" />
				                    
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
			        <td width="30%" align="center" valign="middle">
				        <asp:TextBox ID="TextBoxNomeRuoloEdit" 
				                     runat="server" 
				                     Text='<%# Bind("nome_ruolo") %>'
				                     Width="95%" >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorNomeRuoloEdit" 
				                                    runat="server" 
				                                    ControlToValidate="TextBoxNomeRuoloEdit"
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupRuoloEdit" >
				        </asp:RequiredFieldValidator>
			        </td>
    			    
    			    <%--<td width="10%" align="center" valign="middle">
				        <asp:TextBox ID="txt_Grado_Edit" 
				                     runat="server" 
				                     Text='<%# Bind("grado") %>'
				                     Width="95%" >
				        </asp:TextBox>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidator_txt_Grado_Edit" 
				                                    runat="server" 
				                                    ControlToValidate="txt_Grado_Edit"
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupRuoloEdit" >
				        </asp:RequiredFieldValidator>
				        
				        <asp:RegularExpressionValidator ID="REV_txt_Grado_Edit" 
				                                        runat="server" 
				                                        ControlToValidate="txt_Grado_Edit"
				                                        Display="Dynamic" 
				                                        ErrorMessage="Solo numeri." 
				                                        ValidationExpression="(\d)"
				                                        ValidationGroup="ValidGroupRuoloEdit" >
				        </asp:RegularExpressionValidator>
			        </td>--%>
    			    
			        <td width="60%" align="center" valign="middle">
				        <asp:DropDownList ID="DropDownListOrganoEdit" 
				                          runat="server" 
				                          DataSourceID="SqlDataSourceOrganoEdit"
				                          DataTextField="nome_organo" 
				                          DataValueField="id_organo" 
				                          Width="99%" 
				                          SelectedValue='<%# Bind("id_organo") %>'>
				            <asp:ListItem Text="(seleziona)" Value="" ></asp:ListItem>
				        </asp:DropDownList>
				        
				        <asp:SqlDataSource ID="SqlDataSourceOrganoEdit" 
				                           runat="server" 
				                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                           
				                           SelectCommand="SELECT oo.id_organo, 
                                                                 num_legislatura + ' - ' + oo.nome_organo AS nome_organo
                                                          FROM organi AS oo
                                                          INNER JOIN legislature AS ll
                                                            ON oo.id_legislatura = ll.id_legislatura
                                                          WHERE oo.deleted = 0
                                                          ORDER BY ll.durata_legislatura_da DESC, oo.nome_organo" >
				        </asp:SqlDataSource>
				        
				        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListOrganoEdit" 
				                                    ControlToValidate="DropDownListOrganoEdit"
				                                    runat="server" 
				                                    Display="Dynamic" 
				                                    ErrorMessage="Campo obbligatorio." 
				                                    ValidationGroup="ValidGroupRuoloEdit" >
				        </asp:RequiredFieldValidator>
			        </td>
    			    
			        <td width="10%" align="right" valign="middle">
				        <asp:Button ID="UpdateButton" 
				                    runat="server" 
				                    CommandName="Update" 
				                    Text="Aggiorna"
				                    CssClass="button" 
				                    ValidationGroup="ValidGroupRuoloEdit" />
				                    
				        <asp:Button ID="CancelButton" 
				                    runat="server" 
				                    CommandName="Cancel" 
				                    Text="Annulla"
				                    CssClass="button" />
			        </td>
			    </tr>
		    </EditItemTemplate>
		    
		    <ItemTemplate>
			    <tr style="">
			        <td width="30%" valign="middle">
				        <asp:Label ID="nome_ruoloLabel" 
				                   runat="server" 
				                   Text='<%# Eval("nome_ruolo") %>' >
				        </asp:Label>
			        </td>
    			    
			        <td width="60%" valign="middle">
				        <asp:Label ID="id_organoLabel" 
				                   runat="server" 
				                   Text='<%# Eval("nome_organo") %>' >
				        </asp:Label>
			        </td>
    			    
			        <td width="10%" align="right" valign="middle">
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
		
		<asp:SqlDataSource ID="SqlDataSource3" 
		                   runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                   
		                   SelectCommand="SELECT rr.*, 
                                          num_legislatura + ' - ' + oo.nome_organo AS nome_organo        
                                          FROM tbl_ruoli AS rr 
                                          INNER JOIN organi AS oo 
                                          ON rr.id_organo = oo.id_organo
                                          INNER JOIN legislature AS ll
                                          ON oo.id_legislatura = ll.id_legislatura
			                              WHERE grado = @grado"
		                   
		                   InsertCommand="INSERT INTO tbl_ruoli (nome_ruolo, 
		                                                         grado, 
		                                                         id_organo) 
		                                  VALUES (@nome_ruolo, 
		                                          5, 
		                                          @id_organo)"
		                   
		                   UpdateCommand="UPDATE tbl_ruoli 
		                                  SET nome_ruolo = @nome_ruolo, 
		                                      id_organo = @id_organo 
		                                  WHERE id_ruolo = @id_ruolo"
		                   
		                   DeleteCommand="DELETE FROM tbl_ruoli 
		                                  WHERE id_ruolo = @id_ruolo" >
		    <SelectParameters>
			    <asp:Parameter DefaultValue="5" Name="grado" Type="Int32" />
		    </SelectParameters>
		    
		    <DeleteParameters>
			    <asp:Parameter Name="id_ruolo" Type="Int32" />
		    </DeleteParameters>
		    
		    <UpdateParameters>
			    <asp:Parameter Name="nome_ruolo" Type="String" />
			    <asp:Parameter Name="id_organo" Type="Int32" />
			    <asp:Parameter Name="id_ruolo" Type="Int32" />
		    </UpdateParameters>
		    
		    <InsertParameters>
			    <asp:Parameter Name="nome_ruolo" Type="String" />
			    <asp:Parameter Name="id_organo" Type="Int32" />
		    </InsertParameters>
		</asp:SqlDataSource>
	    </ContentTemplate>
	</asp:UpdatePanel>
    </div>
</asp:Content>