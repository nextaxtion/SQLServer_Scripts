##Get-Credential | Export-Clixml C:\Temp\credemail.xml

##Importando as credencias para conexão com o servidor SMTP
$cred = Import-Clixml C:\Temp\cred.xml 

##Executando Teste de Backup e salvando resultado em variavel
$ResultTestBackup = Test-DbaLastBackup -SqlServer DESKTOP-A7S2JPV\SQLSERVER2016 -Database SQLDAYES,master -WarningVariable Warnings -IgnoreLogBackup

##Exportando resultado para arquivo .txt que será enviado por e-mail
$ResultTestBackup > 'C:\temp\ResultEmail.txt'
$Warnings >>  'C:\temp\ResultEmail.txt'

##Declarando e zerando a variável
$ResultTestHtml = ""

##variável de controle
$count = 0

##Transformando objetos em HTML para enviar no corpo do e-mail
ForEach($obj in $ResultTestBackup)
{   
    if($count.Equals(0)) ##Adiciona a Header
    {     
        $ResultTestHtml +=  ConvertTo-Html -InputObject $obj -As List -Head '<h1 style="color:blue;">Test Last Backup: SUCCEED</h1>'         
    }
    else
    {
        $ResultTestHtml += "<br></br>"        
        $ResultTestHtml +=  ConvertTo-Html -InputObject $obj -As List 
    }    
    $count +=1
}


##Convertendo para string para ser enviado ao parametro -Body do comando Send-MailMessage, retirando informações irrelevantes 
$ResultTestHtml = [string]$ResultTestHtml.Replace('<tr><td>BackupDate:</td><td>System.Object[]</td></tr>','').Replace('<tr><td>BackupFiles:</td><td>System.Object[]</td></tr>','')

##Verificando se houve erros, se houver troca mensagem na Header
if($ResultTestHtml.Contains("Failure") -or $ResultTestHtml.Contains("error"))
{
    $ResultTestHtml = $ResultTestHtml.ToString().Replace('<h1 style="color:blue;">Test Last Backup: SUCCEED</h1>','<h1 style="color:red;">Test Last Backup: FAILED</h1>')
}

##Envia E-mail com arquivo .txt em anexo e corpo HTML
Send-MailMessage -Credential $cred -SmtpServer "smtp.office365.com" -To "reginaldo.silva@dataside.com.br" -From "reginaldo.silva@dataside.com.br" -Subject "Test Last Backup - Dbatools" -UseSsl -Body $ResultTestHtml -BodyAsHtml -Attachments 'C:\temp\ResultEmail.txt' -Priority High


