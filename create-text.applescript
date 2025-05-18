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

-- テキストをコピー
tell application "System Events"
    tell process "KWReportSecretary"
        set theText to value of text area 1 of scroll area 1 of window "診療録"
    end tell
end tell

-- ファイルに保存
set filePath to ((path to desktop) as text) & patientID & ".txt"
set fileRef to open for access filePath with write permission as «class utf8»
write theText to fileRef
close access fileRef
