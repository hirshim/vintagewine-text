-- カルテ印刷を制御する関数
on createPatientReport(patientID)
    -- KWReportSecretary を起動
    tell application "KWReportSecretary"
        activate
    end tell

    -- カルテ印刷ウィンドウが表示されるまで待機
    repeat
        tell application "System Events"
            if exists window "カルテ印刷" of process "KWReportSecretary" then
                exit repeat
            end if
        end tell
        delay 0.5
    end repeat

    -- KWReportSecretary のテキストフィールドに患者IDを入力
    tell application "System Events"
        tell process "KWReportSecretary"
            set frontmost to true
            set focused of text field 1 of window "カルテ印刷" to true
                keystroke patientID
                keystroke return
        end tell
    end tell

    -- 印刷準備ボタンをクリック
    tell application "System Events"
        tell process "KWReportSecretary"
            click button "印刷準備" of window "カルテ印刷"
        end tell
    end tell

    -- 診療録ウィンドウが表示されるまで待機
    repeat
        tell application "System Events"
            if exists window "診療録" of process "KWReportSecretary" then
                exit repeat
            end if
        end tell
        delay 0.5
    end repeat

    -- テキストを取得
    tell application "System Events"
        tell process "KWReportSecretary"
            set focused of text area 1 of scroll area 1 of window "診療録" to true
            set textContent to value of text area 1 of scroll area 1 of window "診療録"
        end tell
    end tell

    -- ファイルに保存
    set currentDate to do shell script "date '+%Y%m%d'"
    set fileName to patientID & "_" & currentDate & ".txt"
    set filePath to "/Users/shimizu/git/vintagewine-card/" & fileName

    -- テキストをUTF-8でファイルに保存
    try
        set fileRef to open for access filePath with write permission
        set eof of fileRef to 0
        write textContent to fileRef as «class utf8»
        close access fileRef
    on error errMsg
        try
            close access fileRef
        end try
        display dialog "ファイルの保存中にエラーが発生しました: " & errMsg buttons {"OK"} default button "OK" with icon stop
    end try

    -- KWReportSecretaryを終了
    tell application "KWReportSecretary"
        quit
    end tell
    delay 1
end createPatientReport

on run
    -- 複数患者IDを入力するダイアログを表示
    set inputIDs to text returned of (display dialog "患者IDをカンマ・スペース・改行で区切って入力してください:" default answer "" buttons {"キャンセル", "OK"} default button "OK")
    
    -- キャンセルまたは空欄の場合は終了
    if inputIDs is "" then
        return
    end if
    
    -- カンマ+スペースを単一のカンマに置換
    set AppleScript's text item delimiters to {", "}
    set inputIDs to text items of inputIDs
    set AppleScript's text item delimiters to ","
    set inputIDs to inputIDs as text
    
    -- 区切り文字で分割（カンマ、スペース、改行）
    set AppleScript's text item delimiters to {",", " ", return, linefeed}
    set idList to text items of inputIDs
    set AppleScript's text item delimiters to ""
    -- IDリストをダイアログに表示
    set idListStr to ""
    repeat with id in idList
        if id is not "" then
            set idListStr to idListStr & id & return
        end if
    end repeat

    display dialog "以下の患者IDを処理します:" & return & return & idListStr buttons {"キャンセル", "続行"} default button "続行"
    if button returned of result is "キャンセル" then
        return
    end if

    -- 各IDに対して処理
    repeat with patientID in idList
        set patientID to (patientID as string)
        if patientID is not "" then
            createPatientReport(patientID)
        end if
    end repeat
end run
