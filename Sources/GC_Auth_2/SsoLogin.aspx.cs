using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GC_Auth_2
{


	using System;
	using System.Security.Claims;
	using System.Text;
	using System.Web;
	using System.Web.UI;
	using System.Security.Cryptography;
	using Microsoft.Owin.Security;
	using Microsoft.Owin.Security.OpenIdConnect;

	public partial class SsoLogin : Page
	{
		private const string SharedSecret = "CAMBIA-QUESTA-CHIAVE-LUNGA-E-SEGRETA"; // stessa della legacy

		protected void Page_Load(object sender, EventArgs e)
		{
			string returnUrl = Request.QueryString["returnUrl"];
			if (string.IsNullOrEmpty(returnUrl))
			{
				return;
			}

			string forceLogin = Request.QueryString["forceLogin"];

			if (forceLogin == "1" || !Request.IsAuthenticated)
			{
				// Non autenticato con OWIN/Azure → avvia Challenge
				AuthenticationProperties props = new AuthenticationProperties();
				props.RedirectUri = RemoveQueryParam(Request.Url, "forceLogin");
				// Dopo OIDC, vogliamo tornare di nuovo su questa pagina (SsoLogin)
				//props.RedirectUri = Request.Url.AbsoluteUri;

				HttpContext.Current
					.GetOwinContext()
					.Authentication
					.Challenge(props, OpenIdConnectAuthenticationDefaults.AuthenticationType);

				Context.ApplicationInstance.CompleteRequest();
				return;
			}

			// Qui siamo autenticati OWIN/Azure AD
			ClaimsIdentity identity = User.Identity as ClaimsIdentity;
			string username = null, role = null, name = null, surname = null;

			if (identity != null)
			{
				Claim nameClaim = identity.FindFirst(ClaimTypes.Name);
				if (nameClaim != null)
				{
					username = nameClaim.Value;
				}

				Claim givenNameClaim = identity.FindFirst(ClaimTypes.GivenName);
				if (givenNameClaim != null)
				{
					name = givenNameClaim.Value;
				}

				Claim surnameClaim = identity.FindFirst(ClaimTypes.Surname);
				if (surnameClaim != null)
				{
					surname = surnameClaim.Value;
				}

				Claim roleClaim = identity.FindFirst(ClaimTypes.Role);
				if (roleClaim != null)
				{
					role = roleClaim.Value;
				}
			}

			if (string.IsNullOrEmpty(username))
			{
				username = User.Identity.Name;
			}
			if (string.IsNullOrEmpty(username))
			{
				username = "utente";
			}

			// Genera token SSO: username|ticks|hmac
			string ticksStr = DateTime.UtcNow.Ticks.ToString();
			string payload = username + "|" + role + "|" + name + "|" + surname + "|" + ticksStr;
			string hmac = ComputeHmac(payload, SharedSecret);

			string tokenString = payload + "|" + hmac;
			byte[] bytes = Encoding.UTF8.GetBytes(tokenString);
			string ssoToken = HttpServerUtility.UrlTokenEncode(bytes);

			string sep = returnUrl.IndexOf("?") >= 0 ? "&" : "?";
			string redirectUrl = returnUrl + sep + "sso=" + HttpUtility.UrlEncode(ssoToken);

			Response.Redirect(redirectUrl, false);
			Context.ApplicationInstance.CompleteRequest();
		}

		private static string ComputeHmac(string data, string key)
		{
			byte[] keyBytes = Encoding.UTF8.GetBytes(key);
			byte[] dataBytes = Encoding.UTF8.GetBytes(data);

			using (HMACSHA256 hmac = new HMACSHA256(keyBytes))
			{
				byte[] hash = hmac.ComputeHash(dataBytes);
				return Convert.ToBase64String(hash);
			}
		}
		private static string RemoveQueryParam(Uri url, string key)
		{
			var uri = new UriBuilder(url);

			var qs = System.Web.HttpUtility.ParseQueryString(uri.Query);
			qs.Remove(key);

			uri.Query = qs.ToString(); // ricostruisce la query senza quel parametro
			return uri.Uri.AbsoluteUri;
		}
	}
}









