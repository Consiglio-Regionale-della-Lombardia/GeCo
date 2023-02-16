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
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Dettaglio Legislature
/// </summary>

public partial class legislature_dettaglio : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    private string id_leg;
    public string isClosingVisibleClass = "position: absolute; left: 0; right: 0; margin-left: auto; margin-right: auto; visibility: hidden;";

    public int role;
    string formato = "";

    string query_select_active_leg = @"SELECT attiva
                                       FROM legislature
                                       WHERE id_legislatura = @id_leg";

    string update_inactive_leg = @"UPDATE legislature
                                   SET attiva = 0
                                   WHERE id_legislatura != @id_leg";

    string query_unclosed_leg = @"SELECT id_legislatura
                                  FROM legislature
                                  WHERE durata_legislatura_a IS NULL";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_leg = Request.QueryString["id"];
        string nuovo = Request.QueryString["nuovo"];

        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (nuovo != null)
        {
            DetailsView1.ChangeMode(DetailsViewMode.Insert);
        }

        ListItem[] chiusuraGiorniItems = new ListItem[32];
        chiusuraGiorniItems[0] = new ListItem() { Text = "Seleziona un giorno", Selected = true, Value = 0.ToString() };

        ListItem[] chiusuraAnniItems = new ListItem[DateTime.Now.Year - 2020 + 1];
        chiusuraAnniItems[0] = new ListItem() { Text = "Seleziona un anno", Selected = true, Value = 0.ToString() };

        int count = 1;

        count = 1;
        for (int i = 1; i < 32; i++)
        {
            chiusuraGiorniItems[count] = new ListItem() { Text = i.ToString(), Value = i.ToString() };
            count++;
        }

        count = 1;
        for (int i = DateTime.Now.Year; i > 2020; i--)
        {
            chiusuraAnniItems[count] = new ListItem() { Text = i.ToString(), Value = i.ToString() };
            count++;
        }

        if (chiusuraGiorni.Items.Count < 1)
        {
            chiusuraGiorni.Items.AddRange(chiusuraGiorniItems);
        }

        if (chiusuraAnni.Items.Count < 1)
        {
            chiusuraAnni.Items.AddRange(chiusuraAnniItems);
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

    protected void ButtonChiusura_Click(object sender, EventArgs e)
    {
        if (Page.IsPostBack == false)
        {
            PanelChiusura.Visible = true;
        }
    }

    protected void ButtonCloseChiusura_Click(object sender, EventArgs e)
    {
        PanelChiusura.Visible = false;
    }

    protected void ButtonConfirmChiusura_Click(object sender, EventArgs e)
    {
        if (chiusuraAnni.SelectedItem.Value.Equals("0") ||
            chiusuraMesi.SelectedItem.Value.Equals("0") ||
            chiusuraGiorni.SelectedItem.Value.Equals("0"))
        {
            labelChiusuraError.Visible = true;
            return;
        }

        DateTime dataChiusura = DateTime.Parse(chiusuraAnni.SelectedItem.Value + "-" + chiusuraMesi.SelectedItem.Value + "-" + chiusuraGiorni.SelectedItem.Value);
        List<int> idPersoneLegislatura = new List<int>();

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);

        string querySp = "EXECUTE dbo.spChiusuraLegislatura " +
            "@idLegislatura = " + id_leg +
            ", @dataChiusura = '" + dataChiusura.ToString("yyyy-MM-dd") + "'";

        SqlCommand cmd = new SqlCommand();

        cmd.Connection = con;
        cmd.Connection.Open();
        cmd.CommandText = querySp;
        int id_rec = Convert.ToInt32(cmd.ExecuteScalar());
        cmd.Connection.Close();

        Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), id_rec, "join_legislature_chiusura");

        Response.Redirect("gestisciLegislature.aspx");
    }

    /// <summary>
    /// Annulla l'operazione corrente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        Response.Redirect("gestisciLegislature.aspx");
    }
    /// <summary>
    /// Log + Redirect post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "legislature");
        Response.Redirect("gestisciLegislature.aspx");
    }

    /// <summary>
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizioInsert") as TextBox;
        e.Values["durata_legislatura_da"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFineInsert") as TextBox;
        if (txtDataFine.Text != "")
        {
            e.Values["durata_legislatura_a"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
            e.Values["attiva"] = 0;
        }
        else
        {
            if (CheckUnclosedLeg())
            {
                Session.Contents.Add("error_message", "Esistono delle legislature ancora attive. Chiuderle prima di proseguire.");
                Response.Redirect("../errore.aspx");
            }

            e.Values["durata_legislatura_a"] = null;
            e.Values["attiva"] = 1;
        }
    }
    /// <summary>
    /// Redirect post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            string id_new_leg = e.Command.Parameters["@id_legislatura"].Value.ToString();

            string select_active_leg = query_select_active_leg.Replace("@id_leg", id_new_leg);

            SqlConnection conn = new SqlConnection(conn_string);
            conn.Open();
            SqlCommand cmd = new SqlCommand(select_active_leg, conn);
            SqlDataReader reader = cmd.ExecuteReader();

            bool active = false;

            while (reader.Read())
            {
                active = Convert.ToBoolean(reader[0]);
            }

            if (active)
            {
                Session.Contents.Add("id_legislatura", id_new_leg);
            }

            conn.Close();
            conn.Dispose();

            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_legislatura"].Value), "legislature");
            Response.Redirect("dettaglio.aspx?id=" + e.Command.Parameters["@id_legislatura"].Value.ToString());
        }
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
        }
    }


    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
        }
    }
    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFineEdit") as TextBox;

        if ((txtDataFine.Text == "") && (e.OldValues["durata_legislatura_a"] != null))
        {
            Session.Contents.Add("error_message", "Non è possibile riattivare una legislatura.");
            Response.Redirect("../errore.aspx");
        }

        if (txtDataFine.Text != "")
        {
            e.NewValues["durata_legislatura_a"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
            e.Keys["durata_legislatura_a"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
            e.Keys["attiva"] = 0;
        }
        else
        {
            e.Keys["durata_legislatura_a"] = null;
            e.Keys["attiva"] = 1;
        }

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizioEdit") as TextBox;
        e.NewValues["durata_legislatura_da"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        e.Keys["durata_legislatura_da"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");

        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "legislature");
    }

    /// <summary>
    /// Metodo verifica Legislature Chiuse
    /// </summary>
    /// <returns>esito se non cliuso</returns>
    protected bool CheckUnclosedLeg()
    {
        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();
        SqlCommand cmd = new SqlCommand(query_unclosed_leg, conn);
        SqlDataReader reader = cmd.ExecuteReader();

        bool result = false;

        if (reader.HasRows)
        {
            result = true;
        }

        conn.Close();
        conn.Dispose();

        return result;
    }

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
            string FileName = "Legislatura";

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
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        if (p_mode == "popup")
        {
            leg_anagrafica.HRef = "dettaglio.aspx?mode=popup&id=" + id_leg;
            leg_gruppi_politici.HRef = "gruppi_politici.aspx?mode=popup&id=" + id_leg;
            leg_componenti.HRef = "componenti.aspx?mode=popup&id=" + id_leg;

            anchor_back.Visible = false;
        }
        else
        {
            leg_anagrafica.HRef = "dettaglio.aspx?mode=normal&id=" + id_leg;
            leg_gruppi_politici.HRef = "gruppi_politici.aspx?mode=normal&id=" + id_leg;
            leg_componenti.HRef = "componenti.aspx?mode=normal&id=" + id_leg;

            anchor_back.Visible = true;
        }
    }

}