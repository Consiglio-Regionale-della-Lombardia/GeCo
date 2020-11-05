<%@ Page Language="C#" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         MasterPageFile="~/MasterPage.master"
         CodeFile="riepilogo.aspx.cs" 
         Inherits="sedute_riepilogo" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

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
	<b>RIEPILOGO DELLE PRESENZE/ASSENZE DEI CONSIGLIERI</b>
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
		<li id="selected">
		    <a href="riepilogo.aspx">
		        RIEPILOGO PRES/ASS
		    </a>
		</li>
		<li>
		    <a href="riepilogo2.aspx">
		        RIEPILOGO SEDUTE
		    </a>
		</li>
	    </ul>
	</div>
	
	<div id="tab_content">
	    <div id="tab_content_content">
		    <asp:UpdatePanel ID="UpdatePanelMaster" runat="server" UpdateMode="Conditional">
	        <ContentTemplate>

            <asp:UpdateProgress ID="UpdateProgressGenerale" runat="server">
              <ProgressTemplate>
                <div align="center" style="position: fixed; text-align:center; z-index:100; top: 50%; left: 50%;"><asp:Image ID="ImageUpdate" runat="server" ImageUrl="../img/wait.gif"  /></div>
              </ProgressTemplate>
            </asp:UpdateProgress>
 
		    <table width="100%">
		        <tr>
		        <td align="left" valign="middle">
			        Tipo Seduta:
			        <asp:DropDownList ID="DropDownListTipoSedute" 
			                          runat="server" 
			                          DataSourceID="SqlDataSourceTipoSedute"
				                      DataTextField="tipo_incontro" 
				                      DataValueField="id_incontro"
				                      AppendDataBoundItems="true" >
				        <asp:ListItem Value="all" Text="Tutte"/>
			        </asp:DropDownList>
			        <asp:SqlDataSource ID="SqlDataSourceTipoSedute" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                       
				                       SelectCommand="SELECT tipo_incontro, 
				                                             id_incontro 
                                                      FROM tbl_incontri">
			        </asp:SqlDataSource>					
			    </td>
		        
			    <td align="left" valign="middle">
			        Seleziona Anno:
			        <asp:DropDownList ID="DropDownListAnnoRiepilogo" runat="server" DataSourceID="SqlDataSourceAnniRiepilogo"
				    DataTextField="anno" DataValueField="anno">
			        </asp:DropDownList>
			        <asp:SqlDataSource ID="SqlDataSourceAnniRiepilogo" 
			                           runat="server" 
			                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                       
				                       SelectCommand="SELECT anno 
				                                      FROM tbl_anni 
				                                      WHERE anno &gt; (YEAR(GETDATE()) - 25) 
				                                        AND anno &lt;= YEAR(GETDATE()) 
				                                      ORDER BY anno DESC" >
			        </asp:SqlDataSource>
			    </td>
			    
			    <td align="left" valign="middle">
			        Seleziona Mese:
			        <asp:DropDownList ID="DropDownListMeseRiepilogo" runat="server">
				    <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
				    <asp:ListItem Text="Gennaio" Value="1"></asp:ListItem>
				    <asp:ListItem Text="Febbraio" Value="2"></asp:ListItem>
				    <asp:ListItem Text="Marzo" Value="3"></asp:ListItem>
				    <asp:ListItem Text="Aprile" Value="4"></asp:ListItem>
				    <asp:ListItem Text="Maggio" Value="5"></asp:ListItem>
				    <asp:ListItem Text="Giugno" Value="6"></asp:ListItem>
				    <asp:ListItem Text="Luglio" Value="7"></asp:ListItem>
				    <asp:ListItem Text="Agosto" Value="8"></asp:ListItem>
				    <asp:ListItem Text="Settembre" Value="9"></asp:ListItem>
				    <asp:ListItem Text="Ottobre" Value="10"></asp:ListItem>
				    <asp:ListItem Text="Novembre" Value="11"></asp:ListItem>
				    <asp:ListItem Text="Dicembre" Value="12"></asp:ListItem>
			        </asp:DropDownList>
			        
			        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListMeseRiepilogo"
				                                runat="server" 
				                                ErrorMessage="Campo obbligatorio." 
				                                ControlToValidate="DropDownListMeseRiepilogo"
				                                Display="Dynamic" 
				                                ValidationGroup="GroupRiepilogo" >
				    </asp:RequiredFieldValidator>
			    </td>
			    
			    <td align="right" valign="middle">
			        <asp:Button ID="ButtonRiepilogo" 
			                    runat="server" 
			                    Text="Visualizza" 
				                ValidationGroup="GroupRiepilogo" 
				                
				                OnClick="ButtonRiepilogo_Click" />
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
		    <br />
			
		    <asp:GridView ID="GridView1" 
		                  runat="server" 
		                  CssClass="tab_gen" 
		                  AutoGenerateColumns="False"
		                  DataSourceID="SqlDataSource1" >
			      				            
		        <Columns>
			        <asp:TemplateField HeaderText="Consiglieri" SortExpression="nome_completo">
			            <ItemTemplate>
							<asp:HiddenField ID="id_persona" runat="server" Value='<%# Eval("id_persona") %>' />
				            <asp:LinkButton ID="lnkbtn_nome" 
		                                    runat="server"
		                                    Text='<%# Eval("nome_completo") %>'
		                                    Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>' >
		                    </asp:LinkButton>
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" HorizontalAlign="Left" />
			        </asp:TemplateField>
					
			        <asp:TemplateField HeaderText="Consiglieri firmatari del foglio ricognitivo">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
					
			        <asp:TemplateField HeaderText="Consiglieri firmatari del foglio patecipanti">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
					
			        <asp:TemplateField HeaderText="Consiglieri assenti">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
		        </Columns>
			    
		        <EmptyDataTemplate>
		            <table width="100%" class="tab_gen">
		                <tr>
		                    <th>
		                        NESSUN DATO DISPONIBILE
		                    </th>
		                </tr>
		            </table>
		        </EmptyDataTemplate>
			    
		    </asp:GridView>
			
		    <asp:SqlDataSource ID="SqlDataSource1" 
		                       runat="server" 
		                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                       SelectCommand="" >
		    </asp:SqlDataSource>


            <asp:GridView ID="GridViewDup53" 
		                  runat="server" 
		                  CssClass="tab_gen" 
		                  AutoGenerateColumns="False"
		                  DataSourceID="SqlDataSourceDup53" 
                          OnRowDataBound="grdViewDup53_RowDataBound"
                          onrowcreated="grdViewDup53_RowCreated" 
                          Visible ="false">
                
                <Columns>
			        <asp:TemplateField HeaderText="Consiglieri" SortExpression="nome_completo">
			            <ItemTemplate>
							<asp:HiddenField ID="id_persona" runat="server" Value='<%# Eval("id_persona") %>' />
				            <asp:LinkButton ID="lnkbtn_nome" 
		                                    runat="server"
		                                    Text='<%# Eval("nome_completo") %>'
		                                    Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>' >
		                    </asp:LinkButton>
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" HorizontalAlign="Left" />
			        </asp:TemplateField>
			        <asp:TemplateField HeaderText="I° PRIOR<br />Detrazione<br />€ 140,60">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
			        <asp:TemplateField HeaderText="II° PRIOR<br />Detrazione<br />€ 70,33">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
			        <asp:TemplateField HeaderText="Presenze">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
			        <asp:TemplateField HeaderText="I° PRIOR<br />Detrazione<br />€ 281,20">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
			        <asp:TemplateField HeaderText="II° PRIOR<br />Detrazione<br />€ 140,60">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
			        <asp:TemplateField HeaderText="Sostituzioni">
			            <ItemTemplate>
			            </ItemTemplate>
			            <ItemStyle Width="200px" HorizontalAlign="Center" />
			        </asp:TemplateField>
                </Columns>
     
		        <EmptyDataTemplate>
		            <table width="100%" class="tab_gen">
		                <tr>
		                    <th>
		                        NESSUN DATO DISPONIBILE
		                    </th>
		                </tr>
		            </table>
		        </EmptyDataTemplate>

            </asp:GridView>

            <asp:GridView ID="GridView2" 
		                  runat="server" 
		                  CssClass="tab_gen" 
		                  AutoGenerateColumns="False"
		                  DataSourceID="SqlDataSourceDup53" 
                          OnRowDataBound="grdViewDup53_RowDataBound"
                          onrowcreated="grdViewDup53_RowCreated" 
                          Visible ="false">
                
                <Columns>
			        <asp:TemplateField HeaderText="Consiglieri" SortExpression="nome_completo">
			            <ItemTemplate>
							<asp:HiddenField ID="id_persona" runat="server" Value='<%# Eval("id_persona") %>' />
				            <asp:LinkButton ID="lnkbtn_nome" 
		                                    runat="server"
		                                    Text='<%# Eval("nome_completo") %>'
		                                    Font-Bold="true"
		                                    onclientclick='<%# getPopupURL("../persona/dettaglio.aspx", Eval("id_persona")) %>' >
		                    </asp:LinkButton>
			            </ItemTemplate>
			            <ItemStyle Font-Bold="True" HorizontalAlign="Left" />
			        </asp:TemplateField>
                    <asp:BoundField DataField="presenza_priorita_1" HeaderText="I° PRIOR<br />Detrazione<br />€ 140,60" HtmlEncode="False" ItemStyle-HorizontalAlign="Left" >
                    </asp:BoundField>
                    <asp:BoundField DataField="presenza_priorita_2" HeaderText="II° PRIOR<br />Detrazione<br />€ 70,33" HtmlEncode="False" ItemStyle-HorizontalAlign="Left" >
                    </asp:BoundField>
                    <asp:BoundField DataField="presenza_priorita_no" HeaderText="Presenze" ItemStyle-HorizontalAlign="Right" >
                    </asp:BoundField>
                    <asp:BoundField DataField="assenza_priorita_1" HeaderText="I° PRIOR<br />Detrazione<br />€ 281,20" HtmlEncode="False" ItemStyle-HorizontalAlign="Left" >
                    </asp:BoundField>
                    <asp:BoundField DataField="assenza_priorita_2" HeaderText="II° PRIOR<br />Detrazione<br />€ 140,60" HtmlEncode="False" ItemStyle-HorizontalAlign="Left" >
                    </asp:BoundField>
                    <asp:BoundField DataField="sostituzioni" HeaderText="Sostituzioni" ItemStyle-HorizontalAlign="Right" >
                    </asp:BoundField>
                </Columns>
     
		        <EmptyDataTemplate>
		            <table width="100%" class="tab_gen">
		                <tr>
		                    <th>
		                        NESSUN DATO DISPONIBILE
		                    </th>
		                </tr>
		            </table>
		        </EmptyDataTemplate>

            </asp:GridView>

		    <asp:SqlDataSource ID="SqlDataSourceDup53" 
		                       runat="server" 
		                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
		                       SelectCommand="" >
		    </asp:SqlDataSource>

	        </ContentTemplate>
		    </asp:UpdatePanel>
    		
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
			    <h3>
			        MODIFICA PRESENZA/ASSENZA
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
				                     DataKeyNames="id_rec" 
				                     
				                     OnItemUpdated="DetailsView1_ItemUpdated"
				                     OnItemUpdating="DetailsView1_ItemUpdating">
				                     
				        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="50%" HorizontalAlign="right" />
				        <RowStyle HorizontalAlign="left" />
				        <HeaderStyle Font-Bold="False" />
				        
				        <Fields>
					    <asp:TemplateField HeaderText="Organo">
					        <ItemTemplate>
						        <asp:Label ID="LabelOrgano" 
						                   runat="server" 
						                   Text='<%# Bind("nome_organo") %>'>
						        </asp:Label>
					        </ItemTemplate>
					        
					        <EditItemTemplate>
						        <asp:DropDownList ID="DropDownListOrgano" 
						                          runat="server" 
						                          DataSourceID="SqlDataSourceOrgano"
						                          SelectedValue='<%# Eval("id_organo") %>' 
						                          DataTextField="nome_organo" 
						                          DataValueField="id_organo"
						                          Width="200px" 
						                          AutoPostBack="True">
						        </asp:DropDownList>
    						    
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorOrgano" 
						                                    runat="server" 
						                                    ErrorMessage="Nessun organo disponibile."
						                                    ControlToValidate="DropDownListOrgano" 
						                                    Display="Dynamic" 
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
    						    
						        <asp:SqlDataSource ID="SqlDataSourceOrgano" 
						                           runat="server" 
						                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						                       
						                           SelectCommand="SELECT DISTINCT oo.id_organo, 
				                                                                  durata_legislatura_da,
				                                                                  ll.num_legislatura + ' - ' + oo.nome_organo AS nome_organo
                                                                  FROM organi AS oo 
                                                                  INNER JOIN legislature AS ll 
                                                                    ON oo.id_legislatura = ll.id_legislatura
                                                                  INNER JOIN sedute AS ss
                                                                    ON oo.id_organo = ss.id_organo
                                                                  WHERE oo.deleted = 0 
                                                                    AND oo.vis_serv_comm = 1
                                                                    AND ss.deleted = 0
                                                                    AND (((ss.data_seduta &gt;= oo.data_inizio) AND (ss.data_seduta &lt;= oo.data_fine))
	                                                                    OR ((ss.data_seduta &gt;= oo.data_inizio) AND (oo.data_fine IS NULL)))
                                                                  ORDER BY durata_legislatura_da DESC, nome_organo ASC" >
						        </asp:SqlDataSource>
					        </EditItemTemplate>
					    </asp:TemplateField>
					    
					    <asp:TemplateField>
					        <HeaderTemplate>
						        <asp:Label ID="LabelTiposeduta" 
						                   runat="server" 
						                   Text='<%# Bind("tipo_incontro") %>'>
						        </asp:Label>
					        </HeaderTemplate>
					        
					        <ItemTemplate>
						        <asp:Label ID="LabelSeduta" 
						                   runat="server" 
						                   Text='<%# Bind("nome_seduta") %>'>
						        </asp:Label>
					        </ItemTemplate>
					        
					        <EditItemTemplate>
						        <asp:DropDownList ID="DropDownListSeduta" 
						                          runat="server" 
						                          DataSourceID="SqlDataSourceSeduta"
						                          OnDataBound="DropDownListSeduta_DataBound" 
						                          DataTextField="nome_seduta" 
						                          DataValueField="id_seduta"
						                          Width="200px" >
						        </asp:DropDownList>
						        
						        <asp:RequiredFieldValidator ID="RequiredFieldValidatorSeduta" 
						                                    runat="server" 
						                                    ErrorMessage="Nessuna seduta disponibile."
						                                    ControlToValidate="DropDownListSeduta" 
						                                    Display="Dynamic" 
						                                    ValidationGroup="ValidGroup" >
						        </asp:RequiredFieldValidator>
						        
						        <asp:SqlDataSource ID="SqlDataSourceSeduta" 
						                           runat="server" 
						                           ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    						                       
						                           SelectCommand="SELECT id_seduta, 
						                                                 'N.' + numero_seduta + ' del ' + CONVERT(varchar(11), data_seduta) AS nome_seduta 
						                                          FROM sedute 
						                                          WHERE deleted = 0
						                                            AND id_organo = @id_organo">
						            <SelectParameters>
							            <asp:ControlParameter ControlID="DetailsView1$DropDownListOrgano" 
							                                  Name="id_organo"
							                                  PropertyName="SelectedValue" 
							                                  Type="Int32" 
							                                  DefaultValue="0" />
						            </SelectParameters>
						        </asp:SqlDataSource>
					        </EditItemTemplate>
					    </asp:TemplateField>
					    
					    <asp:TemplateField HeaderText="Presenza">
					        <ItemTemplate>
						        <asp:Label ID="LabelPresenza" 
						                   runat="server" 
						                   Text='<%# Bind("nome_partecipazione") %>'>
						        </asp:Label>
					        </ItemTemplate>
					        
					        <EditItemTemplate>
						        <asp:RadioButtonList ID="RadioButtonListPresenza" 
						                             runat="Server" 
						                             SelectedValue='<%# Bind("tipo_partecipazione") %>'>
						            <asp:ListItem Value="P1" Text="Presente" Selected="True" />
						            <asp:ListItem Value="P2" Text="Entro 15 min" />
						            <asp:ListItem Value="A2" Text="Assente" />
						        </asp:RadioButtonList>
					        </EditItemTemplate>
					    </asp:TemplateField>
					    
					    <asp:TemplateField ShowHeader="False">
					        <ItemTemplate>
						        <asp:Button ID="btn_edit" 
						                    runat="server" 
						                    CausesValidation="False" 
						                    CommandName="Edit"
						                    Text="Modifica" 
						                    Visible='<%# GetVisibility(Eval("locked1")) %>' />
						                    
						        <asp:Button ID="btn_cancel_item" 
						                    runat="server" 
						                    CausesValidation="False" 
						                    Text="Chiudi" 
						                    CssClass="button"
						                    OnClick="ButtonAnnulla_Click" 
						                    CommandName="Cancel" />
					        </ItemTemplate>
					        
					        <EditItemTemplate>
						        <asp:Button ID="btn_update" 
						                    runat="server" 
						                    CommandName="Update" 
						                    Text="Aggiorna" 
						                    ValidationGroup="ValidGroup" />
						        
						        <asp:Button ID="btn_cancel_edit" 
						                    runat="server" 
						                    CausesValidation="False" 
						                    CommandName="Cancel" 
						                    Text="Annulla" />
					        </EditItemTemplate>
					        
					        <ItemStyle HorizontalAlign="Center" />
					        <ControlStyle CssClass="button" />
					    </asp:TemplateField>
				        </Fields>
				    </asp:DetailsView>
				    
				    <asp:SqlDataSource ID="SqlDataSource2" 
				                       runat="server" 
				                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
				                       
				                       SelectCommand="SELECT jj.*, 
				                                             oo.id_organo, 
				                                             oo.nome_organo, 
				                                             pp.nome_partecipazione, 
				                                             'N.' + ss.numero_seduta + ' del ' + CONVERT(varchar(11), ss.data_seduta) AS nome_seduta, 
				                                             tipo_incontro,
				                                             ss.locked1
						                              FROM join_persona_sedute AS jj 
						                              INNER JOIN sedute AS ss 
						                                ON jj.id_seduta = ss.id_seduta 
						                              INNER JOIN tbl_incontri 
						                                ON ss.tipo_seduta=tbl_incontri.id_incontro 
						                              INNER JOIN tbl_partecipazioni AS pp 
						                                ON jj.tipo_partecipazione = pp.id_partecipazione 
						                              INNER JOIN organi AS oo 
						                                ON ss.id_organo = oo.id_organo
						                              WHERE oo.deleted = 0 
						                                AND oo.vis_serv_comm = 1
						                                AND ss.deleted = 0 
						                                AND jj.deleted = 0 
						                                AND jj.copia_commissioni = 1 
						                                AND id_rec = @id_rec" 
						               
						               UpdateCommand="UPDATE join_persona_sedute 
                                                        SET id_seduta = @id_seduta, 
                                                        tipo_partecipazione = @tipo_partecipazione 
                                                        where id_rec in (
	                                                        select id_rec from join_persona_sedute jps
	                                                        inner join (select id_seduta, id_persona from join_persona_sedute
		                                                    WHERE id_rec = @id_rec) jps1
		                                                    on jps.id_persona = jps1.id_persona and jps.id_seduta = jps1.id_seduta
		                                                    where copia_commissioni in (1,2)
                                                        )" >
						                                
                                          <%-- UpdateCommand="UPDATE join_persona_sedute 
						                              SET id_seduta = @id_seduta, 
						                                  tipo_partecipazione = @tipo_partecipazione 
						                              WHERE copia_commissioni = 1
						                                AND id_rec = @id_rec" >--%>
						                                						                                
				        <SelectParameters>
					        <asp:Parameter Name="id_rec" Type="Int32" />
				        </SelectParameters>
				        <DeleteParameters>
					        <asp:Parameter Name="id_rec" Type="Int32" />
				        </DeleteParameters>
				        <UpdateParameters>
