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

/// <summary>
/// Classe per la gestione Gruppo Politico Persone
/// /// </summary>

public class CGruppoPoliticoPersone
{
    public int pk_id_gruppo;

    /// <summary>
    /// Costruttore CGruppoPoliticoPersone
    /// </summary>
    public CGruppoPoliticoPersone()
    {
    }

    /// <summary>
    /// Metodo per invio dati a OpenData
    /// </summary>
    /// <param name="azione">Azione da eseguire(Upsert, Delete)</param>
    public void SendToOpenData(string azione)
    {
        if (Convert.ToString(System.Configuration.ConfigurationManager.AppSettings["ENABLE_SEND_OPEN_DATA"]).ToLower() == "true")
        {

            WSOpenData ws = new WSOpenData();

            WSParameter p = new WSParameter();

            string query = "select b.id_rec, " +
               "       e.num_legislatura, " +
               "       d.id_carica, " +
               "       d.nome_carica, " +
               "       d.ordine, " +
               "       b.id_gruppo, " +
               "       c.nome_gruppo, " +
               "       a.id_persona id_consigliere, " +
               "       a.cognome, " +
               "       a.nome, " +
               "       b.data_inizio data_inizio_carica, " +
               "       b.data_fine data_fine_carica " +
               "from persona a " +
               "     inner join join_persona_gruppi_politici b on a.id_persona = b.id_persona " +
               "     inner join gruppi_politici c on b.id_gruppo = c.id_gruppo " +
               "     inner join cariche d on b.id_carica = d.id_carica " +
               "     inner join legislature e on b.id_legislatura = e.id_legislatura " +
               "where b.id_gruppo = @id_gruppo";


            string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

            SqlConnection conn = new SqlConnection(conn_string);
            SqlCommand cmd = new SqlCommand(query);
            cmd.Connection = conn;

            SqlParameter prm = new SqlParameter("@id_gruppo", pk_id_gruppo);
            cmd.Parameters.Add(prm);

            conn.Open();

            SqlDataReader reader = cmd.ExecuteReader();

            string p_id_rec = "";

            if (azione != "D")
            {

                string p_legislatura = "";
                string p_id_carica = "";
                string p_nome_carica = "";
                string p_ordine = "";
                string p_id_gruppo = "";
                string p_nome_gruppo = "";
                string p_id_consigliere = "";
                string p_cognome = "";
                string p_nome = "";
                string p_data_inizio_carica = "";
                string p_data_fine_carica = "";

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        p_id_rec = reader["id_rec"].ToString();
                        p_legislatura = reader["num_legislatura"].ToString();
                        p_id_carica = reader["id_carica"].ToString();
                        p_nome_carica = reader["nome_carica"].ToString();
                        p_ordine = reader["ordine"].ToString();
                        p_id_gruppo = reader["id_gruppo"].ToString();
                        p_nome_gruppo = reader["nome_gruppo"].ToString();
                        p_id_consigliere = reader["id_consigliere"].ToString();
                        p_cognome = reader["cognome"].ToString();
                        p_nome = reader["nome"].ToString();
                        p_data_inizio_carica = ws.get_data_format(reader["data_inizio_carica"]);
                        p_data_fine_carica = ws.get_data_format(reader["data_fine_carica"]);

                        p = new WSParameter();
                        p.value = p_id_rec;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_legislatura;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_id_carica;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_nome_carica;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_ordine;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_id_gruppo;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_nome_gruppo;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_id_consigliere;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_cognome;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_nome;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_data_inizio_carica;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = p_data_fine_carica;
                        ws.parametri.Add(p);

                        p = new WSParameter();
                        p.value = ws.SEPARATORE_RECORD;
                        ws.parametri.Add(p);

                    }
                    ws.UpsertCOMPOSIZIONE_GRUPPO();
                }
            }
            else
            {
                while (reader.Read())
                {
                    p_id_rec = reader["id_rec"].ToString();

                    p = new WSParameter();
                    p.value = p_id_rec;
                    ws.parametri.Add(p);

                    p = new WSParameter();
                    p.value = ws.SEPARATORE_RECORD;
                    ws.parametri.Add(p);
                }

                ws.DeleteCOMPOSIZIONE_GRUPPO();
            }

            reader.Close();
            conn.Close();
            conn.Dispose();
        }
    }
}