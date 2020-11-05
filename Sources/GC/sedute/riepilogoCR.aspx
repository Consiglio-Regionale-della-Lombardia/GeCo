<%@ Page Title="Riepilogo Mensile" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="riepilogoCR.aspx.cs" Inherits="sedute_riepilogoCR" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

	
<asp:Content ID="Content1"
    ContentPlaceHolderID="ContentPlaceHolder1"
    runat="Server">
    <asp:ScriptManager ID="ScriptManager1"
        runat="server"
        EnableScriptGlobalization="True">
    </asp:ScriptManager>
    <table style="width: 98%" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <br />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lbl_title"
                    runat="server"
                    Font-Bold="true"
                    Text="RIEPILOGO MENSILE PRESENZE">
                </asp:Label>
            </td>
        </tr>

        <tr>
            <td>
                <br />
            </td>
        </tr>

        <tr>
            <td>

                <%if (role == 2) %>
                <%{%>
                <div id="tab">
	                <ul>		    
		                <li id="selected">
		                    <a href="riepilogoCR.aspx">
		                        RIEPILOGO UFFICIO DI PRESIDENZA
		                    </a>
		                </li>
		    
		                <li>
		                    <a href="riepilogo_UOPrerogative_giunta_regionale.aspx">
		                        RIEPILOGO GIUNTA REGIONALE
		                    </a>
		                </li>
		                <li>
		                    <a href="riepilogo_UOPrerogative.aspx">
                                <%--RIEPILOGO MENSILE DIARIA E RIMBORSO SPESE--%>
		                        RIEPILOGO MENSILE
		                    </a>
		                </li>
	                </ul>
	            </div>
                <div id="tab_content">
	                <div id="tab_content_content">
                <%}%>
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <div style="background-color: #F0F0F0; padding: 10px;">
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:Label ID="lbl_search_legislatura"
                                            runat="server"
                                            Text="Seleziona Legislatura: ">
                                        </asp:Label>

                                        <asp:DropDownList ID="ddl_search_legislatura"
                                            runat="server"
                                            AppendDataBoundItems="true"
                                            DataSourceID="SqlDataSource_Legislature"
                                            DataValueField="id_legislatura"
                                            DataTextField="num_legislatura">
                                            <asp:ListItem Text="(seleziona)" Value=""></asp:ListItem>
                                        </asp:DropDownList>

                                        <asp:RequiredFieldValidator ID="ReqVal_Legislatura"
                                            runat="server"
                                            ControlToValidate="ddl_search_legislatura"
                                            Display="Dynamic"
                                            ErrorMessage="*"
                                            ValidationGroup="GroupRiepilogo">
                                        </asp:RequiredFieldValidator>

                                        <asp:SqlDataSource ID="SqlDataSource_Legislature"
                                            runat="server"
                                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                            SelectCommand="SELECT id_legislatura, 
				                                                         num_legislatura 
				                                                  FROM legislature
				                                                  ORDER BY durata_legislatura_da DESC"></asp:SqlDataSource>
                                    </td>

                                    <td align="left" valign="middle">
                                        <asp:Label ID="lbl_year"
                                            runat="server"
                                            Text="Seleziona Anno: ">
                                        </asp:Label>

                                        <asp:DropDownList ID="DropDownListAnnoRiepilogo"
                                            runat="server"
                                            DataSourceID="SqlDataSourceAnniRiepilogo"
                                            DataTextField="anno"
                                            DataValueField="anno"
                                            Width="100px">
                                        </asp:DropDownList>

                                        <asp:SqlDataSource ID="SqlDataSourceAnniRiepilogo"
                                            runat="server"
                                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                            SelectCommand="SELECT anno 
					                                              FROM tbl_anni 
					                                              WHERE (anno &gt; YEAR(GETDATE()) - 25) 
					                                                AND (anno &lt;= YEAR(GETDATE())) 
					                                              ORDER BY anno DESC"></asp:SqlDataSource>
                                    </td>

                                    <td align="left" valign="middle">
                                        <asp:Label ID="lbl_month"
                                            runat="server"
                                            Text="Seleziona Mese: ">
                                        </asp:Label>

                                        <asp:DropDownList ID="DropDownListMeseRiepilogo"
                                            runat="server"
                                            Width="100px">
                                            <asp:ListItem Text='(seleziona)' Value=''></asp:ListItem>
                                            <asp:ListItem Text='1' Value='1'>Gennaio</asp:ListItem>
                                            <asp:ListItem Text='2' Value='2'>Febbraio</asp:ListItem>
                                            <asp:ListItem Text='3' Value='3'>Marzo</asp:ListItem>
                                            <asp:ListItem Text='4' Value='4'>Aprile</asp:ListItem>
                                            <asp:ListItem Text='5' Value='5'>Maggio</asp:ListItem>
                                            <asp:ListItem Text='6' Value='6'>Giugno</asp:ListItem>
                                            <asp:ListItem Text='7' Value='7'>Luglio</asp:ListItem>
                                            <asp:ListItem Text='8' Value='8'>Agosto</asp:ListItem>
                                            <asp:ListItem Text='9' Value='9'>Settembre</asp:ListItem>
                                            <asp:ListItem Text='10' Value='10'>Ottobre</asp:ListItem>
                                            <asp:ListItem Text='11' Value='11'>Novembre</asp:ListItem>
                                            <asp:ListItem Text='12' Value='12'>Dicembre</asp:ListItem>
                                        </asp:DropDownList>

                                        <asp:RequiredFieldValidator ID="RequiredFieldValidatorDropDownListMeseRiepilogo"
                                            runat="server"
                                            ErrorMessage="*"
                                            ControlToValidate="DropDownListMeseRiepilogo"
                                            Display="Dynamic"
                                            ValidationGroup="GroupRiepilogo">
                                        </asp:RequiredFieldValidator>
                                    </td>

                                    <td align="right" valign="middle">
                                        <asp:Button ID="ButtonRiepilogo"
                                            runat="server"
                                            Text="Visualizza"
                                            CausesValidation="true"
                                            ValidationGroup="GroupRiepilogo"
                                            OnClick="ButtonRiepilogo_Click" />
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <asp:GridView ID="GridView1"
                            runat="server"
                            CssClass="tab_gen"
                            AutoGenerateColumns="False"
                            DataKeyNames="id_seduta"
                            DataSourceID="SqlDataSource1">

                            <EmptyDataTemplate>
                                <table width="100%" class="tab_gen">
                                    <tr>
                                        <th align="center">Nessun record trovato.
                                        </th>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>

                            <Columns>
                                <asp:TemplateField HeaderText="DATA ORA RIUNIONE">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblInfoSeduta"
                                            Font-Bold="true"
                                            Text='<%# Eval("info_seduta") %>'>
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="12%" HorizontalAlign="Center" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri firmatari del foglio ricognitivo">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol1">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri firmatari del solo foglio partecipanti alle sedute">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol2">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri assenti">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol3">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri presenti a incontri, consultazioni, ecc">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol4">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri in missione">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol5">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:GridView ID="GridView2" Visible="false"
                            runat="server"
                            CssClass="tab_gen"
                            AutoGenerateColumns="False"
                            DataKeyNames="id_seduta"
                            DataSourceID="SqlDataSource1">

                            <EmptyDataTemplate>
                                <table width="100%" class="tab_gen">
                                    <tr>
                                        <th align="center">Nessun record trovato.
                                        </th>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>

                            <Columns>
                                <asp:TemplateField HeaderText="Data e ora riunione">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblInfoSeduta"
                                            Font-Bold="true"
                                            Text='<%# Eval("info_seduta") %>'>
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="12%" HorizontalAlign="Center" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri presenti risultanti dal foglio “rimborso forfettario” (commissione prioritaria)">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol1">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri assenti risultanti dal foglio “rimborso forfettario” (commissione prioritaria) ">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol2">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri componenti presenti ai sensi dell’art. 3 della DUP 106/2014">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol3">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri sostituti ai sensi dell’art. 27, comma 4 del Regolamento">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol4a">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri presenti a incontri, audizioni, consultazioni, ecc">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol4">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri in missione">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol5">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:GridView ID="GridViewDup53"
                            runat="server"
                            CssClass="tab_gen"
                            AutoGenerateColumns="False"
                            DataKeyNames="id_seduta"
                            DataSourceID="SqlDataSourceDup53"
                            OnRowDataBound="grdViewDup53_RowDataBound"
                            onrowcreated="grdViewDup53_RowCreated" 
                            Visible="false">

                            <EmptyDataTemplate>
                                <table width="100%" class="tab_gen">
                                    <tr>
                                        <th align="center">Nessun record trovato.
                                        </th>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>

                            <Columns>
                                <asp:TemplateField HeaderText="Data e ora riunione">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblInfoSeduta"
                                            Font-Bold="true"
                                            Text='<%# Eval("info_seduta") %>'>
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="12%" HorizontalAlign="Center" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Una firma">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol1">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Due firme">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol2">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Una firma">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol3">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Due firme">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol4">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

