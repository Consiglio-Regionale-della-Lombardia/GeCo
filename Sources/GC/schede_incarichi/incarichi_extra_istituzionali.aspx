<%@ Page Language="C#"
    MasterPageFile="~/MasterPage.master"
    AutoEventWireup="true"
    CodeFile="incarichi_extra_istituzionali.aspx.cs"
    Inherits="incarichi_extra_istituzionali"
    Title="Incarichi Extra Istituzionali" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>


<%@ Register src="incarichi_scheda.ascx" tagname="incarichi_scheda" tagprefix="inc" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ScriptManager ID="ScriptManager_1"
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
            <td align="left" valign="middle">
                <asp:Label ID="lbl_title"
                    runat="server"
                    Text="INCARICHI EXTRA ISTITUZIONALI"
                    Font-Bold="true">
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
                <div class="pannello_ricerca">
                    <table width="100%">
                        <tr>
                            <td align="left" valign="middle">
                                <asp:Label ID="lbl_search_legislatura"
                                    runat="server"
                                    Text="Legislatura: ">
                                </asp:Label>

                                <asp:DropDownList ID="ddl_search_legislatura"
                                    runat="server"
                                    AutoPostBack="true"
                                    AppendDataBoundItems="false"
                                    DataSourceID="SqlDataSource_Search_Legislature"
                                    DataTextField="num_legislatura"
                                    DataValueField="id_legislatura"
                                    OnSelectedIndexChanged="legislatura_selected">
                                </asp:DropDownList>

                                <%--				    <asp:RegularExpressionValidator ID="REV_search_legislatura" 
				                                    runat="server"
				                                    ControlToValidate="ddl_search_legislatura"
				                                    Display="Dynamic"
				                                    ErrorMessage="*"
				                                    ValidationExpression="^([1-9]+)$"
				                                    ValidationGroup="ValGroup_New" >
				    </asp:RegularExpressionValidator>--%>

                                <asp:SqlDataSource ID="SqlDataSource_Search_Legislature"
                                    runat="server"
                                    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                    SelectCommand="SELECT 0 AS id_legislatura,
		                                                     '(seleziona)' AS num_legislatura,
		                                                     '30001231' AS durata_legislatura_da
		                                              UNION
			                                          SELECT id_legislatura, 
			                                                 num_legislatura,
			                                                 durata_legislatura_da 
			                                          FROM legislature
			                                          ORDER BY durata_legislatura_da DESC"></asp:SqlDataSource>
                            </td>

                            <td align="left" valign="middle">
                                <asp:Label ID="lbl_search_persona"
                                    runat="server"
                                    Text="Consigliere: ">
                                </asp:Label>

                                <asp:DropDownList ID="ddl_search_persona"
                                    runat="server"
                                    AutoPostBack="true"
                                    AppendDataBoundItems="false"
                                    DataSourceID="SqlDataSource_Persone"
                                    DataTextField="nome_completo"
                                    DataValueField="id_persona"
                                    Width="200px"
                                    OnSelectedIndexChanged="persona_selected">
                                </asp:DropDownList>

                                <asp:RegularExpressionValidator ID="REV_persona"
                                    runat="server"
                                    ControlToValidate="ddl_search_persona"
                                    Display="Dynamic"
                                    ErrorMessage="*"
                                    ValidationExpression="^\d+$"
                                    ValidationGroup="ValGroup_New">
                                </asp:RegularExpressionValidator>

                                <asp:SqlDataSource ID="SqlDataSource_Persone"
                                    runat="server"
                                    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                    SelectCommand="SELECT -1 AS id_persona,
		                                                     '(seleziona)' AS nome_completo
		                                              UNION
			                                          SELECT DISTINCT pp.id_persona,
			                                                          pp.cognome + ' ' + pp.nome AS nome_completo 
			                                          FROM persona AS pp
			                                          INNER JOIN join_persona_organo_carica AS jpoc
			                                             ON pp.id_persona = jpoc.id_persona
			                                          INNER JOIN legislature AS ll
			                                             ON jpoc.id_legislatura = ll.id_legislatura
			                                          INNER JOIN organi AS oo
			                                             ON jpoc.id_organo = oo.id_organo
			                                          INNER JOIN cariche AS cc
			                                             ON jpoc.id_carica = cc.id_carica
			                                          WHERE pp.deleted = 0
			                                            AND jpoc.deleted = 0
			                                            AND oo.deleted = 0
			                                            AND ((cc.id_tipo_carica = 4 --'consigliere regionale'
                                                              AND 
                                                              oo.id_categoria_organo = 1 -- consiglio regionale
                                                              )
                                                             OR
                                                             ((cc.id_tipo_carica = 3 -- 'assessore non consigliere'
                                                               AND 
                                                               oo.id_categoria_organo = 4 --giunta regionale
                                                            )))
			                                            AND ll.id_legislatura = @id_legislatura
			                                          ORDER BY nome_completo ASC">
                                    <SelectParameters>
                                        <asp:ControlParameter ControlID="ddl_search_legislatura" Name="id_legislatura" Type="Int32" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                            </td>

                            <td align="left" valign="middle">
                                <asp:Label ID="lbl_search_data_dichiarazione"
                                    runat="server"
                                    Text="Dichiarazione del: ">
                                </asp:Label>

                                <asp:DropDownList ID="ddl_search_data_dichiarazione"
                                    runat="server"
                                    AutoPostBack="true"
                                    AppendDataBoundItems="false"
                                    DataSourceID="SQLDataSource_Dichiarazioni"
                                    DataValueField="id_scheda"
                                    DataTextField="data_dichiarazione"
                                    OnSelectedIndexChanged="scheda_selected">
                                </asp:DropDownList>

                                <asp:SqlDataSource ID="SQLDataSource_Dichiarazioni"
                                    runat="server"
                                    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                                    SelectCommand="SELECT 0 AS id_scheda,
		                                                     '(seleziona)' AS data_dichiarazione,
		                                                     '30001231' AS data
		                                              UNION
		                                              SELECT sc.id_scheda,
                                                             CONVERT(varchar, sc.data, 103) AS data_dichiarazione,
                                                             sc.data
                                                      FROM scheda AS sc
                                                      INNER JOIN persona AS pp
                                                         ON sc.id_persona = pp.id_persona
                                                      INNER JOIN legislature AS ll
                                                         ON sc.id_legislatura = ll.id_legislatura
                                                      WHERE sc.deleted = 0
                                                        AND pp.deleted = 0
                                                        AND pp.id_persona = @id_persona
                                                        AND ll.id_legislatura = @id_legislatura
                                                      ORDER BY data DESC">
                                    <SelectParameters>
                                        <asp:ControlParameter ControlID="ddl_search_legislatura" Name="id_legislatura" Type="Int32" />
                                        <asp:ControlParameter ControlID="ddl_search_persona" Name="id_persona" Type="Int32" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                            </td>

                            <td align="right" valign="middle">
                                <% if ((role == 1) || (role == 2) || ((role == 5) && 
                                        (logged_categoria_organo == (int) Constants.CategoriaOrgano.GiuntaElezioni)))
                                    { %>
                                <asp:Button ID="btn_new_scheda"
                                    runat="server"
                                    Text="Nuova Dichiarazione"
                                    CausesValidation="true"
                                    ValidationGroup="ValGroup_New"
                                    OnClick="New_Scheda" />
                                <% } %>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>

        <tr>
            <td align="center" style="border: solid 2px #006600">
                <inc:incarichi_scheda runat="server" ID="Scheda" OnSchedaAdded="Scheda_SchedaAdded" OnSchedaDeleted="Scheda_SchedaDeleted" />
            </td>
        </tr>

        <tr>
            <td>
                <br />
            </td>
        </tr>
    </table>
</asp:Content>
