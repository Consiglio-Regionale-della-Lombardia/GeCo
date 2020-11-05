/*
 * Copyright (C) 2019 Consiglio Regionale della Lombardia
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using System;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;


/// <summary>
/// Classe per la gestione gruppi politici
/// </summary>
public partial class gruppi_politici_gruppi_politici : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;

    public string photoName;

    int id_user;
    string nome_completo;
    string title = "Elenco Gruppi Politici, ";
    string tab = "Consiglieri - Gruppi Politici";
    string filename = "Elenco_Gruppi_Politici_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_cons_name = @"SELECT cognome + ' ' + nome AS nome_completo 
                               FROM persona 
                               WHERE id_persona = ";

    /// <summary>
    /// Caricamento gruppi politici per persona
    /// </summary>
    string query_select = @"SELECT ll.id_legislatura, 
			                                         ll.num_legislatura, 
			                                         gg.id_gruppo, 

                                                     LTRIM(RTRIM(gg.nome_gruppo)) AS nome_gruppo,
                                                     jpgp.id_rec, 
			                                         jpgp.data_inizio, 
			                                         jpgp.data_fine,
                                                     cc.nome_carica
                                              FROM join_persona_gruppi_politici AS jpgp
                                              INNER JOIN gruppi_politici AS gg

                                                ON jpgp.id_gruppo = gg.id_gruppo
                                              INNER JOIN persona AS pp

                                                ON jpgp.id_persona = pp.id_persona

                                              INNER JOIN join_gruppi_politici_legislature AS jgpl
                                                ON gg.id_gruppo = jgpl.id_gruppo

                                              INNER JOIN legislature AS ll
                                                ON (jgpl.id_legislatura = ll.id_legislatura AND jpgp.id_legislatura = ll.id_legislatura)
                                              INNER JOIN cariche AS cc
                                                ON jpgp.id_carica = cc.id_carica
                                              WHERE pp.deleted = 0
				                                AND gg.deleted = 0
				                                AND jpgp.deleted = 0

                                                AND jgpl.deleted = 0

                                                AND pp.id_persona = @id";


    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura tabelle
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_persona"] as string;


        sel_leg_id = Convert.ToString(Session.Contents["sel_leg_id"]);
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        photoName = Session.Contents["foto_persona"] as string;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }


        Page.CheckIdPersona(id);

        query_cons_name += id;
        DataTableReader reader = Utility.ExecuteQuery(query_cons_name);
        reader.Read();
        nome_completo = reader[0].ToString();

        title += nome_completo;
        filename += nome_completo.Replace(" ", "_");

        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = Session.Contents["id_legislatura_search"].ToString();

        }
        else
        {
            Session.Contents["id_legislatura_search"] = DropDownListLegislatura.SelectedValue;
        }

        EseguiRicerca();

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_gruppi_politici);
    }

    /// <summary>
    /// Metodo per la gestione della pagina di errore
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Error(object sender, EventArgs e)
    {
        Exception ex = Server.GetLastError();
        Session.Contents.Add("error_message", ex.Message.ToString());
        Response.Redirect("../errore.aspx");
    }

    /// <summary>
    /// Gestore dell'evento click sull'oggetto LinkButtonDettagli
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonDettagli_Click(object sender, EventArgs e)
    {
        LinkButton btnDetails = sender as LinkButton;
        GridViewRow row = (GridViewRow)btnDetails.NamingContainer;

        SqlDataSource2.SelectParameters.Clear();
        SqlDataSource2.SelectParameters.Add("id_rec", Convert.ToString(GridView1.DataKeys[row.RowIndex].Value));
        DetailsView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        DropDownList ddGrp = DetailsView1.FindControl("DropDownListGruppo") as DropDownList;
        e.Values["id_gruppo"] = ddGrp.SelectedValue;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        DropDownList ddlCarica = DetailsView1.FindControl("ddlTipoCarica_Insert") as DropDownList;
        e.Values["id_carica"] = ddlCarica.SelectedValue;

        // Imposta la data di fine al record precedente
        string id_rec = "";
        string data_inizio = "";

        DataTableReader reader = Utility.ExecuteQuery(@"SELECT id_rec, 
                                                               data_inizio 
                                                        FROM join_persona_gruppi_politici 
                                                        WHERE id_persona = " + id +
                                                       @" AND data_fine IS NULL 
                                                          AND deleted = 0
                                                        ORDER BY data_inizio DESC");

        while (reader.Read())
        {
            id_rec = reader[0].ToString();
            data_inizio = reader[1].ToString();
            break;
        }

        // campo obbligatorio
        TextBox txtDataInizioInsert = DetailsView1.FindControl("dtIns_inizio") as TextBox;
        DateTime inizio_new = Utility.ConvertStringToDateTime(txtDataInizioInsert.Text, "0", "0", "0");

        DateTime dt_fine_old = inizio_new.AddDays(-1);
        string fine_old = Utility.ConvertDateTimeToANSIString(dt_fine_old);

        if (data_inizio.Length > 0)
        {
            DateTime inizio_old = DateTime.Parse(data_inizio);

            if (id_rec.Length > 0 && inizio_old != null && inizio_old.CompareTo(inizio_new) < 0)
            {
                Utility.ExecuteNonQuery(@"UPDATE join_persona_gruppi_politici 
                                          SET data_fine = '" + fine_old + @"' 
                                          WHERE id_rec = " + id_rec);
            }
        }

        TextBox txtDataDeliberaInizioInsert = DetailsView1.FindControl("dtIns_delib_inizio") as TextBox;
        if (txtDataDeliberaInizioInsert.Text.Length > 0)
            e.Values["data_delibera_inizio"] = Utility.ConvertStringToDateTime(txtDataDeliberaInizioInsert.Text, "0", "0", "0");
        else
            e.Values["data_delibera_inizio"] = null;

        TextBox txtDataDeliberaFineInsert = DetailsView1.FindControl("dtIns_delib_fine") as TextBox;
        if (txtDataDeliberaFineInsert.Text.Length > 0)
            e.Values["data_delibera_fine"] = Utility.ConvertStringToDateTime(txtDataDeliberaFineInsert.Text, "0", "0", "0");
        else
            e.Values["data_delibera_fine"] = null;

        // obbligatorio
        e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizioInsert.Text, "0", "0", "0");

        TextBox txtDataFineInsert = DetailsView1.FindControl("dtIns_fine") as TextBox;
        if (txtDataFineInsert.Text.Length > 0)
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFineInsert.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;
    }

    /// <summary>
    /// Refresh della pagina post-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        string query = query_select;


        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        query += " ORDER BY jpgp.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Gestore dell'evento ItemUpdating sull'oggetto DetailsView1
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        DropDownList ddGrp = DetailsView1.FindControl("DropDownListGruppo") as DropDownList;
        e.Keys["id_gruppo"] = ddGrp.SelectedValue;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        DropDownList ddlCarica = DetailsView1.FindControl("ddlTipoCarica_Edit") as DropDownList;
        e.Keys["id_carica"] = ddlCarica.SelectedValue;

        TextBox txtDataDeliberaInizioEdit = DetailsView1.FindControl("dtMod_delib_inizio") as TextBox;
        if (txtDataDeliberaInizioEdit.Text.Length > 0)
            e.Keys["data_delibera_inizio"] = Utility.ConvertStringToDateTime(txtDataDeliberaInizioEdit.Text, "0", "0", "0");
        else
            e.Keys["data_delibera_inizio"] = null;

        TextBox txtDataDeliberaFineEdit = DetailsView1.FindControl("dtMod_delib_fine") as TextBox;
        if (txtDataDeliberaFineEdit.Text.Length > 0)
            e.Keys["data_delibera_fine"] = Utility.ConvertStringToDateTime(txtDataDeliberaFineEdit.Text, "0", "0", "0");
        else
            e.Keys["data_delibera_fine"] = null;

        // obbligatorio
        TextBox txtDataInizioEdit = DetailsView1.FindControl("dtMod_inizio") as TextBox;
        e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizioEdit.Text, "0", "0", "0");

        TextBox txtDataFineEdit = DetailsView1.FindControl("dtMod_fine") as TextBox;
        if (txtDataFineEdit.Text.Length > 0)
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFineEdit.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;
    }


    /// <summary>
    /// Gestore dell'evento ItemUpdated sull'oggetto DetailsView1
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_gruppi_politici");

        string query = query_select;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        query += " ORDER BY jpgp.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelMaster.Update();
    }

    /// <summary>
    /// Gestore dell'evento ItemDeleted sull'oggetto DetailsView1
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_gruppi_politici");

        string query = query_select;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND ll.id_legislatura = " + DropDownListLegislatura.SelectedValue;
        }

        query += " ORDER BY jpgp.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Apertura popup per l'inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        DetailsView1.ChangeMode(DetailsViewMode.Insert);
        UpdatePanelDetails.Update();
        UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Applica filtri alla lista dei gruppi politici
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>
    protected void EseguiRicerca()
    {
        string query = query_select;

        if (Session.Contents["id_legislatura_search"] != null && Session.Contents["id_legislatura_search"].ToString() != "")
            query += " AND ll.id_legislatura = " + Session.Contents["id_legislatura_search"].ToString();


        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jpgp.data_inizio AND jpgp.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= jpgp.data_inizio AND jpgp.data_fine IS NULL))";
        }

        query += " ORDER BY jpgp.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Gestore dell'evento Click sull'oggetto ButtonAnnulla
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Gestore dell'evento DataBound sull'oggetto DropDownListGruppo
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListGruppo_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_gruppo"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
                li.Selected = true;
        }
    }

    string formato = "";
    string control = "";


    /// <summary>
    /// Gestore dell'evento Click sull'oggetto LinkButtonExcel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "g1";

        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToExcel(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }

    /// <summary>
    /// Gestore dell'evento Click sull'oggetto LinkButtonPdf
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "g1";
        string[] filter_param = new string[2];

        filter_param[0] = "Legislatura";
        filter_param[1] = DropDownListLegislatura.SelectedItem.Text;

        if (GridView1.Rows.Count == 0)
        {
            Session.Contents.Add("error_message", "ATTENZIONE! Nessun elemento da esportare!");
            Response.Redirect("../errore.aspx");
            return;
        }

        GridViewExport.ExportToPDF(Page.Response, GridView1, id_user, tab, title, no_first_col, no_last_col, landscape, filename, filter_param);
    }

    /// <summary>
    /// Gestore dell'evento Click sull'oggetto LinkButtonExcelDetails
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcelDetails_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "d1";
        formato = "xls";
    }

    /// <summary>
    /// Esporta come PDF l'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdfDetails_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "d1";
        formato = "pdf";
    }

    /// <summary>
    /// Verifies that the control is rendered
    /// </summary>
    /// <param name="control">controllo di riferimento</param>
    public override void VerifyRenderingInServerForm(Control control)
    {
        // Verifies that the control is rendered
        return;
    }

    /// <summary>
    /// Metodo per il Render della maschera
    /// </summary>
    /// <param name="writer">writer di riferimento</param>

    protected override void Render(HtmlTextWriter writer)
    {
        if (formato.Length > 0)
        {
            string FileName = "";

            // Trova il nome della persona
            string query = @"SELECT cognome + '_' + nome 
                             FROM persona 
                             WHERE id_persona = " + id;

            DataTableReader reader = Utility.ExecuteQuery(query);
            while (reader.Read())
            {
                FileName = reader[0].ToString();
                break;
            }

            FileName += "_GruppiPolitici";

            if (formato.Equals("xls"))
            {
                if (control.Equals("g1"))
                    GridViewExport.toXls(GridView1, FileName);
                if (control.Equals("d1"))
                    DetailsViewExport.toXls(DetailsView1, FileName + "_Dettaglio");
            }
            else if (formato.Equals("pdf"))
            {
                if (control.Equals("g1"))
                    GridViewExport.toPdf(GridView1, FileName);
                if (control.Equals("d1"))
                    DetailsViewExport.toPdf(DetailsView1, FileName + "_Dettaglio");
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Log + Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            CGruppoPoliticoPersona obj = new CGruppoPoliticoPersona();

            obj.pk_id_rec = (int)e.Command.Parameters["@id_rec"].Value;

            obj.SendToOpenData("I");

            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_gruppi_politici");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Operation post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            CGruppoPoliticoPersona obj = new CGruppoPoliticoPersona();

            obj.pk_id_rec = Convert.ToInt32(e.Command.Parameters["@id_rec"].Value);

            obj.SendToOpenData("U");
        }
    }

    /// <summary>
    /// Operation post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            CGruppoPoliticoPersona obj = new CGruppoPoliticoPersona();

            obj.pk_id_rec = Convert.ToInt32(e.Command.Parameters["@id_rec"].Value);

            obj.SendToOpenData("D");
        }

    }

    /// <summary>
    /// Metodo per invio dati OpenData
    /// </summary>
    /// <param name="e">evento argomenti</param>
    /// <param name="azione">azione da intraprendere</param>
    protected void SendToOpenData(SqlDataSourceStatusEventArgs e, string azione)
    {
        //COMPOSIZIONE_GRUPPI (link_consigliere, dal, al, link_legislatura)

    }

    /// <summary>
    /// Mostra/Nasconde il pannello esportazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ModeChanged(object sender, EventArgs e)
    {
        UpdatePanelEsporta_Toggle();
    }

    /// <summary>
    /// Metodo per visibilita esportazioni
    /// </summary>
    protected void UpdatePanelEsporta_Toggle()
    {
        if (DetailsView1.CurrentMode == DetailsViewMode.ReadOnly)
        {
            LinkButtonExcelDetails.Visible = true;
            LinkButtonPdfDetails.Visible = true;
            UpdatePanelEsporta.Update();
        }
        else
        {
            LinkButtonExcelDetails.Visible = false;
            LinkButtonPdfDetails.Visible = false;
            UpdatePanelEsporta.Update();
        }
    }

    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>
    protected void SetModeVisibility(string p_mode)
    {

        if (p_mode == "popup")
        {
            a_back.Visible = false;
        }
        else
        {
            a_back.Visible = true;
        }
    }

    /// <summary>
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="obj_link">url di riferimento</param>
    /// <param name="id">id di riferimento</param>
    /// <returns>Stringa URL della Form</returns>
    public string getPopupURL(object obj_link, object id)
    {
        string url = obj_link.ToString() + "?mode=popup";

        if (id != null)
        {
            url += "&id=" + id.ToString();
        }

        return "openPopupWindow('" + url + "')";
    }

}