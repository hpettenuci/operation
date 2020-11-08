# Antes de iniciar o procedimento, o certificado pfx deve ser instalado, assim como sua árvore de certificados da CA
# Nos detalhes do certificado existe a informação Thumbnail, que conterá a informação a ser utilizada no parâmetro certhash

# É necessário obter o appid atual através do comando abaixo
netsh http show sslcert 

# Remove SSL da porta 62300
netsh http delete sslcert ipport=0.0.0.0:62300

# Cria Novo
netsh http add sslcert ipport=0.0.0.0:62300 certhash=<cert thumbnail> appid=<ID da aplicação> clientcertnegotiation=enable