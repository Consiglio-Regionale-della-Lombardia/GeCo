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
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using System;
using System.Collections;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione GridViewExport
/// </summary>
public class DetailsViewExport
{
    /// <summary>
    /// Metodo di conversione DetailsView in PDF
    /// </summary>
    /// <param name="DetailsView1">view di riferimento</param>
    public static void toPdf(DetailsView DetailsView1)
    {
        toPdf(DetailsView1, "dettagli");
    }

    /// <summary>
    /// Metodo di conversione DetailsView in PDF
    /// </summary>
    /// <param name="DetailsView1">view di riferimento</param>
    /// <param name="FileName">nome file</param>
    public static void toPdf(DetailsView DetailsView1, string FileName)
    {
        HttpContext.Current.Response.ContentType = "application/pdf";
        HttpContext.Current.Response.AddHeader("content-disposition", "attachment;filename=" + FileName + ".pdf");
        HttpContext.Current.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        PrepareControlForExport(DetailsView1);

        DetailsView1.AllowPaging = false;
        DetailsView1.GridLines = GridLines.Horizontal;
        DetailsView1.Font.Size = 7;
        DetailsView1.DataBind();

        for (int i = 0; i < DetailsView1.Rows.Count; i++)
        {
            DetailsView1.Rows[i].CssClass = "";
        }

        for (int i = 0; i < DetailsView1.PageCount; i++)
        {
            PrepareControlForExport(DetailsView1);
            DetailsView1.RenderControl(hw);
            hw.Write("<br /><br /><br />");
            DetailsView1.PageIndex = i + 1;
        }

        string file = sw.ToString();
        file = removeLastRow(file);

        StringReader sr = new StringReader(file);
        Document pdfDoc = new Document(PageSize.A4, 10f, 10f, 10f, 0f);
        HTMLWorker htmlparser = new HTMLWorker(pdfDoc);
        PdfWriter.GetInstance(pdfDoc, HttpContext.Current.Response.OutputStream);
        pdfDoc.Open();
        htmlparser.Parse(sr);
        pdfDoc.Close();

        HttpContext.Current.Response.Write(pdfDoc);
        HttpContext.Current.Response.End();
    }

    /// <summary>
    /// Metodo di conversione DetailsView in Excel
    /// </summary>
    /// <param name="DetailsView1">view di riferimento</param>
    public static void toXls(DetailsView DetailsView1)
    {
        toXls(DetailsView1, "dettagli");
    }

    /// <summary>
    /// Metodo di conversione DetailsView in Excel
    /// </summary>
    /// <param name="DetailsView1">view di riferiemnto</param>
    /// <param name="FileName">nome file</param>
    public static void toXls(DetailsView DetailsView1, string FileName)
    {
        HttpContext.Current.Response.Clear();
        HttpContext.Current.Response.Buffer = true;

        HttpContext.Current.Response.AddHeader("content-disposition", "attachment;filename=" + FileName + ".xls");
        HttpContext.Current.Response.Charset = "";
        HttpContext.Current.Response.ContentType = "application/vnd.ms-excel";
        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        DetailsView1.AllowPaging = true;
        DetailsView1.PagerSettings.Visible = false;
        DetailsView1.DataBind();

        for (int i = 0; i < DetailsView1.PageCount; i++)
        {
            PrepareControlForExport(DetailsView1);
            DetailsView1.RenderControl(hw);
            hw.Write("<br /><br /><br />");
            DetailsView1.PageIndex = i + 1;
        }

        string file = sw.ToString();
        file = removeLastRow(file);

        HttpContext.Current.Response.Output.Write(file);
        HttpContext.Current.Response.Flush();
        HttpContext.Current.Response.End();
    }

