# akvirtualcamera, virtual camera for Mac and Windows.
# Copyright (C) 2021  Gonzalo Exequiel Pedone
#
# akvirtualcamera is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# akvirtualcamera is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with akvirtualcamera. If not, see <http://www.gnu.org/licenses/>.
#
# Web-Site: http://webcamoid.github.io/

!include LogicLib.nsh
!include x64.nsh

Var arch
Var narchs
Var assistantPath
Var managerPath

Function InstallPlugin
    Push "x86"
    StrCpy $narchs 1

    ${If} ${RunningX64}
        Push "x64"
        StrCpy $narchs 2
    ${EndIf}

    ${For} $R1 1 $narchs
        Pop $arch

        # Load assistant daemon.
        StrCpy $assistantPath "$INSTDIR\$arch\AkVCamAssistant.exe"

        ${If} ${FileExists} "$assistantPath"
            ExecShellWait "" "$assistantPath" "--install" SW_HIDE
        ${EndIf}

        ExecShellWait "" "sc" "start AkVCamAssistant" SW_HIDE
    ${Next}
FunctionEnd

Function un.InstallPlugin
    Push "x86"
    StrCpy $narchs 1

    ${If} ${RunningX64}
        Push "x64"
        StrCpy $narchs 2
    ${EndIf}

    ${For} $R1 1 $narchs
        Pop $arch

        # If the assistant is not running, start it so it won't hang the manager.
        StrCpy $assistantPath "$INSTDIR\$arch\AkVCamAssistant.exe"
        ExecShellWait "" "sc" "start AkVCamAssistant" SW_HIDE

        # Remove virtual cameras
        StrCpy $managerPath "$INSTDIR\$arch\AkVCamManager.exe"

        ${If} ${FileExists} "$managerPath"
            ExecShellWait "" "$managerPath" "remove-devices" SW_HIDE
            ExecShellWait "" "$managerPath" "update" SW_HIDE
        ${EndIf}

        # Uninstall assistant daemon.
        ExecShellWait "" "sc" "stop AkVCamAssistant" SW_HIDE

        ${If} ${FileExists} "$assistantPath"
            ExecShellWait "" "$assistantPath" "--uninstall" SW_HIDE
        ${EndIf}

        # If the assistant is still alive, kill it, no mercy.
        ExecShellWait "" "taskkill" "/F /IM AkVCamAssistant.exe" SW_HIDE
    ${Next}
FunctionEnd

!macro INSTALL_SCRIPT_AFTER_INSTALL
    Call InstallPlugin
!macroend

!macro INSTALL_SCRIPT_UNINSTALL
    Call un.InstallPlugin
!macroend
