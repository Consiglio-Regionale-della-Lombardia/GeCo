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
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Dettaglio Gruppi Politici
/// </summary>
public partial class gruppi_politici_dettaglio : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    string legislatura_corrente;

    public string legislatura_corrente_num;

    public int role;

    string formato = "";
    string control = "";

    string select_rename_idcausa = @"SELECT id_causa
                                     FROM tbl_cause_fine
                                     WHERE descrizione_causa like '%riden%'
                                       AND LOWER(tipo_causa) = 'gruppi-politici'";

    string select_aggregate_idcausa = @"SELECT id_causa
                                        FROM tbl_cause_fine
                                        WHERE descrizione_causa like '%aggreg%'
                                          AND LOWER(tipo_causa) = 'gruppi-politici'";


    /// <summary>
    /// Carica dettagli gruppi politici
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        //legislatura_corrente = Session.Contents["id_legislatura"] as string;

        legislatura_corrente = Session.Contents["id_legislatura_search"] as string;

        legislatura_corrente_num = Utility.GetLegislaturaName(legislatura_corrente);

        role = Convert.ToInt32(Session.Contents["logged_role"]);

        string id = Request.QueryString["id"];
        string nuovo = Request.QueryString["nuovo"];
        string aggrega = Request.QueryString["aggrega"];
        string rinomina = Request.QueryString["rinomina"];

        if (id != null)
        {
            Session.Contents.Add("id_gruppo", id);
        }

        if (nuovo != null)
        {
            DetailsView1.ChangeMode(DetailsViewMode.Insert);
        }

        if (rinomina != null)
        {
            DetailsView1.ChangeMode(DetailsViewMode.Edit);
            LabelGruppiAggregati.Text = "Verrà creato un nuovo gruppo come ridenominazione del precedente.";
        }

        if (aggrega != null) // stampa la label che avverte dell'aggregazione
        {
            LabelGruppiAggregati.Text = "Il gruppo verrà creato come aggregazione dei seguenti gruppi:";
            ArrayList gruppi_aggregati = Session.Contents["gruppi_aggregati"] as ArrayList;

            foreach (string gruppo in gruppi_aggregati)
            {
                string query = @"SELECT nome_gruppo 
                                 FROM gruppi_politici 
                                 WHERE id_gruppo = " + gruppo;

                DataTableReader reader = Utility.ExecuteQuery(query);

                while (reader.Read())
                {
                    LabelGruppiAggregati.Text = LabelGruppiAggregati.Text + "<br />&bull; " + reader[0].ToString();
                    break;
                }

                reader.Close();
            }

            LabelGruppiAggregati.Text = LabelGruppiAggregati.Text + "<br /><br />";
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
    /// Annulla inserimento gruppo politico
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void ButtonAnnulla_Click(object sender, EventArgs e)
    {
        Session.Contents.Remove("gruppi_aggregati");
        Session.Contents.Remove("gruppo_ridenominazione");
        Session.Contents.Remove("gruppo_ridenominato");
        Response.Redirect("gestisciGruppiPolitici.aspx");
    }

    /// <summary>
    /// Inizializzazione parametri pre-insert
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        // La data di inizio è obbligatoria
        TextBox txtInsertDataInizio = DetailsView1.FindControl("dtIns_inizio_group") as TextBox;
        e.Values["data_inizio"] = Utility.ConvertStringToDateTime(txtInsertDataInizio.Text, "0", "0", "0");

        // La data di fine invece non è obbligatoria
        TextBox txtInsertDataFine = DetailsView1.FindControl("dtIns_fine_group") as TextBox;
        if (txtInsertDataFine.Text != "")
        {
            e.Values["data_fine"] = Utility.ConvertStringToDateTime(txtInsertDataFine.Text, "0", "0", "0");
            e.Values["attivo"] = false;
        }
        else
        {
            e.Values["data_fine"] = null;
            e.Values["attivo"] = true;
        }
    }

    /// <summary>
    /// Inserisce gruppi politici
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource4_Inserted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {

            string id_gruppo = Convert.ToString(e.Command.Parameters["@id_gruppo"].Value);

            ExecuteUpdateJPGP(id_gruppo);

            CGruppoPolitico obj = new CGruppoPolitico();

            obj.pk_id_gruppo = (int)e.Command.Parameters["@id_gruppo"].Value;

            obj.SendToOpenData("I");

            // Se il gruppo è creato come aggregazione di altri, effettua la logica
            ArrayList gruppi_aggregati = Session.Contents["gruppi_aggregati"] as ArrayList;

            if (gruppi_aggregati != null)
            {
                string query = "";

                string new_id_gruppo = e.Command.Parameters["@id_gruppo"].Value.ToString();
                string new_data_inizio = "";
                DateTime new_date;

                SqlConnection con = new SqlConnection(conn_string);
                con.Open();
                SqlTransaction tx = con.BeginTransaction();

                try
                {
                    query = @"SELECT data_inizio 
                              FROM gruppi_politici 
                              WHERE id_gruppo = " + new_id_gruppo;

                    SqlDataReader reader = new SqlCommand(query, con, tx).ExecuteReader();

                    while (reader.Read())
                    {
                        new_date = Convert.ToDateTime(reader[0]);
                        new_date = new_date.AddDays(-1);
                        new_data_inizio = Utility.ConvertDateTimeToANSIString(new_date).Substring(0, 8);
                        break;
                    }

                    reader.Close();

                    SqlConnection con2 = new SqlConnection(conn_string);
                    SqlCommand cmd = new SqlCommand(select_aggregate_idcausa, con2);
                    con2.Open();
                    SqlDataReader reader_causa = cmd.ExecuteReader();

                    reader_causa.Read();
                    string id_causa = reader_causa[0].ToString();

                    reader_causa.Dispose();
                    con2.Close();
                    con2.Dispose();

                    /* già inviato
                    CGruppoPolitico obj1 = new CGruppoPolitico();

                    obj1.pk_id_gruppo = (int)e.Command.Parameters["@id_gruppo"].Value;

                    obj1.SendToOpenData("I");
                    */


                    // cicla ogni per ogni gruppo vecchio
                    foreach (string old_id_gruppo in gruppi_aggregati)
                    {
                        SqlCommand cmd_tmp = new SqlCommand();
                        cmd_tmp.Connection = con;
                        cmd_tmp.Transaction = tx;

                        // update del vecchio gruppo
                        query = @"UPDATE gruppi_politici 
                                  SET data_fine = '" + new_data_inizio + "', " +
                                     "attivo = 0, " +
                                     "id_causa_fine = " + id_causa +
                                " WHERE id_gruppo = " + old_id_gruppo;

                        //new SqlCommand(query, con, tx).ExecuteNonQuery();
                        cmd_tmp.CommandText = query;
                        cmd_tmp.ExecuteNonQuery();

                        // inserimento in storia
                        query = @"INSERT INTO gruppi_politici_storia (id_padre, 
                                                                      id_figlio) 
                                  VALUES (" + old_id_gruppo + ", " + new_id_gruppo + ")";

                        //new SqlCommand(query, con, tx).ExecuteNonQuery();
                        cmd_tmp.CommandText = query;
                        cmd_tmp.ExecuteNonQuery();




                        // copia i vecchi record in join_persona_gruppi_politici
                        query = @"INSERT INTO join_persona_gruppi_politici (id_gruppo, 
                                                                            id_persona,  
                                                                            id_carica,
                                                                            id_legislatura,
                                                                            numero_pratica, 
                                                                            numero_delibera_inizio, 
                                                                            data_delibera_inizio, 
                                                                            tipo_delibera_inizio, 
                                                                            numero_delibera_fine, 
                                                                            data_delibera_fine, 
                                                                            tipo_delibera_fine, 
                                                                            data_inizio, 
                                                                            data_fine, 
                                                                            protocollo_gruppo, 
                                                                            varie) 
				                  SELECT " + new_id_gruppo + @" AS id_gruppo, 
                                         id_persona, 
                                         id_carica,
                                         id_legislatura,
                                         numero_pratica, 
                                         numero_delibera_inizio, 
                                         data_delibera_inizio, 
                                         tipo_delibera_inizio, 
                                         numero_delibera_fine,
                                         data_delibera_fine, 
                                         tipo_delibera_fine, 
                                         data_inizio, 
                                         data_fine, 
                                         protocollo_gruppo, 
                                         varie 
                                  FROM join_persona_gruppi_politici 
				                  WHERE deleted = 0 
                                    AND data_fine IS NULL 
                                    AND id_persona IS NOT NULL 
                                    AND id_gruppo = " + old_id_gruppo;

                        //new SqlCommand(query, con, tx).ExecuteNonQuery();
                        cmd_tmp.CommandText = query;
                        cmd_tmp.ExecuteNonQuery();

                        // update di tutti i vecchi record in join_persona_gruppi_politici
                        query = @"UPDATE join_persona_gruppi_politici 
                                  SET data_fine = '" + new_data_inizio + @"' 
                                  WHERE id_gruppo = " + old_id_gruppo;

                        //new SqlCommand(query, con, tx).ExecuteNonQuery();
                        cmd_tmp.CommandText = query;
                        cmd_tmp.ExecuteNonQuery();

                        // update di tutti i nuovi record in join_persona_gruppi_politici
                        query = @"UPDATE join_persona_gruppi_politici 
                                  SET data_inizio = '" + new_data_inizio + @"' 
                                  WHERE id_gruppo = " + new_id_gruppo;

                        //new SqlCommand(query, con, tx).ExecuteNonQuery();
                        cmd_tmp.CommandText = query;
                        cmd_tmp.ExecuteNonQuery();



                        query = @"UPDATE join_gruppi_politici_legislature 
                                  SET data_fine = '" + new_data_inizio + @"'
                                  WHERE id_gruppo = " + old_id_gruppo;

                        cmd_tmp.CommandText = query;
                        cmd_tmp.ExecuteNonQuery();


                    }

                    tx.Commit();
                    con.Close();

                    CGruppoPoliticoPersone objGruppoPoliticoPersone = new CGruppoPoliticoPersone();

                    objGruppoPoliticoPersone.pk_id_gruppo = Convert.ToInt32(new_id_gruppo);

                    objGruppoPoliticoPersone.SendToOpenData("I");

                    foreach (string old_id_gruppo in gruppi_aggregati)
                    {
                        CGruppoPolitico obj_old = new CGruppoPolitico();

                        obj_old.pk_id_gruppo = Convert.ToInt32(old_id_gruppo);

                        obj_old.SendToOpenData("U");

                        objGruppoPoliticoPersone = new CGruppoPoliticoPersone();

                        objGruppoPoliticoPersone.pk_id_gruppo = Convert.ToInt32(old_id_gruppo);

                        objGruppoPoliticoPersone.SendToOpenData("U");
                    }

                    Session.Contents.Remove("gruppi_aggregati");
                }
                catch (SqlException sqlError)
                {
                    tx.Rollback();
                    con.Close();

                    Session.Contents.Add("error_message", sqlError.Message.ToString());
                    Response.Redirect("../errore.aspx");
                }
            }
            else
            {

            }

            Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Command.Parameters["@id_gruppo"].Value), "gruppi_politici");

            Response.Redirect("dettaglio.aspx?id=" + e.Command.Parameters["@id_gruppo"].Value);
        }
    }

    /// <summary>
    /// Aggiorna gruppi politici
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource4_Updated(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {


            string sql = @"UPDATE join_gruppi_politici_legislature
                          SET data_inizio = @data_inizio,
                              data_fine = @data_fine
                          WHERE id_gruppo = @id_gruppo
                          AND id_legislatura = @id_legislatura";


            string id_gruppo = Convert.ToString(e.Command.Parameters["@id_gruppo"].Value);

            sql = sql.Replace("@id_gruppo", id_gruppo);

            TextBox dtMod_inizio_group = DetailsView1.FindControl("dtMod_inizio_group") as TextBox;
            sql = sql.Replace("@data_inizio", "'" + Utility.ConvertStringToDateTime(dtMod_inizio_group.Text, "0", "0", "0").ToString("yyyyMMdd") + "'");

            TextBox dtMod_fine_group = DetailsView1.FindControl("dtMod_fine_group") as TextBox;

            if (dtMod_fine_group.Text != "")
                sql = sql.Replace("@data_fine", "'" + Utility.ConvertStringToDateTime(dtMod_fine_group.Text, "0", "0", "0").ToString("yyyyMMdd") + "'");
            else
                sql = sql.Replace("@data_fine", "null");

            if (legislatura_corrente == "")
                sql = sql.Replace("@id_legislatura", Session.Contents["id_legislatura"].ToString());
            else
                sql = sql.Replace("@id_legislatura", legislatura_corrente);

            Utility.ExecuteNonQuery(sql);



            CGruppoPolitico obj = new CGruppoPolitico();

            obj.pk_id_gruppo = (int)e.Command.Parameters["@id_gruppo"].Value;

            obj.SendToOpenData("U");
        }
    }

    /// <summary>
    /// Delete gruppo politico
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource4_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        if (e.Exception == null)
        {

            CGruppoPolitico obj = new CGruppoPolitico();

            obj.pk_id_gruppo = (int)e.Command.Parameters["@id_gruppo"].Value;

            obj.SendToOpenData("D");

        }

    }

    /// <summary>
    /// Aggiorna JGPL
    /// </summary>
    /// <param name="id_gruppo">gruppo di riferimento</param>
    private void ExecuteUpdateJPGP(string id_gruppo)
    {

        string insert_jgpl = @"INSERT INTO join_gruppi_politici_legislature (id_gruppo
                                                                            ,id_legislatura
                                                                            ,data_inizio
                                                                            ,data_fine
                                                                            ,deleted)
                               VALUES (@id_gruppo
                                      ,@id_legislatura
                                      ,@data_inizio
                                      ,@data_fine
                                      ,0)";



        insert_jgpl = insert_jgpl.Replace("@id_gruppo", id_gruppo);

        TextBox txtInsertDataInizio = DetailsView1.FindControl("dtIns_inizio_group") as TextBox;
        insert_jgpl = insert_jgpl.Replace("@data_inizio", "'" + Utility.ConvertStringToDateTime(txtInsertDataInizio.Text, "0", "0", "0").ToString("yyyyMMdd") + "'");

        TextBox txtInsertDataFine = DetailsView1.FindControl("dtIns_fine_group") as TextBox;
        if (txtInsertDataFine.Text != "")
            insert_jgpl = insert_jgpl.Replace("@data_fine", "'" + Utility.ConvertStringToDateTime(txtInsertDataFine.Text, "0", "0", "0").ToString("yyyyMMdd") + "'");
        else
            insert_jgpl = insert_jgpl.Replace("@data_fine", "null");


        if (legislatura_corrente == "")
            insert_jgpl = insert_jgpl.Replace("@id_legislatura", Session.Contents["id_legislatura"].ToString());
        else
            insert_jgpl = insert_jgpl.Replace("@id_legislatura", legislatura_corrente);

        Utility.ExecuteNonQuery(insert_jgpl);
    }

    /// <summary>
    /// Inizializzazione parametri pre-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdating(object sender, DetailsViewUpdateEventArgs e)
    {
        // Si sta creando il gruppo come ridenominazione del precedente
        string new_id_gruppo = Session.Contents["gruppo_ridenominazione"] as string;
        string old_id_gruppo = "";

        // PRIMA di eseguire la update, si copia il vecchio record
        if (new_id_gruppo != null)
        {
            string query = "";

            SqlConnection con = new SqlConnection(conn_string);
            con.Open();
            SqlTransaction tx = con.BeginTransaction();

            try
            {
                SqlCommand cmd_tmp = new SqlCommand();
                cmd_tmp.Connection = con;
                cmd_tmp.Transaction = tx;

                // copia il vecchio record
                query = @"INSERT INTO gruppi_politici (codice_gruppo, 
                                                       nome_gruppo, 
                                                       data_inizio,                                                        
                                                       data_fine, 
                                                       attivo, 
                                                       id_causa_fine, 
                                                       protocollo, 
                                                       numero_delibera, 
                                                       data_delibera, 
                                                       id_delibera) 
			              SELECT codice_gruppo, 
                                 nome_gruppo, 
                                 data_inizio, 
                                 data_fine, 
                                 attivo, 
                                 id_causa_fine, 
                                 protocollo, 
                                 numero_delibera, 
                                 data_delibera, 
                                 id_delibera 
                          FROM gruppi_politici 
                          WHERE id_gruppo = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // get della id del gruppo vecchio
                query = @"SELECT @@IDENTITY 
                          FROM gruppi_politici";

                SqlDataReader reader = new SqlCommand(query, con, tx).ExecuteReader();

                while (reader.Read())
                {
                    old_id_gruppo = reader[0].ToString();
                    break;
                }

                reader.Close();

                query = @"INSERT INTO join_gruppi_politici_legislature 
                          SELECT " + old_id_gruppo + @" AS id_gruppo,
                                 id_legislatura,
                                 data_inizio,
                                 data_fine,
                                 deleted
                          FROM join_gruppi_politici_legislature
                          WHERE id_gruppo = " + new_id_gruppo;

                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                tx.Commit();
                con.Close();

                CGruppoPolitico obj = new CGruppoPolitico();

                obj.pk_id_gruppo = Convert.ToInt32(old_id_gruppo);

                obj.SendToOpenData("I");

            }
            catch (SqlException sqlError)
            {
                tx.Rollback();
                con.Close();

                Session.Contents.Add("error_message", sqlError.Message.ToString());
                Response.Redirect("../errore.aspx");
            }

            Session.Contents.Add("gruppo_ridenominato", old_id_gruppo);
        }

        TextBox txtUpdateDataInizio = DetailsView1.FindControl("dtMod_inizio_group") as TextBox;
        e.Keys["data_inizio"] = Utility.ConvertStringToDateTime(txtUpdateDataInizio.Text, "0", "0", "0");

        TextBox txtUpdateDataFine = DetailsView1.FindControl("dtMod_fine_group") as TextBox;
        if (txtUpdateDataFine.Text != "")
        {
            e.Keys["data_fine"] = Utility.ConvertStringToDateTime(txtUpdateDataFine.Text, "0", "0", "0");
            e.Keys["attivo"] = false;
        }
        else
        {
            e.Keys["data_fine"] = null;
            e.Keys["attivo"] = true;
        }
    }

    /// <summary>
    /// Refresh pagina post-update
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemUpdated(object sender, DetailsViewUpdatedEventArgs e)
    {
        Audit.LogUpdate(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "gruppi_politici");

        // Si sta creando il gruppo come ridenominazione del precedente
        string new_id_gruppo = Session.Contents["gruppo_ridenominazione"] as string;
        string old_id_gruppo = Session.Contents["gruppo_ridenominato"] as string;

        // DOPO aver eseguito la update si effettua il resto della logica
        if (new_id_gruppo != null && old_id_gruppo != null)
        {
            // La data inizio del nuovo gruppo deve essere usata per tutte le operazioni di update 	
            string new_data = Utility.ConvertDateTimeToANSIString(e.Keys["data_inizio"]);

            DateTime dt = Convert.ToDateTime(e.Keys["data_inizio"]);
            dt = dt.AddDays(-1);
            string old_data_fine = Utility.ConvertDateTimeToANSIString(dt);

            string query = "";

            SqlConnection con = new SqlConnection(conn_string);
            con.Open();
            SqlTransaction tx = con.BeginTransaction();

            SqlConnection con2 = new SqlConnection(conn_string);
            SqlCommand cmd = new SqlCommand(select_rename_idcausa, con2);
            con2.Open();
            SqlDataReader reader_causa = cmd.ExecuteReader();

            reader_causa.Read();
            string id_causa = reader_causa[0].ToString();

            reader_causa.Dispose();
            con2.Close();
            con2.Dispose();

            try
            {
                SqlCommand cmd_tmp = new SqlCommand();
                cmd_tmp.Connection = con;
                cmd_tmp.Transaction = tx;

                // copia i vecchi record in join_persona_gruppi_politici
                query = @"INSERT INTO join_persona_gruppi_politici (id_gruppo, 
                                                                    id_persona,  
                                                                    id_carica,
                                                                    id_legislatura,
                                                                    numero_pratica, 
                                                                    numero_delibera_inizio, 
                                                                    data_delibera_inizio, 
                                                                    tipo_delibera_inizio, 
                                                                    numero_delibera_fine, 
                                                                    data_delibera_fine, 
                                                                    tipo_delibera_fine, 
                                                                    data_inizio, 
                                                                    data_fine, 
                                                                    protocollo_gruppo, 
                                                                    varie) 
                          SELECT " + old_id_gruppo + @" AS id_gruppo, 
                                 id_persona, 
                                 id_carica,
                                 id_legislatura,
                                 numero_pratica, 
                                 numero_delibera_inizio, 
                                 data_delibera_inizio, 
                                 tipo_delibera_inizio, 
                                 numero_delibera_fine, 
                                 data_delibera_fine, 
                                 tipo_delibera_fine, 
                                 data_inizio, 
                                 data_fine, 
                                 protocollo_gruppo, 
                                 varie 
                          FROM join_persona_gruppi_politici 
                          WHERE deleted = 0
                            AND id_gruppo = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();


                // update del vecchio gruppo
                query = @"UPDATE gruppi_politici 
                          SET data_fine = '" + old_data_fine + @"', 
                              attivo = 0, 
                              id_causa_fine = " + id_causa +
                        " WHERE id_gruppo = " + old_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // update di tutti i vecchi record in join_persona_gruppi_politici
                query = @"UPDATE join_persona_gruppi_politici 
                          SET data_fine = '" + new_data + "' " +
                        @"WHERE deleted = 0
                            AND data_fine IS NULL
                            AND id_gruppo = " + old_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // update di tutti i vecchi record in gruppi_politici_storia
                query = @"UPDATE gruppi_politici_storia 
                          SET id_padre = " + old_id_gruppo +
                       @" WHERE deleted = 0 
                            AND id_padre = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                query = @"UPDATE gruppi_politici_storia 
                          SET id_figlio = " + old_id_gruppo +
                       @" WHERE deleted = 0 
                            AND id_figlio = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // update del nuovo gruppo
                query = @"UPDATE gruppi_politici 
                          SET data_inizio = '" + new_data + @"', 
                              attivo = 1 
                          WHERE id_gruppo = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // invio ad open data i record copiati ma già scaduti da join_persona_gruppi_politici
                /******************************************************************************************************************/
                query = "select id_rec " +
                        "from join_persona_gruppi_politici " +
                        "where data_fine is not null " +
                        "and id_gruppo = @id_gruppo";

                cmd_tmp.CommandText = query;

                SqlParameter prm = new SqlParameter("@id_gruppo", new_id_gruppo);
                cmd_tmp.Parameters.Add(prm);

                SqlDataReader reader = cmd_tmp.ExecuteReader();

                CGruppoPoliticoPersona objGruppoPoliticoPersona = null;

                while (reader.Read())
                {
                    objGruppoPoliticoPersona = new CGruppoPoliticoPersona();
                    objGruppoPoliticoPersona.pk_id_rec = Convert.ToInt32(reader["id_rec"].ToString());

                    objGruppoPoliticoPersona.SendToOpenData("D");
                }

                reader.Close();
                /******************************************************************************************************************/

                // elimina i record copiati ma già scaduti da join_persona_gruppi_politici
                query = @"DELETE FROM join_persona_gruppi_politici 
                          WHERE data_fine IS NOT NULL 
                            AND id_gruppo = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // update di tutti i nuovi record in join_persona_gruppi_politici
                query = @"UPDATE join_persona_gruppi_politici 
                        SET data_inizio = '" + new_data + @"' 
                        WHERE id_gruppo = " + new_id_gruppo;

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                // inserire record in gruppi_politici_storia
                query = @"INSERT INTO gruppi_politici_storia (id_padre, 
                                                              id_figlio) 
                          VALUES (" + old_id_gruppo + ", " + new_id_gruppo + ")";

                //new SqlCommand(query, con, tx).ExecuteNonQuery();
                cmd_tmp.CommandText = query;
                cmd_tmp.ExecuteNonQuery();

                query = @"UPDATE join_gruppi_politici_legislature
                          SET data_fine = '" + old_data_fine + @"' 
                          WHERE id_gruppo = " + old_id_gruppo +
                          " AND id_legislatura = " + legislatura_corrente;

                tx.Commit();
                con.Close();

                CGruppoPolitico obj = new CGruppoPolitico();

                obj.pk_id_gruppo = Convert.ToInt32(old_id_gruppo);

                obj.SendToOpenData("I");

                obj = new CGruppoPolitico();

                obj.pk_id_gruppo = Convert.ToInt32(new_id_gruppo);

                obj.SendToOpenData("U");


                CGruppoPoliticoPersone objGruppoPoliticoPersone = new CGruppoPoliticoPersone();
                objGruppoPoliticoPersone.pk_id_gruppo = Convert.ToInt32(old_id_gruppo);

                objGruppoPoliticoPersone.SendToOpenData("I");

                objGruppoPoliticoPersone = new CGruppoPoliticoPersone();
                objGruppoPoliticoPersone.pk_id_gruppo = Convert.ToInt32(new_id_gruppo);

                objGruppoPoliticoPersone.SendToOpenData("U");

                Session.Contents.Remove("gruppo_ridenominazione");
                Session.Contents.Remove("gruppo_ridenominato");
            }
            catch (SqlException sqlError)
            {
                tx.Rollback();
                con.Close();

                Session.Contents.Add("error_message", sqlError.Message.ToString());
                Response.Redirect("../errore.aspx");
            }
        }

        Audit.LogInsert(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(old_id_gruppo), "gruppi_politici");
        Response.Redirect("gestisciGruppiPolitici.aspx");
    }

    /// <summary>
    /// Refresh + Log post-delete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void DetailsView1_ItemDeleted(object sender, DetailsViewDeletedEventArgs e)
    {
        Audit.LogDelete(Convert.ToInt32(Session.Contents["user_id"]), Convert.ToInt32(e.Keys[0]), "gruppi_politici");

        Response.Redirect("gestisciGruppiPolitici.aspx");
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcel_Click(object sender, EventArgs e)
    {
        control = "g1";
        formato = "xls";
    }

    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdf_Click(object sender, EventArgs e)
    {
        control = "g1";
        formato = "pdf";
    }

    /// <summary>
    /// Esporta come Excel
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonExcelDetails_Click(object sender, EventArgs e)
    {
        control = "d1";
        formato = "xls";
    }

    /// <summary>
    /// Esporta come PDF
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void LinkButtonPdfDetails_Click(object sender, EventArgs e)
    {
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
            string FileName = "GruppoPolitico";

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
            a_dettaglio.HRef = "dettaglio.aspx?mode=popup";
            a_componenti.HRef = "componenti.aspx?mode=popup";
            a_legislature.HRef = "legislature.aspx?mode=popup";
            a_storia.HRef = "storia.aspx?mode=popup";

            a_back.Visible = false;
        }
        else
        {
            a_dettaglio.HRef = "dettaglio.aspx?mode=normal";
            a_componenti.HRef = "componenti.aspx?mode=normal";
            a_legislature.HRef = "legislature.aspx?mode=normal";
            a_storia.HRef = "storia.aspx?mode=normal";

            a_back.Visible = true;
        }
    }
}