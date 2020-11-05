<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_cariche.aspx.cs" 
         Inherits="report_cariche" 
         Title="STAMPE > Report Cariche" %>

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
               Text="Report Cariche"
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
            <td align="left" width="21%" >
                <asp:Label ID="lblLegislatura" 
                           runat="server"
                           Text="Legislatura: "
                           Width="80px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlLegislatura" 
                                  runat="server"	                      
                                  AppendDataBoundItems="true" 
                                  DataTextField="num_legislatura"
                                  DataValueField="id_legislatura"	                         
                                  DataSourceID="SQLDataSource_ddlLegislatura">	    	        
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
                <asp:Label ID="lblOrgano" 
                           runat="server"
                           Text="Organo: ">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlOrgano" 
                                  runat="server"	  
                                  Width="530px"                     
                                  AppendDataBoundItems="true" 
                                  DataTextField="leg_nome_organo"
                                  DataValueField="id_organo"	                         
                                  DataSourceID="SQLDataSource_ddlOrgano" >
                                   
                    <asp:ListItem Text="(tutti)" Value="0"></asp:ListItem>   	        
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlOrgano" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                   SelectCommand="SELECT oo.id_organo, 
                                                         ll.num_legislatura + ' - ' + oo.nome_organo AS leg_nome_organo
                                                  FROM organi AS oo
                                                  INNER JOIN legislature AS ll
                                                    ON oo.id_legislatura = ll.id_legislatura
                                                  WHERE oo.deleted = 0
                                                  ORDER BY ll.durata_legislatura_da DESC,
                                                           oo.nome_organo ASC" >
                </asp:SqlDataSource>
            </td>            
        </tr>
        </table>
        
        <table width="100%">
        <tr align="left">
            <td align="left" width="21%">
                <asp:Label ID="lblStatoCariche" 
                           runat="server"
                           Text="Stato carica: "
                           Width="80px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlStatoCariche" 
                                  runat="server" >                                     
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                    <asp:ListItem Text="In carica" Value="1"></asp:ListItem>
                    <asp:ListItem Text="Non in carica" Value="2"></asp:ListItem>
                </asp:DropDownList>
            </td>         
            
            <td align="left" width="28%">
                <asp:Label ID="lblCarica" 
                           runat="server"
                           Text="Carica: ">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlCarica" 
                                  runat="server" >                                     
                    <asp:ListItem Text="(tutte)" Value="0"></asp:ListItem>
                    <asp:ListItem Text="Presidente" Value="1"></asp:ListItem>
                    <asp:ListItem Text="Vice Presidente" Value="2"></asp:ListItem>
                    <asp:ListItem Text="Componente" Value="3"></asp:ListItem>
                    <asp:ListItem Text="Presidente e Vice Presidente" Value="4"></asp:ListItem>
                    <asp:ListItem Text="Presidente e Componente" Value="5"></asp:ListItem>
                    <asp:ListItem Text="Vice Presidente e Componente" Value="6"></asp:ListItem>
                </asp:DropDownList>
            </td>                               
            
            <td align="left" width="19%">
	            <asp:Label ID="lblNoConsigliere" 
                           runat="server"
                           Text="Solo se non consigliere">
                </asp:Label>
        
	            <asp:CheckBox ID="chkNoConsigliere" 
	                          runat="server" 
	                          Checked="false" />
	        </td>                          
    	    
            <td align="left">
	            <asp:Label ID="lblData" 
                           runat="server"
                           Text="Data: ">
                </asp:Label>
                <asp:TextBox ID="TextBoxFiltroData" 
                             runat="server"                              
	                         Width="70px">
	            </asp:TextBox>
                <img alt="calendar" 
                     src="../img/calendar_month.png" 
                     id="ImageFiltroData" 
                     runat="server" />                
                <cc1:CalendarExtender ID="CalendarExtenderFiltroData" 
                                      runat="server" 
                                      TargetControlID="TextBoxFiltroData"
	                                  PopupButtonID="ImageFiltroData" 
	                                  Format="dd/MM/yyyy" >
	            </cc1:CalendarExtender>
                <asp:RegularExpressionValidator ID="RequiredFieldValidatorFiltroData" 
                                                ControlToValidate="TextBoxFiltroData"
	                                            runat="server" 
	                                            ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
	                                            Display="Dynamic"
	                                            ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
	                                            ValidationGroup="FiltroData" />
	        </td>       
        </tr> 
        </table>
        
        <table width="100%">
        <tr align="left">
            <td align="left">
                <asp:Label ID="lblGruppo" 
                           runat="server"
                           Text="Gruppo: "
                           Width="80px">
                </asp:Label> 
                
                <asp:DropDownList ID="ddlGruppo" 
                                  runat="server"	  
                                  Width="700"                     
                                  AppendDataBoundItems="true" 
                                  DataTextField="nomegruppo"
                                  DataValueField="id_gruppo"	                         
                                  DataSourceID="SQLDataSource_ddlGruppo" >
                                   
                    <asp:ListItem Text="(tutti)" Value="0"></asp:ListItem>   	        
                </asp:DropDownList>
                
                <asp:SqlDataSource ID="SQLDataSource_ddlGruppo" 
                                   runat="server"
                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                   SelectCommand="SELECT id_gruppo, 
                                                         LTRIM(RTRIM(nome_gruppo)) AS nomegruppo
                                                  FROM gruppi_politici
                                                  WHERE deleted = 0
                                                  ORDER BY nomegruppo">
                </asp:SqlDataSource>
            </td>    
            
            <td align="right">
                <asp:Button ID="btnApplicaFiltro" 
                            runat="server" 
                            Text="Applica Filtri" 
                            Width="102"
                            OnClick="ApplyFilter" />
            </td>                
        </tr> 
        </table>        
        
        <br />
        
        <asp:Label ID="lblVisibilityTitle" 
                   runat="server"
                   Text="VISUALIZZA:"
                   Font-Bold="true"
                   ValidationGroup="FiltroData" >
        </asp:Label>
        
        <table width="100%">
	    <tr align="left">
	        <td align="right" width="20%">
	            <asp:Label ID="lblChkGruppo" 
                           runat="server"
                           Text="Gruppo Consiliare">
                </asp:Label>
        
	            <asp:CheckBox ID="chkVis_Gruppo" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <%--<td width="50"></td>--%>
	        
	        <td align="right" width="20%">
	            <asp:Label ID="lblChkDate" 
                           runat="server" 
                           Text="Date">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Date" 
	                          runat="server" 
	                          Checked="true" />
	        </td>
	        
	        <%--<td width="50"></td>--%>
	        
	        <td align="right" width="20%">
	            <asp:Label ID="lblChkRecapiti" 
                           runat="server"
                           Text="Recapiti">
                </asp:Label>
                
	            <asp:CheckBox ID="chkVis_Recapiti" 
	                          runat="server" 
	                          Checked="true" />
	        </td>	       
	        
	        <%--<td width="450"></td>--%>
	        
	        <td align="right">
	            <asp:Button ID="btnVisualization" 
                            runat="server" 
                            Text="Applica Vis."
                            Width="102" 
                            OnClick="ApplyVisualization" />
	        </td>	        
	    </tr>
	    </table>
	    
	    <br />
	    
	    <asp:Label ID="lblOrdinamento"
	               runat="server"
	               Text="ORDINAMENTO:"
	               Font-Bold="true">
	    </asp:Label>
	    
	    <table width="100%">
	    
	        <tr align="left">
	    
	            <td align="right" width="20%">
	                <asp:Label ID="lblOrdCognome"
	                           runat="server"
	                           Text="Cognome">
	                </asp:Label>
	                <asp:CheckBox ID="chbOrdCognome"
	                              runat="server"/>
	            </td>
                
                <td align="right" width="20%">
                    <asp:Label ID="lblOrdGruppo"
                               runat="server"
                               Text="Gruppo">
                    </asp:Label>
                    <asp:CheckBox ID="chbOrdGruppo"
                                  runat="server"/>
                </td>	    
                
                <td align="right" width="20%">
                   <asp:Label ID="lblOrdCarica"
                              runat="server"
                              Text="Carica">
                   </asp:Label>
                   <asp:CheckBox ID="chbOrdCarica"
                                 runat="server"/>
                </td>
                
                <td align="right">
                    <asp:Button ID="btnApplyOrder"
                                runat="server"
                                Width="102"
                                Text="Applica Ord."
                                OnClick="ApplyOrder" />
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
		              PagerStyle-HorizontalAlign="Center" 
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
		    
		    <%--versione per datatable--%>
		    <Columns>
		        <asp:BoundField DataField="CARICA" 
			                    SortExpression="CARICA"
			                    ShowHeader="false"  
			                    ItemStyle-HorizontalAlign="left" />		        
		    
		        <asp:BoundField DataField="COGNOME" 
			                    SortExpression="COGNOME" 
			                    ShowHeader="false"
			                    ItemStyle-HorizontalAlign="left" />
		        
		        <asp:BoundField DataField="NOME" 
		                        SortExpression="NOME" 
		                        ShowHeader="false"
		                        ItemStyle-HorizontalAlign="left" />
		        
		        <asp:BoundField DataField="DAL" 
			                    SortExpression="DAL" 
			                    ShowHeader="false"
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="70px"/>
			    
			    <asp:BoundField DataField="AL" 
			                    SortExpression="AL" 
			                    ShowHeader="false"
			                    ItemStyle-HorizontalAlign="center" 
			                    ItemStyle-Width="70px"/>
			    
			    <asp:BoundField DataField="INDIRIZZO" 
			                    SortExpression="INDIRIZZO" 
			                    ShowHeader="false"
			                    ItemStyle-HorizontalAlign="left"/>
			                    
                <asp:BoundField DataField="TEL/FAX" 		                         
			                    SortExpression="TEL/FAX"	
			                    ShowHeader="false"		                     
			                    ItemStyle-HorizontalAlign="left"/>			                    
			                    
                <asp:BoundField DataField="EMAIL" 		                         
			                    SortExpression="EMAIL"	
			                    ShowHeader="false"		                     
			                    ItemStyle-HorizontalAlign="left"/>	
			                                    			                                
		        <asp:BoundField DataField="GRUPPO CONSILIARE" 		                        
			                    SortExpression="GRUPPO CONSILIARE"
			                    ShowHeader="false" 
			                    ItemStyle-HorizontalAlign="left"/>
		    </Columns>		    
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" 
		                   
		                   SelectCommand="" >		                   
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
</asp:Content>