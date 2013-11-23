    '----------------------------------------------------------------------
    ' MediaMonkey\Scripts\Auto\AutoChangeEqualizer.vbs
    '
    ' Version: 3.1.0.1     20 June 2009    By SatinKnights
    '
    'Requires 3.1.0.1221 or better for the SDB.Player.LoadEqualizerPreset()
    'and SDB.Player.isEqualizer functions.
    '
    ' History
    ' 3.1 The wrong variable name was checked at startup, so it was not
    '     not remebering it's state correctly between restarts.
    '
    ' 3.0 Switched from keyboard stuffing to new Equalizer functions 
    '     by SatinKnights 2-5-09
    '
    '     29 January 2009  Changes made possible by jiri fullfilling a 
    '     request from me to add SDB.Player.LoadEqualizerPreset() as a 
    '     script accessable function.  I asked for new code, and the 
    '     following day it was available.
    '     This is AMAZING work by jiri and the rest of the development crew.
    '
    ' 2.2 Added default.sde and quality support 
    '      by SatinKnights unreleased 10-31-08
    '
    ' 2.1 Fixed for MM3 by Modementia 10-09-08
    '
    ' 2.0 By DiddeLeeDoo 13 September 2006
    '    Original for MM2 
    '    http://mediamonkey.com/forum/viewtopic.php?f=2&t=11302
    '    Uses wscript and keyboard stuffing to change the equalizer preset
    ' 
    '----------------------------------------------------------------------

    '----------------------------------------------------------------------
    ' Documentation: This script automatically adjusts the equalizer to
    ' presets depending on genre of the song.  For those needing even
    ' finer control and detail, the genre choice can be overridden by 
    ' having an equalizer preset that has the same name as a "Quality"
    ' classification.
    '
    ' Requirement: Create and save a "default.sde" equalizer setting for
    ' the settings that any song should default to if there are no more
    ' specific matches found. 
    '
    ' Example Setup: Then create your genre specific equalizer settings
    ' with the same names as your genres.  For example: Rock.sde, Jazz.sde,
    ' Dance.sde, Reggae.sde, Audio Book.sde, etc.
    '
    ' Now, overrides:  Also create "extra bass.sde" with a boosted bass,
    ' "hissy.sde" with the high range dampened, "voice only.sde" with the
    ' high and low ranges dampened.  
    '
    ' Now, an audio book recording made at 32 kbps should be tagged with 
    ' genre=Audio Book, quality=hissy.  The "hissy" will take precedence 
    ' and be the preset loaded at the start of the track.  The use of the
    ' quality to override the genre allows one to keep the genre listings
    ' tiddy.  Likewise, Janet Jackson's Black Cat could be tagged with 
    ' Dance but be adjusted with "extra bass" in the quality field.
    '
    ' Priority: first quality value, first genre, default.sde, no change
    ' Quality and Genre fields that contain multiple values seperated by
    ' semicolons use the first value.  
    '
    ' Without the required default.sde equalizer setting mentioned above, 
    ' the script could stay on Rock settings when switching to a Blues 
    ' track if Blues.sde did not exist.
    ' 
    ' For those who wish to, Quality can be disabled as a selector by
    ' commenting out lines 150-169. 
    '
    ' If the Equalizer is disabled, and the user turns on the Auto Equalizer
    ' via the menu, the Equalizer is enabled.
    '
    ' Bugs: The words "Auto Change " and other texts should be also be
    '       internationalized.
    '----------------------------------------------------------------------

'* Change to True to enable logging.  Log file = $TEMP\AutoChangeEqualizer.log
Dim Debug : Debug = False
Dim dqt   : dqt = Chr(34)

Sub OnStartup
    Set Mnu = SDB.UI.AddMenuItem(SDB.UI.Menu_Play,4,2)
    VerChk = (SDB.VersionHi * 100000) + _
             (SDB.VersionLo * 10000) + SDB.VersionBuild
    If (VerChk < 311221) Then
        Mnu.Caption = "Auto " & SDB.Localize("Eq ") &_
                      "Disabled. Requires 3.1.0.1221+"
        Mnu.Hint = "This script requires new functions only " &_
                   "available in version 3.1.0.1221 or later."
        If Debug Then Call out("AutoChangeEqualizer script disabled " &_
                      " because the necessary functions are not available.")
    Else
        Mnu.Caption = "Auto Change " & SDB.Localize("Equalizer ")
        Mnu.Hint = "Automatically change the Equalizer preset " &_
                   "based on Quality and Genre tags (on/off)"
        Mnu.UseScript = Script.ScriptPath
        Mnu.Checked = SDB.IniFile.BoolValue("AutoChangeEqualizer","EQ_Auto")
        Mnu.OnClickFunc = "AutoChangeEqualizer_MenuSwitch"
        If Debug Then Call out("OnStartup() menu registered. EQ active?: " &_
                 "isEQ=" & SDB.Player.isEqualizer & " vs Ini=" &_
                  SDB.IniFile.BoolValue("Equalizer","Enabled") )
        SDB.Objects("AutoChangeEqualizer_Check_Mnu") = Mnu
        If Mnu.Checked Then
            Script.RegisterEvent SDB, "OnPlay", "AutoChangeEqualizer_Check"
            If Debug Then Call out("OnPlay() event registered.")
        Else
            If Debug Then Call out("Menu Item off currently, OnPlay() "&_
                                   "event not registered.")
        End If
        '* Auto-Nag at startup if the default.sde has not been created yet.
        If Not SDB.Tools.FileSystem.FileExists(SDB.EqualizerPath & "Default.sde") Then
            MsgDeleteSettings = "The AutoChangeEqualizer script really works best if " &_
                                "there is a " & dqt & "Default.sde" & dqt & _
                                " Equalizer preset." & vbNewLine &_
                    "Go open the equalizer and save a preset called " & dqt & _
                    "Default.sde" & dqt & " to avoid this nagging at startup."
            Answer = MsgBox(MsgDeleteSettings, vbOkOnly)
            '* Don't care about the answer
        End If
    End If
