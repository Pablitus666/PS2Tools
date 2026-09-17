$ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Modules = @(
    'Core\Disc.Utilities.ps1',
    'Core\Disc.Context.ps1',
    'Core\Disc.Scanner.ps1',
    'Core\Disc.Report.ps1',
    'Core\Language.Provider.ps1',
    'PlayStation\SystemCnf.Provider.ps1',
    'PlayStation\Serial.Provider.ps1',
    'PlayStation\Homebrew.Provider.ps1',
    'PlayStation\Artifacts.Provider.ps1',
    'PlayStation\Elf.Provider.ps1',
    'PlayStation\Features.Provider.ps1',
    'Database\Game.Database.ps1'
)
foreach ($Module in $Modules) { . (Join-Path $ModuleRoot $Module) }

. (Join-Path $ModuleRoot '..\Html\PS2Tools.Html.ps1')
