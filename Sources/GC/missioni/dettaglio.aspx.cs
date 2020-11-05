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
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Dettaglio Missioni
/// </summary>

public partial class missioni_dettaglio : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string id;
    string sel_leg_id;
    string legislatura_corrente;

    public int role;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e caricamento struttura tabelle
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        string nuovo = Request.QueryString["nuovo"];

        if (nuovo != null)
        {
            DetailsView1.ChangeMode(DetailsViewMode.Insert);

            if (!Page.IsPostBack)
            {
                DropDownList ddl_leg = DetailsView1.FindControl("DropDownList3") as DropDownList;
                ddl_leg.SelectedValue = legislatura_corrente;

                TextBox txtCodice = DetailsView1.FindControl("TextBoxCodice_Insert") as TextBox;
                SetMissionCode(ddl_leg, txtCodice);
            }
        }
        else
        {
            id = Request.QueryString["id"];

            if (id != null)
            {
                sel_leg_id = Request.QueryString["sel_leg_id"];

                Session.Contents.Add("id_missione", id);
                Session.Contents.Add("sel_leg_id", sel_leg_id);
            }
            else
            {
                id = Session.Contents["id_missione"] as String;
                sel_leg_id = Session.Contents["sel_leg_id"] as String;
            }
        }

        SetModeVisibility(Request.QueryString["mode"]);
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
    /// Annulla l'operazione corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        Response.Redirect("gestisciMissioni.aspx");
    }
    /// <summary>
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        TextBox txtDataDelibera = DetailsView1.FindControl("dt_delibera_Ins") as TextBox;
        if (txtDataDelibera.Text.Length > 0)
            e.Values["data_delibera"] = Utility.ConvertStringToDateTime(txtDataDelibera.Text, "0", "0", "0");
        else
            e.Values["data_delibera"] = null;

        TextBox txtDataInizio = DetailsView1.FindControl("dt_missioneDa_ins") as TextBox;
        if (txtDataInizio.Text.Length > 0)
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Values["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("dt_missioneA_ins") as TextBox;
        if (txtDataFine.Text.Length > 0)
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;
    }
    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        TextBox txtDataDelibera = DetailsView1.FindControl("dt_delibera_Mod") as TextBox;
        if (txtDataDelibera.Text.Length > 0)
            e.Keys["data_delibera"] = Utility.ConvertStringToDateTime(txtDataDelibera.Text, "0", "0", "0");
        else
            e.Keys["data_delibera"] = null;

        TextBox txtDataInizio = DetailsView1.FindControl("dt_missioneDa_mod") as TextBox;
        if (txtDataInizio.Text.Length > 0)
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Keys["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("dt_missioneA_mod") as TextBox;
        if (txtDataFine.Text.Length > 0)
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;

        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "missioni");
    }
    /// <summary>
    /// Log + Redirect post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "missioni");
        Response.Redirect("gestisciMissioni.aspx");
    }
    /// <summary>
    /// Log + Redirect post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource4_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_missione"].Value), "missioni");

            Response.Redirect("dettaglio.aspx?id=" + e.Command.Parameters["@id_missione"].Value + "&sel_leg_id=" + legislatura_corrente);
        }
    }


    string formato = "";
    /// <summary>
    /// Esporta come Excel l'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcelDetails_Click(object sender, EventArgs e)
    {
        formato = "xls";
    }
    /// <summary>
    /// Esporta come PDF l'elemento selezionato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdfDetails_Click(object sender, EventArgs e)
    {
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
            string FileName = "Missione";

            if (formato.Equals("xls"))
            {
                DetailsViewExport.toXls(DetailsView1, FileName + "-Anagrafica");
            }
            else if (formato.Equals("pdf"))
            {
                DetailsViewExport.toPdf(DetailsView1, FileName + "-Anagrafica");
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Inizializzazione variabili pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SelectedIndexChanged_ddlLegislatura_Insert(object sender, EventArgs e)
    {
        TextBox txt_codice = DetailsView1.FindControl("TextBoxCodice_Insert") as TextBox;
        DropDownList ddl_leg = sender as DropDownList;

        //if (!ddlLeg.SelectedValue.Equals(""))
        //    txtCodice.Text = GetMaxCodice(ddlLeg.SelectedValue);
        //else
        //    txtCodice.Text = "";

        SetMissionCode(ddl_leg, txt_codice);
    }

    /// <summary>
    /// Metodo per generazione codice missione
    /// </summary>
    /// <param name="ddl">DropDownList di riferimento</param>
    /// <param name="txt">TextBox di riferimento</param>
    protected void SetMissionCode(DropDownList ddl, TextBox txt)
    {
        if (!ddl.SelectedValue.Equals(""))
        {
            int tmpInt = -1;
            if (txt.Text == "" || !int.TryParse(txt.Text, out tmpInt))
                txt.Text = GetMaxCodice(ddl.SelectedValue);
        }
        else
        {
            txt.Text = "";
        }
    }

    /// <summary>
    /// Update ddlLegislatura quando cambia il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DataBound_ddlLegislatura_Insert(object sender, EventArgs e)
    {
        TextBox txtCodice = DetailsView1.FindControl("TextBoxCodice_Insert") as TextBox;
        DropDownList ddlLeg = sender as DropDownList;

        if (!ddlLeg.SelectedValue.Equals(""))
        {
            int tmpInt = -1;
            if (txtCodice.Text == "" || !int.TryParse(txtCodice.Text, out tmpInt))
                txtCodice.Text = GetMaxCodice(ddlLeg.SelectedValue);
        }
        else
        {
            txtCodice.Text = "";
        }
    }

    /// <summary>
    /// Metodo per max codice missione
    /// </summary>
    /// <param name="legislatura">legisatura di riferimento</param>
    /// <returns>max codice</returns>
    protected string GetMaxCodice(string legislatura)
    {
        int tmp;

        string strsql = @"SELECT COALESCE(MAX(cast(codice as int)), '0') AS max_code
                          FROM missioni AS mm
                          WHERE ISNUMERIC(mm.codice) = 1
                          AND mm.deleted = 0
                          AND mm.id_legislatura = " + legislatura;

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(strsql, conn);

        SqlDataReader reader = cmd.ExecuteReader();
        reader.Read();

        tmp = Convert.ToInt32(reader[0]);

        conn.Close();
        conn.Dispose();

        tmp++;

        string codice = Convert.ToString(tmp);
        return codice;
    }
    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=popup";
            a_componenti.HRef = "componenti.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=normal";
            a_componenti.HRef = "componenti.aspx?mode=normal";

            a_back.Visible = true;
        }
    }

}