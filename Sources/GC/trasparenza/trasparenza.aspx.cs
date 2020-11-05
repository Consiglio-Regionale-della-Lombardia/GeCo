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
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Trasparenza
/// </summary>

public partial class trasparenza : System.Web.UI.Page
{
    string id;
    string sel_leg_id;
    string legislatura_corrente;
    public int role;
    public string nome_organo;
    public bool canEdit = false;

    public string photoName;

    int id_user;
    int id_user_role;

    string nome_completo;
    string title = "Altri cariche/incarichi, ";
    string tab = "Consiglieri - Altri cariche/incarichi";
    string filename = "Elenco_AltriCaricheIncarichi_";
    bool no_last_col = true;
    bool no_first_col = false;
    bool landscape = false;

    string query_cons_name = "SELECT cognome + ' ' + nome AS nome_completo FROM persona WHERE id_persona = ";

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
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

        canEdit = (role <= 2 || role == 8);

        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        id_user_role = Convert.ToInt32(Session.Contents["user_id_role"]);

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
            EseguiRicerca(false);
        }

        SetModeVisibility(Request.QueryString["mode"]);
        tabsPersona.SelectTab(EnumTabsPersona.a_trasparenza);
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
    /// Apertura popup per l'inserimento
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        DetailsView1.ChangeMode(DetailsViewMode.Insert);
        UpdatePanelDetails.Update();
        //UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>

    protected void EseguiRicerca()
    {
        EseguiRicerca(true);
    }


    /// <summary>
    /// Metodo Estrazione dati
    /// </summary>
    /// <param name="saveFilters">flag se salvare filtri</param>
    protected void EseguiRicerca(bool saveFilters)
    {
        //string query = SqlDataSource1.SelectCommand;
        //query += " ORDER BY jj.data_inizio DESC";
        //SqlDataSource1.SelectCommand = query;
        GridView1.DataBind();
    }
    /// <summary>
    /// Aggiorna dropdown
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DropDownListMissione_DataBound(object sender, EventArgs e)
    {
        DropDownList ddl = (DropDownList)sender;
        Utility.AddEmptyItem(ddl);
        DetailsView det = (DetailsView)ddl.NamingContainer;
        if (det.DataItem != null)
        {
            string key = ((DataRowView)det.DataItem)["id_certificato"].ToString();
            ddl.ClearSelection();
            System.Web.UI.WebControls.ListItem li = ddl.Items.FindByValue(key);
            if (li != null) li.Selected = true;
        }
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
    /// Log + Refresh post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_certificato"].Value), "certificati");
        }

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }
    /// <summary>
    /// Chiude il modale aperto
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        UpdatePanelDetails.Update();
        ModalPopupExtenderDetails.Hide();
    }
    /// <summary>
    /// Visualizza dettagli
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
        //UpdatePanelEsporta_Toggle();
        ModalPopupExtenderDetails.Show();
    }

    /// <summary>
    /// Inizializzazione context key
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void AutoCompleteExtenderSostituto_PreRender(object sender, EventArgs e)
    {
        AjaxControlToolkit.AutoCompleteExtender acei = DetailsView1.FindControl("AutoCompleteExtenderSostitutoInsert") as AjaxControlToolkit.AutoCompleteExtender;
        if (acei != null)
        {
            acei.ContextKey = id;
        }

        AjaxControlToolkit.AutoCompleteExtender acee = DetailsView1.FindControl("AutoCompleteExtenderSostitutoEdit") as AjaxControlToolkit.AutoCompleteExtender;
        if (acee != null)
        {
            acee.ContextKey = id;
        }
    }

    /// <summary>
    /// Metodo per gestione Visibilità
    /// </summary>
    /// <param name="p_mode">modalita di visibilità</param>

    protected void SetModeVisibility(string p_mode)
    {
        string complete_url = "&id=" + id + "&sel_leg_id=" + sel_leg_id;

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
    /// <summary>
    /// Aggiorna dropdown
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSourceLeg_DataBinding(object sender, EventArgs e)
    {
        if (DetailsView1.CurrentMode == DetailsViewMode.Insert)
        {
            FilterLegislatura filter = Session.GetFilterCertificati();
            DropDownList ddlLeg = DetailsView1.FindControl("DropDownListLeg") as DropDownList;
            ddlLeg.SelectedValue = (filter.IdLegislatura.HasValue ? filter.IdLegislatura.Value.ToString() : legislatura_corrente);
        }
    }

    /// <summary>
    /// Metodo per gestione Edit
    /// </summary>
    /// <param name="roleValue">Valore del ruolo</param>
    /// <returns>esito</returns>

    protected Boolean IsEditable(object roleValue)
    {
        if (role <= 2)
        {
            return true;
        }
        else
        {
            int id_role_insert = -1;
            return (roleValue != null && int.TryParse(roleValue.ToString(), out id_role_insert) && id_role_insert == id_user_role);
        }
    }


    protected void RefreshAllegati()
    {


    }


    protected void RefreshData()
    {
        GridView1.DataBind();

        UpdatePanelDetails.Update();
        UpdatePanelMaster.Update();
        ModalPopupExtenderDetails.Hide();
    }

    /// <summary>
    /// Refresh pagina post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        RefreshData();
    }
    /// <summary>
    /// Refresh pagina post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        RefreshData();
    }
    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        RefreshData();
    }

    /// <summary>
    /// Cancella allegato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void cmdDeleteAllegatoDichRedditi_Click(object sender, EventArgs e)
    {
        var cmd = (LinkButton)sender;

        var v = cmd.ValidationGroup.Split(';');

        int anno = int.Parse(v[0]);
        int id_legislatura = int.Parse(v[1]);
        int id_tipo_doc_trasparenza = int.Parse(v[2]);


        //if (int.TryParse(cmd.ValidationGroup, out anno) && anno > 0)
        //{
        AmministrazioneTrasparente.DichRedditi.Delete(int.Parse(id), anno, id_legislatura, id_tipo_doc_trasparenza);
        GridAllegati.DataBind();
        //}
    }

    /// <summary>
    /// Aggiunge allegato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void cmdNewAllegatoDichRedditi_Click(object sender, EventArgs e)
    {
        int anno;

        if (Page.IsValid)
        {
            //int anno = int.Parse(txAnno.Text);

            anno = txAnno.Text == "" ? 0 : int.Parse(txAnno.Text);

            int id_legislatura = int.Parse(DropDownListLegislatura.SelectedValue);
            int id_tipo_doc_trasparenza = int.Parse(DropDownTipo_Doc_Trasparenza.SelectedValue);
            bool mancato_consenso = chkbox_consenso.Checked;

            if (!mancato_consenso)
                if (uploadFileAllegatoDichRedditi.FileBytes != null && !string.IsNullOrEmpty(uploadFileAllegatoDichRedditi.FileName))
                    if (System.IO.Path.GetExtension(uploadFileAllegatoDichRedditi.FileName).Trim('.').ToUpper() != "PDF")
                        throw new Exception("Impossibile caricare il file: sono ammessi solo i PDF.");

            AmministrazioneTrasparente.DichRedditi.Save(uploadFileAllegatoDichRedditi.FileName, uploadFileAllegatoDichRedditi.FileBytes, int.Parse(id), anno, id_legislatura, id_tipo_doc_trasparenza, mancato_consenso);

        }

        GridAllegati.DataBind();
    }

    /// <summary>
    /// Metodo per generazione URL Dichiarazione redditi
    /// </summary>
    /// <param name="fileName">Nome file</param>
    /// <param name="anno">Anno di riferimento</param>
    /// <param name="id_legislatura">Id legislatura</param>
    /// <param name="id_tipo_doc_trasparenza">Tipologia trasparenza</param>
    /// <returns>Url</returns>
    public string getDichRedditiURL(object fileName, object anno, object id_legislatura, object id_tipo_doc_trasparenza)
    {
        var url = new StringBuilder("../allegati/allegatiDownload.aspx?type=#TYPE#&id=#ID#&anno=#ANNO#&id_legislatura=#ID_LEGISLATURA#&id_tipo_doc_trasparenza=#ID_TIPO_DOC_TRASPARENZA#&name=\"#NAME#\"");
        url.Replace("#TYPE#", "DR");
        url.Replace("#ID#", id);
        url.Replace("#ANNO#", anno.ToString());
        url.Replace("#ID_LEGISLATURA#", id_legislatura.ToString());
        url.Replace("#ID_TIPO_DOC_TRASPARENZA#", id_tipo_doc_trasparenza.ToString());
        url.Replace("#NAME#", HttpUtility.UrlPathEncode(fileName.ToString()));

        //return "openPopupWindow('" + url.ToString() + "')";
        return "document.location.href = '" + url.ToString() + "'; return false;";
        //return "alert('" + url.ToString() + "'); return false;";
    }


    /// <summary>
    /// Validazione lato server dell'allegato
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FileDichRedditiValidator_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = Regex.IsMatch(args.Value ?? "", @"\.pdf\s*$", RegexOptions.IgnoreCase);
    }

    /// <summary>
    /// Aggiorna trasparenza
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void DropDownTipo_Doc_Trasparenza_Change(object sender, EventArgs e)
    {
        int id;

        id = int.Parse(DropDownTipo_Doc_Trasparenza.SelectedValue);


        if (id == int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_PATRIMONIALE_MANCATO_CONSENSO"]))
        {
            LabelConsenso.Visible = true;
            chkbox_consenso.Visible = true;
            chkbox_consenso.Checked = false;
        }
        else
        {
            LabelConsenso.Visible = false;
            chkbox_consenso.Visible = false;
            chkbox_consenso.Checked = false;

        }

        if (id == int.Parse(System.Configuration.ConfigurationManager.AppSettings["TIPO_DOC_TRASPARENZA_ALTRE_CARICHE"]))
        {
            txAnno.Enabled = false;
            RequiredFieldValidatorAnno.Enabled = false;
        }
        else
        {
            txAnno.Enabled = true;
            RequiredFieldValidatorAnno.Enabled = true;
        }

        //LabelFile.Visible = true;
        //uploadFileAllegatoDichRedditi.Visible = true;
        uploadFileAllegatoDichRedditi.Enabled = true;
        FileDichRedditiValidator.ValidateEmptyText = true;
    }

    /// <summary>
    /// Aggiorna consenso
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void chkbox_consenso_OnCheckedChanged(object sender, EventArgs e)
    {
        if (chkbox_consenso.Checked)
        {
            //LabelFile.Visible = false;
            //uploadFileAllegatoDichRedditi.Visible = false;
            uploadFileAllegatoDichRedditi.Enabled = false;
            FileDichRedditiValidator.ValidateEmptyText = false;
        }
        else
        {
            //LabelFile.Visible = true;
            //uploadFileAllegatoDichRedditi.Visible = true;
            uploadFileAllegatoDichRedditi.Enabled = true;
            FileDichRedditiValidator.ValidateEmptyText = true;
        }

    }

}