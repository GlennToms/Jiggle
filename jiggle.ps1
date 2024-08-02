# Import necessary namespaces for accessing Windows API
# Add-Type is used to define and load a new .NET type
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

# Constants for the ShowWindow function
$SW_MAXIMIZE = 3

# Get the handle of the foreground window
$hWnd = [User32]::GetForegroundWindow()

# Maximize the window
[User32]::ShowWindow($hWnd, $SW_MAXIMIZE)




Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class UserInput {
    [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
    public const int MOUSEEVENTF_MOVE = 0x0001;
    public const int MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const int MOUSEEVENTF_LEFTUP = 0x0004;
    public const int MOUSEEVENTF_ABSOLUTE = 0x8000;
}
"@

function Move-Mouse {
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

    # Move mouse to a random position on the screen
    $X = Get-Random -Minimum 0 -Maximum $screenWidth
    $Y = Get-Random -Minimum 0 -Maximum $screenHeight

    $absoluteX = [math]::round($x * 65535 / $screenWidth)
    $absoluteY = [math]::round($y * 65535 / $screenHeight)

    [UserInput]::mouse_event([UserInput]::MOUSEEVENTF_MOVE -bor [UserInput]::MOUSEEVENTF_ABSOLUTE, $absoluteX, $absoluteY, 0, 0)
}

function Click-Mouse {
    [UserInput]::mouse_event([UserInput]::MOUSEEVENTF_MOVE -bor [UserInput]::MOUSEEVENTF_ABSOLUTE, 0, 0, 0, 0)
    [UserInput]::mouse_event([UserInput]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    Start-Sleep -Milliseconds 100
    [UserInput]::mouse_event([UserInput]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
}

function Check-Stop {
    return [System.Console]::KeyAvailable
}

Clear-Host

$TEXT = @"
.----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |     _____    | || |     _____    | || |    ______    | || |    ______    | || |   _____      | || |  _________   | |
| |    |_   _|   | || |    |_   _|   | || |  .' ___  |   | || |  .' ___  |   | || |  |_   _|     | || | |_   ___  |  | |
| |      | |     | || |      | |     | || | / .'   \_|   | || | / .'   \_|   | || |    | |       | || |   | |_  \_|  | |
| |   _  | |     | || |      | |     | || | | |    ____  | || | | |    ____  | || |    | |   _   | || |   |  _|  _   | |
| |  | |_' |     | || |     _| |_    | || | \ '.___]  _| | || | \ '.___]  _| | || |   _| |__/ |  | || |  _| |___/ |  | |
| |  '.___.'     | || |    |_____|   | || |  '._____.'   | || |  '._____.'   | || |  |________|  | || | |_________|  | |
| |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PRESS ANY KEY TO EXIT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

"@

Write-Host "$Text"


# Main script loop
while ($true) {
    Click-Mouse

    # Wait for a random time between 1 and 5 minutes
    $waitTime = Get-Random -Minimum 60 -Maximum 300
    $waitTime = Get-Random -Minimum 5 -Maximum 10
    for ($i = 0; $i -lt $waitTime; $i++) {
        Move-Mouse
        if (Check-Stop) {
            Write-Host "Exit command detected. Exiting..." -ForegroundColor Red
            Clear-Host
            exit
        }
        Start-Sleep -Seconds 1
    }
}
