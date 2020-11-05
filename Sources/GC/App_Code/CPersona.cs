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
using System.Web;

/// <summary>
/// Classe per la gestione Persona
/// /// </summary>


public class CPersona
{
    public int pk_id_persona;
    public int id_legislatura;

    /// <summary>
    /// Costruttore CPersona
    /// </summary>
    public CPersona()
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



            string p_id_persona = Convert.ToString(pk_id_persona);

            p = new WSParameter();
            p.value = p_id_persona;
            ws.parametri.Add(p);

            if (azione != "D")
            {

                string query = "select a.id_persona, " +
                                       "a.nome, " +
                                       "a.cognome, " +
                                       "b.comune, " +
                                       "b.provincia, " +
                                       "a.data_nascita,  " +
                                       "a.sesso, " +
                                       "dbo.get_legislature_from_persona(a.id_persona) legislature " +
                               "from persona a " +
                               "     inner join tbl_comuni b on a.id_comune_nascita = b.id_comune " +
                               "where a.id_persona = @id_persona";

                string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

                SqlConnection conn = new SqlConnection(conn_string);
                SqlCommand cmd = new SqlCommand(query);
                cmd.Connection = conn;

                SqlParameter prm = new SqlParameter("@id_persona", pk_id_persona);
                cmd.Parameters.Add(prm);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                string p_nome = "";
                string p_cognome = "";
                string p_luogo_nascita = "";
                string p_provincia_nascita = "";
                string p_data_nascita = "";
                string p_sesso = "";

                string p_legislatura = ""; ;

                if (reader.HasRows)
                {
                    reader.Read();

                    p_nome = reader["nome"].ToString();
                    p_cognome = reader["cognome"].ToString();
                    p_luogo_nascita = reader["comune"].ToString();
                    p_provincia_nascita = reader["provincia"].ToString();
                    p_data_nascita = ws.get_data_format(reader["data_nascita"]);
                    p_sesso = reader["sesso"].ToString();
                    p_legislatura = reader["legislature"].ToString();
                }

                reader.Close();
                conn.Close();
                conn.Dispose();

                p = new WSParameter();
                p.value = p_cognome;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_nome;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_data_nascita;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_luogo_nascita;
                ws.parametri.Add(p);


                p = new WSParameter();
                p.value = p_provincia_nascita;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_sesso;
                ws.parametri.Add(p);

                p = new WSParameter();
                p.value = p_legislatura;
                ws.parametri.Add(p);

                //2019-04 Gabriele
                //Nuovo parametro "non eletto"
                var nonConsigliere = checkIsNonConsigliere(pk_id_persona);
                p = new WSParameter();
                p.value = nonConsigliere ? "SI" : string.Empty;
                ws.parametri.Add(p);

                ws.UpsertCONS();
            }
            else
                ws.DeleteCONS();
        }
    }


    /// <summary>
    /// Metodo verifica se Persona è un Consigliere
    /// </summary>
    /// <param name="idPersona">identificativo persona</param>
    /// <returns>booleano</returns>
    private bool checkIsNonConsigliere(int idPersona)
    {
        try
        {
            bool result = false;

            var legislatura_corrente = Convert.ToString(HttpContext.Current.Session.Contents["id_legislatura"]);

            string query = @"SELECT jpoc.id_carica
                            FROM persona AS pp
                            INNER JOIN join_persona_organo_carica AS jpoc
                            ON pp.id_persona = jpoc.id_persona
                            INNER JOIN legislature AS ll
                            ON jpoc.id_legislatura = ll.id_legislatura
                            INNER JOIN organi AS oo
                            ON jpoc.id_organo = oo.id_organo
                            INNER JOIN cariche AS cc
                            ON jpoc.id_carica = cc.id_carica
                            WHERE pp.deleted = 0
                            AND jpoc.deleted = 0
                            AND oo.deleted = 0
                            AND(
                                (cc.id_tipo_carica = 3 -- 'assessore non consigliere' 
                                 AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                                )
                            )
                            AND ll.id_legislatura = @id_legislatura
                            AND pp.id_persona = @id_persona";

            string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

            SqlConnection conn = new SqlConnection(conn_string);
            SqlCommand cmd = new SqlCommand(query);
            cmd.Connection = conn;

            cmd.Parameters.Add(new SqlParameter("@id_persona", idPersona));
            cmd.Parameters.Add(new SqlParameter("@id_legislatura", legislatura_corrente));

            conn.Open();

            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.HasRows)
                result = true;

            return result;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


}