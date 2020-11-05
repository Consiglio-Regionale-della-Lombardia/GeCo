<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DettaglioAssenze.ascx.cs"
    Inherits="sedute_DettaglioAssenze" %>

<div>
    <asp:HiddenField ID="hidYear" runat="server" />
    <asp:HiddenField ID="hidMonth" runat="server" />
    <asp:HiddenField ID="hidIdPersona" runat="server" />
    <h3>DETTAGLIO ASSENZE
    </h3>
    <h2>
        <asp:Label ID="lbDescPersona" runat="server" />
        -
        <asp:Label ID="lbAnnoMese" runat="server" />
    </h2>
    <div>
        <table style="width:100%;">
            <tr>
                <td style="text-align:left; vertical-align:top;">
                    <asp:DetailsView ID="DetailsView_CorrezioneDiaria"
                        runat="server"
                        AutoGenerateRows="False"
                        CssClass="tab_det"
                        Width="350px"
                        DataKeyNames="id_persona"
                        DataSourceID="SQLDataSource_DetailsView_CorrezioneDiaria">

                        <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="80%" HorizontalAlign="right" />
<%--                    <RowStyle HorizontalAlign="left" />
                        <HeaderStyle Font-Bold="False" />--%>

                        <EmptyDataRowStyle HorizontalAlign="Center" BorderStyle="Solid" BorderWidth="1" BorderColor="White" />
                        <EmptyDataTemplate>
                            <%--<div style="border-color: White;">
                                NESSUNA CORREZIONE EFFETTUATA
                            </div>--%>
                            <asp:Label ID="lbl_corr_ass_diaria_empty"
                                runat="server" 
                                Text="NESSUNA CORREZIONE EFFETTUATA" />
                        </EmptyDataTemplate>

                        <Fields>
                            <asp:TemplateField HeaderText="Correzione Assenza Diaria">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />

                                <ItemTemplate>
                                    <asp:Label ID="lbl_corr_ass_diaria"
                                        runat="server" 
                                        Text='<%# Eval("corr_ass_diaria") %>'>
                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Correzione Assenza Rimborso Spese">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />

                                <ItemTemplate>
                                    <asp:Label ID="lbl_corr_ass_rimborso"
                                        runat="server"
                                        Text='<%# Eval("corr_ass_rimb_spese") %>'>

                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Fields>
                    </asp:DetailsView>

                    <asp:SqlDataSource ID="SQLDataSource_DetailsView_CorrezioneDiaria"
                        runat="server"
                        ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                        SelectCommand="SELECT id_persona,
                                                corr_ass_diaria,
                                                corr_ass_rimb_spese,
                                                corr_segno
                                        FROM correzione_diaria
                                        WHERE id_persona = @id_persona
                                        AND mese = @mese 
                                        AND anno = @anno">

                        <SelectParameters>
                            <asp:Parameter Name="id_persona" Type="Int32" />
                            <asp:Parameter Name="mese" Type="Int32" />
                            <asp:Parameter Name="anno" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>


                    <asp:DetailsView ID="DetailsView_Correzione"
                        runat="server"
                        AutoGenerateRows="False"
                        CssClass="tab_det"
                        Width="350px"
                        DataKeyNames="id_persona"
                        DataSourceID="SQLDataSource_DetailsView_Correzione">

                       <FieldHeaderStyle Font-Bold="True" BackColor="LightGray" Width="80%" HorizontalAlign="right" />
                       <%-- <RowStyle HorizontalAlign="left" />
                        <HeaderStyle Font-Bold="False" />--%>

                        <EmptyDataRowStyle HorizontalAlign="Center" BorderStyle="Solid" BorderWidth="1" BorderColor="White" />
                        <EmptyDataTemplate>
                            <%--<div style="border-color: White;">
                                NESSUNA CORREZIONE EFFETTUATA
                            </div>--%>
                            <asp:Label ID="lbl_corr_ass_diaria_empty"
                                runat="server" 
                                Text="NESSUNA CORREZIONE EFFETTUATA" />
                        </EmptyDataTemplate>

                        <Fields>
                            <asp:TemplateField HeaderText="Correzione Assenza Rimborso Spese">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />

                                <ItemTemplate>
                                    <asp:Label ID="lbl_corr_ass_diaria"
                                        runat="server"
                                        Text='<%# Eval("corr_frazione") != DBNull.Value ? String.Concat(Eval("corr_segno"), Eval("corr_ass_diaria"), " <sup>", Eval("corr_frazione"), "</sup") : Eval("corr_ass_diaria") %> ' >
                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Fields>
                    </asp:DetailsView>

                    <asp:SqlDataSource ID="SQLDataSource_DetailsView_Correzione"
                        runat="server"
                        ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
                        SelectCommand="SELECT id_persona, corr_ass_diaria, corr_frazione, corr_segno
                                            FROM correzione_diaria
                                            WHERE id_persona = @id_persona
                                            AND mese = @mese 
                                            AND anno = @anno">
                        <SelectParameters>
                            <asp:Parameter Name="id_persona" Type="Int32" />
                            <asp:Parameter Name="mese" Type="Int32" />
                            <asp:Parameter Name="anno" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                </td>
                <td style="text-align:right; vertical-align:top;">
                    <input type="checkbox" id="chkShowAll_SRV" class="chkShowAll_SRV" runat="server" style="display:none;" />
                    <input type="checkbox" id="chkShowAll" style="display:none;" onclick="ToggleCalcolo(event);" />
                    <%--Visualizza tutte le partecipazioni del mese--%>
                </td>
            </tr>
        </table>
    </div>
    <br />
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" CellPadding="5"
        CssClass="tab_gen" DataSourceID="SqlDataSource1" GridLines="None" OnRowDataBound="GridView1_RowDataBound">
        <EmptyDataTemplate>
            <table width="100%" class="tab_gen">
                <tr>
                    <th align="center">Nessun record trovato.
                    </th>
                </tr>
            </table>
        </EmptyDataTemplate>
        <Columns>
