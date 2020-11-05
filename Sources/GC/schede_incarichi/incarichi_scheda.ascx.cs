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
using System.Collections;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


/// <summary>
/// Dichiarazione evento schedaChanged per modifica scheda
/// </summary>
/// <param name="sender">Oggetto che ha generato l'evento</param>
/// <param name="id_scheda">Id della scheda modificata</param>
public delegate void schedaChanged_event(object sender, int id_scheda);


/// <summary>
/// Classe per la gestione Scheda Incarichi
/// </summary>
public partial class incarichi_scheda : System.Web.UI.UserControl
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    public int id_user, id_legislatura, id_persona, id_scheda, role;
    public string selected_text_legislatura, selected_text_persona;

    public string nome_organo, legislatura_corrente;
    public int? logged_categoria_organo;

    string select_new_scheda = @"SELECT id_legislatura,
                                        id_persona,
                                        CONVERT(varchar, data, 120) AS data
                                 FROM scheda
                                 WHERE deleted = 0
                                   AND id_scheda = @id_scheda";

    string select_old_scheda = @"SELECT TOP(1) id_scheda
                                 FROM scheda
                                 WHERE deleted = 0
                                   AND id_scheda != @id_scheda
                                   AND id_legislatura = @id_legislatura
                                   AND id_persona = @id_persona
                                   AND CONVERT(varchar, data, 120) < '@data'
                                 ORDER BY data DESC";


    string insert_scheda_incarichi = @"INSERT INTO incarico (id_scheda, 
                                                             nome_incarico, 
                                                             riferimenti_normativi, 
                                                             data_cessazione, 
                                                             note_istruttorie, 
                                                             data_inizio,
	                                                         compenso,
	                                                         note_trasparenza,
                                                             deleted)
                                       SELECT @new_id_scheda,
                                              nome_incarico,
                                              riferimenti_normativi,
                                              data_cessazione,
                                              note_istruttorie,
                                              data_inizio,
	                                          compenso,
	                                          note_trasparenza,
                                              deleted
                                       FROM incarico
                                       WHERE deleted = 0
                                         AND id_scheda = @old_id_scheda";



    const int n_info_scheda = 9;
    const int n_info_incarico = 7; //4;

    public event schedaChanged_event SchedaAdded;
    public event schedaChanged_event SchedaDeleted;
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        legislatura_corrente = Session.Contents["id_legislatura"].ToString();

        if (role > 4 || role == 2)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
            logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;
        }
    }


    public void ChangeMode(FormViewMode mode)
    {
        FormView_Scheda.ChangeMode(mode);
    }

    /// <summary>
    /// /Metodo per generazione URL attachment
    /// </summary>
    /// <param name="idScheda">id di riferimento</param>
    /// <param name="fileName">Nome file</param>
    /// <returns>Url</returns>
    public string getAttachmentURL(object idScheda, object fileName)
    {
        var url = new StringBuilder("../allegati/allegatiDownload.aspx?type=#TYPE#&id=#ID#&name=#NAME#");
        url.Replace("#TYPE#", AllegatiType.Dichiarazione_IncExtraIst.ToString());
        url.Replace("#ID#", idScheda.ToString());
        url.Replace("#NAME#", HttpUtility.UrlPathEncode(fileName.ToString()));

        //return "openPopupWindow('" + url.ToString() + "')";
        return "document.location.href = '" + url.ToString() + "'; return false;";
    }

    protected void btn_insert_cancel_click(object sender, EventArgs e)
    {

    }

    #region DB OPERATIONS

    /// <summary>
    /// Gestione Evento ItemDeleted dell'oggetto FormView_Scheda
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void FormView_Scheda_ItemDeleted(object sender, FormViewDeletedEventArgs e)
    {
        var id_scheda = int.Parse(Session.Contents["selected_id_scheda"].ToString());
        Session.Remove("selected_id_scheda");

        //If attachment exists, delete it
        Allegati.DeleteBytes(id_scheda, AllegatiType.Dichiarazione_IncExtraIst, false);

        if (SchedaDeleted != null)
            SchedaDeleted(this, id_scheda);
    }

    /// <summary>
    /// Gestione Evento ItemInserting dell'oggetto FormView_Scheda
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void FormView_Scheda_ItemInserting(object sender, FormViewInsertEventArgs e)
    {
        // consiliere
        e.Values["id_persona"] = Session.Contents["selected_id_persona"].ToString();

        // legislatura
        e.Values["id_legislatura"] = Session.Contents["selected_id_legislatura"].ToString();

        // gruppo consiliare
        DropDownList ddl_gruppo = FormView_Scheda.FindControl("ddl_insert_gruppo_consiliare") as DropDownList;
        if (ddl_gruppo.SelectedValue != "")
        {
            e.Values["id_gruppo"] = ddl_gruppo.SelectedValue;
        }
        else
        {
            e.Values["id_gruppo"] = null;
        }

        // data
        TextBox txt_data = FormView_Scheda.FindControl("txt_insert_dichiarazione_del") as TextBox;
        e.Values["data"] = Utility.ConvertStringToDateTime(txt_data.Text, "0", "0", "0");

        // info seduta
        DropDownList ddl_info_seduta = FormView_Scheda.FindControl("ddl_insert_info_seduta") as DropDownList;
        if (ddl_info_seduta.SelectedValue != "")
        {
            e.Values["id_seduta"] = Convert.ToInt32(ddl_info_seduta.SelectedValue);
        }
        else
        {
            e.Values["id_seduta"] = null;
        }

        // indicazioni gde
        TextBox txt_indicazioni_gde = FormView_Scheda.FindControl("txt_insert_indicazioni_gde") as TextBox;
        if (txt_indicazioni_gde.Text != "")
        {
            e.Values["indicazioni_gde"] = txt_indicazioni_gde.Text;
        }
        else
        {
            e.Values["indicazioni_gde"] = null;
        }

        // indicazioni segreteria
        TextBox txt_indicazioni_seg = FormView_Scheda.FindControl("txt_insert_indicazioni_segreteria") as TextBox;
        if (txt_indicazioni_seg.Text != "")
        {
            e.Values["indicazioni_seg"] = txt_indicazioni_seg.Text;
        }
        else
        {
            e.Values["indicazioni_seg"] = null;
        }
    }

    /// <summary>
    /// Gestione Evento Inserted dell'oggetto SqlDataSource_Scheda
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource_Scheda_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            string new_id_scheda = e.Command.Parameters["@id_scheda"].Value.ToString();

            string query_new_scheda_info = select_new_scheda.Replace("@id_scheda", new_id_scheda);

            SqlConnection conn = new SqlConnection(conn_string);
            conn.Open();

            SqlCommand cmd = new SqlCommand(query_new_scheda_info, conn);
            SqlDataReader reader = cmd.ExecuteReader();

            string id_legislatura = "0";
            string id_persona = "0";
            string data = "19000101";

            while (reader.Read())
            {
                id_legislatura = reader[0].ToString();
                id_persona = reader[1].ToString();
                data = reader[2].ToString();

                break;
            }

            reader.Close();

            string query_old_id_scheda = select_old_scheda.Replace("@id_scheda", new_id_scheda);
            query_old_id_scheda = query_old_id_scheda.Replace("@id_legislatura", id_legislatura);
            query_old_id_scheda = query_old_id_scheda.Replace("@id_persona", id_persona);
            query_old_id_scheda = query_old_id_scheda.Replace("@data", data);


            cmd.CommandText = query_old_id_scheda;
            reader = cmd.ExecuteReader();

            string old_id_scheda = "0";

            while (reader.Read())
            {
                old_id_scheda = reader[0].ToString();

                break;
            }

            reader.Close();

            if (old_id_scheda != "0")
            {
                string insert = insert_scheda_incarichi.Replace("@new_id_scheda", new_id_scheda);
                insert = insert.Replace("@old_id_scheda", old_id_scheda);

                Utility.ExecuteNonQuery(insert);
            }

            reader.Close();
            reader.Dispose();

            conn.Close();
            conn.Dispose();

            Session.Contents["selected_id_scheda"] = new_id_scheda;

            //ddl_search_data_dichiarazione.DataBind();

            if (SchedaAdded != null)
                SchedaAdded(this, int.Parse(new_id_scheda));
        }
    }

    /// <summary>
    /// Gestione Evento ItemUpdating dell'oggetto FormView_Scheda
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void FormView_Scheda_ItemUpdating(object sender, FormViewUpdateEventArgs e)
    {
        // scheda
        e.Keys["id_scheda"] = Session.Contents["selected_id_scheda"].ToString();

        var schedaEdit = FormView_Scheda.FindControl("SchedaEdit");

        // gruppo consiliare
        DropDownList ddl_gruppo = schedaEdit.FindControl("ddl_edit_gruppo_consiliare") as DropDownList;
        if (ddl_gruppo.SelectedValue != "")
        {
            e.Keys["id_gruppo"] = ddl_gruppo.SelectedValue;
        }
        else
        {
            e.Keys["id_gruppo"] = null;
        }

        // info seduta
        DropDownList ddl_info_seduta = schedaEdit.FindControl("ddl_edit_info_seduta") as DropDownList;
        if (ddl_info_seduta.SelectedValue != "")
        {
            e.Keys["id_seduta"] = Convert.ToInt32(ddl_info_seduta.SelectedValue);
        }
        else
        {
            e.Keys["id_seduta"] = null;
        }

        // indicazioni gde
        TextBox txt_indicazioni_gde = schedaEdit.FindControl("txt_edit_indicazioni_gde") as TextBox;
        if (txt_indicazioni_gde.Text != "")
        {
            e.Keys["indicazioni_gde"] = txt_indicazioni_gde.Text;
        }
        else
        {
            e.Keys["indicazioni_gde"] = null;
        }

        // indicazioni segreteria
        TextBox txt_indicazioni_seg = schedaEdit.FindControl("txt_edit_indicazioni_segreteria") as TextBox;
        if (txt_indicazioni_seg.Text != "")
        {
            e.Keys["indicazioni_seg"] = txt_indicazioni_seg.Text;
        }
        else
        {
            e.Keys["indicazioni_seg"] = null;
        }

        //attached file
        e.Keys["filename"] = null;
        e.Keys["filesize"] = null;
        e.Keys["filehash"] = null;
        FileUpload uploadFile = schedaEdit.FindControl("uploadFile") as FileUpload;
        if (uploadFile.FileBytes != null && !string.IsNullOrEmpty(uploadFile.FileName))
        {
            if (System.IO.Path.GetExtension(uploadFile.FileName).Trim('.').ToUpper() == "PDF")
            {
                var hash = Allegati.ComputeHash(uploadFile.FileBytes);
                e.Keys["filename"] = uploadFile.FileName;
                e.Keys["filesize"] = uploadFile.FileBytes.Length;
                e.Keys["filehash"] = hash;
            }
            else
                throw new Exception("Impossibile caricare il file: sono ammessi solo i PDF.");
        }
        else
        {
            HiddenField hidden_filename = schedaEdit.FindControl("hidden_filename") as HiddenField;
            if (!string.IsNullOrEmpty(hidden_filename.Value))
            {
                e.Keys["filename"] = hidden_filename.Value;
            }
            HiddenField hidden_filesize = schedaEdit.FindControl("hidden_filesize") as HiddenField;
            if (!string.IsNullOrEmpty(hidden_filesize.Value))
            {
                e.Keys["filesize"] = hidden_filesize.Value;
            }
            HiddenField hidden_filehash = schedaEdit.FindControl("hidden_filehash") as HiddenField;
            if (!string.IsNullOrEmpty(hidden_filehash.Value))
            {
                e.Keys["filehash"] = hidden_filehash.Value;
            }
        }
    }

    /// <summary>
    /// Gestione Evento OnClick dell'oggetto LinkButtonPdfTrasparenza
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void FormView_Scheda_ItemUpdated(object sender, FormViewUpdatedEventArgs e)
    {
        var id_scheda = int.Parse(Session.Contents["selected_id_scheda"].ToString());

        var schedaEdit = FormView_Scheda.FindControl("SchedaEdit");
        FileUpload uploadFile = schedaEdit.FindControl("uploadFile") as FileUpload;

        if (uploadFile.FileBytes != null && !string.IsNullOrEmpty(uploadFile.FileName))
        {
            if (System.IO.Path.GetExtension(uploadFile.FileName).Trim('.').ToUpper() == "PDF")
            {
                //File added by user, save it on disk (replace if exists for id_scheda)
                Allegati.ReplaceBytes(id_scheda, uploadFile.FileBytes, AllegatiType.Dichiarazione_IncExtraIst);
            }
        }
        else
        {
            HiddenField hidden_filename = schedaEdit.FindControl("hidden_filename") as HiddenField;
            if (string.IsNullOrEmpty(hidden_filename.Value))
            {
                //File deleted by user, remove it from disk
                Allegati.DeleteBytes(id_scheda, AllegatiType.Dichiarazione_IncExtraIst, false);
            }
        }
    }

    #endregion

    #region PRINT PDF

    /// <summary>
    /// Gestione Evento OnClick dell'oggetto LinkButtonPdfTrasparenza
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Print_SchedaTrasparenza(object sender, EventArgs e)
    {
        string[] info_scheda = new string[n_info_scheda];
        ArrayList info_incarichi = new ArrayList();

        GetInfoToPrint(FormView_Scheda, info_scheda, info_incarichi);

        DetailsViewExport.StampaSchedaPDF(Page.Response, Page.Request, info_scheda, info_incarichi, true);
    }

    /// <summary>
    /// Gestione Evento OnClick dell'oggetto LinkButtonPdfDetails
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Print_Scheda(object sender, EventArgs e)
    {
        string[] info_scheda = new string[n_info_scheda];
        ArrayList info_incarichi = new ArrayList();

        GetInfoToPrint(FormView_Scheda, info_scheda, info_incarichi);

        DetailsViewExport.StampaSchedaPDF(Page.Response, Page.Request, info_scheda, info_incarichi, false);
    }


    protected void GetInfoToPrint(FormView p_form, string[] p_info_scheda, ArrayList p_info_incarichi)
    {
        BuildInfoScheda(p_form, p_info_scheda);

        BuildInfoIncarichi(p_form, p_info_incarichi);
    }


    protected void BuildInfoScheda(FormView p_form, string[] p_info_scheda)
    {
        // Nome Organo
        Label lbl_nome_organo = p_form.FindControl("lbl_item_organo") as Label;
        p_info_scheda[0] = lbl_nome_organo.Text;

        // Legislatura
        Label lbl_item_legislatura_2 = p_form.FindControl("lbl_item_legislatura_2") as Label;
        p_info_scheda[1] = lbl_item_legislatura_2.Text;

        // Consigliere
        Label lbl_item_consigliere_2 = p_form.FindControl("lbl_item_consigliere_2") as Label;
        p_info_scheda[2] = lbl_item_consigliere_2.Text;

        // Gruppo Consiliare
        Label lbl_item_gruppo_consiliare_2 = p_form.FindControl("lbl_item_gruppo_consiliare_2") as Label;
        p_info_scheda[3] = lbl_item_gruppo_consiliare_2.Text;

        // Data Proclamazione
        Label lbl_item_data_proclamazione_2 = p_form.FindControl("lbl_item_data_proclamazione_2") as Label;
        p_info_scheda[4] = lbl_item_data_proclamazione_2.Text;

        // Dichiarazione del
        Label lbl_item_dichiarazione_del_2 = p_form.FindControl("lbl_item_dichiarazione_del_2") as Label;
        p_info_scheda[5] = lbl_item_dichiarazione_del_2.Text;

        // Seduta
        Label lbl_item_info_seduta_val = p_form.FindControl("lbl_item_info_seduta_val") as Label;
        p_info_scheda[6] = lbl_item_info_seduta_val.Text;

        // Indicazioni GDE
        Label lbl_item_indicazioni_gde_2 = p_form.FindControl("lbl_item_indicazioni_gde_2") as Label;
        p_info_scheda[7] = lbl_item_indicazioni_gde_2.Text;

        // Indicazioni Segreteria
        Label lbl_item_indicazioni_segreteria_2 = p_form.FindControl("lbl_item_indicazioni_segreteria_2") as Label;
        p_info_scheda[8] = lbl_item_indicazioni_segreteria_2.Text;
    }

    protected void BuildInfoIncarichi(FormView p_form, ArrayList p_info_incarichi)
    {
        string query_incarichi = SQLDataSource_Incarichi.SelectCommand;
        query_incarichi = query_incarichi.Replace("@id_scheda", Session.Contents["selected_id_scheda"].ToString());
        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(query_incarichi, conn);

        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            string[] incarico = new string[n_info_incarico];

            for (int i = 1; i < reader.FieldCount; i++)
            {
                incarico[i - 1] = reader[i].ToString();
            }

            p_info_incarichi.Add(incarico);
        }

        reader.Close();
        reader.Dispose();

        conn.Close();
        conn.Dispose();
    }

    #endregion

}