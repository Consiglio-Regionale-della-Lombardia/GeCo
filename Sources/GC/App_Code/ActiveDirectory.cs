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
using System.Collections.Generic;
using System.Linq;

/// <summary>
/// Classe per la gestione login su ActiveDirectory
/// </summary>
public class ActiveDirectory
{

    private static System.Security.Principal.IIdentity _identity = null;

    /// <summary>
    /// Metodo di verifica su parametro di configurazione per login di rete
    /// </summary>
    public static bool IsEnabled
    {
        get
        {
            return (Convert.ToString(System.Configuration.ConfigurationManager.AppSettings["ENABLE_LOGIN_RETE"]).ToLower() == "true");
        }
    }

    /// <summary>
    /// Prorietà gestione utente loggato
    /// </summary>
    public static bool LoggedIn
    {
        get { return (System.Web.HttpContext.Current.Session.Contents["logged_in"] as string) == "1"; }
        set { System.Web.HttpContext.Current.Session.Contents["logged_in"] = value ? "1" : "0"; }
    }

    /// <summary>
    /// Prorietà utente corrente
    /// </summary>
    public static string UserName
    {
        get
        {
            var session = System.Web.HttpContext.Current.Session;
            return session.Contents["user_name"] as string;
        }
    }

    /// <summary>
    /// Metodo inizializzazione Login
    /// Viene impostato utente corrente e legislatura corrente    
    /// </summary>
    /// <param name="identity">identità utente</param>
    public static void CheckLogin(System.Security.Principal.IIdentity identity)
    {
        try
        {
            var req = System.Web.HttpContext.Current.Request;
            if (req.Url.ToString().ToLower().Contains("errore.aspx"))
            {
                //Sono nella pagina di errore, non devo controllare
                return;
            }

            if (IsEnabled)
            {
                _identity = identity;
                var adUser = LoggedUser;

                if (adUser != null && adUser.CurrentProfile != null)
                {
                    Legislatura.setLegislaturaCorrente();
                    LoggedIn = true;
                }
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per reset Login
    /// Vengono resettate le principali variabili di sessione
    /// </summary>
    public static void ResetLogin()
    {
        LoggedUser = null;

        var session = System.Web.HttpContext.Current.Session;
        session.Contents["user_id"] = null;
        session.Contents["user_name"] = null;
        session.Contents["logged_role"] = null;
        session.Contents["logged_organo"] = null;
        session.Contents["logged_organo_name"] = null;
        session.Contents["logged_organo_vis_serv_comm"] = null;
        session.Contents["user_id_role"] = null;
        session.Contents["logged_categoria_organo"] = null;
    }

    /// <summary>
    /// Proprietà utento loggato
    /// </summary>
    public static ActiveDirectoryUser LoggedUser
    {
        get
        {
            if (System.Web.HttpContext.Current.Session.Contents["logged_user_AD"] == null)
            {
                System.Web.HttpContext.Current.Session.Contents["logged_user_AD"] = new ActiveDirectoryUser(_identity);
            }
            return (ActiveDirectoryUser)System.Web.HttpContext.Current.Session.Contents["logged_user_AD"];
        }
        set
        {
            System.Web.HttpContext.Current.Session.Contents["logged_user_AD"] = value;
        }
    }

}

/// <summary>
/// Classe per la gestione dell'utent eloggato su ActiveDirectory
/// </summary>
public class ActiveDirectoryUser
{
    #region COSTANTI

    public const string QUERY_GET_ROLES = @"
        if exists(select nome_ruolo from tbl_ruoli where grado = 1 and rete_gruppo in (@GRUPPO_RETE))
	        begin
		        SELECT   
			        tbl_r.rete_gruppo
			        ,tbl_r.rete_sort
			        ,tbl_r.nome_ruolo
			        ,tbl_r.id_ruolo
			        ,tbl_r.grado
			        ,oo.id_organo
			        ,LTRIM(RTRIM(oo.nome_organo)) AS nome_organo
			        ,oo.vis_serv_comm
			        ,ll.id_legislatura
			        ,ll.num_legislatura
			        ,ll.durata_legislatura_da
                    ,oo.id_categoria_organo
		        FROM tbl_ruoli AS tbl_r
		        LEFT OUTER JOIN organi AS oo
		        ON tbl_r.id_organo = oo.id_organo
		        LEFT OUTER JOIN legislature AS ll
		        ON oo.id_legislatura = ll.id_legislatura		
	        end
        else
	        begin
		        SELECT   
			        tbl_r.rete_gruppo
			        ,tbl_r.rete_sort
			        ,tbl_r.nome_ruolo
			        ,tbl_r.id_ruolo
			        ,tbl_r.grado
			        ,oo.id_organo
			        ,LTRIM(RTRIM(oo.nome_organo)) AS nome_organo
			        ,oo.vis_serv_comm
			        ,ll.id_legislatura
			        ,ll.num_legislatura
			        ,ll.durata_legislatura_da
                    ,oo.id_categoria_organo
		        FROM tbl_ruoli AS tbl_r
		        LEFT OUTER JOIN organi AS oo
		        ON tbl_r.id_organo = oo.id_organo
		        LEFT OUTER JOIN legislature AS ll
		        ON oo.id_legislatura = ll.id_legislatura
		        where 						
		        tbl_r.rete_gruppo in (@GRUPPO_RETE)
	        end";

    #endregion

    public string UserName { get; private set; }
    public List<string> Groups { get; private set; }
    public List<GroupProfile> Profiles { get; private set; }
    public GroupProfile CurrentProfile { get; set; }

    /// <summary>
    /// Proprietà CurrentProfileName (nome ruolo)
    /// </summary>
    public string CurrentProfileName
    {
        get { return (CurrentProfile != null ? CurrentProfile.nome_ruolo : "") ?? ""; }
    }

    /// <summary>
    /// Proprietà CanChangeProfile
    /// </summary>
    public bool CanChangeProfile
    {
        get { return (Profiles != null && Profiles.Count > 1); }
    }

    /// <summary>
    /// Proprietà Lista Profili ordinati
    /// </summary>
    public List<GroupProfile> OrderedProfiles
    {
        get { return Profiles.OrderByDescending(p => p.data_inizio_legislatura).ThenBy(p => p.rete_sort).ToList(); }
    }

    /// <summary>
    /// Costruttore Classe ActiveDirectoryUser
    /// Verifica gruppo di appartenenza
    /// </summary>
    /// <param name="identity">identità utente</param>
    public ActiveDirectoryUser(System.Security.Principal.IIdentity identity)
    {
        try
        {

            if (identity.IsAuthenticated)
                UserName = identity.Name;

            Groups = System.Web.HttpContext.Current.Request.LogonUserIdentity.Groups
                .Select(p => p.Translate(typeof(System.Security.Principal.NTAccount)).ToString()).ToList();

            if (Groups == null || Groups.Count == 0)
                throw new Exception("L'utente '" + (UserName ?? "NULL") + "' non appartiene a nessun gruppo di accesso");

            LoadProfiles();

            SelectDefaultProfile();
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per selezione Profilo
    /// Viene preso il primo della lista
    /// </summary>
    public void SelectDefaultProfile()
    {
        if (Profiles == null || Profiles.Count == 0)
            throw new Exception("L'utente non appartiene a nessun gruppo di accesso");

        var defProfile = OrderedProfiles.First();
        SelectProfile(defProfile);
    }

    /// <summary>
    /// Metodo per estrarre un profilo dalla lista in base a indice di posizione
    /// </summary>
    /// <param name="position">posiszione nella lista</param>
    public void SelectProfileAtPosition(int position)
    {
        var profile = OrderedProfiles.ElementAt(position);
        SelectProfile(profile);
    }

    /// <summary>
    /// Metodo di inizializzazione Profilo
    /// Vengono valorizzate le principali variabili di Sessione
    /// </summary>
    /// <param name="profile">profilo utente</param>
    public void SelectProfile(GroupProfile profile)
    {
        try
        {
            CurrentProfile = profile;

            var session = System.Web.HttpContext.Current.Session;
            session.Contents["user_id"] = 0; //In questo non ho userId
            session.Contents["user_name"] = UserName;
            session.Contents["logged_role"] = CurrentProfile.grado.ToString();
            session.Contents["logged_organo"] = (CurrentProfile.id_organo.HasValue ? CurrentProfile.id_organo.Value.ToString() : "");
            session.Contents["logged_organo_name"] = CurrentProfile.nome_organo;
            session.Contents["logged_organo_vis_serv_comm"] = CurrentProfile.vis_serv_comm.ToString();
            session.Contents["user_id_role"] = CurrentProfile.id_ruolo;
            session.Contents["logged_categoria_organo"] = CurrentProfile.id_categoria_organo;

            session.ClearFilters();

            ActiveDirectory.LoggedIn = true;
        }
        catch (Exception ex)
        {
            throw new Exception("Impossibile passare al profilo selezionato: " + ex.Message, ex);
        }
    }

    /// <summary>
    /// Metodo per il caricamento dei profili utente
    /// </summary>
    private void LoadProfiles()
    {
        Profiles = new List<GroupProfile>();

        try
        {
            if (Groups == null || Groups.Count == 0)
                throw new Exception("L'utente non appartiene a nessun gruppo di accesso");

            var whereGroups = string.Join(",", Groups.Select(p => "'" + p.Replace("'", "''") + "'").ToArray());

            string query_info = QUERY_GET_ROLES.Replace("@GRUPPO_RETE", whereGroups);

            var rows = Utility.GetDataRows(query_info);

            if (rows != null && rows.Count > 0)
            {
                foreach (var row in rows)
                {
                    var profile = new GroupProfile();

                    profile.rete_gruppo = row[0].ToString();
                    profile.rete_sort = int.MaxValue;
                    if (row[1] != DBNull.Value)
                        profile.rete_sort = int.Parse(row[1].ToString());

                    profile.nome_ruolo = row[2].ToString();
                    profile.id_ruolo = int.Parse(row[3].ToString());
                    profile.grado = int.Parse(row[4].ToString());
                    profile.id_organo = (row[5] != DBNull.Value ? int.Parse(row[5].ToString()) : (int?)null);
                    profile.nome_organo = row[6].ToString();
                    profile.vis_serv_comm = (row[7] != DBNull.Value ? bool.Parse(row[7].ToString()) : false);
                    profile.id_legislatura = (row[8] != DBNull.Value ? int.Parse(row[8].ToString()) : (int?)null);
                    profile.num_legislatura = row[9].ToString();

                    profile.data_inizio_legislatura = DateTime.MaxValue;
                    if (row[10] != DBNull.Value)
                        profile.data_inizio_legislatura = DateTime.Parse(row[10].ToString());

                    profile.id_categoria_organo = (row[11] != DBNull.Value ? int.Parse(row[11].ToString()) : (int?)null);

                    Profiles.Add(profile);
                }
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

/// <summary>
/// Classe per gestione Profili Utente
/// </summary>
public class GroupProfile
{
    public string rete_gruppo { get; set; }
    public int rete_sort { get; set; }
    public string nome_ruolo { get; set; }
    public int id_ruolo { get; set; }
    public int grado { get; set; }
    public int? id_organo { get; set; }
    public string nome_organo { get; set; }
    public bool vis_serv_comm { get; set; }
    public int? id_legislatura { get; set; }
    public string num_legislatura { get; set; }
    public DateTime data_inizio_legislatura { get; set; }
    public int? id_categoria_organo { get; set; }
}