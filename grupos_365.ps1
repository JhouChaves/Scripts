# Importar o módulo Exchange Online Management
Import-Module ExchangeOnlineManagement

# Conectar ao Microsoft 365
Connect-ExchangeOnline

# Obter todos os grupos de distribuição
$groups = Get-DistributionGroup -ResultSize Unlimited

# Inicializar uma lista vazia para armazenar os resultados
$results = @()

# Loop através de cada grupo de distribuição
foreach ($group in $groups) {
    # Obter os membros do grupo de distribuição
    $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited
    
    # Loop através de cada membro
    foreach ($member in $members) {
        # Criar um objeto personalizado com os detalhes do grupo e membro
        $result = New-Object -TypeName PSObject
        $result | Add-Member -MemberType NoteProperty -Name "Grupo" -Value $group.Name
        $result | Add-Member -MemberType NoteProperty -Name "Membro" -Value $member.Name
        
        # Adicionar o objeto à lista de resultados
        $results += $result
    }
}

# Exportar os resultados para um arquivo CSV
$results | Export-Csv -Path "C:\Users\Jhonathan\Desktop\LBGS-Grupos\grupos.csv" -NoTypeInformation
