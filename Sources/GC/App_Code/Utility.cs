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
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Utility
/// </summary>
public class Utility
{
    /// <summary>
    /// Hash an input string and return the hash as a 32 character hexadecimal string.
    /// </summary>
    /// <param name="input">stringa di input</param>
    /// <returns>Stringa HASH</returns>

    public static string getMd5Hash(string input)
    {
        // Create a new instance of the MD5CryptoServiceProvider object.
        MD5CryptoServiceProvider md5Hasher = new MD5CryptoServiceProvider();

        // Convert the input string to a byte array and compute the hash.
        byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(input));

        // Create a new Stringbuilder to collect the bytes
        // and create a string.
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string.
        return sBuilder.ToString();
    }

    /// <summary>
    /// Verify a hash against a string.
    /// </summary>
    /// <param name="input">stringa di input</param>
    /// <param name="hash">contenuto hash</param>
    /// <returns>booleano</returns>
    public static bool verifyMd5Hash(string input, string hash)
    {
        // Hash the input.
        string hashOfInput = getMd5Hash(input);

        // Create a StringComparer an comare the hashes.
        StringComparer comparer = StringComparer.OrdinalIgnoreCase;

        if (0 == comparer.Compare(hashOfInput, hash))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /// <summary>
    /// Ottiene Nome Persona a partire dall'id persona
    /// </summary>
    /// <param name="id_persona">identificativo persona</param>
    /// <returns>nome persona</returns>
    public static string getNomePersonaFromID(int id_persona)
    {
        string nome_completo = "";

        if (id_persona > 0)
        {
            string query = @"SELECT pp.nome + ' ' + pp.cognome AS nome_completo 
                             FROM persona AS pp
                             WHERE pp.deleted = 0 AND pp.chiuso = 0 
                               AND pp.id_persona = " + id_persona;

            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();

            SqlCommand cmd = new SqlCommand(query, conn);

            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                nome_completo = reader[0].ToString();
                break;
            }
        }

        return nome_completo;
    }

    /// <summary>
    /// Metodo per aggiungere un elemento vuoto ad una lista
    /// </summary>
    /// <param name="ddl">DropDownList di riferimento</param>
    public static void AddEmptyItem(DropDownList ddl)
    {
        System.Web.UI.WebControls.ListItem li = new System.Web.UI.WebControls.ListItem("(seleziona)", "");
        ddl.Items.Insert(0, li);
    }


    /// <summary>
    /// Metodo per generazione stringa id di una griglia
    /// </summary>
    /// <param name="GridView1">Griglia di input</param>
    /// <returns>stringa id riga</returns>
    public static string getAllRowIds(GridView GridView1)
    {
        string keys = "";

        for (int i = 0; i < GridView1.DataKeys.Count; i++)
        {
            keys += GridView1.DataKeys[i].Value.ToString() + ",";
        }

        if (keys.Length > 0)
        {
            keys = keys.Substring(0, keys.Length - 1);
        }

        return keys;
    }

    /// <summary>
    /// Metodo per Strip HTML
    /// </summary>
    /// <param name="inputString">stringa di input</param>
    /// <returns>stringa manipolata</returns>
    public static string StripHTML(string inputString)
    {
        return Regex.Replace(inputString, "<.*?>", string.Empty);
    }

    /// <summary>
    /// Metodo per generazione DataRows da query
    /// </summary>
    /// <param name="Query">query di riferimento</param>
    /// <returns>lista di righe</returns>
    public static List<DataRow> GetDataRows(string Query)
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();
        command.Connection = con;
        command.Connection.Open();
        command.CommandText = Query;

        DataTable dataTable = new DataTable();

        SqlDataAdapter adp = new SqlDataAdapter(command);
        adp.Fill(dataTable);

        command.Dispose();

        adp.Dispose();
        con.Close();
        con.Dispose();

        return dataTable.Rows.OfType<DataRow>().ToList();
    }

    /// <summary>
    /// Metodo per generazione DataTable da query
    /// </summary>
    /// <param name="Query">query di riferimento</param>
    /// <returns>DataTable</returns>
    public static DataTable GetTable(string Query,
        CommandType commandType = CommandType.Text,
        Dictionary<string, object> param = null)
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();
        command.Connection = con;
        command.Connection.Open();
        command.CommandText = Query;
        command.CommandType = commandType;

        if (param != null && param.Count > 0)
        {
            foreach (var p in param)
            {
                command.Parameters.AddWithValue(p.Key.StartsWith("@") ? p.Key : "@" + p.Key, p.Value);
            }
        }

        DataTable dataTable = new DataTable();

        SqlDataAdapter adp = new SqlDataAdapter(command);
        adp.Fill(dataTable);

        SqlDataReader Recordset = command.ExecuteReader();
        command.Dispose();

        adp.Dispose();
        con.Close();
        con.Dispose();

        return dataTable;
    }

    /// <summary>
    /// Metodo per recuperare un singolo valore dal database
    /// </summary>
    /// <typeparam name="T">Tipo del valore restituito</typeparam>
    /// <param name="Query">Query da eseguire</param>
    /// <param name="commandType">Tipo di query (testo o stored procedure)</param>
    /// <param name="param">Parametri da passare alla query (null o vuoto se la query non ha parametri)</param>
    /// <returns>Valore restituito: il primo campo della prima riga della tabella risultante dalla query</returns>
    public static T GetValueFromDb<T>(string Query,
        CommandType commandType = CommandType.Text,
        Dictionary<string, object> param = null)
    {
        T result = default(T);

        var table = GetTable(Query, commandType, param);
        if (table != null && table.Rows.Count > 0)
        {
            result = table.Rows[0].Field<T>(0);
        }

        return result;
    }


    /// <summary>
    /// Metodo per esecuzione query su database
    /// </summary>
    /// <param name="Query">Query da eseguire</param>
    /// <param name="commandType">Tipo di query (testo o stored procedure)</param>
    /// <param name="param">Parametri da passare alla query (null o vuoto se la query non ha parametri)</param>
    /// <returns>DataTableReader per i risultati della query</returns>
    public static DataTableReader ExecuteQuery(
        string Query,
        CommandType commandType = CommandType.Text,
        Dictionary<string, object> param = null)
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();
        command.Connection = con;
        command.Connection.Open();
        command.CommandText = Query;
        command.CommandType = commandType;

        if (param != null && param.Count > 0)
        {
            foreach (var p in param)
            {
                command.Parameters.AddWithValue(p.Key.StartsWith("@") ? p.Key : "@" + p.Key, p.Value);
            }
        }

        SqlDataReader Recordset = command.ExecuteReader();
        command.Dispose();

        DataTable dataTable = new DataTable();

        Adapter dar = new Adapter();
        dar.FillFromReader(dataTable, Recordset);
        dar.Dispose();
        con.Close();
        con.Dispose();

        DataTableReader Recordset_finale = dataTable.CreateDataReader();
        dataTable.Dispose();
        Recordset.Dispose();

        return Recordset_finale;
    }

    /// <summary>
    /// Metodo per generazione SqlDataReader da query e sessione
    /// </summary>
    /// <param name="Query">query di riferimento</param>
    /// <param name="sessione">sessione di riferimento</param>
    /// <returns>SqlDataReader</returns>
    public static SqlDataReader ExecuteQuery2(string Query, System.Web.SessionState.HttpSessionState sessione)
    {
        SqlCommand cmd = new SqlCommand(Query, (SqlConnection)sessione.Contents["DBConnection"]);
        SqlDataReader rdr = cmd.ExecuteReader();
        cmd.Dispose();
        return rdr;
    }

    /// <summary>
    /// Metodo per esecuzione query senza valore di ritorno
    /// </summary>
    /// <param name="Query">query di riferimento</param>
    public static void ExecuteNonQuery(string Query)
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();

        command.Connection = con;
        command.Connection.Open();
        command.CommandText = Query;
        command.ExecuteNonQuery();
        command.Connection.Close();
    }


    /// <summary>
    /// Metodo per generazione stringa "NULL"
    /// </summary>
    /// <param name="text">testo di riferimento</param>
    /// <returns>null</returns>
    public static string EmptyStringToNull(Object text)
    {
        if ((text == null) || (text.ToString().Equals("")))
            return "NULL";
        else
            return "'" + text.ToString() + "'";
    }

    /// <summary>
    /// Metodo di conversione data nel formato yyyyMMdd HH:mm:ss
    /// </summary>
    /// <param name="obj">data di input</param>
    /// <returns>conversione data</returns>
    public static string ConvertDateTimeToANSIString(Object obj)
    {
        DateTime dt;

        try
        {
            dt = Convert.ToDateTime(obj);
        }
        catch (Exception e)
        {
            //IMPORTANTE - DEFAULT
            dt = DateTime.Now;
        }

        string ret = dt.Year.ToString();

        if (dt.Month < 10)
            ret += "0" + dt.Month.ToString();
        else
            ret += dt.Month.ToString();

        if (dt.Day < 10)
            ret += "0" + dt.Day.ToString() + " ";
        else
            ret += dt.Day.ToString() + " ";

        if (dt.Hour < 10)
            ret += "0" + dt.Hour.ToString() + ":";
        else
            ret += dt.Hour.ToString() + ":";

        if (dt.Minute < 10)
            ret += "0" + dt.Minute.ToString() + ":";
        else
            ret += dt.Minute.ToString() + ":";

        if (dt.Second < 10)
            ret += "0" + dt.Second.ToString();
        else
            ret += dt.Second.ToString();

        return ret;
    }

    /// <summary>
    /// Metodo di conversione data nel formato data dd/MM/yyyy
    /// ritorna una stringa nel formato dd/MM/yyyy
    /// </summary>
    /// <param name="obj">data di input</param>
    /// <returns>conversione data</returns>
    public static string ConvertDateTimeToDateString(Object obj)
    {
        DateTime dt;

        try
        {
            dt = Convert.ToDateTime(obj);
        }
        catch (Exception e)
        {
            //IMPORTANTE - DEFAULT
            dt = DateTime.Now;
        }

        string ret = "";

        if (dt.Day < 10)
            ret += "0" + dt.Day.ToString() + "/";
        else
            ret += dt.Day.ToString() + "/";

        if (dt.Month < 10)
            ret += "0" + dt.Month.ToString() + "/";
        else
            ret += dt.Month.ToString() + "/";

        ret += dt.Year.ToString();

        return ret;
    }

    /// <summary>
    /// Metodo di conversione data in ore
    /// </summary>
    /// <param name="obj">data di input</param>
    /// <returns>data in ore</returns>
    public static int DateTimeToHour(object obj)
    {
        DateTime dt;

        try
        {
            dt = Convert.ToDateTime(obj);
        }
        catch (Exception e)
        {
            //IMPORTANTE - DEFAULT
            dt = DateTime.Now;
        }

        return dt.Hour;
    }

    /// <summary>
    /// Metodo di conversione data in minuti
    /// </summary>
    /// <param name="obj">data di input</param>
    /// <returns>data in minuti</returns>
    public static int DateTimeToMinute(object obj)
    {
        DateTime dt;

        try
        {
            dt = Convert.ToDateTime(obj);
        }
        catch (Exception e)
        {
            //IMPORTANTE - DEFAULT
            dt = DateTime.Now;
        }

        return dt.Minute;
    }

    /// <summary>
    /// Metodo di conversione stringa in oggetto data
    /// N.B. la stringa della data deve essere nel formato "dd/MM/yyyy"
    /// </summary>
    /// <param name="str_data">data di input</param>
    /// <param name="str_ora">ora di input</param>
    /// <param name="str_minuti">minuti di input</param>
    /// <param name="str_secondi">secondi di input</param>
    /// <returns>conversione data</returns>
    public static DateTime ConvertStringToDateTime(string str_data, string str_ora, string str_minuti, string str_secondi)
    {
        int giorno = ConvertStringToInt(str_data.Substring(0, 2));
        int mese = ConvertStringToInt(str_data.Substring(3, 2));
        int anno = ConvertStringToInt(str_data.Substring(6, 4));

        int ore = ConvertStringToInt(str_ora);
        int minuti = ConvertStringToInt(str_minuti);
        int secondi = ConvertStringToInt(str_secondi);

        DateTime dt = new DateTime(anno, mese, giorno, ore, minuti, secondi);

        return dt;
    }

    /// <summary>
    /// Metodo di conversione di una data in formato stringa
    /// </summary>
    /// <param name="p_data">Data</param>
    /// <param name="p_format_orig">Formato di origine della data (it,en)</param>
    /// <returns>conversione data</returns>
    public static string ConvertStringDateToANSI(string p_data, string p_format_orig)
    {
        string result;
        string giorno = "", mese = "", anno = "";

        switch (p_format_orig)
        {
            case "it":
                giorno = p_data.Substring(0, 2);
                mese = p_data.Substring(3, 2);
                anno = p_data.Substring(6, 4);
                break;

            case "en":
                giorno = p_data.Substring(3, 2);
                mese = p_data.Substring(0, 2);
                anno = p_data.Substring(6, 4);
                break;
        }

        result = anno + mese + giorno;

        return result;
    }

    /// <summary>
    /// Metodo di conversione di una stringa in intero
    /// </summary>
    /// <param name="s">stringa di input</param>
    /// <returns>int</returns>
    public static int ConvertStringToInt(string s)
    {
        int intero;
        try
        {
            intero = Convert.ToInt32(s);
        }
        catch (Exception e)
        {
            intero = 0;
        }
        return intero;
    }

    /// <summary>
    /// Metodo per creazione DataTable
    /// </summary>
    /// <param name="ncolumns">numero colonne da creare</param>
    /// <returns>DataTable</returns>
    public static DataTable CreateDataTable(int ncolumns)
    {
        DataTable table = new DataTable();
        DataColumn column;

        for (int i = 0; i < ncolumns; i++)
        {
            column = new DataColumn();
            column.DataType = Type.GetType("System.String");
            column.ColumnName = "";
            table.Columns.Add(column);
        }

        return table;
    }

    /// <summary>
    /// Metodo per aggiungere dati a DataTable
    /// </summary>
    /// <param name="table">tabella di riferimento</param>
    /// <param name="cells">array di celle da aggiungere</param>
    public static void AddDataToTable(DataTable table, string[] cells)
    {
        DataRow row;

        int ncolumns = table.Columns.Count;
        int nrows = (cells.Length) / ncolumns;
        int ind = 0;

        for (int i = 0; i < nrows; i++)
        {
            row = table.NewRow();

            for (int j = 0; j < ncolumns; j++)
            {
                row[j] = cells[ind];
                ind++;

                if (ind == cells.Length)
                    break;
            }

            table.Rows.Add(row);
        }
    }

    /// <summary>
    /// Metodo per esecuzione comando SQL
    /// Esegue SOLO comandi non-query
    /// </summary>
    /// <param name="commands">aray di comandi</param>
    /// <returns>esito booleano</returns>
    public static bool ExecuteTransaction(string[] commands)
    {
        SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        connection.Open();

        SqlTransaction transaction = connection.BeginTransaction();
        SqlCommand command = new SqlCommand();
        command.Connection = connection;
        command.Transaction = transaction;

        try
        {
            for (int i = 0; i < commands.Length; i++)
            {
                command.CommandText = commands[i];
                command.ExecuteNonQuery();
            }

            transaction.Commit();
        }
        catch (Exception e)
        {
            transaction.Rollback();

            connection.Close();
            connection.Dispose();

            return false;
        }

        connection.Close();
        connection.Dispose();

        return true;
    }

    /// <summary>
    /// Metodo per estrazione Organo di riferimento utente
    /// </summary>
    /// <param name="id_user">utente di input</param>
    /// <returns>nome organo</returns>
    public static int GetOrganoFromUser(int id_user)
    {
        string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

        int result = 0;

        string select = @"SELECT id_organo
                          FROM utenti AS uu
                          INNER JOIN tbl_ruoli AS tr
                             ON uu.id_ruolo = tr.id_ruolo
                          INNER JOIN organi AS oo
                             ON tr.id_organo = oo.id_organo
                          WHERE oo.deleted = 0
                            AND uu.id_utente = " + id_user;

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(select, conn);
        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            result = (int)reader[0];
            break;
        }

        conn.Close();
        conn.Dispose();

        return result;
    }

    /// <summary>
    /// Metdo per estrazione organo dall'id categoria
    /// </summary>
    /// <param name="id_legislatura">identificativo legislatura</param>
    /// <param name="id_categoria_organo">id categoria organo da cercare</param>
    /// <returns>id organo</returns>
    public static int get_id_organo_by_categoria(int id_legislatura, int id_categoria_organo)
    {
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
        SqlCommand command = new SqlCommand();

        int ret = 0;

        command.Connection = con;
        command.Connection.Open();
        command.CommandText = "SELECT id_organo FROM organi where id_categoria_organo = @id_categoria_organo and id_legislatura = @id_legislatura";

        command.Parameters.Add("@id_categoria_organo", SqlDbType.Int);
        command.Parameters["@id_categoria_organo"].Value = id_categoria_organo;
        command.Parameters.Add("@id_legislatura", SqlDbType.Int);
        command.Parameters["@id_legislatura"].Value = id_legislatura;

        SqlDataReader reader = command.ExecuteReader();

        while (reader.Read())
        {
            ret = Convert.ToInt32(reader[0].ToString());
            break;
        }

        reader.Dispose();

        con.Close();
        con.Dispose();

        return ret;
    }

    /// <summary>
    /// Metodo per verifica esistenza persona
    /// </summary>
    /// <param name="p_CF">Codice Fiscale</param>
    /// <param name="p_cognome">Cognome</param>
    /// <param name="p_nome">Nome</param>
    /// <returns>esisto esistenza persona</returns>
    public static bool ExistPersona(string p_CF, string p_cognome, string p_nome)
    {
        string query_CF = @"SELECT id_persona
                            FROM persona
                            WHERE deleted = 0 AND chiuso = 0 
                              AND LOWER(LTRIM(RTRIM(codice_fiscale))) = '@CF'";

        string query_nominativo = @"SELECT id_persona
                                    FROM persona
                                    WHERE deleted = 0 AND chiuso = 0 
                                      AND LOWER(LTRIM(RTRIM(cognome))) = '@cognome'
                                      AND LOWER(LTRIM(RTRIM(nome))) = '@nome'";

        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ToString());
        conn.Open();

        SqlCommand cmd = new SqlCommand();
        cmd.Connection = conn;

        string command_text;

        bool result = true;

        if (p_CF != "")
        {
            command_text = query_CF.Replace("@CF", p_CF);
        }
        else
        {
            command_text = query_nominativo.Replace("@cognome", p_cognome);
            command_text = command_text.Replace("@nome", p_nome);
        }

        cmd.CommandText = command_text;
        SqlDataReader reader = cmd.ExecuteReader();

        if (reader.HasRows)
        {
            result = false;
        }

        conn.Close();
        conn.Dispose();

        return result;
    }

    /// <summary>
    /// Metodo per estarzione Nome Legislatura
    /// </summary>
    /// <param name="p_id_leg">identificativo della legislatura</param>
    /// <returns>nome legislatura</returns>
    public static string GetLegislaturaName(string p_id_leg)
    {
        string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

        string result = "";

        string select = @"SELECT num_legislatura
                          FROM legislature 
                          WHERE id_legislatura = " + p_id_leg;

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(select, conn);
        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            result = reader[0].ToString();
            break;
        }

        conn.Close();
        conn.Dispose();

        return result;
    }

    /// <summary>
    /// Recupera DUP vigente in base alla data
    /// </summary>
    /// <param name="dataInizio">Data di riferimento</param>
    /// <returns>Dup vigente alla data indicata</returns>
    public static Constants.Dup GetDupByDate(DateTime dataInizio)
    {
        var idDup = Utility.GetValueFromDb<byte>("select dbo.fnGetDupByDate(@dateToTest)", CommandType.Text,
            new Dictionary<string, object>() { { "dateToTest", dataInizio } });
        return (Constants.Dup)idDup;
    }

    /// <summary>
    /// Recupera DUP vigente in base ad anno e mese
    /// </summary>
    /// <param name="year">Anno di riferimento</param>
    /// <param name="month">Mese di riferimento</param>
    /// <returns>Dup vigente al primo giorno dell'anno e mese indicati</returns>
    public static Constants.Dup GetDupByYearMonth(int year, int month)
    {
        return GetDupByDate(new DateTime(year, month, 1));
    }
}


