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
/// Classe per la gestione Dettagli Organi
/// </summary>

public partial class organi_dettaglio : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public int role;
    protected string id_org;
    public string logoName;

    string formato = "";

    public int id_legislatura;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        //var diz = Session.Contents.Keys.OfType<string>()
        //     .ToDictionary(p => p, p => Session.Contents[p]);

        string id = Request.QueryString["id"];
        string idleg = Request.QueryString["idleg"];
        string nuovo = Request.QueryString["nuovo"];
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        id_legislatura = Convert.ToInt32(Session.Contents["id_legislatura"]);

        if (id != null)
        {
            Session.Contents.Add("id_organo", id);
        }

        if (idleg != null)
            Session.Contents.Add("id_organo_leg", idleg);
        else
            Session.Contents.Add("id_organo_leg", id_legislatura);


        id = Session.Contents["id_organo"] as String;
        id_org = id;

        if (nuovo != null)
        {
            DetailsView1.ChangeMode(DetailsViewMode.Insert);
        }

        if (DetailsView1.CurrentMode == DetailsViewMode.Edit)
        {
            PanelFoto.Visible = true;
        }
        else
        {
            PanelFoto.Visible = false;
        }

        string logo = GetLogoName(id);

        if (logo != "")
        {
            logoName = "../loghi/" + logo;
        }
        else
        {
            logoName = "../loghi/fotond.jpg";
        }

        SetModeVisibility(Request.QueryString["mode"]);
    }


    protected void ddLeg_SelectedIndexChanged(object sender, EventArgs e)
    {
        var dd = (DropDownList)sender;
        var ddComm = DetailsView1.FindControl("dd_idcommissione") as DropDownList;


        var curVal = ddComm.SelectedValue;

        var qry = @"select null as id_organo, '' as nome_organo
                   union
                  select id_organo, nome_organo from organi 
                  where nome_organo like '%commissione%'
                  and id_legislatura = " + dd.SelectedValue + " order by nome_organo ";

        var table = Utility.GetTable(qry);
        ddComm.DataSourceID = null;
        ddComm.SelectedIndex = -1;
        ddComm.DataSource = table;
        ddComm.DataBind();
    }

    protected void ddIdComm_SelectedIndexChanged(object sender, EventArgs e)
    {

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
        Response.Redirect("gestisciOrgani.aspx");
    }

    /// <summary>
    /// Inizializzazione DetailsView prima della visualizzazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DetailsView1_PreRender(object sender, EventArgs e)
    {
        DropDownList ddLeg = DetailsView1.FindControl("dd_legislatura") as DropDownList;
        DropDownList ddComm = DetailsView1.FindControl("dd_idcommissione") as DropDownList;
        HiddenField hid = DetailsView1.FindControl("hid_id_commissione") as HiddenField;
        CheckBox chk = DetailsView1.FindControl("check_comitato_ristretto") as CheckBox;
        CheckBox chkVSC = DetailsView1.FindControl("check_vis_serv_comm") as CheckBox;
        //DropDownList ddTipoOrgano = DetailsView1.FindControl("dd_idtipoorgano") as DropDownList;

        if (ddLeg != null && ddComm != null && hid != null && chk != null)
        {
            if (role == 4)
            {
                chk.Checked = true;
                chk.Enabled = false;

                if (chkVSC != null)
                {
                    chkVSC.Checked = true;
                    chkVSC.Enabled = false;
                }
            }

            if (chk.Checked && ddLeg.SelectedValue != null && ddLeg.SelectedValue == Request.QueryString["idleg"])
                ddComm.SelectedValue = hid.Value;
        }
    }
    /// <summary>
    /// Impostazione campi per salvataggio record su db
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        DropDownList ddComm = DetailsView1.FindControl("dd_idcommissione") as DropDownList;
        e.Values["id_commissione"] = ddComm.SelectedValue;

        DropDownList ddTipoOrgano = DetailsView1.FindControl("dd_idtipoorgano") as DropDownList;
        e.Values["id_tipo_organo"] = ddTipoOrgano.SelectedValue;

        DropDownList ddCategoriaOrgano = DetailsView1.FindControl("dd_idcategoriaorgano") as DropDownList;
        e.Values["id_categoria_organo"] = ddTipoOrgano.SelectedValue;

        // campo obbligatorio
        TextBox txtDataInizio = DetailsView1.FindControl("dtIns_inizio_group") as TextBox;
        e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");

        TextBox txtDataFine = DetailsView1.FindControl("dtIns_fine_group") as TextBox;

        if (txtDataFine.Text.Length > 0)
        {
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        }
        else
        {
            e.Values["data_fine"] = null;
        }
    }

    /// <summary>
    /// Inizializzazione variabili pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        DropDownList ddComm = DetailsView1.FindControl("dd_idcommissione") as DropDownList;
        e.Keys["id_commissione"] = (!string.IsNullOrEmpty(ddComm.SelectedValue) ? ddComm.SelectedValue : null);

        // campo obbligatorio
        TextBox txtDataInizio = DetailsView1.FindControl("dtMod_inizio_group") as TextBox;
        e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtDataInizio.Text, "0", "0", "0");

        TextBox txtDataFine = DetailsView1.FindControl("dtMod_fine_group") as TextBox;
        if (txtDataFine.Text.Length > 0)
        {
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtDataFine.Text, "0", "0", "0");
        }
        else
        {
            e.Keys["data_fine"] = null;
        }

        DropDownList ddTipoOrgano = DetailsView1.FindControl("dd_idtipoorgano") as DropDownList;
        e.Keys["id_tipo_organo"] = (!string.IsNullOrEmpty(ddTipoOrgano.SelectedValue) ? ddTipoOrgano.SelectedValue : null);

        DropDownList ddCategoriaOrgano = DetailsView1.FindControl("dd_idcategoriaorgano") as DropDownList;
        e.Keys["id_categoria_organo"] = (!string.IsNullOrEmpty(ddCategoriaOrgano.SelectedValue) ? ddCategoriaOrgano.SelectedValue : null);

    }
    /// <summary>
    /// Log + Redirect post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "organi");
        Response.Redirect("gestisciOrgani.aspx");
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
            COrgano obj = new COrgano();

            obj.pk_id_organo = (int)e.Command.Parameters["@id_organo"].Value;

            obj.SendToOpenData("I");

            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_organo"].Value), "organi");
            Response.Redirect("dettaglio.aspx?id=" + e.Command.Parameters["@id_organo"].Value + "&idleg=" + e.Command.Parameters["@id_legislatura"].Value);
        }
    }
    /// <summary>
    /// Redirect post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            COrgano obj = new COrgano();

            obj.pk_id_organo = (int)e.Command.Parameters["@id_organo"].Value;

            obj.SendToOpenData("U");

            Response.Redirect("dettaglio.aspx?id=" + e.Command.Parameters["@id_organo"].Value + "&idleg=" + e.Command.Parameters["@id_legislatura"].Value);
        }
    }
    /// <summary>
    /// Operazione post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            COrgano obj = new COrgano();

            obj.pk_id_organo = (int)e.Command.Parameters["@id_organo"].Value;

            obj.SendToOpenData("D");
        }

    }

    protected void idComm_ServerValidate(object source, ServerValidateEventArgs args)
    {
        DropDownList ddComm = DetailsView1.FindControl("dd_idcommissione") as DropDownList;
        CheckBox chkCC = DetailsView1.FindControl("check_comitato_ristretto") as CheckBox;

        args.IsValid = true;
        if (chkCC.Checked)
            args.IsValid = (ddComm.SelectedIndex > 0);
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
            string FileName = "Organo";

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
    /// Log update operation
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "organi");
    }

    /// <summary>
    /// Carica l'allegato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Carica_Click(object sender, EventArgs e)
    {
        string id;
        string logoN;

        // otteniamo il path della cartella principale dell'applicazione
        string filePath = Request.PhysicalApplicationPath;

        // aggiungiamo il nome della nostra cartella al path
        filePath += "loghi/";

        // recupero id_persona
        id = id_org;

        // controlliamo se il controllo FileUpload1
        // contiene un file da caricare
        if (FileUpload1.HasFile)
        {
            // se si, aggiorniamo il path del file
            string extension = System.IO.Path.GetExtension(FileUpload1.FileName).ToLower();

            // Dà errore in caso di estensione non ammessa
            // o se le dimensioni superano 100k
            if (!extension.Equals(".jpg") || FileUpload1.PostedFile.ContentLength > 102400)
            {
                Session.Contents.Add("error_message", "La dimensione della foto non può superare i 100kB.");
                Response.Redirect("../errore.aspx");
                return;
            }

            logoN = id + extension;
            filePath += logoN;

            // salviamo il file nel percorso calcolato
            FileUpload1.SaveAs(filePath);

            // salviamo il nome della foto nel DB
            UpdLogoName(id, logoN);

            // inseriamo il nome della foto nella variabile globale per il primo caricamento
            logoName = "../loghi/" + logoN;

            DetailsView1.ChangeMode(DetailsViewMode.Edit);
        }
    }

    private void UpdLogoName(String Session_id, String logoN)
    {
        int updated;
        SqlConnection conn = null;

        try
        {
            conn = new SqlConnection(conn_string);
            conn.Open();

            string update = @"UPDATE organi 
                              SET logo = '" + logoN + "' " +
                             "WHERE id_organo = " + id_org;

            SqlCommand upd = new SqlCommand(update, conn);
            updated = upd.ExecuteNonQuery();
            conn.Close();
        }
        finally
        {
            if (conn != null)
            {
                conn.Close();
            }
        }
    }

    /// <summary>
    /// Metodo per scelta logo organo
    /// </summary>
    /// <param name="id_org">id di riferimento organo</param>
    /// <returns>Nome Logo</returns>
    private string GetLogoName(String id_org)
    {
        String logo = null;
        SqlConnection conn = null;
        SqlDataReader reader = null;

        if (id_org == null)
        {
            return "";
        }

        try
        {
            conn = new SqlConnection(conn_string);
            conn.Open();

            string select = @"SELECT logo 
                              FROM organi
                              WHERE id_organo = " + id_org;

            SqlCommand sel = new SqlCommand(select, conn);
            reader = sel.ExecuteReader();

            while (reader.Read())
            {
                logo = reader[0].ToString();
                break;
            }

            conn.Close();
        }
        finally
        {
            if (conn != null)
            {
                conn.Close();
            }
        }

        return logo;
    }
    /// <summary>
    /// Mostra/Nasconde il pannello esportazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ModeChanged(object sender, EventArgs e)
    {
        if (DetailsView1.CurrentMode == DetailsViewMode.Edit)
        {
            PanelFoto.Visible = true;
        }
        else
        {
            PanelFoto.Visible = false;
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
            a_dettaglio.HRef = "dettaglio.aspx?mode=popup";
            a_componenti.HRef = "componenti.aspx?mode=popup";
            a_cariche.HRef = "cariche.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=normal";
            a_componenti.HRef = "componenti.aspx?mode=normal";
            a_cariche.HRef = "cariche.aspx?mode=normal";

            a_back.Visible = true;
        }
    }
}