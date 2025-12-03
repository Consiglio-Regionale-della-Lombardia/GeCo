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
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Default
/// </summary>
public partial class _Default : System.Web.UI.Page
{
    string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;


    string login_err_msg = "LOGIN FALLITA: Utente non riconosciuto.";


    string query_info_login = @"SELECT uu.id_utente 
                                      ,uu.nome_utente 
                                      ,tr.grado 
                                      ,oo.id_organo
                                      ,LTRIM(RTRIM(oo.nome_organo)) AS nome_organo
                                      ,oo.vis_serv_comm
                                      ,uu.id_ruolo
                                FROM utenti AS uu 
                                INNER JOIN tbl_ruoli AS tr 
                                   ON uu.id_ruolo = tr.id_ruolo
                                LEFT OUTER JOIN organi AS oo
                                   ON tr.id_organo = oo.id_organo
                                LEFT OUTER JOIN legislature AS ll
                                   ON oo.id_legislatura = ll.id_legislatura
                                WHERE uu.attivo = 1
                                   AND LOWER(uu.nome_utente) = '@username'
                                   AND uu.pwd = '@password'
                                ORDER BY ll.durata_legislatura_da DESC";

	/// <summary>
	/// Evento per il caricamento della pagina - Inizializzazione dati e verifica login
	/// </summary>
	/// <param name="sender">Oggetto che ha generato l'evento</param>
	/// <param name="e">Argomenti</param>

	//protected void Page_Load(object sender, EventArgs e)
	//{
	//    string loggedout = Request.QueryString["logout"];
	//
	//    if (loggedout != null)
	//    {
	//        Session.Contents.RemoveAll();
	//    }
	//
	//    string loggedin = Convert.ToString(Session.Contents["logged_in"]);
	//
	//    if (loggedin == null)
	//    {
	//        loggedin = "0";
	//    }
	//
	//    // Già loggato? Redirect alla prima pagina
	//    if (loggedin.Equals("1"))
	//    {
	//        Response.Redirect("~/persona/persona.aspx");
	//    }
	//    else
	//    {
	//        if (!ActiveDirectory.IsEnabled)
	//            Login1.Focus();
	//    }
	//}




	protected void Page_Load(object sender, EventArgs e)
	{
		// 1) SSO: mi assicuro di avere un AuthUser
		AuthUser user = AuthHelper.EnsureAuthenticated();
		if (user == null)
		{
			// EnsureAuthenticated ha fatto un Redirect → non proseguo
			return;
		}

		// 2) Gestione eventuale logout legacy
		string loggedout = Request.QueryString["logout"];
		if (loggedout != null)
		{
			Session.Contents.RemoveAll();
		}

		// 3) Stato login legacy
		string loggedin = Convert.ToString(Session.Contents["logged_in"]);
		if (loggedin == null)
		{
			loggedin = "0";
		}

		// 4) Se NON ancora loggato nella logica legacy,
		//    provo a fare login usando l'utente SSO
		if (!loggedin.Equals("1"))
		{
			EnsureLegacyLoginFromSso(user);

			loggedin = Convert.ToString(Session.Contents["logged_in"]);
			if (loggedin == null)
			{
				loggedin = "0";
			}
		}

		// 5) Se ora siamo loggati → redirect alla pagina iniziale dell'app
		if (loggedin.Equals("1"))
		{
			Response.Redirect("~/persona/persona.aspx");
			return;
		}
		else
		{
			// Solo se tieni ancora il vecchio form di login locale
			// (ActiveDirectory.IsEnabled come nel codice precedente)
			if (!ActiveDirectory.IsEnabled)
			{
				Login1.Focus();
			}
		}
	}