/// <summary>
/// Classe per la gestione Extensions
/// </summary>
public static class Extensions
{
    /// <summary>
    /// Metodo per gestione apici
    /// </summary>
    /// <param name="str">stringa SQL di input</param>
    /// <returns>sql</returns>
    public static string ToSqlString(this string str)
    {
        return str.Replace("'", "''");
    }

    /// <summary>
    /// Metodo di conversione tipo allegato in stringa
    /// </summary>
    /// <param name="type">tipo allegato</param>
    /// <returns>valore tipo allegato</returns>
    public static string Value(this AllegatiType type)
    {
        return ((char)type).ToString();
    }

    /// <summary>
    /// Metodo di conversione in Esadecimale
    /// </summary>
    /// <param name="bytes">contenuto di input</param>
    /// <returns>Esadecimale</returns>

    public static string toHexString(this byte[] bytes)
    {
        try
        {
            var hex = new StringBuilder(bytes.Length * 2);
            foreach (byte bit in bytes)
                hex.AppendFormat("{0:x2}", bit);
            return hex.ToString();
        }
        catch (Exception)
        { throw; }
    }


    #region PAGE

    /// <summary>
    /// Redirect alla home page se l'ID non è valido
    /// </summary>
    /// <param name="page">pagina che invoca questa funzione</param>
    /// <param name="id">id persona da verificare</param>
    public static void CheckIdPersona(this Page page, string id)
    {
        if (string.IsNullOrEmpty(id))
            page.Response.Redirect("/Index.aspx");
    }

