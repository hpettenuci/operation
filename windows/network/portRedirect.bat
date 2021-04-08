# Doc usada para o comando: http://woshub.com/port-forwarding-in-windows/
# Doc do Netsch para uso do portproxy: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc731068(v=ws.10)?redirectedfrom=MSDN
#
netsh interface portproxy add v4tov4 listenport=58458 listenaddress=0.0.0.0 connectport=1433 connectaddress=127.0.0.1