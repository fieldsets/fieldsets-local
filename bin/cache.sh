#!/usr/bin/env -S pwsh -NoLogo -NoExit -WorkingDirectory "/usr/local/fieldsets/"

function getFieldType {
    param(
        [Parameter(Mandatory=$true,Position=0)][String]$data_type
    )
    $field_type_id = 0
    $field_type = 'none'
    switch ($data_type.ToLower()) {
        ({
            ($_ -eq 'hashtable') -or
            ($_ -eq 'object') -or
            ($_ -eq 'drdereddictionary') -or
            ($_ -eq 'dictionary')
        }) {
            $field_type_id = 6
            $field_type = 'object'
            break
        }
        ({
            ($_ -eq 'double') -or
            ($_ -eq 'float') -or
            ($_ -eq 'decimal')
        }) {
            $field_type_id = 5
            $field_type = 'decimal'
            break
        }
        ({
            ($_ -eq 'int') -or
            ($_ -eq 'int16') -or
            ($_ -eq 'int32') -or
            ($_ -eq 'int64')
        }) {
            $field_type_id = 4
            $field_type = 'number'
            break
        }
        ({
            ($_ -eq 'string') -or
            ($_ -eq 'char') -or
            ($_ -eq 'text')
        }) {
            $field_type_id = 3
            $field_type = 'string'
            break
        }
        ({
            ($_ -eq 'datetime') -or
            ($_ -eq 'timestamp')
        }) {
            $field_type_id = 12
            $field_type = 'ts'
            break
        }
        ({
            ($_ -eq 'object[]') -or
            ($_ -eq 'string[]') -or
            ($_ -eq 'int[]') -or
            ($_ -eq 'array') -or
            ($_ -eq 'list')
        }) {
            $field_type_id = 7
            $field_type = 'list'
            break
        }
        ({
            ($_ -eq 'bool') -or
            ($_ -eq 'boolean')
        }) {
            $field_type_id = 10
            $field_type = 'bool'
            break
        }
        Default {
            $field_type_id = 6
            $field_type = 'object'
        }
    }
    return @($field_type_id,$field_type)
}

function session_cache_init {
    Param (
        [Parameter(Mandatory=$false)][Int]$expires_sec = 86400 #24hrs by default
    )

    $cache_host = 'localhost'
    $cache_port = 11211
    $data_value = ''
    $encoding = New-Object System.Text.AsciiEncoding
    $buffer = New-Object System.Byte[] 1024

    $socket = New-Object System.Net.Sockets.TcpClient("$($cache_host)", $cache_port)
    if ($null -eq $socket) {
        return
    }
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $command = 'get fieldsets_session_cache'
    $writer.WriteLine($command)
    $writer.Flush()
    $cache_initialized = $false

    while ($stream.DataAvailable) {
        $read = $stream.Read($buffer, 0, 1024)
        $readline_value = ($encoding.GetString($buffer, 0, $read)).Trim(" ","`r","`n","`t")
        if (
            ("$($readline_value)".Length -gt 0 ) -and
            (!($readline_value.StartsWith('VALUE fieldsets_session_cache'))) -and
            ($readline_value -ne 'END')
        ) {
            $data_value = "$($data_value)$($readline_value)"
        }
    }

    if ($data_value.Length -gt 0) {
        $cache_initialized = $true
    } else {
        $cache_initialized = $false
    }

    if ($false -eq $cache_initialized) {
        $data_value = ConvertTo-Json -InputObject @{'initialized' = $true}
        $data_value_bytes = [System.Text.Encoding]::ASCII.GetBytes($data_value)
        $command = "set fieldsets_session_cache 6 $($expires_sec) $($data_value_bytes.Length)`r`n$($data_value)`r`n"
        $writer.WriteLine($command)
        $writer.Flush()
    }
    $socket.Close()

    return $data_value
}


function session_cache_set {
    Param(
        [Parameter(Mandatory=$true)][String]$key,
        [Parameter(Mandatory=$true)][PSCustomObject]$value,
        [Parameter(Mandatory=$false)][Int]$expires_sec = 86400 #24hrs by default
    )
    $cache_host = 'localhost'
    $cache_port = 11211
    $data_value = ''

    $socket = New-Object System.Net.Sockets.TcpClient("$($cache_host)", $cache_port)
    if ($null -eq $socket) {
        return
    }
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)

    $data_value = $value
    $data_type = $value.GetType().Name
    $field_type = getFieldType -data_type $data_type
    $data_value_json = ConvertTo-Json -InputObject $data_value -Compress
    $data_value_bytes = [System.Text.Encoding]::ASCII.GetBytes($data_value_json)
    $command = "set $($key) $($field_type[0]) $($expires_sec) $($data_value_bytes.Length)"
    $command_data = $data_value_json
    $writer.WriteLine($command)
    $writer.WriteLine($command_data)
    $writer.Flush()

    $socket.Close()
    return
}


function session_cache_get {
    Param(
        [Parameter(Mandatory=$true)][String]$key
    )
    $cache_host = 'localhost'
    $cache_port = 11211
    $data_value = ''
    $encoding = New-Object System.Text.AsciiEncoding
    $buffer = New-Object System.Byte[] 1024

    $socket = New-Object System.Net.Sockets.TcpClient("$($cache_host)", $cache_port)
    if ($null -eq $socket) {
        return
    }
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $command = "get $($key)"
    $writer.WriteLine($command)
    $writer.Flush()

    $reader = New-Object System.IO.StreamReader($stream)
    while ($stream.DataAvailable) {
        $read = $reader.ReadLine()
        $readline_value = ($encoding.GetString($buffer, 0, $read)).Trim(" ","`r","`n","`t")
        Write-Host $readline_value
        #if (
        #    ("$($readline_value)".Length -gt 0 ) -and
        #    (!($readline_value.StartsWith('VALUE fieldsets_session_cache'))) -and
        #    ($readline_value -ne 'END')
        #) {
            $data_value = "$($data_value)$($readline_value)"
        #}
    }
    $socket.Close()
    if ("$($data_value)".Length -gt 0) {
        $return_val = ConvertFrom-Json -InputObject $data_value -Compress
        return $return_val
    } else {
        return
    }
}

function session_cache_delete {
    Param(
        [Parameter(Mandatory=$true)][String]$key
    )
    $cache_host = 'localhost'
    $cache_port = 11211
    $socket = New-Object System.Net.Sockets.TcpClient("$($cache_host)", $cache_port)
    if ($null -eq $socket) {
        return
    }
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $command = "delete $($key)"
    $writer.WriteLine($command)
    $writer.Flush()
    $socket.Close()
    return
}

function session_cache_flush {
    $cache_host = 'localhost'
    $cache_port = 11211
    $socket = New-Object System.Net.Sockets.TcpClient("$($cache_host)", $cache_port)
    if ($null -eq $socket) {
        return
    }
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $command = "flush_all "
    $writer.WriteLine($command)
    $writer.Flush()
    $socket.Close()
    return
}


#session_cache_delete -key 'fieldsets_session_cache'

#session_cache_flush

$init_check = session_cache_init

#Write-Output $init_check

session_cache_set -key 'mykey' -value 4.3212

$value_check = session_cache_get -key 'mykey'

Write-Output $value_check

Exit
