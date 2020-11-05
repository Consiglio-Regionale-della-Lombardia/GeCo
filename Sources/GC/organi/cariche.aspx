<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master"
         CodeFile="cariche.aspx.cs" 
         Inherits="organi_cariche" 
         Title="Organo > Cariche" %>

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
	<b>ORGANO &gt; CARICHE</b>
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
		    <li><a id="a_dettaglio" runat="server" >ANAGRAFICA</a></li>
		    <li><a id="a_componenti" runat="server" >COMPONENTI</a></li>
		    <li id="selected"><a id="a_cariche" runat="server" >CARICHE</a></li>
	        </ul>
	    </div>
    	
	    <div id="tab_content">
	        <div id="tab_content_content">
		    <asp:ScriptManager ID="ScriptManager2" runat="server" EnableScriptGlobalization="True">
		    </asp:ScriptManager>
		    <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
		        <ContentTemplate>
			    <table width="100%" cellspacing="5">
		        <tr>
			        <td valign="top" width="50%">
			            <asp:ListView ID="ListView1" 
			                          runat="server" 
			                          DataKeyNames="id_rec" 
			                          DataSourceID="SqlDataSource2"
				                      InsertItemPosition="LastItem" 
    					              
				                      OnItemInserting="ListView1_ItemInserting" 
				                      OnSelectedIndexChanging="ListView1_SelectedIndexChanging"
				                      OnItemDeleted="ListView1_ItemDeleted" >
    					   
				            <LayoutTemplate>
				                <table runat="server" width="100%">
					            <tr runat="server">
					                <td runat="server">
						            <table id="itemPlaceholderContainer" runat="server" class="tab_gen">
						                <tr runat="server">
							                <th runat="server">
							                    Carica
							                </th>
							                
							                <th id="Th1" runat="server">
							                </th>
						                </tr>
						                <tr id="itemPlaceholder" runat="server">
						                </tr>
						            </table>
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
				                <% if (role <= 2 || role == 4) { %>
				                <tr>
					                <td width="80%">
					                    <asp:DropDownList ID="DropDownList1" 
					                                      runat="server" 
					                                      DataSourceID="SqlDataSource1"
						                                  DataTextField="nome_carica" 
						                                  DataValueField="id_carica" 
						                                  Width="99%">
					                    </asp:DropDownList>
        						        
					                    <asp:SqlDataSource ID="SqlDataSource1" 
			                                               runat="server" 
			                                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    					                                   
				                                           SelectCommand="SELECT * 
				                                                          FROM cariche 
				                                                          WHERE tipologia = 'ORGANI'
                                                                          ORDER BY NOME_CARICA
				                                                          --ORDER BY ordine">
				                        </asp:SqlDataSource>
					                </td>
    						        
					                <td align="center">
					                    <asp:Button ID="InsertButton" 
					                                runat="server" 
					                                CommandName="Insert" 
					                                Text="Inserisci"
						                            CssClass="button" />
					                </td>
				                </tr>
				                <%} %>
				            </InsertItemTemplate>
    		
				            <ItemTemplate>
				                <tr style="">
					                <td width="80%">
					                    <asp:Label ID="nome_caricaLabel" 
					                               runat="server" 
					                               Text='<%# Eval("nome_carica") %>' >
					                    </asp:Label>
					                </td>
                                    <% if (role <= 2 || role == 4) { %>   
    						            <td align="center">
					                        <% if (role <= 2) { %>   
					                            <asp:Button ID="EditMaskButton" 
					                                        runat="server" 
					                                        CommandName="Select" 
					                                        Text="Maschera..."
						                                    CssClass="button" />
                                            <%} %>	                  
					                        <asp:Button ID="DeleteButton" 
					                                    runat="server" 
					                                    CommandName="Delete" 
					                                    Text="Elimina"
						                                CssClass="button" 
						                                OnClientClick="return confirm ('Procedere con l\'eliminazione?');" />
					                    </td>
					                <%} %>
				                </tr>
				            </ItemTemplate>						
			            </asp:ListView>
    				    
			            <asp:SqlDataSource ID="SqlDataSource2" 
			                               runat="server" 
			                               ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    					                   
				                           DeleteCommand="UPDATE join_cariche_organi 
				                                          SET deleted = 1 
				                                          WHERE id_rec = @id_rec"
    					                                  
				                           InsertCommand="INSERT INTO join_cariche_organi (id_organo, 
				                                                                           id_carica, 
				                                                                           flag) 
				                                          VALUES (@id_organo, 
				                                                  @id_carica, 
				                                                  @flag); 
				                                          SELECT @id_rec = SCOPE_IDENTITY();"
    					                   
				                           SelectCommand="SELECT * 
				                                          FROM join_cariche_organi AS jj 
				                                          INNER JOIN cariche AS cc 
				                                            ON jj.id_carica = cc.id_carica 
				                                          WHERE deleted = 0 
				                                            AND id_organo = @id_organo"
    					                   
				                           OnInserted="SqlDataSource1_Inserted">
    					                   
				            <SelectParameters>
				                <asp:SessionParameter Name="id_organo" SessionField="id_organo" Type="Int32" />
				            </SelectParameters>
        					
				            <DeleteParameters>
				                <asp:Parameter Name="id_rec" Type="Int32" />
				            </DeleteParameters>
        					
				            <InsertParameters>
				                <asp:Parameter Name="id_organo" Type="Int32" />
				                <asp:Parameter Name="id_carica" Type="Int32" />
				                <asp:Parameter Name="flag" Type="String" />
				                <asp:Parameter Direction="Output" Name="id_rec" Type="Int32" />
				            </InsertParameters>
			            </asp:SqlDataSource>				    				    
			        </td>
    				
			        <td valign="top">
			        <div class="singleborder" id="EditMaskDiv" runat="server" style="padding: 10px;">
				    <b>Modifica maschera per la carica selezionata:</b>
    				
				    <br />					
				    <br />

                    <div style="margin:2px; padding:4px; font-weight:bold; border:solid 1px black;">
                        <asp:CheckBox runat="server" ID="chkVisAmmTrasp" Text="Visibile in Amministrazione Trasparente" />
                    </div>
    				
				    <asp:CheckBoxList ID="CheckBoxList1" runat="server">
				        <%--
				        <asp:ListItem Text="Data elezione" Value="0" />
				        <asp:ListItem Text="Circoscrizione" Value="0" />
				        <asp:ListItem Text="Lista" Value="0" />
				        <asp:ListItem Text="Maggioranza" Value="0" />
				        <asp:ListItem Text="Voti" Value="0" />
				        <asp:ListItem Text="Neoeletto" Value="0" />
				        --%>

				        <asp:ListItem Text="Numero pratica" Value="0" />
				        <asp:ListItem Text="Data proclamazione" Value="0" />
				        <asp:ListItem Text="Delibera proclamazione" Value="0" />
				        <asp:ListItem Text="Data delibera proclamazione" Value="0" />
				        <asp:ListItem Text="Tipo delibera proclamazione" Value="0" />
				        <asp:ListItem Text="Protocollo delibera proclamazione" Value="0" />
				        <asp:ListItem Text="Data convalida" Value="0" />
				        <asp:ListItem Text="Telefono" Value="0" />
				        <asp:ListItem Text="Fax" Value="0" />
				        <asp:ListItem Text="Causa fine" Value="0" />
				        <%--<asp:ListItem Text="Diaria" Value="0" />--%>
                        <asp:ListItem Text="Opzione" Value="0" />
				        <asp:ListItem Text="Note" Value="0" />
				    </asp:CheckBoxList>
    				
				    <br />
    				
				    <asp:Button ID="SaveMaskButton" 
				                runat="server" 
				                Text="Salva" 
				                CssClass="button" 
				                OnClick="SaveMaskButton_Click" />
    				
				    <asp:Button ID="CancelMaskButton" 
				                runat="server" 
				                Text="Annulla" 
				                CssClass="button"
				                OnClick="CancelMaskButton_Click" />
			        </div>
			    </td>
		        </tr>
			    </table>
		        </ContentTemplate>
		    </asp:UpdatePanel>
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
	    <a id="a_back" runat="server" href="../organi/gestisciOrgani.aspx">
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