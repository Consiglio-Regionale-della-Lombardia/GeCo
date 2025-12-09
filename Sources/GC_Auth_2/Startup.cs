using Microsoft.IdentityModel.Tokens;
using Microsoft.Owin;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using Owin;
using System;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Configuration;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;
using System.Web.Security;

[assembly: OwinStartup(typeof(GC_Auth_2.Startup))]

namespace GC_Auth_2
{
	public partial class Startup
	{

		public void Configuration(IAppBuilder app)
		{
			string tenantId = ConfigurationManager.AppSettings["ida:TenantId"];
			string baseUrl = ConfigurationManager.AppSettings["ida:AuthBaseUrl"];
			string redirectUri = baseUrl + "/signin-oidc";

			app.UseCookieAuthentication(new CookieAuthenticationOptions
			{
				AuthenticationType = CookieAuthenticationDefaults.AuthenticationType
			});

			app.UseOpenIdConnectAuthentication(new OpenIdConnectAuthenticationOptions
			{
				ClientId = ConfigurationManager.AppSettings["ida:ClientId"],
				Authority = $"https://login.microsoftonline.com/{tenantId}",
				RedirectUri = redirectUri,
				PostLogoutRedirectUri = redirectUri,
				ResponseType = "id_token",
				Scope = "openid profile email",
				CallbackPath = new PathString("/signin-oidc"),

				TokenValidationParameters = new TokenValidationParameters
				{
					ValidateIssuer = true
				},

				Notifications = new OpenIdConnectAuthenticationNotifications
				{
					SecurityTokenValidated = context =>
					{
						var identity = (ClaimsIdentity)context.AuthenticationTicket.Identity;

						// Recupero un nome utente sensato
						var name =
							identity.FindFirst(ClaimTypes.Name)?.Value ??
							identity.FindFirst("name")?.Value ??
							identity.Name;

						// TODO: se vuoi, qui puoi prendere ruoli/altre info da mettere nel ticket
						var userData = ""; // es: "Role=Admin"

						// Crea il ticket FormsAuth che la legacy capirà
						var ticket = new FormsAuthenticationTicket(
							1,                   // versione
							name,                // name (User.Identity.Name sulla legacy)
							DateTime.Now,
							DateTime.Now.AddMinutes(60),
							false,               // persistente?
							userData
						);

						var encrypted = FormsAuthentication.Encrypt(ticket);
						
						var cookieName = ".ASPXFORMSAUTH";
						var cookie = new HttpCookie(cookieName, encrypted)
						{
							HttpOnly = true,
							Secure = true,    // siamo in https
							Path = "/"
							// Domain: su localhost NON metterlo; in produzione,
							// se hai auth.miodominio.it e legacy.miodominio.it
							// allora: cookie.Domain = ".miodominio.it";
						};

						HttpContext.Current.Response.Cookies.Add(cookie);

						return Task.FromResult(0);
					}
				}

			});

			app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType);

			//app.Run(ctx =>
			//{
			//	ctx.Response.ContentType = "text/plain";
			//	return ctx.Response.WriteAsync("OWIN OK - Path: " + ctx.Request.Path.Value);
			//});
		}

		//public void Configuration(IAppBuilder app)
		//{
		//	var clientId = ConfigurationManager.AppSettings["ida:ClientId"];
		//	var tenantId = ConfigurationManager.AppSettings["ida:TenantId"];
		//	var authority = $"https://login.microsoftonline.com/{tenantId}";
		//	var redirectUri = "https://localhost:44374/signin-oidc";// ConfigurationManager.AppSettings["ida:RedirectUri"];
		//	// Deve coincidere con la Redirect URI registrata in Entra ID
		//
		//	app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType);
		//
		//	app.UseCookieAuthentication(new CookieAuthenticationOptions
		//	{
		//		AuthenticationType = CookieAuthenticationDefaults.AuthenticationType
		//	});
		//
		//
		//	app.UseOpenIdConnectAuthentication(new OpenIdConnectAuthenticationOptions
		//	{
		//		ClientId = clientId,
		//		Authority = authority,
		//		RedirectUri = redirectUri,
		//		PostLogoutRedirectUri = redirectUri,
		//		ResponseType = "id_token", // TODO da abilitare sull app in ENTRA ID
		//		Scope = "openid profile email",
		//		CallbackPath = new PathString("/signin-oidc"),
		//
		//		TokenValidationParameters = new TokenValidationParameters
		//		{
		//			ValidateIssuer = true
		//		}
		//		/*,
		//		
		//		Notifications = new OpenIdConnectAuthenticationNotifications
		//		{
		//			AuthenticationFailed = context =>
		//			{
		//				// per debug
		//				context.HandleResponse();
		//				context.Response.Redirect("/Error?message=" + Uri.EscapeDataString(context.Exception.Message));
		//				return System.Threading.Tasks.Task.FromResult(0);
		//			}
		//		}
		//		*/
		//	});
		//}
	}
}
