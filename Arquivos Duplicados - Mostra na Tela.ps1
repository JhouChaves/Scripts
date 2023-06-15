# Diretório raiz a ser verificado
$diretorioRaiz = "E:\Compartilhamentos"

# Obter todos os arquivos do diretório raiz e suas subpastas
$arquivos = Get-ChildItem $diretorioRaiz -Recurse | Where-Object {!$_.PSIsContainer}

# Dicionário para armazenar o hash do arquivo e o caminho completo do arquivo
$hashes = @{}

# Percorrer cada arquivo e comparar os hashes
foreach ($arquivo in $arquivos) {
    $hash = Get-FileHash $arquivo.FullName | Select-Object -ExpandProperty Hash
    
    # Verificar se o hash já existe no dicionário
    if ($hashes.ContainsKey($hash)) {
        # O arquivo é um duplicado, exibir o caminho completo
        Write-Output "Arquivo duplicado: $($arquivo.FullName)"
        Write-Output "Já existente em: $($hashes[$hash])"
    } else {
        # Adicionar o hash e o caminho completo ao dicionário
        $hashes[$hash] = $arquivo.FullName
    }
}