    /// <summary>
    /// Metodo di preparazione controllo
    /// </summary>
    /// <param name="control">controllo di riferimento</param>
    private static void PrepareControlForExport(Control control)
    {
        for (int i = 0; i < control.Controls.Count; i++)
        {
            Control current = control.Controls[i];

            if (current is LinkButton)
            {
                control.Controls.Remove(current);
                control.Controls.AddAt(i, new LiteralControl(Utility.StripHTML((current as LinkButton).Text)));
            }
            else if (current is ImageButton)
            {
                control.Controls.Remove(current);
                control.Controls.AddAt(i, new LiteralControl(Utility.StripHTML((current as ImageButton).AlternateText)));
            }
            else if (current is HyperLink)
            {
                control.Controls.Remove(current);
                control.Controls.AddAt(i, new LiteralControl(Utility.StripHTML((current as HyperLink).Text)));
            }
            else if (current is DropDownList)
            {
                control.Controls.Remove(current);
                control.Controls.AddAt(i, new LiteralControl(Utility.StripHTML((current as DropDownList).SelectedItem.Text)));
            }
            else if (current is CheckBox)
            {
                control.Controls.Remove(current);
                control.Controls.AddAt(i, new LiteralControl(Utility.StripHTML((current as CheckBox).Checked ? "Si" : "No")));
            }

            if (current.HasControls())
            {
                PrepareControlForExport(current);
            }
        }
    }

    /// <summary>
    /// Metodo per rimuovere ultima riga
    /// </summary>
    /// <param name="text">testo di riferimento</param>
    /// <returns>testo rimosso</returns>
    private static string removeLastRow(string text)
    {
        return text.Substring(0, text.LastIndexOf("<tr")) + "</table></div>";
    }


    /// <summary>
    /// Metodo per Stampare la tessera di un consigliere 
    /// </summary>
    /// <param name="response">output pagina</param>
    /// <param name="request">richiesta http</param>
    /// <param name="info_tessera">array informazioni scheda</param>    
    public static void StampaTesseraPDF_0(HttpResponse response, HttpRequest request, string[] info_tessera)
    {
        float TextSize_Title = 8;
        float TextSize_Header = 7;
        float TextSize_Normal = 6;

        // dimensioni della pagina (in cm)
        float PageSize_X = 12.3f;
        float PageSize_Y = 9;
        float inch_measure = 2.54f;
        float inch_point = 72;

        string cognome = info_tessera[0];
        string nome = info_tessera[1];
        string num_tessera = info_tessera[6];
        string foto = info_tessera[7];
        string legislatura = info_tessera[8];

        string filename = "tessera_" + cognome.Replace(" ", "").ToLower() + "_" + nome.Replace(" ", "").ToLower();

        string[] headers = new string[6];
        headers[0] = "Cognome :";
        headers[1] = "Nome :";
        headers[2] = "Nato a :";
        headers[3] = "Il :";
        headers[4] = "Residente a :";
        headers[5] = "Via :";

        string[] headers2 = new string[2];
        headers2[0] = "TESSERA N.";
        headers2[1] = "Rilasciata il :";

        string[] info_tessera2 = new string[2];
        info_tessera2[0] = num_tessera;
        info_tessera2[1] = DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString();

        iTextSharp.text.Image foto_image = null;

        if (foto != "no_foto")
        {
            string foto_file_path = request.PhysicalApplicationPath + "foto/" + foto;

            foto_image = iTextSharp.text.Image.GetInstance(new Uri(foto_file_path));
            foto_image.ScaleAbsolute(90, 90);
        }

        string logo_file_path = request.PhysicalApplicationPath + "img/LogoTessera.png";

        iTextSharp.text.Image logo_image = iTextSharp.text.Image.GetInstance(new Uri(logo_file_path));
        logo_image.ScaleAbsolute(115, 54);

        // Creates a PDF document
        Rectangle pagesize = new Rectangle((PageSize_X / inch_measure) * inch_point, (PageSize_Y / inch_measure) * inch_point);
        Document document = new Document(pagesize, 0, 0, 15, 5);

        iTextSharp.text.pdf.PdfPTable MainTable = new iTextSharp.text.pdf.PdfPTable(2);
        MainTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        Phrase string_empty = new Phrase("");
        PdfPCell cell_empty = new PdfPCell(string_empty);
        cell_empty.Border = PdfPCell.NO_BORDER;

        //FOGLIO 1
        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 15);

        MainTable.AddCell(cell_empty);

