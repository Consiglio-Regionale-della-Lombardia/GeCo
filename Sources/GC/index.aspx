<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true"
         CodeFile="index.aspx.cs" 
         Inherits="_Default" 
         Title="Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="content" align="center">
	    <div id="error" style="color: Red;">
	    </div>
	    
	    <br />
	    <br />
	    	       
	    <asp:Login ID="Login1" 
	               runat="server" 
	               UserNameLabelText="Username: "
	               PasswordLabelText="Password: "
	               DestinationPageUrl="~/persona/persona.aspx"
	               DisplayRememberMe="false"  
	               FailureText="LOGIN FALLITA: Username o Password errate."
	               TitleTextStyle-Font-Bold="true"
	               TitleTextStyle-CssClass="tab_ris_header"
	               TitleText="Accedi"
	               LoginButtonText="Accedi"
	               
	               OnAuthenticate="executeLoginForm" >
	        <TextBoxStyle Width="150px" />
	        <TitleTextStyle Font-Bold="True" />
	    </asp:Login>
    </div>
</asp:Content>