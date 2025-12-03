using Microsoft.Owin.Security;
using Microsoft.Owin.Security.OpenIdConnect;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GC_Auth_2
{
	public partial class Login : System.Web.UI.Page
	{

		/*
		protected void Page_Load(object sender, EventArgs e)
		{
			// returnUrl passato dalla legacy: https://auth.../Login.aspx?returnUrl=...
			var returnUrl = Request.QueryString["returnUrl"];

			if (string.IsNullOrEmpty(returnUrl))
			{
				return;
			}

			// Se è già autenticato (cookie OWIN), non rifare il giro, vai subito alla destinazione
			if (Request.IsAuthenticated)
			{
				RedirectToReturnUrl(returnUrl);
				return;
			}

			var rawReturnUrl = Request.QueryString["returnUrl"] ?? "https://google.com";

			var authProps = new AuthenticationProperties
			{
				RedirectUri = "/signin-oidc"   // callback OWIN
			};

			authProps.Dictionary["returnUrl"] = rawReturnUrl;

			HttpContext.Current.GetOwinContext().Authentication.Challenge(
				authProps,
				OpenIdConnectAuthenticationDefaults.AuthenticationType
			);

			// NIENTE Response.End();
			Context.ApplicationInstance.CompleteRequest();
		}
		*/





		protected void Page_Load(object sender, EventArgs e)
		{
			// returnUrl passato dalla legacy: https://auth.../Login.aspx?returnUrl=...
			var returnUrl = Request.QueryString["returnUrl"];

			if (string.IsNullOrEmpty(returnUrl))
			{
				// Se non c'è returnUrl, puoi decidere una destinazione di default
				returnUrl = "/Default.aspx";
				return;
			}

			// Se è già autenticato (cookie OWIN), vai subito alla destinazione
			if (Request.IsAuthenticated)
			{
				RedirectToReturnUrl(returnUrl);
				return;
			}

			var authProps = new AuthenticationProperties
			{
				// 👉 DOPO IL LOGIN voglio andare QUI, NON a /signin-oidc
				RedirectUri = returnUrl
			};

			HttpContext.Current.GetOwinContext().Authentication.Challenge(
				authProps,
				OpenIdConnectAuthenticationDefaults.AuthenticationType
			);

			Context.ApplicationInstance.CompleteRequest();
		}


		private void RedirectToReturnUrl(string returnUrl)
		{
			if (!string.IsNullOrEmpty(returnUrl))
			{
				// Qui eventualmente puoi fare una validazione sul dominio per sicurezza
				Response.Redirect(returnUrl, endResponse: true);
			}
			else
			{
				Response.Redirect(ResolveUrl("~/"), endResponse: true);
			}
		}

	}
}