        PdfPCell cell_logo = new PdfPCell(logo_image);
        cell_logo.Border = PdfPCell.NO_BORDER;
        cell_logo.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_logo);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 20);

        MainTable.AddCell(cell_empty);

        Phrase string_legislatura = new Phrase(legislatura + " LEGISLATURA", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_legislatura = new PdfPCell(string_legislatura);
        cell_legislatura.Border = PdfPCell.NO_BORDER;
        cell_legislatura.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_legislatura);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 5);

        //FOGLIO 2
        //cella [0, 0]
        MainTable.AddCell(cell_empty);

        //cella [0, 1]
        Phrase string_title_consigliere = new Phrase("CONSIGLIERE REGIONALE", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_consigliere = new PdfPCell(string_title_consigliere);
        cell_title_consigliere.Border = PdfPCell.NO_BORDER;
        cell_title_consigliere.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_consigliere);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 1);

        //cella [2, 0]
        if (foto_image != null)
        {
            PdfPCell cell_foto = new PdfPCell(foto_image);
            cell_foto.Border = PdfPCell.NO_BORDER;
            cell_foto.HorizontalAlignment = Element.ALIGN_CENTER;

            //MainTable.AddCell(cell_empty);
            MainTable.AddCell(cell_foto);
        }
        else
        {
            MainTable.AddCell(cell_empty);
        }

        //cella [2, 1]
        PdfPTable table_anagrafica = Build_DataTable(headers, info_tessera, cell_empty);
        MainTable.AddCell(table_anagrafica);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella [3, 0]
        PdfPTable table_anagrafica2 = Build_DataTable(headers2, info_tessera2, cell_empty);
        MainTable.AddCell(table_anagrafica2);

        //cella [3, 1]
        MainTable.AddCell(cell_empty);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella [4, 0]
        Phrase string_title_firma_titolare = new Phrase("FIRMA DEL TITOLARE", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_firma_titolare = new PdfPCell(string_title_firma_titolare);
        cell_title_firma_titolare.Border = PdfPCell.NO_BORDER;
        cell_title_firma_titolare.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma_titolare);

        //cella [4, 1]
        Phrase string_title_firma_presidente = new Phrase("IL PRESIDENTE DEL CONSIGLIO", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_firma_presidente = new PdfPCell(string_title_firma_presidente);
        cell_title_firma_presidente.Border = PdfPCell.NO_BORDER;
        cell_title_firma_presidente.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma_presidente);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella firma titolare
        Phrase string_title_firma = new Phrase(".....................................", FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_title_firma = new PdfPCell(string_title_firma);
        cell_title_firma.Border = PdfPCell.NO_BORDER;
        cell_title_firma.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma);

        //cella firma presediente
        MainTable.AddCell(cell_title_firma);

        //chiudo la tabella
        MainTable.CompleteRow();

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, response.OutputStream);

        document.Open();
        document.Add(MainTable);
        document.Close();

        response.Charset = "text/html";
        response.ContentType = "application/pdf";
        response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        response.End();
    }

    /// <summary>
    /// Metodo per Stampare la tessera di un consigliere 
    /// </summary>
    /// <param name="response">output pagina</param>
    /// <param name="request">richiesta http</param>
    /// <param name="info_tessera">array informazioni scheda</param>    
    public static void StampaTesseraPDF_1(HttpResponse response, HttpRequest request, string[] info_tessera)
    {
        float TextSize_Title = 8;
        float TextSize_Normal = 6;

        // dimensioni della pagina (in cm)
        float PageSize_X = 12.5f;
        float PageSize_Y = 8.5f;
        float inch_measure = 2.54f;
        float inch_point = 72;

        string cognome = info_tessera[0];
        string nome = info_tessera[1];
        string num_tessera = info_tessera[6];
        string foto = info_tessera[7];
        string legislatura = info_tessera[8];

        string filename = "tessera_" + cognome.Replace(" ", "").ToLower() + "_" + nome.Replace(" ", "").ToLower();

        string[] headers = new string[6];
        headers[0] = "Cognome :";
        headers[1] = "Nome :";
        headers[2] = "Nato a :";
        headers[3] = "Il :";
        headers[4] = "Residente a :";
        headers[5] = "Via :";

        string[] headers2 = new string[2];
        headers2[0] = "TESSERA N.";
        headers2[1] = "Rilasciata il :";

        string[] info_tessera2 = new string[2];
        info_tessera2[0] = num_tessera;
        info_tessera2[1] = DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString();

        iTextSharp.text.Image foto_image = null;


        if (foto != "no_foto")
        {
            string foto_file_path = request.PhysicalApplicationPath + "foto/" + foto;

            foto_image = iTextSharp.text.Image.GetInstance(new Uri(foto_file_path));
            foto_image.ScaleAbsolute(90, 90);
        }

        Phrase s_new_line = new Phrase("\n");
        PdfPCell cell_new_line = new PdfPCell(s_new_line);
        cell_new_line.Border = PdfPCell.NO_BORDER;


        // Creates a PDF document
        Rectangle pagesize = new Rectangle((PageSize_X / inch_measure) * inch_point, (PageSize_Y / inch_measure) * inch_point);
        Document document = new Document(pagesize, 0, 0, 15, 5);

        iTextSharp.text.pdf.PdfPTable MainTable = new iTextSharp.text.pdf.PdfPTable(2);
        MainTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        Phrase string_empty = new Phrase("");
        PdfPCell cell_empty = new PdfPCell(string_empty);
        cell_empty.Border = PdfPCell.NO_BORDER;

        //FOGLIO 1
        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 15);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 20);


        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 5);

        //FOGLIO 2
        //cella [0, 0]
        MainTable.AddCell(cell_empty);

        //cella [0, 1]
        Phrase string_title_consigliere = new Phrase("CONSIGLIERE REGIONALE", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_consigliere = new PdfPCell(string_title_consigliere);
        cell_title_consigliere.Border = PdfPCell.NO_BORDER;
        cell_title_consigliere.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_consigliere);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 1);

        //cella [2, 0]
        if (foto_image != null)
        {
            PdfPCell cell_foto = new PdfPCell(foto_image);
            cell_foto.Border = PdfPCell.NO_BORDER;
            cell_foto.HorizontalAlignment = Element.ALIGN_CENTER;

            //MainTable.AddCell(cell_empty);
            MainTable.AddCell(cell_foto);
        }
        else
        {
            MainTable.AddCell(cell_empty);
        }

        //cella [2, 1]
        PdfPTable table_anagrafica = Build_DataTable(headers, info_tessera, cell_empty);
        MainTable.AddCell(table_anagrafica);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella [3, 0]
        PdfPTable table_anagrafica2 = Build_DataTable(headers2, info_tessera2, cell_empty);
        MainTable.AddCell(table_anagrafica2);

        //cella [3, 1]
        MainTable.AddCell(cell_empty);

        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella [4, 0]
        Phrase string_title_firma_titolare = new Phrase("FIRMA DEL TITOLARE", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_firma_titolare = new PdfPCell(string_title_firma_titolare);
        cell_title_firma_titolare.Border = PdfPCell.NO_BORDER;
        cell_title_firma_titolare.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma_titolare);

        //cella [4, 1]
        Phrase string_title_firma_presidente = new Phrase("IL PRESIDENTE DEL CONSIGLIO", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_firma_presidente = new PdfPCell(string_title_firma_presidente);
        cell_title_firma_presidente.Border = PdfPCell.NO_BORDER;
        cell_title_firma_presidente.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma_presidente);

        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella firma titolare
        Phrase string_title_firma = new Phrase("..........................................................................", FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_title_firma = new PdfPCell(string_title_firma);
        cell_title_firma.Border = PdfPCell.NO_BORDER;
        cell_title_firma.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma);

        //cella firma presediente
        MainTable.AddCell(cell_title_firma);

        //chiudo la tabella
        MainTable.CompleteRow();

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, response.OutputStream);

        document.Open();
        document.Add(MainTable);
        document.Close();

        response.Charset = "text/html";
        response.ContentType = "application/pdf";
        response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        response.End();
    }

    /// <summary>
    /// Metodo per Stampare la tessera di un consigliere 
    /// </summary>
    /// <param name="response">output pagina</param>
    /// <param name="request">richiesta http</param>
    /// <param name="info_tessera">array informazioni scheda</param>    
    public static void StampaTesseraPDF(HttpResponse response, HttpRequest request, string[] info_tessera)
    {
        bool border_show = false;

        float TextSize_Title = 8;
        float TextSize_Normal = 6;

        // dimensioni della pagina (in cm)
        float PageSize_X = 12.5f;
        float PageSize_Y = 8.5f;
        float inch_measure = 2.54f;
        float inch_point = 72;

        string cognome = info_tessera[0];
        string nome = info_tessera[1];
        string num_tessera = info_tessera[6];
        string foto = info_tessera[7];
        string legislatura = info_tessera[8];

        string filename = "tessera_" + cognome.Replace(" ", "").ToLower() + "_" + nome.Replace(" ", "").ToLower();

        string[] headers = new string[6];
        headers[0] = "Cognome :";
        headers[1] = "Nome :";
        headers[2] = "Nato a :";
        headers[3] = "Il :";
        headers[4] = "Residente a :";
        headers[5] = "Via :";

        string[] headers2 = new string[2];
        headers2[0] = "TESSERA N.";
        headers2[1] = "Rilasciata il :";

        string[] info_tessera2 = new string[2];
        info_tessera2[0] = num_tessera;
        info_tessera2[1] = DateTime.Now.Day.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Year.ToString();

        iTextSharp.text.Image foto_image = null;


        if (foto != "no_foto")
        {
            string foto_file_path = request.PhysicalApplicationPath + "foto/" + foto;

            foto_image = iTextSharp.text.Image.GetInstance(new Uri(foto_file_path));
            foto_image.ScaleAbsolute(90, 90);
        }

        Phrase s_new_line = new Phrase("\n");
        PdfPCell cell_new_line = new PdfPCell(s_new_line);
        if (!border_show) cell_new_line.Border = PdfPCell.NO_BORDER;


        // Creates a PDF document
        Rectangle pagesize = new Rectangle((PageSize_X / inch_measure) * inch_point, (PageSize_Y / inch_measure) * inch_point);
        Document document = new Document(pagesize, 0, 0, 15, 5);

        iTextSharp.text.pdf.PdfPTable MainTable = new iTextSharp.text.pdf.PdfPTable(3);
        float[] widths = new float[] { 40, 10, 50 };

        MainTable.SetWidths(widths);

        if (!border_show) MainTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        Phrase string_empty = new Phrase("");
        PdfPCell cell_empty = new PdfPCell(string_empty);
        if (!border_show) cell_empty.Border = PdfPCell.NO_BORDER;

        //FOGLIO 1
        //aggiungo degli spazi
        //AddNCellToTable(MainTable, cell_empty, 15);

        //aggiungo degli spazi
        //AddNCellToTable(MainTable, cell_empty, 20);


        //aggiungo degli spazi
        //AddNCellToTable(MainTable, cell_empty, 5);

        //FOGLIO 2
        //cella [0, 0]
        MainTable.AddCell(cell_empty);
        MainTable.AddCell(cell_empty);

        //cella [0, 1]
        Phrase string_title_consigliere = new Phrase("CONSIGLIERE REGIONALE", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_consigliere = new PdfPCell(string_title_consigliere);
        if (!border_show) cell_title_consigliere.Border = PdfPCell.NO_BORDER;
        cell_title_consigliere.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_consigliere);

        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);

        //aggiungo degli spazi
        //AddNCellToTable(MainTable, cell_empty, 1);

        //cella [2, 0]
        if (foto_image != null)
        {
            PdfPCell cell_foto = new PdfPCell(foto_image);
            if (!border_show) cell_foto.Border = PdfPCell.NO_BORDER;
            cell_foto.HorizontalAlignment = Element.ALIGN_CENTER;

            //MainTable.AddCell(cell_empty);
            MainTable.AddCell(cell_foto);
        }
        else
        {
            MainTable.AddCell(cell_empty);
        }

        MainTable.AddCell(cell_empty);

        //cella [2, 1]
        PdfPTable table_anagrafica = Build_DataTable(headers, info_tessera, cell_empty);
        MainTable.AddCell(table_anagrafica);

        //aggiungo degli spazi
        //AddNCellToTable(MainTable, cell_empty, 4);

        //cella [3, 0]
        PdfPTable table_anagrafica2 = Build_DataTable(headers2, info_tessera2, cell_empty);
        MainTable.AddCell(table_anagrafica2);

        //cella [3, 1]
        MainTable.AddCell(cell_empty);

        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);

        //aggiungo degli spazi
        AddNCellToTable(MainTable, cell_empty, 4);

        //cella [4, 0]
        Phrase string_title_firma_titolare = new Phrase("FIRMA DEL TITOLARE", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_firma_titolare = new PdfPCell(string_title_firma_titolare);
        if (!border_show) cell_title_firma_titolare.Border = PdfPCell.NO_BORDER;
        cell_title_firma_titolare.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma_titolare);

        MainTable.AddCell(cell_empty);

        //cella [4, 1]
        Phrase string_title_firma_presidente = new Phrase("IL PRESIDENTE DEL CONSIGLIO", FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title_firma_presidente = new PdfPCell(string_title_firma_presidente);
        if (!border_show) cell_title_firma_presidente.Border = PdfPCell.NO_BORDER;
        cell_title_firma_presidente.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma_presidente);

        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);
        MainTable.AddCell(cell_new_line);

        //aggiungo degli spazi
        //AddNCellToTable(MainTable, cell_empty, 4);

        //cella firma titolare
        Phrase string_title_firma = new Phrase("...........................................................", FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_title_firma = new PdfPCell(string_title_firma);
        if (!border_show) cell_title_firma.Border = PdfPCell.NO_BORDER;
        cell_title_firma.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_title_firma);

        MainTable.AddCell(cell_empty);

        //cella firma presediente
        MainTable.AddCell(cell_title_firma);

        //chiudo la tabella
        MainTable.CompleteRow();

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, response.OutputStream);

        document.Open();
        document.Add(MainTable);
        document.Close();

        response.Charset = "text/html";
        response.ContentType = "application/pdf";
        response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        response.End();
    }

    /// <summary>
    /// Metodo per creazione PdfPTable
    /// </summary>
    /// <param name="headers">intestazioni tabella</param>
    /// <param name="data">data di riferimento</param>
    /// <param name="cell_empty">cella vuota</param>
    /// <returns>PdfPTable</returns>
    public static PdfPTable Build_DataTable(string[] headers, string[] data, PdfPCell cell_empty)
    {
        float TextSize_Title = 8;
        float TextSize_Header = 7;
        float TextSize_Normal = 8;

        iTextSharp.text.pdf.PdfPTable TabellaAnagrafica = new iTextSharp.text.pdf.PdfPTable(2);
        TabellaAnagrafica.DefaultCell.Border = PdfPCell.NO_BORDER;

        for (int i = 0; i < headers.Length; i++)
        {
            Phrase cell_header_string = new Phrase(headers[i], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.NORMAL));
            PdfPCell cell_header = new PdfPCell(cell_header_string);
            cell_header.Border = PdfPCell.NO_BORDER;
            cell_header.HorizontalAlignment = Element.ALIGN_LEFT;

            Phrase cell_data_string = new Phrase(data[i], FontFactory.GetFont("Times New Roman", TextSize_Normal, iTextSharp.text.Font.NORMAL));
            PdfPCell cell_data = new PdfPCell(cell_data_string);
            cell_data.Border = PdfPCell.NO_BORDER;
            cell_data.HorizontalAlignment = Element.ALIGN_LEFT;

            TabellaAnagrafica.AddCell(cell_header);
            TabellaAnagrafica.AddCell(cell_data);

            TabellaAnagrafica.AddCell(cell_empty);
            TabellaAnagrafica.AddCell(cell_empty);
        }

        TabellaAnagrafica.CompleteRow();

        return TabellaAnagrafica;
    }

    /// <summary>
    /// Metodo per aggiungere N celle alla tabella
    /// </summary>
    /// <param name="table">table di riferimento</param>
    /// <param name="cell">cella di riferimento</param>
    /// <param name="number">numaro da aggiungere</param>
    public static void AddNCellToTable(PdfPTable table, PdfPCell cell, int number)
    {
        for (int i = 0; i < number; i++)
        {
            table.AddCell(cell);
            table.AddCell(cell);
        }
    }


    /// <summary>
    /// Metodo per Stampare la scheda degli incarichi extra istituzionali di un consigliere 
    /// </summary>
    /// <param name="p_response">output pagina</param>
    /// <param name="p_request">richiesta http</param>
    /// <param name="p_info_scheda">array informazioni scheda</param>
    /// <param name="p_info_incarichi">lista informazioni incarichi</param>
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

        int n_columns = trasparenza ? 5 : 4; //4; --2019-11-05 aggiunte 3 colone, nascosto riferimenti normativi

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
            cell_widths[1] = 120;
            cell_widths[2] = 120;
            cell_widths[3] = 190;
            //cell_widths[3] = 120;
            //cell_widths[4] = 120;
            //cell_widths[5] = 190;
            //cell_widths[6] = 190;
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

        if (!trasparenza)
        {
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
        }

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
    /// Metodo per generazone informazioni Scheda
    /// </summary>
    /// <param name="p_info_scheda">informazoni scheda</param>
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
    /// Metodo per generazone informazioni Incarichi
    /// </summary>
    /// <param name="p_incarichi">lista incarichi</param>
    /// <param name="p_table">tabella di riferimento</param>
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
                headers_incarico[1] = "DATA INIZIO";
                headers_incarico[2] = "DATA CESSAZIONE";
                headers_incarico[3] = "NOTE ISTRUTTORIE";
            }

            foreach (var header_incarico in headers_incarico)
            {
                Phrase phrase_header = new Phrase(header_incarico, FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
                PdfPCell cell_header = new PdfPCell(phrase_header);
                cell_header.HorizontalAlignment = Element.ALIGN_CENTER;
                p_table.AddCell(cell_header);
            }

            for (int i = 0; i < p_incarichi.Count; i++)
            {
                string[] incarico = (string[])p_incarichi[i];

                // FIELDS

                if (trasparenza)
                {
                    Phrase phrase_field_1 = new Phrase(incarico[0], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_1 = new PdfPCell(phrase_field_1);
                    cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER;
                    cell_field_1.HorizontalAlignment = Element.ALIGN_LEFT;

                    Phrase phrase_field_2 = new Phrase(incarico[5], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_2 = new PdfPCell(phrase_field_2);
                    cell_field_2.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_2.HorizontalAlignment = Element.ALIGN_RIGHT;

                    Phrase phrase_field_3 = new Phrase(incarico[4], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_3 = new PdfPCell(phrase_field_3);
                    cell_field_3.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_3.HorizontalAlignment = Element.ALIGN_RIGHT;

                    Phrase phrase_field_4 = new Phrase(incarico[2], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_4 = new PdfPCell(phrase_field_4);
                    cell_field_4.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_4.HorizontalAlignment = Element.ALIGN_RIGHT;

                    Phrase phrase_field_5 = new Phrase(incarico[6], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_5 = new PdfPCell(phrase_field_5);
                    cell_field_5.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_5.HorizontalAlignment = Element.ALIGN_LEFT;

                    if (i == p_incarichi.Count - 1)
                    {
                        cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_2.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_3.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_4.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_5.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    }

                    p_table.AddCell(cell_field_1);
                    p_table.AddCell(cell_field_2);
                    p_table.AddCell(cell_field_3);
                    p_table.AddCell(cell_field_4);
                    p_table.AddCell(cell_field_5);

                }
                else
                {

                    Phrase phrase_field_1 = new Phrase(incarico[0], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_1 = new PdfPCell(phrase_field_1);
                    cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER;
                    cell_field_1.HorizontalAlignment = Element.ALIGN_LEFT;

                    Phrase phrase_field_2 = new Phrase(incarico[4], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_2 = new PdfPCell(phrase_field_2);
                    cell_field_2.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_2.HorizontalAlignment = Element.ALIGN_RIGHT;

                    Phrase phrase_field_3 = new Phrase(incarico[2], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_3 = new PdfPCell(phrase_field_3);
                    cell_field_3.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_3.HorizontalAlignment = Element.ALIGN_RIGHT;

                    Phrase phrase_field_4 = new Phrase(incarico[3], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                    PdfPCell cell_field_4 = new PdfPCell(phrase_field_4);
                    cell_field_4.Border = PdfPCell.RIGHT_BORDER;
                    cell_field_4.HorizontalAlignment = Element.ALIGN_LEFT;

                    if (i == p_incarichi.Count - 1)
                    {
                        cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_2.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_3.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                        cell_field_4.Border = PdfPCell.RIGHT_BORDER | PdfPCell.BOTTOM_BORDER;
                    }

                    p_table.AddCell(cell_field_1);
                    p_table.AddCell(cell_field_2);
                    p_table.AddCell(cell_field_3);
                    p_table.AddCell(cell_field_4);

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