    #endregion


    #region SESSION

    /// <summary>
    /// Metodo per gestione visibilità sezione Certificati
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <returns>esito se visibile</returns>
    public static bool IsVisible_Certificati(this HttpSessionState session)
    {
        bool result = false;

        int tmpRole = -1;

        if (session.Contents["logged_role"] != null && int.TryParse(session.Contents["logged_role"].ToString(), out tmpRole))
        {
            result = true;

            if (tmpRole == 5)
            {
                if (session.Contents["logged_categoria_organo"] != null)
                {
                    int organo = (int)session.Contents["logged_categoria_organo"];
                    result = (organo != (int)Constants.CategoriaOrgano.GiuntaElezioni);
                }
            }
        }

        return result;
    }

    /// <summary>
    /// Metodo per gestione visibilità sezione Incarichi extra
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <returns>esito se visibile</returns>
    public static bool IsVisible_IncExtraCost(this HttpSessionState session)
    {
        bool result = false;

        int tmpRole = -1;

        if (session.Contents["logged_role"] != null && int.TryParse(session.Contents["logged_role"].ToString(), out tmpRole))
        {
            if (tmpRole == 1 || tmpRole == 2)
                result = true;
            else if (tmpRole == 5)
            {
                if (session.Contents["logged_categoria_organo"] != null)
                {
                    int categoria_organo = (int)session.Contents["logged_categoria_organo"];
                    result = (categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni);
                }
            }
        }

        return result;
    }

