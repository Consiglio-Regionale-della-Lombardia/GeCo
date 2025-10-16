<%@ Page Language="C#" 
         MasterPageFile="~/MasterPage.master" 
         AutoEventWireup="true" 
         CodeFile="errore.aspx.cs" 
         Inherits="errore" 
         Title="Errore" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<div align="center" style="padding-top: 30px;">
    <div align="center" id="tab_error">
        <h3>Si è verificato un errore.</h3>
        
        <div id="div_err" runat="server" align="left">
            <table id="tbl_err" runat="server">
            <tr>
                <td>
                    <asp:Label ID="LabelErrore" 
                               runat="server" >
                    </asp:Label>
                </td>
            </tr>
            
            <tr>
                <td id="td_details" runat="server" align="justify">
                    <asp:Label ID="lbl_errore_details_content" 
	                           runat="server" >
	                </asp:Label>
                </td>
            </tr>
            </table>
        </div>
        
        <br />
        
        <a href="javascript:;" onclick="javascript:history.back(1);">
            Torna alla pagina precedente
        </a>
    </div>
</div>
</asp:Content>