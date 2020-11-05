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
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;

/// <summary>
/// Classe per la gestione Allegati
/// </summary>
public class Allegati
{
    #region PROPERTIES

    /// <summary>
    /// Proprietà per impostare il path degli allegati in base al parametro di configurazione PATH_ALLEGATI
    /// </summary>
    public static string DirectoryPath
    {
        get
        {
            try
            {
                var ret = System.Configuration.ConfigurationManager.AppSettings["PATH_ALLEGATI"].ToString();
                if (string.IsNullOrEmpty(ret))
                    throw new Exception("Percorso di salvataggio degli alllegati non valido.");
                if (ret.Trim() == "")
                    throw new Exception("Percorso di salvataggio degli alllegati non valido.");

                if (!ret.Trim().StartsWith("~/"))
                    ret = "~/" + ret;

                ret = HttpContext.Current.Server.MapPath(ret);

                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception("Impossibile recuperare il percorso di salvataggio degli allegati. Verificare la configurazione.", ex);
            }
        }
    }

    #endregion


    #region METHODS - DB

    /// <summary>
    /// Metodo per salvataggio file seduta sul database e filesystem
    /// </summary>
    /// <param name="filename">nome file</param>
    /// <param name="fileBytes">dimensione file</param>
    /// <param name="id_seduta">identificativo seduta</param>
    public static void Save_Seduta(string filename, byte[] fileBytes, int id_seduta)
    {
        int? id_allegato = null;

        try
        {
            var hash = ComputeHash(fileBytes);
            Check_File_Exists(hash, AllegatiType.Seduta);

            var qry = new StringBuilder(@" INSERT INTO [dbo].[allegati_seduta]
                                                   ([id_seduta]
                                                   ,[filename]
                                                   ,[filesize]
                                                   ,[filehash])
                                             VALUES
                                                   (@id_seduta
                                                   ,'@filename'
                                                   ,@filesize
                                                   ,'@filehash')

                                            SELECT SCOPE_IDENTITY()
                                         ");
            qry.Replace("@id_seduta", id_seduta.ToString());
            qry.Replace("@filename", filename);
            qry.Replace("@filesize", fileBytes.Length.ToString());
            qry.Replace("@filehash", hash);

            var rows = Utility.GetDataRows(qry.ToString());
            id_allegato = (int)rows.First().Field<decimal>(0);

            if (id_allegato.HasValue)
                SaveBytes(id_allegato.Value, fileBytes, AllegatiType.Seduta);
        }
        catch (Exception ex)
        {
            if (id_allegato.HasValue)
            {
                try
                {
                    var qryDel = new StringBuilder(@" DELETE [dbo].[allegati_seduta] 
                                                      WHERE id_allegato = @id_allegato ");
                    qryDel.Replace("@id_allegato", id_allegato.Value.ToString());

                    Utility.ExecuteNonQuery(qryDel.ToString());
                }
                catch { }
            }

            throw ex;
        }
    }

    /// <summary>
    /// Metodo per salvataggio file Riepilogo sul database e filesystem
    /// </summary>
    /// <param name="filename">nome file</param>
    /// <param name="fileBytes">dimensione file</param>
    /// <param name="anno">anno di riferimento</param>
    /// <param name="mese">mese di riferimento</param>
    public static void Save_Riepilogo(string filename, byte[] fileBytes, int anno, int mese)
    {
        int? id_allegato = null;

        try
        {
            var hash = ComputeHash(fileBytes);

            Check_File_Exists(hash, AllegatiType.Riepilogo);

            var qry = new StringBuilder(@" INSERT INTO [dbo].[allegati_riepilogo]
                                                   ([anno]
                                                   ,[mese]
                                                   ,[filename]
                                                   ,[filesize]
                                                   ,[filehash])
                                             VALUES
                                                   (@anno
                                                   ,@mese
                                                   ,'@filename'
                                                   ,@filesize
                                                   ,'@filehash')

                                            SELECT SCOPE_IDENTITY()
                                         ");
            qry.Replace("@anno", anno.ToString());
            qry.Replace("@mese", mese.ToString());
            qry.Replace("@filename", filename);
            qry.Replace("@filesize", fileBytes.Length.ToString());
            qry.Replace("@filehash", hash);

            var rows = Utility.GetDataRows(qry.ToString());
            id_allegato = (int)rows.First().Field<decimal>(0);

            if (id_allegato.HasValue)
                SaveBytes(id_allegato.Value, fileBytes, AllegatiType.Riepilogo);
        }
        catch (Exception ex)
        {
            if (id_allegato.HasValue)
            {
                try
                {
                    var qryDel = new StringBuilder(@" DELETE [dbo].[allegati_riepilogo] 
                                                      WHERE id_allegato = @id_allegato ");
                    qryDel.Replace("@id_allegato", id_allegato.Value.ToString());

                    Utility.ExecuteNonQuery(qryDel.ToString());
                }
                catch { }
            }

            throw ex;
        }
    }


    /// <summary>
    /// Metodo gestione esistenza file allegato
    /// </summary>
    /// <param name="fileHash">Stringa Hash file crittografato</param>
    /// <param name="allegati_type">Tipo allegato</param>
    private static void Check_File_Exists(string fileHash, AllegatiType allegati_type)
    {
        try
        {
            var qryHash = new StringBuilder();

            if (allegati_type == AllegatiType.Seduta)
            {
                qryHash.Append(@" SELECT A.id_allegato 
                                FROM [dbo].[allegati_seduta] A
                                inner join sedute S on S.id_seduta = A.id_seduta
                                WHERE S.deleted = 0 and A.filehash = '@filehash' ");
            }
            else if (allegati_type == AllegatiType.Riepilogo)
            {
                qryHash.Append(@" SELECT A.id_allegato 
                                FROM [dbo].[allegati_riepilogo] A
                                WHERE A.filehash = '@filehash' ");
            }
            else
            {
                return;
            }

            qryHash.Replace("@filehash", fileHash);

            var hashRows = Utility.GetDataRows(qryHash.ToString());
            if (hashRows.Count > 0)
            {
                if (allegati_type == AllegatiType.Seduta)
                {
                    throw new Exception("Il file selezionato è già stato inserito in questa seduta.");
                }
                else if (allegati_type == AllegatiType.Riepilogo)
                {
                    throw new Exception("Il file selezionato è già stato inserito.");
                }
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


    #endregion


    #region METHODS - IO

    /// <summary>
    /// Metodo per creazione Hash di un file
    /// </summary>
    /// <param name="fileBytes">contenuto del file</param>
    /// <returns>stringa hash</returns>
    public static string ComputeHash(byte[] fileBytes)
    {
        try
        {
            var hashAlgorithm = System.Security.Cryptography.SHA256.Create();
            var hashBytes = hashAlgorithm.ComputeHash(fileBytes);

            return hashBytes.toHexString();
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per caricamento file
    /// </summary>
    /// <param name="id_allegato">identificativo file</param>
    /// <param name="type">tipo file</param>
    /// <returns>array di byte</returns>
    public static byte[] LoadBytes(int id_allegato, AllegatiType type)
    {
        try
        {
            var fileName = GetSaveName(id_allegato, type);
            return LoadBytes(fileName);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per salvataggio File
    /// </summary>
    /// <param name="id_allegato">identificativo file</param>
    /// <param name="fileBytes">contenuto file</param>
    /// <param name="type">tipo file</param>
    public static void SaveBytes(int id_allegato, byte[] fileBytes, AllegatiType type)
    {
        try
        {
            var fileName = GetSaveName(id_allegato, type);
            SaveBytes(fileName, fileBytes);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per eliminazione contenuto file
    /// </summary>
    /// <param name="id_allegato">identificativo file</param>
    /// <param name="type">tipo file</param>
    /// <param name="throwIfNotExisting">flag esistenza file</param>
    public static void DeleteBytes(int id_allegato, AllegatiType type, bool throwIfNotExisting = true)
    {
        try
        {
            var fileName = GetSaveName(id_allegato, type);
            DeleteBytes(fileName, throwIfNotExisting);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per sostituzione contenuto file
    /// </summary>
    /// <param name="id_allegato">identificativo file</param>
    /// <param name="fileBytes">contenuto file</param>
    /// <param name="type">tipo file</param>
    public static void ReplaceBytes(int id_allegato, byte[] fileBytes, AllegatiType type)
    {
        try
        {
            var fileName = GetSaveName(id_allegato, type);
            ReplaceBytes(fileName, fileBytes);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per creazione Path completo file
    /// </summary>
    /// <param name="id_allegato">identificativo file</param>
    /// <param name="type">tipo file</param>
    /// <returns>path esteso</returns>
    public static string GetFullPath(int id_allegato, AllegatiType type)
    {
        try
        {
            var fileName = GetSaveName(id_allegato, type);
            return Path.Combine(DirectoryPath, fileName);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per creazione Nome file salvato
    /// </summary>
    /// <param name="id_allegato">identificativo file</param>
    /// <param name="type">tipo file</param>
    /// <returns>nome file allegato</returns>
    public static string GetSaveName(int id_allegato, AllegatiType type)
    {
        return ((char)type).ToString() + "_" + id_allegato.ToString("0000000000") + ".pdf";
    }

    /// <summary>
    /// Metodo per caricamento contenuto File
    /// </summary>
    /// <param name="fileName">Nome File</param>
    /// <returns>array di byte del file</returns>
    public static byte[] LoadBytes(string fileName)
    {
        try
        {
            var fullPath = Path.Combine(DirectoryPath, fileName);
            if (!File.Exists(fullPath))
                throw new Exception("Impossibile trovare il file");

            return File.ReadAllBytes(fullPath);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


    /// <summary>
    /// Metodo per salvataggio contenuto File
    /// </summary>
    /// <param name="fileName">Nome del file</param>
    /// <param name="fileBytes">contenuto file</param>
    public static void SaveBytes(string fileName, byte[] fileBytes)
    {
        try
        {
            var fullPath = Path.Combine(DirectoryPath, fileName);
            if (File.Exists(fullPath))
                throw new Exception("Il file che si sta salvando risulta già esistente.");

            File.WriteAllBytes(fullPath, fileBytes);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Metodo per eliminazzione contenuto File
    /// </summary>
    /// <param name="fileName">Nome del file</param>
    /// <param name="throwIfNotExisting">flag esistenza file</param>
    public static void DeleteBytes(string fileName, bool throwIfNotExisting = true)
    {
        try
        {
            var fullPath = Path.Combine(DirectoryPath, fileName);
            if (!File.Exists(fullPath))
            {
                if (throwIfNotExisting)
                    throw new Exception("Impossibile trovare il file");
                else
                    return;
            }

            File.Delete(fullPath);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


    /// <summary>
    /// Metodo per sostituzione contenuto File
    /// </summary>
    /// <param name="fileName">Nome del file</param>
    /// <param name="fileBytes">contenuto file</param>
    public static void ReplaceBytes(string fileName, byte[] fileBytes)
    {
        try
        {
            var fullPath = Path.Combine(DirectoryPath, fileName);
            if (File.Exists(fullPath))
                File.Delete(fullPath);

            File.WriteAllBytes(fullPath, fileBytes);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    #endregion
}

/// <summary>
/// Enumerazione per gestione tipologie Allegati
/// </summary>
public enum AllegatiType
{
    Seduta = 'S',
    Riepilogo = 'R',
    Dichiarazione_IncExtraIst = 'D'
}