    /// <summary>
    /// Metodo per gestione edit sezione Incarichi extra
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <returns>esito se editabile</returns>
    public static bool IsEditable_IncExtraCost(this HttpSessionState session)
    {
        bool result = false;

        int tmpRole = -1;

        if (session.Contents["logged_role"] != null && int.TryParse(session.Contents["logged_role"].ToString(), out tmpRole))
        {
            if (tmpRole == 1 || tmpRole == 2)
                result = true;
            else if (tmpRole == 5)
            {
                if (session.Contents["logged_categoria_organo"] != null)
                {
                    int categoria_organo = (int)session.Contents["logged_categoria_organo"];
                    result = (categoria_organo == (int)Constants.CategoriaOrgano.GiuntaElezioni);
                }

            }
        }

        return result;
    }

    /// <summary>
    /// Metodo di conversione Nome Sessione in stringa
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <param name="name">nome di riferimento</param>
    /// <returns>nome sessione</returns>
    public static string GetString(this HttpSessionState session, string name)
    {
        if (session[name] != null)
            return session[name].ToString();
        else
            return null;
    }

    /// <summary>
    /// Metodo per assegnazione Valore Sessione
    /// </summary>
    /// <param name="session">Sesione di riferimento</param>
    /// <param name="name">nome sessione</param>
    /// <param name="value">valora da impostare</param>
    public static void SetString(this HttpSessionState session, string name, string value)
    {
        session[name] = value;
    }

