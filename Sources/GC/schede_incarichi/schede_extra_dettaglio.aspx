<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="schede_extra_dettaglio.aspx.cs" 
         Inherits="schede_extra_dettaglio" 
         Title="Incarichi Extra Istituzionali > Scheda Dettaglio" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
<tr>
    <td>
        <table width="100%" cellspacing="5" cellpadding="10" >
        <tr>
            <td class="singleborder" valign="top" width="100%" >
                <asp:FormView ID="FormView1" 
                              runat="server" 
                              DataKeyNames="id_scheda" 
                              DataSourceID="SqlDataSource1" 
                              Width="99%" 
                              
	                          OnItemDeleted="FormView1_ItemDeleted" 
	                          OnItemInserting="FormView1_ItemInserting" 
	                          OnItemUpdating="FormView1_ItemUpdating"  
                              OnModeChanged="FormView1_ModeChanged" >
                	
                    <%--ITEM--%>
                    <ItemTemplate>
		                <div>
                            <table style="width:100%;" border="0" cellpadding="0" cellspacing="0" >
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_item_organo" 
                                               runat="server" 
                                               Text="ORGANO:(???)" 
                                               Font-Bold="True">
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_item_legislatura" 
                                               runat="server" 
                                               Text="LEGISLATURA:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_item_legislatura_2" 
                                               runat="server" 
                                               Text='<%# Eval("legislatura") %>' >
                                    </asp:Label>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--consigliere + gruppo--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_item_consigliere" 
                                               runat="server" 
                                               Text="CONSIGLIERE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_item_consigliere_2" 
                                               runat="server" 
                                               Text='<%# Eval("consigliere") %>' >
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_item_gruppo_consiliare" 
                                               runat="server" 
                                               Text="GRUPPO CONSILIARE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_item_gruppo_consiliare_2" 
                                               runat="server" 
                                               Text='<%# Eval("gruppo_consiliare") %>' >
                                    </asp:Label>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--data_procl + dichiarazione del incarichi--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_item_data_proclamazione" 
                                               runat="server" 
                                               Text="DATA PROCLAMAZIONE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_item_data_proclamazione_2" 
                                               runat="server" 
                                               Text='<%# Eval("data_proclamazione", "{0:dd/MM/yyyy}") %>' >
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_item_dichiarazione_del" 
                                               runat="server" 
                                               Text="DICHIARAZIONE DEL:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_item_dichiarazione_del_2" 
                                               runat="server" 
                                               Text='<%# Eval("data", "{0:dd/MM/yyyy}") %>' >
                                    </asp:Label>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--lista incarichi--%>
                            <tr>
                                <td colspan="2" align="center">
                                    <asp:GridView ID="GridView_Item_Incarichi" 
                                                  runat="server"
                                                  AllowPaging="false"
                                                  AllowSorting="false"
                                                  AutoGenerateColumns="false"
                                                  CssClass="tab_gen" 
                                                  GridLines="None" 
		                                          DataKeyNames="id_incarico"
                                                  DataSourceID="SQLDataSource_Incarichi" >
                                        
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen" >
			                                <tr>
				                                <th align="center">
				                                    Nessun incarico associato alla scheda.
				                                </th>
			                                </tr>
			                                </table>
                                        </EmptyDataTemplate>
                                        
                                        <Columns>
                                            <asp:BoundField HeaderText="INCARICO" 
                                                            DataField="nome_incarico" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                                            
                                            <asp:BoundField HeaderText="RIFERIMENTI NORMATIVI" 
                                                            DataField="riferimenti_normativi" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                                            
                                            <asp:BoundField HeaderText="DATA CESSAZIONE" 
                                                            DataField="data_cessazione" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                                            
                                            <asp:BoundField HeaderText="NOTE ISTRUTTORIE" 
                                                            DataField="note_istruttorie" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                        </Columns>
                                    </asp:GridView>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--indicazioni gde--%>
                            <tr>
                                <td colspan="2" align="left">
                                    <asp:Label ID="lbl_item_indicazioni_gde" 
                                               runat="server" 
                                               Text="INDICAZIONI GDE:" 
                                               Font-Bold="true" >
                                    </asp:Label>
                                    
                                    <br />
                                    
                                    <asp:Label ID="lbl_item_indicazioni_gde_2" 
                                               runat="server" 
                                               Text='<%# Eval("indicazioni_gde") %>'>
                                    </asp:Label>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--indicazioni segreteria--%>
                            <tr>
                                <td colspan="2" align="left">
                                    <asp:Label ID="lbl_item_indicazioni_segreteria" 
                                               runat="server" 
                                               Text="INDICAZIONI SEGRETERIA:" 
                                               Font-Bold="true" >
                                    </asp:Label>
                                    
                                    <br />
                                    
                                    <asp:Label ID="lbl_item_indicazioni_segreteria_2" 
                                               runat="server" 
                                               Text='<%# Eval("indicazioni_seg") %>' >
                                    </asp:Label>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--crudel--%>
                            <tr>
                                <td colspan="2" align="center" >
                                    <asp:Button ID="btn_item_edit" 
                                                runat="server" 
                                                CausesValidation="False" 
                                                CommandName="Edit" 
                                                CssClass="button" 
                                                Text="Modifica" 
                                                Visible='<%# ((role == 1) || ((role == 5) && (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni))) ? true : false %>' />
                                    
                                    <asp:Button ID="btn_item_delete"
                                                runat="server" 
                                                CausesValidation="False" 
                                                CommandName="Delete" 
                                                CssClass="button" 
                                                Text="Elimina" 
                                                Visible='<%# ((role == 1) || ((role == 5) && (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni))) ? true : false %>' 
                                                
                                                OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
                                </td>
                            </tr>
                            </table>
                        </div>
                    </ItemTemplate>
        		    
                    <%--EDIT--%>
                    <EditItemTemplate>
                        <div>
                            <table style="width:100%;" border="0" cellpadding="0" cellspacing="0" >
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_edit_organo" 
                                               runat="server" 
                                               Text="ORGANO:(???)" 
                                               Font-Bold="True">
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_edit_legislatura" 
                                               runat="server" 
                                               Text="LEGISLATURA:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_edit_legislatura_2" 
                                               runat="server" 
                                               Text='<%# Eval("legislatura") %>' >
                                    </asp:Label>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--consigliere + gruppo--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_edit_consigliere" 
                                               runat="server" 
                                               Text="CONSIGLIERE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="txt_edit_consigliere" 
                                               runat="server" 
                                               Text='<%# Eval("consigliere") %>' >
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_edit_gruppo_consiliare" 
                                               runat="server" 
                                               Text="GRUPPO CONSILIARE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:DropDownList ID="ddl_edit_gruppo_consiliare" 
                                                      runat="server" 
                                                      AppendDataBoundItems="true"
                                                      DataSourceID="SQLDataSource_GruppiConsiliari"
                                                      DataTextField="nome_gruppo" 
                                                      DataValueField="id_gruppo"
                                                      Width="200px" >
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--data_procl + dichiarazione del incarichi--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_edit_data_proclamazione" 
                                               runat="server" 
                                               Text="DATA PROCLAMAZIONE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_edit_data_proclamazione_2" 
                                               runat="server" 
                                               Text='<%# Eval("data_proclamazione") %>' >
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_edit_dichiarazione_del" 
                                               runat="server" 
                                               Text="DICHIARAZIONE DEL:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_edit_dichiarazione_del_2" 
                                               runat="server" 
                                               Text='<%# Eval("data") %>' >
                                    </asp:Label>
                                    
                                    <%--<asp:TextBox ID="txt_edit_dichiarazione_del" 
                                                 runat="server" 
                                                 Text='<%# Bind("data") %>' 
                                                 Width="80px" >
                                    </asp:TextBox>--%>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--lista incarichi--%>
                            <tr>
                                <td colspan="2" align="center">
                                    <asp:GridView ID="GridView_Edit_Incarichi" 
                                                  runat="server"
                                                  AllowPaging="false"
                                                  AllowSorting="false" 
                                                  AutoGenerateColumns="false"
                                                  CssClass="tab_gen" 
                                                  GridLines="None" 
		                                          DataKeyNames="id_incarico"
                                                  DataSourceID="SQLDataSource_Incarichi" >
                                        
                                        <EmptyDataTemplate>
                                            <table width="100%" class="tab_gen" >
			                                <tr>
				                                <th align="center">
				                                    Nessun incarico associato alla scheda.
				                                </th>
			                                </tr>
			                                </table>
                                        </EmptyDataTemplate>
                                        
                                        <Columns>
                                            <asp:BoundField HeaderText="INCARICO" 
                                                            DataField="nome_incarico" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                                            
                                            <asp:BoundField HeaderText="RIFERIMENTI NORMATIVI" 
                                                            DataField="riferimenti_normativi" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                                            
                                            <asp:BoundField HeaderText="DATA CESSAZIONE" 
                                                            DataField="data_cessazione" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                                            
                                            <asp:BoundField HeaderText="NOTE ISTRUTTORIE" 
                                                            DataField="note_istruttorie" 
                                                            ItemStyle-HorizontalAlign="Center" />
                                        </Columns>
                                    </asp:GridView>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--indicazioni gde--%>
                            <tr>
                                <td colspan="2" align="left">
                                    <asp:Label ID="lbl_item_indicazioni_gde" 
                                               runat="server" 
                                               Text="INDICAZIONI GDE:" 
                                               Font-Bold="true" >
                                    </asp:Label>
                                    
                                    <br />
                                    
                                    <asp:TextBox ID="txt_item_indicazioni_gde" 
                                                 runat="server" 
                                                 TextMode="MultiLine" 
                                                 Rows="4"
                                                 Text='<%# Bind("indicazioni_gde") %>' 
                                                 Width="99%" >
                                    </asp:TextBox>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--indicazioni segreteria--%>
                            <tr>
                                <td colspan="2" align="left">
                                    <asp:Label ID="lbl_item_indicazioni_segreteria" 
                                               runat="server" 
                                               Text="INDICAZIONI SEGRETERIA:" 
                                               Font-Bold="true" >
                                    </asp:Label>
                                    
                                    <br />
                                    
                                    <asp:TextBox ID="txt_item_indicazioni_segreteria" 
                                                 runat="server" 
                                                 TextMode="MultiLine" 
                                                 Rows="4"
                                                 Text='<%# Bind("indicazioni_seg") %>' 
                                                 Width="99%" >
                                    </asp:TextBox>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--crudel--%>
                            <tr>
                                <td colspan="2" align="center" >
                                    <asp:Button ID="btn_edit_update" 
                                                runat="server" 
                                                CausesValidation="False" 
                                                CommandName="Update" 
                                                CssClass="button" 
                                                Text="Aggiorna" 
                                                Visible='<%# ((role == 1) || ((role == 5) && (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni))) ? true : false %>' />
                                    
                                    <asp:Button ID="btn_edit_cancel"
                                                runat="server" 
                                                CausesValidation="False" 
                                                CommandName="Cancel" 
                                                CssClass="button" 
                                                Text="Annulla" />
                                </td>
                            </tr>
                            </table>
                        </div>
                    </EditItemTemplate>
                    
                    <%--INSERT--%>
                    <InsertItemTemplate>
                        <div>
                            <table style="width:100%;" border="0" cellpadding="0" cellspacing="0" >
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_insert_organo" 
                                               runat="server" 
                                               Text="ORGANO:(???)" 
                                               Font-Bold="True">
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_insert_legislatura" 
                                               runat="server" 
                                               Text="LEGISLATURA:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:DropDownList ID="ddl_insert_legislatura" 
                                                      runat="server" 
                                                      AppendDataBoundItems="true"
                                                      DataSourceID="SQLDataSource_Legislature"
                                                      DataTextField="num_legislatura" 
                                                      DataValueField="id_legislatura"
                                                      Width="80px" 
                                                      OnDataBound="ddl_insert_legislatura_databound" >
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--consigliere + gruppo--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_insert_consigliere" 
                                               runat="server" 
                                               Text="CONSIGLIERE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_insert_consigliere_2" 
                                               runat="server" >
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_insert_gruppo_consiliare" 
                                               runat="server" 
                                               Text="GRUPPO CONSILIARE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:DropDownList ID="ddl_insert_gruppo_consiliare" 
                                                      runat="server" 
                                                      AppendDataBoundItems="true"
                                                      DataSourceID="SQLDataSource_GruppiConsiliari"
                                                      DataTextField="nome_gruppo" 
                                                      DataValueField="id_gruppo"
                                                      Width="200px" >
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--data_procl + dichiarazione del incarichi--%>
                            <tr>
                                <td align="left">
                                    <asp:Label ID="lbl_insert_data_proclamazione" 
                                               runat="server" 
                                               Text="DATA PROCLAMAZIONE:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:Label ID="lbl_insert_data_proclamazione_2" 
                                               runat="server" >
                                    </asp:Label>
                                </td>
                                
                                <td align="right">
                                    <asp:Label ID="lbl_insert_dichiarazione_del" 
                                               runat="server" 
                                               Text="DICHIARAZIONE DEL:" 
                                               Font-Bold="True">
                                    </asp:Label>
                                    
                                    <asp:TextBox ID="txt_insert_dichiarazione_del" 
                                                 runat="server" 
                                                 Width="80px" >
                                    </asp:TextBox>
                                    
                                    <asp:RequiredFieldValidator ID="RFV_data" 
                                                                runat="server"
                                                                ControlToValidate="txt_insert_dichiarazione_del"
                                                                ErrorMessage="*"
                                                                ValidationGroup="ValidGroup_Insert" >
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--lista incarichi--%>
                            <tr>
                                <td colspan="2" align="center">
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--indicazioni gde--%>
                            <tr>
                                <td colspan="2" align="left">
                                    <asp:Label ID="lbl_insert_indicazioni_gde" 
                                               runat="server" 
                                               Text="INDICAZIONI GDE:" 
                                               Font-Bold="true" >
                                    </asp:Label>
                                    
                                    <br />
                                    
                                    <asp:TextBox ID="txt_insert_indicazioni_gde" 
                                                 runat="server" 
                                                 TextMode="MultiLine" 
                                                 Rows="4" 
                                                 MaxLength="200"
                                                 Width="99%" >
                                    </asp:TextBox>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--indicazioni segreteria--%>
                            <tr>
                                <td colspan="2" align="left">
                                    <asp:Label ID="lbl_insert_indicazioni_segreteria" 
                                               runat="server" 
                                               Text="INDICAZIONI SEGRETERIA:" 
                                               Font-Bold="true" >
                                    </asp:Label>
                                    
                                    <br />
                                    
                                    <asp:TextBox ID="txt_insert_indicazioni_segreteria" 
                                                 runat="server" 
                                                 TextMode="MultiLine" 
                                                 Rows="4" 
                                                 MaxLength="200"
                                                 Width="99%" >
                                    </asp:TextBox>
                                </td>
                            </tr>
                            
                            <%--spazio--%>
                            <tr>
                                <td colspan="2">
                                    &nbsp;
                                </td>
                            </tr>
                            
                            <%--crudel--%>
                            <tr>
                                <td colspan="2" align="center" >
                                    <asp:Button ID="btn_insert_insert" 
                                                runat="server" 
                                                CausesValidation="True" 
                                                ValidationGroup="ValidGroup_Insert"
                                                CommandName="Insert" 
                                                CssClass="button" 
                                                Text="Inserisci" 
                                                Visible='<%# ((role == 1) || ((role == 5) && (logged_categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni))) ? true : false %>' />
                                    
                                    <asp:Button ID="btn_insert_cancel"
                                                runat="server" 
                                                CausesValidation="False" 
                                                CommandName="Cancel" 
                                                CssClass="button" 
                                                Text="Annulla" 
                                                
                                                OnClick="btn_insert_cancel_click" />
                                </td>
                            </tr>
                            </table>
                        </div>
                    </InsertItemTemplate>
                </asp:FormView>
                
                <asp:SqlDataSource ID="SqlDataSource1" 
                                   runat="server" 
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                   
                                   OnInserted="SqlDataSource1_Inserted" 
                                   
                                   SelectCommand="SELECT ll.id_legislatura,
                                                         ll.num_legislatura AS legislatura,
                                                         sc.id_scheda,
                                                         pp.cognome + ' ' + pp.nome AS consigliere,
                                                         LTRIM(RTRIM(gg.nome_gruppo)) AS gruppo_consiliare,
                                                         CONVERT(varchar, jpoc.data_proclamazione, 103) AS data_proclamazione,
                                                         CONVERT(varchar, sc.data, 103) AS data,
                                                         sc.indicazioni_gde,
                                                         sc.indicazioni_seg,
                                                         CONVERT(varchar, ss.data_seduta, 103) AS data_seduta,
                                                         ss.numero_seduta
                                                  FROM scheda AS sc
                                                  INNER JOIN persona AS pp
                                                     ON sc.id_persona = pp.id_persona
                                                  INNER JOIN legislature AS ll
                                                     ON sc.id_legislatura = ll.id_legislatura
                                                  INNER JOIN join_persona_organo_carica AS jpoc
                                                     ON (pp.id_persona = jpoc.id_persona AND ll.id_legislatura = jpoc.id_legislatura)
                                                  INNER JOIN organi AS oo
                                                     ON jpoc.id_organo = oo.id_organo
                                                  INNER JOIN cariche AS cc
                                                     ON jpoc.id_carica = cc.id_carica
                                                  LEFT OUTER JOIN gruppi_politici AS gg
                                                     ON (sc.id_gruppo = gg.id_gruppo AND gg.deleted = 0)
                                                  LEFT OUTER JOIN sedute AS ss
                                                     ON (sc.id_seduta = ss.id_seduta AND ss.deleted = 0)
                                                  WHERE sc.deleted = 0
                                                    AND pp.deleted = 0
                                                    AND jpoc.deleted = 0
                                                    AND oo.deleted = 0
                                                    AND cc.id_tipo_carica = 4 --'consigliere regionale'
                                                    AND oo.id_categoria_organo = 1 --consiglio regionale
                                                    AND sc.id_scheda = @id_scheda"
                                   
                                   InsertCommand="INSERT INTO scheda (id_legislatura,
                                                                      id_persona,
                                                                      id_gruppo, 
                                                                      data,
                                                                      indicazioni_gde,
                                                                      indicazioni_seg,
                                                                      id_seduta,
                                                                      deleted) 
                                                  VALUES (@id_legislatura,
                                                          @id_persona,
                                                          @id_gruppo,
                                                          @data,
                                                          @indicazioni_gde,
                                                          @indicazioni_seg,
                                                          @id_seduta,
                                                          0); 
                                                  SELECT @id_scheda = SCOPE_IDENTITY();"
                                   
                                   UpdateCommand="UPDATE scheda 
                                                  SET id_gruppo = @id_gruppo 
                                                      data = @data 
                                                      indicazioni_gde = @indicazioni_gde 
                                                      indicazione_seg = @indicazione_seg 
                                                      id_seduta = @id_seduta 
                                                  WHERE id_scheda = @id_scheda"
                                   
                                   DeleteCommand="DELETE FROM scheda 
                                                  WHERE id_scheda = @id_scheda; 
                                                  DELETE FROM join_scheda_incarico 
                                                  WHERE id_scheda = @id_scheda;" >
                                  
                    <SelectParameters>
                        <asp:SessionParameter Name="id_scheda" SessionField="id_scheda" Type="Int32" />
                    </SelectParameters>

                    <InsertParameters>
                        <asp:Parameter Name="id_legislatura" Type="Int32" />
                        <asp:Parameter Name="id_persona" Type="Int32" />
                        <asp:Parameter Name="id_gruppo" Type="Int32" />
                        <asp:Parameter Name="data" Type="Datetime" />
                        <asp:Parameter Name="indicazioni_gde" Type="String" />
                        <asp:Parameter Name="indicazioni_seg" Type="String" />
                        <asp:Parameter Name="id_seduta" Type="Int32" />
                        <asp:Parameter Name="id_scheda" Type="Int32" Direction="Output" />
                    </InsertParameters>
                    
                    <UpdateParameters>
                        <asp:Parameter Name="id_gruppo" Type="Int32" />
                        <asp:Parameter Name="indicazioni_gde" Type="String" />
                        <asp:Parameter Name="indicazioni_seg" Type="String" />
                        <asp:Parameter Name="id_seduta" Type="Int32" />
                        <asp:Parameter Name="id_scheda" Type="Int32" />
                    </UpdateParameters>
                    
                    <DeleteParameters>
                        <asp:Parameter Name="id_scheda" Type="Int32" />
                    </DeleteParameters>
                </asp:SqlDataSource>
                
                <asp:SqlDataSource ID="SqlDataSource_Legislature" 
                                   runat="server" 
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                   
                                   SelectCommand="SELECT ll.id_legislatura, 
                                                         ll.num_legislatura,
                                                         ll.durata_legislatura_da
                                                  FROM legislature AS ll
                                                  INNER JOIN join_persona_organo_carica AS jpoc
                                                     ON ll.id_legislatura = jpoc.id_legislatura
                                                  INNER JOIN persona AS pp
                                                     ON jpoc.id_persona = pp.id_persona
                                                  INNER JOIN organi AS oo
                                                     ON jpoc.id_organo = oo.id_organo
                                                  WHERE jpoc.deleted = 0
                                                    AND pp.deleted = 0 
                                                    AND oo.deleted = 0
                                                    AND pp.id_persona = @id_persona
                                                  ORDER BY ll.durata_legislatura_da DESC" >
                    <SelectParameters>
                        <asp:SessionParameter Name="id_persona" SessionField="id_persona" />
                    </SelectParameters>
                </asp:SqlDataSource>
                
                <asp:SqlDataSource ID="SqlDataSource_GruppiConsiliari" 
                                   runat="server" 
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                   
                                   SelectCommand="SELECT gg.id_gruppo, 
                                                         LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo,
                                                         jpgp.data_inizio
                                                  FROM gruppi_politici AS gg
                                                  INNER JOIN join_persona_gruppi_politici AS jpgp
                                                     ON gg.id_gruppo = jpgp.id_gruppo
                                                  INNER JOIN legislature AS ll
                                                     ON jpgp.id_legislatura = ll.id_legislatura
                                                  INNER JOIN persona AS pp
                                                     ON jpgp.id_persona = pp.id_persona
                                                  WHERE jpgp.deleted = 0 
                                                    AND pp.deleted = 0 
                                                    AND gg.deleted = 0 
                                                    AND pp.id_persona = @id_persona
                                                  ORDER BY jpgp.data_inizio DESC" >
                    <SelectParameters>
                        <asp:SessionParameter Name="id_persona" SessionField="id_persona" />
                    </SelectParameters>
                </asp:SqlDataSource>
                
                <asp:SqlDataSource ID="SQLDataSource_Incarichi" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                  
                                   SelectCommand="SELECT ii.id_incarico,
                                                         ii.nome_incarico,
                                                         ii.riferimenti_normativi,
                                                         CONVERT(varchar, ii.data_cessazione, 103) AS data_cessazione,
                                                         ii.note_istruttorie
                                                  FROM incarico AS ii
                                                  INNER JOIN join_scheda_incarico AS jsi
                                                     ON ii.id_incarico = jsi.id_incarico
                                                  INNER JOIN scheda AS sc
                                                     ON jsi.id_scheda = sc.id_scheda
                                                  WHERE sc.deleted = 0
                                                    AND ii.deleted = 0
                                                    AND sc.id_scheda = @id_scheda
                                                  ORDER BY ii.data_inizio" >
                    <SelectParameters>
                        <asp:SessionParameter Name="id_scheda" SessionField="id_scheda" />
                    </SelectParameters>
                </asp:SqlDataSource>
            </td>
        </tr>
        </table>
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
               href="../schede_incarichi/schede_extra.aspx?mode=normal">
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