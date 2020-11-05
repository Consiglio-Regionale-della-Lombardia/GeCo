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
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Lista Allegati
/// </summary>
public partial class allegati_allegatiList : System.Web.UI.UserControl
{
    public bool isEnabled = false;

    public AllegatiType allegati_type;
    public string seduta_id;
    public int riepilogo_anno = 0;
    public int riepilogo_mese = 0;

    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        bool queryOk = false;
        var sbSelect = new StringBuilder("select * from #TABLE# where #WHERE# order by filename");
        var sbDelete = new StringBuilder("delete #TABLE# where id_allegato = @id_allegato");
        string table = "";

        if (allegati_type == AllegatiType.Seduta)
        {
            table = "allegati_seduta";
            sbDelete.Replace("#TABLE#", table);
            sbSelect.Replace("#TABLE#", table);
            sbSelect.Replace("#WHERE#", " id_seduta = " + seduta_id.ToString());

            queryOk = true;
        }
        else if (allegati_type == AllegatiType.Riepilogo)
        {
            table = "allegati_riepilogo";
            sbDelete.Replace("#TABLE#", table);
            sbSelect.Replace("#TABLE#", table);
            sbSelect.Replace("#WHERE#", " anno = " + riepilogo_anno.ToString() + " and mese = " + riepilogo_mese.ToString());
            queryOk = true;
        }

        if (queryOk)
        {
            SqlDataSource_GridViewAllegati.SelectCommand = sbSelect.ToString();
            SqlDataSource_GridViewAllegati.DeleteCommand = sbDelete.ToString();
            GridViewAllegati.DataBind();
        }
    }

    /// <summary>
    /// Gestione Evento DataBound dell'oggetto GridViewAllegati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    public void GridViewAllegati_DataBound(object sender, EventArgs e)
    {
        var num = GridViewAllegati.Rows.Count;
        if (num > 0)
        {

        }
    }

    /// <summary>
    /// Gestione Evento DataBinding dell'oggetto GridViewAllegati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    public void GridViewAllegati_DataBinding(object sender, EventArgs e)
    {
        var num = GridViewAllegati.Rows.Count;
        if (num > 0)
        {

        }
    }

    /// <summary>
    /// Gestione Evento DataBinding dell'oggetto SqlDataSource_GridViewAllegati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    public void SqlDataSource_GridViewAllegati_DataBinding(object sender, EventArgs e)
    {
        var num = GridViewAllegati.Rows.Count;
        if (num > 0)
        {

        }
    }

    /// <summary>
    /// Gestione Evento Click dell'oggetto cmdNew
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        if (uploadFile.FileBytes != null && !string.IsNullOrEmpty(uploadFile.FileName))
        {
            if (System.IO.Path.GetExtension(uploadFile.FileName).Trim('.').ToUpper() == "PDF")
            {
                if (allegati_type == AllegatiType.Seduta)
                    Allegati.Save_Seduta(uploadFile.FileName, uploadFile.FileBytes, int.Parse(seduta_id));
                else if (allegati_type == AllegatiType.Riepilogo)
                    Allegati.Save_Riepilogo(uploadFile.FileName, uploadFile.FileBytes, riepilogo_anno, riepilogo_mese);
            }
            else
                throw new Exception("Impossibile caricare il file: sono ammessi solo i PDF.");
        }

        GridViewAllegati.DataBind();
    }

    /// <summary>
    /// Gestione Evento Click dell'oggetto cmdDelete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        Button cmd = (Button)sender;
        int id_allegato = int.Parse(cmd.ID.Split('_').First());

        //Response.Redirect("dettaglio.aspx?nuovo=true");
    }

    /// <summary>
    /// Gestione Evento Command dell'oggetto cmdDelete
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void cmdDelete_Command(object sender, CommandEventArgs e)
    {
        var test = e.CommandArgument;
    }

    /// <summary>
    /// Gestione Evento Deleted dell'oggetto SqlDataSource_GridViewAllegati
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>
    protected void SqlDataSource_GridViewAllegati_Deleted(object sender, SqlDataSourceStatusEventArgs e)
    {
        var id = e.Command.Parameters[0].Value as int?;

        if (id.HasValue)
        {
            Allegati.DeleteBytes(id.Value, allegati_type);
        }
    }

    /// <summary>
    /// Creazione della URL della Form per apertura Popup
    /// </summary>
    /// <param name="id">id di riferimento</param>
    /// <param name="fileName">nome file</param>
    /// <returns>Stringa URL della Form</returns>
    public string getPopupURL(object id, object fileName)
    {
        var url = new StringBuilder("../allegati/allegatiDownload.aspx?type=#TYPE#&id=#ID#&name=#NAME#");
        url.Replace("#TYPE#", allegati_type.Value());
        url.Replace("#ID#", id.ToString());
        url.Replace("#NAME#", HttpUtility.UrlPathEncode(fileName.ToString()));

        return "document.location.href = '" + url.ToString() + "'; return false;";
    }
}