    /// <summary>
    /// Metodo per Reset Filtri
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    public static void ClearFilters(this HttpSessionState session)
    {
        session["FilterSedute"] = null;
        session["FilterCertificati"] = null;
    }

    /// <summary>
    /// Metodo per caricamento istanza FilterSedute
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <returns>Filtri sedute</returns>
    public static FilterSedute GetFilterSedute(this HttpSessionState session)
    {
        FilterSedute filter = new FilterSedute();

        if (session["FilterSedute"] != null)
            filter = (FilterSedute)session["FilterSedute"];

        return filter;
    }

    /// <summary>
    /// Metodo per impostare sessione oggetto FilterSedute
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <param name="filter">filtri</param>
    public static void SetFilterSedute(this HttpSessionState session, FilterSedute filter)
    {
        session["FilterSedute"] = filter;
    }

    /// <summary>
    /// Metodo per caricamento istanza FilterLegislatura
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <returns>Filtri legislatura</returns>
    public static FilterLegislatura GetFilterCertificati(this HttpSessionState session)
    {
        FilterLegislatura filter = new FilterLegislatura();

        if (session["FilterCertificati"] != null)
            filter = (FilterLegislatura)session["FilterCertificati"];

        return filter;
    }

    /// <summary>
    /// Metodo per impostare sessione oggetto FilterCertificati
    /// </summary>
    /// <param name="session">Sessione di riferimento</param>
    /// <param name="filter">filtri</param>