	/// <summary>
	/// Effettua il "login legacy" usando solo l'utente SSO (AuthUser),
	/// senza password: legge la riga in tabella "utenti" e popola la Session.
	/// </summary>
	/// <param name="user">Utente autenticato via SSO (AuthUser)</param>
	private void EnsureLegacyLoginFromSso(AuthUser user)
	{
		if (user == null)
			return;

		string username = user.Username;
		if (string.IsNullOrEmpty(username))
			return;

		// Se dall'SSO arriva "nome.cognome@dominio", qui puoi fare il mapping
		// a "nome.cognome" se è questo che hai in uu.nome_utente
		username = username.ToLower();

		SqlConnection conn = null;
		SqlDataReader reader = null;

		try
		{
			conn = new SqlConnection(conn_string);
			conn.Open();

			// Query simile alla vecchia query_info_login, ma SENZA password
			string query_info = @"
                SELECT  uu.id_utente,
                        uu.nome_utente,
                        tr.grado,
                        oo.id_organo,
                        LTRIM(RTRIM(oo.nome_organo)) AS nome_organo,
                        oo.vis_serv_comm,
                        uu.id_ruolo
                FROM utenti AS uu 
                INNER JOIN tbl_ruoli AS tr 
                    ON uu.id_ruolo = tr.id_ruolo
                LEFT OUTER JOIN organi AS oo
                    ON tr.id_organo = oo.id_organo
                LEFT OUTER JOIN legislature AS ll
                    ON oo.id_legislatura = ll.id_legislatura
                WHERE uu.attivo = 1
                  AND LOWER(uu.nome_utente) = @username
                ORDER BY ll.durata_legislatura_da DESC";

			SqlCommand cmd = new SqlCommand(query_info, conn);
			cmd.Parameters.AddWithValue("@username", username);

			reader = cmd.ExecuteReader();

			if (reader.HasRows)
			{
				if (reader.Read())
				{
					// Popolo la Session come faceva il vecchio executeLoginForm
					Session.Contents["user_id"] = reader[0].ToString();                   // uu.id_utente
					Session.Contents["logged_in"] = "1";
					Session.Contents["logged_role"] = reader[2].ToString();               // tr.grado
					Session.Contents["logged_organo"] = reader[3].ToString();             // oo.id_organo
					Session.Contents["logged_organo_name"] = reader[4].ToString();        // nome_organo
					Session.Contents["logged_organo_vis_serv_comm"] = reader[5].ToString(); // oo.vis_serv_comm
					Session.Contents["user_id_role"] = reader[6].ToString();              // uu.id_ruolo

					// Inizializza la legislatura come prima
					Legislatura.setLegislaturaCorrente();
				}
			}
			else
			{
				// Utente SSO non trovato in tabella "utenti"
				// Qui puoi gestire caso speciale: log, pagina di errore, ecc.
				// Page_Error_Custom(login_err_msg, "center");
			}
		}
		finally
		{
			if (reader != null)
			{
				reader.Close();
			}

			if (conn != null)
			{
				conn.Close();
				conn.Dispose();
			}
		}
	}







	/// <summary>
	/// Metodo per la gestione della pagina di errore
	/// </summary>
	/// <param name="sender">Oggetto che ha generato l'evento</param>
	/// <param name="e">Argomenti</param>

	protected void Page_Error(object sender, EventArgs e)
    {
        Session.Contents.Add("error_message", Server.GetLastError().Message);
        Response.Redirect("~/errore.aspx");
    }

    /// <summary>
    /// Metodo per la gestione della pagina Custom di errore
    /// </summary>
    /// <param name="p_err_msg">messaggio di errore</param>
    /// <param name="p_alignment">allineamento</param>
    protected void Page_Error_Custom(string p_err_msg, string p_alignment)
    {
        Session.Contents.Add("align", p_alignment);
        Session.Contents.Add("error_message", p_err_msg);
        Response.Redirect("~/errore.aspx");
    }

    /// <summary>
    /// Metodo per autenticazione
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void executeLoginForm(object sender, AuthenticateEventArgs e)
    {
        bool loggedin = false;

        string username = Login1.UserName.ToLower();
        string password = Utility.getMd5Hash(Login1.Password);

        SqlConnection conn = null;
        SqlDataReader reader = null;

        try
        {
            conn = new SqlConnection(conn_string);
            conn.Open();

            string query_info = query_info_login;

            query_info = query_info.Replace("@username", username);
            query_info = query_info.Replace("@password", password);

            SqlCommand cmd = new SqlCommand(query_info, conn);

            reader = cmd.ExecuteReader();

            if (reader.HasRows)
            {
                loggedin = true;

                while (reader.Read())
                {
                    Session.Contents.Add("user_id", reader[0].ToString());
                    Session.Contents.Add("logged_in", "1");
                    Session.Contents.Add("logged_role", reader[2].ToString());
                    Session.Contents.Add("logged_organo", reader[3].ToString());
                    Session.Contents.Add("logged_organo_name", reader[4].ToString());
                    Session.Contents.Add("logged_organo_vis_serv_comm", reader[5].ToString());
                    Session.Contents.Add("user_id_role", reader[6].ToString());

                    /*
                        logged_role = tbl_ruoli.grado
                        user_id_role = tbl_ruoli.id_ruolo
                    */

                    break;
                }

                //setLegislaturaCorrente();
                Legislatura.setLegislaturaCorrente();
            }
        }
        finally
        {
            if (reader != null)
            {
                reader.Close();
            }

            if (conn != null)
            {
                conn.Close();
                conn.Dispose();
            }
        }

        e.Authenticated = loggedin;
    }

}