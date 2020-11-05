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
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Cariche Assessori
/// </summary>
public partial class cariche_assessori : System.Web.UI.Page
{
    string id;
    string legislatura_corrente;
    public int role;
    public string photoName;

    int id_user;
    string nome_completo;
    string title = "Elenco Cariche, ";
    string tab = "Assessori - Cariche";
    string filename = "Elenco_Cariche_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string query_cons_name = "SELECT cognome + ' ' + nome AS nome_completo FROM persona WHERE id_persona = ";

    int id_tipo_carica_default = (int)Constants.TipoCarica.AssessoreNonConsigliere;

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        id = Session.Contents["id_persona"] as string;
        legislatura_corrente = Session.Contents["id_legislatura"] as string;
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        photoName = Session.Contents["foto_persona"] as string;

        id_user = Convert.ToInt32(Session.Contents["user_id"]);

        Page.CheckIdPersona(id);

        query_cons_name += id;
        DataTableReader reader = Utility.ExecuteQuery(query_cons_name);
        reader.Read();
        nome_completo = reader[0].ToString();

        title += nome_completo;
        filename += nome_completo.Replace(" ", "_");

        if (Page.IsPostBack == false)
        {
            DropDownListLegislatura.SelectedValue = legislatura_corrente;

            string query = SqlDataSource1.SelectCommand;

            query += " AND (jj.id_legislatura = " + legislatura_corrente + ")";
            query += " ORDER BY jj.data_inizio DESC";

            SqlDataSource1.SelectCommand = query;
            GridView1.DataBind();
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_cariche);
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
    /// Apertura popup nuova carica
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
    /// Inizializzazione pre-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Values["id_legislatura"] = ddLeg.SelectedValue;

        DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        e.Values["id_organo"] = ddOrg.SelectedValue;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        e.Values["id_carica"] = ddCar.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizio") as TextBox;
        if (txtDataInizio.Text != "")
            e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Values["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFine") as TextBox;
        if (txtDataFine.Text != "")
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Values["data_fine"] = null;

        TextBox txtDataProclamazione = DetailsView1.FindControl("TextBoxDataProclamazione") as TextBox;
        if (txtDataProclamazione.Text != "")
            e.Values["data_proclamazione"] = Utility.ConvertStringToDateTime(txtDataProclamazione.Text, "0", "0", "0");
        else
            e.Values["data_proclamazione"] = null;

        TextBox txtDataDeliberaProclamazione = DetailsView1.FindControl("TextBoxDataDeliberaProclamazione") as TextBox;
        if (txtDataDeliberaProclamazione.Text != "")
            e.Values["data_delibera_proclamazione"] = Utility.ConvertStringToDateTime(txtDataDeliberaProclamazione.Text, "0", "0", "0");
        else
            e.Values["data_delibera_proclamazione"] = null;

