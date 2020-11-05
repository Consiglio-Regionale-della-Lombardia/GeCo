<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LoggedUserPanel.ascx.cs" Inherits="LoggedUserPanel" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<style>
    
</style>

<div style="margin: 2px; padding: 2px 10px 2px 10px; background-color: #FFFFFF; color: #006600; vertical-align: middle;">
    <asp:LinkButton runat="server" ID="Button_User_Refresh" CssClass="linkButton" OnClick="Button_User_Refresh_Click">
        Utente: <b><%= adUser != null ? (adUser.UserName ?? "") : "" %></b>
    </asp:LinkButton>

    &#160;
    
    &#160;&#160;&#160;
    Profilo: <b><%= adUser != null ? adUser.CurrentProfileName : "" %></b>
    <% if (adUser != null && adUser.CanChangeProfile)
       { %>
    <a  style="background-color:#006600; color:#FFFFFF; margin:1px; padding:0px 2px;"
            href="#" onclick="TogglePopupRuoli(true); return false;"><b>Cambia</b></a>           
    <% } %>
</div>


<div id="Popup_CambiaRuolo" style="display:none; z-index: 100000; position:absolute; left:0px; top:0px; width:100%; height:100%; background-color:rgba(0,0,0,0.4);">
    <div style="position: absolute; z-index: 100001; width:600px; height:400px; left: 350px; top: 150px;">
        <div style="background-color: White; border-color: DarkSeaGreen; border-width: 2px; border-style: solid; width:600px; height:400px; overflow-y: scroll; padding: 10px; position: relative; z-index: 2;">
            <div align="center">
                <br>
                <h3>
                    CAMBIA RUOLO
                    <button id="Button_Chiudi_Popup" style="width:50px; float:right;" onclick="TogglePopupRuoli(false); return false;">Chiudi</button>
                </h3>
                
                <br>

                <asp:GridView ID="ListProfili"
                    runat="server"
                    AllowSorting="false"
                    AutoGenerateColumns="False"
                    CellPadding="5"
                    CssClass="tab_gen" 
                    GridLines="None" OnRowCommand="ListProfili_RowCommand">

                    <EmptyDataTemplate>
                        <table width="100%" class="tab_gen">
                            <tr>
                                <th align="center">Nessun record trovato.
                                </th>
                            </tr>
                        </table>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:ButtonField ButtonType="Link" CommandName="Seleziona"          
                             Text="Seleziona" HeaderText="" ItemStyle-Width="50px" />
                        <asp:BoundField DataField="nome_ruolo" HeaderText="Profilo" />
                        <asp:BoundField DataField="num_legislatura" HeaderText="Leg." ItemStyle-HorizontalAlign="Center" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <%--<div style="background-color: black; position: absolute; left: 5px; top: 5px; width:600px; height:400px; visibility: visible; z-index: 1;"></div>--%>
    </div>
</div>


<script>
    function TogglePopupRuoli(visible)
    {
        $('#Popup_CambiaRuolo').css("display", visible == true ? "block" : "none");
        return false;
    }
</script>
