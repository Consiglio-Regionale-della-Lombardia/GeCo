<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master"
         AutoEventWireup="true" 
         EnableEventValidation="false"
         CodeFile="persona_assessori.aspx.cs" 
         Inherits="persona_assessori" 
         Title="Assessori > Ricerca" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>
             
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div id="content">
<asp:ScriptManager ID="ScriptManager1" 
                   runat="server" 
                   EnableScriptGlobalization="True">
</asp:ScriptManager>

<b>Assessori &gt; RICERCA</b>

<br />
<br />

<asp:UpdatePanel ID="UpdatePanel1" runat="server">
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
	    
	    <table width="100%">
	    <tr>
		    <td align="left" valign="middle">
		        Nome:
		        <asp:TextBox ID="TextBoxRicNome" 
		                     runat="server" 
		                     Width="150px">
		        </asp:TextBox>
		    </td>
		    
		    <td align="left" valign="middle">
		        Cognome:
		        <asp:TextBox ID="TextBoxRicCognome" 
		                     runat="server" 
		                     Width="150px">
		        </asp:TextBox>
		    </td>
		    
		    <td align="left" valign="middle">
		        Legislatura:
		        <asp:DropDownList ID="DropDownListRicLeg" 
		                          runat="server" 
		                          DataSourceID="SqlDataSourceLegislature"
			                      DataTextField="num_legislatura" 
			                      DataValueField="id_legislatura" 
			                      Width="70px"
			                      AppendDataBoundItems="true">
			        <asp:ListItem Text="(tutte)" Value="" />
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
		    
		    <td align="right" valign="middle">
		        <asp:Button ID="ButtonRic" 
		                    runat="server" 
		                    Text="Applica" 
		                    CssClass="button"
		                    OnClick="ButtonRic_Click" />
		    </td>
	    </tr>
	    </table>
    </asp:Panel>
</div>

<asp:GridView ID="GridView1" 
              runat="server" 
              AllowPaging="True" 
              AllowSorting="True" 
              PagerStyle-HorizontalAlign="Center"
              AutoGenerateColumns="False"		             
              CssClass="tab_gen" 
              GridLines="None" 
              DataSourceID="SqlDataSource1" 
              		                
              OnRowDataBound="GridView1_RowDataBound" >
              
    <EmptyDataTemplate>
	    <table width="100%" class="tab_gen">
	    <tr>
		    <th align="center">
		        Nessun record trovato.
		    </th>
		    
		    <th width="100">
		        <% if (role <= 2) { %>
		        <asp:Button ID="Button1" 
		                    runat="server" 
		                    Text="Nuovo..." 
		                    OnClick="Button1_Click" 
		                    CssClass="button"
			                CausesValidation="false" />
		        <% } %>
		    </th>
	    </tr>
	    </table>
    </EmptyDataTemplate>
    <AlternatingRowStyle BackColor="#b2cca7" />	
    <Columns>
	    <asp:TemplateField HeaderText="Legislatura" SortExpression="num_legislatura">
	        <ItemTemplate>
	            <asp:LinkButton ID="lnkbtn_leg" 
	                            runat="server"
	                            Text='<%# Eval("num_legislatura") %>'
	                            Font-Bold="true"
	                            onclientclick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>' >
	            </asp:LinkButton>
	        </ItemTemplate>
	        
	        <ItemStyle HorizontalAlign="center" 
	                   VerticalAlign="Middle"
	                   Width="80px" />
	    </asp:TemplateField>
	    
	    <asp:BoundField DataField="cognome" 
	                    HeaderText="Cognome" 
	                    SortExpression="cognome" 
	                    ItemStyle-Width="120px" 
	                    ItemStyle-VerticalAlign="Middle" />
	    
	    <asp:BoundField DataField="nome" 
	                    HeaderText="Nome" 
	                    SortExpression="nome" 
	                    ItemStyle-Width="120px" 
	                    ItemStyle-VerticalAlign="Middle" />
	    
	    <asp:BoundField DataField="nome_carica" 
	                    HeaderText="Carica" 
	                    SortExpression="nome_carica" 
	                    ItemStyle-Width="220px" 
	                    ItemStyle-VerticalAlign="Middle" />
	    
	    <asp:BoundField DataField="data_nascita" 
	                    HeaderText="Data Nascita" 
	                    SortExpression="data_nascita"
	                    DataFormatString="{0:dd/MM/yyyy}" 
	                    ItemStyle-HorizontalAlign="center" 
	                    ItemStyle-VerticalAlign="Middle" 
	                    ItemStyle-Width="90px" />
	    
	    <asp:BoundField HeaderText="Comune nascita" 
	                    DataField="nome_comune" 
	                    SortExpression="nome_comune" 
	                    ItemStyle-VerticalAlign="Middle" />    	        
	    
	    <%--NavigateUrl='<%# Eval("id_persona", "dettaglio_assessori.aspx?mode=normal&id={0}") %>'--%>
	    <asp:TemplateField>
	        <ItemTemplate>
		        <asp:HyperLink ID="HyperLinkDettagli" 
		                       runat="server" 
		                       NavigateUrl='<%# "dettaglio_assessori.aspx?mode=normal&id=" +  Eval("id_persona") + "&sel_leg_id=" + Eval("id_legislatura") %>'
		                       Text="Dettagli">
		        </asp:HyperLink>				        
	        </ItemTemplate>
	        
	        <HeaderTemplate>
		        <% if (role <= 2) { %>
		        <asp:Button ID="Button1" 
		                    runat="server" 
		                    OnClick="Button1_Click" 
		                    Text="Nuovo..." 
		                    CssClass="button" />
		        <% } %>
	        </HeaderTemplate>
	        
	        <ItemStyle HorizontalAlign="Center" 
	                   VerticalAlign="Middle" 
	                   Width="60px" />
	    </asp:TemplateField>
    </Columns>
</asp:GridView>

<asp:SqlDataSource ID="SqlDataSource1" 
                   runat="server" 
                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                   
                   SelectCommand="">
</asp:SqlDataSource>
</ContentTemplate>
</asp:UpdatePanel>

<br />

<div align="right">
    <asp:LinkButton ID="LinkButtonExcel" 
                    runat="server" 
                    OnClick="LinkButtonExcel_Click">
        <img src="../img/page_white_excel.png" 
             alt="" 
             align="top" /> 
        Esporta
    </asp:LinkButton>
    -
    <asp:LinkButton ID="LinkButtonPdf" 
                    runat="server" 
                    OnClick="LinkButtonPdf_Click">
        <img src="../img/page_white_acrobat.png" 
             alt="" 
             align="top" /> 
        Esporta
    </asp:LinkButton>      
</div>
</div>
</asp:Content>