    public static void SetFilterCertificati(this HttpSessionState session, FilterLegislatura filter)
    {
        session["FilterCertificati"] = filter;
    }

    #endregion
}


/// <summary>
/// Classe per la gestione Constants
/// </summary>
public class Constants
{
    /// <summary>
    /// ANNOMESE_DUP53
    /// attivazione DUP 53
    /// </summary>
    public const string ANNOMESE_DUP53 = "201504";

    /// <summary>
    /// DATA_DUP53
    /// attivazione DUP 53
    /// </summary>
    public const string DATA_DUP53 = "20150401";

    /// <summary>
    /// ANNOMESE_DUP106
    /// </summary>
    public const string ANNOMESE_DUP106 = "201405";
    /// <summary>
    /// DATA_DUP106
    ///Data attivazione DUP 106
    /// </summary>
    public const string DATA_DUP106 = "20140501";

    /// <summary>
    /// Per gestire gli header dei report in cui non deve più comparire la DIARIA da Luglio 2013 
    /// </summary>
    public const string ANNOMESE_ABOLIZIONE_DIARIA = "201306";

    public const string OPZIONE_SI_DIARIA = "CONSIGLIERI CHE HANNO OPTATO PER LA DIARIA";
    public const string OPZIONE_NO_DIARIA = "CONSIGLIERI CHE NON HANNO OPTATO PER LA DIARIA";

