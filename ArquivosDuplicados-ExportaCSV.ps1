# Diret�rio raiz a ser verificado
$diretorioRaiz = "E:\Compartilhamentos"

# Caminho do arquivo CSV de sa�da
$csvPath = "E:\Compartilhamentos\Arquivo.csv"

# Obter todos os arquivos do diret�rio raiz e suas subpastas
$arquivos = Get-ChildItem $diretorioRaiz -Recurse | Where-Object {!$_.PSIsContainer}

# Dicion�rio para armazenar o hash do arquivo e o caminho completo do arquivo
$hashes = @{}

# Lista para armazenar os resultados dos arquivos duplicados
$resultados = @()

# Percorrer cada arquivo e comparar os hashes
foreach ($arquivo in $arquivos) {
    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $stream = [System.IO.File]::OpenRead($arquivo.FullName)
    $hash = [System.BitConverter]::ToString($hasher.ComputeHash($stream)).Replace("-", "")
    $stream.Close()

    # Verificar se o hash j� existe no dicion�rio
    if ($hashes.ContainsKey($hash)) {
        # O arquivo � um duplicado, adicionar o resultado � lista
        $resultado = [PSCustomObject]@{
            ArquivoDuplicado = $arquivo.FullName
            JaExistenteEm = $hashes[$hash]
            Tamanho = $arquivo.Length
        }
        $resultados += $resultado
    } else {
        # Adicionar o hash e o caminho completo ao dicion�rio
        $hashes[$hash] = $arquivo.FullName
    }
}

# Verificar se h� resultados antes de exportar para o arquivo CSV
if ($resultados.Count -gt 0) {
    # Criar manualmente o conte�do do arquivo CSV
    $csvContent = "ArquivoDuplicado,JaExistenteEm,Tamanho`n"
    foreach ($resultado in $resultados) {
        $csvContent += "$($resultado.ArquivoDuplicado),$($resultado.JaExistenteEm),$($resultado.Tamanho)`n"
    }

    # Gravar o conte�do no arquivo CSV
    $csvContent | Out-File -FilePath $csvPath -Encoding UTF8
    Write-Output "Arquivo CSV exportado com sucesso: $csvPath"
} else {
    Write-Output "Nenhum arquivo duplicado encontrado."
}
