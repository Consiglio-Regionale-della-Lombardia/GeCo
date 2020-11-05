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
/// Classe per la gestione Dettaglio scheda extra
/// </summary>

public partial class schede_extra_dettaglio : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string back_url = "schede_extra.aspx?mode=normal";
    public string action;

    public int id_user, id_scheda, id_persona, role;

    public string legislatura_corrente;
    public int id_organo;
    public int? logged_categoria_organo;


    string select_info_insert = @"SELECT pp.cognome + ' ' + pp.nome,
                                         CONVERT(varchar, jpoc.data_proclamazione, 103)
                                  FROM persona AS pp
                                  INNER JOIN join_persona_organo_carica AS jpoc
                                     ON pp.id_persona = jpoc.id_persona
                                  INNER JOIN organi AS oo
                                     ON jpoc.id_organo = oo.id_organo
                                  INNER JOIN cariche AS cc
                                     ON jpoc.id_carica = cc.id_carica
                                  INNER JOIN legislature AS ll
                                     ON jpoc.id_legislatura = ll.id_legislatura
                                  WHERE pp.deleted = 0
                                    AND oo.deleted = 0
                                    AND id_tipo_carica = 4 -- consigliere regionale
                                    AND id_categoria_organo = 1 --consiglio regionale
                                    AND pp.id_persona = @id_persona
                                    AND ll.id_legislatura = @id_legislatura";

    string insert_join_scheda_incarico = @"INSERT INTO join_scheda_incarico (id_scheda, id_incarico, deleted)
                                           SELECT @id_scheda,
                                                  ii.id_incarico,
                                                  0
                                           FROM scheda AS sc, incarico AS ii
                                           WHERE sc.deleted = 0
                                             AND ii.deleted = 0
                                             AND sc.id_scheda = @id_scheda
                                             AND ii.id_persona = @id_persona
                                             AND ii.data_inizio <= sc.data";
    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);
        legislatura_corrente = Session.Contents["id_legislatura"].ToString();
        logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;

        action = Session.Contents["action"].ToString();

        id_persona = Convert.ToInt32(Session.Contents["id_persona"]);

        if (action == "insert")
        {
            FormView1.ChangeMode(FormViewMode.Insert);

            if (!Page.IsPostBack)
            {
                DropDownList ddl_leg = FormView1.FindControl("ddl_insert_legislatura") as DropDownList;
                ddl_leg.SelectedValue = legislatura_corrente;
            }
        }
        else
        {
            id_scheda = Convert.ToInt32(Session.Contents["id_scheda"]);
        }
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


    protected void FormView1_ItemInserting(object sender, FormViewInsertEventArgs e)
    {
        e.Values["id_persona"] = id_persona;

        // legislatura
        DropDownList ddl_legislatura = FormView1.FindControl("ddl_insert_legislatura") as DropDownList;
        e.Values["id_legislatura"] = ddl_legislatura.SelectedValue;

        // gruppo consiliare
        DropDownList ddl_gruppo = FormView1.FindControl("ddl_insert_gruppo_consiliare") as DropDownList;
        if (ddl_gruppo.SelectedValue != "")
        {
            e.Values["id_gruppo"] = ddl_gruppo.SelectedValue;
        }
        else
        {
            e.Values["id_gruppo"] = null;
        }

        // data
        TextBox txt_data = FormView1.FindControl("txt_insert_dichiarazione_del") as TextBox;
        e.Values["data"] = Utility.ConvertStringToDateTime(txt_data.Text, "0", "0", "0");

        // indicazioni gde
        TextBox txt_indicazioni_gde = FormView1.FindControl("txt_insert_indicazioni_gde") as TextBox;
        if (txt_indicazioni_gde.Text != "")
        {
            e.Values["indicazioni_gde"] = txt_indicazioni_gde.Text;
        }
        else
        {
            e.Values["indicazioni_gde"] = null;
        }

        // indicazioni segreteria
        TextBox txt_indicazioni_seg = FormView1.FindControl("txt_insert_indicazioni_segreteria") as TextBox;
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
    /// Query post-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void SqlDataSource1_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {
            string new_id_scheda = e.Command.Parameters["@id_scheda"].Value.ToString();

            string comand = insert_join_scheda_incarico.Replace("@id_scheda", new_id_scheda);
            comand = comand.Replace("@id_persona", id_persona.ToString());

            Utility.ExecuteNonQuery(comand);

            Session.Contents["action"] = "item";
            Session.Contents["id_scheda"] = new_id_scheda;
        }
    }

    /// <summary>
    /// Inizializzazione pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView1_ItemUpdating(object sender, FormViewUpdateEventArgs e)
    {
        e.Keys["id_scheda"] = id_scheda;

        // legislatura
        //DropDownList ddl_legislatura = FormView1.FindControl("ddl_insert_legislatura") as DropDownList;
        //e.Keys["id_legislatura"] = ddl_legislatura.SelectedValue;

        // gruppo consiliare
        DropDownList ddl_gruppo = FormView1.FindControl("ddl_edit_gruppo_consiliare") as DropDownList;
        if (ddl_gruppo.SelectedValue != "")
        {
            e.Keys["id_gruppo"] = ddl_gruppo.SelectedValue;
        }
        else
        {
            e.Keys["id_gruppo"] = null;
        }

        // data
        //TextBox txt_data = FormView1.FindControl("txt_edit_dichiarazione_del") as TextBox;
        //e.Keys["data"] = Utility.ConvertStringToDateTime(txt_data.Text, "0", "0", "0");

        // indicazioni gde
        TextBox txt_indicazioni_gde = FormView1.FindControl("txt_edit_indicazioni_gde") as TextBox;
        if (txt_indicazioni_gde.Text != "")
        {
            e.Keys["indicazioni_gde"] = txt_indicazioni_gde.Text;
        }
        else
        {
            e.Keys["indicazioni_gde"] = null;
        }

        // indicazioni segreteria
        TextBox txt_indicazioni_seg = FormView1.FindControl("txt_edit_indicazioni_segreteria") as TextBox;
        if (txt_indicazioni_seg.Text != "")
        {
            e.Keys["indicazioni_seg"] = txt_indicazioni_seg.Text;
        }
        else
        {
            e.Keys["indicazioni_seg"] = null;
        }
    }

    /// <summary>
    /// Torna alla pagina precedente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView1_ItemDeleted(object sender, FormViewDeletedEventArgs e)
    {
        GoBack();
    }

    /// <summary>
    /// Torna alla pagina precedente
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void btn_insert_cancel_click(object sender, EventArgs e)
    {
        GoBack();
    }

    /// <summary>
    /// NOP
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void FormView1_ModeChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Refresh ddl legislatura
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ddl_insert_legislatura_databound(object sender, EventArgs e)
    {
        Label lbl_nome = FormView1.FindControl("lbl_insert_consigliere_2") as Label;

        Label lbl_data_procl = FormView1.FindControl("lbl_insert_data_proclamazione_2") as Label;

        DropDownList ddl_leg = sender as DropDownList;
        string leg_insert = ddl_leg.SelectedValue;

        string select = select_info_insert.Replace("@id_legislatura", leg_insert);
        select = select.Replace("@id_persona", id_persona.ToString());

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(select, conn);
        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            lbl_nome.Text = reader[0].ToString();
            lbl_data_procl.Text = reader[1].ToString();
            break;
        }

        conn.Close();
        conn.Dispose();
    }

    /// <summary>
    /// Torna alla pagina precedente
    /// </summary>
    protected void GoBack()
    {
        Session.Remove("action");
        Session.Remove("id_scheda");

        Response.Redirect(back_url);
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {

    }
    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {

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
        base.Render(writer);
    }

}