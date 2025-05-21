-- カルテ印刷を制御する関数
on createPatientReport(patientID)
    -- KWReportSecretary を前面に出す（未起動なら起動）
    tell application "KWReportSecretary" to activate

    -- カルテ印刷ウィンドウが表示されるまで待機
    repeat
        tell application "System Events"
            if exists window "カルテ印刷" of process "KWReportSecretary" then exit repeat
        end tell
        delay 0.5
    end repeat

    -- 患者IDを入力
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
            if exists window "診療録" of process "KWReportSecretary" then exit repeat
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
    set currentDateTime to do shell script "date '+%Y%m%d_%H%M%S'"
    set fileName to patientID & "_" & currentDateTime & ".txt"
    set filePath to "/Users/shimizu/git/vintagewine-card/" & fileName

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

    -- KWReportSecretary を終了し、完全に終了するまで待機
    tell application "KWReportSecretary" to quit
    delay 1
end createPatientReport

on run
    -- 複数患者IDを入力
    set inputIDs to text returned of (display dialog "患者IDをカンマ・スペース・改行で区切って入力してください:" default answer "" buttons {"キャンセル", "OK"} default button "OK")
    if inputIDs is "" then return


    -- カンマ+スペースをカンマに統一
    set AppleScript's text item delimiters to {", "}
    set inputIDs to text items of inputIDs
    set AppleScript's text item delimiters to ","
    set inputIDs to inputIDs as text


    -- 区切り文字で分割
    set AppleScript's text item delimiters to {",", " ", return, linefeed}
    set idList to text items of inputIDs
    set AppleScript's text item delimiters to ""




    -- プログレスバーを表示
    set totalSteps to count idList
    set currentStep to 0
    
    repeat with patientID in idList
        set patientID to (patientID as string)
        if patientID is not "" then
            set currentStep to currentStep + 1
            set progress description to "カルテ印刷処理中: " & patientID & " (" & currentStep & "/" & totalSteps & ")"
            set progress total steps to totalSteps
            set progress completed steps to currentStep
            createPatientReport(patientID)
        end if
    end repeat

    -- 処理完了メッセージを表示
    display dialog "すべての患者IDの処理が完了しました。" buttons {"OK"} default button "OK"
end run
