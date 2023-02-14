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
using System.Text;

/// <summary>
/// Classe per la gestione Tabs Persona
/// </summary>

public partial class TabsPersona : System.Web.UI.UserControl
{
    public string legislatura_corrente;
    public int id_user;
    public int role;
    public string nome_organo;

    string id_persona;
    string sel_leg_id;

    bool isConsigliere = false;
    bool isAssessore = false;

    /// <summary>
    /// Evento per il caricamento della pagina - Inizializzazione dati e visibilità
    /// </summary>
    /// <param name="sender">Oggetto che ha generato l'evento</param>
    /// <param name="e">Argomenti</param>

    protected void Page_Load(object sender, EventArgs e)
    {
        legislatura_corrente = Convert.ToString(Session.Contents["id_legislatura"]);
        id_user = Convert.ToInt32(Session.Contents["user_id"]);
        role = Convert.ToInt32(Session.Contents["logged_role"]);

        if (role > 4)
        {
            nome_organo = Session.Contents["logged_organo_name"].ToString().ToLower();
        }


        id_persona = Request.QueryString["id"];
        sel_leg_id = null;

        if (id_persona != null)
        {
            sel_leg_id = Request.QueryString["sel_leg_id"];

            //Session.Contents.Add("id_persona", id);
            //Session.Contents.Add("sel_leg_id", sel_leg_id);
        }
        else
        {
            id_persona = Session.Contents["id_persona"] as String;
            sel_leg_id = Session.Contents["sel_leg_id"] as String;
        }

        if (string.IsNullOrEmpty(sel_leg_id))
            sel_leg_id = legislatura_corrente;

        isConsigliere = CheckIsConsigliere();
        isAssessore = CheckIsAssessore();

        SetVisibility();

        SetModeVisibility();
    }


    /// <summary>
    /// Metodo per impostazione visibilità
    /// </summary>
    private void SetVisibility()
    {
        //Tab non più utilizzato 
        a_pratiche.Visible = false;

        a_gruppi_politici.Visible = isConsigliere;

        var isEconomato = (role == 8);

        a_sospensioni.Visible = !isEconomato && isConsigliere;
        a_sostituzioni.Visible = !isEconomato && isConsigliere;
        a_aspettative.Visible = !isEconomato && isConsigliere;
        a_risultati_elettorali.Visible = !isEconomato && isConsigliere;
        a_presenze_assenze.Visible = !isEconomato;
        a_varie.Visible = !isEconomato;

        a_certificati.Visible = Session.IsVisible_Certificati();

        //a_incarichi_extra_istituzionali.Visible = !isAssessore && Session.IsVisible_IncExtraCost();
        a_incarichi_extra_istituzionali.Visible = Session.IsVisible_IncExtraCost();
    }

    /// <summary>
    /// Metodo per selezione tab
    /// </summary>
    /// <param name="selTab">Tab di riferimento</param>
    public void SelectTab(EnumTabsPersona selTab)
    {
        try
        {
            hidSelection.Value = selTab.ToString();

        }
        catch (Exception ex)
        {

        }
    }

    /// <summary>
    /// Metodo gestione visibilita
    /// </summary>
    /// <param name="p_mode">modalità di visualizzazione</param>

