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
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione Master Page
/// </summary>
public partial class MasterPage : System.Web.UI.MasterPage
{
    protected string loggedin;
    protected int role;
    protected string logged_organo;
    protected string logged_organo_name;
    protected int? logged_categoria_organo;

    protected string mode = "";

    /// <summary>
    /// Gestione Evento OnInit
    /// </summary>
    /// <param name="e">Argomenti</param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        try
        {
            if (!Request.Url.ToString().ToLower().Contains("errore.aspx"))
            {
                ActiveDirectory.CheckLogin(Page.User.Identity);
                panel_loggeruser.Refresh();
            }
        }
        catch (Exception ex)
        {
            Page_Error_Custom(ex.Message);
        }
    }
    /// <summary>
    /// Evento per il caricamento della pagina
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            loggedin = Session.Contents["logged_in"] as string;
            logged_organo = Session.Contents["logged_organo"] as string;
            logged_organo_name = Session.Contents["logged_organo_name"] as string;
            role = Convert.ToInt32(Session.Contents["logged_role"]);

            logged_categoria_organo = Session.Contents["logged_categoria_organo"] as int?;

            if (loggedin == null)
            {
                loggedin = "0";
            }

            mode = Request.QueryString["mode"];
        }
        catch (Exception ex)
        {
            Page_Error_Custom(ex.Message);
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

    protected void Page_Error_Custom(string p_err_msg)
    {
        Session.Contents.Add("align", "center");
        Session.Contents.Add("error_message", p_err_msg);
        Response.Redirect("~/errore.aspx");
    }

    /// <summary>
    /// Metodo per impostare le immagini
    /// </summary>

    void SetImage()
    {
        if (!string.IsNullOrEmpty(logged_organo_name))
        {
            var img = form1.FindControl("Image1") as Image;
            var organo = logged_organo_name.ToUpper();
            if (organo.StartsWith("I "))
                img.ImageUrl = "loghi/Logo_I_Commissione.gif";
            else if (organo.StartsWith("II "))
                img.ImageUrl = "loghi/Logo_II_Commissione.gif";
            else if (organo.StartsWith("III "))
                img.ImageUrl = "loghi/Logo_III_Commissione.gif";
            else if (organo.StartsWith("IV "))
                img.ImageUrl = "loghi/Logo_IV_Commissione.gif";
            else if (organo.StartsWith("V "))
                img.ImageUrl = "loghi/Logo_V_Commissione.gif";
            else if (organo.StartsWith("VI "))
                img.ImageUrl = "loghi/Logo_VI_Commissione.gif";
            else if (organo.StartsWith("VII "))
                img.ImageUrl = "loghi/Logo_VII_Commissione.gif";
        }
    }

    /// <summary>
    /// Gestione Evento Click dell'oggetto Button1
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Button1_Click(object sender, EventArgs e)
    {
        Session.Contents.RemoveAll();
        Response.Redirect("../index.aspx");
    }

    /// <summary>
    /// Metodo conversione in booleano
    /// </summary>
    /// <param name="obj">oggetto di riferimento</param>
    /// <returns>oggetto convertito</returns>
    public bool ToBool(object obj)
    {
        bool ret = false;

        if (obj != null)
            bool.TryParse(obj.ToString(), out ret);

        return ret;
    }
}