<%--                                <asp:TemplateField HeaderText="Nessuna firma">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol5">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>--%>

                                <asp:TemplateField HeaderText="I° Prioritaria">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol5a">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="II° Prioritaria">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol5b">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri<br />presenti<br />(impegno non prioritario)<br /><br />Seduta">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol6">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sostituto">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol7">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sostituito">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol8">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Una firma">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol9">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="22%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:GridView ID="GridView3" Visible="false"
                            runat="server"
                            CssClass="tab_gen"
                            AutoGenerateColumns="False"
                            DataKeyNames="id_seduta"
                            DataSourceID="SqlDataSource1">

                            <EmptyDataTemplate>
                                <table width="100%" class="tab_gen">
                                    <tr>
                                        <th align="center">Nessun record trovato.
                                        </th>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>

                            <Columns>
                                <asp:TemplateField HeaderText="Data e ora riunione">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblInfoSeduta"
                                            Font-Bold="true"
                                            Text='<%# Eval("info_seduta") %>'>
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="12%" HorizontalAlign="Center" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri presenti ad entrambe le rilevazioni">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol1">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri che non hanno sottoscritto il foglio firma di rilevazione in ingresso">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol2">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Consiglieri che non hanno sottoscritto il foglio firma di rilevazione in uscita">
                                    <ItemTemplate>
                                        <asp:Label runat="server"
                                            ID="lblCol3">
                                        </asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle Width="18%" HorizontalAlign="Left" VerticalAlign="Top" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:SqlDataSource ID="SqlDataSource1"
                            runat="server"
                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>

                        <asp:SqlDataSource ID="SqlDataSourceDup53"
                            runat="server"
                            ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"></asp:SqlDataSource>

                    </ContentTemplate>
                </asp:UpdatePanel>
                <%if (role == 2)%>
                <%{%>
                </div>
                </div>
                <%}%>

                <br />

                <div align="right">
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
                <%--
		        <asp:LinkButton ID="LinkButtonPdf"
                    runat="server"
                    OnClientClick="alert('Funzione non disponibile per manutenzione.');">
		            <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
			        Esporta
                </asp:LinkButton>
                 --%>

                </div>

                <div align="center">
                    <asp:Button ID="ButtonInvia"
                        runat="server"
                        Text="Invia i fogli presenze di questo mese"
                        OnClick="ButtonInvia_Click"
                        OnClientClick="return confirm ('Confermare tutti i fogli presenza del mese selezionato?\nNon sarà più possibile effettuare ulteriori modifiche al foglio presenze.');" />
                </div>
            </td>
        </tr>

        <tr>
            <td>
                <br />
            </td>
        </tr>
    </table>
</asp:Content>

