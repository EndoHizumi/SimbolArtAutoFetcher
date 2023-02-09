$ErrorActionPreference = "Stop"
$myDocument=[System.Environment]::GetFolderPath("MyDocuments")
$history="$myDocument\SEGA\PHANTASYSTARONLINE2\symbolarts\cache\"

try {
    Write-Host 'SimbolArtAutoFetcher v.0.0.2 @Endo_hizumi'
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $history  # 監視するディレクトリ
    $watcher.Filter = "*.sar"  # ファイル名
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents   = $true

    $moveSa = {
        $myDocument=[System.Environment]::GetFolderPath("MyDocuments")
        $import="$myDocument\SEGA\PHANTASYSTARONLINE2\symbolarts\import\"
        $name = $Event.SourceEventArgs.Name 
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType 
        $timeStamp = $Event.TimeGenerated 
        Write-Host "The file '$name' was $changeType at $timeStamp" -ForegroundColor red 
        move-item $path $import -Verbose -Force
    }

    [string] $sourceId = New-Guid
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $moveSa -SourceIdentifier $sourceId | Out-Null
    Register-ObjectEvent $watcher "Changed" -Action $moveSa | Out-Null
    Register-ObjectEvent $watcher "Renamed" -Action $moveSa | Out-Null
    Wait-Event -SourceIdentifier $sourceId
    
} finally {
  Write-Debug -vb 'Cleaning up...'
  Unregister-Event -SourceIdentifier $sourceId
  $watcher.Dispose() 
}