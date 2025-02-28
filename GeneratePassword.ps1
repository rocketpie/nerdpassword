[CmdletBinding()]
Param(
    [ValidateSet('eff-short', 'eff-long', 'nerd')]
    $list = 'eff-short',
    [string]$pattern = '{word}-{word}-{word}-{word}'
)

[string]$result = $pattern
$wordList = @(Get-Content (Join-Path $PSScriptRoot "$($list)list.txt"))

function ReplaceMatch {
    param (
        [string]$Text,
        [System.Text.RegularExpressions.Match]$Match,
        [string]$Replacement
    )    
    
    $result = $Text.Substring(0, $Match.Index)
    $result += $Replacement
    $result += $Text.Substring($Match.Index + $Match.Length)
    return $result
}

$placeHolders = [regex]::Matches($result, '\{(\w+)\}')
for ($i = ($placeHolders.Count - 1); $i -ge 0; $i--) {   

    $replacement = $null
    switch ($placeHolders[$i].Groups[1].Value) {
        'word' {
            $replacement = $wordList[(Get-Random -Minimum 0 -Maximum $wordList.Count)]
        }

        'digit' {
            $replacement = (Get-Random -Minimum 0 -Maximum 9).ToString()
        }

        'guid' {
            $replacement = [guid]::NewGuid().ToString().ToLower()
        }

        Default {
            Write-Error "pattern not found: '$(placeHolders[$i].Groups[1].Value)'"
        }
    }

    $result = ReplaceMatch -Text $result -Match $placeHolders[$i] -Replacement $replacement
}

$result