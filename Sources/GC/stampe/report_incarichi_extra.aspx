<%@ Page Language="C#" 
         AutoEventWireup="true" 
         MasterPageFile="~/MasterPage.master" 
         CodeFile="report_incarichi_extra.aspx.cs" 
         Inherits="report_incarichi_extra" 
         Title="STAMPE > Incarichi Extra Istituzionali" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
    <asp:ScriptManager ID="ScriptManager2" 
		                runat="server" 
		                EnableScriptGlobalization="True">
	</asp:ScriptManager>

    <asp:Label ID="lblTitle" 
               runat="server"
               Text="Report Incarichi Extra Istituzionali"
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
            <tr>
                <td align="left">
                    <asp:Label ID="lblLegislatura" 
                               runat="server"
                               Text="Legislatura: ">
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
    	            <asp:Label ID="lblNominativo" 
                               runat="server"
                               Text="Nominativo: " >
                    </asp:Label> 
    	        
    	            <asp:DropDownList ID="ddlNominativo" 
                                      runat="server"	                      
                                      AppendDataBoundItems="true" 
                                      DataTextField="nominativo"
                                      DataValueField="id_persona"	                         
                                      DataSourceID="SQLDataSource_ddlNominativo">	
                    
                        <asp:ListItem Text="(tutti)" Value=""></asp:ListItem>    	        
                    </asp:DropDownList>
                
                    <asp:SqlDataSource ID="SQLDataSource_ddlNominativo" 
                                       runat="server"
                                       ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"                     
        	                       
                                       SelectCommand="SELECT DISTINCT pp.id_persona,
                                                                      pp.cognome + ' ' + pp.nome AS nominativo
                                                      FROM persona AS pp
                                                      --INNER JOIN scheda AS sc
                                                         --ON pp.id_persona = sc.id_persona
                                                      WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                                        --AND sc.deleted = 0
                                                      ORDER BY nominativo" >
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
            <tr>
                <td colspan="3" valign="middle" style="padding-top:10px;">
                    <asp:Label ID="Label1"
				                runat="server"
				                Width="120px" 
				                Text="Data dichiarazione">
				    </asp:Label>
				            
				    <asp:Label ID="Label2"
				                runat="server" 
				                Text="dal: ">
				    </asp:Label>
				            			            				            				            
				    <asp:TextBox ID="txtStartDate_Search" 
				                    runat="server" 
				                    Width="70px">
				    </asp:TextBox>
				            
				    <img alt="calendar" 
				            src="../img/calendar_month.png" 
				            id="ImageStartDate_Search" 
				            runat="server" style="vertical-align: middle;" />
				            
				    <cc1:CalendarExtender ID="CalendarExtender1" 
				                            runat="server" 
				                            TargetControlID="txtStartDate_Search"
					                        PopupButtonID="ImageStartDate_Search" 
					                        Format="dd/MM/yyyy">
				    </cc1:CalendarExtender>				            				            
				            
				    <asp:RegularExpressionValidator ID="RegularExpressionValidator_StartDate" 
				                                    ControlToValidate="txtStartDate_Search"
					                                runat="server" 
					                                ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                                Display="Dynamic"
					                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                                ValidationGroup="FiltroData" >
					</asp:RegularExpressionValidator>
					        
					<asp:Label ID="Label5"
				                runat="server"
				                Width="30px"
				                Text="&nbsp;">
				    </asp:Label>
					        
					<asp:Label ID="Label3"
				                runat="server" 
				                Text="al: ">
				    </asp:Label>
				            
				    <asp:TextBox ID="txtEndDate_Search" 
				                    runat="server" 
				                    Width="70px">
				    </asp:TextBox>
				            
				    <img alt="calendar" 
				            src="../img/calendar_month.png" 
				            id="ImageEndDate_Search" 
				            runat="server" style="vertical-align: middle;" />
				            
				    <cc1:CalendarExtender ID="CalendarExtender3" 
				                            runat="server" 
				                            TargetControlID="txtEndDate_Search"
					                        PopupButtonID="ImageEndDate_Search" 
					                        Format="dd/MM/yyyy">
				    </cc1:CalendarExtender>				            				            
				            
				    <asp:RegularExpressionValidator ID="RegularExpressionValidator_EndDate" 
				                                    ControlToValidate="txtEndDate_Search"
					                                runat="server" 
					                                ErrorMessage="Ammessi solo valori GG/MM/AAAA." 
					                                Display="Dynamic"
					                                ValidationExpression="^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$"
					                                ValidationGroup="FiltroData" >
					</asp:RegularExpressionValidator>

                    <asp:Label ID="Label4"
				                runat="server"  style="margin-left:50px;"
				                Text="Incarico:">
				    </asp:Label>
				            
				    <asp:TextBox ID="TextBoxIncarico" 
				                    runat="server" 
				                    Width="300px">
				    </asp:TextBox>
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
		              AutoGenerateColumns="false" 
		              CssClass="tab_gen"		                
		              DataSourceID="SqlDataSource1"
		              DataKeyNames="id_scheda" >
		    
		    <EmptyDataTemplate>
			    <table width="100%" class="tab_gen">
			    <tr>
				    <th align="center">
				        Nessuna scheda trovata.
				    </th>				    
			    </tr>
			    </table>
		    </EmptyDataTemplate>
		    		    
		    <Columns>
		        <asp:BoundField DataField="num_legislatura" 
		                        HeaderText="LEGISLATURA" 
			                    SortExpression="num_legislatura" 
			                    ItemStyle-HorizontalAlign="Center"
			                    ItemStyle-Width="70px"/>
			                    
		        <asp:BoundField DataField="nominativo" 
		                        HeaderText="NOMINATIVO" 
			                    SortExpression="nominativo" 
			                    ItemStyle-HorizontalAlign="Left" />		        		        
		        
		        <asp:BoundField DataField="data_dichiarazione" 
		                        HeaderText="DATA DICHIARAZIONE" 
			                    SortExpression="data_dichiarazione" 
			                    ItemStyle-HorizontalAlign="Center" 
			                    ItemStyle-Width="160px" />
			    
			    <asp:BoundField DataField="info_seduta" 
		                        HeaderText="SEDUTA" 
			                    SortExpression="info_seduta" 
			                    ItemStyle-HorizontalAlign="Center"
			                    ItemStyle-Width="160px" />	        		        	                                    		        		        		       			    			    
		    </Columns>
	    </asp:GridView>
	
	    <asp:SqlDataSource ID="SqlDataSource1" 
	                       runat="server" 
		                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>" >		                   
	    </asp:SqlDataSource>
	
	</div>
	
	<% if (printable) { %>
	<br />
	
	<div align="right">
	    <asp:LinkButton ID="LinkButtonPdf" 
	                    runat="server" 
	                    
	                    OnClick="LinkButtonPdf_Click">
	        <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
	        Stampa
	    </asp:LinkButton>	    	    
	</div>
	<% } %>
</div>
</asp:Content>