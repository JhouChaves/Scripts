function ConvertTo-HumanReadableSize {
    param([Parameter(Mandatory = $true)][long]$SizeInBytes)

    $sizeSuffixes = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0

    while ($SizeInBytes -ge 1024 -and $index -lt ($sizeSuffixes.Length - 1)) {
        $SizeInBytes /= 1024
        $index++
    }

    "{0:N2} {1}" -f $SizeInBytes, $sizeSuffixes[$index]
}

# Diret�rio que voc� deseja analisar
$diretorio = "E:\Compartilhamentos\JURIDICO"

# Data limite para determinar se um arquivo n�o foi utilizado nos �ltimos 5 anos
$dataLimite = (Get-Date).AddYears(-5)

# Obter todos os arquivos do diret�rio e subdiret�rios
$arquivos = Get-ChildItem -Path $diretorio -Recurse | Where-Object { $_.PSIsContainer -eq $false }

# Filtrar os arquivos com base na data de acesso ou modifica��o
$arquivosNaoUtilizados = $arquivos | Where-Object { $_.LastAccessTime -lt $dataLimite -or $_.LastWriteTime -lt $dataLimite }

# Contar o n�mero de arquivos
$numeroDeArquivos = $arquivosNaoUtilizados.Count

# Calcular o tamanho total dos arquivos n�o utilizados
$tamanhoTotal = ($arquivosNaoUtilizados | Measure-Object -Property Length -Sum).Sum

# Converter o tamanho para uma unidade leg�vel por humanos
$tamanhoTotalLegivel = ConvertTo-HumanReadableSize $tamanhoTotal

# Exibir os resultados
Write-Host "N�mero de arquivos n�o utilizados: $numeroDeArquivos"
Write-Host "Tamanho total dos arquivos n�o utilizados: $tamanhoTotalLegivel"

# Exportar os resultados para um arquivo CSV
$resultados = $arquivosNaoUtilizados | Select-Object Name, FullName, @{Name="Tamanho";Expression={ConvertTo-HumanReadableSize $_.Length}}, LastAccessTime, LastWriteTime
$resultados | Export-Csv -Path "C:\Verificar Arquivos Nao Utilizados\arquivo.csv" -NoTypeInformation