        TextBox txtDataConvalida = DetailsView1.FindControl("TextBoxDataConvalida") as TextBox;
        if (txtDataConvalida.Text != "")
            e.Values["data_convalida"] = Utility.ConvertStringToDateTime(txtDataConvalida.Text, "0", "0", "0");
        else
            e.Values["data_convalida"] = null;
    }

    /// <summary>
    /// Refresh pagina post-inserimento, eventualmente filtrata per legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        e.Keys["id_persona"] = id;

        DropDownList ddLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
        e.Keys["id_legislatura"] = ddLeg.SelectedValue;

        DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        e.Keys["id_organo"] = ddOrg.SelectedValue;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        e.Keys["id_carica"] = ddCar.SelectedValue;

        TextBox txtDataInizio = DetailsView1.FindControl("TextBoxDataInizio") as TextBox;
        if (txtDataInizio.Text != "")
            e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");
        else
            e.Keys["data_inizio"] = null;

        TextBox txtDataFine = DetailsView1.FindControl("TextBoxDataFine") as TextBox;
        if (txtDataFine.Text != "")
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        else
            e.Keys["data_fine"] = null;

        TextBox txtDataProclamazione = DetailsView1.FindControl("TextBoxDataProclamazione") as TextBox;
        if (txtDataProclamazione.Text != "")
            e.Keys["data_proclamazione"] = Utility.ConvertStringToDateTime(txtDataProclamazione.Text, "0", "0", "0");
        else
            e.Keys["data_proclamazione"] = null;

        TextBox txtDataDeliberaProclamazione = DetailsView1.FindControl("TextBoxDataDeliberaProclamazione") as TextBox;
        if (txtDataDeliberaProclamazione.Text != "")
            e.Keys["data_delibera_proclamazione"] = Utility.ConvertStringToDateTime(txtDataDeliberaProclamazione.Text, "0", "0", "0");
        else
            e.Keys["data_delibera_proclamazione"] = null;

        TextBox txtDataConvalida = DetailsView1.FindControl("TextBoxDataConvalida") as TextBox;
        if (txtDataConvalida.Text != "")
            e.Keys["data_convalida"] = Utility.ConvertStringToDateTime(txtDataConvalida.Text, "0", "0", "0");
        else
            e.Keys["data_convalida"] = null;
    }

    /// <summary>
    /// Refresh pagina post-update, eventualmente filtrata per legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica");

        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelMaster.Update();
    }

    /// <summary>
    /// Refresh pagina post-delete, eventualmente filtrata per legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "join_persona_organo_carica");

        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals(""))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Applica i filtri desiderati alla lista delle cariche
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonFiltri_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
    }

    /// <summary>
    /// Filtra le cariche
    /// </summary>
    protected void EseguiRicerca()
    {
        string query = SqlDataSource1.SelectCommand;

        if (!DropDownListLegislatura.SelectedValue.Equals("0"))
        {
            query += " AND (jj.id_legislatura = " + DropDownListLegislatura.SelectedValue + ")";
        }

        if (!TextBoxFiltroData.Text.Equals(""))
        {
            query += " AND (('" + TextBoxFiltroData.Text + "' BETWEEN jj.data_inizio AND jj.data_fine) OR ('" + TextBoxFiltroData.Text + "' >= jj.data_inizio AND jj.data_fine IS NULL))";
        }

        query += " ORDER BY jj.data_inizio DESC";

        SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }

    /// <summary>
    /// Aggiunge un Organo alla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListOrgano_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_organo"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
                li.Selected = true;
        }

        DetailsView1_RefreshFields();
    }

    /// <summary>
    /// Aggiunge una Carica alla lista
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListCarica_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;

        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_carica"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);

            if (li != null)
                li.Selected = true;
        }

        DetailsView1_RefreshFields();
    }

    /// <summary>
    /// Refresh della pagina in base ai filtri selezionati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DropDownListCarica_SelectedIndexChanged(object sender, EventArgs e)
    {
        DetailsView1_RefreshFields();
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_DataBound(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Metodo per refresh campi
    /// </summary>
    protected void DetailsView1_RefreshFields()
    {
        DropDownList ddOrg = DetailsView1.FindControl("DropDownListOrgano") as DropDownList;
        string id_organo = ddOrg.SelectedValue;

        DropDownList ddCar = DetailsView1.FindControl("DropDownListCarica") as DropDownList;
        string id_carica = ddCar.SelectedValue;

        Refreshing(id_organo, id_carica);
    }

    /// <summary>
    /// Metodo per Refresh della maschera
    /// </summary>
    /// <param name="id_organo">id di riferimento</param>
    /// <param name="id_carica">id di riferimento</param>
    protected void Refreshing(string id_organo, string id_carica)
    {
        // Trovo la maschera relativa a questa carica
        SqlConnection conn = null;
        SqlDataReader reader = null;
        string mask = "";

        // Se sono vuoti, disattivo tutto
        if (id_organo.Equals("") || id_carica.Equals(""))
        {
            //mask = "000000000000000000"; // <--- nota: 18 caratteri
            mask = "000000000000"; // <--- nota: 12 caratteri
        }

        // Altrimenti cerco la mask relativa a organo/carica selezionati
        else
        {
            try
            {
                // instantiate and open connection
                conn = new SqlConnection(conn_string);
                conn.Open();

                string strsql = @"SELECT flag 
                                  FROM join_cariche_organi 
                                  WHERE id_organo = " + id_organo +
                                  " AND id_carica = " + id_carica;
                SqlCommand cmd = new SqlCommand(strsql, conn);

                // get data stream
                reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    mask = reader[0].ToString();
                    break;
                }
            }
            finally
            {
                if (reader != null)
                {
                    reader.Close();
                }

                if (conn != null)
                {
                    conn.Close();
                }
            }
        }

        // A seconda della mask attivo o disattivo i field
        // Le prime 5 sono fisse, l'ultima è la riga dei control
        for (int i = 5; i < DetailsView1.Rows.Count - 2; i++)
        {
            DetailsViewRow dvr = DetailsView1.Rows[i];

            if (mask[i - 5] == '0')
            {
                //dvr.Enabled = false;
                dvr.Visible = false;
            }
            else
            {
                //dvr.Enabled = true;
                dvr.Visible = true;
            }
        }
    }

    /// <summary>
    /// Mostra/Nasconde il pannello per esportare il contenuto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ModeChanged(object sender, EventArgs e)
    {
        UpdatePanelEsporta_Toggle();
    }

    string formato = "";
    string control = "";

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "g1";
        //formato = "xls";

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
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        EseguiRicerca();
        control = "g1";
        //formato = "pdf";

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
    /// Visualizza dettagli come Excel
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
    /// Visualizza dettagli come PDF
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
    /// NOP
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
            string query = "SELECT cognome + '-' + nome FROM persona WHERE id_persona = " + id;
            DataTableReader reader = Utility.ExecuteQuery(query);
            while (reader.Read())
            {
                FileName = reader[0].ToString();
                break;
            }

            FileName += "-Cariche";

            if (formato.Equals("xls"))
            {
                if (control.Equals("g1"))
                    GridViewExport.toXls(GridView1, FileName);
                if (control.Equals("d1"))
                    DetailsViewExport.toXls(DetailsView1, FileName + "-Dettaglio");
            }
            else if (formato.Equals("pdf"))
            {
                if (control.Equals("g1"))
                    GridViewExport.toPdf(GridView1, FileName);
                if (control.Equals("d1"))
                    DetailsViewExport.toPdf(DetailsView1, FileName + "-Dettaglio");
            }
        }

        base.Render(writer);
    }

    /// <summary>
    /// Refresh pagina post-inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_rec"].Value), "join_persona_organo_carica");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Chiude il modale appena aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Visualizza dettagli dell'elemento selezionato
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
    /// Metodo per gestione abilitazione
    /// </summary>
    /// <param name="obj">id tipo carica di riferimento</param>
    /// <returns>esito se disabilitare</returns>
    public bool IsEnabled(object obj)
    {
        if (obj == DBNull.Value)
            return true;

        if (obj == null)
            return true;

        int id_tipo_carica = Convert.ToInt32(obj);
        if (id_tipo_carica == id_tipo_carica_default)
        {
            // Se aministratore abilito 
            if (role.Equals(1))
                return true;
            else
                return false;
        }
        else
        {
            return true;
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