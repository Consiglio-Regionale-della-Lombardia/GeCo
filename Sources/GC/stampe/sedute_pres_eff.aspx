<%@ Page Language="C#"          
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true" 
         EnableEventValidation="false"
         CodeFile="sedute_pres_eff.aspx.cs" 
         Inherits="stampe_sedute_pres_eff" 
         Title="Stampe > Presenze Effettive" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
<asp:ScriptManager ID="ScriptManager1" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>

<b>
    Stampa il numero di Presenze Effettive per ogni Consigliere
</b>

<br />
<br />

<asp:UpdatePanel ID="UpdatePanel1" runat="server">
<ContentTemplate>
    <div class="pannello_ricerca">		        
        <asp:Panel ID="PanelRicerca" runat="server">
            <table width="100%">
            <tr>
	            <td align="left" valign="middle">
	                <asp:Label ID="LabelSearchLegislatura" 
	                           runat="server"
	                           Width="80px"
	                           Text="Legislatura:" >
	                </asp:Label>
    	            
	                <asp:DropDownList ID="ddl_Legislatura" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceLegislature"
		                              DataTextField="num_legislatura" 
		                              DataValueField="id_legislatura" 
		                              Width="70px"
		                              AppendDataBoundItems="True"
		                              AutoPostBack="true" 
		                              OnSelectedIndexChanged="ddl_Legislatura_SelectedIndexChanged"
		                              OnDataBound="ddl_Legislatura_DataBound" >
		                <asp:ListItem Text="(tutte)" Value="" ></asp:ListItem>
	                </asp:DropDownList>
    	            
	                <asp:SqlDataSource ID="SqlDataSourceLegislature" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    				                   
		                               SelectCommand="SELECT id_legislatura, 
		                                                     num_legislatura 
		                                              FROM legislature
		                                              ORDER BY durata_legislatura_da DESC">
	                </asp:SqlDataSource>
	            </td>
    			
			    <td align="left" valign="middle">
                    <asp:Label ID="lbl_tipo_seduta_search" 
	                           runat="server"
	                           Text="Tipo seduta:" >
	                </asp:Label>
    	            
	                <asp:DropDownList ID="ddl_tipo_seduta" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSource_TipoSedute"
		                              DataTextField="tipo_incontro" 
		                              DataValueField="id_incontro"
		                              AppendDataBoundItems="True"
		                              AutoPostBack="false" >
		                <asp:ListItem Text="(tutte)" Value="" ></asp:ListItem>
	                </asp:DropDownList>
    	            
	                <asp:SqlDataSource ID="SqlDataSource_TipoSedute" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    				                   
		                               SelectCommand="SELECT id_incontro,
		                                                     tipo_incontro
                                                      FROM tbl_incontri
                                                      ORDER BY tipo_incontro">
	                </asp:SqlDataSource>
	            </td>
    			
	            <td align="left" valign="middle">
                    <asp:Label ID="LabelSearchData_dal"
	                           runat="server"
	                           Text="DAL:">
	                </asp:Label>
    	            				            
	                <asp:TextBox ID="TextBoxFiltroDAL" 
	                             runat="server" 
	                             Width="70px">
	                </asp:TextBox>
    	            
	                <img alt="calendar" 
	                     src="../img/calendar_month.png" 
	                     id="ImageFiltroDataDAL" 
	                     runat="server" />
    	            
	                <cc1:CalendarExtender ID="CalendarExtender2" 
	                                      runat="server" 
	                                      TargetControlID="TextBoxFiltroDAL"
		                                  PopupButtonID="ImageFiltroDataDAL" 
		                                  Format="dd/MM/yyyy">
	                </cc1:CalendarExtender>
    	            
	                <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
	                                                ControlToValidate="TextBoxFiltroDAL"
		                                            runat="server" 
		                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
		                                            Display="Dynamic"
		                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
		                                            ValidationGroup="FiltroData" >
		            </asp:RegularExpressionValidator>
	            </td>
    					
			    <td align="left" valign="middle">
                    <asp:Label ID="LabelSearchData_al" 
                               runat="server" 
                               Text="AL:">
                    </asp:Label>
                    
                    <asp:TextBox ID="TextBoxFiltroAL" 
                                 runat="server" 
                                 Width="70px">
                    </asp:TextBox>
                    
                    <cc1:CalendarExtender ID="TextBoxFiltroAL_CalendarExtender" 
                                          runat="server" 
                                          Format="dd/MM/yyyy" 
                                          PopupButtonID="ImageFiltroDataAL" 
                                          TargetControlID="TextBoxFiltroAL">
                    </cc1:CalendarExtender>
                    
                    <img alt="calendar" 
	                     src="../img/calendar_month.png" 
	                     id="ImageFiltroDataAL" 
	                     runat="server" />
	                     
                    <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData0" 
                                                    runat="server" 
                                                    ControlToValidate="TextBoxFiltroAL" 
                                                    Display="Dynamic" 
                                                    ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
                                                    ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$" 
                                                    ValidationGroup="FiltroData">
                    </asp:RegularExpressionValidator>
                </td>
    					
			    <td align="right" valign="middle" >
	                <asp:Button ID="ButtonFiltri" 
	                            runat="server" 
	                            Text="Applica" 
	                            Visible="true" 
	                            Width="100"
	                            
	                            OnClick="ButtonFiltri_Click" />
	            </td>        			        								        
            </tr>
            
            <% 
            if (role == 4)
            { 
            %>
            <tr>
                <td align="left" valign="middle" colspan="3">
                    <asp:Label ID="Label_SearchOrg"
		                       runat="server" 
		                       width="80px"
		                       Text="Organo:">
		            </asp:Label>
				            
	                <asp:DropDownList ID="ddl_organi_servcomm" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceOrgani_ServComm"
		                              DataTextField="nome_organo" 
		                              DataValueField="id_organo" 
		                              Width="500px"
		                              AppendDataBoundItems="False" >
	                </asp:DropDownList>
    	            
	                <asp:SqlDataSource ID="SqlDataSourceOrgani_ServComm" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >
	                </asp:SqlDataSource>
                </td>
                
                <td align="left" valign="middle">
                    &nbsp;
                </td>
            </tr>
            <% }
            else if (role == 5)
            { %>
            <tr>
                <td align="left" valign="middle" colspan="3">
                    <asp:Label ID="Label1"
		                       runat="server"
		                       Text="Organo:"
		                       Width="50px" >
		            </asp:Label>
				            
	                <asp:DropDownList ID="ddl_organi_comm" 
	                                  runat="server" 
	                                  DataSourceID="SqlDataSourceOrgani_Comm"
		                              DataTextField="nome_organo" 
		                              DataValueField="id_organo" 
		                              Width="625px"
		                              AppendDataBoundItems="true" >
		                <asp:ListItem Text="(tutti)" Value=""></asp:ListItem>
	                </asp:DropDownList>
    	            
	                <asp:SqlDataSource ID="SqlDataSourceOrgani_Comm" 
	                                   runat="server" 
	                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
	                                   
	                                   SelectCommand="select id_organo, nome_organo from (
                                                        SELECT oo.id_organo AS id_organo, oo.nome_organo,   
                                                             case when oo.id_organo = @id_commissione then 1 else 2 end as Sorting
                                                        FROM organi AS oo 
                                                        WHERE oo.deleted = 0 
                                                        AND (oo.id_organo = @id_commissione OR (oo.comitato_ristretto = 1 AND oo.id_commissione = @id_commissione))
                                                      ) O
                                                      ORDER BY Sorting ASC, nome_organo ASC">
                         <SelectParameters>
                               <asp:SessionParameter Name="id_commissione" 
                                                     Type="Int32" 
                                                     SessionField="logged_organo" />   
                         </SelectParameters>                             
	                </asp:SqlDataSource>
                </td>
            </tr>            
            <% } %>
            
            </table>
	    </asp:Panel>
    </div>

    <asp:GridView ID="GridView1" 
                  runat="server" 
                  AllowSorting="false" 
                  AllowPaging="false" 
                  AutoGenerateColumns="false" 
                  CssClass="tab_gen" 
                  GridLines="None" 
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
            <asp:BoundField DataField="NOME COMPLETO"
                            ShowHeader="false"
                            SortExpression="NOME COMPLETO"
                            ItemStyle-VerticalAlign="Middle" 
                            ItemStyle-HorizontalAlign="Left" />
            
            <asp:BoundField DataField="TOTALE SEDUTE" 
                            ShowHeader="false" 
                            SortExpression="TOTALE SEDUTE"
                            ItemStyle-VerticalAlign="Middle" 
                            ItemStyle-HorizontalAlign="Center" />
            
            <asp:BoundField DataField="PRESENZE EFFETTIVE" 
                            ShowHeader="false" 
                            SortExpression="PRESENZE EFFETTIVE"
                            ItemStyle-VerticalAlign="Middle" 
                            ItemStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
</ContentTemplate>    
</asp:UpdatePanel>

<br />

<div align="right">
    <asp:LinkButton ID="LinkButtonExcel" 
                    runat="server"
                    OnClick="LinkButtonExcel_Click" >
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
</asp:Content>