    protected void SetModeVisibility()
    {
        string mode = Request.QueryString["mode"];

        string complete_url = "&id=" + id_persona + "&sel_leg_id=" + sel_leg_id;

        if (!isConsigliere)
        {
            if (mode == "popup")
            {
                a_dettaglio.HRef = "~/persona/dettaglio_assessori.aspx?mode=popup";
                a_cariche.HRef = "~/cariche/cariche_assessori.aspx?mode=popup";
                a_missioni.HRef = "~/missioni/missioni_assessori.aspx?mode=popup";
                a_certificati.HRef = "~/certificati/certificati.aspx?mode=popup";
                a_pratiche.HRef = "~/pratiche/pratiche_assessori.aspx?mode=popup";
                a_trasparenza.HRef = "~/trasparenza/trasparenza.aspx?mode=popup";
                a_presenze_assenze.HRef = "~/presenze/presenze_assessori.aspx?mode=popup";
                a_varie.HRef = "~/varie/varie_assessori.aspx?mode=popup";
                a_incarichi_extra_istituzionali.HRef = "~/schede_incarichi/incarichi_extra_istituzionali_assessore.aspx?mode=popup" + complete_url;
            }
            else
            {
                a_dettaglio.HRef = "~/persona/dettaglio_assessori.aspx?mode=normal";
                a_cariche.HRef = "~/cariche/cariche_assessori.aspx?mode=normal";
                a_missioni.HRef = "~/missioni/missioni_assessori.aspx?mode=normal";
                a_certificati.HRef = "~/certificati/certificati.aspx?mode=normal";
                a_pratiche.HRef = "~/pratiche/pratiche_assessori.aspx?mode=normal";
                a_trasparenza.HRef = "~/trasparenza/trasparenza.aspx?mode=normal";
                a_presenze_assenze.HRef = "~/presenze/presenze_assessori.aspx?mode=normal";
                a_varie.HRef = "~/varie/varie_assessori.aspx?mode=normal";
                a_incarichi_extra_istituzionali.HRef = "~/schede_incarichi/incarichi_extra_istituzionali_assessore.aspx?mode=normal" + complete_url;
            }
        }
        else
        {
            if (mode == "popup")
            {
                a_dettaglio.HRef = "~/persona/dettaglio.aspx?mode=popup" + complete_url;
                a_gruppi_politici.HRef = "~/gruppi_politici/gruppi_politici.aspx?mode=popup" + complete_url;
                a_cariche.HRef = "~/cariche/cariche.aspx?mode=popup" + complete_url;
                a_sospensioni.HRef = "~/sospensioni/sospensioni.aspx?mode=popup" + complete_url;
                a_sostituzioni.HRef = "~/sostituzioni/sostituzioni.aspx?mode=popup" + complete_url;
                a_missioni.HRef = "~/missioni/missioni.aspx?mode=popup" + complete_url;
                a_certificati.HRef = "~/certificati/certificati.aspx?mode=popup" + complete_url;
                a_aspettative.HRef = "~/aspettative/aspettative.aspx?mode=popup" + complete_url;
                a_risultati_elettorali.HRef = "~/risultati_elettorali/risultati_elettorali.aspx?mode=popup" + complete_url;
                a_pratiche.HRef = "~/pratiche/pratiche.aspx?mode=popup" + complete_url;
                a_trasparenza.HRef = "~/trasparenza/trasparenza.aspx?mode=popup" + complete_url;
                a_presenze_assenze.HRef = "~/presenze/presenze.aspx?mode=popup" + complete_url;
                a_varie.HRef = "~/varie/varie.aspx?mode=popup" + complete_url;
                a_incarichi_extra_istituzionali.HRef = "~/schede_incarichi/incarichi_extra_istituzionali_consigliere.aspx?mode=popup" + complete_url;
            }
            else
            {
                a_dettaglio.HRef = "~/persona/dettaglio.aspx?mode=normal" + complete_url;
                a_gruppi_politici.HRef = "~/gruppi_politici/gruppi_politici.aspx?mode=normal" + complete_url;
                a_cariche.HRef = "~/cariche/cariche.aspx?mode=normal" + complete_url;
                a_sospensioni.HRef = "~/sospensioni/sospensioni.aspx?mode=normal" + complete_url;
                a_sostituzioni.HRef = "~/sostituzioni/sostituzioni.aspx?mode=normal" + complete_url;
                a_missioni.HRef = "~/missioni/missioni.aspx?mode=normal" + complete_url;
                a_certificati.HRef = "~/certificati/certificati.aspx?mode=normal" + complete_url;
                a_aspettative.HRef = "~/aspettative/aspettative.aspx?mode=normal" + complete_url;
                a_risultati_elettorali.HRef = "~/risultati_elettorali/risultati_elettorali.aspx?mode=normal" + complete_url;
                a_pratiche.HRef = "~/pratiche/pratiche.aspx?mode=normal" + complete_url;
                a_trasparenza.HRef = "~/trasparenza/trasparenza.aspx?mode=normal" + complete_url;
                a_presenze_assenze.HRef = "~/presenze/presenze.aspx?mode=normal" + complete_url;
                a_varie.HRef = "~/varie/varie.aspx?mode=normal" + complete_url;
                a_incarichi_extra_istituzionali.HRef = "~/schede_incarichi/incarichi_extra_istituzionali_consigliere.aspx?mode=normal" + complete_url;
            }
        }
    }

