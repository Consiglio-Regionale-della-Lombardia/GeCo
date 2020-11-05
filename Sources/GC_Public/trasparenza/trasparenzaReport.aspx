<%@ Page Language="C#" AutoEventWireup="true" CodeFile="trasparenzaReport.aspx.cs" Inherits="trasparenza_trasparenzaReport" %>

<%@ Register Assembly="AjaxControlToolkit" 
             Namespace="AjaxControlToolkit" 
             TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Gestione Consiglieri - Trasparenza</title>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
    <meta content="no-cache" http-equiv="Cache-Control" />
    <meta content="no-cache" http-equiv="Pragma" />
    <meta content="0" http-equiv="Expires" />
    <link href="~/css/tabs.css" rel="stylesheet" type="text/css" media="screen" />

    <script type="text/javascript" src="~/js/jquery.min.js"></script>
    <script type="text/javascript" src="~/js/sddm.js"></script>
    <link href="~/css/theme.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="~/js/modal_popup.js"></script>

    <style type="text/css">
        tr.riga-cessato td
        {
            color: #888888;
        }

        tr.riga-new td
        {
            border-top: 1px solid gray;    
            border-bottom: 0px none;
            border-left: 1px solid gray;
            border-right: 1px solid gray;
        }
        tr.riga-same td
        {
            border-top: 0px none;    
            border-bottom: 0px none;
            border-left: 1px solid gray;
            border-right: 1px solid gray;  
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" 
                           runat="server" 
                           EnableScriptGlobalization="True">
        </asp:ScriptManager>

        <div class="contenuti" style="height: 300px; width: 1500px;">
            <div class="pannello_ricerca">
                <asp:ImageButton ID="ImageButtonRicerca"
                    runat="server"
                    ImageUrl="~/img/magnifier_arrow.png" />

                <asp:Label ID="LabelRicerca"
                    runat="server"
                    Text="">
                </asp:Label>

                <asp:Panel ID="PanelRicerca" runat="server">
                    <table border="0">
                        <tr>
                            <td valign="middle">
                                <b>Anno di riferimento:</b> 
                                <asp:DropDownList ID="ddAnno" runat="server" AutoPostBack="true"></asp:DropDownList>
                            </td>
                            <td valign="middle">
                                Legislatura:
                               <asp:DropDownList ID="DropDownListLegislatura" 
				                              runat="server" 
				                              DataSourceID="SqlDataSourceLegislature"
					                          DataTextField="num_legislatura" 
					                          DataValueField="id_legislatura" 
					                          Width="130px"
					                          AppendDataBoundItems="false"
					                          AutoPostBack="true"
                                              OnSelectedIndexChanged="DropDownListLegislatura_SelectedIndexChanged"
                                              OnDataBound="DropDownListLegislatura_DataBound">
				                </asp:DropDownList>            
				                <asp:SqlDataSource ID="SqlDataSourceLegislature" 
				                                   runat="server" 
				                                   ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        					                   
					                               SelectCommand="SELECT id_legislatura, num_legislatura 
                                                                    FROM legislature
                                                                    where year(durata_legislatura_da) <= @Anno and isnull(year(durata_legislatura_a),3000) >= @Anno
                                                                   ORDER BY durata_legislatura_da DESC">
                                    <SelectParameters>
                                        <asp:ControlParameter Name="Anno" Type="Int32"
                                            ControlID="ddAnno" PropertyName="SelectedValue" />
                                    </SelectParameters>

				                </asp:SqlDataSource>
                            </td>
                            <td align="left" valign="middle">
                                <asp:Button ID="ButtonRic"
                                    runat="server"
                                    Text="Applica"
                                    CssClass="button"
                                    Width="200px"
                                    OnClick="ButtonRic_Click" 
                                    Visible ="false"/>
                            </td>
                            <td>
                                <asp:LinkButton ID="LinkButtonExcel" 
                                                runat="server" 
                                                OnClick="LinkButtonExcel_Click">
                                    <img src="../img/page_white_excel.png" 
                                            alt="" 
                                            align="top" /> 
                                    Esporta CSV
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </div>

            <div style="padding:6px; font-weight:bold;">
                Dati inerenti <span id="lbMode" runat="server"></span> (ai sensi dell'art.14 d.lgs. 33/2013)
            </div>
            <div style="padding:6px; font-style:italic;">
                (*) Le indennità di carica e di funzione sono indicate al lordo delle imposte fiscali e degli altri eventuali oneri di legge. Gli
                importi indicati non sono comprensivi di eventuali trattenute effettuate a vario titolo (per esempio, spese telefoniche).</br>
                (**) Il rimborso forfettario per l'esercizio del mandato non è assoggettato a tassazione (art.52 D.P.R. n.917 del 1986).
                L'importo indicato non è comprensivo di eventuali trattenute per assenze secondo quanto previsto dalle disposizioni vigenti.</br>
                (***) Gli importi indicati sono relativi ai compensi effettivamente erogati, comprensivi di eventuali trattenute a qualsiasi titolo. Il dato è pubblicato a consuntivo, nell’anno successivo a quello di riferimento.</br>
                      
            </div>
            <div style="padding:6px; font-weight:bold;">
                <table border="0">
                    <tr>
                        <td colspan="2">Modalità di estrazione dei dati</td>
                    </tr>
                    <tr>
                        <td>Anno:</td> 
                        <td><span id="lbAnno" runat="server"></span></td>
                    </tr>
                    <tr>
                        <td>Legislatura:</td>
                        <td><span id="lbLegislatura" runat="server"></span></td>
                    </tr>
                </table>

            </div>
            <asp:UpdatePanel ID="UpdatePanelReportTrasparenza" runat="server">
                <ContentTemplate>
                    <asp:GridView ID="GridViewTrasparenza"
                        runat="server"
                        AllowPaging="False"
                        AllowSorting="False"
                        PagerStyle-HorizontalAlign="Center"
                        AutoGenerateColumns="False"
                        CssClass="tab_gen_s"
                        GridLines="None"
                        Font-Size="9px" 
                        OnRowDataBound="GridViewTrasparenza_RowDataBound">

                        <EmptyDataTemplate>
                            <table class="tab_gen" border="0">
                                <tr>
                                    <th align="center">Nessun record trovato.
                                    </th>
                                </tr>
                            </table>
                        </EmptyDataTemplate>

                        <Columns>
                            
                        </Columns>
                    </asp:GridView>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
