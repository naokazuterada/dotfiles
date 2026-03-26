-- VPN Timer
-- VPN接続して指定時間後に自動切断するアプリ
-- osacompile -o ~/Applications/VPN\ Timer.app VPNTimer.applescript

property pidFile : "/tmp/vpn_timer.pid"
property timerScript : "/tmp/vpn_timer_bg.sh"
property endTimeFile : "/tmp/vpn_timer_end.txt"

on run
	-- 既存タイマーの確認
	set existingPid to ""
	try
		set existingPid to do shell script "cat " & pidFile & " 2>/dev/null"
	end try

	if existingPid is not "" then
		set isRunning to false
		try
			do shell script "kill -0 " & existingPid & " 2>/dev/null"
			set isRunning to true
		end try

		if isRunning then
			-- HUDを再表示
			set hudBin to do shell script "echo ~/.dotfiles/vpn-timer/vpn-timer-hud"
			set endTimeVal to do shell script "cat " & endTimeFile & " 2>/dev/null"
			set disconnectScptFile to "/tmp/vpn_timer_disconnect.scpt"
			do shell script "/bin/bash -c 'nohup " & quoted form of hudBin & " " & endTimeVal & " " & disconnectScptFile & " > /dev/null 2>&1 &'"
			return
		else
			try
				do shell script "rm -f " & pidFile & " " & timerScript
			end try
		end if
	end if

	-- 時間選択
	set timeOptions to {"10秒（テスト）", "5分", "15分", "30分", "1時間", "2時間", "3時間", "4時間", "5時間", "6時間", "7時間", "8時間"}
	set selectedTime to choose from list timeOptions with prompt "VPN接続時間を選択してください" with title "VPN Timer" default items {"1時間"}

	if selectedTime is false then return
	set selectedTime to item 1 of selectedTime

	-- 秒数に変換
	set duration to 0
	if selectedTime is "10秒（テスト）" then
		set duration to 10
	else if selectedTime is "5分" then
		set duration to 300
	else if selectedTime is "15分" then
		set duration to 900
	else if selectedTime is "30分" then
		set duration to 1800
	else if selectedTime is "1時間" then
		set duration to 3600
	else if selectedTime is "2時間" then
		set duration to 7200
	else if selectedTime is "3時間" then
		set duration to 10800
	else if selectedTime is "4時間" then
		set duration to 14400
	else if selectedTime is "5時間" then
		set duration to 18000
	else if selectedTime is "6時間" then
		set duration to 21600
	else if selectedTime is "7時間" then
		set duration to 25200
	else if selectedTime is "8時間" then
		set duration to 28800
	end if

	-- VPN接続
	vpn_connect()
	delay 2

	-- 終了時刻を保存（現在のUnix時刻 + duration秒）
	do shell script "echo $(( $(date +%s) + " & duration & " )) > " & endTimeFile

	-- 切断用AppleScriptをファイルに書き出す
	set disconnectScptFile to "/tmp/vpn_timer_disconnect.scpt"
	set disconnectScptSrc to "tell application \"System Events\"
tell menu bar 1 of application process \"SystemUIServer\"
set vpnMenu to menu bar item 1
click vpnMenu
delay 0.3
tell vpnMenu
try
click menu item \"接続解除: MyIP\" of menu 1
on error
key code 53
end try
end tell
end tell
end tell"
	do shell script "osacompile -o " & disconnectScptFile & " -e " & quoted form of disconnectScptSrc

	-- バックグラウンドタイマー起動
	set scriptContent to "#!/bin/bash" & linefeed & "sleep " & duration & linefeed & "osascript " & disconnectScptFile & linefeed & "osascript -e 'display notification \"タイマー終了。VPNを自動切断しました\" with title \"VPN Timer\"'" & linefeed & "rm -f " & pidFile & " " & timerScript & " " & disconnectScptFile & " " & endTimeFile

	do shell script "echo " & quoted form of scriptContent & " > " & timerScript & " && chmod +x " & timerScript
	set pid to do shell script "/bin/bash -c 'nohup " & timerScript & " > /dev/null 2>&1 & echo $!'"
	do shell script "echo " & pid & " > " & pidFile

	-- HUDウィンドウを起動（リアルタイムカウントダウン表示）
	set hudBin to do shell script "echo ~/.dotfiles/vpn-timer/vpn-timer-hud"
	set endTimeVal to do shell script "cat " & endTimeFile
	do shell script "/bin/bash -c 'nohup " & quoted form of hudBin & " " & endTimeVal & " " & disconnectScptFile & " > /dev/null 2>&1 &'"
end run

on vpn_connect()
	tell application "System Events"
		tell menu bar 1 of application process "SystemUIServer"
			set vpnMenu to menu bar item 1
			click vpnMenu
			delay 0.3
			tell vpnMenu
				try
					click menu item "接続: MyIP" of menu 1
				on error
					key code 53
				end try
			end tell
		end tell
	end tell
end vpn_connect

on vpn_disconnect()
	tell application "System Events"
		tell menu bar 1 of application process "SystemUIServer"
			set vpnMenu to menu bar item 1
			click vpnMenu
			delay 0.3
			tell vpnMenu
				try
					click menu item "接続解除: MyIP" of menu 1
				on error
					key code 53
				end try
			end tell
		end tell
	end tell
end vpn_disconnect
