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
using iTextSharp.tool.xml;
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Classe per la gestione GridViewExport
/// </summary>
public class GridViewExport
{

    /// <summary>
    /// Per gestire gli header dei report in cui non deve più comparire la DIARIA da luglio 2013 
    /// </summary>    
    public static string header_opzione_si = "";
    public static string header_opzione_no = "";


    public static string conn_string = ConfigurationManager.ConnectionStrings["GestioneConsiglieriConnectionString"].ConnectionString;

    /// <summary>
    /// Metodo di conversione GridView to PDF
    /// </summary>
    /// <param name="GridView1">grid di riferimento</param>
    public static void toPdf(GridView GridView1)
    {
        toPdf(GridView1, "risultati");
    }

    /// <summary>
    /// Metodo di conversione GridView to PDF
    /// </summary>
    /// <param name="GridView1">grid di riferimento</param>
    /// <param name="FileName">nome file</param>
    public static void toPdf(GridView GridView1, string FileName)
    {
        if (GridView1.Rows.Count == 0)
        {
            HttpContext.Current.Session.Contents.Add("error_message", "L'elemento da esportare è vuoto.");
            HttpContext.Current.Response.Redirect("../errore.aspx");
            return;
        }

        HttpContext.Current.Response.ContentType = "application/pdf";
        HttpContext.Current.Response.AddHeader("content-disposition", "attachment;filename=" + FileName + ".pdf");
        HttpContext.Current.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        //GridView1.AllowPaging = false;
        //GridView1.AllowSorting = false;
        //GridView1.DataBind();

        // Se la grid contiene la colonna dettagli, la nasconde
        if (GridView1.Rows.Count > 1)
        {
            GridViewRow row = GridView1.Rows[1];
            HyperLink hh = row.FindControl("HyperLinkDettagli") as HyperLink;

            if (hh != null)
            {
                GridView1.Columns[GridView1.Columns.Count - 1].Visible = false;
            }
        }

        PrepareControlForExport(GridView1);

        GridView1.Font.Size = 7;

        //Apply style to Header Row
        GridView1.HeaderStyle.BackColor = System.Drawing.Color.DarkCyan;
        GridView1.HeaderStyle.ForeColor = System.Drawing.Color.White;

        for (int i = 0; i < GridView1.Rows.Count; i++)
        {
            GridViewRow row = GridView1.Rows[i];

            //Apply style to Alternating Row
            if (i % 2 != 0)
            {
                row.BackColor = System.Drawing.Color.Lavender;
            }
        }

        GridView1.RenderControl(hw);

        string file = sw.ToString();
        file = file.Replace("<div>", string.Empty);
        file = file.Replace("</div>", string.Empty);

        StringReader sr = new StringReader(file);
        Document pdfDoc = new Document(PageSize.A4, 10f, 10f, 10f, 0f);

        // Se ha tante colonne, ruota la pagina
        if (GridView1.Columns.Count > 10)
        {
            pdfDoc = new Document(PageSize.A4.Rotate(), 10f, 10f, 10f, 0f);
        }

        HTMLWorker htmlparser = new HTMLWorker(pdfDoc);
        PdfWriter.GetInstance(pdfDoc, HttpContext.Current.Response.OutputStream);
        pdfDoc.Open();
        htmlparser.Parse(sr);
        pdfDoc.Close();

        HttpContext.Current.Response.Write(pdfDoc);
        HttpContext.Current.Response.End();
    }

    /// <summary>
    /// Metodo di conversione GridView to EXCEL
    /// </summary>
    /// <param name="GridView1">grid di riferimento</param>
    public static void toXls(GridView GridView1)
    {
        toXls(GridView1, "risultati");
    }

    /// <summary>
    /// Metodo di conversione GridView to EXCEL
    /// </summary>
    /// <param name="GridView1">grid di riferimento</param>
    /// <param name="FileName">nome file</param>
    public static void toXls(GridView GridView1, string FileName)
    {
        if (GridView1.Rows.Count == 0)
        {
            HttpContext.Current.Session.Contents.Add("error_message", "L'elemento da esportare è vuoto.");
            HttpContext.Current.Response.Redirect("../errore.aspx");
            return;
        }

        HttpContext.Current.Response.Clear();
        HttpContext.Current.Response.Buffer = true;

        HttpContext.Current.Response.AddHeader("content-disposition", "attachment;filename=" + FileName + ".xls");
        HttpContext.Current.Response.Charset = "";
        HttpContext.Current.Response.ContentType = "application/vnd.ms-excel";
        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        //GridView1.AllowPaging = false;
        //GridView1.AllowSorting = false;
        //GridView1.DataBind();

        // Se la grid contiene la colonna dettagli, la nasconde
        if (GridView1.Rows.Count > 1)
        {
            GridViewRow row = GridView1.Rows[1];
            HyperLink hh = row.FindControl("HyperLinkDettagli") as HyperLink;

            if (hh != null)
            {
                GridView1.Columns[GridView1.Columns.Count - 1].Visible = false;
            }
        }

        for (int i = 0; i < GridView1.Columns.Count; i++)
        {
            GridView1.Columns[i].ItemStyle.Width = 100;
        }

        PrepareControlForExport(GridView1);

        //Apply style to Header Row
        GridView1.HeaderStyle.BackColor = System.Drawing.Color.DarkCyan;
        GridView1.HeaderStyle.ForeColor = System.Drawing.Color.White;

        for (int i = 0; i < GridView1.Rows.Count; i++)
        {
            GridViewRow row = GridView1.Rows[i];

            //Apply style to Alternating Row
            if (i % 2 != 0)
            {
                row.BackColor = System.Drawing.Color.Lavender;
            }
        }

        GridView1.RenderControl(hw);

        string file = sw.ToString();

        HttpContext.Current.Response.Output.Write(file);
        HttpContext.Current.Response.Flush();
        HttpContext.Current.Response.End();
    }

