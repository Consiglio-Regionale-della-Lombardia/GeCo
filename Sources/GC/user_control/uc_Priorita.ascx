<%@ Control Language="C#" AutoEventWireup="true" CodeFile="uc_Priorita.ascx.cs" Inherits="uc_Priorita" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<asp:Panel ID="PanelPriorita" 
            runat="server" 
            Width="1000px" 
            BackColor="White" 
            BorderColor="DarkSeaGreen"
            BorderWidth="2px" 
            Style="display: none;">
    <asp:Panel runat="server" id="dragPoint" style="cursor:move;">
        <div align="center">
            <br />                                    
            <h3>GESTIONE PRIORITA'</h3>
            <br />
        </div>
    </asp:Panel>
                                                              
    <asp:UpdatePanel ID="UpdatePanelPriorita" runat="server">
        <ContentTemplate>
            <asp:ListView ID="ListViewPriorita" runat="server" DataKeyNames="id_rec" DataSourceID="SqlDataSourcePriorita"
                InsertItemPosition="LastItem" OnItemInserting="ListViewPriorita_ItemInserting"
                OnItemInserted="ListViewPriorita_ItemInserted" OnItemUpdating="ListViewPriorita_ItemUpdating"
                OnItemUpdated="ListViewPriorita_ItemUpdated" OnItemDeleted="ListViewPriorita_ItemDeleted">
                <LayoutTemplate>
                    <table id="Table1" runat="server" width="95%">
                        <tr id="Tr1" runat="server">
                            <td id="Td1" runat="server">
                                <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
                                    <tr id="Tr2" runat="server">
                                        <th id="Th1" runat="server">
                                            Tipo Priorità
                                        </th>
                                        <th id="Th2" runat="server">
                                            Data Inizio
                                        </th>
                                        <th id="Th3" runat="server">
                                            Data Fine
                                        </th>
                                        <th id="Th4" runat="server">
                                        </th>
                                    </tr>
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="Tr3" runat="server">
                            <td id="Td2" runat="server" style="">
                            </td>
                        </tr>
                    </table>
                </LayoutTemplate>                                  
                <InsertItemTemplate>
                    <tr style="">
                        <td width="160" valign="top" align="center">
                            <asp:DropDownList ID="DropDownListTipoPrioritaInsert" runat="server" DataSourceID="SqlDataSourceTipoPriorita"
                                DataTextField="descrizione" DataValueField="id_tipo_commissione_priorita" Width="150px">
                            </asp:DropDownList>
                        </td>                                                    
                        <td width="100" valign="top">
                            <asp:TextBox ID="dt_Priorita_Data_Inizio" runat="server" Width="70px" />
                            <img alt="calendar" src="../img/calendar_month.png" id="Image1" runat="server" />
                            <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dt_Priorita_Data_Inizio"
                                PopupButtonID="Image1" Format="dd/MM/yyyy">
                            </cc1:CalendarExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorResidenzaSince" runat="server"
                                ControlToValidate="dt_Priorita_Data_Inizio" ErrorMessage="Campo obbligatorio." Display="Dynamic"
                                ValidationGroup="PrioritaInsertGroup" />
                            <asp:RegularExpressionValidator ID="RegularExpressionValidator_dt_Priorita_Data_Inizio" ControlToValidate="dt_Priorita_Data_Inizio"
                                runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                ValidationGroup="PrioritaInsertGroup" />
                        </td>
                                                    
                        <td width="100" valign="top">
                            <asp:TextBox ID="dt_Priorita_Data_Fine" runat="server" Width="70px" />
                            <img alt="calendar" src="../img/calendar_month.png" id="Image2" runat="server" />
                            <cc1:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="dt_Priorita_Data_Fine"
                                PopupButtonID="Image2" Format="dd/MM/yyyy">
                            </cc1:CalendarExtender>
                            <asp:RegularExpressionValidator ID="RequiredFieldValidator_dt_Priorita_Data_Fineo" ControlToValidate="dt_Priorita_Data_Fine"
                                runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                ValidationGroup="PrioritaInsertGroup" />
                        </td>
                        <td width="23%" valign="top" align="center">
                            <asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Inserisci"
                                CssClass="button" ValidationGroup="PrioritaInsertGroup" />
                            <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancella"
                                CssClass="button" CausesValidation="false" />
                        </td>
                    </tr>
                </InsertItemTemplate>
                <EditItemTemplate>
                    <tr style="">
                        <td width="160" valign="top" align="center">
                            <asp:DropDownList ID="DropDownListTipoPrioritaEdit" runat="server" SelectedValue='<%# Bind("id_tipo_commissione_priorita") %>'
                                DataSourceID="SqlDataSourceTipoPriorita" DataTextField="descrizione" DataValueField="id_tipo_commissione_priorita"
                                Width="150px">
                            </asp:DropDownList>
                        </td>
                        <td valign="top">
                            <asp:TextBox ID="dt_Priorita_Data_Inizio_E" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>'
                                Width="70px" MaxLength="10" />
                            <img alt="calendar" src="../img/calendar_month.png" id="Image3" runat="server" />
                            <cc1:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="dt_Priorita_Data_Inizio_E"
                                PopupButtonID="Image3" Format="dd/MM/yyyy">
                            </cc1:CalendarExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorDtResidenzaSince" runat="server"
                                ControlToValidate="dt_Priorita_Data_Inizio_E" ErrorMessage="Campo obbligatorio." Display="Dynamic"
                                ValidationGroup="PrioritaEditGroup" />
                            <asp:RegularExpressionValidator ID="RegularExpressionDtResidenzaSince" ControlToValidate="dt_Priorita_Data_Inizio_E"
                                runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                ValidationGroup="PrioritaEditGroup" />
                        </td>
                        <td valign="top">
                            <asp:TextBox ID="dt_Priorita_Data_Fine_E" runat="server" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>'
                                Width="70px" MaxLength="10" />
                            <img alt="calendar" src="../img/calendar_month.png" id="Image4" runat="server" />
                            <cc1:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="dt_Priorita_Data_Fine_E"
                                PopupButtonID="Image4" Format="dd/MM/yyyy">
                            </cc1:CalendarExtender>
                            <asp:RegularExpressionValidator ID="RegularExpressionDtResidenzaTo" ControlToValidate="dt_Priorita_Data_Fine_E"
                                runat="server" ErrorMessage="Ammessi solo valori GG/MM/AAAA." Display="Dynamic"
                                ValidationExpression="(((0[1-9]|[12][0-9]|3[01])([/])(0[13578]|10|12)([/])(\d{4}))|(([0][1-9]|[12][0-9]|30)([/])(0[469]|11)([/])(\d{4}))|((0[1-9]|1[0-9]|2[0-8])([/])(02)([/])(\d{4}))|((29)(\.|-|\/)(02)([/])([02468][048]00))|((29)([/])(02)([/])([13579][26]00))|((29)([/])(02)([/])([0-9][0-9][0][48]))|((29)([/])(02)([/])([0-9][0-9][2468][048]))|((29)([/])(02)([/])([0-9][0-9][13579][26])))"
                                ValidationGroup="PrioritaEditGroup" />
                        </td>
                        <td width="23%" valign="top" align="center">
                            <asp:Button ID="UpdateButton" runat="server" CommandName="Update" Text="Aggiorna"
                                CssClass="button" ValidationGroup="PrioritaEditGroup" />
                            <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Annulla"
                                CssClass="button" CausesValidation="false" />
                        </td>
                    </tr>
                </EditItemTemplate>
                <ItemTemplate>
                    <tr style="">
                        <td>
                            <asp:Label ID="TipoPriorita_Label" runat="server" Text='<%# Eval("descrizione") %>' />
                        </td>
                        <td>
                            <asp:Label ID="data_inizio_Label" runat="server" Text='<%# Eval("data_inizio", "{0:dd/MM/yyyy}") %>' />
                        </td>
                        <td>
                            <asp:Label ID="data_fine_Label" runat="server" Text='<%# Eval("data_fine", "{0:dd/MM/yyyy}") %>' />
                        </td>
                        <td width="23%" valign="top" align="center">
                            <asp:Button ID="EditButton" runat="server" CommandName="Edit" Text="Modifica" CssClass="button"
                                CausesValidation="false" />
                            <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" Text="Elimina"
                                CssClass="button" CausesValidation="false" OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                        </td>
                    </tr>
                </ItemTemplate>
                <EmptyDataTemplate>
                    <table id="Table2" runat="server" style="">
                        <tr>
                            <td>
                                Non è stato restituito alcun dato.
                            </td>
                        </tr>
                    </table>
                </EmptyDataTemplate>
            </asp:ListView>
            <asp:SqlDataSource ID="SqlDataSourceResidenza" 
                                runat="server" 
                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                           
                                DeleteCommand="DELETE FROM join_persona_residenza 
			                                    WHERE id_rec = @id_rec" 
			                                          
			                    InsertCommand="INSERT INTO join_persona_residenza (id_persona, 
			                                                                        indirizzo_residenza, 
			                                                                        id_comune_residenza, 
			                                                                        data_da, 
			                                                                        data_a, 
			                                                                        residenza_attuale, 
			                                                                        cap) 
			                                    VALUES (@id_persona, 
			                                            @indirizzo_residenza, 
			                                            @id_comune, 
			                                            @data_da, 
			                                            @data_a, 
			                                            @residenza_attuale, 
			                                            @cap); 
			                                    SELECT @id_rec = SCOPE_IDENTITY();" 
			                                          
			                    SelectCommand="SELECT j.*, 
		                                                c.comune + ' (' + c.provincia + ')' AS nome_comune 
		                                        FROM join_persona_residenza AS j 
		                                        INNER JOIN tbl_comuni AS c 
		                                            ON j.id_comune_residenza = c.id_comune 
		                                        WHERE id_persona = @id_persona" 
			                                          
			                    UpdateCommand="UPDATE join_persona_residenza 
			                                    SET id_persona = @id_persona, 
			                                        indirizzo_residenza = @indirizzo_residenza, 
			                                        id_comune_residenza = @id_comune, 
			                                        data_da = @data_da, 
			                                        data_a = @data_a, 
			                                        residenza_attuale = @residenza_attuale, 
			                                        cap = @cap 
			                                    WHERE id_rec = @id_rec" 
        			                                          
			                    OnInserting="SqlDataSourcePriorita_Inserting"
                                OnInserted="SqlDataSourcePriorita_Inserted" >
                <SelectParameters>
                    <asp:SessionParameter Name="id_persona" SessionField="id_persona" Type="Int32" />
                </SelectParameters>
                                            
                <DeleteParameters>
                    <asp:Parameter Name="id_rec" Type="Int32" />
                </DeleteParameters>
                                            
                <UpdateParameters>
                    <%--<asp:Parameter Name="id_residenza" Type="Int32" />--%>
                    <asp:Parameter Name="id_persona" Type="Int32" />
                    <asp:Parameter Name="indirizzo_residenza" Type="String" />
                    <asp:Parameter Name="id_comune" Type="String" />
                    <asp:Parameter Name="data_da" Type="DateTime" />
                    <asp:Parameter Name="data_a" Type="DateTime" />
                    <asp:Parameter Name="residenza_attuale" Type="String" />
                    <asp:Parameter Name="cap" Type="String" />
                    <asp:Parameter Name="id_rec" Type="Int32" />
                </UpdateParameters>
                                            
                <InsertParameters>
                    <%--<asp:Parameter Name="id_residenza" Type="Int32" />--%>
                    <asp:Parameter Name="id_persona" Type="Int32" />
                    <asp:Parameter Name="indirizzo_residenza" Type="String" />
                    <asp:Parameter Name="id_comune" Type="String" />
                    <asp:Parameter Name="data_da" Type="DateTime" />
                    <asp:Parameter Name="data_a" Type="DateTime" />
                    <asp:Parameter Name="residenza_attuale" Type="String" />
                    <asp:Parameter Name="cap" Type="String" />
                    <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                </InsertParameters>
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSourceTipoPriorita" 
                                runat="server" 
                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                           
                                SelectCommand="SELECT * 
                                                FROM [tipo_commissione_priorita] 
                                                ORDER BY [id_tipo_commissione_priorita]">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSourcePriorita" 
                                runat="server" 
                                ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                                       
                                DeleteCommand="DELETE FROM [join_persona_organo_carica_priorita] 
                                                WHERE [id_rec] = @id_rec"
   
                                InsertCommand="INSERT INTO [join_persona_organo_carica_priorita] ([id_join_persona_organo_carica], 
                                                                                                [data_inizio], 
                                                                                                [data_fine],
                                                                                                [id_tipo_commissione_priorita]) 
                                                VALUES (@id_join_persona_organo_carica, 
                                                        @data_inizio, 
                                                        @data_fine,
                                                        @id_tipo_commissione_priorita); 
                                                SELECT @id_rec = SCOPE_IDENTITY();"
                                                           
                                SelectCommand="SELECT * 
                                                FROM join_persona_organo_carica_priorita a 
                                                INNER JOIN tipo_commissione_priorita b 
                                                ON a.id_tipo_commissione_priorita = b.id_tipo_commissione_priorita 
                                                WHERE id_join_persona_organo_carica = @id_join_persona_organo_carica"
                                                           
                                UpdateCommand="UPDATE [join_persona_organo_carica_priorita] 
                                                SET [id_join_persona_organo_carica] = @id_join_persona_organo_carica, 
                                                    [data_inizio] = @data_inizio, 
                                                    [data_fine] = @data_fine,
                                                    [id_tipo_commissione_priorita] = @id_tipo_commissione_priorita 
                                                WHERE [id_rec] = @id_rec"

					                                                      
                                OnInserted="SqlDataSourcePriorita_Inserted">

				        
                <SelectParameters>
                    <asp:ControlParameter ControlID="GridView1" 
				                        Name="id_join_persona_organo_carica" 
				                        PropertyName="SelectedValue"
					                    Type="Int32" />

                </SelectParameters>
                                            
                <DeleteParameters>
                    <asp:Parameter Name="id_rec" Type="Int32" />
                </DeleteParameters>
                                            
                <UpdateParameters>
                    <asp:Parameter Name="id_join_persona_organo_carica" Type="Int32" />
                    <asp:Parameter Name="data_inizio" Type="DateTime" />
                    <asp:Parameter Name="data_fine" Type="DateTime" />
                    <asp:Parameter Name="id_tipo_commissione_priorita" Type="Int32" />
                    <asp:Parameter Name="id_rec" Type="Int32" />
                </UpdateParameters>
                                            
                <InsertParameters>
                    <asp:Parameter Name="id_join_persona_organo_carica" Type="Int32" />
                    <asp:Parameter Name="data_inizio" Type="DateTime" />
                    <asp:Parameter Name="data_fine" Type="DateTime" />
                    <asp:Parameter Name="id_tipo_commissione_priorita" Type="Int32" />
                    <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
                </InsertParameters>
            </asp:SqlDataSource>

        </ContentTemplate>
    </asp:UpdatePanel>
    <div align="center">
        <br />
        <asp:Button ID="ButtonChiudiPriorita" runat="server" Text="Chiudi" CssClass="button" OnClick="ButtonChiudiPriorita_Click" />
        <br />
        <br />
    </div>
    <cc1:ModalPopupExtender ID="ModalPopupExtenderPriorita" BehaviorID="ModalPopup2"
        runat="server" PopupControlID="PanelPriorita" BackgroundCssClass="modalBackground"
        DropShadow="true" Drag="true" PopupDragHandleControlID="dragPoint" TargetControlID="ButtonPrioritaFake">
    </cc1:ModalPopupExtender>
			                        
	<asp:Button ID="ButtonPrioritaFake" runat="server" Text="" Style="display: none;" />

</asp:Panel>

