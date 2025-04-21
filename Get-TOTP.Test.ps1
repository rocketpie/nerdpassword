[CmdletBinding()]
Param(
)

if ($PSBoundParameters['Debug']) {
    $DebugPreference = 'Continue'
}

function PrintResult {
    param (
        [bool]$TestResult
    )

    if ($TestResult) { return "PASS" }
    return "FAIL  <----  !!!!"
}

$sut = $MyInvocation.MyCommand.Definition.Replace('.Test', '')

# https://datatracker.ietf.org/doc/html/rfc4226#page-32 Appendix D
$rfcTestData = @{
    0 = "755224"
    1 = "287082"
    2 = "359152"
    3 = "969429"
    4 = "338314"
    5 = "254676"
    6 = "287922"
    7 = "162583"
    8 = "399871"
    9 = "520489"
}

foreach ($key in $rfcTestData.Keys) {
    $expected = $rfcTestData[$key]    
    # GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ decodes to 0x3132333435363738393031323334353637383930
    $actual = & $sut -Base32Secret "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ" -OtpTime ([datetime]::new(1970, 1, 1).AddSeconds(30 * $key))
    $actual = $actual[0].Replace(' ', '')
    "TOTP-Test $($key) ($($expected) == $($actual)): $(PrintResult ($expected -eq $actual))"
}