    /// <summary>
    /// Metodo per preparzione Controllo per export
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
    /// Metodo per esportazione di gridview in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="no_first_col">flag se prima colonna</param>
    /// <param name="no_last_col">flag se ultima colonna</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="filter_param">parametri filtri</param>
    public static void ExportToExcel(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] filter_param)
    {
        ExportToExcel(Response, gvReport, id_user, tab_place, title, no_first_col, no_last_col, LandScape, filename, filter_param, true);
    }

    /// <summary>
    /// Metodo per esportazione di gridview in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="no_first_col">flag se prima colonna</param>
    /// <param name="no_last_col">flag se ultima colonna</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="filter_param">parametri filtri</param>
    /// <param name="databind">flag se databind</param>
    public static void ExportToExcel(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] filter_param, bool databind)
    {
        int ncolumns = 0, start = 0;

        string user = GetUserName(id_user);

        Response.Clear();
        Response.Buffer = true;

        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "text/html";
        Response.ContentType = "application/vnd.ms-excel";

        Response.ContentEncoding = Encoding.GetEncoding("Windows-1252");

        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        // costruisco la gridview per l'header
        int ind_filter_header = 6;
        int ind_filter = 0;
        string[] cells = new string[10 + filter_param.Length];
        cells[0] = Utility.ConvertDateTimeToDateString(DateTime.Now);
        cells[1] = title;
        cells[2] = "Richiedente:";
        cells[3] = user;
        cells[4] = "Menu:";
        cells[5] = tab_place;

        if (filter_param.Length >= 2)
        {
            cells[6] = "Filtri:";
            cells[7] = "";
            ind_filter_header = ind_filter_header + 2;
        }

        while (ind_filter < filter_param.Length - 1)
        {
            cells[ind_filter_header] = filter_param[ind_filter] + ":";
            cells[ind_filter_header + 1] = filter_param[ind_filter + 1];

            ind_filter = ind_filter + 2;
            ind_filter_header = ind_filter_header + 2;
        }

        DataTable table = Utility.CreateDataTable(2);
        Utility.AddDataToTable(table, cells);

        GridView gvHeader = new GridView();
        gvHeader.DataSource = table;
        gvHeader.DataBind();

        // gestisco il layout dell'header
        gvHeader.GridLines = GridLines.None;
        gvHeader.HeaderRow.Visible = false;
        gvHeader.Rows[0].Font.Bold = true;
        gvHeader.Rows[3].Font.Bold = true;
        for (int i = 0; i < gvHeader.Rows.Count; i++)
        {
            gvHeader.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            //gvHeader.Rows[i].VerticalAlign = VerticalAlign.Middle;
            gvHeader.Rows[i].Style.Add("vertical-align", "middle");

            var cnum = gvHeader.Rows[i].Cells.Count;
            for (int j = 0; j < cnum; j++)
            {
                gvHeader.Rows[i].Cells[j].Wrap = false;
            }
        }

        // costruisco la gridview del report vero e proprio
        gvReport.AllowPaging = false;

        if (databind)
            gvReport.DataBind();

        ncolumns = gvReport.Columns.Count;

        if (no_last_col)
        {
            ncolumns = ncolumns - 1;
            gvReport.Columns[ncolumns].Visible = false;
        }

        if (no_first_col)
        {
            gvReport.Columns[0].Visible = false;
            start = 1;
        }

        int decColumns = 0;

        // cambio il back-color degli headers a bianco
        gvReport.HeaderRow.Style.Add("background-color", "#FFFFFF");

        //applico lo stile agli header singolarmente      
        for (int i = start; i < ncolumns; i++)
        {
            try
            {
                //gvReport.HeaderRow.Cells[i].TemplateControl.            
                gvReport.HeaderRow.Cells[i].Style.Add("border-style", "solid");
                gvReport.HeaderRow.Cells[i].Style.Add("border-width", "thin");
                gvReport.HeaderRow.Cells[i].Style.Add("text-font", "bold");
                gvReport.HeaderRow.Cells[i].Text = Convert.ToString(gvReport.Columns[i].HeaderText);
                gvReport.HeaderRow.Cells[i].Wrap = false;
            }
            catch (Exception e)
            {
                decColumns++;
            }
        }

        ncolumns = ncolumns - decColumns;

        GridViewRow row;


        string s = "";
        string type;

        for (int i = 0; i < gvReport.Rows.Count; i++)
        {
            //gvReport.Rows[i].Font.Bold = false;
            row = gvReport.Rows[i];
            row.Font.Bold = false;

            for (int j = start; j < ncolumns; j++)
            {
                s = "";

                // cambio il back-color a bianco
                row.BackColor = System.Drawing.Color.White;

                // applico lo stile ad ogni cella 
                row.Attributes.Add("class", "textmode");

                // applico lo stile alla cella
                row.Cells[j].Font.Bold = false;
                //row.Cells[j].VerticalAlign = VerticalAlign.Middle;

                row.Cells[j].Style.Add("border-style", "solid");
                row.Cells[j].Style.Add("border-width", "thin");
                //row.Cells[j].Style.Add("font-bold", "false");
                //row.Cells[j].Style.Add("text-font", "normal");
                //row.Cells[j].Style.Add("text-align", "center");
                row.Cells[j].Style.Add("vertical-align", "middle");

                if (gvReport.Columns[j] is TemplateField)
                {
                    type = row.Cells[j].Controls[1].GetType().ToString();

                    switch (type)
                    {
                        case "System.Web.UI.WebControls.LinkButton":
                            LinkButton lb = row.Cells[j].Controls[1] as LinkButton;
                            s = lb.Text.Trim();
                            break;

                        case "System.Web.UI.WebControls.HyperLink":
                            HyperLink hl = row.Cells[j].Controls[1] as HyperLink;
                            s = hl.Text.Trim();
                            break;

                        case "System.Web.UI.WebControls.CheckBoxField":
                            CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                            if (chk.Checked)
                                s = "Si";
                            else
                                s = "No";
                            break;

                        case "System.Web.UI.WebControls.RadioButton":
                            RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                            if (rdb.Checked)
                                s = "Si";
                            break;

                        case "System.Web.UI.WebControls.Label":
                            Label lbl = row.Cells[j].Controls[1] as Label;
                            s = lbl.Text;
                            break;

                        default:
                            break;
                    }
                }
                else
                {
                    type = gvReport.Columns[j].GetType().ToString();

                    switch (type)
                    {
                        case "System.Web.UI.WebControls.CheckBoxField":
                            CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                            if (chk.Checked)
                                s = "Si";
                            else
                                s = "No";
                            break;

                        case "System.Web.UI.WebControls.RadioButton":
                            RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                            if (rdb.Checked)
                                s = "Si";
                            break;

                        default:
                            s = row.Cells[j].Text.Trim();
                            if (s == "&nbsp;")
                                s = "";
                            break;
                    }
                }

                row.Cells[j].Text = s;
            }
        }

        gvHeader.RenderControl(hw);
        gvReport.RenderControl(hw);

        //style to format numbers to string
        string style = @"<style> .textmode { mso-number-format:\@; } </style>";
        Response.Write(style);
        Response.Output.Write(sw.ToString());
        Response.Flush();
        Response.End();
    }

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="no_first_col">flag se prima colonna</param>
    /// <param name="no_last_col">flag se ultima colonna</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="filter_param">parametri filtri</param>
    public static void ExportToPDF(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] filter_param)
    {
        ExportToPDF(Response, gvReport, id_user, tab_place, title, no_first_col, no_last_col, LandScape, filename, filter_param, true);
    }

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="no_first_col">flag se prima colonna</param>
    /// <param name="no_last_col">flag se ultima colonna</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="filter_param">parametri filtri</param>
    /// <param name="databind">flag se databind</param>
    public static void ExportToPDF(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] filter_param, bool databind)
    {
        string charset = "ISO-8859-1";

        float HeaderTextSize = 9;
        float ReportNameSize = 10;
        float ReportTextSize = 8;
        float ApplicationNameSize = 7;

        int noOfColumns = 0, noOfRows = 0;
        DataTable tbl = null;

        string user = GetUserName(id_user);

        gvReport.AllowPaging = false;

        if (databind)
            gvReport.DataBind();

        if (gvReport.AutoGenerateColumns)
        {
            tbl = gvReport.DataSource as DataTable; // Gets the DataSource of the GridView Control.

            if (no_last_col)
                noOfColumns = tbl.Columns.Count - 1;
            else
                noOfColumns = tbl.Columns.Count;

            noOfRows = tbl.Rows.Count;
        }
        else
        {
            if (no_last_col)
                noOfColumns = gvReport.Columns.Count - 1;
            else
                noOfColumns = gvReport.Columns.Count;

            noOfRows = gvReport.Rows.Count;
        }

        int start = 0;

        if (no_first_col)
        {
            start = 1;
        }

        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0, 0, 15, 5);
        }
        else
        {
            document = new Document(PageSize.A4, 0, 0, 15, 5);
        }

        iTextSharp.text.pdf.PdfPTable mainTable;

        // Creates a PdfPTable with column count of the table equal to no of columns of the gridview or gridview datasource.
        if (no_first_col)
            mainTable = new iTextSharp.text.pdf.PdfPTable(noOfColumns - 1);
        else
            mainTable = new iTextSharp.text.pdf.PdfPTable(noOfColumns);

        // Sets the first 4 rows of the table as the header rows which will be repeated in all the pages.
        //mainTable.HeaderRows = 4;

        // Creates a PdfPTable with 1 column to hold the header in the exported PDF.
        iTextSharp.text.pdf.PdfPTable headerTable = new iTextSharp.text.pdf.PdfPTable(1);

        // cella contenente la data ed il titolo
        Phrase phDate = new Phrase(DateTime.Now.Date.ToString("dd/MM/yyyy") + " - " + title, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clDate = new PdfPCell(phDate);
        clDate.HorizontalAlignment = Element.ALIGN_LEFT;
        clDate.Border = PdfPCell.NO_BORDER;

        // cella contenente il nome del richiedente
        Phrase phUser = new Phrase("Richiedente: " + user, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clUser = new PdfPCell(phUser);
        clUser.Border = PdfPCell.NO_BORDER;
        clUser.HorizontalAlignment = Element.ALIGN_LEFT;

        // cella contenente la tab da dove si è richiesta l'esportazione
        Phrase phTab = new Phrase("Menù: " + tab_place, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clTab = new PdfPCell(phTab);
        clTab.Border = PdfPCell.NO_BORDER;
        clTab.HorizontalAlignment = Element.ALIGN_LEFT;

        // aggiunge le celle alla tabella dell'header
        headerTable.AddCell(clDate);
        headerTable.AddCell(clUser);
        headerTable.AddCell(clTab);

        // cella contenente la voce Filtri
        if (filter_param.Length >= 2)
        {
            Phrase phFiltri = new Phrase("Filtri:", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell clFiltri = new PdfPCell(phFiltri);
            clFiltri.Border = PdfPCell.NO_BORDER;
            clFiltri.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFiltri);
        }

        Phrase phFilterCell;
        PdfPCell clFilterCell;
        int ind = 0;
        while (ind < filter_param.Length - 1)
        {
            phFilterCell = new Phrase("  " + filter_param[ind] + ": " + filter_param[ind + 1], FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
            clFilterCell = new PdfPCell(phFilterCell);
            clFilterCell.Border = PdfPCell.NO_BORDER;
            clFilterCell.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFilterCell);

            ind = ind + 2;
        }

        // Sets the border of the headerTable to zero.
        headerTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellHeader = new PdfPCell(headerTable);
        cellHeader.Border = PdfPCell.NO_BORDER;

        // Sets the column span of the header cell to noOfColumns.
        if (no_first_col)
            cellHeader.Colspan = noOfColumns - 1;
        else
            cellHeader.Colspan = noOfColumns;

        // Adds the above header cell to the table.
        mainTable.AddCell(cellHeader);

        // cella per separare l'header dalla tabella
        Phrase phSeparator = new Phrase("_____________________________________________________________________");
        PdfPCell clSeparator = new PdfPCell(phSeparator);
        clSeparator.Border = PdfPCell.NO_BORDER;
        if (no_first_col)
            clSeparator.Colspan = noOfColumns - 1;
        else
            clSeparator.Colspan = noOfColumns;
        clSeparator.HorizontalAlignment = Element.ALIGN_CENTER;
        mainTable.AddCell(clSeparator);

        // cella per andare a capo
        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        if (no_first_col)
            clSpace.Colspan = noOfColumns - 1;
        else
            clSpace.Colspan = noOfColumns;
        mainTable.AddCell(clSpace);

        // Sets the gridview column names as table headers.
        for (int i = start; i < noOfColumns; i++)
        {
            Phrase ph = null;
            PdfPCell phcell = null;

            if (gvReport.AutoGenerateColumns)
            {
                ph = new Phrase(tbl.Columns[i].ColumnName, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            }
            else
            {
                ph = new Phrase(gvReport.Columns[i].HeaderText, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            }

            phcell = new PdfPCell(ph);
            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
            phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
            mainTable.AddCell(phcell);
        }

        string s = "";
        string type = "";
        string hAlign = "";

        // Reads the gridview rows and adds them to the mainTable
        for (int rowNo = 0; rowNo < noOfRows; rowNo++)
        {
            for (int columnNo = start; columnNo < noOfColumns; columnNo++)
            {
                hAlign = gvReport.Columns[columnNo].ItemStyle.HorizontalAlign.ToString();
                hAlign = hAlign.ToLower();

                if (gvReport.AutoGenerateColumns)
                {
                    s = gvReport.Rows[rowNo].Cells[columnNo].Text.Trim();
                }
                else
                {
                    if (gvReport.Columns[columnNo] is TemplateField)
                    {
                        if (gvReport.Rows[rowNo].Cells[columnNo].Controls.Count == 0)
                            type = "";
                        else
                            type = gvReport.Rows[rowNo].Cells[columnNo].Controls[1].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.LinkButton":
                                LinkButton lb = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as LinkButton;
                                s = lb.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.HyperLink":
                                HyperLink hl = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as HyperLink;
                                s = hl.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            case "System.Web.UI.WebControls.Label":
                                Label lbl = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as Label;
                                s = lbl.Text.Replace("<br />", "\n");
                                break;

                            default:
                                break;
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[columnNo].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            default:
                                s = gvReport.Rows[rowNo].Cells[columnNo].Text.Trim();
                                if (s == "&nbsp;")
                                    s = "";
                                break;
                        }
                    }
                }

                //s = s.Replace("&#224;", "à");

                s = System.Web.HttpUtility.HtmlDecode(s);

                Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                PdfPCell phcell = new PdfPCell(ph);

                switch (hAlign)
                {
                    case "center":
                        phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                        break;
                    case "right":
                        phcell.HorizontalAlignment = Element.ALIGN_RIGHT;
                        break;
                    default:
                        phcell.HorizontalAlignment = Element.ALIGN_LEFT;
                        break;
                }

                phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
                mainTable.AddCell(phcell);
            }

            // Tells the mainTable to complete the row even if any cell is left incomplete.
            mainTable.CompleteRow();
        }

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        //HeaderFooter pdfFooter = new HeaderFooter(new Phrase(), true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        // Sets the document footer to pdfFooter.
        //document.Footer = pdfFooter;
        // Opens the document.
        document.Open();
        // Adds the mainTable to the document.
        document.Add(mainTable);
        // Closes the document.
        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();
    }


    /// <summary>
    /// Metodo per esportazione di gridview in Excel
    /// esportazione di gridview in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="filters">filtri</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    public static void ExportReportToExcel(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, string[] filters, bool LandScape, string filename)
    {
        string user = GetUserName(id_user);

        Response.Clear();
        Response.Buffer = true;

        //style to format numbers to string
        string style = @"<style> .text { mso-number-format:\@; ";

        if (LandScape)
        {
            style += " mso-page-orientation:landscape;";
        }

        style += "br {mso-data-placement:same-cell;}";

        style += @" } </style>";

        Response.ClearContent();

        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "text/html";
        Response.ContentType = "application/excel";

        Response.ContentEncoding = Encoding.GetEncoding("Windows-1252");

        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        // costruisco la gridview per l'header
        int ind_filter_header = 6;
        int ind_filter = 0;
        string[] cells = new string[10 + filters.Length];
        cells[0] = Utility.ConvertDateTimeToDateString(DateTime.Now);
        cells[1] = title;
        cells[2] = "Richiedente:";
        cells[3] = user;
        cells[4] = "Menu:";
        cells[5] = tab_place;

        if (filters.Length >= 2)
        {
            cells[6] = "Filtri:";
            cells[7] = "";
            ind_filter_header = ind_filter_header + 2;
        }

        while (ind_filter < filters.Length - 1)
        {
            cells[ind_filter_header] = filters[ind_filter] + ":";
            cells[ind_filter_header + 1] = filters[ind_filter + 1];

            ind_filter = ind_filter + 2;
            ind_filter_header = ind_filter_header + 2;
        }

        DataTable table = Utility.CreateDataTable(2);
        Utility.AddDataToTable(table, cells);

        GridView gvHeader = new GridView();
        gvHeader.DataSource = table;
        gvHeader.DataBind();

        // gestisco il layout dell'header
        gvHeader.GridLines = GridLines.None;
        gvHeader.HeaderRow.Visible = false;
        gvHeader.Rows[0].Font.Bold = true;
        gvHeader.Rows[3].Font.Bold = true;

        for (int i = 0; i < gvHeader.Rows.Count; i++)
        {
            gvHeader.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            gvHeader.Rows[i].Style.Add("vertical-align", "middle");
        }

        // costruisco la gridview del report vero e proprio
        gvReport.AllowPaging = false;

        int nColumns = gvReport.Columns.Count;

        // cambio il back-color degli headers a bianco
        gvReport.HeaderRow.Style.Add("background-color", "#FFFFFF");

        if (gvReport.FooterRow.Visible == true)
        {
            gvReport.FooterRow.Style.Add("border-width", "thin");

            gvReport.FooterRow.BackColor = System.Drawing.Color.White;
            gvReport.FooterRow.BorderStyle = BorderStyle.Solid;
            gvReport.FooterRow.Font.Bold = true;
            gvReport.FooterRow.ForeColor = System.Drawing.Color.Black;

            gvReport.FooterRow.Attributes.Add("class", "text");
        }

        //applico lo stile agli header singolarmente      
        for (int i = 0; i < nColumns; i++)
        {
            if (gvReport.Columns[i].Visible)
            {
                gvReport.HeaderRow.Cells[i].Style.Add("border-style", "solid");
                gvReport.HeaderRow.Cells[i].Style.Add("border-width", "thin");
                gvReport.HeaderRow.Cells[i].Style.Add("text-font", "bold");

                gvReport.HeaderRow.Cells[i].Text = gvReport.Columns[i].HeaderText;

                //gvReport.HeaderRow.Attributes.Add("class", "text");
            }
        }

        GridViewRow row;

        string s;
        string type;

        for (int i = 0; i < gvReport.Rows.Count; i++)
        {
            row = gvReport.Rows[i];
            row.Font.Bold = false;

            for (int j = 0; j < nColumns; j++)
            {
                s = "";

                // cambio il back-color a bianco
                row.BackColor = System.Drawing.Color.White;

                // applico lo stile ad ogni cella 
                row.Attributes.Add("class", "text");

                // applico lo stile alla cella
                row.Cells[j].Font.Bold = false;
                row.Cells[j].ForeColor = System.Drawing.Color.Black;

                row.Cells[j].Style.Add("border-style", "solid");
                row.Cells[j].Style.Add("border-width", "thin");
                row.Cells[j].Style.Add("vertical-align", "middle");

                if (gvReport.Columns[j] is TemplateField)
                {
                    type = row.Cells[j].Controls[1].GetType().ToString();

                    switch (type)
                    {
                        case "System.Web.UI.WebControls.LinkButton":
                            LinkButton lb = row.Cells[j].Controls[1] as LinkButton;
                            s = lb.Text.Trim();
                            break;

                        case "System.Web.UI.WebControls.HyperLink":
                            HyperLink hl = row.Cells[j].Controls[1] as HyperLink;
                            s = hl.Text.Trim();
                            break;

                        case "System.Web.UI.WebControls.CheckBoxField":
                            CheckBox chk = row.Cells[j].Controls[0] as CheckBox;

                            if (chk.Checked)
                            {
                                s = "Si";
                            }
                            else
                            {
                                s = "No";
                            }
                            break;

                        case "System.Web.UI.WebControls.RadioButton":
                            RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;

                            if (rdb.Checked)
                            {
                                s = "Si";
                            }
                            break;

                        case "System.Web.UI.WebControls.Label":
                            Label lbl = row.Cells[j].Controls[1] as Label;
                            s = lbl.Text;
                            break;

                        default:
                            break;
                    }
                }
                else
                {
                    type = gvReport.Columns[j].GetType().ToString();

                    switch (type)
                    {
                        case "System.Web.UI.WebControls.CheckBoxField":
                            CheckBox chk = row.Cells[j].Controls[0] as CheckBox;

                            if (chk.Checked)
                            {
                                s = "Si";
                            }
                            else
                            {
                                s = "No";
                            }
                            break;

                        case "System.Web.UI.WebControls.RadioButton":
                            RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;

                            if (rdb.Checked)
                            {
                                s = "Si";
                            }
                            break;

                        default:
                            s = row.Cells[j].Text.Trim();

                            if (s == "&nbsp;")
                            {
                                s = "";
                            }
                            break;
                    }
                }

                row.Cells[j].Text = s;
            }
        }

        gvHeader.RenderControl(hw);
        gvReport.RenderControl(hw);

        if (filename == "Report_Durata_Sedute")
        {
            Label lbl_num_sedute = new Label();
            lbl_num_sedute.Text = "n. sedute: " + gvReport.Rows.Count.ToString();
            lbl_num_sedute.Font.Bold = true;

            lbl_num_sedute.RenderControl(hw);
        }

        //string ss = sw.ToString();
        //ss = Regex.Replace(ss, "</br>", "<br>", RegexOptions.IgnoreCase);

        Response.Write(style);
        Response.Output.Write(sw.ToString());

        Response.Flush();
        Response.End();
    }

    /// <summary>
    /// ExportTestExcel
    /// </summary>
    /// <param name="Response">output pagina</param>
    public static void ExportTestExcel(HttpResponse Response)
    {


    }

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab">tab</param>
    /// <param name="title">titolo export</param>
    /// <param name="filters">filtri</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    public static void ExportReportToPDF(HttpResponse Response, GridView gvReport, int id_user, string tab, string title, string[] filters, bool LandScape, string filename)
    {
        float HeaderTextSize = 9;
        float ReportTextSize = 8;

        string user = GetUserName(id_user);

        gvReport.AllowPaging = false;
        //gvReport.DataBind();

        int nColumns = gvReport.Columns.Count;
        int nRows = gvReport.Rows.Count;

        // ottengo il numero di colonne che devono essere visualizzate
        int nVisCol = nColumns;
        for (int i = 0; i < nColumns; i++)
        {
            if (!gvReport.Columns[i].Visible)
            {
                nVisCol--;
            }
        }

        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0, 0, 15, 5);
        }
        else
        {
            document = new Document(PageSize.A4, 0, 0, 15, 5);
        }

        iTextSharp.text.pdf.PdfPTable mainTable;

        // Creates a PdfPTable with column count of the table equal to no of columns of the gridview or gridview datasource.
        mainTable = new iTextSharp.text.pdf.PdfPTable(nVisCol);

        // Sets the first 4 rows of the table as the header rows which will be repeated in all the pages.
        //mainTable.HeaderRows = 4;

        // Creates a PdfPTable with 1 column to hold the header in the exported PDF.
        iTextSharp.text.pdf.PdfPTable headerTable = new iTextSharp.text.pdf.PdfPTable(1);

        // cella contenente la data ed il titolo
        Phrase phDate = new Phrase(DateTime.Now.Date.ToString("dd/MM/yyyy") + " - " + title, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clDate = new PdfPCell(phDate);
        clDate.HorizontalAlignment = Element.ALIGN_LEFT;
        clDate.Border = PdfPCell.NO_BORDER;

        // cella contenente il nome del richiedente
        Phrase phUser = new Phrase("Richiedente: " + user, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clUser = new PdfPCell(phUser);
        clUser.Border = PdfPCell.NO_BORDER;
        clUser.HorizontalAlignment = Element.ALIGN_LEFT;

        // cella contenente la tab da dove si è richiesta l'esportazione
        Phrase phTab = new Phrase("Menù: " + tab, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clTab = new PdfPCell(phTab);
        clTab.Border = PdfPCell.NO_BORDER;
        clTab.HorizontalAlignment = Element.ALIGN_LEFT;

        // aggiunge le celle alla tabella dell'header
        headerTable.AddCell(clDate);
        headerTable.AddCell(clUser);
        headerTable.AddCell(clTab);

        // cella contenente la voce Filtri
        if (filters.Length >= 2)
        {
            Phrase phFiltri = new Phrase("Filtri:", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell clFiltri = new PdfPCell(phFiltri);
            clFiltri.Border = PdfPCell.NO_BORDER;
            clFiltri.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFiltri);
        }

        Phrase phFilterCell;
        PdfPCell clFilterCell;
        int ind = 0;

        while (ind < filters.Length - 1)
        {
            phFilterCell = new Phrase("  " + filters[ind] + ": " + filters[ind + 1], FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
            clFilterCell = new PdfPCell(phFilterCell);
            clFilterCell.Border = PdfPCell.NO_BORDER;
            clFilterCell.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFilterCell);

            ind = ind + 2;
        }

        // Sets the border of the headerTable to zero.
        headerTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellHeader = new PdfPCell(headerTable);
        cellHeader.Border = PdfPCell.NO_BORDER;

        // Sets the column span of the header cell to nColumns.
        cellHeader.Colspan = nVisCol;

        // Adds the above header cell to the table.
        mainTable.AddCell(cellHeader);

        // cella per separare l'header dalla tabella
        Phrase phSeparator = new Phrase("_____________________________________________________________________");
        PdfPCell clSeparator = new PdfPCell(phSeparator);
        clSeparator.Border = PdfPCell.NO_BORDER;
        clSeparator.Colspan = nVisCol;
        clSeparator.HorizontalAlignment = Element.ALIGN_CENTER;
        mainTable.AddCell(clSeparator);

        // cella per andare a capo
        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        clSpace.Colspan = nVisCol;
        mainTable.AddCell(clSpace);

        // Sets the gridview column names as table headers.
        for (int i = 0; i < nColumns; i++)
        {
            if ((gvReport.Columns[i].Visible) && (gvReport.Columns[i].ShowHeader))
            {
                Phrase ph = null;
                PdfPCell phcell = null;

                //ph = new Phrase(gvReport.HeaderRow.Cells[i].Text, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
                ph = new Phrase(gvReport.Columns[i].HeaderText, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));

                phcell = new PdfPCell(ph);
                phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
                phcell.Colspan = gvReport.HeaderRow.Cells[i].ColumnSpan;
                mainTable.AddCell(phcell);
            }
        }

        string s;
        string type = "";
        string hAlign = "";

        // Reads the gridview rows and adds them to the mainTable
        for (int indexRow = 0; indexRow < nRows; indexRow++)
        {
            GridViewRow row = gvReport.Rows[indexRow];

            for (int indexColumn = 0; indexColumn < nColumns; indexColumn++)
            {
                s = "";

                if (gvReport.Columns[indexColumn].Visible)
                {
                    hAlign = row.Cells[indexColumn].HorizontalAlign.ToString().ToLower();

                    if (hAlign == "notset")
                    {
                        hAlign = gvReport.Columns[indexColumn].ItemStyle.HorizontalAlign.ToString().ToLower();
                    }

                    if (gvReport.Columns[indexColumn] is TemplateField)
                    {
                        if (row.Cells[indexColumn].Controls.Count == 0)
                        {
                            type = "";
                        }
                        else
                        {
                            type = row.Cells[indexColumn].Controls[1].GetType().ToString();
                        }

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.LinkButton":
                                LinkButton lb = row.Cells[indexColumn].Controls[1] as LinkButton;
                                s = lb.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.HyperLink":
                                HyperLink hl = row.Cells[indexColumn].Controls[1] as HyperLink;
                                s = hl.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = row.Cells[indexColumn].Controls[0] as CheckBox;

                                if (chk.Checked)
                                {
                                    s = "Si";
                                }
                                else
                                {
                                    s = "No";
                                }
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = row.Cells[indexColumn].Controls[0] as RadioButton;

                                if (rdb.Checked)
                                {
                                    s = "Si";
                                }
                                break;

                            case "System.Web.UI.WebControls.Label":
                                Label lbl = row.Cells[indexColumn].Controls[1] as Label;
                                s = lbl.Text.Replace("<br />", "\n");
                                break;

                            default:
                                break;
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[indexColumn].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = row.Cells[indexColumn].Controls[0] as CheckBox;

                                if (chk.Checked)
                                {
                                    s = "Si";
                                }
                                else
                                {
                                    s = "No";
                                }
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = row.Cells[indexColumn].Controls[0] as RadioButton;

                                if (rdb.Checked)
                                {
                                    s = "Si";
                                }
                                break;

                            default:
                                s = row.Cells[indexColumn].Text.Trim();

                                if (s == "&nbsp;")
                                {
                                    s = "";
                                }
                                break;
                        }
                    }

                    //s = s.Replace("&#224;", "à");

                    s = System.Web.HttpUtility.HtmlDecode(s);

                    Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                    PdfPCell phcell = new PdfPCell(ph);

                    phcell.VerticalAlignment = Element.ALIGN_MIDDLE;

                    int colspan = row.Cells[indexColumn].ColumnSpan;

                    if (colspan > 1)
                    {
                        phcell.Colspan = row.Cells[indexColumn].ColumnSpan;
                        indexColumn = indexColumn + phcell.Colspan - 1;
                    }

                    switch (hAlign)
                    {
                        case "center":
                            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                            break;

                        case "right":
                            phcell.HorizontalAlignment = Element.ALIGN_RIGHT;
                            break;

                        default:
                            phcell.HorizontalAlignment = Element.ALIGN_LEFT;
                            break;
                    }

                    mainTable.AddCell(phcell);
                }
            }

            // Tells the mainTable to complete the row even if any cell is left incomplete.
            mainTable.CompleteRow();
        }

        if (gvReport.FooterRow.Visible == true)
        {
            GridViewRow footer_row = gvReport.FooterRow;

            for (int indexColumn = 0; indexColumn < nColumns; indexColumn++)
            {
                s = "";

                if (gvReport.Columns[indexColumn].Visible)
                {
                    hAlign = footer_row.Cells[indexColumn].HorizontalAlign.ToString().ToLower();

                    if (hAlign == "notset")
                    {
                        hAlign = gvReport.Columns[indexColumn].ItemStyle.HorizontalAlign.ToString().ToLower();
                    }

                    if (gvReport.Columns[indexColumn] is TemplateField)
                    {
                        if (footer_row.Cells[indexColumn].Controls.Count == 0)
                        {
                            type = "";
                        }
                        else
                        {
                            type = footer_row.Cells[indexColumn].Controls[1].GetType().ToString();
                        }

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.LinkButton":
                                LinkButton lb = footer_row.Cells[indexColumn].Controls[1] as LinkButton;
                                s = lb.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.HyperLink":
                                HyperLink hl = footer_row.Cells[indexColumn].Controls[1] as HyperLink;
                                s = hl.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = footer_row.Cells[indexColumn].Controls[0] as CheckBox;

                                if (chk.Checked)
                                {
                                    s = "Si";
                                }
                                else
                                {
                                    s = "No";
                                }
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = footer_row.Cells[indexColumn].Controls[0] as RadioButton;

                                if (rdb.Checked)
                                {
                                    s = "Si";
                                }
                                break;

                            case "System.Web.UI.WebControls.Label":
                                Label lbl = footer_row.Cells[indexColumn].Controls[1] as Label;
                                s = lbl.Text.Replace("<br />", "\n");
                                break;

                            default:
                                break;
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[indexColumn].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = footer_row.Cells[indexColumn].Controls[0] as CheckBox;

                                if (chk.Checked)
                                {
                                    s = "Si";
                                }
                                else
                                {
                                    s = "No";
                                }
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = footer_row.Cells[indexColumn].Controls[0] as RadioButton;

                                if (rdb.Checked)
                                {
                                    s = "Si";
                                }
                                break;

                            default:
                                s = footer_row.Cells[indexColumn].Text.Trim();

                                if (s == "&nbsp;")
                                {
                                    s = "";
                                }
                                break;
                        }
                    }

                    //s = s.Replace("&#224;", "à");

                    s = System.Web.HttpUtility.HtmlDecode(s);

                    Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.BOLD));
                    PdfPCell phcell = new PdfPCell(ph);

                    if (s.ToLower() == "totale")
                    {
                        hAlign = "right";
                    }

                    phcell.VerticalAlignment = Element.ALIGN_MIDDLE;

                    int colspan = footer_row.Cells[indexColumn].ColumnSpan;

                    if (colspan > 1)
                    {
                        phcell.Colspan = footer_row.Cells[indexColumn].ColumnSpan;
                        indexColumn = indexColumn + phcell.Colspan - 1;
                    }

                    switch (hAlign)
                    {
                        case "center":
                            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                            break;

                        case "right":
                            phcell.HorizontalAlignment = Element.ALIGN_RIGHT;
                            break;

                        default:
                            phcell.HorizontalAlignment = Element.ALIGN_LEFT;
                            break;
                    }

                    mainTable.AddCell(phcell);
                }
            }

            mainTable.CompleteRow();
        }

        if (filename == "Report_Durata_Sedute")
        {
            Phrase ph = new Phrase("n. sedute: " + gvReport.Rows.Count.ToString(), FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell phcell = new PdfPCell(ph);
            phcell.Border = PdfPCell.NO_BORDER;
            phcell.Colspan = nVisCol;

            mainTable.AddCell(phcell);

            mainTable.CompleteRow();
        }

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        //HeaderFooter pdfFooter = new HeaderFooter(new Phrase(), true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        //document.Footer = pdfFooter;
        document.Open();
        document.Add(mainTable);
        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();
    }


    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="databind">flag se databind</param>
    public static void ExportToPDF_Simple(HttpResponse Response, GridView gvReport, bool LandScape, string filename, bool databind)
    {
        float HeaderTextSize = 9;
        float ReportTextSize = 8;

        int noOfColumns = 0, noOfRows = 0;
        DataTable tbl = null;

        gvReport.AllowPaging = false;

        if (databind)
            gvReport.DataBind();

        if (gvReport.AutoGenerateColumns)
        {
            tbl = gvReport.DataSource as DataTable; // Gets the DataSource of the GridView Control.

            noOfColumns = tbl.Columns.Count;
            noOfRows = tbl.Rows.Count;
        }
        else
        {
            noOfColumns = gvReport.Columns.Count;
            noOfRows = gvReport.Rows.Count;
        }

        int start = 0;

        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0, 0, 15, 5);
        }
        else
        {
            document = new Document(PageSize.A4, 0, 0, 15, 5);
        }

        iTextSharp.text.pdf.PdfPTable mainTable;

        // Creates a PdfPTable with column count of the table equal to no of columns of the gridview or gridview datasource.
        mainTable = new iTextSharp.text.pdf.PdfPTable(noOfColumns);

        // cella per andare a capo
        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        clSpace.Colspan = noOfColumns;
        mainTable.AddCell(clSpace);

        // Sets the gridview column names as table headers.
        for (int i = start; i < noOfColumns; i++)
        {
            Phrase ph = null;
            PdfPCell phcell = null;

            if (gvReport.AutoGenerateColumns)
            {
                ph = new Phrase(tbl.Columns[i].ColumnName, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            }
            else
            {
                ph = new Phrase(gvReport.Columns[i].HeaderText, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            }

            phcell = new PdfPCell(ph);
            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
            phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
            mainTable.AddCell(phcell);
        }

        string s = "";
        string type = "";
        string hAlign = "";

        // Reads the gridview rows and adds them to the mainTable
        for (int rowNo = 0; rowNo < noOfRows; rowNo++)
        {
            for (int columnNo = start; columnNo < noOfColumns; columnNo++)
            {
                hAlign = gvReport.Columns[columnNo].ItemStyle.HorizontalAlign.ToString();
                hAlign = hAlign.ToLower();

                if (gvReport.AutoGenerateColumns)
                {
                    s = gvReport.Rows[rowNo].Cells[columnNo].Text.Trim();
                }
                else
                {
                    if (gvReport.Columns[columnNo] is TemplateField)
                    {
                        if (gvReport.Rows[rowNo].Cells[columnNo].Controls.Count == 0)
                            type = "";
                        else
                            type = gvReport.Rows[rowNo].Cells[columnNo].Controls[1].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.LinkButton":
                                LinkButton lb = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as LinkButton;
                                s = lb.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.HyperLink":
                                HyperLink hl = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as HyperLink;
                                s = hl.Text.Trim();
                                break;

                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            case "System.Web.UI.WebControls.Label":
                                Label lbl = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as Label;
                                s = lbl.Text.Replace("<br />", "\n");
                                break;

                            default:
                                break;
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[columnNo].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            default:
                                s = gvReport.Rows[rowNo].Cells[columnNo].Text.Trim();
                                if (s == "&nbsp;")
                                    s = "";
                                break;
                        }
                    }
                }

                //s = s.Replace("&#224;", "à");

                s = System.Web.HttpUtility.HtmlDecode(s);

                Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                PdfPCell phcell = new PdfPCell(ph);

                switch (hAlign)
                {
                    case "center":
                        phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                        break;
                    case "right":
                        phcell.HorizontalAlignment = Element.ALIGN_RIGHT;
                        break;
                    default:
                        phcell.HorizontalAlignment = Element.ALIGN_LEFT;
                        break;
                }

                phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
                mainTable.AddCell(phcell);
            }

            // Tells the mainTable to complete the row even if any cell is left incomplete.
            mainTable.CompleteRow();
        }

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        //HeaderFooter pdfFooter = new HeaderFooter(new Phrase(), true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        // Sets the document footer to pdfFooter.
        //document.Footer = pdfFooter;
        // Opens the document.
        document.Open();
        // Adds the mainTable to the document.
        document.Add(mainTable);
        // Closes the document.
        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();

    }



    #region esportazione per la pagine di riepilogo mensile

    /// <summary>
    /// Metodo per esportazione di gridview Sedute in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="filters">filtri</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="num_seduta">numero seduta</param>
    public static void ExportSeduteToExcel(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, string[] filters, bool LandScape, string filename, int num_seduta)
    {
        //int nVisCol = nColumns;
        string user = GetUserName(id_user);

        Response.Clear();
        Response.Buffer = true;

        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "text/html";
        Response.ContentType = "application/vnd.ms-excel";

        Response.ContentEncoding = Encoding.GetEncoding("Windows-1252");


        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        // costruisco la gridview per l'header
        int ind_filter_header = 6;
        int ind_filter = 0;
        string[] cells = new string[10 + filters.Length];
        cells[0] = Utility.ConvertDateTimeToDateString(DateTime.Now);
        cells[1] = title;
        cells[2] = "Richiedente:";
        cells[3] = user;
        cells[4] = "Menu:";
        cells[5] = tab_place;

        if (filters.Length >= 2)
        {
            cells[6] = "Filtri:";
            cells[7] = "";
            ind_filter_header = ind_filter_header + 2;
        }

        while (ind_filter < filters.Length - 1)
        {
            cells[ind_filter_header] = filters[ind_filter] + ":";
            cells[ind_filter_header + 1] = filters[ind_filter + 1];

            ind_filter = ind_filter + 2;
            ind_filter_header = ind_filter_header + 2;
        }

        DataTable table = Utility.CreateDataTable(2);
        Utility.AddDataToTable(table, cells);

        GridView gvHeader = new GridView();
        gvHeader.DataSource = table;
        gvHeader.DataBind();

        // gestisco il layout dell'header
        gvHeader.GridLines = GridLines.None;
        gvHeader.HeaderRow.Visible = false;
        gvHeader.Rows[0].Font.Bold = true;
        gvHeader.Rows[3].Font.Bold = true;

        for (int i = 0; i < gvHeader.Rows.Count; i++)
        {
            gvHeader.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            gvHeader.Rows[i].Style.Add("vertical-align", "middle");
        }

        // costruisco la gridview del report vero e proprio
        gvReport.AllowPaging = false;
        //questo era decommentato
        //gvReport.DataBind();

        int nColumns = gvReport.Columns.Count;

        // cambio il back-color degli headers a bianco
        gvReport.HeaderRow.Style.Add("background-color", "#FFFFFF");

        //applico lo stile agli header singolarmente      
        for (int i = 0; i < nColumns; i++)
        {
            if (gvReport.Columns[i].Visible)
            {
                gvReport.HeaderRow.Cells[i].Style.Add("border-style", "solid");
                gvReport.HeaderRow.Cells[i].Style.Add("border-width", "thin");
                gvReport.HeaderRow.Cells[i].Style.Add("text-font", "bold");
                gvReport.HeaderRow.Cells[i].Text = Convert.ToString(gvReport.Columns[i].HeaderText);
            }
        }

        GridViewRow row;

        string s;
        string type;


        for (int i = 0; i < gvReport.Rows.Count; i++)
        {
            row = gvReport.Rows[i];
            row.Font.Bold = false;

            bool firts_iter = true;

            for (int j = 0; j < nColumns; j++)
            {
                if ((firts_iter) && (num_seduta == 4))
                {
                    firts_iter = false;
                }
                else
                {
                    s = "";

                    // cambio il back-color a bianco
                    row.BackColor = System.Drawing.Color.White;

                    // applico lo stile ad ogni cella 
                    row.Attributes.Add("class", "textmode");

                    // applico lo stile alla cella
                    row.Cells[j].Font.Bold = false;
                    row.Cells[j].ForeColor = System.Drawing.Color.Black;

                    row.Cells[j].Style.Add("border-style", "solid");
                    row.Cells[j].Style.Add("border-width", "thin");
                    row.Cells[j].Style.Add("vertical-align", "middle");

                    if (gvReport.Columns[j] is TemplateField)
                    {
                        //if (row.Cells[j].Controls.Count == 0)
                        //    type = "";
                        if (row.Cells[j].Controls.Count == 0)
                            type = "";
                        else
                        {
                            for (int indexControl = 0; indexControl < row.Cells[j].Controls.Count; indexControl++)
                            {
                                type = row.Cells[j].Controls[indexControl].GetType().ToString();

                                switch (type)
                                {
                                    //case "System.Web.UI.WebControls.LinkButton":
                                    //    LinkButton lb = row.Cells[j].Controls[1] as LinkButton;
                                    //    s = lb.Text.Trim();
                                    //    break;        
                                    case "System.Web.UI.WebControls.HyperLink":
                                        HyperLink hl = row.Cells[j].Controls[1] as HyperLink;
                                        s = hl.Text.Trim();
                                        break;

                                    case "System.Web.UI.WebControls.LinkButton":
                                        LinkButton lnk_btn = row.Cells[j].Controls[indexControl] as LinkButton;
                                        s = lnk_btn.Text;
                                        break;

                                    case "System.Web.UI.WebControls.CheckBoxField":
                                        CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                                        if (chk.Checked)
                                            s = "Si";
                                        else
                                            s = "No";
                                        break;

                                    case "System.Web.UI.WebControls.RadioButton":
                                        RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                                        if (rdb.Checked)
                                            s = "Si";
                                        break;

                                    case "System.Web.UI.WebControls.Label":
                                        Label lbl = row.Cells[j].Controls[indexControl] as Label;
                                        s = lbl.Text;
                                        //s = Regex.Replace(s, "</br>", " ", RegexOptions.IgnoreCase);
                                        s = Regex.Replace(s, "</?sup>", " ", RegexOptions.IgnoreCase);

                                        break;

                                    default:
                                        break;
                                }
                            }
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[j].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            default:
                                s = row.Cells[j].Text.Trim();
                                if (s == "&nbsp;")
                                    s = "";
                                break;
                        }
                    }

                    //row.Cells[j].Text = s;
                }
            }
        }

        gvHeader.RenderControl(hw);
        gvReport.RenderControl(hw);

        //style to format numbers to string        
        //string style = @"<style> .textmode { mso-number-format:\@; } </style>";
        //string style = @"<style> { mso-number-format:\@;";

        string style = @"<style> .textmode{mso-number-format:\@;} </style>";

        //string style = @"<style> .num{mso-number-format:0\.000} </style>";

        //if (LandScape)
        //    style += " mso-page-orientation:landscape;";

        //style += @" } </style>";

        string ss = sw.ToString();
        //ss = Regex.Replace(ss, "</br>", " ", RegexOptions.IgnoreCase);
        //ss = Regex.Replace(ss, "<sup>", "&nbsp;(", RegexOptions.IgnoreCase);
        //ss = Regex.Replace(ss, "</sup>", ")", RegexOptions.IgnoreCase);


        Response.Write(style);
        //Response.Output.Write(sw.ToString());
        Response.Output.Write(ss);
        Response.Flush();
        Response.End();
    }

    /// <summary>
    /// Metodo per esportazione di gridview Sedute in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="Request">Richiesta di riferimento</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="filters">filtri</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="num_seduta">numero seduta</param>
    public static void ExportSeduteToPDF(HttpResponse Response, HttpRequest Request, GridView gvReport, int id_user, string tab, string title, string[] filters, bool LandScape, string filename, int num_seduta)
    {
        float HeaderTextSize = 9;
        float ReportTextSize = 8;

        string user = GetUserName(id_user);

        gvReport.AllowPaging = false;
        //gvReport.DataBind();

        int nColumns = gvReport.Columns.Count;
        int nRows = gvReport.Rows.Count;

        // ottengo il numero di colonne che devono essere visualizzate
        int nVisCol = nColumns;
        for (int i = 0; i < nColumns; i++)
        {
            if (!gvReport.Columns[i].Visible || !gvReport.Columns[i].ShowHeader)
            {
                nVisCol--;
            }
        }

        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0, 0, 15, 25);
        }
        else
        {
            document = new Document(PageSize.A4, 0, 0, 15, 25);
        }

        // la tabella che contiene i dati per tutto il documento
        iTextSharp.text.pdf.PdfPTable MainTable = new iTextSharp.text.pdf.PdfPTable(1);

        // Creates a PdfPTable with column count of the table equal to no of columns of the gridview or gridview datasource.
        iTextSharp.text.pdf.PdfPTable GridTable = new iTextSharp.text.pdf.PdfPTable(nVisCol);

        // Sets the first 4 rows of the table as the header rows which will be repeated in all the pages.
        //mainTable.HeaderRows = 4;

        //tabella intestazione
        iTextSharp.text.pdf.PdfPTable HeaderTable = new iTextSharp.text.pdf.PdfPTable(1);

        // Creates a PdfPTable with 1 column to hold the header in the exported PDF.
        iTextSharp.text.pdf.PdfPTable InfoTable = new iTextSharp.text.pdf.PdfPTable(1);

        // cella contenente la data ed il titolo
        Phrase phTitle = new Phrase(title, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clTitle = new PdfPCell(phTitle);
        clTitle.HorizontalAlignment = Element.ALIGN_CENTER;
        clTitle.Border = PdfPCell.NO_BORDER;

        // cella contenente il nome del richiedente
        Phrase phUser = new Phrase("\nRichiedente: " + user, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clUser = new PdfPCell(phUser);
        clUser.Border = PdfPCell.NO_BORDER;
        clUser.HorizontalAlignment = Element.ALIGN_LEFT;

        // cella contenente la tab da dove si è richiesta l'esportazione
        Phrase phTab = new Phrase("Menù: " + tab, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clTab = new PdfPCell(phTab);
        clTab.Border = PdfPCell.NO_BORDER;
        clTab.HorizontalAlignment = Element.ALIGN_LEFT;

        // aggiunge le celle alla tabella dell'header
        InfoTable.AddCell(clTitle);
        InfoTable.AddCell(clUser);
        InfoTable.AddCell(clTab);

        // cella contenente la voce Filtri
        if (filters.Length >= 2)
        {
            Phrase phFiltri = new Phrase("Filtri:", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell clFiltri = new PdfPCell(phFiltri);
            clFiltri.Border = PdfPCell.NO_BORDER;
            clFiltri.HorizontalAlignment = Element.ALIGN_LEFT;

            InfoTable.AddCell(clFiltri);

            Phrase phFilterCell;
            PdfPCell clFilterCell;
            int ind = 0;

            while (ind < filters.Length - 1)
            {
                phFilterCell = new Phrase("  " + filters[ind] + ": " + filters[ind + 1], FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
                clFilterCell = new PdfPCell(phFilterCell);
                clFilterCell.Border = PdfPCell.NO_BORDER;
                clFilterCell.HorizontalAlignment = Element.ALIGN_LEFT;

                InfoTable.AddCell(clFilterCell);

                ind = ind + 2;
            }
        }

        // Sets the border of the headerTable to zero.
        InfoTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellHeader = new PdfPCell(InfoTable);
        cellHeader.Border = PdfPCell.NO_BORDER;
        cellHeader.HorizontalAlignment = Element.ALIGN_CENTER;

        // Sets the column span of the header cell to nColumns.
        //cellHeader.Colspan = nVisCol - 1;

        //aggiunge il logo
        string logo_file_path = Request.PhysicalApplicationPath + "img/LogoTessera.png";

        iTextSharp.text.Image logo_image = iTextSharp.text.Image.GetInstance(new Uri(logo_file_path));
        //logo_image.ScaleAbsolute(115, 54);
        //logo_image.ScaleAbsolute(229, 107);
        logo_image.ScalePercent(25);

        PdfPCell cell_logo = new PdfPCell(logo_image);
        cell_logo.Border = PdfPCell.NO_BORDER;
        cell_logo.HorizontalAlignment = Element.ALIGN_CENTER;

        HeaderTable.AddCell(cell_logo);

        // Adds the above header cell to the table.
        HeaderTable.AddCell(cellHeader);

        PdfPCell cell_header = new PdfPCell(HeaderTable);
        cell_header.Border = PdfPCell.NO_BORDER;
        cell_header.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_header);

        // cella per separare l'header dalla tabella
        Phrase phSeparator = new Phrase("_____________________________________________________________________");
        PdfPCell clSeparator = new PdfPCell(phSeparator);
        clSeparator.Border = PdfPCell.NO_BORDER;
        //clSeparator.Colspan = nVisCol;
        clSeparator.HorizontalAlignment = Element.ALIGN_CENTER;
        MainTable.AddCell(clSeparator);

        // cella per andare a capo
        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        //clSpace.Colspan = nVisCol;
        MainTable.AddCell(clSpace);

        float[] cell_widths = new float[nColumns];

        switch (num_seduta)
        {
            case 1:
                break;

            case 2:
                for (int i = 0; i < nColumns; i++)
                {
                    if (i == 0)
                    {
                        cell_widths[i] = 100;
                    }
                    else
                    {
                        cell_widths[i] = 24;
                    }
                }
                break;
        }

        //MainTable.CompleteRow();
        PdfPTable table_grid_header = new PdfPTable(nVisCol);

        if (num_seduta == 2)
        {
            table_grid_header.SetWidths(cell_widths);
        }

        for (int i = 0; i < nColumns; i++)
        {
            if ((gvReport.Columns[i].Visible) && (gvReport.Columns[i].ShowHeader))
            {
                var text = gvReport.Columns[i].HeaderText;
                text = Regex.Replace(text, "<br />", Environment.NewLine, RegexOptions.IgnoreCase);
                text = Regex.Replace(text, "</?sup>", " ", RegexOptions.IgnoreCase);

                //Phrase column_header = new Phrase(gvReport.Columns[i].HeaderText.Replace("</br>",Environment.NewLine), FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
                Phrase column_header = new Phrase(text, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));

                PdfPCell column_cell = new PdfPCell(column_header);

                column_cell.HorizontalAlignment = Element.ALIGN_CENTER;
                column_cell.VerticalAlignment = Element.ALIGN_MIDDLE;
                column_cell.Colspan = gvReport.HeaderRow.Cells[i].ColumnSpan;

                table_grid_header.AddCell(column_cell);
            }
        }

        PdfPCell cell_grid_header = new PdfPCell(table_grid_header);
        cell_grid_header.HorizontalAlignment = Element.ALIGN_CENTER;
        cell_grid_header.Border = PdfPCell.NO_BORDER;
        MainTable.AddCell(cell_grid_header);

        string s;
        string type = "";
        string hAlign = "";

        // Reads the gridview rows and adds them to the mainTable
        for (int indexRow = 0; indexRow < nRows; indexRow++)
        {
            GridViewRow row = gvReport.Rows[indexRow];
            bool first_iter = true;

            PdfPTable data_table = new PdfPTable(nVisCol);

            if (num_seduta == 2)
            {
                data_table.SetWidths(cell_widths);
            }

            for (int indexColumn = 0; indexColumn < nColumns; indexColumn++)
            {
                if ((first_iter) && (num_seduta == 4))
                {
                    first_iter = false;
                }
                else
                {
                    s = "";

                    if (gvReport.Columns[indexColumn].Visible)
                    {
                        hAlign = gvReport.Columns[indexColumn].ItemStyle.HorizontalAlign.ToString();
                        hAlign = hAlign.ToLower();

                        if (gvReport.Columns[indexColumn] is TemplateField)
                        {
                            if (row.Cells[indexColumn].Controls.Count == 0)
                            {
                                type = "";
                            }
                            else
                            {
                                var pattern = @"^\s*\[\d+\]\s*$";
                                for (int indexControl = 0; indexControl < row.Cells[indexColumn].Controls.Count; indexControl++)
                                {
                                    type = row.Cells[indexColumn].Controls[indexControl].GetType().ToString();

                                    switch (type)
                                    {
                                        case "System.Web.UI.WebControls.HyperLink":
                                            HyperLink hl = row.Cells[indexColumn].Controls[indexControl] as HyperLink;
                                            if (Regex.IsMatch(hl.Text, pattern, RegexOptions.IgnoreCase))
                                                s += " " + hl.Text.Trim();
                                            else
                                                s = hl.Text.Trim();

                                            break;

                                        case "System.Web.UI.WebControls.LinkButton":
                                            LinkButton lnk_btn = row.Cells[indexColumn].Controls[indexControl] as LinkButton;
                                            if (Regex.IsMatch(lnk_btn.Text, pattern, RegexOptions.IgnoreCase))
                                                s += " " + lnk_btn.Text.Trim();
                                            else
                                                s = lnk_btn.Text.Trim();

                                            break;

                                        case "System.Web.UI.WebControls.CheckBoxField":
                                            CheckBox chk = row.Cells[indexColumn].Controls[indexControl] as CheckBox;
                                            if (chk.Checked)
                                            {
                                                s = "Si";
                                            }
                                            else
                                            {
                                                s = "No";
                                            }
                                            break;

                                        case "System.Web.UI.WebControls.RadioButton":
                                            RadioButton rdb = row.Cells[indexColumn].Controls[indexControl] as RadioButton;
                                            if (rdb.Checked)
                                            {
                                                s = "Si";
                                            }
                                            break;

                                        case "System.Web.UI.WebControls.Label":
                                            Label lbl = row.Cells[indexColumn].Controls[indexControl] as Label;
                                            s = lbl.Text;

                                            s = Regex.Replace(s, "<br />", Environment.NewLine, RegexOptions.IgnoreCase);
                                            //s = Regex.Replace(s, "</?sup>", " ", RegexOptions.IgnoreCase);

                                            s = Regex.Replace(s, "<sup>", " (", RegexOptions.IgnoreCase);
                                            s = Regex.Replace(s, "</sup>", ")", RegexOptions.IgnoreCase);

                                            break;

                                        default:
                                            break;
                                    }
                                }
                            }
                        }
                        else
                        {
                            type = gvReport.Columns[indexColumn].GetType().ToString();

                            switch (type)
                            {
                                case "System.Web.UI.WebControls.CheckBoxField":
                                    CheckBox chk = row.Cells[indexColumn].Controls[0] as CheckBox;
                                    if (chk.Checked)
                                    {
                                        s = "Si";
                                    }
                                    else
                                    {
                                        s = "No";
                                    }
                                    break;

                                case "System.Web.UI.WebControls.RadioButton":
                                    RadioButton rdb = row.Cells[indexColumn].Controls[0] as RadioButton;
                                    if (rdb.Checked)
                                    {
                                        s = "Si";
                                    }
                                    break;

                                default:
                                    s = row.Cells[indexColumn].Text.Trim();
                                    if (s == "&nbsp;")
                                    {
                                        s = "";
                                    }
                                    break;
                            }
                        }

                        //s = s.Replace("&#224;", "à");

                        s = System.Web.HttpUtility.HtmlDecode(s);

                        Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                        PdfPCell cell_data_column = new PdfPCell(ph);

                        switch (hAlign)
                        {
                            case "center":
                                cell_data_column.HorizontalAlignment = Element.ALIGN_CENTER;
                                break;

                            case "right":
                                cell_data_column.HorizontalAlignment = Element.ALIGN_RIGHT;
                                break;

                            case "justify":
                                cell_data_column.HorizontalAlignment = Element.ALIGN_JUSTIFIED;
                                break;

                            default:
                                cell_data_column.HorizontalAlignment = Element.ALIGN_LEFT;
                                break;
                        }

                        cell_data_column.VerticalAlignment = Element.ALIGN_MIDDLE;

                        data_table.AddCell(cell_data_column);
                    }
                }
            }

            PdfPCell cell_data_row = new PdfPCell(data_table);
            cell_data_row.Border = PdfPCell.NO_BORDER;
            cell_data_row.HorizontalAlignment = Element.ALIGN_CENTER;

            // Tells the mainTable to complete the row even if any cell is left incomplete.
            MainTable.AddCell(cell_data_row);
        }

        MainTable.CompleteRow();

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        Phrase date_footer = new Phrase(Utility.ConvertDateTimeToDateString(DateTime.Now) + " - Pagina ");
        //HeaderFooter pdfFooter = new HeaderFooter(date_footer, true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        //document.Footer = pdfFooter;
        document.Open();

        /*
        Chunk normalText = new Chunk("Normal text at normal y-location. ");
        document.Add(normalText);

        Chunk superScript = new Chunk("Superscript");
        superScript.SetTextRise(5f);
        document.Add(superScript);

        Chunk moreNormalText = new Chunk(". More normal y-location text. ");
        document.Add(moreNormalText);

        Chunk subScript = new Chunk("Subscript");
        subScript.SetTextRise(-5f);
        document.Add(subScript);
        */


        document.Add(MainTable);

        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();
    }

    #endregion


    #region SERVIZIO COMMISSIONI - esportazione per la pagine di riepilogo mensile

    /// <summary>
    /// Metodo per esportazione di gridview in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="filters">filtri</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="num_seduta">numero seduta</param>
    public static void ExportSeduteToExcel_ServComm(HttpResponse Response, GridView gvReport, int id_user, string tab_place, string title, string[] filters, bool LandScape, string filename, int num_seduta)
    {
        //int nVisCol = nColumns;
        string user = GetUserName(id_user);

        Response.Clear();
        Response.Buffer = true;

        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "text/html";
        Response.ContentType = "application/vnd.ms-excel";
        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        // costruisco la gridview per l'header
        string[] cells = new string[2];
        cells[0] = title;
        cells[1] = "";

        DataTable table = Utility.CreateDataTable(1);
        Utility.AddDataToTable(table, cells);

        GridView gvHeader = new GridView();
        gvHeader.DataSource = table;
        gvHeader.DataBind();

        // gestisco il layout dell'header
        gvHeader.GridLines = GridLines.None;
        gvHeader.HeaderRow.Visible = false;
        gvHeader.Rows[0].Font.Bold = true;

        //gvHeader.Rows[3].Font.Bold = true;

        for (int i = 0; i < gvHeader.Rows.Count; i++)
        {
            gvHeader.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            gvHeader.Rows[i].Style.Add("vertical-align", "middle");
            gvHeader.Rows[i].Cells[0].Wrap = false;
        }


        //Footer
        string[] cellsF = new string[4];
        cellsF[2] = "Milano,";
        cellsF[3] = "Il Dirigente";

        DataTable tableF = Utility.CreateDataTable(2);
        Utility.AddDataToTable(tableF, cellsF);

        GridView gvFooter = new GridView();
        gvFooter.DataSource = tableF;
        gvFooter.DataBind();

        gvFooter.GridLines = GridLines.None;
        gvFooter.HeaderRow.Visible = false;

        for (int i = 0; i < gvFooter.Rows.Count; i++)
        {
            gvFooter.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            gvFooter.Rows[i].Style.Add("vertical-align", "middle");

            for (int j = 0; j < gvFooter.Columns.Count; i++)
            {
                gvFooter.Rows[i].Cells[j].Style.Add("horizontal-align", "left");
                gvFooter.Rows[i].Cells[j].Wrap = false;
                gvFooter.Rows[i].Cells[j].HorizontalAlign = HorizontalAlign.Left;
            }
        }

        gvFooter.Rows[0].Cells[0].ColumnSpan = 16;
        gvFooter.Rows[0].Cells[1].ColumnSpan = 16;
        gvFooter.Rows[1].Cells[0].ColumnSpan = 16;
        gvFooter.Rows[1].Cells[1].ColumnSpan = 16;

        // costruisco la gridview del report vero e proprio
        gvReport.AllowPaging = false;
        //questo era decommentato
        //gvReport.DataBind();

        gvReport.Style.Add("border-style", "none");

        int nColumns = gvReport.Columns.Count;

        // cambio il back-color degli headers a bianco
        gvReport.HeaderRow.Style.Add("background-color", "#FFFFFF");

        //applico lo stile agli header singolarmente      
        //for (int i = 0; i < nColumns; i++)
        //{
        //    if (gvReport.Columns[i].Visible)
        //    {
        //        gvReport.HeaderRow.Cells[i].Style.Add("border-style", "solid");
        //        gvReport.HeaderRow.Cells[i].Style.Add("border-width", "thin");
        //        gvReport.HeaderRow.Cells[i].Style.Add("text-font", "bold");
        //        gvReport.HeaderRow.Cells[i].Text = Convert.ToString(gvReport.Columns[i].HeaderText);
        //    }
        //}

        for (int i = 0; i < nColumns; i++)
        {
            gvReport.HeaderRow.Cells[i].Style.Add("border-style", "none");

            if (i > 0)
                gvReport.Columns[i].ControlStyle.Width = 50;
        }


        gvReport.HeaderRow.Cells[0].Style.Add("border-style", "solid");
        gvReport.HeaderRow.Cells[0].Style.Add("border-width", "thin");
        gvReport.HeaderRow.Cells[0].Style.Add("text-font", "bold");
        gvReport.HeaderRow.Cells[0].Text = "Commissione";

        gvReport.HeaderRow.Cells[1].Style.Add("border-style", "solid");
        gvReport.HeaderRow.Cells[1].Style.Add("border-width", "thin");
        gvReport.HeaderRow.Cells[1].Style.Add("text-font", "bold");
        gvReport.HeaderRow.Cells[1].Text = "Giorno";

        GridViewRow row;

        string s;
        string type;

        for (int i = 0; i < gvReport.Rows.Count; i++)
        {
            row = gvReport.Rows[i];
            row.Font.Bold = false;

            bool firts_iter = true;

            for (int j = 0; j < nColumns; j++)
            {
                if ((firts_iter) && (num_seduta == 4))
                {
                    firts_iter = false;
                }
                else
                {
                    s = "";

                    // cambio il back-color a bianco
                    row.BackColor = System.Drawing.Color.White;

                    // applico lo stile ad ogni cella 
                    row.Attributes.Add("class", "textmode");

                    // applico lo stile alla cella
                    row.Cells[j].Font.Bold = false;
                    row.Cells[j].ForeColor = System.Drawing.Color.Black;

                    if (i > 0 || j < 2)
                    {
                        row.Cells[j].Style.Add("border-style", "solid");
                        row.Cells[j].Style.Add("border-width", "thin");
                    }

                    row.Cells[j].Style.Add("vertical-align", "middle");

                    if (gvReport.Columns[j] is TemplateField)
                    {
                        //if (row.Cells[j].Controls.Count == 0)
                        //    type = "";
                        if (row.Cells[j].Controls.Count == 0)
                            type = "";
                        else
                        {
                            for (int indexControl = 0; indexControl < row.Cells[j].Controls.Count; indexControl++)
                            {
                                type = row.Cells[j].Controls[indexControl].GetType().ToString();

                                switch (type)
                                {
                                    //case "System.Web.UI.WebControls.LinkButton":
                                    //    LinkButton lb = row.Cells[j].Controls[1] as LinkButton;
                                    //    s = lb.Text.Trim();
                                    //    break;        
                                    case "System.Web.UI.WebControls.HyperLink":
                                        HyperLink hl = row.Cells[j].Controls[1] as HyperLink;
                                        s = hl.Text.Trim();
                                        break;

                                    case "System.Web.UI.WebControls.LinkButton":
                                        LinkButton lnk_btn = row.Cells[j].Controls[indexControl] as LinkButton;
                                        s = lnk_btn.Text;
                                        break;

                                    case "System.Web.UI.WebControls.CheckBoxField":
                                        CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                                        if (chk.Checked)
                                            s = "Si";
                                        else
                                            s = "No";
                                        break;

                                    case "System.Web.UI.WebControls.RadioButton":
                                        RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                                        if (rdb.Checked)
                                            s = "Si";
                                        break;

                                    case "System.Web.UI.WebControls.Label":
                                        if (string.IsNullOrEmpty(s))
                                        {
                                            Label lbl = row.Cells[j].Controls[indexControl] as Label;
                                            s = lbl.Text;
                                        }
                                        break;

                                    default:
                                        break;
                                }
                            }
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[j].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            default:
                                s = row.Cells[j].Text.Trim();
                                if (s == "&nbsp;")
                                    s = "";
                                break;
                        }
                    }

                    //row.Cells[j].Text = s;
                }
            }
        }

        gvHeader.RenderControl(hw);
        gvReport.RenderControl(hw);
        gvFooter.RenderControl(hw);

        //style to format numbers to string        
        //string style = @"<style> .textmode { mso-number-format:\@; } </style>";
        string style = @"<style> { mso-number-format:\@;";

        if (LandScape)
            style += " mso-page-orientation:landscape;";
        style += @" } </style>";

        Response.Write(style);
        Response.Output.Write(sw.ToString());
        Response.Flush();
        Response.End();
    }

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="Request">richiesta di riferimeto</param>
    /// <param name="gvReport">grid di riferimento</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab">tab place</param>
    /// <param name="title">titolo export</param>
    /// <param name="filters">filtri</param>
    /// <param name="LandScape">flag se landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="num_seduta">numero seduta</param>
    public static void ExportSeduteToPDF_ServComm(HttpResponse Response, HttpRequest Request, GridView gvReport, int id_user, string tab, string title, string[] filters, bool LandScape, string filename, int num_seduta)
    {
        float HeaderTextSize = 9;
        float ReportTextSize = 8;

        string user = GetUserName(id_user);

        gvReport.AllowPaging = false;
        //gvReport.DataBind();

        int nColumns = gvReport.Columns.Count;
        int nRows = gvReport.Rows.Count;

        // ottengo il numero di colonne che devono essere visualizzate
        int nVisCol = nColumns;
        for (int i = 0; i < nColumns; i++)
        {
            if (!gvReport.Columns[i].Visible || !gvReport.Columns[i].ShowHeader)
            {
                nVisCol--;
            }
        }

        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0, 0, 15, 5);
        }
        else
        {
            document = new Document(PageSize.A4, 0, 0, 15, 5);
        }

        // la tabella che contiene i dati per tutto il documento
        iTextSharp.text.pdf.PdfPTable MainTable = new iTextSharp.text.pdf.PdfPTable(1);

        // Creates a PdfPTable with column count of the table equal to no of columns of the gridview or gridview datasource.
        iTextSharp.text.pdf.PdfPTable GridTable = new iTextSharp.text.pdf.PdfPTable(nVisCol);

        // Sets the first 4 rows of the table as the header rows which will be repeated in all the pages.
        //mainTable.HeaderRows = 4;

        //tabella intestazione
        iTextSharp.text.pdf.PdfPTable HeaderTable = new iTextSharp.text.pdf.PdfPTable(1);

        // Creates a PdfPTable with 1 column to hold the header in the exported PDF.
        iTextSharp.text.pdf.PdfPTable InfoTable = new iTextSharp.text.pdf.PdfPTable(1);

        // cella contenente la data ed il titolo
        Phrase phTitle = new Phrase(title, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clTitle = new PdfPCell(phTitle);
        clTitle.HorizontalAlignment = Element.ALIGN_CENTER;
        clTitle.Border = PdfPCell.NO_BORDER;

        // aggiunge le celle alla tabella dell'header
        InfoTable.AddCell(clTitle);

        // Sets the border of the headerTable to zero.
        InfoTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellHeader = new PdfPCell(InfoTable);
        cellHeader.Border = PdfPCell.NO_BORDER;
        cellHeader.HorizontalAlignment = Element.ALIGN_CENTER;

        // Sets the column span of the header cell to nColumns.
        //cellHeader.Colspan = nVisCol - 1;

        //aggiunge il logo
        string logo_file_path = Request.PhysicalApplicationPath + "img/LogoTessera.png";

        iTextSharp.text.Image logo_image = iTextSharp.text.Image.GetInstance(new Uri(logo_file_path));
        //logo_image.ScaleAbsolute(115, 54);
        //logo_image.ScaleAbsolute(229, 107);
        logo_image.ScalePercent(15);

        PdfPCell cell_logo = new PdfPCell(logo_image);
        cell_logo.Border = PdfPCell.NO_BORDER;
        cell_logo.HorizontalAlignment = Element.ALIGN_CENTER;

        HeaderTable.AddCell(cell_logo);

        // Adds the above header cell to the table.
        HeaderTable.AddCell(cellHeader);

        PdfPCell cell_header = new PdfPCell(HeaderTable);
        cell_header.Border = PdfPCell.NO_BORDER;
        cell_header.HorizontalAlignment = Element.ALIGN_CENTER;

        MainTable.AddCell(cell_header);

        // cella per andare a capo
        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        //clSpace.Colspan = nVisCol;
        MainTable.AddCell(clSpace);

        float[] cell_widths = new float[nColumns];
        float[] cell_widths_header = new float[2];

        switch (num_seduta)
        {
            case 1:
                break;

            case 2:
                cell_widths_header[0] = 250;
                cell_widths_header[1] = 0;

                for (int i = 0; i < nColumns; i++)
                {
                    if (i == 0)
                    {
                        cell_widths[i] = 250;
                    }
                    else
                    {
                        cell_widths[i] = 30;
                        cell_widths_header[1] += cell_widths[i];
                    }
                }
                break;
        }

        //MainTable.CompleteRow();
        PdfPTable table_grid_header = new PdfPTable(2);

        if (num_seduta == 2)
        {
            table_grid_header.SetWidths(cell_widths_header);

            Phrase column_header0 = new Phrase("Commissione", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell column_cell0 = new PdfPCell(column_header0);
            column_cell0.HorizontalAlignment = Element.ALIGN_CENTER;
            column_cell0.VerticalAlignment = Element.ALIGN_MIDDLE;
            SetPadding(column_cell0);
            table_grid_header.AddCell(column_cell0);

            Phrase column_header1 = new Phrase("Giorno", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell column_cell1 = new PdfPCell(column_header1);
            column_cell1.HorizontalAlignment = Element.ALIGN_CENTER;
            column_cell1.VerticalAlignment = Element.ALIGN_MIDDLE;
            SetPadding(column_cell1);
            table_grid_header.AddCell(column_cell1);
        }

        //for (int i = 0; i < nColumns; i++)
        //{
        //    if ((gvReport.Columns[i].Visible) && (gvReport.Columns[i].ShowHeader))
        //    {
        //        Phrase column_header = new Phrase(gvReport.Columns[i].HeaderText, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        //        PdfPCell column_cell = new PdfPCell(column_header);
        //        column_cell.HorizontalAlignment = Element.ALIGN_CENTER;
        //        column_cell.VerticalAlignment = Element.ALIGN_MIDDLE;
        //        column_cell.Colspan = gvReport.HeaderRow.Cells[i].ColumnSpan;

        //        table_grid_header.AddCell(column_cell);
        //    }
        //}

        PdfPCell cell_grid_header = new PdfPCell(table_grid_header);
        cell_grid_header.HorizontalAlignment = Element.ALIGN_CENTER;
        cell_grid_header.Border = PdfPCell.NO_BORDER;
        MainTable.AddCell(cell_grid_header);

        string s;
        string type = "";
        string hAlign = "";

        // Reads the gridview rows and adds them to the mainTable
        for (int indexRow = 0; indexRow < nRows; indexRow++)
        {
            GridViewRow row = gvReport.Rows[indexRow];
            bool first_iter = true;

            PdfPTable data_table = new PdfPTable(nVisCol);

            if (num_seduta == 2)
            {
                data_table.SetWidths(cell_widths);
            }

            for (int indexColumn = 0; indexColumn < nColumns; indexColumn++)
            {
                if ((first_iter) && (num_seduta == 4))
                {
                    first_iter = false;
                }
                else
                {
                    s = "";

                    if (gvReport.Columns[indexColumn].Visible)
                    {
                        hAlign = gvReport.Columns[indexColumn].ItemStyle.HorizontalAlign.ToString();
                        hAlign = hAlign.ToLower();

                        if (gvReport.Columns[indexColumn] is TemplateField)
                        {
                            if (row.Cells[indexColumn].Controls.Count == 0)
                            {
                                type = "";
                            }
                            else
                            {
                                var pattern = @"^\s*\[\d+\]\s*$";
                                for (int indexControl = 0; indexControl < row.Cells[indexColumn].Controls.Count; indexControl++)
                                {
                                    type = row.Cells[indexColumn].Controls[indexControl].GetType().ToString();

                                    switch (type)
                                    {
                                        case "System.Web.UI.WebControls.HyperLink":
                                            HyperLink hl = row.Cells[indexColumn].Controls[indexControl] as HyperLink;
                                            if (Regex.IsMatch(hl.Text, pattern, RegexOptions.IgnoreCase))
                                                s += " " + hl.Text.Trim();
                                            else
                                                s = hl.Text.Trim();

                                            break;

                                        case "System.Web.UI.WebControls.LinkButton":
                                            LinkButton lnk_btn = row.Cells[indexColumn].Controls[indexControl] as LinkButton;
                                            if (Regex.IsMatch(lnk_btn.Text, pattern, RegexOptions.IgnoreCase))
                                                s += " " + lnk_btn.Text.Trim();
                                            else
                                                s = lnk_btn.Text.Trim();

                                            break;

                                        case "System.Web.UI.WebControls.CheckBoxField":
                                            CheckBox chk = row.Cells[indexColumn].Controls[indexControl] as CheckBox;
                                            if (chk.Checked)
                                            {
                                                s = "Si";
                                            }
                                            else
                                            {
                                                s = "No";
                                            }
                                            break;

                                        case "System.Web.UI.WebControls.RadioButton":
                                            RadioButton rdb = row.Cells[indexColumn].Controls[indexControl] as RadioButton;
                                            if (rdb.Checked)
                                            {
                                                s = "Si";
                                            }
                                            break;

                                        case "System.Web.UI.WebControls.Label":
                                            if (string.IsNullOrEmpty(s))
                                            {
                                                Label lbl = row.Cells[indexColumn].Controls[indexControl] as Label;
                                                s = lbl.Text.Replace("<br />", "\n");
                                            }

                                            break;

                                        default:
                                            break;
                                    }
                                }
                            }
                        }
                        else
                        {
                            type = gvReport.Columns[indexColumn].GetType().ToString();

                            switch (type)
                            {
                                case "System.Web.UI.WebControls.CheckBoxField":
                                    CheckBox chk = row.Cells[indexColumn].Controls[0] as CheckBox;
                                    if (chk.Checked)
                                    {
                                        s = "Si";
                                    }
                                    else
                                    {
                                        s = "No";
                                    }
                                    break;

                                case "System.Web.UI.WebControls.RadioButton":
                                    RadioButton rdb = row.Cells[indexColumn].Controls[0] as RadioButton;
                                    if (rdb.Checked)
                                    {
                                        s = "Si";
                                    }
                                    break;

                                default:
                                    s = row.Cells[indexColumn].Text.Trim();
                                    if (s == "&nbsp;")
                                    {
                                        s = "";
                                    }
                                    break;
                            }
                        }

                        //s = s.Replace("&#224;", "à");

                        s = System.Web.HttpUtility.HtmlDecode(s);

                        Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                        PdfPCell cell_data_column = new PdfPCell(ph);
                        SetPadding(cell_data_column);

                        switch (hAlign)
                        {
                            case "center":
                                cell_data_column.HorizontalAlignment = Element.ALIGN_CENTER;
                                break;

                            case "right":
                                cell_data_column.HorizontalAlignment = Element.ALIGN_RIGHT;
                                break;

                            case "justify":
                                cell_data_column.HorizontalAlignment = Element.ALIGN_JUSTIFIED;
                                break;

                            default:
                                cell_data_column.HorizontalAlignment = Element.ALIGN_LEFT;
                                break;
                        }

                        cell_data_column.VerticalAlignment = Element.ALIGN_MIDDLE;

                        data_table.AddCell(cell_data_column);
                    }
                }
            }

            PdfPCell cell_data_row = new PdfPCell(data_table);
            cell_data_row.Border = PdfPCell.NO_BORDER;
            cell_data_row.HorizontalAlignment = Element.ALIGN_CENTER;

            // Tells the mainTable to complete the row even if any cell is left incomplete.
            MainTable.AddCell(cell_data_row);
        }

        MainTable.CompleteRow();

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        //Phrase date_footer = new Phrase(Utility.ConvertDateTimeToDateString(DateTime.Now) + " - Pagina ");
        //HeaderFooter pdfFooter = new HeaderFooter(date_footer, true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;


        //Footer table
        PdfPTable FooterTable = new PdfPTable(3);
        FooterTable.TotalWidth = document.PageSize.Width - document.LeftMargin - document.RightMargin;

        PdfPCell FooterLeftCell = new PdfPCell(new Phrase(2, "Milano,"));
        FooterLeftCell.HorizontalAlignment = Element.ALIGN_LEFT;
        FooterLeftCell.VerticalAlignment = Element.ALIGN_CENTER;
        FooterLeftCell.Border = 0;
        FooterTable.AddCell(FooterLeftCell);

        PdfPCell FooterCenterCell = new PdfPCell(new Phrase(2, ""));
        FooterCenterCell.HorizontalAlignment = Element.ALIGN_CENTER;
        FooterCenterCell.VerticalAlignment = Element.ALIGN_CENTER;
        FooterCenterCell.Border = 0;
        FooterTable.AddCell(FooterCenterCell);

        PdfPCell FooterRightCell = new PdfPCell(new Phrase(2, "Il Dirigente"));
        FooterRightCell.HorizontalAlignment = Element.ALIGN_LEFT;
        FooterRightCell.VerticalAlignment = Element.ALIGN_CENTER;
        FooterRightCell.Border = 0;
        FooterTable.AddCell(FooterRightCell);

        PdfPCell cell_data_footer = new PdfPCell(FooterTable);
        cell_data_footer.PaddingTop = 20f;
        cell_data_footer.Border = PdfPCell.NO_BORDER;
        cell_data_footer.HorizontalAlignment = Element.ALIGN_CENTER;
        MainTable.AddCell(cell_data_footer);


        //document.Footer = null; //pdfFooter;
        document.Open();
        document.Add(MainTable);
        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();
    }

    #endregion



    #region Export 2

    /// <summary>
    /// Metodo per esportazione di gridview in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvlist">lista griglie</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo</param>
    /// <param name="no_first_col">flag prima colonna</param>
    /// <param name="no_last_col">flag utima colonna</param>
    /// <param name="LandScape">flag landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="info">informazioni export</param>
    /// <param name="filter_param">parametri filtri</param>
    /// <param name="id_seduta">id seduta di riferimento</param>
    /// <param name="diaria">flag diaria</param>
    public static void ExportToExcel2(HttpResponse Response, GridView[] gvlist, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] info, string[] filter_param, string id_seduta, bool diaria)
    {
        int ncolumns = 0, start = 0;

        string user = GetUserName(id_user);


        GridView gvdiaria = new GridView();
        GridView gvnodiaria = new GridView();
        GridView gvincontro = new GridView();
        GridView gvspace = new GridView();
        GridView gvnorecord = new GridView();

        DataTable table_diaria = Utility.CreateDataTable(1);
        DataRow tablerow_diaria = table_diaria.NewRow();
        //tablerow_diaria[0] = "CONSIGLIERI CHE HANNO OPTATO PER LA DIARIA";
        tablerow_diaria[0] = header_opzione_si;
        table_diaria.Rows.Add(tablerow_diaria);
        gvdiaria.DataSource = table_diaria;
        gvdiaria.DataBind();
        gvdiaria.GridLines = GridLines.None;
        gvdiaria.HeaderRow.Visible = false;
        gvdiaria.Rows[0].Font.Bold = true;

        DataTable table_nodiaria = Utility.CreateDataTable(1);
        DataRow tablerow_nodiaria = table_nodiaria.NewRow();
        //tablerow_nodiaria[0] = "CONSIGLIERI CHE NON HANNO OPTATO PER LA DIARIA";
        tablerow_nodiaria[0] = header_opzione_no;
        table_nodiaria.Rows.Add(tablerow_nodiaria);
        gvnodiaria.DataSource = table_nodiaria;
        gvnodiaria.DataBind();
        gvnodiaria.GridLines = GridLines.None;
        gvnodiaria.HeaderRow.Visible = false;
        gvnodiaria.Rows[0].Font.Bold = true;

        DataTable table_incontro = Utility.CreateDataTable(1);
        DataRow tablerow_incontro = table_incontro.NewRow();
        tablerow_incontro[0] = "CONSIGLIERI";
        table_incontro.Rows.Add(tablerow_incontro);
        gvincontro.DataSource = table_incontro;
        gvincontro.DataBind();
        gvincontro.GridLines = GridLines.None;
        gvincontro.HeaderRow.Visible = false;
        gvincontro.Rows[0].Font.Bold = true;

        DataTable table_norecord = Utility.CreateDataTable(1);
        DataRow tablerow_norecord = table_norecord.NewRow();
        tablerow_norecord[0] = "Nessun record trovato.";
        table_norecord.Rows.Add(tablerow_norecord);
        gvnorecord.DataSource = table_norecord;
        gvnorecord.DataBind();
        gvnorecord.GridLines = GridLines.None;
        gvnorecord.HeaderRow.Visible = false;
        gvnorecord.Rows[0].Font.Bold = false;

        DataTable table_space = Utility.CreateDataTable(1);
        DataRow tablerow_space = table_space.NewRow();
        tablerow_space[0] = "";
        table_space.Rows.Add(tablerow_space);
        gvspace.DataSource = table_space;
        gvspace.DataBind();
        gvspace.GridLines = GridLines.None;
        gvspace.HeaderRow.Visible = false;

        Response.Clear();
        Response.Buffer = true;

        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "text/html";
        Response.ContentType = "application/vnd.ms-excel";
        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        // costruisco la gridview per l'header            
        string[] cells = new string[10 + filter_param.Length + info.Length];
        cells[0] = Utility.ConvertDateTimeToDateString(DateTime.Now);
        cells[1] = title;
        cells[2] = "Richiedente:";
        cells[3] = user;
        cells[4] = "Menu:";
        cells[5] = tab_place;

        int ind_filter = 0;
        int ind_filter_header = 8;

        bool filter_present = false;
        if (filter_param.Length >= 2)
        {
            cells[6] = "";
            cells[7] = "";
            cells[8] = "Filtri:";
            cells[9] = "";
            ind_filter_header = ind_filter_header + 2;
            filter_present = true;
        }

        while (ind_filter < filter_param.Length - 1)
        {
            cells[ind_filter_header] = filter_param[ind_filter] + ":";
            cells[ind_filter_header + 1] = filter_param[ind_filter + 1];

            ind_filter = ind_filter + 2;
            ind_filter_header = ind_filter_header + 2;
        }

        if (filter_param.Length >= 2)
        {
            cells[ind_filter_header] = "";
            cells[ind_filter_header + 1] = "";

            ind_filter_header = ind_filter_header + 2;
        }

        ind_filter = 0;
        while (ind_filter < info.Length - 1)
        {
            cells[ind_filter_header] = info[ind_filter] + ":";
            cells[ind_filter_header + 1] = info[ind_filter + 1];

            ind_filter = ind_filter + 2;
            ind_filter_header = ind_filter_header + 2;
        }

        DataTable table = Utility.CreateDataTable(2);
        Utility.AddDataToTable(table, cells);

        GridView gvHeader = new GridView();
        gvHeader.DataSource = table;
        gvHeader.DataBind();

        // gestisco il layout dell'header
        gvHeader.GridLines = GridLines.None;
        gvHeader.HeaderRow.Visible = false;
        gvHeader.Rows[0].Font.Bold = true;

        if (filter_present)
        {
            gvHeader.Rows[3].Font.Bold = true;
        }

        for (int i = 0; i < gvHeader.Rows.Count; i++)
        {
            gvHeader.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            gvHeader.Rows[i].Style.Add("vertical-align", "middle");
        }

        gvHeader.RenderControl(hw);

        int gridview_inserted = 0;

        foreach (GridView gv in gvlist)
        {
            if (gv != null)
            {
                if (gridview_inserted == 0) //prima gridview
                {
                    if (diaria)
                    {
                        gvdiaria.RenderControl(hw);
                    }
                    else
                    {
                        gvincontro.RenderControl(hw);
                    }
                }
                else //gridview successive
                {
                    gvspace.RenderControl(hw);
                    gvnodiaria.RenderControl(hw);
                }

                // costruisco la gridview del report vero e proprio
                gv.AllowPaging = false;
                gv.DataBind();

                int nrows = gv.Rows.Count;

                if (nrows != 0)
                {
                    ncolumns = gv.Columns.Count;

                    if (no_last_col)
                    {
                        ncolumns = ncolumns - 1;
                        gv.Columns[ncolumns].Visible = false;
                    }

                    if (no_first_col)
                    {
                        gv.Columns[0].Visible = false;
                        start = 1;
                    }

                    // cambio il back-color degli headers a bianco
                    gv.HeaderRow.Style.Add("background-color", "#FFFFFF");

                    //applico lo stile agli header singolarmente      
                    for (int i = start; i < ncolumns; i++)
                    {
                        gv.HeaderRow.Cells[i].Style.Add("border-style", "solid");
                        gv.HeaderRow.Cells[i].Style.Add("border-width", "thin");
                        gv.HeaderRow.Cells[i].Style.Add("text-font", "bold");
                        gv.HeaderRow.Cells[i].Text = Convert.ToString(gv.Columns[i].HeaderText);
                    }



                    for (int i = 0; i < gv.Rows.Count; i++)
                    {
                        GridViewRow row = gv.Rows[i];
                        row.Font.Bold = false;

                        string id_persona = Convert.ToString(gv.DataKeys[i].Values[0]);

                        string query_partecipazione = @"SELECT jj.tipo_partecipazione, 
                                                               pp.cognome + ' ' +  pp.nome AS sostituto,
                                                               jj.presenza_effettiva
				                                        FROM join_persona_sedute AS jj 
                                                        LEFT OUTER JOIN persona AS pp 
                                                          ON jj.sostituito_da = pp.id_persona 
				                                        WHERE jj.deleted = 0
                                                          AND jj.copia_commissioni = 0 
                                                          AND jj.id_seduta = " + id_seduta +
                                                        " AND jj.id_persona = " + id_persona;

                        DataTableReader reader_partecipazione = Utility.ExecuteQuery(query_partecipazione);
                        reader_partecipazione.Read();

                        string tipo_partecipazione = reader_partecipazione[0].ToString();
                        string nome_sostituito = reader_partecipazione[1].ToString();
                        bool presenza_effettiva = Convert.ToBoolean(reader_partecipazione[2]);

                        if (nome_sostituito == null)
                        {
                            nome_sostituito = "";
                        }

                        switch (tipo_partecipazione)
                        {
                            case "P1":
                                RadioButton cp = row.FindControl("rbtn_presente") as RadioButton;
                                cp.Checked = true;
                                break;

                            case "P2":
                                RadioButton ce = row.FindControl("rbtn_ritardo") as RadioButton;
                                ce.Checked = true;

                                RadioButton ce2 = row.FindControl("rbtn_ritardo_2") as RadioButton;
                                ce2.Checked = true;

                                break;

                            case "C1":
                                RadioButton cg = row.FindControl("rbtn_congedo") as RadioButton;
                                cg.Checked = true;
                                break;

                            case "A2":
                                RadioButton ca = row.FindControl("rbtn_assente") as RadioButton;
                                ca.Checked = true;
                                break;
                        }

                        if (presenza_effettiva)
                        {
                            CheckBox chkbox = row.FindControl("chkbox_pres_eff") as CheckBox;
                            chkbox.Checked = true;
                        }

                        for (int j = start; j < ncolumns; j++)
                        {
                            string s = "";
                            string type;

                            // cambio il back-color a bianco
                            row.BackColor = System.Drawing.Color.White;

                            // applico lo stile ad ogni cella 
                            row.Attributes.Add("class", "textmode");

                            // applico lo stile alla cella
                            row.Cells[j].Font.Bold = false;

                            row.Cells[j].Style.Add("border-style", "solid");
                            row.Cells[j].Style.Add("border-width", "thin");
                            row.Cells[j].Style.Add("vertical-align", "middle");

                            if (gv.Columns[j] is TemplateField)
                            {
                                type = row.Cells[j].Controls[1].GetType().ToString();

                                switch (type)
                                {
                                    case "System.Web.UI.WebControls.LinkButton":
                                        LinkButton lb = row.Cells[j].Controls[1] as LinkButton;
                                        s = lb.Text.Trim();
                                        break;

                                    case "System.Web.UI.WebControls.HyperLink":
                                        HyperLink hl = row.Cells[j].Controls[1] as HyperLink;
                                        s = hl.Text.Trim();
                                        break;

                                    case "System.Web.UI.WebControls.CheckBox":
                                        CheckBox chk = row.Cells[j].Controls[1] as CheckBox;

                                        if (chk.Checked)
                                        {
                                            s = "Si";
                                        }
                                        else
                                        {
                                            s = "No";
                                        }
                                        break;

                                    case "System.Web.UI.WebControls.RadioButton":
                                        RadioButton rdb = row.Cells[j].Controls[1] as RadioButton;

                                        if (rdb.Checked)
                                        {
                                            s = "Si";
                                        }
                                        break;

                                    case "System.Web.UI.WebControls.Label":
                                        s = nome_sostituito;
                                        row.Cells[j].HorizontalAlign = HorizontalAlign.Left;
                                        break;

                                    default:
                                        break;
                                }
                            }
                            else
                            {
                                type = gv.Columns[j].GetType().ToString();

                                switch (type)
                                {
                                    case "System.Web.UI.WebControls.CheckBoxField":
                                        CheckBox chk = row.Cells[j].Controls[0] as CheckBox;

                                        if (chk.Checked)
                                        {
                                            s = "Si";
                                        }
                                        else
                                        {
                                            s = "No";
                                        }
                                        break;

                                    case "System.Web.UI.WebControls.RadioButton":
                                        RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;

                                        if (rdb.Checked)
                                        {
                                            s = "Si";
                                        }
                                        break;

                                    default:
                                        s = row.Cells[j].Text.Trim();

                                        if (s == "&nbsp;")
                                        {
                                            s = "";
                                        }
                                        break;
                                }
                            }

                            row.Cells[j].Text = s;
                        }
                    }

                    gv.RenderControl(hw);
                    gridview_inserted++;
                }
                else
                {
                    gvnorecord.RenderControl(hw);
                    gridview_inserted++;
                }
            }
        }

        //style to format numbers to string
        string style = @"<style> .textmode { mso-number-format:\@; } </style>";
        Response.Write(style);
        Response.Output.Write(sw.ToString());
        Response.Flush();
        Response.End();
    }


    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvlist">lista griglie</param>
    /// <param name="id_user">id utente di riferimento</param>
    /// <param name="tab_place">tab place</param>
    /// <param name="title">titolo</param>
    /// <param name="no_first_col">flag prima colonna</param>
    /// <param name="no_last_col">flag utima colonna</param>
    /// <param name="LandScape">flag landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="info">informazioni export</param>
    /// <param name="filter_param">parametri filtri</param>
    /// <param name="id_seduta">id seduta di riferimento</param>
    /// <param name="diaria">flag diaria</param>
    public static void ExportToPDF2(HttpResponse Response, GridView[] gvlist, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] info, string[] filter_param, string id_seduta, bool diaria)
    {
        float HeaderTextSize = 9;
        //float ReportNameSize = 10;
        float ReportTextSize = 8;
        //float ApplicationNameSize = 7;

        //Phrase phtop_title = new Phrase("CONSIGLIERI CHE HANNO OPTATO PER LA DIARIA", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        Phrase phtop_title = new Phrase(header_opzione_si, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell cltop_title = new PdfPCell(phtop_title);
        cltop_title.HorizontalAlignment = Element.ALIGN_LEFT;
        cltop_title.Border = PdfPCell.NO_BORDER;

        //Phrase phmiddle_title = new Phrase("CONSIGLIERI CHE NON HANNO OPTATO PER LA DIARIA", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        Phrase phmiddle_title = new Phrase(header_opzione_no, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clmiddle_title = new PdfPCell(phmiddle_title);
        clmiddle_title.HorizontalAlignment = Element.ALIGN_LEFT;
        clmiddle_title.Border = PdfPCell.NO_BORDER;

        Phrase phtitle = new Phrase("CONSIGLIERI", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell cltitle = new PdfPCell(phtitle);
        cltitle.HorizontalAlignment = Element.ALIGN_LEFT;
        cltitle.Border = PdfPCell.NO_BORDER;

        Phrase phnorecord = new Phrase("Nessun record trovato.", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clnorecord = new PdfPCell(phnorecord);
        clnorecord.HorizontalAlignment = Element.ALIGN_LEFT;
        clnorecord.Border = PdfPCell.NO_BORDER;

        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        clSpace.Colspan = 1;

        int noOfColumns = 0, noOfRows = 0;
        DataTable tbl = null;

        string user = GetUserName(id_user);


        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0, 0, 15, 5);
        }
        else
        {
            document = new Document(PageSize.A4, 0, 0, 15, 5);
        }

        iTextSharp.text.pdf.PdfPTable mainTable = new PdfPTable(1);
        mainTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Sets the first 4 rows of the table as the header rows which will be repeated in all the pages.
        //mainTable.HeaderRows = 3;        

        // Creates a PdfPTable with 1 column to hold the header in the exported PDF.
        iTextSharp.text.pdf.PdfPTable headerTable = new iTextSharp.text.pdf.PdfPTable(1);

        // cella contenente la data ed il titolo
        Phrase phDate = new Phrase(DateTime.Now.Date.ToString("dd/MM/yyyy") + " - " + title, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clDate = new PdfPCell(phDate);
        clDate.HorizontalAlignment = Element.ALIGN_LEFT;
        clDate.Border = PdfPCell.NO_BORDER;

        // cella contenente il nome del richiedente
        Phrase phUser = new Phrase("Richiedente: " + user, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clUser = new PdfPCell(phUser);
        clUser.Border = PdfPCell.NO_BORDER;
        clUser.HorizontalAlignment = Element.ALIGN_LEFT;

        // cella contenente la tab da dove si è richiesta l'esportazione
        Phrase phTab = new Phrase("Menù: " + tab_place, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clTab = new PdfPCell(phTab);
        clTab.Border = PdfPCell.NO_BORDER;
        clTab.HorizontalAlignment = Element.ALIGN_LEFT;

        // aggiunge le celle alla tabella dell'header
        headerTable.AddCell(clDate);
        headerTable.AddCell(clUser);
        headerTable.AddCell(clTab);

        // cella contenente la voce Filtri
        if (filter_param.Length >= 2)
        {
            Phrase phFiltri = new Phrase("Filtri:", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell clFiltri = new PdfPCell(phFiltri);
            clFiltri.Border = PdfPCell.NO_BORDER;
            clFiltri.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFiltri);
        }

        Phrase phFilterCell;
        PdfPCell clFilterCell;
        int ind = 0;
        while (ind < filter_param.Length - 1)
        {
            phFilterCell = new Phrase("  " + filter_param[ind] + ": " + filter_param[ind + 1], FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
            clFilterCell = new PdfPCell(phFilterCell);
            clFilterCell.Border = PdfPCell.NO_BORDER;
            clFilterCell.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFilterCell);

            ind = ind + 2;
        }

        // cella per andare a capo        
        headerTable.AddCell(clSpace);

        ind = 0;
        while (ind < info.Length - 1)
        {
            phFilterCell = new Phrase("  " + info[ind] + ": " + info[ind + 1], FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
            clFilterCell = new PdfPCell(phFilterCell);
            clFilterCell.Border = PdfPCell.NO_BORDER;
            clFilterCell.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFilterCell);

            ind = ind + 2;
        }

        // Sets the border of the headerTable to zero.
        headerTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellHeader = new PdfPCell(headerTable);
        cellHeader.Border = PdfPCell.NO_BORDER;

        // Sets the column span of the header cell to noOfColumns.
        cellHeader.Colspan = 1;

        // Adds the above header cell to the table.
        mainTable.AddCell(cellHeader);

        // cella per separare l'header dalla tabella
        Phrase phSeparator = new Phrase("_____________________________________________________________________");
        PdfPCell clSeparator = new PdfPCell(phSeparator);
        clSeparator.Border = PdfPCell.NO_BORDER;
        clSeparator.Colspan = 1;
        clSeparator.HorizontalAlignment = Element.ALIGN_CENTER;
        mainTable.AddCell(clSeparator);

        // cella per andare a capo
        mainTable.AddCell(clSpace);

        int grid_inserted = 0;

        foreach (GridView gv in gvlist)
        {
            if (gv != null)
            {
                PdfPTable grid_table = new PdfPTable(1);
                grid_table.DefaultCell.Border = PdfPCell.NO_BORDER;

                if (grid_inserted == 0) //prima gridview
                {
                    if (diaria)
                    {
                        grid_table.AddCell(cltop_title);
                    }
                    else
                    {
                        grid_table.AddCell(cltitle);
                    }
                }
                else //gridview successive
                {
                    grid_table.AddCell(clmiddle_title);
                }

                if (gv.AutoGenerateColumns)
                {
                    tbl = gv.DataSource as DataTable; // Gets the DataSource of the GridView Control.

                    if (no_last_col)
                        noOfColumns = tbl.Columns.Count - 1;
                    else
                        noOfColumns = tbl.Columns.Count;
                }
                else
                {
                    if (no_last_col)
                        noOfColumns = gv.Columns.Count - 1;
                    else
                        noOfColumns = gv.Columns.Count;
                }

                int start = 0;

                if (no_first_col)
                {
                    start = 1;
                }

                noOfRows = gv.Rows.Count;

                if (noOfRows != 0)
                {
                    int n = noOfColumns;

                    for (int i = start; i < noOfColumns; i++)
                    {
                        if (gv.Columns[i].Visible == false)
                        {
                            n--;
                        }
                    }

                    iTextSharp.text.pdf.PdfPTable tmp_table = new PdfPTable(n);

                    // Sets the gridview column names as table headers.
                    for (int i = start; i < noOfColumns; i++)
                    {
                        if (gv.Columns[i].Visible)
                        {
                            Phrase ph = null;
                            PdfPCell phcell = null;

                            if (gv.AutoGenerateColumns)
                            {
                                ph = new Phrase(tbl.Columns[i].ColumnName, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
                            }
                            else
                            {
                                ph = new Phrase(gv.Columns[i].HeaderText, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
                            }

                            phcell = new PdfPCell(ph);
                            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                            phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
                            tmp_table.AddCell(phcell);
                        }
                    }

                    gv.AllowPaging = false;
                    gv.DataBind();

                    // Reads the gridview rows and adds them to the mainTable
                    for (int rowNo = 0; rowNo < noOfRows; rowNo++)
                    {
                        GridViewRow row = gv.Rows[rowNo];

                        string id_persona = Convert.ToString(gv.DataKeys[rowNo].Values[0]);

                        string query_partecipazione = @"SELECT jj.tipo_partecipazione, 
                                                               pp.cognome + ' ' +  pp.nome AS sostituto,
                                                               jj.presenza_effettiva,
                                                               jj.presente_in_uscita
				                                        FROM join_persona_sedute AS jj 
                                                        LEFT OUTER JOIN persona AS pp 
                                                          ON jj.sostituito_da = pp.id_persona 
				                                        WHERE jj.deleted = 0 
                                                          AND jj.copia_commissioni = 0 
                                                          AND jj.id_seduta = " + id_seduta +
                                                        " AND jj.id_persona = " + id_persona;

                        DataTableReader reader_partecipazione = Utility.ExecuteQuery(query_partecipazione);

                        if (reader_partecipazione.HasRows)
                        {
                            reader_partecipazione.Read();

                            string tipo_partecipazione = reader_partecipazione[0].ToString();
                            string nome_sostituito = reader_partecipazione[1].ToString();
                            bool presenza_effettiva = Convert.ToBoolean(reader_partecipazione[2]);
                            bool presente_in_uscita = Convert.ToBoolean(reader_partecipazione[3]);
                            if (nome_sostituito == null)
                            {
                                nome_sostituito = "";
                            }

                            switch (tipo_partecipazione)
                            {
                                case "P1":
                                    RadioButton cp = row.FindControl("rbtn_presente") as RadioButton;
                                    cp.Checked = true;
                                    break;

                                case "P2":
                                    RadioButton ce = row.FindControl("rbtn_ritardo") as RadioButton;
                                    ce.Checked = true;

                                    RadioButton ce2 = row.FindControl("rbtn_ritardo_2") as RadioButton;
                                    ce2.Checked = true;
                                    break;

                                case "C1":
                                    RadioButton cg = row.FindControl("rbtn_congedo") as RadioButton;
                                    cg.Checked = true;
                                    break;

                                case "A2":
                                    RadioButton ca = row.FindControl("rbtn_assente") as RadioButton;
                                    ca.Checked = true;
                                    break;
                            }

                            if (presenza_effettiva)
                            {
                                CheckBox chkbox = row.FindControl("chkbox_pres_eff") as CheckBox;
                                chkbox.Checked = true;
                            }

                            if (presente_in_uscita)
                            {
                                CheckBox chkbox = row.FindControl("chkbox_pres_usc") as CheckBox;
                                chkbox.Checked = true;
                            }




                            for (int columnNo = start; columnNo < noOfColumns; columnNo++)
                            {
                                if (gv.Columns[columnNo].Visible)
                                {
                                    string s = "";
                                    string type = "";
                                    string hAlign = "";

                                    hAlign = gv.Columns[columnNo].ItemStyle.HorizontalAlign.ToString();
                                    hAlign = hAlign.ToLower();

                                    if (gv.AutoGenerateColumns)
                                    {
                                        s = row.Cells[columnNo].Text.Trim();
                                    }
                                    else
                                    {
                                        if (gv.Columns[columnNo] is TemplateField)
                                        {
                                            if (row.Cells[columnNo].Controls.Count == 0)
                                                type = "";
                                            else
                                                type = row.Cells[columnNo].Controls[1].GetType().ToString();

                                            switch (type)
                                            {
                                                case "System.Web.UI.WebControls.LinkButton":
                                                    LinkButton lb = row.Cells[columnNo].Controls[1] as LinkButton;
                                                    s = lb.Text.Trim();
                                                    break;

                                                case "System.Web.UI.WebControls.HyperLink":
                                                    HyperLink hl = row.Cells[columnNo].Controls[1] as HyperLink;
                                                    s = hl.Text.Trim();
                                                    break;

                                                case "System.Web.UI.WebControls.CheckBox":
                                                    CheckBox chk = row.Cells[columnNo].Controls[1] as CheckBox;

                                                    if (chk.Checked)
                                                    {
                                                        s = "Si";
                                                    }
                                                    else
                                                    {
                                                        s = "No";
                                                    }
                                                    break;

                                                case "System.Web.UI.WebControls.RadioButton":
                                                    RadioButton rdb = row.Cells[columnNo].Controls[1] as RadioButton;

                                                    if (rdb.Checked)
                                                    {
                                                        s = "Si";
                                                    }
                                                    break;

                                                case "System.Web.UI.WebControls.Label":
                                                    s = nome_sostituito;
                                                    hAlign = "left";
                                                    break;

                                                default:
                                                    s = "";
                                                    break;
                                            }
                                        }
                                        else
                                        {
                                            type = gv.Columns[columnNo].GetType().ToString();

                                            switch (type)
                                            {
                                                case "System.Web.UI.WebControls.CheckBoxField":
                                                    CheckBox chk = row.Cells[columnNo].Controls[0] as CheckBox;

                                                    if (chk.Checked)
                                                    {
                                                        s = "Si";
                                                    }
                                                    else
                                                    {
                                                        s = "No";
                                                    }
                                                    break;

                                                case "System.Web.UI.WebControls.RadioButton":
                                                    RadioButton rdb = row.Cells[columnNo].Controls[1] as RadioButton;

                                                    if (rdb.Checked)
                                                    {
                                                        s = "Si";
                                                    }
                                                    break;

                                                default:
                                                    s = row.Cells[columnNo].Text.Trim();

                                                    if (s == "&nbsp;")
                                                    {
                                                        s = "";
                                                    }
                                                    break;
                                            }
                                        }
                                    }

                                    //s = s.Replace("&#224;", "à");

                                    s = System.Web.HttpUtility.HtmlDecode(s);

                                    Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                                    PdfPCell phcell = new PdfPCell(ph);

                                    switch (hAlign)
                                    {
                                        case "center":
                                            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                                            break;

                                        case "right":
                                            phcell.HorizontalAlignment = Element.ALIGN_RIGHT;
                                            break;

                                        default:
                                            phcell.HorizontalAlignment = Element.ALIGN_LEFT;
                                            break;
                                    }

                                    phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
                                    tmp_table.AddCell(phcell);
                                }
                            }

                            // Tells the mainTable to complete the row even if any cell is left incomplete.
                            tmp_table.CompleteRow();
                        }
                    }

                    grid_table.AddCell(tmp_table);
                    mainTable.AddCell(grid_table);
                    grid_inserted++;
                }
                else
                {
                    grid_table.AddCell(clnorecord);
                    mainTable.AddCell(grid_table);
                    grid_inserted++;
                }
            }
        }

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        //HeaderFooter pdfFooter = new HeaderFooter(new Phrase(), true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        // Sets the document footer to pdfFooter.
        //document.Footer = pdfFooter;
        // Opens the document.
        document.Open();
        // Adds the mainTable to the document.
        document.Add(mainTable);
        // Closes the document.
        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();
    }
    #endregion


    #region Stampa Schede

    /// <summary>
    /// n_info_scheda
    /// n_info_incarico
    /// </summary>
    static int n_info_scheda = 9, n_info_incarico = 4;

    /// <summary>
    /// query_info_scheda
    /// </summary>
    static string query_info_scheda = @"SELECT ll.num_legislatura AS legislatura,
                                               pp.cognome + ' ' + pp.nome AS consigliere,
                                               COALESCE(LTRIM(RTRIM(gg.nome_gruppo)), 'NESSUN GRUPPO') AS gruppo_consiliare,
                                               COALESCE(CONVERT(varchar, jpoc.data_proclamazione, 103), 'N/A') AS data_proclamazione,
                                               CONVERT(varchar, sc.data, 103) AS data,
                                               COALESCE('n° ' + ss.numero_seduta + ' del ' + CONVERT(varchar, ss.data_seduta, 103), 'N/A') AS info_seduta,
                                               LTRIM(RTRIM(sc.indicazioni_gde)) AS indicazioni_gde,
                                               LTRIM(RTRIM(sc.indicazioni_seg)) AS indicazioni_seg
                                        FROM scheda AS sc
                                        INNER JOIN persona AS pp
                                           ON sc.id_persona = pp.id_persona
                                        INNER JOIN legislature AS ll
                                           ON sc.id_legislatura = ll.id_legislatura
                                        INNER JOIN join_persona_organo_carica AS jpoc
                                           ON (pp.id_persona = jpoc.id_persona AND ll.id_legislatura = jpoc.id_legislatura)
                                        INNER JOIN organi AS oo
                                           ON jpoc.id_organo = oo.id_organo
                                        INNER JOIN cariche AS cc
                                           ON jpoc.id_carica = cc.id_carica
                                        LEFT OUTER JOIN gruppi_politici AS gg
                                           ON (sc.id_gruppo = gg.id_gruppo AND gg.deleted = 0)
                                        LEFT OUTER JOIN sedute AS ss
                                           ON (sc.id_seduta = ss.id_seduta AND ss.deleted = 0)
                                        WHERE sc.deleted = 0
                                          AND pp.deleted = 0
                                          AND jpoc.deleted = 0
                                          AND oo.deleted = 0
                                          AND (id_tipo_carica = 4 -- consigliere regionale
                                                AND 
                                                id_categoria_organo = 1 -- consiglio regionale
                                                )
                                               OR
                                               (id_tipo_carica = 3 -- assessore non consigliere
                                                AND 
                                                id_categoria_organo = 4 -- giunta regionale
                                                ))
                                          AND sc.id_scheda = @id_scheda";

    /// <summary>
    /// query_info_incarichi
    /// </summary>
    static string query_info_incarichi = @"SELECT LTRIM(RTRIM(ii.nome_incarico)) AS incarico,
                                                  COALESCE(LTRIM(RTRIM(ii.riferimenti_normativi)), '') AS riferimenti,
                                                  COALESCE(LTRIM(RTRIM(ii.data_cessazione)), '') AS data_cessazione,
                                                  COALESCE(LTRIM(RTRIM(ii.note_istruttorie)), '') AS note
                                           FROM incarico AS ii
                                           INNER JOIN scheda AS sc
                                              ON sc.id_scheda = ii.id_scheda
                                           WHERE sc.deleted = 0
                                             AND ii.deleted = 0
                                             AND sc.id_scheda = @id_scheda";

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="p_response">output pagina</param>
    /// <param name="p_gridview">grid di riferimento</param>
    /// <param name="p_filename">nome file</param>
    public static void StampaSchedePDF(HttpResponse p_response, GridView p_gridview, string p_filename)
    {
        // crea un documento A4, in formato landscape
        Document document = new Document(PageSize.A4.Rotate(), 5, 5, 5, 5);

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, p_response.OutputStream);

        // Creates a footer for the PDF document.
        Phrase date_footer = new Phrase(Utility.ConvertDateTimeToDateString(DateTime.Now) + " - Pagina ");
        //HeaderFooter pdfFooter = new HeaderFooter(date_footer, true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        //document.Footer = pdfFooter;

        // apro il documento
        document.Open();

        foreach (GridViewRow row in p_gridview.Rows)
        {
            int row_index = row.RowIndex;

            string id_scheda = p_gridview.DataKeys[row_index].Value.ToString();

            string[] info_scheda = GetInfoScheda(id_scheda);

            ArrayList info_incarichi = GetInfoIncarichi(id_scheda);

            iTextSharp.text.pdf.PdfPTable table_scheda = GetTableScheda(info_scheda, info_incarichi);

            // aggiungo la tabella della scheda al documento
            document.Add(table_scheda);

            document.NewPage();
        }

        // chiudo il documento
        document.Close();

        p_response.Charset = "text/html";
        p_response.ContentType = "application/pdf";
        p_response.AddHeader("content-disposition", "attachment; filename=" + p_filename + ".pdf");
        p_response.End();
    }

    /// <summary>
    /// Metodo per estrarre Informazioni scheda
    /// </summary>
    /// <param name="p_id_scheda">id di riferimento</param>
    /// <returns>array di stringhe informazioni</returns>
    protected static string[] GetInfoScheda(string p_id_scheda)
    {
        string[] r_info_scheda = new string[n_info_scheda];

        string query_scheda = query_info_scheda.Replace("@id_scheda", p_id_scheda);

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(query_scheda, conn);

        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            r_info_scheda[0] = "GIUNTA DELLE ELEZIONI";
            r_info_scheda[1] = reader[0].ToString();
            r_info_scheda[2] = reader[1].ToString();
            r_info_scheda[3] = reader[2].ToString();
            r_info_scheda[4] = reader[3].ToString();
            r_info_scheda[5] = reader[4].ToString();
            r_info_scheda[6] = reader[5].ToString();
            r_info_scheda[7] = reader[6].ToString();
            r_info_scheda[8] = reader[7].ToString();
            break;
        }

        reader.Close();
        reader.Dispose();

        conn.Close();
        conn.Dispose();

        return r_info_scheda;
    }

    /// <summary>
    /// Metodo per estrarre Informazioni incarichi
    /// </summary>
    /// <param name="p_id_scheda">id di riferimento</param>
    /// <returns>ArrayList Informazioni incarichi</returns>
    protected static ArrayList GetInfoIncarichi(string p_id_scheda)
    {
        ArrayList r_info_incarichi = new ArrayList();

        string query_incarichi = query_info_incarichi.Replace("@id_scheda", p_id_scheda);

        SqlConnection conn = new SqlConnection(conn_string);
        conn.Open();

        SqlCommand cmd = new SqlCommand(query_incarichi, conn);

        SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            string[] incarico = new string[n_info_incarico];

            for (int i = 0; i < reader.FieldCount; i++)
            {
                incarico[i] = reader[i].ToString();
            }

            r_info_incarichi.Add(incarico);
        }

        reader.Close();
        reader.Dispose();

        conn.Close();
        conn.Dispose();

        return r_info_incarichi;
    }

    /// <summary>
    /// Metodo per generazione PdfPTable
    /// </summary>
    /// <param name="p_info_scheda">informazioni scheda</param>
    /// <param name="p_info_incarichi">lista incarichi</param>
    /// <returns>PdfPTable</returns>
    public static PdfPTable GetTableScheda(string[] p_info_scheda, ArrayList p_info_incarichi)
    {
        // dimensioni del testo
        float TextSize_Title = 10;
        float TextSize_Normal = 10;

        string title = "INCARICHI EXTRA ISTITUZIONALI";

        string organo = p_info_scheda[0];
        string legislatura = p_info_scheda[1];
        string consigliere = p_info_scheda[2];
        string gruppo_consiliare = p_info_scheda[3];
        string data_proclamazione = p_info_scheda[4];
        string data_dichiarazione = p_info_scheda[5];
        string info_seduta = p_info_scheda[6];
        string indicazioni_gde = p_info_scheda[7];
        string indicazioni_seg = p_info_scheda[8];

        // campi della scheda
        string[] headers_scheda = new string[p_info_scheda.Length];
        headers_scheda[0] = organo;
        headers_scheda[1] = "LEGISLATURA:";
        headers_scheda[2] = "CONSIGLIERE:";
        headers_scheda[3] = "GRUPPO CONSILIARE:";
        headers_scheda[4] = "DATA PROCLAMAZIONE:";
        headers_scheda[5] = "DICHIARAZIONE DEL:";
        headers_scheda[6] = "SEDUTA:";
        headers_scheda[7] = "INDICAZIONI GDE:";
        headers_scheda[8] = "INDICAZIONI SEGRETERIA:";

        // crea un documento A4, in formato landscape
        Document document = new Document(PageSize.A4.Rotate(), 5, 5, 5, 5);

        int n_columns = 4;

        iTextSharp.text.pdf.PdfPTable r_table_scheda = new iTextSharp.text.pdf.PdfPTable(n_columns);
        r_table_scheda.DefaultCell.Border = PdfPCell.NO_BORDER;
        r_table_scheda.WidthPercentage = 95;

        // ampiezza delle colonne
        float[] cell_widths = new float[n_columns];
        cell_widths[0] = 380;
        cell_widths[1] = 120;
        cell_widths[2] = 120;
        cell_widths[3] = 380;

        r_table_scheda.SetWidths(cell_widths);

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
        r_table_scheda.AddCell(cell_empty_row);
        r_table_scheda.AddCell(cell_empty_row);

        // TITOLO
        Phrase phrase_title = new Phrase(title, FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_title = new PdfPCell(phrase_title);
        cell_title.Colspan = n_columns;
        cell_title.Border = PdfPCell.NO_BORDER;
        cell_title.HorizontalAlignment = Element.ALIGN_CENTER;

        r_table_scheda.AddCell(cell_title);

        // riga vuota
        r_table_scheda.AddCell(cell_empty_row);
        r_table_scheda.AddCell(cell_empty_row);

        // tabella degli header
        iTextSharp.text.pdf.PdfPTable table_info_scheda = BuildTable_InfoScheda_Upper(p_info_scheda);

        PdfPCell cell_info_scheda = new PdfPCell(table_info_scheda);
        cell_info_scheda.Colspan = n_columns;
        cell_info_scheda.Border = PdfPCell.NO_BORDER;
        cell_info_scheda.HorizontalAlignment = Element.ALIGN_CENTER;

        r_table_scheda.AddCell(cell_info_scheda);

        // riga vuota
        r_table_scheda.AddCell(cell_empty_row);
        r_table_scheda.AddCell(cell_empty_row);

        // LISTA INCARICHI
        BuildTable_Incarichi(p_info_incarichi, r_table_scheda, n_columns);

        // riga vuota
        r_table_scheda.AddCell(cell_empty_row);
        r_table_scheda.AddCell(cell_empty_row);

        // INDICAZIONI GDE
        Phrase phrase_indicazioni_gde = new Phrase(headers_scheda[7], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_indicazioni_gde = new PdfPCell(phrase_indicazioni_gde);
        cell_indicazioni_gde.Colspan = n_columns;
        cell_indicazioni_gde.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_gde.HorizontalAlignment = Element.ALIGN_LEFT;

        r_table_scheda.AddCell(cell_indicazioni_gde);

        Phrase phrase_indicazioni_gde_val = new Phrase(indicazioni_gde, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_indicazioni_gde_val = new PdfPCell(phrase_indicazioni_gde_val);
        cell_indicazioni_gde_val.Colspan = n_columns;
        cell_indicazioni_gde_val.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_gde_val.HorizontalAlignment = Element.ALIGN_LEFT;

        r_table_scheda.AddCell(cell_indicazioni_gde_val);

        // riga vuota
        r_table_scheda.AddCell(cell_empty_row);
        r_table_scheda.AddCell(cell_empty_row);

        // INDICAZIONI SEGRETERIA
        Phrase phrase_indicazioni_segreteria = new Phrase(headers_scheda[8], FontFactory.GetFont("Arial", TextSize_Title, iTextSharp.text.Font.BOLD));
        PdfPCell cell_indicazioni_segreteria = new PdfPCell(phrase_indicazioni_segreteria);
        cell_indicazioni_segreteria.Colspan = n_columns;
        cell_indicazioni_segreteria.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_segreteria.HorizontalAlignment = Element.ALIGN_LEFT;

        r_table_scheda.AddCell(cell_indicazioni_segreteria);

        Phrase phrase_indicazioni_segreteria_val = new Phrase(indicazioni_seg, FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
        PdfPCell cell_indicazioni_segreteria_val = new PdfPCell(phrase_indicazioni_segreteria_val);
        cell_indicazioni_segreteria_val.Colspan = n_columns;
        cell_indicazioni_segreteria_val.Border = PdfPCell.NO_BORDER;
        cell_indicazioni_segreteria_val.HorizontalAlignment = Element.ALIGN_LEFT;

        r_table_scheda.AddCell(cell_indicazioni_segreteria_val);

        // chiudo la tabella
        r_table_scheda.CompleteRow();

        return r_table_scheda;
    }

    /// <summary>
    /// Metodo per generazione PdfPTable
    /// </summary>
    /// <param name="p_info_scheda">informazioni scheda</param>
    /// <returns>PdfPTable</returns>
    public static PdfPTable BuildTable_InfoScheda_Upper(string[] p_info_scheda)
    {
        // dimensioni del testo
        float TextSize_Title = 10;
        float TextSize_Normal = 10;

        string organo = p_info_scheda[0];
        string legislatura = p_info_scheda[1];
        string consigliere = p_info_scheda[2];
        string gruppo_consiliare = p_info_scheda[3];
        string data_proclamazione = p_info_scheda[4];
        string data_dichiarazione = p_info_scheda[5];
        string info_seduta = p_info_scheda[6];

        // campi della scheda
        string[] headers_scheda = new string[p_info_scheda.Length];
        headers_scheda[0] = organo;
        headers_scheda[1] = "LEGISLATURA:";
        headers_scheda[2] = "CONSIGLIERE:";
        headers_scheda[3] = "GRUPPO CONSILIARE:";
        headers_scheda[4] = "DATA PROCLAMAZIONE:";
        headers_scheda[5] = "DICHIARAZIONE DEL:";
        headers_scheda[6] = "SEDUTA:";

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
    /// Metodo per generazione PdfPTable
    /// </summary>
    /// <param name="p_incarichi">lista incarichi</param>
    /// <param name="p_table">table di riferimento</param>
    /// <param name="p_n_columns">numero di colonne</param>
    public static void BuildTable_Incarichi(ArrayList p_incarichi, PdfPTable p_table, int p_n_columns)
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
            headers_incarico[0] = "CARICHE, INCARICHI, UFFICI, PROFESSIONI, ECC.";
            headers_incarico[1] = "RIFERIMENTI NORMATIVI";
            headers_incarico[2] = "DATA CESSAZIONE";
            headers_incarico[3] = "NOTE ISTRUTTORIE";

            // HEADERS
            Phrase phrase_header_1 = new Phrase(headers_incarico[0], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            PdfPCell cell_header_1 = new PdfPCell(phrase_header_1);
            cell_header_1.HorizontalAlignment = Element.ALIGN_CENTER;

            Phrase phrase_header_2 = new Phrase(headers_incarico[1], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            PdfPCell cell_header_2 = new PdfPCell(phrase_header_2);
            cell_header_2.HorizontalAlignment = Element.ALIGN_CENTER;

            Phrase phrase_header_3 = new Phrase(headers_incarico[2], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            PdfPCell cell_header_3 = new PdfPCell(phrase_header_3);
            cell_header_3.HorizontalAlignment = Element.ALIGN_CENTER;

            Phrase phrase_header_4 = new Phrase(headers_incarico[3], FontFactory.GetFont("Arial", TextSize_Header, iTextSharp.text.Font.BOLD));
            PdfPCell cell_header_4 = new PdfPCell(phrase_header_4);
            cell_header_4.HorizontalAlignment = Element.ALIGN_CENTER;

            p_table.AddCell(cell_header_1);
            p_table.AddCell(cell_header_2);
            p_table.AddCell(cell_header_3);
            p_table.AddCell(cell_header_4);

            for (int i = 0; i < p_incarichi.Count; i++)
            {
                string[] incarico = (string[])p_incarichi[i];

                // FIELDS
                Phrase phrase_field_1 = new Phrase(incarico[0], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_1 = new PdfPCell(phrase_field_1);
                cell_field_1.Border = PdfPCell.LEFT_BORDER | PdfPCell.RIGHT_BORDER;
                cell_field_1.HorizontalAlignment = Element.ALIGN_LEFT;

                Phrase phrase_field_2 = new Phrase(incarico[1], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_2 = new PdfPCell(phrase_field_2);
                cell_field_2.Border = PdfPCell.RIGHT_BORDER;
                cell_field_2.HorizontalAlignment = Element.ALIGN_LEFT;

                Phrase phrase_field_3 = new Phrase(incarico[2], FontFactory.GetFont("Arial", TextSize_Normal, iTextSharp.text.Font.NORMAL));
                PdfPCell cell_field_3 = new PdfPCell(phrase_field_3);
                cell_field_3.Border = PdfPCell.RIGHT_BORDER;
                cell_field_3.HorizontalAlignment = Element.ALIGN_LEFT;

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

    #endregion


    #region DETTAGLIO ASSENZE

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di rifferimento</param>
    /// <param name="dvCorrezioni">view correzioni</param>
    /// <param name="showAll">flag se visualizzare tutto</param>
    /// <param name="id_user">id utente</param>
    /// <param name="tab_place">tab_place</param>
    /// <param name="title">titolo</param>
    /// <param name="no_first_col">flag prima colonna</param>
    /// <param name="no_last_col">flag ultima colonna</param>
    /// <param name="LandScape">flag landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="filter_param">parametri filtri</param>
    /// <param name="databind">flag databind</param>
    public static void ExportDettaglioAssenzeToPDF(HttpResponse Response, GridView gvReport, DetailsView dvCorrezioni, bool showAll, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] filter_param, bool databind)
    {
        string charset = "ISO-8859-1";

        float HeaderTextSize = 8;
        float ReportNameSize = 10;
        float ReportTextSize = 6;
        float ApplicationNameSize = 7;

        int noOfColumns = 0, noOfRows = 0;
        DataTable tbl = null;

        string user = GetUserName(id_user);

        gvReport.AllowPaging = false;

        if (databind)
            gvReport.DataBind();

        if (gvReport.AutoGenerateColumns)
        {
            tbl = gvReport.DataSource as DataTable; // Gets the DataSource of the GridView Control.

            if (no_last_col)
                noOfColumns = tbl.Columns.Count - 1;
            else
                noOfColumns = tbl.Columns.Count;

            noOfRows = tbl.Rows.Count;
        }
        else
        {
            if (no_last_col)
                noOfColumns = gvReport.Columns.Count - 1;
            else
                noOfColumns = gvReport.Columns.Count;

            noOfRows = gvReport.Rows.Count;
        }

        int start = 0;

        if (no_first_col)
        {
            start = 1;
        }

        // Creates a PDF document
        Document document = null;
        if (LandScape == true)
        {
            // Sets the document to A4 size and rotates it so that the orientation of the page is Landscape.
            document = new Document(PageSize.A4.Rotate(), 0f, 0f, 15f, 5f);
        }
        else
        {
            document = new Document(PageSize.A4, 0f, 0f, 15f, 5f);
        }

        iTextSharp.text.pdf.PdfPTable mainTable;

        // Creates a PdfPTable with column count of the table equal to no of columns of the gridview or gridview datasource.
        if (no_first_col)
            mainTable = new iTextSharp.text.pdf.PdfPTable(noOfColumns - 1);
        else
            mainTable = new iTextSharp.text.pdf.PdfPTable(noOfColumns);

        mainTable.WidthPercentage = 98;

        int[] widths = new int[gvReport.Columns.Count];

        widths[0] = 80;
        widths[1] = 200;
        widths[2] = 120;
        widths[3] = 100;
        widths[4] = 100;
        widths[5] = 120;
        widths[6] = 100;
        widths[7] = 100;
        widths[8] = 150;
        widths[9] = 100;
        widths[10] = 120;
        widths[11] = 120;
        widths[12] = 120;
        widths[13] = 200;
        widths[14] = 200;
        widths[15] = 200;
        widths[16] = 120;
        widths[17] = 150;

        mainTable.SetWidths(widths);

        // Sets the first 4 rows of the table as the header rows which will be repeated in all the pages.
        //mainTable.HeaderRows = 4;

        // Creates a PdfPTable with 1 column to hold the header in the exported PDF.
        iTextSharp.text.pdf.PdfPTable headerTable = new iTextSharp.text.pdf.PdfPTable(1);

        // cella contenente la data ed il titolo
        Phrase phDate = new Phrase(DateTime.Now.Date.ToString("dd/MM/yyyy") + " - " + title, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
        PdfPCell clDate = new PdfPCell(phDate);
        clDate.HorizontalAlignment = Element.ALIGN_LEFT;
        clDate.Border = PdfPCell.NO_BORDER;

        // cella contenente il nome del richiedente
        Phrase phUser = new Phrase("Richiedente: " + user, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        PdfPCell clUser = new PdfPCell(phUser);
        clUser.Border = PdfPCell.NO_BORDER;
        clUser.HorizontalAlignment = Element.ALIGN_LEFT;

        // cella contenente la tab da dove si è richiesta l'esportazione
        //Phrase phTab = new Phrase("Menù: " + tab_place, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
        //PdfPCell clTab = new PdfPCell(phTab);
        //clTab.Border = PdfPCell.NO_BORDER;
        //clTab.HorizontalAlignment = Element.ALIGN_LEFT;

        // aggiunge le celle alla tabella dell'header
        headerTable.AddCell(clDate);
        headerTable.AddCell(clUser);
        //headerTable.AddCell(clTab);

        // cella contenente la voce Filtri
        if (filter_param.Length >= 2)
        {
            Phrase phFiltri = new Phrase("Filtri:", FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            PdfPCell clFiltri = new PdfPCell(phFiltri);
            clFiltri.Border = PdfPCell.NO_BORDER;
            clFiltri.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFiltri);
        }

        Phrase phFilterCell;
        PdfPCell clFilterCell;
        int ind = 0;
        while (ind < filter_param.Length - 1)
        {
            phFilterCell = new Phrase("  " + filter_param[ind] + ": " + filter_param[ind + 1], FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.NORMAL));
            clFilterCell = new PdfPCell(phFilterCell);
            clFilterCell.Border = PdfPCell.NO_BORDER;
            clFilterCell.HorizontalAlignment = Element.ALIGN_LEFT;

            headerTable.AddCell(clFilterCell);

            ind = ind + 2;
        }

        // Sets the border of the headerTable to zero.
        headerTable.DefaultCell.Border = PdfPCell.NO_BORDER;

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellHeader = new PdfPCell(headerTable);
        cellHeader.Border = PdfPCell.NO_BORDER;

        // Sets the column span of the header cell to noOfColumns.
        if (no_first_col)
            cellHeader.Colspan = noOfColumns - 1;
        else
            cellHeader.Colspan = noOfColumns;

        // Adds the above header cell to the table.
        mainTable.AddCell(cellHeader);

        // cella per separare l'header dalla tabella
        Phrase phSeparator = new Phrase("_____________________________________________________________________");
        PdfPCell clSeparator = new PdfPCell(phSeparator);
        clSeparator.Border = PdfPCell.NO_BORDER;
        if (no_first_col)
            clSeparator.Colspan = noOfColumns - 1;
        else
            clSeparator.Colspan = noOfColumns;
        clSeparator.HorizontalAlignment = Element.ALIGN_CENTER;
        mainTable.AddCell(clSeparator);

        // cella per andare a capo
        Phrase phSpace = new Phrase("\n");
        PdfPCell clSpace = new PdfPCell(phSpace);
        clSpace.Border = PdfPCell.NO_BORDER;
        if (no_first_col)
            clSpace.Colspan = noOfColumns - 1;
        else
            clSpace.Colspan = noOfColumns;
        mainTable.AddCell(clSpace);


        //DETTAGLIO CORREZIONI
        iTextSharp.text.pdf.PdfPTable corrTable = new iTextSharp.text.pdf.PdfPTable(2);

        int corrRows = dvCorrezioni.Rows.Count;
        for (int ic = 0; ic < corrRows; ic++)
        {
            var corrRow = dvCorrezioni.Rows[ic];
            var numCells = corrRow.Cells.Count;

            for (int icol = 0; icol < numCells; icol++)
            {
                var cell = corrRow.Cells[icol];
                var lbl = cell.Controls.OfType<Label>().FirstOrDefault();

                Phrase phCorr = new Phrase(lbl != null ? lbl.Text.ToString().Replace("<sup>", "(").Replace("</sup", ")") : cell.Text);
                if (icol == 0)
                    phCorr.Font.SetStyle(iTextSharp.text.Font.BOLD);

                PdfPCell clCorr = new PdfPCell(phCorr);
                corrTable.AddCell(clCorr);
            }
            corrTable.CompleteRow();
        }

        // Creates a PdfPCell that accepts the headerTable as a parameter and then adds that cell to the main PdfPTable.
        PdfPCell cellCorr = new PdfPCell(corrTable);
        cellCorr.Border = PdfPCell.NO_BORDER;

        // Sets the column span of the header cell to noOfColumns.
        if (no_first_col)
            cellCorr.Colspan = noOfColumns - 1;
        else
            cellCorr.Colspan = noOfColumns;

        // Adds the above header cell to the table.
        mainTable.AddCell(cellCorr);

        // cella per andare a capo
        Phrase phSpace2 = new Phrase("\n");
        PdfPCell clSpace2 = new PdfPCell(phSpace2);
        clSpace2.Border = PdfPCell.NO_BORDER;
        if (no_first_col)
            clSpace2.Colspan = noOfColumns - 1;
        else
            clSpace2.Colspan = noOfColumns;
        mainTable.AddCell(clSpace2);

        //DETTAGLIO CORREZIONI - fine


        // Sets the gridview column names as table headers.
        for (int i = start; i < noOfColumns; i++)
        {
            Phrase ph = null;
            PdfPCell phcell = null;

            if (gvReport.AutoGenerateColumns)
            {
                ph = new Phrase(tbl.Columns[i].ColumnName, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            }
            else
            {
                ph = new Phrase(gvReport.Columns[i].HeaderText, FontFactory.GetFont("Arial", HeaderTextSize, iTextSharp.text.Font.BOLD));
            }

            phcell = new PdfPCell(ph);
            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
            phcell.VerticalAlignment = Element.ALIGN_MIDDLE;

            mainTable.AddCell(phcell);
        }

        string s = "";
        string type = "";
        string hAlign = "";

        // Reads the gridview rows and adds them to the mainTable
        for (int rowNo = 0; rowNo < noOfRows; rowNo++)
        {
            if (showAll || !gvReport.Rows[rowNo].ControlStyle.CssClass.Contains("hidden"))
            {
                for (int columnNo = start; columnNo < noOfColumns; columnNo++)
                {
                    hAlign = gvReport.Columns[columnNo].ItemStyle.HorizontalAlign.ToString();
                    hAlign = hAlign.ToLower();

                    if (gvReport.AutoGenerateColumns)
                    {
                        s = gvReport.Rows[rowNo].Cells[columnNo].Text.Trim();
                    }
                    else
                    {
                        if (gvReport.Columns[columnNo] is TemplateField)
                        {
                            if (gvReport.Columns[columnNo].SortExpression == "calcolo")
                            {
                                DataBoundLiteralControl img = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as DataBoundLiteralControl;
                                if (img.Text.ToLower().Contains("calcolo_1"))
                                    s = "C";
                                else
                                    s = "";
                            }
                            else
                            {
                                if (gvReport.Rows[rowNo].Cells[columnNo].Controls.Count < 2)
                                    type = "";
                                else
                                    type = gvReport.Rows[rowNo].Cells[columnNo].Controls[1].GetType().ToString();

                                switch (type)
                                {
                                    case "System.Web.UI.WebControls.LinkButton":
                                        LinkButton lb = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as LinkButton;
                                        s = lb.Text.Trim();
                                        break;

                                    case "System.Web.UI.WebControls.HyperLink":
                                        HyperLink hl = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as HyperLink;
                                        s = hl.Text.Trim();
                                        break;

                                    case "System.Web.UI.WebControls.CheckBoxField":
                                        CheckBox chk = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as CheckBox;
                                        if (chk.Checked)
                                            s = "Si";
                                        else
                                            s = "No";
                                        break;

                                    case "System.Web.UI.WebControls.RadioButton":
                                        RadioButton rdb = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as RadioButton;
                                        if (rdb.Checked)
                                            s = "Si";
                                        break;

                                    case "System.Web.UI.WebControls.Label":
                                        Label lbl = gvReport.Rows[rowNo].Cells[columnNo].Controls[1] as Label;
                                        s = lbl.Text.Replace("<br />", "\n");
                                        break;

                                    default:
                                        break;
                                }
                            }
                        }
                        else
                        {
                            type = gvReport.Columns[columnNo].GetType().ToString();

                            switch (type)
                            {
                                case "System.Web.UI.WebControls.CheckBoxField":
                                    CheckBox chk = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as CheckBox;
                                    if (chk.Checked)
                                        s = "Si";
                                    else
                                        s = "No";
                                    break;

                                case "System.Web.UI.WebControls.RadioButton":
                                    RadioButton rdb = gvReport.Rows[rowNo].Cells[columnNo].Controls[0] as RadioButton;
                                    if (rdb.Checked)
                                        s = "Si";
                                    break;

                                default:
                                    s = gvReport.Rows[rowNo].Cells[columnNo].Text.Trim();
                                    if (s == "&nbsp;")
                                        s = "";
                                    break;
                            }
                        }
                    }

                    //s = s.Replace("&#224;", "à");

                    s = System.Web.HttpUtility.HtmlDecode(s);

                    Phrase ph = new Phrase(s, FontFactory.GetFont("Arial", ReportTextSize, iTextSharp.text.Font.NORMAL));
                    PdfPCell phcell = new PdfPCell(ph);

                    switch (hAlign)
                    {
                        case "center":
                            phcell.HorizontalAlignment = Element.ALIGN_CENTER;
                            break;
                        case "right":
                            phcell.HorizontalAlignment = Element.ALIGN_RIGHT;
                            break;
                        default:
                            phcell.HorizontalAlignment = Element.ALIGN_LEFT;
                            break;
                    }

                    phcell.VerticalAlignment = Element.ALIGN_MIDDLE;
                    mainTable.AddCell(phcell);
                }

                // Tells the mainTable to complete the row even if any cell is left incomplete.
                mainTable.CompleteRow();
            }
        }

        // Gets the instance of the document created and writes it to the output stream of the Response object.
        PdfWriter.GetInstance(document, Response.OutputStream);

        // Creates a footer for the PDF document.
        //HeaderFooter pdfFooter = new HeaderFooter(new Phrase(), true);
        //pdfFooter.Alignment = Element.ALIGN_CENTER;
        //pdfFooter.Border = iTextSharp.text.Rectangle.NO_BORDER;

        // Sets the document footer to pdfFooter.
        //document.Footer = pdfFooter;
        // Opens the document.
        document.Open();
        // Adds the mainTable to the document.
        document.Add(mainTable);
        // Closes the document.
        document.Close();

        Response.Charset = "text/html";
        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment; filename=" + filename + ".pdf");
        Response.End();
    }

    /// <summary>
    /// Metodo per esportazione di gridview in Excel
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di rifferimento</param>
    /// <param name="dvCorrezioni">view correzioni</param>
    /// <param name="showAll">flag se visualizzare tutto</param>
    /// <param name="id_user">id utente</param>
    /// <param name="tab_place">tab_place</param>
    /// <param name="title">titolo</param>
    /// <param name="no_first_col">flag prima colonna</param>
    /// <param name="no_last_col">flag ultima colonna</param>
    /// <param name="LandScape">flag landscape</param>
    /// <param name="filename">nome file</param>
    /// <param name="filter_param">parametri filtri</param>
    /// <param name="databind">flag databind</param>
    public static void ExportDettaglioAssenzeToExcel(HttpResponse Response, GridView gvReport, DetailsView dvCorrezioni, bool showAll, int id_user, string tab_place, string title, bool no_first_col, bool no_last_col, bool LandScape, string filename, string[] filter_param, bool databind)
    {
        int ncolumns = 0, start = 0;

        string user = GetUserName(id_user);

        Response.Clear();
        Response.Buffer = true;

        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "text/html";
        Response.ContentType = "application/vnd.ms-excel";
        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);

        // costruisco la gridview per l'header
        int ind_filter_header = 6;
        int ind_filter = 0;
        string[] cells = new string[10 + filter_param.Length];
        cells[0] = Utility.ConvertDateTimeToDateString(DateTime.Now);
        cells[1] = title;
        cells[2] = "Richiedente:";
        cells[3] = user;
        //cells[4] = "Menu:";
        //cells[5] = tab_place;

        if (filter_param.Length >= 2)
        {
            cells[6] = "Filtri:";
            cells[7] = "";
            ind_filter_header = ind_filter_header + 2;
        }

        while (ind_filter < filter_param.Length - 1)
        {
            cells[ind_filter_header] = filter_param[ind_filter] + ":";
            cells[ind_filter_header + 1] = filter_param[ind_filter + 1];

            ind_filter = ind_filter + 2;
            ind_filter_header = ind_filter_header + 2;
        }

        DataTable table = Utility.CreateDataTable(2);
        Utility.AddDataToTable(table, cells);

        GridView gvHeader = new GridView();
        gvHeader.DataSource = table;
        gvHeader.DataBind();

        // gestisco il layout dell'header
        gvHeader.GridLines = GridLines.None;
        gvHeader.HeaderRow.Visible = false;
        gvHeader.Rows[0].Font.Bold = true;
        gvHeader.Rows[3].Font.Bold = true;
        for (int i = 0; i < gvHeader.Rows.Count; i++)
        {
            gvHeader.Rows[i].HorizontalAlign = HorizontalAlign.Left;
            //gvHeader.Rows[i].VerticalAlign = VerticalAlign.Middle;
            gvHeader.Rows[i].Style.Add("vertical-align", "middle");

            var cnum = gvHeader.Rows[i].Cells.Count;
            for (int j = 0; j < cnum; j++)
            {
                gvHeader.Rows[i].Cells[j].Wrap = false;
            }
        }


        //Gridview correzioni

        DataTable tableCorr = new DataTable();
        tableCorr.Columns.Add();

        if (dvCorrezioni != null && dvCorrezioni.Rows != null && dvCorrezioni.Rows.Count > 0)
        {
            foreach (var rowCorr in dvCorrezioni.Rows.OfType<DetailsViewRow>().Where(p => p.Cells.Count > 0))
            {
                var sb = new StringBuilder();

                var cell = rowCorr.Cells[0];
                var lbl = cell.Controls.OfType<Label>().FirstOrDefault();
                sb.Append(lbl != null ? lbl.Text : cell.Text);

                if (rowCorr.Cells.Count > 1)
                {
                    cell = rowCorr.Cells[1];
                    lbl = cell.Controls.OfType<Label>().FirstOrDefault();
                    sb.Append(": ");
                    sb.Append(lbl != null ? lbl.Text : cell.Text);
                }

                var tbRow = tableCorr.NewRow();
                tbRow[0] = sb.ToString();
                tableCorr.Rows.Add(tbRow);
            }
        }

        //riga bianca per separare
        tableCorr.Rows.Add(tableCorr.NewRow());

        GridView gvCorr = new GridView();
        gvCorr.DataSource = tableCorr;
        gvCorr.DataBind();
        gvCorr.GridLines = GridLines.None;
        gvCorr.HeaderRow.Visible = false;

        foreach (var rowCorr in gvCorr.Rows.OfType<GridViewRow>())
        {
            var cellCorr = rowCorr.Cells[0];
            cellCorr.HorizontalAlign = HorizontalAlign.Left;
            cellCorr.Wrap = false;
            cellCorr.ColumnSpan = 4;
        }


        // costruisco la gridview del report vero e proprio
        gvReport.AllowPaging = false;

        if (databind)
            gvReport.DataBind();

        ncolumns = gvReport.Columns.Count;

        if (no_last_col)
        {
            ncolumns = ncolumns - 1;
            gvReport.Columns[ncolumns].Visible = false;
        }

        if (no_first_col)
        {
            gvReport.Columns[0].Visible = false;
            start = 1;
        }
        // cambio il back-color degli headers a bianco
        gvReport.HeaderRow.Style.Add("background-color", "#FFFFFF");



        //applico lo stile agli header singolarmente      
        for (int i = start; i < ncolumns; i++)
        {
            //gvReport.HeaderRow.Cells[i].TemplateControl.            
            gvReport.HeaderRow.Cells[i].Style.Add("border-style", "solid");
            gvReport.HeaderRow.Cells[i].Style.Add("border-width", "thin");
            gvReport.HeaderRow.Cells[i].Style.Add("text-font", "bold");
            gvReport.HeaderRow.Cells[i].Text = Convert.ToString(gvReport.Columns[i].HeaderText);
            gvReport.HeaderRow.Cells[i].Wrap = false;
        }

        GridViewRow row;

        for (int i = 0; i < gvReport.Rows.Count; i++)
        {
            //gvReport.Rows[i].Font.Bold = false;
            row = gvReport.Rows[i];

            if (showAll || !row.ControlStyle.CssClass.Contains("hidden"))
            {
                row.Font.Bold = false;

                for (int j = start; j < ncolumns; j++)
                {
                    string type;
                    string s = "";

                    // cambio il back-color a bianco
                    row.BackColor = System.Drawing.Color.White;

                    // applico lo stile ad ogni cella 
                    row.Attributes.Add("class", "textmode");

                    // applico lo stile alla cella
                    row.Cells[j].Font.Bold = false;
                    //row.Cells[j].VerticalAlign = VerticalAlign.Middle;

                    row.Cells[j].Style.Add("border-style", "solid");
                    row.Cells[j].Style.Add("border-width", "thin");
                    //row.Cells[j].Style.Add("font-bold", "false");
                    //row.Cells[j].Style.Add("text-font", "normal");
                    //row.Cells[j].Style.Add("text-align", "center");
                    row.Cells[j].Style.Add("vertical-align", "middle");

                    if (gvReport.Columns[j] is TemplateField)
                    {
                        if (gvReport.Columns[j].SortExpression == "calcolo")
                        {
                            DataBoundLiteralControl img = row.Cells[j].Controls[0] as DataBoundLiteralControl;
                            if (img.Text.ToLower().Contains("calcolo_1"))
                                s = "C";
                            else
                                s = "";
                        }
                        else
                        {
                            type = row.Cells[j].Controls[1].GetType().ToString();

                            switch (type)
                            {
                                case "System.Web.UI.WebControls.Label":
                                    Label lbl = row.Cells[j].Controls[1] as Label;
                                    s = lbl.Text.Trim();
                                    break;

                                case "System.Web.UI.WebControls.LinkButton":
                                    LinkButton lb = row.Cells[j].Controls[1] as LinkButton;
                                    s = lb.Text.Trim();
                                    break;

                                case "System.Web.UI.WebControls.HyperLink":
                                    HyperLink hl = row.Cells[j].Controls[1] as HyperLink;
                                    s = hl.Text.Trim();
                                    break;

                                case "System.Web.UI.WebControls.CheckBoxField":
                                    CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                                    if (chk.Checked)
                                        s = "Si";
                                    else
                                        s = "No";
                                    break;

                                case "System.Web.UI.WebControls.RadioButton":
                                    RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                                    if (rdb.Checked)
                                        s = "Si";
                                    break;

                                default:
                                    break;
                            }
                        }
                    }
                    else
                    {
                        type = gvReport.Columns[j].GetType().ToString();

                        switch (type)
                        {
                            case "System.Web.UI.WebControls.CheckBoxField":
                                CheckBox chk = row.Cells[j].Controls[0] as CheckBox;
                                if (chk.Checked)
                                    s = "Si";
                                else
                                    s = "No";
                                break;

                            case "System.Web.UI.WebControls.RadioButton":
                                RadioButton rdb = row.Cells[j].Controls[0] as RadioButton;
                                if (rdb.Checked)
                                    s = "Si";
                                break;

                            default:
                                s = row.Cells[j].Text.Trim();
                                if (s == "&nbsp;")
                                    s = "";
                                break;
                        }
                    }

                    row.Cells[j].Text = s;
                }
            }
            else
            {
                row.Visible = false;
            }
        }

        gvHeader.RenderControl(hw);

        gvCorr.RenderControl(hw);

        //dvCorrezioni.RenderControl(hw);

        //DataTable tableTemp = new DataTable();
        //tableTemp.Columns.Add();
        //tableTemp.Rows.Add(tableTemp.NewRow());
        //GridView gvTemp = new GridView();
        //gvTemp.DataSource = tableTemp;
        //gvTemp.DataBind();
        //gvTemp.GridLines = GridLines.None;
        //gvTemp.HeaderRow.Visible = false;
        //gvTemp.RenderControl(hw);

        gvReport.RenderControl(hw);

        //style to format numbers to string
        string style = @"<style> .textmode { mso-number-format:\@; } </style>";
        Response.Write(style);
        Response.Output.Write(sw.ToString());
        Response.Flush();
        Response.End();
    }


    #endregion


    /// <summary>
    /// Metodo per estrarre UserName
    /// </summary>
    /// <param name="id_user">id utente</param>
    /// <returns>Username</returns>
    private static string GetUserName(int id_user)
    {
        string user = null;

        if (id_user > 0)
        {
            string query_user = @"SELECT top 1 nome_utente 
                              FROM utenti 
                              WHERE id_utente = " + id_user;

            var row = Utility.GetDataRows(query_user).ToList().FirstOrDefault();
            if (row != null)
                user = row.Field<string>(0);
        }
        else
        {
            user = ActiveDirectory.UserName;
        }

        return user ?? "";
    }



    private static float padding_X = 2;
    private static float padding_Y = 6;

    /// <summary>
    /// Metodo per gestione Padding
    /// </summary>
    /// <param name="cell">cella di riferimento</param>
    private static void SetPadding(PdfPCell cell)
    {
        cell.PaddingTop = padding_Y;
        cell.PaddingBottom = padding_Y;
        cell.PaddingLeft = padding_X;
        cell.PaddingRight = padding_X;
    }

    /// <summary>
    /// Metodo per esportazione di gridview in PDF
    /// </summary>
    /// <param name="Response">output pagina</param>
    /// <param name="gvReport">grid di rifferimento</param>
    /// <param name="id_user">id utente</param>
    /// <param name="tab">tab</param>
    /// <param name="title">titolo</param>
    /// <param name="filters">parametri filtri</param>
    /// <param name="filename">nome file</param>
    public static void GridViewToPDF(HttpResponse Response, HttpRequest Request, GridView gvReport, int id_user, string tab, string title, string[] filters, string filename)
    {

        string user = GetUserName(id_user);

        string html = "<div> " +
            "<table style='width: 100%'>" +
            "<tr><td style='text-align: center'><img src='" + Request.PhysicalApplicationPath + "img/LogoTessera.png" + "' width='250'/></td></tr>" +
            "</table>" +
            "<BR />" +
            "<BR />" +
            "</div>";


        GridView grd = new GridView();

        grd.GridLines = GridLines.None;


        DataTable tbl = new DataTable();

        /*
        tbl.Columns.Add("Informazioni Estrazione", typeof(string));        
        
        tbl.Rows.Add("");
        tbl.Rows.Add(title);
        tbl.Rows.Add("\nRichiedente: " + user);
        tbl.Rows.Add("Menù: " + tab);

        if (filters.Length >= 2)
        {
            tbl.Rows.Add("Filtri:");

            int ind = 0;

            while (ind < filters.Length - 1)
            {
                tbl.Rows.Add("......" + filters[ind] + ": " + filters[ind + 1]);

                ind = ind + 2;
            }
        }
        */

        tbl.Columns.Add(" ");

        tbl.Rows.Add(title);

        string s = "";

        if (filters.Length >= 2)
        {
            int ind = 0;

            while (ind < filters.Length - 1)
            {
                if (filters[ind] == "Mese")
                    s = filters[ind + 1] + " ";

                if (filters[ind] == "Anno")
                    s = s + filters[ind + 1];

                ind = ind + 2;
            }
        }

        tbl.Rows.Add(s);

        tbl.Rows.Add("");
        tbl.Rows.Add("");
        tbl.Rows.Add("");

        grd.DataSource = tbl;
        grd.DataBind();

        grd.HorizontalAlign = HorizontalAlign.Center;

        foreach (GridViewRow r in grd.Rows)
            for (int i = 0; i < r.Cells.Count; i++)
                r.Cells[i].HorizontalAlign = HorizontalAlign.Center;


        StringWriter sw1 = new StringWriter();
        HtmlTextWriter hw1 = new HtmlTextWriter(sw1);

        grd.RenderControl(hw1);

        StringWriter sw2 = new StringWriter();
        HtmlTextWriter hw2 = new HtmlTextWriter(sw2);

        gvReport.Width = Unit.Percentage(100);
        gvReport.Font.Size = 9;

        string type;

        foreach (GridViewRow r in gvReport.Rows)
        {

            r.Font.Name = "Arial";
            r.Font.Bold = false;

            for (int i = 0; i < r.Cells.Count; i++)
            {

                for (int j = 0; j < r.Cells[i].Controls.Count; j++)
                {
                    type = r.Cells[i].Controls[j].GetType().ToString();

                    if (type == "System.Web.UI.WebControls.LinkButton")
                    {
                        LinkButton lb = r.Cells[i].Controls[j] as LinkButton;

                        Label l = new Label();

                        l.Text = lb.Text;

                        r.Cells[i].Controls.Remove(r.Cells[i].Controls[j]);

                        r.Cells[i].Controls.AddAt(j, l);

                    }
                }
            }
            //r.Attributes["style"] = "page-break-inside:avoid;";
            //r.Attributes["style"] = "page-break-inside:always;";
        }

        gvReport.RenderControl(hw2);


        StringReader sr = new StringReader(html + sw1.ToString() + sw2.ToString());

        Document pdfDoc = new Document(PageSize.A4.Rotate(), 10, 10, 15, 5);


        PdfWriter writer = PdfWriter.GetInstance(pdfDoc, Response.OutputStream);

        pdfDoc.Open();

        XMLWorkerHelper.GetInstance().ParseXHtml(writer, pdfDoc, sr);

        pdfDoc.Close();

        Response.ContentType = "application/pdf";
        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".pdf");
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Write(pdfDoc);
        Response.End();



    }
}