<%--					        <asp:Parameter Name="id_rec" Type="Int32" />--%>
					        <asp:Parameter Name="id_seduta" Type="Int32" />
					        <asp:Parameter Name="id_persona" Type="Int32" />
					        <asp:Parameter Name="tipo_partecipazione" Type="String" />
				        </UpdateParameters>
				    </asp:SqlDataSource>
			        </ContentTemplate>
			    </asp:UpdatePanel>
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
    		
		    <br />
    		
		    <div id="tab_content_content_footer" align="right">
		        <asp:CheckBox ID="chkOptionLandscape" 
                              runat="server"
                              Text="Landscape"
                              Checked="false" />
                              
                <asp:Label ID="lblGap" 
                           runat="server" 
                           Text="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" >
                </asp:Label> 
                
		        <asp:LinkButton ID="LinkButtonExcel" 
		                        runat="server"
		                        OnClick="LinkButtonExcel_Click" >
		            <img src="../img/page_white_excel.png" alt="" align="top" /> 
		            Esporta
		        </asp:LinkButton>
		        -
		        <asp:LinkButton ID="LinkButtonPdf" 
		                        runat="server" 
		                        OnClick="LinkButtonPdf_Click" >
		            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		            Esporta
		        </asp:LinkButton>
<%--		        <asp:LinkButton ID="LinkButtonPdf" 
		                        runat="server" 
		                        OnClientClick="alert('Funzione non disponibile per manutenzione.');" >
		            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
		            Esporta
		        </asp:LinkButton>--%>

		    </div>
		    
		    <div align="center">
		        <asp:Button ID="ButtonInvia" 
		                    runat="server" 
		                    Text="Invia i fogli presenze di questo mese" 
		                    
			                OnClick="ButtonInvia_Click" 
			                OnClientClick="return confirm ('Confermare tutti i fogli presenza del mese selezionato?\nNon sarà più possibile effettuare ulteriori modifiche al foglio presenze.');" />
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
</table>
</asp:Content>