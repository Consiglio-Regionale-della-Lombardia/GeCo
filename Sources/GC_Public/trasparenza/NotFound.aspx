<%@ Page Language="C#" AutoEventWireup="true" CodeFile="NotFound.aspx.cs" Inherits="trasparenza_NotFound" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Gestione Consiglieri - Trasparenza - Contenuto non trovato</title>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
    <meta content="no-cache" http-equiv="Cache-Control" />
    <meta content="no-cache" http-equiv="Pragma" />
    <meta content="0" http-equiv="Expires" />
    <link href="~/css/tabs.css" rel="stylesheet" type="text/css" media="screen" />

    <script type="text/javascript" src="~/js/jquery.min.js"></script>
    <script type="text/javascript" src="~/js/sddm.js"></script>
    <link href="~/css/theme.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="~/js/modal_popup.js"></script>

    <style type="text/css">
        .message {
            background-color: #99cc99;
            border: 1px solid #EEE;
            font-weight: bold;
            font-family: Verdana;
            font-size: 16px;
            color: #006600;
            text-align: center;
            vertical-align: middle;
            padding: 10px;
            margin: 20px;
        }
    </style>
</head>
<body>
    <div class="message">
        <%= Message %>
    </div>
</body>
</html>