End Sub

Function AutoChangeEqualizer_MenuSwitch(Mnu)
    If SDB.Objects("AutoChangeEqualizer_Check_Mnu").Checked Then
        SDB.Objects("AutoChangeEqualizer_Check_Mnu").Checked = False
        SDB.IniFile.BoolValue("AutoChangeEqualizer","EQ_Auto") = False
        If Debug Then Call out("Menu item " & dqt & "Auto Change Equalizer" &_
                               dqt & " clicked off.")
    Else
        SDB.Objects("AutoChangeEqualizer_Check_Mnu").Checked = True
        SDB.IniFile.BoolValue("AutoChangeEqualizer","EQ_Auto") = True
        Script.RegisterEvent SDB, "OnPlay", "AutoChangeEqualizer_Check"
        '*
        '* The equalizer was off, but the user just turned on the 
        '* auto change equalizer, so we enable the equalizer also.
        '* We do not do the reverse, so if the user manually chooses
        '* a preset, we do not disable it.
        '*
        If SDB.Player.isEqualizer = False Then
            SDB.Player.isEqualizer = True
        End If
        If Debug Then Call out("Menu item " & dqt & "Auto Change Equalizer" &_
                               dqt & " clicked on.")    
        If Debug Then Call out("We enabled the equalizer also.")    
    End If
End Function

Sub AutoChangeEqualizer_Check
'    If Debug Then Call out("Starting a song. Is the EQ active?:" &_
'             " isEQualizer = " & SDB.Player.isEqualizer &_
'             " vs Ini = " & SDB.IniFile.BoolValue("Equalizer","Enabled"))

    If SDB.Player.isEqualizer=True And _
       SDB.Objects("AutoChangeEqualizer_Check_Mnu").Checked Then
        FirstGenre = ""
'*
'* For people who don't like using the Quality field, disable the 
'* next twenty lines by placing a ' in the first column to comment out
'* the code.  A different tag can be chosen by replacing "Quality" with
'* another tag database name.
'*
        If SDB.Player.CurrentSong.Quality <> "" Then
            tmpArray = Split(SDB.Player.CurrentSong.Quality,";",-1,1)
            FirstQuality = tmpArray(0)

            '* Paranoia is a good thing
            If InStr(FirstQuality, "\") or InStr(FirstQuality, "/") Then 
                FirstGenre = "default"
                If Debug Then Call out("Paranoia: The quality contains a " &_
                         " \ or / so we revert to the default.sde file.")
            End If

            If FirstQuality <> "" Then 
                If SDB.Tools.FileSystem.FileExists(SDB.EqualizerPath &_
                   FirstQuality &".sde") Then
                    FirstGenre = FirstQuality
                    If Debug Then Call out("Quality chose possible equalizer " &_
                                           " preset change to " & FirstQuality)
                End If
            End If
        End If
'*
'* Stopping here.
'*
        If Not FirstGenre <> "" Then 
            If SDB.Player.CurrentSong.Genre <> "" Then
                tmpArray = Split(SDB.Player.CurrentSong.Genre,";",-1,1)
                FirstGenre = tmpArray(0)
            End If
        End If

        '* Paranoia is a good thing
        If InStr(FirstGenre, "\") or InStr(FirstGenre, "/") Then 
            FirstGenre = "default"
            If Debug Then Call out("Paranoia: The genre contains a \ or" &_
                     " / so we revert to the default.sde file.")
        End If

        If FirstGenre <> "" Then
            If Not SDB.Tools.FileSystem.FileExists(SDB.EqualizerPath &_
                                                   FirstGenre &".sde") Then
                FirstGenre ="default"
            End If
        Else 
            FirstGenre ="default"
        End If
            
        If SDB.Tools.FileSystem.FileExists(SDB.EqualizerPath & _
                                           FirstGenre & ".sde") And Not _
           SDB.IniFile.StringValue("AutoChangeEqualizer","EQ_LastSong")=FirstGenre Then
            If Not SDB.Player.isPaused Then
                SDB.Player.Pause
                If Debug Then Call out("Pausing playback to change preset")
            End If
            SDB.Player.LoadEqualizerPreset(FirstGenre &".sde")
            SDB.IniFile.StringValue("AutoChangeEqualizer","EQ_LastSong") = FirstGenre
            If Debug Then Call out("Equalizer preset changed to " & dqt & _
                                   FirstGenre & dqt & " for " &_
                                   dqt & SDB.Player.CurrentSong.Title & dqt)

            '* A pause, followed by a second quickly to unPause, is too fast and 
            '* not processed.  So, we just execute a play to restart the music.
            '* This causes the script to repeat but causes no confusion for us.
            '* WARNING: It may hiccup other OnPlay() scripts
            SDB.Player.Play
            If Debug Then Call out("Restarting playback after change")
        End If   
    Else
        '* The menu option or the equalizer is off, so disable ourselves.
        Script.UnRegisterEvents SDB
    End If
End Sub


Sub out(txt)
    Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
    Dim loc : loc = SDB.TemporaryFolder & "\AutoChangeEqualizer.log"
    Dim logf : Set logf = fso.OpenTextFile(loc,8,True)
    logf.WriteLine(SDB.ToAscii(txt))
    logf.Close
End Sub