    /// <summary>
    /// Verifica se assessore
    /// </summary>
    /// <returns>esito</returns>
    protected bool CheckIsAssessore()
    {
        if (id_persona != null && sel_leg_id != null)
        {
            var sb = new StringBuilder(@"SELECT pp.id_persona
                                    FROM persona AS pp
                                    INNER JOIN join_persona_organo_carica AS jpoc
                                    ON pp.id_persona = jpoc.id_persona
                                    INNER JOIN legislature AS ll
                                    ON jpoc.id_legislatura = ll.id_legislatura
                                    INNER JOIN organi AS oo
                                    ON jpoc.id_organo = oo.id_organo
                                    INNER JOIN cariche AS cc
                                    ON jpoc.id_carica = cc.id_carica
                                    WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                    AND jpoc.deleted = 0
                                    AND oo.deleted = 0
                                    AND oo.id_categoria_organo = 4 -- 'giunta regionale'
                                    AND LOWER(cc.nome_carica) like 'assessore%'
                                    AND ll.id_legislatura = @id_legislatura
                                    and pp.id_persona = @id_persona");

            sb.Replace("@id_persona", id_persona);
            sb.Replace("@id_legislatura", sel_leg_id);

            var rows = Utility.GetDataRows(sb.ToString());
            return (rows != null && rows.Count > 0);
        }
        else
        {
            return false;
        }
    }

    /// <summary>
    /// Verifica se consigliere
    /// </summary>
    /// <returns>esito</returns>
    protected bool CheckIsConsigliere()
    {
        /* Verifica se la persona è o è stato un consigliere */

        if (id_persona != null && sel_leg_id != null)
        {
            var sb = new StringBuilder(@"SELECT pp.id_persona
                                    FROM persona AS pp
                                    INNER JOIN join_persona_organo_carica AS jpoc
                                    ON pp.id_persona = jpoc.id_persona
                                    INNER JOIN legislature AS ll
                                    ON jpoc.id_legislatura = ll.id_legislatura
                                    INNER JOIN organi AS oo
                                    ON jpoc.id_organo = oo.id_organo
                                    INNER JOIN cariche AS cc
                                    ON jpoc.id_carica = cc.id_carica
                                    WHERE pp.deleted = 0 AND pp.chiuso = 0 
                                    AND jpoc.deleted = 0
                                    AND oo.deleted = 0
                                    AND cc.id_carica in (select id_carica 
                                                        from join_cariche_organi 
                                                        where id_organo in (select id_organo 
                                                                            from organi 
                                                                            where id_tipo_organo=1 
                                                                            and deleted=0) 
                                                        and deleted=0)
                                    AND ll.id_legislatura = @id_legislatura
                                    and pp.id_persona = @id_persona");

            sb.Replace("@id_persona", id_persona);
            sb.Replace("@id_legislatura", sel_leg_id);

            var rows = Utility.GetDataRows(sb.ToString());
            return (rows != null && rows.Count > 0);
        }
        else
        {
            return false;
        }
    }

}

/// <summary>
/// Enmerazione Tabs
/// </summary>
public enum EnumTabsPersona
{
    a_dettaglio,
    a_gruppi_politici,
    a_cariche,
    a_sospensioni,
    a_sostituzioni,
    a_missioni,
    a_certificati,
    a_aspettative,
    a_risultati_elettorali,
    a_pratiche,
    a_trasparenza,
    a_presenze_assenze,
    a_varie,
    a_incarichi_extra_istituzionali
}