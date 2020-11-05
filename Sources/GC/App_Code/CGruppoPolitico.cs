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
/// Classe per la gestione Gruppo Politico
/// </summary>

public class CGruppoPolitico
{
    public int pk_id_gruppo;
    /// <summary>
    /// Costruttore CGruppoPolitico
    /// </summary>
    public CGruppoPolitico()
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

            string p_id_gruppo = Convert.ToString(pk_id_gruppo);

            p = new WSParameter();
            p.value = p_id_gruppo;
            ws.parametri.Add(p);

            if (azione != "D")
            {
                string query = "select c.num_legislatura, " +
                               "       a.codice_gruppo, " +
                               "       a.nome_gruppo,  " +
                               "       a.data_inizio,  " +
                               "       a.data_fine,  " +
                               "       d.descrizione_causa  " +
                               "from gruppi_politici a " +
                               "     inner join join_gruppi_politici_legislature b on a.id_gruppo = b.id_gruppo " +
                               "     inner join legislature c on b.id_legislatura = c.id_legislatura " +
                               "     left outer join tbl_cause_fine d on a.id_causa_fine = d.id_causa " +
                               "     where a.id_gruppo = @id_gruppo";

                string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

                SqlConnection conn = new SqlConnection(conn_string);
                SqlCommand cmd = new SqlCommand(query);
                cmd.Connection = conn;

                SqlParameter prm = new SqlParameter("@id_gruppo", pk_id_gruppo);
                cmd.Parameters.Add(prm);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                string p_codice_gruppo = "";
                string p_nome_gruppo = "";
                string p_data_inizio = "";
                string p_data_fine = "";
                string p_motivo_fine = "";

                string p_legislatura = ""; ;

                if (reader.HasRows)
                {
                    reader.Read();

                    p_legislatura = reader["num_legislatura"].ToString();
                    p_codice_gruppo = reader["codice_gruppo"].ToString();
                    p_nome_gruppo = reader["nome_gruppo"].ToString();
                    p_data_inizio = ws.get_data_format(reader["data_inizio"]);
                    p_data_fine = ws.get_data_format(reader["data_fine"]);
                    p_motivo_fine = reader["descrizione_causa"].ToString();
                }

                reader.Close();
                conn.Close();
                conn.Dispose();

                p = new WSParameter();
                p.value = p_legislatura;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_codice_gruppo;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_nome_gruppo;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_inizio;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_fine;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_motivo_fine;
                ws.parametri.Add(p);

                ws.UpsertGRUPPO();
            }
            else
                ws.DeleteGRUPPO();


        }
    }

}