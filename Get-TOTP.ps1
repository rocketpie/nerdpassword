<#
    given a standard TOTP Key (BASE32 secret), 
    calculate the current and next standard TOTP (6-digit, 30s, SHA1)
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Base32Secret,
    [datetime]$OtpTime = [datetime]::UtcNow
)

if ($PSBoundParameters['Debug']) {
    $DebugPreference = 'Continue'
}

function Main {
    param (
        [string]$Base32Secret,
        [datetime]$OtpTime
    )
        
    $keyBytes = ConvertFrom-Base32String $Base32Secret
    Write-Debug "keyBytes: '$(($keyBytes | ForEach-Object { $_.ToString('X2')}) -join '')'"
    if (($null -eq $keyBytes) -or ($keyBytes.Count -lt 1)) {
        Write-Error "could not convert the -Base32Secret"
        return
    }

    # based on https://en.wikipedia.org/wiki/Time-based_One-time_Password
    $t_minus_t0 = [System.Math]::Floor(($OtpTime - [datetime]::new(1970, 1, 1)).TotalSeconds)
    $bigT_x = 30
    $bigC_t = [System.Math]::Floor($t_minus_t0 / $bigT_x)
    $counterExpires = [System.Math]::Floor((($bigC_t + 1) * $bigT_x) - $t_minus_t0)
    Write-Debug "T-T0: $($t_minus_t0), T_x: $($bigT_x), C_t: $($bigC_t), expires: $($counterExpires)s"

    $token = Get-HOTP -KeyBytes $keyBytes -counter $bigC_t
    # add some spaces
    "$(FormatToken $token)"
    
    "`ntoken expires in $($counterExpires)s"
    $bigC_t++
    $nextToken = Get-HOTP -KeyBytes $keyBytes -counter $bigC_t
    # add some spaces
    "next: $(FormatToken $nextToken)"
}

function FormatToken {
    Param(
        [string]$token
    )
    # add some spaces
    return ($token -replace '^(.{3})(.{3})(.*)$', '$1 $2 $3').Trim()
}

function ConvertFrom-Base32String([string]$base32String) {
    if (-not $base32String) {
        return [byte[]]::new(0)
    }
    while (($base32String.Length % 8) -ne 0) {
        $base32String += "="
    }

    $base32String = $base32String.ToUpperInvariant();

    $BITS_PER_BYTE = 8;
    $BITS_PER_CHAR = 5;
    $BASE_32_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

    $bufferSize = (($base32String.Length * $BITS_PER_CHAR) / $BITS_PER_BYTE)
    if ([System.Math]::Floor($bufferSize) -ne $bufferSize) {
        Write-Error "invalid base32: evenly-divisible-bufferSize check failed: $($bufferSize)"
        return
    }
    $byteBuffer = [byte[]]::new($bufferSize);

    # 40 bit blocks a 5 bytes / 8 chars
    $blockIdx = 0
    while ((($blockIdx * 5) + 4) -lt $byteBuffer.Length) {
        # translate 8 characters to bytes, treating '='-padding as 0's
        $charBytes = @(0..8 | % { $BASE_32_ALPHABET.IndexOf($base32String[(($blockIdx * 8) + $_)]) } | % { [System.Math]::Max($_, 0) })

        # see diagram in https://de.wikipedia.org/wiki/Base32
        # byte 1 from character 1 and 2
        $byteBuffer[($blockIdx * 5) + 0] = ($charBytes[0] -shl 3) % 256
        $byteBuffer[($blockIdx * 5) + 0] += $charBytes[1] -shr 2

        # byte 2 from character 2, 3 and 4
        $byteBuffer[($blockIdx * 5) + 1] = ($charBytes[1] -shl 6) % 256
        $byteBuffer[($blockIdx * 5) + 1] += ($charBytes[2] -shl 1) % 256
        $byteBuffer[($blockIdx * 5) + 1] += $charBytes[3] -shr 4

        # byte 3 from character 4 and 5
        $byteBuffer[($blockIdx * 5) + 2] = ($charBytes[3] -shl 4) % 256
        $byteBuffer[($blockIdx * 5) + 2] += $charBytes[4] -shr 1

        # byte 4 from character 5, 6 and 7
        $byteBuffer[($blockIdx * 5) + 3] = ($charBytes[4] -shl 7) % 256
        $byteBuffer[($blockIdx * 5) + 3] += ($charBytes[5] -shl 2) % 256
        $byteBuffer[($blockIdx * 5) + 3] += $charBytes[6] -shr 3

        # byte 5 from character 6 and 7
        $byteBuffer[($blockIdx * 5) + 4] = ($charBytes[6] -shl 5) % 256
        $byteBuffer[($blockIdx * 5) + 4] += $charBytes[7]

        $blockIdx++
    }

    $dataSize = [Math]::Floor(($base32String.TrimEnd('=').Length * $BITS_PER_CHAR) / $BITS_PER_BYTE)
    Write-Debug "BASE32: $($bufferSize)b buffer, $($dataSize)b data"
    if (($bufferSize -gt $dataSize) -and $byteBuffer[$dataSize] -gt 0) {
        Write-Error "invalid base32: padded data bytes found"
        return
    }

    if ($dataSize -eq $bufferSize) {
        return $byteBuffer
    }
    else {
        $result = [byte[]]::new($dataSize)
        [array]::Copy($byteBuffer, 0, $result, 0, $result.Length)
        return $result
    }
}

# https://datatracker.ietf.org/doc/html/rfc4226#section-5 5.4
function Rfc4226Truncate([byte[]]$hashBytes) {
    $offset = $hashBytes[-1] -band 0xF
    if ($offset + 3 -gt $hashBytes.Length) {
        Write-Error "IndexOutOfRange: $($offset+3) > $($hashBytes.Length)"
    }

    $result = ($hashBytes[$offset] -band 0x7F) -shl 24
    $result = $result -bor (($hashBytes[($offset + 1)] -band 0xFF) -shl 16)
    $result = $result -bor (($hashBytes[($offset + 2)] -band 0xFF) -shl 8)
    $result = $result -bor (($hashBytes[($offset + 3)] -band 0xFF))
    return $result
}

# based on https://en.wikipedia.org/wiki/HMAC-based_One-time_Password_Algorithm#Definition
function Get-HOTP([byte[]]$KeyBytes, [long]$counter) {
    $counterBytes = [System.BitConverter]::GetBytes($counter)
    if ([System.BitConverter]::IsLittleEndian) {
        [Array]::Reverse($counterBytes)
    }
    Write-Debug "Counter: $([System.BitConverter]::ToString($counterBytes).Replace('-', '').ToLower())"
    
    $hmacBytes = [System.Security.Cryptography.HMACSHA1]::new($KeyBytes).ComputeHash($counterBytes)
    Write-Debug "HMACSHA1: $([System.BitConverter]::ToString($hmacBytes).Replace('-', '').ToLower())"
    
    $hotp = Rfc4226Truncate -hashBytes $hmacBytes
    Write-Debug "HOTP: $($hotp)"
    
    $tokenLength = 6
    $hotpValue = ($hotp % [System.Math]::Pow(10, $tokenLength)).ToString().PadLeft($tokenLength, '0')
    return $hotpValue
}


Main -Base32Secret $Base32Secret -OtpTime $OtpTime