    public const string OPZIONE_SI_LR2013 = "Consiglieri che hanno optato ai fini delle trattenute di cui all’art. 6 della L.R. n. 3/2013";
    public const string OPZIONE_NO_LR2013 = "Consiglieri che non hanno optato ai fini delle trattenute di cui all’art. 6 della L.R. n. 3/2013";

    public const string OPZIONE_PRIMA_PRIORITARIA = "Consiglieri che hanno indicato la commissione come Prima Prioritaria";
    public const string OPZIONE_SECONDA_PRIORITARIA = "Consiglieri che hanno indicato la commissione come Seconda Prioritaria";
    public const string OPZIONE_NESSUNA_PRIORITARIA = "Consiglieri che non hanno indicato la commissione come Prioritaria";

    /// <summary>
    /// Priorità
    /// </summary>
    public enum Priorita
    {
        Nessuna = 1,
        Prima = 2,
        Seconda = 3
    }

    /// <summary>
    /// Dup (da tabella tb_dup)
    /// </summary>
    public enum Dup
    {
        Nessuno = 0,
        DUP106 = 1,
        DUP53 = 2
    }


    /// <summary>
    /// Enumerativo della categoria organo
    /// </summary>

    public enum CategoriaOrgano
    {
        ConsiglioRegionale = 1,
        CommissioneRegionale,
        Conferenza,
        GiuntaRegionale,
        GiuntaRegolamento,
        ComitatoRistretto,
        UfficioPresidenza,
        ConferenzaPresidentiGruppi,
        GiuntaElezioni,
        CommissioneInchiesta
    }