<%--            <asp:TemplateField HeaderText="" SortExpression="calcolo">
                <ItemTemplate>
                    <img class='calcolo_<%# Eval("calcolo") %>' src="../img/calcolo.png" alt="C" />
                </ItemTemplate>
                <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="30px" />
            </asp:TemplateField>--%>
            <asp:TemplateField HeaderText="Leg." SortExpression="num_legislatura">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkbtn_leg" runat="server" Text='<%# Eval("num_legislatura") %>'
                        Font-Bold="true" OnClientClick='<%# getPopupURL("../legislature/dettaglio.aspx", Eval("id_legislatura")) %>'>
                    </asp:LinkButton>
                </ItemTemplate>
                <ItemStyle HorizontalAlign="center" Font-Bold="True" Width="80px" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Organo" SortExpression="nome_organo">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkbtn_organo" runat="server" Text='<%# Eval("nome_organo") %>'
                        Font-Bold="true" OnClientClick='<%# getPopupURL("../organi/dettaglio.aspx", Eval("id_organo")) %>'>
                    </asp:LinkButton>
                </ItemTemplate>
                <ItemStyle Font-Bold="True" />
            </asp:TemplateField>
            <asp:BoundField DataField="tipo_incontro" HeaderText="Tipo seduta" SortExpression="tipo_incontro"
                ItemStyle-HorizontalAlign="center" ItemStyle-Width="90px" />
            <asp:TemplateField HeaderText="Seduta" SortExpression="nome_seduta">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkbtn_seduta" runat="server" Text='<%# Eval("nome_seduta") %>'
                        Font-Bold="true" OnClientClick='<%# getPopupURL("../sedute/dettaglio.aspx", Eval("id_seduta")) %>'>
                    </asp:LinkButton>
                </ItemTemplate>
                <ItemStyle Font-Bold="True" Width="100px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:BoundField DataField="data_seduta" HeaderText="Del" SortExpression="data_seduta"
                DataFormatString="{0:dd/MM/yyyy}" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="center" />
            <asp:TemplateField HeaderText="Tipo Sessione" SortExpression="id_tipo_sessione">
                <ItemTemplate>
                    <asp:Label ID="lbl_tipo_sessione" runat="server" Text='<%# Eval("id_tipo_sessione") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:BoundField DataField="ora_inizio" HeaderText="Inizio" SortExpression="ora_inizio"
                ItemStyle-HorizontalAlign="center" ItemStyle-Width="50px" />
            <asp:BoundField DataField="ora_fine" HeaderText="Fine" SortExpression="ora_fine"
                ItemStyle-HorizontalAlign="center" ItemStyle-Width="50px" />
            <asp:TemplateField HeaderText="Firma Ingressso" SortExpression="nome_partecipazione">
                <ItemTemplate>
                    <asp:Label ID="lbl_nome_partecipazione" runat="server" Text='<%# Eval("ha_sostituito") != DBNull.Value ? "Sostituzione":  Eval("nome_partecipazione") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Firma Uscita" SortExpression="presente_in_uscita">
                <ItemTemplate>
                    <asp:Label ID="lbl_presente_in_uscita" runat="server" Text='<%# Eval("ha_sostituito") != DBNull.Value ? "Sostituzione": Eval("presente_in_uscita")  %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Ha sostituito" SortExpression="ha_sostituito">
                <ItemTemplate>
                    <asp:Label ID="lbl_ha_sostituito" runat="server" Text='<%# Eval("ha_sostituito") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Priorità" SortExpression="priorita">
                <ItemTemplate>
                    <asp:Label ID="lbl_priorita" runat="server" Text='<%# Eval("priorita") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Opzione" SortExpression="opzione">
                <ItemTemplate>
                    <asp:Label ID="lbl_opzione" runat="server" Text='<%# Eval("opzione") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Convocato" SortExpression="agg_dinamicamente">
                <ItemTemplate>
                    <asp:Label ID="lbl_aggiunto_dinamicamente" runat="server" Text='<%# Eval("agg_dinamicamente") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Presidente di Gruppo" SortExpression="presidente_gruppo">
                <ItemTemplate>
                    <asp:Label ID="lbl_presidente_gruppo" runat="server" Text='<%# Eval("presidente_gruppo") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Considera assenze Presidenti Gruppo" SortExpression="organo_ass_presid">
                <ItemTemplate>
                    <asp:Label ID="lbl_organo_con_assenze_presidenti" runat="server" 
                        style="display:block;"
                        Text='<%# Eval("organo_ass_presid") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Missione" SortExpression="missione">
                <ItemTemplate>
                    <asp:Label ID="lbl_missione" runat="server" Text='<%# Eval("missione") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Certificato" SortExpression="certificato">
                <ItemTemplate>
                    <asp:Label ID="lbl_certificato" runat="server" Text='<%# Eval("certificato") %>'>
                    </asp:Label>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <br />
    <div>
        <asp:UpdatePanel ID="UpdatePaneExport" runat="server" UpdateMode="Conditional">
		    <ContentTemplate>

                <asp:CheckBox ID="chkOptionLandscape" runat="server" Style="margin-right: 50px;"
                    Text="Landscape" Checked="true" />
                <asp:LinkButton ID="lnkbtn_Export_Excel" runat="server" OnClick="LinkButtonExcel_Click">
                    <img src="../img/page_white_excel.png" alt="" align="top" /> 
                    Esporta
                </asp:LinkButton>
                -
                <asp:LinkButton ID="lnkbtn_Export_PDF" runat="server" OnClick="LinkButtonPdf_Click">
                    <img src="../img/page_white_acrobat.png" alt="" align="top" /> 
                    Esporta
                </asp:LinkButton>
            </ContentTemplate>
            <Triggers>
		        <asp:PostBackTrigger ControlID="lnkbtn_Export_Excel" />
		        <asp:PostBackTrigger ControlID="lnkbtn_Export_PDF" />
            </Triggers>

        </asp:UpdatePanel>
    </div>
    <br />
    <br />

    <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
        SelectCommand="spGetDettaglioCalcoloPresAssPersona"
        SelectCommandType="StoredProcedure"
        OnSelecting="SqlDataSource1_Selecting">
        <SelectParameters>
			<asp:SessionParameter Name="idLegislatura" DbType="Int32" SessionField="id_legislatura" />
			<asp:Parameter Name="idPersona" DbType="Int32" />
			<asp:Parameter Name="idTipoCarica" DbType="Int16" />
			<asp:Parameter Name="dataInizio" DbType="Date" />
			<asp:Parameter Name="dataFine" DbType="Date" />
			<asp:Parameter Name="role" DbType="Int32" />
            <asp:Parameter Name="idDup" DbType="Int16" />
        </SelectParameters>
    </asp:SqlDataSource>
</div>

<script>
    function ToggleCalcolo(ev) {
        try {
            var showAll = ($("#chkShowAll").attr("checked") == true);

            $(".chkShowAll_SRV").attr("checked", showAll);

            if (showAll) {
                $('.calcolo_toggle_0').removeClass("hidden");
            }
            else {
                $('.calcolo_toggle_0').addClass("hidden");
            }
        }
        catch (e) {
            alert(e.message);
        }
    }
</script>
