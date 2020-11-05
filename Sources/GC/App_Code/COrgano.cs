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
/// Classe per la gestione Organo
/// /// </summary>

public class COrgano
{
    public int pk_id_organo;

    /// <summary>
    /// Costruttore COrgano
    /// </summary>
    public COrgano()
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

            string p_id_organo = Convert.ToString(pk_id_organo);

            p = new WSParameter();
            p.value = p_id_organo;
            ws.parametri.Add(p);

            if (azione != "D")
            {
                string query = "select b.num_legislatura, " +
                               "       a.nome_organo, " +
                               "       a.data_inizio, " +
                               "       a.data_fine, " +
                               "       a.id_tipo_organo " +
                               "from organi a " +
                               "     inner join legislature b on a.id_legislatura = b.id_legislatura " +
                               "     where a.id_organo = @id_organo";

                string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

                SqlConnection conn = new SqlConnection(conn_string);
                SqlCommand cmd = new SqlCommand(query);
                cmd.Connection = conn;

                SqlParameter prm = new SqlParameter("@id_organo", pk_id_organo);
                cmd.Parameters.Add(prm);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                string p_nome_organo = "";
                string p_data_inizio = "";
                string p_data_fine = "";
                string p_id_tipo_organo = "";
                string p_legislatura = "";


                if (reader.HasRows)
                {
                    reader.Read();

                    p_nome_organo = reader["nome_organo"].ToString();
                    p_data_inizio = ws.get_data_format(reader["data_inizio"]);
                    p_data_fine = ws.get_data_format(reader["data_fine"]);
                    p_id_tipo_organo = reader["id_tipo_organo"].ToString();
                    p_legislatura = reader["num_legislatura"].ToString();
                }

                reader.Close();
                conn.Close();
                conn.Dispose();

                p = new WSParameter();
                p.value = p_legislatura;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_nome_organo;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_inizio;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_fine;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_id_tipo_organo;
                ws.parametri.Add(p);

                ws.UpsertORGANO();
            }
            else
                ws.DeleteORGANO();

        }
    }
}