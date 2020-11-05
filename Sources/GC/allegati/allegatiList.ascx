<%@ Control Language="C#" AutoEventWireup="true" CodeFile="allegatiList.ascx.cs" Inherits="allegati_allegatiList" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="cc1" %>

<div>
    <table>
        <tr>
            <td>
                <asp:Image ID="ImageButtonAllegati"
                    runat="server" 
                    ImageUrl="~/img/attachment.png" />
            </td>
            <td>
                <asp:Label ID="LabelAllegati"
                    runat="server"
                    Font-Bold="true" Text="ALLEGATI">
                </asp:Label>
            </td>
            <td>
                 <% if (isEnabled)
                    { %>
                    <div style="margin-left:20px;">
                        <asp:FileUpload ID="uploadFile" runat="server" BackColor="#BBEEBB" Width="400" />

                        <asp:Button ID="cmdNew"
                                    runat="server"
                                    Text="Aggiungi"
                                    OnClick="cmdNew_Click"
                                    CssClass="button" 
                                    EnableViewState="false"
                                    CausesValidation="false" />

<%--                        <asp:RegularExpressionValidator
                            id="Validate_uploadFile" runat="server"
                            ErrorMessage="Selezionare un file PDF"
                            ValidationExpression="^(([a-zA-Z]:)|(\\{2}\w+)\$?)(\\(\w[\w].*))(.pdf|.PDF)$"
                            ControlToValidate="uploadFile" CssClass="text-red">
                        </asp:RegularExpressionValidator>--%>
                    </div>
                <% } %>             
            </td>
        </tr>
    </table>

<%--    <cc1:CollapsiblePanelExtender ID="cpe"
        runat="Server"
        TargetControlID="PanelAllegati"
        CollapsedSize="0"
        Collapsed="False"
        ExpandControlID="ImageButtonAllegati"
        CollapseControlID="ImageButtonAllegati"
        AutoCollapse="False"
        AutoExpand="False"
        ScrollContents="False"
        TextLabelID="LabelAllegati"
        CollapsedText="Visualizza allegati"
        ExpandedText="Nascondi allegati"
        ExpandDirection="Vertical">
    </cc1:CollapsiblePanelExtender>--%>

    <asp:Panel ID="PanelAllegati" runat="server">

        <asp:GridView ID="GridViewAllegati"
            runat="server"
            AllowPaging="False"
            PagerStyle-HorizontalAlign="Center"
            AllowSorting="false"
            AutoGenerateColumns="false"
            DataSourceID="SqlDataSource_GridViewAllegati"
            CssClass="tab_gen"
            GridLines="None"
            DataKeyNames="id_allegato"
            CellPadding="5"
            OnDataBinding="GridViewAllegati_DataBinding"
            OnDataBound="GridViewAllegati_DataBound">

            <EmptyDataTemplate>
                <table width="100%" class="tab_gen">
                    <tr>
                        <th align="center">
                            Nessun allegato presente.
                        </th>
<%--                        <th width="100">
                            <% if (isEnabled)
                               { %>
                                <asp:Button ID="cmdNew"
                                    runat="server"
                                    Text="Nuovo..."
                                    OnClick="cmdNew_Click"
                                    CssClass="button"
                                    CausesValidation="false" />
                            <% } %>
                        </th>--%>
                    </tr>
                </table>
            </EmptyDataTemplate>
            <AlternatingRowStyle BackColor="#b2cca7" />	
            <Columns>
                <asp:TemplateField HeaderText="File" SortExpression="filename">
                    <ItemTemplate>
                        <asp:LinkButton ID="lnkbtn_dilename"
                            runat="server"
                            Text='<%# Eval("filename") %>'
                            Font-Bold="true"
                            OnClientClick='<%# getPopupURL(Eval("id_allegato"), Eval("filename")) %>'>
                        </asp:LinkButton>
                    </ItemTemplate>
                    <ItemStyle Font-Bold="True" />
                </asp:TemplateField>

                <asp:TemplateField HeaderText="">
                    <ItemTemplate>
                        <% if (isEnabled)
                           { %>
                          <asp:LinkButton ID="cmdDelete"
                            runat="server"
                            Text="Elimina"
                            CssClass="button"
                            CausesValidation="false"
                            CommandName="Delete"
                            CommandArgument='<%# Eval("id_allegato") %>'
                            OnClientClick="return confirm('Confermare la cancellazione del file?');"
                            OnCommand="cmdDelete_Command" />
                        <% } %>
                    </ItemTemplate>

<%--                    <HeaderTemplate>
                        <% if (isEnabled)
                            { %>
                            <asp:Button ID="cmdNew"
                                runat="server"
                                Text="Nuovo..."
                                OnClick="cmdNew_Click"
                                CssClass="button"
                                CausesValidation="false" />
                        <% } %>
			        </HeaderTemplate>--%>
    			        
			        <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="100px" />
                </asp:TemplateField>
            </Columns>

        </asp:GridView>

    </asp:Panel>

</div>



<asp:SqlDataSource ID="SqlDataSource_GridViewAllegati"
    runat="server"
    ConnectionString="<%$ ConnectionStrings:GestioneConsiglieriConnectionString %>"
    OnDataBinding="SqlDataSource_GridViewAllegati_DataBinding"
    OnDeleted="SqlDataSource_GridViewAllegati_Deleted">

    <DeleteParameters>
        <asp:Parameter Name="id_allegato" Type="Int32" />
    </DeleteParameters>

</asp:SqlDataSource>

