<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_segrcons_presenze_legislature_gruppo.aspx.cs" 
         Inherits="report_segrcons_presenze_legislature_gruppo" 
         Title="STAMPE > Report Presenze Legislature Gruppo" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<asp:ScriptManager ID="ScriptManager" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>

<cc1:CollapsiblePanelExtender ID="cpe" 
                              runat="Server" 
                              TargetControlID="PanelFake"
                              CollapsedSize="0" 
                              Collapsed="True" 
                              ExpandControlID="ImageFiltroData" 
                              CollapseControlID="ImageFiltroData"
                              AutoCollapse="False" 
                              AutoExpand="False" 
                              ScrollContents="False" 
                              TextLabelID="LabelRicerca"
                              CollapsedText="" 
                              ExpandedText="" 
                              ExpandDirection="Horizontal" >
</cc1:CollapsiblePanelExtender>

<asp:Panel ID="PanelFake" 
           runat="server" 
           Visible="false">
</asp:Panel>

<div id="content">
    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Presenze Legislature Gruppo"
               Font-Bold="true" >
    </asp:Label>   
     
	<br />
	<br />

    <asp:Panel ID="panelFiltri" runat="server">
    <div id="content_filtri_vis" class="pannello_ricerca">
        <asp:Label ID="lblFilterTitle" 
                   runat="server"
                   Text="FILTRI:"
                   Font-Bold="true" >
        </asp:Label> 
        
        <table width="100%">
        <tr align="left">
            <td align="left" width="35%">
                <asp:Label ID="lbl_legislatura" 
                           runat="server"
                           Text="Legislatura: "
                           Width="80px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddl_legislatura" 
                                  runat="server"
                                  AppendDataBoundItems="true" 
                                  DataTextField="num_legislatura"
                                  DataValueField="id_legislatura"
                                  DataSourceID="SQLDataSource_ddlLegislatura"
                                  AutoPostBack="true">
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlLegislatura" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        	                       
                                   SelectCommand="SELECT id_legislatura,
                                                         num_legislatura
                                                  FROM legislature
                                                  ORDER BY durata_legislatura_da DESC">
                </asp:SqlDataSource>
            </td>    	    
    	    
    	    <td align="left">
                <asp:Label ID="lbl_data_da" 
                           runat="server"
                           Text="Data da: "
                           Width="60px">
                </asp:Label> 
                
                <asp:TextBox ID="txt_data_da" 
                             runat="server" 
	                         Width="70px">
	            </asp:TextBox>
	            
                <img id="img_data_da" 
                     runat="server"
                     alt="calendar" 
                     src="../img/calendar_month.png" />
                                   
                <cc1:CalendarExtender ID="CE_data_da" 
                                      runat="server" 
                                      TargetControlID="txt_data_da"
	                                  PopupButtonID="img_data_da" 
	                                  Format="dd/MM/yyyy" >
	            </cc1:CalendarExtender>
	            
                <asp:RegularExpressionValidator ID="RFV_data_da" 
                                                ControlToValidate="txt_data_da"
	                                            runat="server" 
	                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
	                                            Display="Dynamic"
	                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
	                                            ValidationGroup="FilterGroup" >
	            </asp:RegularExpressionValidator>
            </td>
            
            <td align="left">
                <asp:Label ID="lbl_data_a" 
                           runat="server"
                           Text="Data a: ">
                </asp:Label> 
                
                <asp:TextBox ID="txt_data_a" 
                             runat="server" 
	                         Width="70px">
	            </asp:TextBox>
	            
                <img id="img_data_a" 
                     runat="server"
                     alt="calendar" 
                     src="../img/calendar_month.png" />
                                   
                <cc1:CalendarExtender ID="CE_data_a" 
                                      runat="server" 
                                      TargetControlID="txt_data_a"
	                                  PopupButtonID="img_data_a" 
	                                  Format="dd/MM/yyyy" >
	            </cc1:CalendarExtender>
	            
                <asp:RegularExpressionValidator ID="RFV_data_a" 
                                                ControlToValidate="txt_data_a"
	                                            runat="server" 
	                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
	                                            Display="Dynamic"
	                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
	                                            ValidationGroup="FilterGroup" >
	            </asp:RegularExpressionValidator>
            </td>
            
            <td>
            </td>
        </tr>
        
        <tr align="left">
            <td align="left" width="35%">
                <asp:Label ID="lbl_persona"
                           runat="server"
                           Text="Persona: "
                           Width="80px">
                </asp:Label>
                
                <asp:HiddenField ID="txt_persona_id" runat="server" Value=''></asp:HiddenField>
                <asp:TextBox ID="txt_persona"
                             runat="server" 
                             Width="200px">
                </asp:TextBox>
                
                <div id="div_persona"></div>
                
                <cc1:AutoCompleteExtender ID="AutoCompleteExtender_Persona" 
                                          runat="server"
	                                      EnableCaching="True" 
	                                      TargetControlID="txt_persona" 
	                                      ServicePath="~/ricerca_persone.asmx"
	                                      ServiceMethod="RicercaPersoneConsiglioRegionale" 
	                                      MinimumPrefixLength="1" 
	                                      CompletionInterval="0"
	                                      CompletionListElementID="div_persona" 
	                                      CompletionSetCount="15" 
		                                  UseContextKey="false" 
                                          OnClientItemSelected="autoCompletePersonaSelected">
	                <Animations>
	                    <OnShow>
		                    <Sequence>
		                        <OpacityAction Opacity='0'></OpacityAction>
		                        <HideAction Visible='true'></HideAction>
		                        <StyleAction Attribute='fontSize' Value='8pt' ></StyleAction>
		                        <Parallel Duration='.15'>
			                        <FadeIn></FadeIn>
		                        </Parallel>
		                    </Sequence>
	                    </OnShow>
	                    
	                    <OnHide>
		                    <Parallel Duration='.15'>
		                        <FadeOut></FadeOut>
		                    </Parallel>
	                    </OnHide>
	                </Animations>
                </cc1:AutoCompleteExtender>
            </td>    
            
            <td align="left" colspan="2">
                <asp:DropDownList ID="ddl_gruppo" 
                                  runat="server" 
                                  Width="500px"
                                  DataTextField="nome_gruppo"
                                  DataValueField="id_gruppo"
                                  DataSourceID="SQLDataSource_Gruppi">
                    <asp:ListItem Text="(tutti)" Value=""></asp:ListItem>
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_Gruppi" 
                                   runat="server" 
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                   
                                   SelectCommand="
                                                SELECT NULL as id_gruppo, '(tutti)' as nome_gruppo
                                                union
                                                SELECT gp.id_gruppo,
                                              gp.nome_gruppo
                                              FROM gruppi_politici gp
                                              inner join join_gruppi_politici_legislature jgpl
                                              on gp.id_gruppo = jgpl.id_gruppo
                                              WHERE gp.deleted = 0 and jgpl.id_legislatura = @id_legislatura
                                              ORDER BY nome_gruppo">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="panelFiltri$ddl_legislatura" 
                                              DefaultValue="0" 
                                              Name="id_legislatura" 
                                              PropertyName="SelectedValue" 
                                              Type="Int32" />
                    </SelectParameters>
                </asp:SqlDataSource>          
            </td> 
            
            <td align="left">
            </td>
            
            <td align="right">
                <asp:Button ID="btn_apply_filter" 
                            runat="server" 
                            Text="Applica" 
                            Width="80px"
                            CausesValidation="true"
                            ValidationGroup="FilterGroup"
                            OnClick="ApplyFilter" />
            </td>                
        </tr> 
        </table>
    </div>
    </asp:Panel>
	
	<div align="center">
	    <asp:GridView ID="GridView1" 
	                  runat="server" 
	                  AllowSorting="false" 
		              AllowPaging="false" 
		              AutoGenerateColumns="False" 
		              CssClass="tab_gen"
		              ShowHeader="false"
                      
		              OnRowDataBound="GridView1_OnRowDataBound" >
		    
		    <EmptyDataTemplate>		    
			    <table width="100%" class="tab_gen">
			    <tr>
				    <th align="center">
				        Nessun record.
				    </th>
			    </tr>
			    </table>
		    </EmptyDataTemplate>
		    
		    <Columns>
		        <asp:BoundField DataField="Cognome" 
			                    SortExpression="Cognome"
			                    ShowHeader="false" 
			                    ItemStyle-HorizontalAlign="Left" />
		        
		        <asp:BoundField DataField="Nome" 
			                    SortExpression="Nome"
			                    ShowHeader="false" 
			                    ItemStyle-HorizontalAlign="Left" />
			    
			    <asp:BoundField DataField="Totale sedute" 
			                    SortExpression="Totale sedute"
			                    ShowHeader="false" 
			                    ItemStyle-Width="90px" 
			                    ItemStyle-HorizontalAlign="Center" />
			                  
		        <asp:BoundField DataField="Presente" 
			                    SortExpression="Presente"
			                    ShowHeader="false" 
			                    ItemStyle-Width="90px" 
			                    ItemStyle-HorizontalAlign="Center" />
			                    
			    <asp:BoundField DataField="Assente" 
			                    SortExpression="Assente"
			                    ShowHeader="false" 
			                    ItemStyle-Width="90px" 
			                    ItemStyle-HorizontalAlign="Center" />
			    
			    <asp:BoundField DataField="Ritardo" 
			                    SortExpression="Ritardo"
			                    ShowHeader="false" 
			                    ItemStyle-Width="90px" 
			                    ItemStyle-HorizontalAlign="Center" />
			                  
			    <asp:BoundField DataField="In Congedo" 
			                    SortExpression="In Congedo"
			                    ShowHeader="false"
			                    ItemStyle-Width="90px" 
			                    ItemStyle-HorizontalAlign="Center" />
		    </Columns>		    
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
	    </asp:SqlDataSource>
	</div>
	
	<br />
	
	<div align="right">
	    <asp:CheckBox ID="chkOptionLandscape" 
                      runat="server"
                      Text="Landscape"  
                      Checked="false" />
                      
        <asp:Label ID="lblGap" 
                   runat="server" 
                   Text="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;">
        </asp:Label>  
              
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
	
</div>

      <script type="text/javascript">

        function autoCompletePersonaSelected(source, eventArgs) {
            var id = eventArgs.get_value();
            var text = eventArgs.get_text();

            //DEBUG ONLY alert(" Text : " + text + "  Value :  " + id);

            $('input[id$=_txt_persona_id').val(id);
        }

      </script>

</asp:Content>