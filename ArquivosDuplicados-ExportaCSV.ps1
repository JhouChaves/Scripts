# Diretório raiz a ser verificado
$diretorioRaiz = "E:\Compartilhamentos"

# Caminho do arquivo CSV de saída
$csvPath = "E:\Compartilhamentos\Arquivo.csv"

# Obter todos os arquivos do diretório raiz e suas subpastas
$arquivos = Get-ChildItem $diretorioRaiz -Recurse | Where-Object {!$_.PSIsContainer}

# Dicionário para armazenar o hash do arquivo e o caminho completo do arquivo
$hashes = @{}

# Lista para armazenar os resultados dos arquivos duplicados
$resultados = @()

# Percorrer cada arquivo e comparar os hashes
foreach ($arquivo in $arquivos) {
    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $stream = [System.IO.File]::OpenRead($arquivo.FullName)
    $hash = [System.BitConverter]::ToString($hasher.ComputeHash($stream)).Replace("-", "")
    $stream.Close()

    # Verificar se o hash já existe no dicionário
    if ($hashes.ContainsKey($hash)) {
        # O arquivo é um duplicado, adicionar o resultado à lista
        $resultado = [PSCustomObject]@{
            ArquivoDuplicado = $arquivo.FullName
            JaExistenteEm = $hashes[$hash]
            Tamanho = $arquivo.Length
        }
        $resultados += $resultado
    } else {
        # Adicionar o hash e o caminho completo ao dicionário
        $hashes[$hash] = $arquivo.FullName
    }
}

# Verificar se há resultados antes de exportar para o arquivo CSV
if ($resultados.Count -gt 0) {
    # Criar manualmente o conteúdo do arquivo CSV
    $csvContent = "ArquivoDuplicado,JaExistenteEm,Tamanho`n"
    foreach ($resultado in $resultados) {
        $csvContent += "$($resultado.ArquivoDuplicado),$($resultado.JaExistenteEm),$($resultado.Tamanho)`n"
    }

    # Gravar o conteúdo no arquivo CSV
    $csvContent | Out-File -FilePath $csvPath -Encoding UTF8
    Write-Output "Arquivo CSV exportado com sucesso: $csvPath"
} else {
    Write-Output "Nenhum arquivo duplicado encontrado."
}
