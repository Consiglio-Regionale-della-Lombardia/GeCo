using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class DebugAuth : System.Web.UI.Page
{
	protected void Page_Load(object sender, EventArgs e)
	{
		Response.ContentType = "text/html";

		Response.Write("<h3>Elenco Request.Cookies</h3>");
		Response.Write("<pre>");

		if (Request.Cookies.Count == 0)
		{
			Response.Write("⚠️  Nessun cookie trovato nella Request\n");
		}
		else
		{
			foreach (string key in Request.Cookies.AllKeys)
			{
				var c = Request.Cookies[key];
				Response.Write(key + " = " + c.Value + " <br/>\n");
			}
		}

		Response.Write("</pre>");
	}

	/*
	protected void Page_Load(object sender, EventArgs e)
	{
		var ctx = HttpContext.Current;

		Response.Write("<pre>");

		Response.Write("IsAuthenticated: " + (ctx.User.Identity.IsAuthenticated) + "\n");
		Response.Write("User.Identity.Name: " + (ctx.User.Identity.Name ?? "(null)") + "\n\n");

		var cookie = ctx.Request.Cookies[".ASPXFORMSAUTH"];
		if (cookie == null)
		{
			Response.Write("Cookie .ASPXFORMSAUTH: NON presente\n");
		}
		else
		{
			Response.Write("Cookie .ASPXFORMSAUTH: PRESENTE\n");
			Response.Write("Valore: " + cookie.Value + "\n\n");

			try
			{
				var ticket = FormsAuthentication.Decrypt(cookie.Value);
				if (ticket == null)
				{
					Response.Write("Decrypt: ticket NULL (machineKey NON allineata?)\n");
				}
				else
				{
					Response.Write("Decrypt OK\n");
					Response.Write("Ticket.Name: " + ticket.Name + "\n");
					Response.Write("Ticket.UserData: " + ticket.UserData + "\n");
					Response.Write("Ticket.IssueDate: " + ticket.IssueDate + "\n");
					Response.Write("Ticket.Expiration: " + ticket.Expiration + "\n");
				}
			}
			catch (Exception ex)
			{
				Response.Write("Decrypt EXCEPTION: " + ex.Message + "\n");
			}
		}

		Response.Write("</pre>");
	}
	*/

}