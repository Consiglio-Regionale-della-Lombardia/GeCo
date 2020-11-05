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
/// Classe per la gestione Carica Persona
/// </summary>

public class CCaricaPersona
{
    public int pk_id_rec;
    /// <summary>
    /// Costruttore CCaricaPersona
    /// </summary>
    public CCaricaPersona()
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

            string p_id_rec = Convert.ToString(pk_id_rec);

            p = new WSParameter();
            p.value = p_id_rec;
            ws.parametri.Add(p);

            if (azione != "D")
            {

                string query = "select b.id_rec, " +
                               "       d.num_legislatura, " +
                               "       b.id_carica, " +
                               "       c.nome_carica, " +
                               "       c.ordine, " +
                               "       b.id_organo, " +
                               "       e.nome_organo, " +
                               "       a.id_persona id_consigliere, " +
                               "       a.cognome, " +
                               "       a.nome, " +
                               "       b.data_inizio data_inizio_carica, " +
                               "       b.data_fine data_fine_carica, " +
                               "       f.descrizione_causa, " +
                               "       e.comitato_ristretto " + //2019-10-22 Aggiunto campo comitato_ristretto per check
                               "from persona a " +
                               "     inner join join_persona_organo_carica b on a.id_persona = b.id_persona " +
                               "     inner join cariche c on b.id_carica = c.id_carica " +
                               "     inner join legislature d on b.id_legislatura = d.id_legislatura " +
                               "     inner join organi e on b.id_organo = e.id_organo " +
                               "     left outer join tbl_cause_fine f on b.id_causa_fine = f.id_causa " +
                               "where b.id_rec = @id_rec";


                string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

                SqlConnection conn = new SqlConnection(conn_string);
                SqlCommand cmd = new SqlCommand(query);
                cmd.Connection = conn;

                SqlParameter prm = new SqlParameter("@id_rec", pk_id_rec);
                cmd.Parameters.Add(prm);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                string p_legislatura = "";
                string p_id_carica = "";
                string p_nome_carica = "";
                string p_ordine = "";
                string p_id_organo = "";
                string p_nome_organo = "";
                string p_id_consigliere = "";
                string p_cognome = "";
                string p_nome = "";
                string p_data_inizio_carica = "";
                string p_data_fine_carica = "";
                string p_descrizione_causa = "";

                if (reader.HasRows)
                {
                    reader.Read();

                    //2019-10-22 Modifica: escludere comitati ristretti (comitato_ristretto = true)
                    var p_comitato_ristretto = reader["comitato_ristretto"].ToString();
                    bool comitato_ristretto = false;
                    bool isRistretto = !string.IsNullOrWhiteSpace(p_comitato_ristretto)
                        && bool.TryParse(p_comitato_ristretto, out comitato_ristretto)
                        && comitato_ristretto;
                    if (isRistretto)
                    {
                        //Esci senza inviare dati
                        return;
                    }

                    p_legislatura = reader["num_legislatura"].ToString();
                    p_id_carica = reader["id_carica"].ToString();
                    p_nome_carica = reader["nome_carica"].ToString();
                    p_ordine = reader["ordine"].ToString();
                    p_id_organo = reader["id_organo"].ToString();
                    p_nome_organo = reader["nome_organo"].ToString();
                    p_id_consigliere = reader["id_consigliere"].ToString();
                    p_cognome = reader["cognome"].ToString();
                    p_nome = reader["nome"].ToString();
                    p_data_inizio_carica = ws.get_data_format(reader["data_inizio_carica"]);
                    p_data_fine_carica = ws.get_data_format(reader["data_fine_carica"]);
                    p_descrizione_causa = reader["descrizione_causa"].ToString();
                }

                reader.Close();
                conn.Close();
                conn.Dispose();

                p = new WSParameter();
                p.value = p_legislatura;
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
                p.value = p_id_carica;
                ws.parametri.Add(p);


                p = new WSParameter();
                p.value = p_nome_carica;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_ordine;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_id_organo;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_nome_organo;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_inizio_carica;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_fine_carica;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_descrizione_causa;
                ws.parametri.Add(p);

                ws.UpsertCARICA();
            }
            else
                ws.DeleteCARICA();
        }
    }
}