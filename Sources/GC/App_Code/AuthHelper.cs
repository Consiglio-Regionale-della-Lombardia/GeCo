using System;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web;

public class AuthUser
{
	public string Username { get; set; }
	public string Nome { get; set; }
	public string Cognome { get; set; }
	public string Ruolo { get; set; }
}

public static class AuthHelper
{
	private const string SessionUserKey = "CurrentUser";
	private const string SsoParam = "sso";

	// Chiave segreta condivisa fra legacy e app Auth
	private const string SharedSecret = "CAMBIA-QUESTA-CHIAVE-LUNGA-E-SEGRETA";

	/// <summary>
	/// Se esiste un utente in Session, lo restituisce.
	/// Altrimenti gestisce sso=... oppure redirect verso l'app Auth.
	/// </summary>
	public static AuthUser EnsureAuthenticated()
	{
		HttpContext ctx = HttpContext.Current;

		// 1) Utente già in Session?
		object sessionValue = ctx.Session[SessionUserKey];
		if (sessionValue != null && sessionValue is AuthUser)
		{
			return (AuthUser)sessionValue;
		}

		// 2) Sto tornando dall'app Auth con ?sso=...
		string ssoToken = ctx.Request.QueryString[SsoParam];
		if (!string.IsNullOrEmpty(ssoToken))
		{
			AuthUser user = ValidateSsoToken(ssoToken);
			if (user != null)
			{
				// Salvo in Session
				ctx.Session[SessionUserKey] = user;

				// Tolgo "sso=..." dalla query string con un redirect "pulito"
				Uri url = ctx.Request.Url;
				string cleanUrl = RemoveQueryStringParameter(url, SsoParam);
				ctx.Response.Redirect(cleanUrl, true);
				return null; // non eseguo altro codice dopo Redirect
			}
		}

		// 3) Non autenticato → redirect all'app Auth per SSO
		Uri current = ctx.Request.Url;
		string currentUrl = current.AbsoluteUri;
		string encodedReturnUrl = HttpUtility.UrlEncode(currentUrl);

		// URL dell'app Auth con pagina SsoLogin.aspx
		string authBaseUrl = ConfigurationManager.AppSettings["AuthBaseUrl"];
		string authLoginUrl = authBaseUrl + "/SsoLogin.aspx?returnUrl=" + encodedReturnUrl;

		ctx.Response.Redirect(authLoginUrl, true);
		return null;
	}

	private static string RemoveQueryStringParameter(Uri url, string paramName)
	{
		// .NET 4: niente cose moderne, usiamo ParseQueryString
		System.Collections.Specialized.NameValueCollection nvc =
			HttpUtility.ParseQueryString(url.Query ?? string.Empty);

		nvc.Remove(paramName);

		string baseUrl = url.GetLeftPart(UriPartial.Path);
		string newQuery = nvc.ToString();

		if (string.IsNullOrEmpty(newQuery))
		{
			return baseUrl;
		}

		return baseUrl + "?" + newQuery;
	}

	private static AuthUser ValidateSsoToken(string ssoToken)
	{
		try
		{
			byte[] data = HttpServerUtility.UrlTokenDecode(ssoToken);
			if (data == null)
				return null;

			string token = Encoding.UTF8.GetString(data);

			// formato: username|ticks|hmac
			string[] parts = token.Split('|');
			if (parts.Length != 6)
				return null;

			string username = parts[0];
			string role = parts[1];
			string name = parts[2];
			string surname = parts[3];
			string ticksStr = parts[4];
			string sentHmac = parts[5];

			long ticks;
			if (!long.TryParse(ticksStr, out ticks))
				return null;

			DateTime ts = new DateTime(ticks, DateTimeKind.Utc);

			// validità del token: 5 minuti
			if (DateTime.UtcNow - ts > TimeSpan.FromMinutes(5))
				return null;

			string payload = username + "|" + role + "|" + name + "|" + surname + "|" + ticksStr;
			string expectedHmac = ComputeHmac(payload, SharedSecret);

			if (!SlowEquals(sentHmac, expectedHmac))
				return null;

			AuthUser user = new AuthUser();
			user.Username = username;
			user.Ruolo = role;
			user.Nome = name;
			user.Cognome = surname;
			return user;
		}
		catch
		{
			return null;
		}
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

	private static bool SlowEquals(string a, string b)
	{
		if (a == null || b == null)
			return false;

		byte[] ba = Encoding.UTF8.GetBytes(a);
		byte[] bb = Encoding.UTF8.GetBytes(b);

		if (ba.Length != bb.Length)
			return false;

		int diff = 0;
		for (int i = 0; i < ba.Length; i++)
		{
			diff |= ba[i] ^ bb[i];
		}
		return diff == 0;
	}
}
