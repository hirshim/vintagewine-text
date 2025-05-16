-- カルテ印刷を制御
set patientID to "0"

-- KWReportSecretary を起動
tell application "KWReportSecretary"
    activate
end tell

-- 1秒待つ
delay 1

-- KWReportSecretary のテキストフィールドに患者IDを入力
tell application "System Events"
    tell process "KWReportSecretary"
        set frontmost to true
--        set value of text field 1 of window "カルテ印刷" to patientID
    end tell
end tell

-- 改行コードを入力
tell application "System Events"
    tell process "KWReportSecretary"
        set focused of text field 1 of window "カルテ印刷" to true
            keystroke patientID
            keystroke return
    end tell
end tell

