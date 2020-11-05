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
using iTextSharp.text;
using iTextSharp.text.pdf;
using System;
using System.Collections;
using System.Web;

/// <summary>
/// Classe per la generazione on demand delle schede in PDF
/// </summary>
public class DetailsViewExport
{

    /// <summary>
    /// StampaSchedaPDF
    /// Stampa la scheda degli incarichi extra istituzionali di un consigliere
    /// </summary>
    /// <param name="p_response">output pagina</param>
    /// <param name="p_request">richiesta di riferimento</param>
    /// <param name="p_info_scheda">scheda di riferimento</param>
    /// <param name="p_info_incarichi">lista incarichi</param>
    /// <param name="trasparenza">flag trasparenza</param>
    public static void StampaSchedaPDF(HttpResponse p_response, HttpRequest p_request, string[] p_info_scheda, ArrayList p_info_incarichi, bool trasparenza)
    {
        // dimensioni del testo
        float TextSize_Title = 10;
        float TextSize_Normal = 10;

        string title = trasparenza ? "CARICHE/INCARICHI EXTRAISTITUZIONALI ( D.lgs 33/2013 – l.r. 3/2013)" : "INCARICHI EXTRA ISTITUZIONALI";

        string organo = trasparenza ? "" : p_info_scheda[0];
        string legislatura = p_info_scheda[1];
        string consigliere = p_info_scheda[2];
        string gruppo_consiliare = p_info_scheda[3];
        string data_proclamazione = p_info_scheda[4];
        string data_dichiarazione = p_info_scheda[5];
        string info_seduta = trasparenza ? "" : p_info_scheda[6];
        string indicazioni_gde = p_info_scheda[7];
        string indicazioni_seg = p_info_scheda[8];

        // nome del file
        string filename = (trasparenza ? "scheda_trasparenza_" : "scheda_") + data_dichiarazione.Replace("/", "_").ToLower() + "_" + consigliere.Replace(" ", "_").ToLower();

        // campi della scheda
        string[] headers_scheda = new string[p_info_scheda.Length];
        headers_scheda[0] = trasparenza ? "" : organo;
        headers_scheda[1] = "LEGISLATURA:";
        headers_scheda[2] = "CONSIGLIERE:";
        headers_scheda[3] = "GRUPPO CONSILIARE:";
        headers_scheda[4] = "DATA PROCLAMAZIONE:";
        headers_scheda[5] = "DICHIARAZIONE DEL:";
        headers_scheda[6] = trasparenza ? "" : "SEDUTA:";
        headers_scheda[7] = "INDICAZIONI GDE:";
        headers_scheda[8] = "INDICAZIONI SEGRETERIA:";

        // crea un documento A4, in formato landscape
        Document document = new Document(PageSize.A4.Rotate(), 5, 5, 5, 5);

        int n_columns = trasparenza ? 5 : 7; //4; --2019-11-05 aggiunte 3 colone, nascosto riferimenti normativi

        iTextSharp.text.pdf.PdfPTable MainTable = new iTextSharp.text.pdf.PdfPTable(n_columns);
        MainTable.DefaultCell.Border = PdfPCell.NO_BORDER;
        MainTable.WidthPercentage = 95;

        // ampiezza delle colonne
        float[] cell_widths = new float[n_columns];
        if (trasparenza)
        {
            cell_widths[0] = 380;
            cell_widths[1] = 120;
            cell_widths[2] = 120;
            cell_widths[3] = 120;
            cell_widths[4] = 380;
        }
        else
        {
            cell_widths[0] = 380;
            cell_widths[1] = 0;
            cell_widths[2] = 120;
            cell_widths[3] = 120;
            cell_widths[4] = 120;
            cell_widths[5] = 190;
            cell_widths[6] = 190;
        }

        MainTable.SetWidths(cell_widths);


        // template frase vuota
        Phrase phrase_empty = new Phrase("");

        // template cella vuota
        PdfPCell cell_empty = new PdfPCell(phrase_empty);
        cell_empty.Border = PdfPCell.NO_BORDER;

        // template riga vuota
        PdfPCell cell_empty_row = new PdfPCell(phrase_empty);
        cell_empty_row.Colspan = n_columns;
        cell_empty_row.Border = PdfPCell.NO_BORDER;

        // riga vuota
        MainTable.AddCell(cell_empty_row);

        //aggiunge il logo
        string logo_file_path = p_request.PhysicalApplicationPath + "img/LogoTessera.png";

        iTextSharp.text.Image logo_image = iTextSharp.text.Image.GetInstance(new Uri(logo_file_path));
        logo_image.ScalePercent(25);

        PdfPCell cell_logo = new PdfPCell(logo_image);
        cell_logo.Border = PdfPCell.NO_BORDER;
        cell_logo.HorizontalAlignment = Element.ALIGN_CENTER;
        cell_logo.Colspan = n_columns;
        MainTable.AddCell(cell_logo);

        // riga vuota
        MainTable.AddCell(cell_empty_row);

        // TITOLO
        Phrase phrase_title = new Phrase("\n\n\n\n\n\n\n\n\n\n\n\n" + title, FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title = new PdfPCell(phrase_title);
        cell_title.Colspan = n_columns;
        cell_title.Border = PdfPCell.NO_BORDER;
        cell_title.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title);

        // riga vuota
        MainTable.AddCell(cell_empty_row);
        MainTable.AddCell(cell_empty_row);

        // tabella degli header
        iTextSharp.text.pdf.PdfPTable table_info_scheda = BuildTable_InfoScheda_Upper(p_info_scheda, trasparenza);

        PdfPCell cell_info_scheda = new PdfPCell(table_info_scheda);
        cell_info_scheda.Colspan = n_columns;
        cell_info_scheda.Border = PdfPCell.NO_BORDER;
        cell_info_scheda.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_info_scheda);

