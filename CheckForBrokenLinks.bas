Attribute VB_Name = "CheckForBrokenLinks"
Function GetAllHyperlinks()
    Dim pattern As String
    'Regular Expression pattern compatible with VBA to look for URLs
    'This expression does not work for strings like duckduckgo.com
    'It works only if the string starts with www or http or https
    pattern = "(www\.|https?:\/\/){1}[a-zA-Z0-9u00a1-\uffff0-]{2,}\.[a-zA-Z0-9u00a1-\uffff0-]{2,}(\S*)"
    Dim docCurrent As Document
    Set docCurrent = ActiveDocument
    Dim regex As New VBScript_RegExp_55.RegExp
    Dim allMatches As Object, match As Object
    With regex
        .IgnoreCase = True
        .Global = True
        .MultiLine = True
        .pattern = pattern
    End With
    'Find all URLs in the document
    Set matches = regex.Execute(docCurrent.Content.Text)
    Dim wrongURLs As String
    For Each match In matches
        Dim stringURL As String: stringURL = CStr(match)
        'Check if the URL exists
        If Not UrlExists(stringURL) Then
            'Adding carriage return at the end of each URL
            wrongURLs = wrongURLs & stringURL & Chr(13) & Chr(10)
        End If
    Next
    'If there are any unreachable URLs, show them to the user
    If Not IsEmpty(wrongURLs) Then
        'MsgBox (wrongURLs)
        WriteToNotepad (wrongURLs)
    End If
End Function

Function UrlExists(url As String) As Boolean
    Dim xmlHTTP As Object
    Set xmlHTTP = CreateObject("MSXML2.ServerXMLHTTP")
    'add http if doesnt already present in the url
    'if http is not specified xmlHTTP.Open will fail
    If Not UCase(url) Like "HTTP*" Then
        url = "http://" & url
    End If
    On Error GoTo haveError
    xmlHTTP.Open "HEAD", url, False
    xmlHTTP.send
    UrlExists = IIf(xmlHTTP.Status = 200, True, False)
    Exit Function
haveError:
'    MsgBox "Failed to parse the URL " & url & " due to - " & Err.Number & Err.Description, vbInformation
    UrlExists = False
End Function

Sub WriteToNotepad(inputString As String)
    'Assuming that the focus will not be lost between opening notepad and writing into it.
    Dim notepad As String
    notepad = Shell("Notepad", vbNormalFocus)
    SendKeys inputString, True
End Sub
