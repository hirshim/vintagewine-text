-- カルテ印刷を制御
set patientID to "0"

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
set fileName to currentDate & "_" & patientID & ".txt"
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