        // riga vuota
        MainTable.AddCell(cell_empty_row);
        MainTable.AddCell(cell_empty_row);

        // LISTA INCARICHI
        BuildTable_Incarichi(p_info_incarichi, MainTable, n_columns, trasparenza);

        // riga vuota
        MainTable.AddCell(cell_empty_row);
        MainTable.AddCell(cell_empty_row);

        // INDICAZIONI GDE
        Phrase phrase_indicazioni_gde = new Phrase(headers_scheda[7], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_indicazioni_gde = new PdfPCell(phrase_indicazioni_gde);
        cell_indicazioni_gde.Colspan = n_columns;
        cell_indicazioni_gde.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_gde.HorizontalAlignment = Element.ALIGN_LEFT;

        MainTable.AddCell(cell_indicazioni_gde);

        Phrase phrase_indicazioni_gde_val = new Phrase(indicazioni_gde, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_indicazioni_gde_val = new PdfPCell(phrase_indicazioni_gde_val);
        cell_indicazioni_gde_val.Colspan = n_columns;
        cell_indicazioni_gde_val.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_gde_val.HorizontalAlignment = Element.ALIGN_LEFT;

        MainTable.AddCell(cell_indicazioni_gde_val);

        // riga vuota
        MainTable.AddCell(cell_empty_row);
        MainTable.AddCell(cell_empty_row);

        // INDICAZIONI SEGRETERIA
        Phrase phrase_indicazioni_segreteria = new Phrase(headers_scheda[8], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_indicazioni_segreteria = new PdfPCell(phrase_indicazioni_segreteria);
        cell_indicazioni_segreteria.Colspan = n_columns;
        cell_indicazioni_segreteria.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_segreteria.HorizontalAlignment = Element.ALIGN_LEFT;

        MainTable.AddCell(cell_indicazioni_segreteria);

        Phrase phrase_indicazioni_segreteria_val = new Phrase(indicazioni_seg, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_indicazioni_segreteria_val = new PdfPCell(phrase_indicazioni_segreteria_val);
        cell_indicazioni_segreteria_val.Colspan = n_columns;
        cell_indicazioni_segreteria_val.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_segreteria_val.HorizontalAlignment = Element.ALIGN_LEFT;

        MainTable.AddCell(cell_indicazioni_segreteria_val);

        // chiudo la tabella
        MainTable.CompleteRow();

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, p_response.OutputStream);

        // Creates a footer for the PDF document.
        Phrase date_footer = new Phrase(Utility.ConvertDateTimeToDateString(DateTime.Now) + " - Pagina ");
        //HeaderFooter pdfFooter = new HeaderFooter(date_footer, true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        //document.Footer = pdfFooter;

        document.Open();
        document.Add(MainTable);
        document.Close();

        p_response.Charset = "text/html";
        p_response.ContentType = "application/pdf";
        p_response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        p_response.End();
    }

    /// <summary>
    /// PdfPTable
    /// </summary>
    /// <param name="p_info_scheda">scheda di riferimento</param>
    /// <param name="trasparenza">flag trasparenza</param>
    /// <returns>PdfPTable</returns>
    public static PdfPTable BuildTable_InfoScheda_Upper(string[] p_info_scheda, bool trasparenza)
    {
        // dimensioni del testo
        float TextSize_Title = 10;
        float TextSize_Normal = 10;

        string organo = trasparenza ? "" : p_info_scheda[0];
        string legislatura = p_info_scheda[1];
        string consigliere = p_info_scheda[2];
        string gruppo_consiliare = p_info_scheda[3];
        string data_proclamazione = p_info_scheda[4];
        string data_dichiarazione = p_info_scheda[5];
        string info_seduta = trasparenza ? "" : p_info_scheda[6];

        // campi della scheda
        string[] headers_scheda = new string[p_info_scheda.Length];
        headers_scheda[0] = trasparenza ? "" : organo;
        headers_scheda[1] = "LEGISLATURA:";
        headers_scheda[2] = "CONSIGLIERE:";
        headers_scheda[3] = "GRUPPO CONSILIARE:";
        headers_scheda[4] = "DATA PROCLAMAZIONE:";
        headers_scheda[5] = "DICHIARAZIONE DEL:";
        headers_scheda[6] = trasparenza ? "" : "SEDUTA:";

        int n_columns = 2;

        iTextSharp.text.pdf.PdfPTable table_headers = new PdfPTable(n_columns);

        // template frase vuota
        Phrase phrase_empty = new Phrase("");

        // template cella vuota
        PdfPCell cell_empty = new PdfPCell(phrase_empty);
        cell_empty.Border = PdfPCell.NO_BORDER;

        // template riga vuota
        PdfPCell cell_empty_row = new PdfPCell(phrase_empty);
        cell_empty_row.Colspan = n_columns;
        cell_empty_row.Border = PdfPCell.NO_BORDER;

        // ------------ ORGANO ------------
        Phrase phrase_organo = new Phrase(organo, FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_organo = new PdfPCell(phrase_organo);
        cell_organo.Border = PdfPCell.NO_BORDER;
        cell_organo.HorizontalAlignment = Element.ALIGN_LEFT;

        table_headers.AddCell(cell_organo);
        //----------------------------------

        // ------------ LEGISLATURA ------------
        Chunk chunk_legislatura = new Chunk(headers_scheda[1], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        Chunk chunk_legislatura_val = new Chunk(legislatura, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));

        Phrase phrase_legislatura = new Phrase();
        phrase_legislatura.Add(chunk_legislatura);
        phrase_legislatura.Add("  ");
        phrase_legislatura.Add(chunk_legislatura_val);

        PdfPCell cell_legislatura = new PdfPCell(phrase_legislatura);
        cell_legislatura.Border = PdfPCell.NO_BORDER;
        cell_legislatura.HorizontalAlignment = Element.ALIGN_RIGHT;

        table_headers.AddCell(cell_legislatura);
        //----------------------------------

        //  riga vuota 
        table_headers.AddCell(cell_empty_row);
        table_headers.AddCell(cell_empty_row);

        // ------------ CONSIGLIERE ------------
        Chunk chunk_consigliere = new Chunk(headers_scheda[2], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        Chunk chunk_consigliere_val = new Chunk(consigliere, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));

        Phrase phrase_consigliere = new Phrase();
        phrase_consigliere.Add(chunk_consigliere);
        phrase_consigliere.Add("  ");
        phrase_consigliere.Add(chunk_consigliere_val);

        PdfPCell cell_consigliere = new PdfPCell(phrase_consigliere);
        cell_consigliere.Border = PdfPCell.NO_BORDER;
        cell_consigliere.HorizontalAlignment = Element.ALIGN_LEFT;

        table_headers.AddCell(cell_consigliere);
        //----------------------------------

        // ------------ GRUPPO CONSILIARE ------------
        Chunk chunk_gruppo_consiliare = new Chunk(headers_scheda[3], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        Chunk chunk_gruppo_consiliare_val = new Chunk(gruppo_consiliare, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));

        Phrase phrase_gruppo_consiliare = new Phrase();
        phrase_gruppo_consiliare.Add(chunk_gruppo_consiliare);
        phrase_gruppo_consiliare.Add("  ");
        phrase_gruppo_consiliare.Add(chunk_gruppo_consiliare_val);

        PdfPCell cell_gruppo_consiliare = new PdfPCell(phrase_gruppo_consiliare);
        cell_gruppo_consiliare.Border = PdfPCell.NO_BORDER;
        cell_gruppo_consiliare.HorizontalAlignment = Element.ALIGN_RIGHT;

        table_headers.AddCell(cell_gruppo_consiliare);
        //----------------------------------

        // riga vuota
        table_headers.AddCell(cell_empty_row);
        table_headers.AddCell(cell_empty_row);

        // ------------ DATA PROCLAMAZIONE ------------
        Chunk chunk_data_proclamazione = new Chunk(headers_scheda[4], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        Chunk chunk_data_proclamazione_val = new Chunk(data_proclamazione, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));

        Phrase phrase_data_proclamazione = new Phrase();
        phrase_data_proclamazione.Add(chunk_data_proclamazione);
        phrase_data_proclamazione.Add("  ");
        phrase_data_proclamazione.Add(chunk_data_proclamazione_val);

        PdfPCell cell_data_proclamazione = new PdfPCell(phrase_data_proclamazione);
        cell_data_proclamazione.Border = PdfPCell.NO_BORDER;
        cell_data_proclamazione.HorizontalAlignment = Element.ALIGN_LEFT;

        table_headers.AddCell(cell_data_proclamazione);
        //----------------------------------

        // ------------ DATA DICHIARAZIONE & INFO SEDUTA ------------
        Chunk chunk_data_dichiarazione = new Chunk(headers_scheda[5], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        Chunk chunk_data_dichiarazione_val = new Chunk(data_dichiarazione, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        Chunk chunk_seduta = new Chunk(headers_scheda[6], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        Chunk chunk_seduta_val = new Chunk(info_seduta, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));

        Phrase phrase_data_dichiarazione_seduta = new Phrase();
        phrase_data_dichiarazione_seduta.Add(chunk_data_dichiarazione);
        phrase_data_dichiarazione_seduta.Add("  ");
        phrase_data_dichiarazione_seduta.Add(chunk_data_dichiarazione_val);
        phrase_data_dichiarazione_seduta.Add("    ");
        phrase_data_dichiarazione_seduta.Add(chunk_seduta);
        phrase_data_dichiarazione_seduta.Add("  ");
        phrase_data_dichiarazione_seduta.Add(chunk_seduta_val);

        PdfPCell cell_data_dichiarazione_seduta = new PdfPCell(phrase_data_dichiarazione_seduta);
        cell_data_dichiarazione_seduta.Border = PdfPCell.NO_BORDER;
        cell_data_dichiarazione_seduta.HorizontalAlignment = Element.ALIGN_RIGHT;

        table_headers.AddCell(cell_data_dichiarazione_seduta);
        //----------------------------------

        return table_headers;
    }

    /// <summary>
    /// BuildTable_Incarichi
    /// </summary>
    /// <param name="p_incarichi">array incarichi</param>
    /// <param name="p_table">table di riferimento</param>
    /// <param name="p_n_columns">numero di colonne</param>
    /// <param name="trasparenza">flag trasparenza</param>
    public static void BuildTable_Incarichi(ArrayList p_incarichi, PdfPTable p_table, int p_n_columns, bool trasparenza)
    {
        float TextSize_Header = 10;
        float TextSize_Normal = 9;

        // template frase vuota
        Phrase phrase_empty = new Phrase("");

        // template cella vuota
        PdfPCell cell_empty = new PdfPCell(phrase_empty);
        cell_empty.Border = PdfPCell.NO_BORDER;

        // template riga vuota
        PdfPCell cell_empty_row = new PdfPCell(phrase_empty);
        cell_empty_row.Colspan = p_n_columns;
        cell_empty_row.Border = PdfPCell.NO_BORDER;

        if (p_incarichi.Count > 0)
        {
            // campi dell'incarico
            string[] headers_incarico = new string[p_n_columns];

            if (trasparenza)
            {
                headers_incarico[0] = "CARICHE, INCARICHI, UFFICI, PROFESSIONI, ECC.";
                headers_incarico[1] = "COMPENSO";
                headers_incarico[2] = "DATA INIZIO";
                headers_incarico[3] = "DATA CESSAZIONE";
                headers_incarico[4] = "NOTE TRASPARENZA";
            }
            else
            {
                headers_incarico[0] = "CARICHE, INCARICHI, UFFICI, PROFESSIONI, ECC.";
                headers_incarico[1] = "RIFERIMENTI NORMATIVI";
                headers_incarico[2] = "DATA INIZIO";
                headers_incarico[3] = "DATA CESSAZIONE";
                headers_incarico[4] = "COMPENSO";
                headers_incarico[5] = "NOTE ISTRUTTORIE";
                headers_incarico[6] = "NOTE TRASPARENZA";
            }


            // HEADERS
            //Phrase phrase_header_1 = new Phrase(headers_incarico[0], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            //PdfPCell cell_header_1 = new PdfPCell(phrase_header_1);
            //cell_header_1.HorizontalAlignment = Element.ALIGN_CENTER;

            //Phrase phrase_header_2 = new Phrase(headers_incarico[1], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            //PdfPCell cell_header_2 = new PdfPCell(phrase_header_2);
            //cell_header_2.HorizontalAlignment = Element.ALIGN_CENTER;

            //Phrase phrase_header_3 = new Phrase(headers_incarico[2], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            //PdfPCell cell_header_3 = new PdfPCell(phrase_header_3);
            //cell_header_3.HorizontalAlignment = Element.ALIGN_CENTER;

            //Phrase phrase_header_4 = new Phrase(headers_incarico[3], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            //PdfPCell cell_header_4 = new PdfPCell(phrase_header_4);
            //cell_header_4.HorizontalAlignment = Element.ALIGN_CENTER;

            //p_table.AddCell(cell_header_1);
            //p_table.AddCell(cell_header_2);
            //p_table.AddCell(cell_header_3);
            //p_table.AddCell(cell_header_4);

            foreach (var header_incarico in headers_incarico)
            {
                Phrase phrase_header = new Phrase(header_incarico, FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
                PdfPCell cell_header = new PdfPCell(phrase_header);
                cell_header.HorizontalAlignment = Element.ALIGN_CENTER;
                p_table.AddCell(cell_header);
            }


            /*
                 ii.id_incarico, 
               0 ii.nome_incarico,
               1 ii.riferimenti_normativi,
               2 ii.data_cessazione,
               3 ii.note_istruttorie,
               4 ii.data_inizio,
               5 ii.compenso,
               6 ii.note_trasparenza

                headers_incarico[0] = "CARICHE, INCARICHI, UFFICI, PROFESSIONI, ECC."; 0
                headers_incarico[1] = "COMPENSO"; 5
                headers_incarico[2] = "DATA INIZIO"; 4
                headers_incarico[3] = "DATA CESSAZIONE"; 2
                headers_incarico[4] = "NOTE TRASPARENZA"; 6
             */

            for (int i = 0; i < p_incarichi.Count; i++)
            {
                string[] incarico = (string[])p_incarichi[i];

                // FIELDS
                Phrase phrase_field_1 = new Phrase(incarico[0], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_1 = new PdfPCell(phrase_field_1);
                cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER;
                cell_field_1.HorizontalAlignment = Element.ALIGN_LEFT;

                Phrase phrase_field_2 = new Phrase(trasparenza ? incarico[5] : incarico[1], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_2 = new PdfPCell(phrase_field_2);
                cell_field_2.Border = PdfPCell.RIGHT_BORDER;
                cell_field_2.HorizontalAlignment = Element.ALIGN_LEFT;

                Phrase phrase_field_3 = new Phrase(trasparenza ? incarico[4] : incarico[2], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_3 = new PdfPCell(phrase_field_3);
                cell_field_3.Border = PdfPCell.RIGHT_BORDER;
                cell_field_3.HorizontalAlignment = Element.ALIGN_LEFT;

                Phrase phrase_field_4 = new Phrase(trasparenza ? incarico[2] : incarico[3], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_4 = new PdfPCell(phrase_field_4);
                cell_field_4.Border = PdfPCell.RIGHT_BORDER;
                cell_field_4.HorizontalAlignment = Element.ALIGN_LEFT;

                Phrase phrase_field_5 = new Phrase(trasparenza ? incarico[6] : incarico[4], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_5 = new PdfPCell(phrase_field_5);
                cell_field_5.Border = PdfPCell.RIGHT_BORDER;
                cell_field_5.HorizontalAlignment = Element.ALIGN_LEFT;

                PdfPCell cell_field_6 = null;
                PdfPCell cell_field_7 = null;

                if (!trasparenza)
                {
                    Phrase phrase_field_6 = new Phrase(incarico[5], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    cell_field_6 = new PdfPCell(phrase_field_6);
                    cell_field_6.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_6.HorizontalAlignment = Element.ALIGN_LEFT;

                    Phrase phrase_field_7 = new Phrase(incarico[6], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    cell_field_7 = new PdfPCell(phrase_field_7);
                    cell_field_7.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_7.HorizontalAlignment = Element.ALIGN_LEFT;
                }

                if (i == p_incarichi.Count - 1)
                {
                    cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    cell_field_2.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    cell_field_3.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    cell_field_4.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    cell_field_5.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;

                    if (!trasparenza)
                    {
                        cell_field_6.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_7.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    }
                }

                p_table.AddCell(cell_field_1);
                p_table.AddCell(cell_field_2);
                p_table.AddCell(cell_field_3);
                p_table.AddCell(cell_field_4);
                p_table.AddCell(cell_field_5);

                if (!trasparenza)
                {
                    p_table.AddCell(cell_field_6);
                    p_table.AddCell(cell_field_7);
                }
            }
        }
        else
        {
            // riga vuota
            p_table.AddCell(cell_empty_row);

            Phrase phrase_empty_table = new Phrase("Nessun incarico associato alla scheda", FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            PdfPCell cell_empty_table = new PdfPCell(phrase_empty_table);
            cell_empty_table.Colspan = p_n_columns;
            cell_empty_table.Border = PdfPCell.NO_BORDER;
            cell_empty_table.HorizontalAlignment = Element.ALIGN_CENTER;

            p_table.AddCell(cell_empty_table);

            // riga vuota
            p_table.AddCell(cell_empty_row);
        }
    }

}