    /// <summary>
    /// Enumerativo della tipologia della carica
    /// </summary>
    public enum TipoCarica
    {
        Assessore = 1,
        AssessoreVicePresidente,
        AssessoreNonConsigliere,
        Consigliere,
        ConsigliereSupplente,
        CoPresidente,
        Presidente,
        PresidenteCommissione,
        Segretario,
        SottoSegretario,
        VicePresidente,
        Componente
    }
}


/// <summary>
/// Classe per la gestione FilterLegislatura
/// </summary>
public class FilterLegislatura
{
    public int? IdLegislatura { get; set; }

    /// <summary>
    /// Proprietà gestione legislatura definita
    /// </summary>
    public bool IsDefined
    {
        get { return (IdLegislatura.HasValue); }
    }

    /// <summary>
    /// Metodo reset legislatura
    /// </summary>
    public void Reset()
    {
        IdLegislatura = null;
    }
}

/// <summary>
/// Classe per la gestione FilterSedute
/// </summary>
public class FilterSedute
{
    public int? Mese { get; set; }
    public int? Anno { get; set; }
    public int? IdOrgano { get; set; }
    public int? IdLegislatura { get; set; }
    public string TipoSeduta { get; set; }

    /// <summary>
    /// Proprietà gestione filtro definito
    /// </summary>
    public bool IsDefined
    {
        get { return (Mese.HasValue || Anno.HasValue || IdOrgano.HasValue || IdLegislatura.HasValue || !string.IsNullOrEmpty(TipoSeduta)); }
    }

    /// <summary>
    /// Metodo per reset oggetto
    /// </summary>

    public void Reset()
    {
        Mese = null;
        Anno = null;
        IdOrgano = null;
        IdLegislatura = null;
        TipoSeduta = null;
    }
}

/// <summary>
/// Classe per la gestione FilterSedute
/// </summary>
public class Legislatura
{
    static string query_current_leg = @"SELECT id_legislatura
                                 FROM legislature 
                                 WHERE attiva = 1
                                   AND durata_legislatura_a IS NULL
                                 ORDER BY durata_legislatura_da DESC";

    static string query_last_leg = @"SELECT id_legislatura
                              FROM legislature 
                              WHERE attiva = 0
                                AND durata_legislatura_a IS NOT NULL
                              ORDER BY durata_legislatura_da DESC";


    /// <summary>
    /// Metodo per impostazione Legislatura
    /// </summary>
    public static void setLegislaturaCorrente()
    {
        SqlConnection conn = null;
        SqlDataReader reader = null;

        try
        {
            conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString);
            conn.Open();

            SqlCommand cmd = new SqlCommand(query_current_leg, conn);

            reader = cmd.ExecuteReader();

            string id_legislatura = null;

            while (reader.Read())
            {
                id_legislatura = reader[0].ToString();
                break;
            }

            reader.Close();

            if (id_legislatura != null)
            {
                System.Web.HttpContext.Current.Session.Contents.Add("id_legislatura", id_legislatura);
            }
            else
            {
                cmd.CommandText = query_last_leg;
                reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    id_legislatura = reader[0].ToString();
                    break;
                }

                reader.Close();

                if (id_legislatura != null)
                {
                    System.Web.HttpContext.Current.Session.Contents.Add("id_legislatura", id_legislatura);
                }
                else
                {
                    throw new Exception("Impossibile trovare una legislatura");
                }
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
            }
        }
    }
}