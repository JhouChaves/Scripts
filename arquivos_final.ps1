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

# Diretório que você deseja analisar
$diretorio = "E:\Compartilhamentos\JURIDICO"

# Data limite para determinar se um arquivo não foi utilizado nos últimos 2 anos
$dataLimite = (Get-Date).AddYears(-2)

# Obter todos os arquivos do diretório e subdiretórios
$arquivos = Get-ChildItem -Path $diretorio -Recurse | Where-Object { $_.PSIsContainer -eq $false }

# Filtrar os arquivos com base na data de acesso ou modificação
$arquivosNaoUtilizados = $arquivos | Where-Object { $_.LastAccessTime -lt $dataLimite -or $_.LastWriteTime -lt $dataLimite }

# Contar o número de arquivos
$numeroDeArquivos = $arquivosNaoUtilizados.Count

# Calcular o tamanho total dos arquivos não utilizados
$tamanhoTotal = ($arquivosNaoUtilizados | Measure-Object -Property Length -Sum).Sum

# Converter o tamanho para uma unidade legível por humanos
$tamanhoTotalLegivel = ConvertTo-HumanReadableSize $tamanhoTotal

# Exibir os resultados
Write-Host "Número de arquivos não utilizados: $numeroDeArquivos"
Write-Host "Tamanho total dos arquivos não utilizados: $tamanhoTotalLegivel"

# Exportar os resultados para um arquivo CSV
$resultados = $arquivosNaoUtilizados | Select-Object Name, FullName, @{Name="Tamanho";Expression={ConvertTo-HumanReadableSize $_.Length}}, LastAccessTime, LastWriteTime
$resultados | Export-Csv -Path "C:\Verificar Arquivos Nao Utilizados\arquivo.csv" -NoTypeInformation
